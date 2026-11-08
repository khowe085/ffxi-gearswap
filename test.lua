-------------------------------------------------------------------------------------------------------------------
-- gs test set <set>, gs test engaged and gs test [precast|midcast] <action>: put gear on to look at it, then hold
-- it until gs test done.
--
-- Nothing here knows how the user file builds its sets. 'set' reads the set as gs equip does, then lays over it
-- what the user file's test_set_locks(set) returns, if it has one: the gear the file keeps on whatever the set
-- names. 'engaged' hands the user file's own status_change a change to Engaged, and the action form its precast
-- and midcast the spell table GearSwap would, flagged spell.test, through equip_sets, so whatever framework the
-- file is built on picks the gear. No action packet is built or sent.
--
-- Each form then switches the user file off, as a bare gs disable does, so nothing swaps the gear away. gs test
-- done switches it back on and gives it a status_change with the current status, the event user files dress idle
-- or engaged gear on. A bare gs enable or gs disable, or gs naked, takes over from the hold instead.
-------------------------------------------------------------------------------------------------------------------

local test_usage = 'Usage: //gs test set <set>  or  //gs test [precast|midcast] <action>'
local weapon_slots = {main = true, sub = true, range = true}

-- test_holding marks the file as switched off by a test rather than by the player.
local test_holding = false

-- True while a test phase runs the user file's hooks. send_cmd_user drops the file's commands while it is set.
test_silenced = false

local function notice(text)
    msg.addon_msg(123, 'Test: '..text)
end

-- The spell table GearSwap would hand the hooks for the named action, aimed at the current target or the player,
-- or nil when no spell, ability or weapon skill has that name.
local function test_action(name)
    local resources = {['/ma'] = res.spells, ['/ws'] = res.weapon_skills, ['/ja'] = res.job_abilities}
    for _, prefix in ipairs({'/ma', '/ws', '/ja'}) do
        local id = validabils[language][prefix][name]
        if id then
            local r_line = copy_entry(resources[prefix][id])
            r_line.name = r_line[language]
            local spell = spell_complete(r_line)
            spell.target = target_complete(windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('me'))
            -- A spell that can't be aimed at a monster is tested on the player, as it would be cast. Aimed at the
            -- monster, a file that corrects targets (Sel's AdjustTargets) would cancel it and cast it for real.
            if spell.target.type == 'MONSTER' and not (spell.targets and spell.targets.Enemy) then
                spell.target = target_complete(windower.ffxi.get_mob_by_target('me'))
            end
            spell.target.raw = spell.target.type == 'SELF' and '<me>' or '<t>'
            spell.action_type = action_type_map[prefix]
            spell.test = true
            return spell
        end
    end
end

-- Ends the hold, if a test took it.
local function test_release()
    if not test_holding then return end
    test_holding = false
    gearswap_disabled = false
end

-- Called by a bare gs enable or gs disable, which leaves the file as the player set it, and by gs naked.
-- Returns true when there was a hold to end.
function test_hold_end()
    if not test_holding then return false end
    test_holding = false
    return true
end

local function test_hold()
    test_holding = true
    gearswap_disabled = true
    notice('user file off while the test gear is on, until //gs test done.')
end

local function test_done()
    if not test_holding then
        notice('no test to end.')
        return
    end
    test_release()
    audit_cancel()
    notice('user file back on.')
    refresh_globals()
    -- GearSwap's own status_change trigger skips dead, engaged dead and event (2, 3 and 4).
    if not T{2,3,4}:contains(windower.ffxi.get_player().status) then
        equip_sets('status_change', nil, player.status, player.status)
    end
end

local function naked_slots(keep)
    local naked = {}
    for _, slot_name in pairs(default_slot_map) do
        if not (keep and keep[slot_name]) then naked[slot_name] = empty end
    end
    return naked
end

-- Runs fn inside equip_sets as the event it names, with the file's chat input and commands silenced, so nothing
-- a framework or job file sends in response (an ability it uses first, a corrected target, the action itself)
-- reaches the game. Input it schedules meanwhile is the silent stand-in, so that stays quiet too.
local function test_event(event, fn, val)
    local chat_input = windower.chat.input
    windower.chat.input = function() end
    test_silenced = true
    local ok, err = pcall(equip_sets, function()
        _global.current_event = event
        fn()
    end, nil, val)
    windower.chat.input = chat_input
    test_silenced = false
    if not ok then error(err, 0) end
end

-- One phase of the action, run as GearSwap runs that event, so a phase check in the hook sees the phase it
-- expects. strip names the slots to empty first; the hook's own equip calls land over them.
local function test_phase(phase, spell, strip)
    test_event(phase, function()
        if strip then equip(strip) end
        user_pcall(phase, spell)
    end, spell)
end

-- The file's status_change runs with player.status as Engaged, so a framework that reads the status rather than
-- the hook's argument picks its engaged gear too. The status is the game's again afterwards.
local function test_engaged()
    local status = player.status
    player.status = 'Engaged'
    local ok, err = pcall(test_event, 'status_change', function()
        equip(naked_slots())
        user_pcall('status_change', 'Engaged', status)
        equip(type(user_env.test_set_locks) == 'function' and user_env.test_set_locks() or {})
    end)
    player.status = status
    if not ok then error(err, 0) end
end

-- Returns true when the gear went on.
function test_command(args)
    local stage = args[1] and args[1]:lower()
    if stage == 'done' then
        test_done()
        return
    end
    if gearswap_disabled and not test_holding then
        msg.addon_msg(123, 'Cannot test while the user file is disabled.')
        return
    end
    if not user_env then
        msg.addon_msg(123, 'There is nothing to test because there is no file loaded.')
        return
    end

    if stage == 'engaged' then
        test_release()
        refresh_globals()
        test_engaged()
        notice('naked, then the user file\'s engaged gear')
        test_hold()
        return true
    end

    if stage == 'set' then
        if not args[2] then
            msg.addon_msg(123, test_usage)
            return
        end
        local keys = parse_set_to_keys({unpack(args, 2)})
        local set = get_set_from_keys(keys)
        if not set then
            notice('no set called '..table.concat(args, ' ', 2)..'.')
            return
        end
        test_release()
        refresh_globals()
        local locks = type(user_env.test_set_locks) == 'function' and user_env.test_set_locks(set) or {}
        equip_sets(function()
            equip(naked_slots(), set, locks)
        end, nil, set)
        notice('naked, then '..table.concat(args, ' ', 2))
        test_hold()
        return true
    end

    local first = 1
    if stage == 'precast' or stage == 'midcast' then
        first = 2
    else
        stage = nil
    end
    local name = table.concat(args, ' ', first):gsub('"', ''):lower()
    if name == '' then
        msg.addon_msg(123, test_usage)
        return
    end

    refresh_globals()
    local spell = test_action(name)
    if not spell then
        notice('no spell, ability or weapon skill called "'..name..'".')
        return
    end
    test_release()

    -- The weapons stay as a real action would leave them: whatever the hooks choose, or what is on.
    test_phase('precast', spell, naked_slots(weapon_slots))
    notice('['..spell.name..'] naked but main, sub and range, then precast')
    if stage ~= 'precast' then
        test_phase('midcast', spell)
        notice('['..spell.name..'] midcast')
    end
    test_hold()
    return true
end
