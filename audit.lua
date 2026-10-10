-------------------------------------------------------------------------------------------------------------------
-- gs audit takes gs test's arguments: it runs the test, sends /checkparam <me>, and appends what the client was
-- told about the gear to data/audit/<Character>.jsonl, one JSON object a line.
--
-- Two packets carry the numbers. The char-stats packet (0x061), which the server sends after the gear changes,
-- has STR to CHR, attack, defense, the elemental resistances, max HP and MP, and master level. /checkparam
-- answers with action messages (0x029) for accuracy and attack by hand, ranged, and evasion and defense.
-- Nothing the client gets shows haste, fast cast, magic accuracy or damage taken.
-------------------------------------------------------------------------------------------------------------------

-- How long the char-stats packets must stop for the gear to count as on, how long to wait for the first one
-- (gear that is already on sends none), and how long /checkparam's lines must stop before the record is written.
local audit_settle_seconds = 1
local audit_stats_timeout = 3
local audit_checkparam_seconds = 1.5

local checkparam_messages = {
    [712] = {'primary', 'accuracy', 'attack'},
    [713] = {'auxiliary', 'accuracy', 'attack'},
    [714] = {'ranged', 'accuracy', 'attack'},
    [715] = {'evasion_defense', 'evasion', 'defense'},
}

local stat_names = {'str', 'dex', 'vit', 'agi', 'int', 'mnd', 'chr'}
-- The order the char-stats packet holds them in, as Windower's packets/fields.lua gives it. GearSwap's own
-- parse of 0x061 in packet_parsing.lua names them in another order.
local resistance_names = {'fire', 'ice', 'wind', 'earth', 'lightning', 'water', 'light', 'dark'}

-- audit_pending is the audit waiting on packets; audit_token makes a superseded audit's timers stale.
local audit_pending, audit_token = nil, 0

local function notice(text)
    msg.addon_msg(123, 'Audit: '..text)
end

-- Offsets are 1-based, as string.unpack takes them: fields.lua's offset plus one.
local function parse_char_stats(data)
    local stats, added, resistances = {}, {}, {}
    for i, name in ipairs(stat_names) do
        local base = data:unpack('H', 0x15 + 2*(i-1))
        added[name] = data:unpack('h', 0x23 + 2*(i-1))
        stats[name] = base + added[name]
    end
    for i, name in ipairs(resistance_names) do
        resistances[name] = data:unpack('h', 0x35 + 2*(i-1))
    end
    return {
        max_hp = data:unpack('I', 0x05),
        max_mp = data:unpack('I', 0x09),
        master_level = data:byte(0x66),
        stats = stats,
        stats_from_gear_and_buffs = added,
        attack = data:unpack('H', 0x31),
        defense = data:unpack('H', 0x33),
        resistances = resistances,
    }
end

local json_escapes = {['"'] = '\\"', ['\\'] = '\\\\', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t'}

local function json_string(s)
    return '"'..s:gsub('[%c"\\]', function(c)
        return json_escapes[c] or ('\\u%04x'):format(c:byte())
    end)..'"'
end

-- Arrays are tables with only keys 1..n. An empty table is written as an object unless it carries json_array.
-- Object keys are sorted so the lines diff well.
local json_array = {}

local function to_json(value)
    local kind = type(value)
    if kind == 'string' then return json_string(value) end
    if kind == 'number' or kind == 'boolean' then return tostring(value) end
    if kind ~= 'table' then return 'null' end
    local count = 0
    for _ in pairs(value) do count = count + 1 end
    if count == #value and (count > 0 or getmetatable(value) == json_array) then
        local parts = {}
        for i, v in ipairs(value) do parts[i] = to_json(v) end
        return '['..table.concat(parts, ',')..']'
    end
    local keys = {}
    for k in pairs(value) do keys[#keys+1] = k end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    local parts = {}
    for i, k in ipairs(keys) do parts[i] = json_string(tostring(k))..':'..to_json(value[k]) end
    return '{'..table.concat(parts, ',')..'}'
end

local function audit_record(pending)
    local p = windower.ffxi.get_player()
    local record = {
        date = os.date('%Y-%m-%dT%H:%M:%S'),
        character = p.name,
        args = pending.args,
        job = {
            main = p.main_job,
            main_level = p.main_job_level,
            sub = p.sub_job,
            sub_level = p.sub_job_level,
        },
        checkparam = pending.checkparam,
    }

    local data = windower.packets.last_incoming(0x061)
    if data then
        local char_stats = parse_char_stats(data)
        record.job.master_level = char_stats.master_level
        char_stats.master_level = nil
        record.char_stats = char_stats
    end
    -- false: no stats packet came after the gear went on, so char_stats may predate it.
    record.char_stats_fresh = pending.stats_seen

    refresh_globals()
    record.gear = {}
    for slot, name in pairs(player.equipment) do record.gear[slot] = name end

    record.buffs = setmetatable({}, json_array)
    for _, id in ipairs(p.buffs) do
        if res.buffs[id] then record.buffs[#record.buffs+1] = res.buffs[id][language] end
    end
    return record
end

local function audit_write(pending)
    audit_pending = nil
    if not windower.ffxi.get_player() then
        notice('dropped: no player to read (logged out or zoning).')
        return
    end
    local record = audit_record(pending)
    local dir = windower.addon_path..'data/audit'
    if not windower.dir_exists(dir) then windower.create_dir(dir) end
    local path = dir..'/'..record.character..'.jsonl'
    local f = io.open(path, 'a')
    if not f then
        notice('could not open '..path..'.')
        return
    end
    f:write(to_json(record), '\n')
    f:close()
    if not record.char_stats then
        notice('no char stats packet has been seen; the record has /checkparam only.')
    elseif not record.char_stats_fresh then
        notice('no char stats update came, so char_stats is the last one seen (fine if the gear was already on).')
    end
    if not next(pending.checkparam) then
        notice('no /checkparam lines came back; the record has the char stats only.')
    end
    notice('appended to data/audit/'..record.character..'.jsonl.')
end

-- Each call restarts the wait, so the record is written once the lines stop coming.
local function audit_schedule(pending, seconds, fn)
    audit_token = audit_token + 1
    local token = audit_token
    coroutine.schedule(function()
        if token == audit_token and audit_pending == pending then fn(pending) end
    end, seconds)
end

local function audit_checkparam(pending)
    pending.stage = 'checkparam'
    windower.chat.input('/checkparam <me>')
    audit_schedule(pending, audit_checkparam_seconds, audit_write)
end

windower.register_event('incoming chunk', function(id, data, modified, injected)
    local pending = audit_pending
    if injected or not pending then return end
    if id == 0x061 and pending.stage == 'gear' then
        pending.stats_seen = true
        audit_schedule(pending, audit_settle_seconds, audit_checkparam)
    elseif id == 0x029 and pending.stage == 'checkparam' then
        local fields = checkparam_messages[data:unpack('H', 0x19) % 32768]
        local actor, target = data:unpack('I', 0x05), data:unpack('I', 0x09)
        if fields and (actor == pending.player_id or target == pending.player_id) then
            pending.checkparam[fields[1]] = {
                [fields[2]] = data:unpack('I', 0x0D),
                [fields[3]] = data:unpack('I', 0x11),
            }
            audit_schedule(pending, audit_checkparam_seconds, audit_write)
        end
    end
end)

-- Called by whatever can change the gear before the record is written: gs test, a bare gs enable or gs disable,
-- a user file load, and the end of the test hold.
function audit_cancel()
    audit_pending = nil
end

function audit_command(args)
    audit_cancel()
    if not test_command(args) then return end
    audit_pending = {
        args = {unpack(args)},
        stage = 'gear',
        stats_seen = false,
        player_id = windower.ffxi.get_player().id,
        checkparam = {},
    }
    audit_schedule(audit_pending, audit_stats_timeout, audit_checkparam)
end
