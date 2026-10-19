-------------------------------------------------------------------------------------------------------------------
-- A stand-in for the game and for the Windower API an addon sees: one character in a field zone, its bags and
-- gear, a monster to target, and the server's side of equipping.
--
-- Nothing happens on its own. What the addon sends (packets, commands, chat input) waits in a queue, as it would
-- for the next frame, and settle() handles it: an equip request is carried out and confirmed with the packets the
-- server answers with, a command runs, input goes through the outgoing text event. advance(seconds) moves the clock
-- on, runs the timers that fall due (coroutine.schedule, @wait) and settles after each. The tests say when the
-- server answers an action (finish_action, interrupt_action) and when a buff comes or goes.
--
-- The game reads its items, spells and abilities from the resources it is given: the raw tables of Windower's
-- resource files, with jobs, slots and races still bit masks.
-------------------------------------------------------------------------------------------------------------------

local lfs = require('lfs')

local real_coroutine = coroutine

local Game = {}
Game.__index = Game

local slot_names = {[0] = 'main', 'sub', 'range', 'ammo', 'head', 'body', 'hands', 'legs', 'feet', 'neck', 'waist',
    'left_ear', 'right_ear', 'left_ring', 'right_ring', 'back'}
local slot_ids = {}
for id, name in pairs(slot_names) do
    slot_ids[name] = id
end
Game.slot_names = slot_names
Game.slot_ids = slot_ids

local function copy(value)
    if type(value) ~= 'table' then
        return value
    end
    local result = {}
    for k, v in pairs(value) do
        result[k] = copy(v)
    end
    return result
end
Game.copy = copy

local function has_bit(mask, index)
    return math.floor((mask or 0) / 2 ^ index) % 2 == 1
end
Game.has_bit = has_bit

-- The entry with that name, short or long; of several, the one with the lowest id.
local function find_by_name(resource, name, kind)
    local lowered = name:lower()
    local found
    for id, entry in pairs(resource) do
        if type(entry) == 'table' and (entry.en and entry.en:lower() == lowered or entry.enl and entry.enl:lower() == lowered)
            and (not found or id < found) then
            found = id
        end
    end
    if not found then
        error(('the test resources have no %s named %q'):format(kind, name), 3)
    end
    return found, resource[found]
end

-- Windower lists a path's entries by their names on disk. GearSwap runs on Windows, where a file's name matches in
-- any case, and asks for files by names it lowered; the files keep their case on disk.
local function resolve(path)
    if lfs.attributes(path) then
        return path
    end
    local absolute = path:sub(1, 1) == '/'
    local resolved = absolute and '' or '.'
    for part in path:gmatch('[^/\\]+') do
        local exact = resolved .. '/' .. part
        if lfs.attributes(exact) then
            resolved = exact
        else
            local found
            if lfs.attributes(resolved, 'mode') == 'directory' then
                for entry in lfs.dir(resolved) do
                    if entry:lower() == part:lower() then
                        found = resolved .. '/' .. entry
                        break
                    end
                end
            end
            if not found then
                return nil
            end
            resolved = found
        end
    end
    if not absolute then
        resolved = resolved:sub(3)
    end
    return resolved
end
Game.resolve = resolve

local function packet_header(id, size, sequence)
    local words = math.ceil(size / 4)
    return string.char(id % 256, math.floor(id / 256) % 2 + 2 * words, sequence % 256, math.floor(sequence / 256) % 256)
end

local function pad(data, size)
    return data .. string.char(0):rep(size - #data)
end

local function u16(value)
    return string.char(value % 256, math.floor(value / 256) % 256)
end

local function u32(value)
    value = value % 2 ^ 32
    return string.char(value % 256, math.floor(value / 256) % 256, math.floor(value / 65536) % 256, math.floor(value / 16777216) % 256)
end

local function read_u16(data, position)
    return data:byte(position) + 256 * data:byte(position + 1)
end

local function read_u32(data, position)
    return read_u16(data, position) + 65536 * read_u16(data, position + 2)
end

-- options: res (the raw resource tables), paths (addon and windower, for the API), name, id, index, main_job,
-- main_job_level, sub_job, sub_job_level, race, status, zone, items ({name=, bag=, extdata=, count=}, bag by its API
-- name, inventory unless given), wearing (slot name to the item's position in items), buffs (names), spells and
-- abilities (the names known; every one the resources hold unless given), tp (0 unless given).
function Game.new(options)
    local game = setmetatable({}, Game)
    game.res = options.res
    -- os.clock in Windower counts from the game's start, long before an addon loads; Sel takes a clock near 0 for
    -- an action that has only just begun.
    game.clock = 1000
    game.sequence = 0
    game.next_event_id = 1
    game.handlers = {}
    game.timers = {}
    game.queue = {}
    game.sent = {}
    game.actions = {}
    game.typed = {}
    game.commands = {}
    game.chat_log = {}
    game.last_packets = {incoming = {}, outgoing = {}}
    game.action_tables = {}

    local res = game.res
    local function job_id(short)
        for id, job in pairs(res.jobs) do
            if type(job) == 'table' and job.ens == short then
                return id
            end
        end
        error(('the test resources have no job %q'):format(short), 3)
    end
    local main_job_id = job_id(options.main_job or 'WHM')
    local sub_job_id = options.sub_job and job_id(options.sub_job) or 0
    local jobs = {}
    for id, job in pairs(res.jobs) do
        if type(job) == 'table' and job.ens then
            jobs[job.ens] = id == main_job_id and (options.main_job_level or 99)
                or id == sub_job_id and (options.sub_job_level or 49) or 1
        end
    end
    local job_points = {}
    for _, job in pairs(res.jobs) do
        if type(job) == 'table' and job.ens and job.ens ~= 'NON' then
            job_points[job.ens:lower()] = {jp = 0, jp_spent = 2100, cp = 0}
        end
    end

    game.player = {
        id = options.id or 0x100001,
        index = options.index or 0x400,
        name = options.name or 'Testy',
        main_job_id = main_job_id,
        main_job_level = options.main_job_level or 99,
        sub_job_id = sub_job_id,
        sub_job_level = sub_job_id ~= 0 and (options.sub_job_level or 49) or 0,
        jobs = jobs,
        job_points = job_points,
        superior_level = 5,
        item_level = 119,
        race = options.race or 1,
        status = options.status or 0,
        nation = 0,
        vitals = {hp = 1500, mp = 1000, max_hp = 1500, max_mp = 1000, hpp = 100, mpp = 100, tp = options.tp or 0},
        buffs = {},
        skills = {},
        merits = {},
    }
    for _, name in ipairs(options.buffs or {}) do
        game.player.buffs[#game.player.buffs + 1] = (find_by_name(res.buffs, name, 'buff'))
    end

    game.zone = options.zone or 288
    game.monster = {
        id = 0x1069001, index = 0x001, name = 'Apex Toad', is_npc = true, spawn_type = 16, race = 0, status = 0,
        hpp = 100, distance = 9, x = 3, y = 0, z = 0, facing = 0, claim_id = 0, valid_target = true,
        model_size = 1, target_index = 0,
    }
    game.target_index = game.monster.index

    game.spells = {}
    if options.spells then
        for _, name in ipairs(options.spells) do
            game.spells[(find_by_name(res.spells, name, 'spell'))] = true
        end
    else
        for id in pairs(res.spells) do
            game.spells[id] = true
        end
    end
    game.job_abilities, game.weapon_skills = {}, {}
    local abilities = options.abilities
    for id, ability in pairs(res.job_abilities) do
        if type(ability) == 'table' and (not abilities or abilities[ability.en]) then
            game.job_abilities[#game.job_abilities + 1] = id
        end
    end
    for id, skill in pairs(res.weapon_skills) do
        if type(skill) == 'table' and (not abilities or abilities[skill.en]) then
            game.weapon_skills[#game.weapon_skills + 1] = id
        end
    end
    table.sort(game.job_abilities)
    table.sort(game.weapon_skills)

    game.bags = {}
    for id, bag in pairs(res.bags) do
        if type(bag) == 'table' then
            game.bags[id] = {api = bag.api, max = 80, items = {}}
        end
    end
    game.equipment = {}
    local placed = {}
    for position, item in ipairs(options.items or {}) do
        local bag_id = assert(game:bag_id(item.bag or 'inventory'), ('no bag named %s'):format(tostring(item.bag)))
        local item_id = find_by_name(res.items, item.name, 'item')
        local bag = game.bags[bag_id]
        local slot = #bag.items + 1
        bag.items[slot] = {id = item_id, count = item.count or 1, status = 0, slot = slot, bazaar = 0,
            extdata = item.extdata or string.char(0):rep(24)}
        placed[position] = {bag = bag_id, slot = slot}
    end
    for slot_name, position in pairs(options.wearing or {}) do
        local spot = placed[position]
        game.equipment[slot_ids[slot_name]] = spot
        game.bags[spot.bag].items[spot.slot].status = 5
    end

    game.windower = game:make_windower(options.paths)
    return game
end

-------------------------------------------------------------------------------------------------------------------
-- The state the Windower API reports. Each call hands out a new table, as Windower's do, since GearSwap writes into
-- the ones it gets.
-------------------------------------------------------------------------------------------------------------------

function Game:job_names(id)
    local job = self.res.jobs[id]
    return job and job.ens or 'NON', job and job.en or 'None'
end

function Game:get_player()
    local player = copy(self.player)
    player.main_job, player.main_job_full = self:job_names(player.main_job_id)
    if player.sub_job_id ~= 0 then
        player.sub_job, player.sub_job_full = self:job_names(player.sub_job_id)
    else
        player.sub_job_id, player.sub_job_level = nil, nil
    end
    player.target_index = self.target_index
    player.in_combat = self.player.status == 1
    return player
end

function Game:player_mob()
    local player = self.player
    return {
        id = player.id, index = player.index, name = player.name, is_npc = false, spawn_type = 13, race = player.race,
        status = player.status, hpp = player.vitals.hpp, mpp = player.vitals.mpp, tp = player.vitals.tp,
        distance = 0, x = self:player_x(), y = 0, z = 0, facing = 0, claim_id = 0, valid_target = true, in_party = true,
        in_alliance = true, model_size = 1, target_index = self.target_index or 0,
    }
end

function Game:mobs()
    local mobs = {[self.player.index] = self:player_mob()}
    if self.monster then
        mobs[self.monster.index] = copy(self.monster)
    end
    return mobs
end

function Game:mob_by_target(target)
    target = (target or ''):lower():gsub('^<(.*)>$', '%1')
    if target == 'me' or target == 'self' then
        return self:player_mob()
    elseif (target == 't' or target == 'bt') and self.target_index then
        return self:mobs()[self.target_index]
    end
end

function Game:mob_by_id(id)
    for _, mob in pairs(self:mobs()) do
        if mob.id == id then
            return mob
        end
    end
end

function Game:items_of(bag_id)
    local bag = self.bags[bag_id]
    local list = {max = bag.max, count = #bag.items, enabled = true}
    for slot = 1, bag.max do
        list[slot] = copy(bag.items[slot]) or {id = 0, count = 0, status = 0, slot = slot, bazaar = 0, extdata = string.char(0):rep(24)}
    end
    return list
end

function Game:bag_id(name)
    if type(name) == 'number' then
        return name
    end
    for id, bag in pairs(self.bags) do
        if bag.api == name then
            return id
        end
    end
end

function Game:get_items(bag, index)
    if bag then
        local list = self:items_of(self:bag_id(bag))
        if index then
            return list[index]
        end
        return list
    end
    local all = {equipment = {}, gil = 0}
    for id, data in pairs(self.bags) do
        all[data.api] = self:items_of(id)
        all['count_' .. data.api], all['max_' .. data.api], all['enabled_' .. data.api] = #data.items, data.max, true
    end
    for id, name in pairs(slot_names) do
        local spot = self.equipment[id]
        all.equipment[name] = spot and spot.slot or 0
        all.equipment[name .. '_bag'] = spot and spot.bag or 0
    end
    return all
end

function Game:get_bag_info()
    local info = {}
    for _, bag in pairs(self.bags) do
        info[bag.api] = {max = bag.max, count = #bag.items, enabled = true}
    end
    return info
end

function Game:get_info()
    return {logged_in = true, zone = self.zone, server = 1, language = 'English', weather = 0, day = 0, moon = 50,
        moon_phase = 0, time = 720, mog_house = false, menu_open = false, chat_open = false,
        target_arrow = {x = 0, y = 0, z = 0}}
end

function Game:get_party()
    local player = self.player
    local party = {
        p0 = {name = player.name, mob = self:player_mob(), hp = player.vitals.hp, mp = player.vitals.mp,
            tp = player.vitals.tp, hpp = player.vitals.hpp, mpp = player.vitals.mpp, zone = self.zone},
        party1_leader = player.id, party1_count = 1, party2_count = 0, party3_count = 0,
    }
    for i, name in ipairs(self.party_members or {}) do
        party['p' .. i] = {name = name, hp = 1000, mp = 0, tp = 0, hpp = 100, mpp = 100, zone = self.zone}
        party.party1_count = i + 1
    end
    return party
end

-- What get_mjob_data reports. A blue mage's spells are its 20 set slots, by spell id, 512 in an empty one: here
-- the blue magic it knows, the lowest ids first.
function Game:mjob_data()
    if self.res.jobs[self.player.main_job_id].ens ~= 'BLU' then
        return {}
    end
    local set = {}
    for id in pairs(self.spells) do
        if self.res.spells[id] and self.res.spells[id].type == 'BlueMagic' then
            set[#set + 1] = id
        end
    end
    table.sort(set)
    for slot = 1, 20 do
        set[slot] = set[slot] or 512
    end
    return {spells = {unpack(set, 1, 20)}}
end

-- The recast of each job ability the character knows, by recast id, in seconds: every one ready.
function Game:ability_recasts()
    local recasts = {}
    for _, id in ipairs(self.job_abilities) do
        local ability = self.res.job_abilities[id]
        if ability.recast_id then
            recasts[ability.recast_id] = self:ability_recast(ability.recast_id)
        end
    end
    return recasts
end

-- Seconds left on the recast of the abilities with that recast id: 0 once they are ready again.
function Game:ability_recast(recast_id)
    local ready = self.abilities_ready_at and self.abilities_ready_at[recast_id]
    return ready and math.max(0, ready - self.clock) or 0
end

-- What get_spell_recasts reports for the spell: the time left on its recast in 60ths of a second, as Windower
-- counts it, 0 once it is ready again.
function Game:spell_recast(spell_id)
    local ready = self.spells_ready_at and self.spells_ready_at[spell_id]
    return ready and math.max(0, ready - self.clock) * 60 or 0
end

-- Where the character stands along x: walking (walk()) moves it on five yalms a second.
function Game:player_x()
    local x = self.walked or 0
    if self.walking_since then
        x = x + 5 * (self.clock - self.walking_since)
    end
    return x
end

-- Lays these fields over what get_info reports from here on: time (minutes past midnight), day and weather (by id)
-- and the like. The game takes a get_info of its own that lays them over Game.get_info's.
function Game:change_info(fields)
    if not rawget(self, 'info_changes') then
        self.info_changes = {}
        self.get_info = function(game)
            local info = Game.get_info(game)
            for k, v in pairs(game.info_changes) do
                info[k] = v
            end
            return info
        end
    end
    for k, v in pairs(fields) do
        self.info_changes[k] = v
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Events, the queue and the clock.
-------------------------------------------------------------------------------------------------------------------

-- Registers the handler, the last argument, for each event the arguments before it name, under one id.
function Game:register(...)
    local arguments = {...}
    local handler = table.remove(arguments)
    local id = self.next_event_id
    self.next_event_id = id + 1
    for _, event in ipairs(arguments) do
        self.handlers[event] = self.handlers[event] or {}
        table.insert(self.handlers[event], {id = id, handler = handler})
    end
    return id
end

function Game:unregister(id)
    for _, list in pairs(self.handlers) do
        for i = #list, 1, -1 do
            if list[i].id == id then
                table.remove(list, i)
            end
        end
    end
end

-- Calls each handler of the event in the order they were registered, and returns what the last one returned.
function Game:fire(event, ...)
    local result
    for _, entry in ipairs(copy(self.handlers[event] or {})) do
        result = entry.handler(...)
    end
    return result
end

function Game:enqueue(kind, ...)
    self.queue[#self.queue + 1] = {kind = kind, ...}
end

-- Handles what waits in the queue, and what that adds to it, until nothing is left.
function Game:settle()
    local handled = 0
    while #self.queue > 0 do
        handled = handled + 1
        if handled > 10000 then
            error('the game queue never emptied; something keeps adding to it', 2)
        end
        local entry = table.remove(self.queue, 1)
        if entry.kind == 'incoming' then
            self:deliver_incoming(entry[1], entry[2])
        elseif entry.kind == 'outgoing' then
            self:fire('outgoing chunk', entry[1], entry[2], entry[2], true, false)
        elseif entry.kind == 'command' then
            self:run_command(entry[1])
        elseif entry.kind == 'input' then
            self:input(entry[1])
        end
    end
end

-- Runs fn at the clock's time plus delay, inside a coroutine, as coroutine.schedule does. A coroutine that yields a
-- number of seconds (coroutine.sleep) is resumed that much later.
function Game:schedule(fn, delay, ...)
    local co = type(fn) == 'thread' and fn or real_coroutine.create(fn)
    self.timers[#self.timers + 1] = {at = self.clock + (delay or 0), co = co, arguments = {...}}
    return co
end

function Game:cancel(co)
    for i = #self.timers, 1, -1 do
        if self.timers[i].co == co then
            table.remove(self.timers, i)
        end
    end
end

function Game:advance(seconds)
    local finish = self.clock + (seconds or 0)
    self:settle()
    local ran = 0
    while true do
        ran = ran + 1
        if ran > 10000 then
            error('the game\'s timers never ran out; something keeps setting more', 2)
        end
        local due
        for i, timer in ipairs(self.timers) do
            if timer.at <= finish and (not due or timer.at < self.timers[due].at) then
                due = i
            end
        end
        if not due then
            break
        end
        local timer = table.remove(self.timers, due)
        self.clock = math.max(self.clock, timer.at)
        local results = {real_coroutine.resume(timer.co, unpack(timer.arguments))}
        if not results[1] then
            error(debug.traceback(timer.co, results[2]), 0)
        end
        if real_coroutine.status(timer.co) == 'suspended' then
            local wait = tonumber(results[2]) or tonumber(results[3]) or 0
            self.timers[#self.timers + 1] = {at = self.clock + wait, co = timer.co, arguments = {}}
        end
        self:settle()
    end
    self.clock = finish
    self:settle()
end

-- Moves the clock on as the game does, a frame at a time, each frame a tenth of a second: the timers due run, then
-- the prerender handlers, which Sel's tick and its checks of movement hang on, then the game settles.
function Game:play(seconds)
    local frames = math.floor((seconds or 0) * 10 + 0.5)
    for _ = 1, frames do
        self:advance(0.1)
        self:fire('prerender')
        self:settle()
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Commands and chat input.
-------------------------------------------------------------------------------------------------------------------

-- Splits a command line at its semicolons, leaving those inside quotes.
local function split_commands(line)
    local commands, current, quoted = {}, {}, false
    for char in line:gmatch('.') do
        if char == '"' then
            quoted = not quoted
        end
        if char == ';' and not quoted then
            commands[#commands + 1] = table.concat(current)
            current = {}
        else
            current[#current + 1] = char
        end
    end
    commands[#commands + 1] = table.concat(current)
    return commands
end

-- Splits a command's words at spaces, keeping a quoted phrase as one word without its quotes.
local function split_words(command)
    local words = {}
    local position = 1
    while true do
        local start = command:find('%S', position)
        if not start then
            return words
        end
        if command:sub(start, start) == '"' then
            local finish = command:find('"', start + 1, true) or #command + 1
            words[#words + 1] = command:sub(start + 1, finish - 1)
            position = finish + 1
        else
            local finish = command:find('%s', start) or #command + 1
            words[#words + 1] = command:sub(start, finish - 1)
            position = finish
        end
    end
end
Game.split_words = split_words

-- Runs a line as Windower's console would: each command in turn, with a wait putting off the ones after it.
function Game:run_command(line)
    local commands = split_commands(line)
    for i, command in ipairs(commands) do
        command = command:gsub('^%s+', ''):gsub('%s+$', ''):gsub('^@', '')
        local words = split_words(command)
        local verb = words[1] and words[1]:lower()
        if verb == 'wait' then
            local rest = table.concat(commands, ';', i + 1)
            if rest ~= '' then
                self:schedule(function()
                    self:enqueue('command', rest)
                end, tonumber(words[2]) or 0)
            end
            return
        elseif verb then
            self.commands[#self.commands + 1] = command
            if verb == 'gs' or verb == 'gearswap' then
                self:fire('addon command', select(2, unpack(words)))
            elseif verb == 'lua' and (words[2] == 'i' or words[2] == 'invoke') and words[3] and words[3]:lower() == 'gearswap' then
                self.invoke(words[4], select(5, unpack(words)))
            elseif verb == 'input' then
                self:input(command:match('^%S+%s+(.*)$') or '')
            end
        end
    end
end

-- Text typed into the chat line, or sent by chat.input: the outgoing text handlers see it first, and what they let
-- through the game would act on.
function Game:input(text)
    local modified = text
    for _, entry in ipairs(copy(self.handlers['outgoing text'] or {})) do
        local result = entry.handler(text, modified)
        if result == true then
            return true
        elseif type(result) == 'string' then
            modified = result
        end
    end
    if modified ~= '' then
        self.typed[#self.typed + 1] = modified
    end
    return modified
end

-------------------------------------------------------------------------------------------------------------------
-- Packets: what the addon injects, and the server's answers.
-------------------------------------------------------------------------------------------------------------------

function Game:next_sequence()
    self.sequence = (self.sequence + 1) % 65536
    return self.sequence
end

function Game:receive(id, body)
    local size = 4 + #body
    local data = pad(packet_header(id, size, self:next_sequence()) .. body, 4 * math.ceil(size / 4))
    self:enqueue('incoming', id, data)
    return data
end

function Game:deliver_incoming(id, data)
    self.last_packets.incoming[id] = {data, self.clock}
    self:fire('incoming chunk', id, data, data, false, false)
    if id == 0x028 then
        local act = self.action_tables[data]
        if act then
            self:fire('action', copy(act))
        end
    end
end

-- Whether the item in that bag and bag slot can go in the equipment slot, as the server judges it.
function Game:wearable(bag_id, bag_slot, slot_id)
    local bag = self.bags[bag_id]
    local item = bag and bag.items[bag_slot]
    local entry = item and self.res.items[item.id]
    if not entry or not entry.slots or not has_bit(entry.slots, slot_id) or not self.res.bags[bag_id].equippable then
        return false
    end
    local player = self.player
    return has_bit(entry.jobs, player.main_job_id) and (entry.level or 0) <= player.main_job_level
        and has_bit(entry.races, player.race)
end

-- Carries out one equip request, as four bytes: bag slot, equipment slot, bag. Returns the bytes to confirm it
-- with, or nil when the server refuses it.
function Game:equip_chunk(chunk)
    local bag_slot, slot_id, bag_id = chunk:byte(1), chunk:byte(2), chunk:byte(3)
    local current = self.equipment[slot_id]
    if bag_slot == 0 then
        if current then
            self.bags[current.bag].items[current.slot].status = 0
        end
        self.equipment[slot_id] = nil
        return string.char(0, slot_id, 0, 0)
    end
    if not self:wearable(bag_id, bag_slot, slot_id) then
        return nil
    end
    for other, spot in pairs(self.equipment) do
        if spot.bag == bag_id and spot.slot == bag_slot and other ~= slot_id then
            self.equipment[other] = nil
        end
    end
    if current then
        self.bags[current.bag].items[current.slot].status = 0
    end
    self.equipment[slot_id] = {bag = bag_id, slot = bag_slot}
    self.bags[bag_id].items[bag_slot].status = 5
    return string.char(bag_slot, slot_id, bag_id, 0)
end

-- The equipset reply (0x117): the request as it came, then what is worn in each slot.
function Game:equipset_reply(request)
    local count = request:byte(5)
    local body = string.char(count, 0, 0, 0) .. request:sub(9, 8 + 4 * count)
    body = pad(body, 0x44)
    for id = 0, 15 do
        local spot = self.equipment[id]
        body = body .. (spot and string.char(spot.slot, id, spot.bag, 0) or string.char(0, id, 0, 0))
    end
    return body
end

function Game:inject_outgoing(id, data)
    self.last_packets.outgoing[id] = {data, self.clock}
    self.sent[#self.sent + 1] = {id = id, data = data, at = self.clock}
    self:enqueue('outgoing', id, data)
    if id == 0x050 then
        local reply = self:equip_chunk(data:sub(5, 8))
        if reply then
            self:receive(0x050, reply)
        end
    elseif id == 0x051 then
        for i = 1, data:byte(5) do
            local reply = self:equip_chunk(data:sub(5 + 4 * i, 8 + 4 * i))
            if reply then
                self:receive(0x050, reply)
            end
        end
        self:receive(0x117, self:equipset_reply(data))
    elseif id == 0x01A then
        local action = {target_id = read_u32(data, 5), target_index = read_u16(data, 9), category = read_u16(data, 11),
            param = read_u16(data, 13)}
        self.actions[#self.actions + 1] = action
        self.sent[#self.sent].action = action
    end
end

-- The action packet (0x028) for an action of the player's, as Windower's parse_action gives it. The packet's bytes
-- only carry the header; parse_action and the action event hand out this table for them.
function Game:send_action_packet(act)
    act.actor_id = act.actor_id or self.player.id
    act.target_count = #act.targets
    local data = self:receive(0x028, u32(act.actor_id) .. string.char(#act.targets, act.category, 0, 0) .. u32(self.sequence))
    self.action_tables[data] = act
    return data
end

-- The action message packet (0x029), in the bytes GearSwap reads.
function Game:send_action_message(fields)
    local body = u32(fields.actor_id or self.player.id) .. u32(fields.target_id or self.player.id)
        .. u32(fields.param_1 or 0) .. u32(fields.param_2 or 0)
        .. u16(fields.actor_index or self.player.index) .. u16(fields.target_index or self.player.index)
        .. u16(fields.message_id or 0) .. u16(0)
    return self:receive(0x029, body)
end

-- The buff packet (0x063, type 9): the player's 32 buff slots, then when each wears off. The times count from the
-- game's clock, not from the epoch GearSwap counts a buff's duration from, so the durations it works out are
-- meaningless; a test of a duration needs the times set right first.
function Game:send_buffs()
    local ids, times = {}, {}
    for i = 1, 32 do
        local id = self.player.buffs[i]
        ids[i] = u16(id or 255)
        times[i] = u32(id and (self.clock + 600) * 60 or 0)
    end
    return self:receive(0x063, string.char(9, 0, 0, 0) .. table.concat(ids) .. table.concat(times))
end

-- A packet the client sends of its own: the outgoing chunk handlers see it as it goes, not as injected.
function Game:send_from_client(id, body)
    local size = 4 + #body
    local data = pad(packet_header(id, size, self:next_sequence()) .. body, 4 * math.ceil(size / 4))
    self.last_packets.outgoing[id] = {data, self.clock}
    self:fire('outgoing chunk', id, data, data, false, false)
    return data
end

-- Writes bytes into a packet's body at a position counted, as GearSwap counts it, from the packet's first byte.
local function put(body, position, bytes)
    return body:sub(1, position - 5) .. bytes .. body:sub(position - 4 + #bytes)
end

-- The zone-in packet (0x00A) for the character and zone as the game holds them, in the bytes GearSwap reads.
function Game:send_zone_in()
    local player = self.player
    local body = string.char(0):rep(0x100)
    body = put(body, 0x05, u32(player.id))
    body = put(body, 0x09, u16(player.index))
    body = put(body, 0x31, u16(self.zone))
    body = put(body, 0x69, string.char(self:get_info().weather))
    body = put(body, 0x85, player.name)
    body = put(body, 0xB5, string.char(player.main_job_id))
    body = put(body, 0xB8, string.char(player.sub_job_id))
    body = put(body, 0xE9, u32(player.vitals.max_hp) .. u32(player.vitals.max_mp))
    return self:receive(0x00A, body)
end

-- The char stats packet (0x061), in the bytes GearSwap reads: maximum HP and MP, and the jobs and their levels.
function Game:send_char_stats()
    local player = self.player
    local body = string.char(0):rep(0x50)
    body = put(body, 0x05, u32(player.vitals.max_hp) .. u32(player.vitals.max_mp))
    body = put(body, 0x0D, string.char(player.main_job_id, player.main_job_level, player.sub_job_id, player.sub_job_level))
    return self:receive(0x061, body)
end

-------------------------------------------------------------------------------------------------------------------
-- The Windower API.
-------------------------------------------------------------------------------------------------------------------

local function noop() end

function Game:make_windower(paths)
    local game = self
    paths = paths or {}
    local text_objects = {}
    local windower
    windower = {
        addon_path = paths.addon,
        windower_path = paths.windower,
        version = '4.3.0.0',
        debug = noop,
        register_event = function(...) return game:register(...) end,
        raw_register_event = function(...) return game:register(...) end,
        unregister_event = function(id) game:unregister(id) end,
        send_command = function(command) game:enqueue('command', command) end,
        add_to_chat = function(color, text) game.chat_log[#game.chat_log + 1] = {color = color, text = text} end,
        chat = {input = function(text) game:enqueue('input', text) end},
        to_shift_jis = function(text) return text end,
        from_shift_jis = function(text) return text end,
        convert_auto_trans = function(text) return text end,
        -- Matches text to a pattern in which * stands for any run of characters and ? for any one.
        wc_match = function(text, pattern)
            local lua_pattern = '^' .. pattern:gsub('[%^%$%(%)%%%.%[%]%+%-]', '%%%0'):gsub('%*', '.*'):gsub('%?', '.') .. '$'
            return text:match(lua_pattern) ~= nil
        end,
        copy_to_clipboard = noop,
        get_windower_settings = function()
            return {ui_x_res = 1920, ui_y_res = 1080, x_res = 1920, y_res = 1080, window_x_pos = 0, window_y_pos = 0}
        end,
        file_exists = function(path)
            local resolved = resolve(path)
            return resolved ~= nil and lfs.attributes(resolved, 'mode') == 'file'
        end,
        dir_exists = function(path)
            local resolved = resolve((path:gsub('[/\\]$', '')))
            return resolved ~= nil and lfs.attributes(resolved, 'mode') == 'directory'
        end,
        create_dir = function(path)
            local built = path:sub(1, 1) == '/' and '' or '.'
            for part in path:gmatch('[^/\\]+') do
                built = built .. '/' .. part
                if not lfs.attributes(built) then
                    lfs.mkdir(built)
                end
            end
            return true
        end,
        get_dir = function(path)
            local names = {}
            local resolved = resolve((path:gsub('[/\\]$', '')))
            if resolved then
                for entry in lfs.dir(resolved) do
                    if entry ~= '.' and entry ~= '..' then
                        names[#names + 1] = entry
                    end
                end
            end
            table.sort(names)
            return names
        end,
        text = {
            create = function(name) text_objects[name] = {} end,
            delete = function(name) text_objects[name] = nil end,
        },
        prim = {create = noop, delete = noop},
        packets = {
            inject_outgoing = function(id, data) game:inject_outgoing(id, data) end,
            inject_incoming = function(id, data) game:enqueue('incoming', id, data) end,
            last_incoming = function(id) return unpack(game.last_packets.incoming[id] or {}) end,
            last_outgoing = function(id) return unpack(game.last_packets.outgoing[id] or {}) end,
            parse_action = function(data) return copy(game.action_tables[data]) end,
        },
        ffxi = {
            get_player = function() return game:get_player() end,
            get_mob_by_target = function(target) return game:mob_by_target(target) end,
            get_mob_by_id = function(id) return game:mob_by_id(id) end,
            get_mob_by_index = function(index) return game:mobs()[index] end,
            get_mob_by_name = function(name)
                for _, mob in pairs(game:mobs()) do
                    if mob.name == name then return mob end
                end
            end,
            get_mob_array = function() return game:mobs() end,
            get_mob_list = function()
                local list = {}
                for index, mob in pairs(game:mobs()) do list[index] = mob.name end
                return list
            end,
            get_items = function(bag, index) return game:get_items(bag, index) end,
            get_bag_info = function(bag)
                local info = game:get_bag_info()
                if bag then return info[game.bags[game:bag_id(bag)].api] end
                return info
            end,
            get_info = function() return game:get_info() end,
            get_party = function() return game:get_party() end,
            get_spells = function() return copy(game.spells) end,
            get_abilities = function()
                return {job_abilities = copy(game.job_abilities), weapon_skills = copy(game.weapon_skills), job_traits = {}}
            end,
            get_spell_recasts = function()
                local recasts = {}
                for id in pairs(game.res.spells) do recasts[id] = game:spell_recast(id) end
                return recasts
            end,
            get_ability_recasts = function() return game:ability_recasts() end,
            get_mjob_data = function() return game:mjob_data() end,
            get_sjob_data = function() return {} end,
            get_key_items = function() return {} end,
            get_position = function() return '(?-?)' end,
            turn = noop, run = noop, follow = noop, toggle_walk = noop,
        },
    }
    for name in pairs({set_text = true, set_location = true, set_visibility = true, set_color = true,
        set_bg_color = true, set_bg_visibility = true, set_font = true, set_font_size = true, set_bold = true,
        set_italic = true, set_stroke_width = true, set_stroke_color = true, set_bg_border_size = true,
        set_right_justified = true, set_bottom_justified = true, set_pad = true, set_stroke_transparency = true,
        set_bg_transparency = true, set_transparency = true}) do
        windower.text[name] = noop
        windower.prim[name] = noop
    end
    windower.text.get_extents = function() return 0, 0 end
    windower.text.get_location = function() return 0, 0 end
    return windower
end

-------------------------------------------------------------------------------------------------------------------
-- What the tests ask of the game.
-------------------------------------------------------------------------------------------------------------------

-- The name of the item worn in each slot, by GearSwap's slot names; empty slots are left out.
function Game:worn()
    local worn = {}
    for id, spot in pairs(self.equipment) do
        local item = self.bags[spot.bag].items[spot.slot]
        worn[slot_names[id]] = self.res.items[item.id].en
    end
    return worn
end

-- What an equip packet (0x050 or 0x051) asks for, as {slot = item name, or 'empty'}.
function Game:equip_request(packet)
    local chunks = {}
    if packet.id == 0x050 then
        chunks[1] = packet.data:sub(5, 8)
    elseif packet.id == 0x051 then
        for n = 1, packet.data:byte(5) do
            chunks[n] = packet.data:sub(5 + 4 * n, 8 + 4 * n)
        end
    end
    local request = {}
    for _, chunk in ipairs(chunks) do
        local bag_slot, slot_id, bag_id = chunk:byte(1), chunk:byte(2), chunk:byte(3)
        local item = bag_slot ~= 0 and self.bags[bag_id].items[bag_slot]
        request[slot_names[slot_id]] = item and self.res.items[item.id].en or 'empty'
    end
    return request
end

function Game:gain_buff(name)
    local id = find_by_name(self.res.buffs, name, 'buff')
    table.insert(self.player.buffs, id)
    self:send_buffs()
    self:fire('gain buff', id)
end

function Game:lose_buff(name)
    local id = find_by_name(self.res.buffs, name, 'buff')
    for i, buff in ipairs(self.player.buffs) do
        if buff == id then
            table.remove(self.player.buffs, i)
            break
        end
    end
    self:send_buffs()
    self:fire('lose buff', id)
end

function Game:set_status(status)
    local old = self.player.status
    self.player.status = status
    self:fire('status change', status, old)
end

-- Puts the job ability on recast for that many seconds, as the server does once it is used.
function Game:start_ability_recast(name, seconds)
    local _, ability = find_by_name(self.res.job_abilities, name, 'job ability')
    self.abilities_ready_at = self.abilities_ready_at or {}
    self.abilities_ready_at[ability.recast_id] = self.clock + seconds
end

-- Puts the spell on recast for that many seconds, as the server does once it is cast.
function Game:start_spell_recast(name, seconds)
    local id = find_by_name(self.res.spells, name, 'spell')
    self.spells_ready_at = self.spells_ready_at or {}
    self.spells_ready_at[id] = self.clock + seconds
end

-- The character's TP changes, as it does with each hit and weapon skill, and Windower's tp change event follows.
function Game:set_tp(tp)
    local old = self.player.vitals.tp
    self.player.vitals.tp = tp
    self:fire('tp change', tp, old)
end

-- The character starts walking, and moves on until it stands again.
function Game:walk()
    self.walked = self:player_x()
    self.walking_since = self.clock
end

function Game:stand()
    self.walked = self:player_x()
    self.walking_since = nil
end

-- Someone joins the party, as a trust does once called: get_party lists them from p1 on, in the order they joined.
function Game:join_party(name)
    self.party_members = self.party_members or {}
    table.insert(self.party_members, name)
end

-- The monster begins readying a TP move at the character: the action packet the server sends for it.
function Game:monster_readies(name)
    local id = find_by_name(self.res.monster_abilities, name, 'monster ability')
    return self:send_action_packet({actor_id = self.monster.id, category = 7, param = 24931,
        targets = {{id = self.player.id, actions = {{message = 43, param = id, reaction = 0, animation = 0,
            effect = 0, stagger = 0}}}}})
end

-- The items the addon used (the use item packet, 0x037), in order, as {item = name, target = name}.
function Game:items_used()
    local used = {}
    for _, packet in ipairs(self.sent) do
        if packet.id == 0x037 then
            local bag = self.bags[packet.data:byte(17)]
            local item = bag and bag.items[packet.data:byte(15)]
            local target = self:mob_by_id(read_u32(packet.data, 5))
            used[#used + 1] = {item = item and self.res.items[item.id].en, target = target and target.name}
        end
    end
    return used
end

-- The monster hits the character with a melee swing.
function Game:monster_hits()
    return self:send_action_packet({actor_id = self.monster.id, category = 1, param = 0,
        targets = {{id = self.player.id, actions = {{message = 1, param = 50, reaction = 0, animation = 0,
            effect = 0, stagger = 0}}}}})
end

-- Moves Vana'diel's clock to minutes past midnight, and fires the event that says so.
function Game:set_time(minutes)
    local old = self:get_info().time
    self:change_info({time = minutes})
    self:fire('time change', minutes, old)
end

-- Makes it the day of that id (res.days), and fires the event that says so.
function Game:set_day(id)
    local old = self:get_info().day
    self:change_info({day = id})
    self:fire('day change', id, old)
end

-- Makes the weather that of that id (res.weather), and fires the event that says so.
function Game:set_weather(id)
    local old = self:get_info().weather
    self:change_info({weather = id})
    self:fire('weather change', id, old)
end

-- The client leaving its zone, as on zoning or logging out: its leave-zone packet (0x00D).
function Game:leave_zone()
    self:send_from_client(0x00D, string.char(0):rep(4))
end

-- Zones the character into the zone of that id as the game does: the leave-zone packet out, the zone-out answer
-- (0x00B), the zone-in packet (0x00A) and the buff packet after it in, then the zone change event.
function Game:change_zone(zone_id)
    local old = self.zone
    self:leave_zone()
    self:receive(0x00B, string.char(0):rep(0x18))
    self.zone = zone_id
    self:send_zone_in()
    self:send_buffs()
    self:settle()
    self:fire('zone change', zone_id, old)
end

-- Changes the character's sub job (by its short name) and its level, as at a Moogle, with the char stats packet
-- that tells of it.
function Game:change_sub_job(short, level)
    for id, job in pairs(self.res.jobs) do
        if type(job) == 'table' and job.ens == short then
            self.player.sub_job_id = id
        end
    end
    self.player.sub_job_level = level or 49
    self.player.jobs[short] = self.player.sub_job_level
    self:send_char_stats()
end

return Game
