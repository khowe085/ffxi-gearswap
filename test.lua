-------------------------------------------------------------------------------------------------------------------
-- gs test set <set> and gs test [precast|midcast] <action>: put gear on to look at it, then hold it.
--
-- Nothing here knows how the user file builds its sets. 'set' reads the set as gs equip does. The action form
-- hands the user file's own precast and midcast the spell table GearSwap would, flagged spell.test, through
-- equip_sets, so whatever framework the file is built on picks the gear. No action packet is built or sent.
--
-- Either form then switches the user file off for test_hold_seconds, as a bare gs disable does, so nothing swaps
-- the gear away. When the hold lapses the file switches back on and gets a status_change with the current status,
-- the event user files dress idle or engaged gear on. Another gs test during the hold starts over, and a bare
-- gs enable or gs disable takes over from the timer.
-------------------------------------------------------------------------------------------------------------------

local test_hold_seconds = 30
local test_usage = 'Usage: //gs test set <set>  or  //gs test [precast|midcast] <action>'
local weapon_slots = {main = true, sub = true, range = true}

-- test_token makes a lapsed hold's timer stale once a newer test or a bare enable/disable has acted.
-- test_holding marks the file as switched off by a test rather than by the player.
local test_token, test_holding = 0, false

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

-- Ends the hold, if a test took it. The timer it set lapses.
local function test_release()
    if not test_holding then return end
    test_holding = false
    test_token = test_token + 1
    gearswap_disabled = false
end

-- Called by a bare gs enable or gs disable, which leaves the file as the player set it.
function test_hold_end()
    if not test_holding then return end
    test_holding = false
    test_token = test_token + 1
end

local function test_hold()
    test_token = test_token + 1
    test_holding = true
    gearswap_disabled = true
    notice(('user file off for %d seconds while the test gear is on.'):format(test_hold_seconds))
    local token = test_token
    coroutine.schedule(function()
        if token ~= test_token or not test_holding then return end
        test_release()
        audit_cancel()
        notice('user file back on.')
        refresh_globals()
        -- GearSwap's own status_change trigger skips dead, engaged dead and event (2, 3 and 4).
        if not T{2,3,4}:contains(windower.ffxi.get_player().status) then
            equip_sets('status_change', nil, player.status, player.status)
        end
    end, test_hold_seconds)
end

-- One phase of the action, run as GearSwap runs that event, so a phase check in the hook sees the phase it
-- expects. strip names the slots to empty first; the hook's own equip calls land over them.
-- The hooks run with the file's chat input and commands silenced, so nothing a framework or job file sends in
-- response (an ability it uses first, a corrected target, the action itself) reaches the game. Input it schedules
-- during the phase is the silent stand-in, so that stays quiet too.
local function test_phase(phase, spell, strip)
    local chat_input = windower.chat.input
    windower.chat.input = function() end
    test_silenced = true
    local ok, err = pcall(equip_sets, function()
        _global.current_event = phase
        if strip then equip(strip) end
        user_pcall(phase, spell)
    end, nil, spell)
    windower.chat.input = chat_input
    test_silenced = false
    if not ok then error(err, 0) end
end

-- Returns true when the gear went on.
function test_command(args)
    if gearswap_disabled and not test_holding then
        msg.addon_msg(123, 'Cannot test while the user file is disabled.')
        return
    end
    if not user_env then
        msg.addon_msg(123, 'There is nothing to test because there is no file loaded.')
        return
    end

    local stage = args[1] and args[1]:lower()
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
        local naked = {}
        for _, slot_name in pairs(default_slot_map) do naked[slot_name] = empty end
        equip_sets(function()
            equip(naked, set)
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
    local strip = {}
    for _, slot_name in pairs(default_slot_map) do
        if not weapon_slots[slot_name] then strip[slot_name] = empty end
    end
    test_phase('precast', spell, strip)
    notice('['..spell.name..'] naked but main, sub and range, then precast')
    if stage ~= 'precast' then
        test_phase('midcast', spell)
        notice('['..spell.name..'] midcast')
    end
    test_hold()
    return true
end
