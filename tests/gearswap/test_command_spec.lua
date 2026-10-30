local plain = require('plain')

local calls, names = plain.calls, plain.names

local function boot(file)
    local gs = plain.boot(file or 'Testy_WHM.lua')
    calls(gs)
    return gs
end

local function gs_test(gs, text)
    gs:console('gs test ' .. text)
    return gs:chat()
end

local hold_message = 'GearSwap: Test: user file off for 30 seconds while the test gear is on.'

describe('gs test set', function()
    it('takes everything off and puts the set on', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        assert.same({head = "Bunzi's Hat", neck = 'Loricate Torque +1', left_ring = 'Kishar Ring'}, gs:worn())
    end)

    it('says what it did and that the user file is off', function()
        local gs = boot()
        assert.same({'GearSwap: Test: naked, then sets.precast.FastCast', hold_message}, gs_test(gs, 'set sets.precast.FastCast'))
    end)

    it('finds the set as gs equip does, with or without sets in front', function()
        local gs = boot()
        gs_test(gs, 'set precast.FastCast')
        assert.same({head = "Bunzi's Hat", neck = 'Loricate Torque +1', left_ring = 'Kishar Ring'}, gs:worn())
    end)

    it('is also gs t', function()
        local gs = boot()
        gs:console('gs t set sets.precast.FastCast')
        assert.equal("Bunzi's Hat", gs:worn().head)
    end)

    it('says so when there is no such set, and changes nothing', function()
        local gs = boot()
        assert.same({'GearSwap: Test: no set called sets.nothing.'}, gs_test(gs, 'set sets.nothing'))
        assert.same({}, gs:traffic())
        assert.is_false(gs.env.gearswap_disabled)
    end)

    it('says how to use it when it is given no set', function()
        local gs = boot()
        assert.same({'GearSwap: Usage: //gs test set <set>  or  //gs test [precast|midcast] <action>'}, gs_test(gs, 'set'))
    end)

    it('says how to use it when it is given nothing', function()
        local gs = boot()
        assert.same({'GearSwap: Usage: //gs test set <set>  or  //gs test [precast|midcast] <action>'}, gs_test(gs, ''))
    end)

    it('calls none of the user file\'s hooks', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        assert.same({}, calls(gs))
    end)

    it('lays the gear the user file\'s test_set_locks returns for the set over it, as the file would lock it', function()
        local gs = boot()
        local handed
        gs.user.test_set_locks = function(set)
            handed = set
            return {main = 'Daybreak', head = 'Kaykaus Mitra +1'}
        end
        gs_test(gs, 'set sets.precast.FastCast')
        assert.equal(gs.user.sets.precast.FastCast, handed)
        assert.same({main = 'Daybreak', head = 'Kaykaus Mitra +1', neck = 'Loricate Torque +1',
            left_ring = 'Kishar Ring'}, gs:worn())
    end)
end)

describe('gs test of an action', function()
    local function boot_actions()
        local gs = plain.boot('Testy_Actions.lua')
        calls(gs)
        return gs
    end

    local weapons = {main = 'Daybreak', sub = 'Ammurapi Shield'}

    it('with precast takes off all but the weapons and puts on what the precast hook does', function()
        local gs = boot_actions()
        gs_test(gs, 'precast Cure III')
        assert.same({main = 'Daybreak', sub = 'Ammurapi Shield', head = "Bunzi's Hat"}, gs:worn())
    end)

    it('with precast calls precast and nothing else', function()
        local gs = boot_actions()
        gs_test(gs, 'precast Cure III')
        assert.same({'precast'}, names(calls(gs)))
    end)

    it('with midcast runs the precast, then the midcast, over it', function()
        local gs = boot_actions()
        gs_test(gs, 'midcast Cure III')
        assert.same({'precast', 'midcast'}, names(calls(gs)))
        assert.same({main = 'Daybreak', sub = 'Ammurapi Shield', head = 'Kaykaus Mitra +1'}, gs:worn())
    end)

    it('with neither runs both phases', function()
        local gs = boot_actions()
        gs_test(gs, 'Cure III')
        assert.same({'precast', 'midcast'}, names(calls(gs)))
    end)

    it('says what it did and that the user file is off', function()
        local gs = boot_actions()
        assert.same({'GearSwap: Test: [Cure III] naked but main, sub and range, then precast',
            'GearSwap: Test: [Cure III] midcast', hold_message}, gs_test(gs, 'Cure III'))
    end)

    it('says only the precast when it is only that', function()
        local gs = boot_actions()
        assert.same({'GearSwap: Test: [Cure III] naked but main, sub and range, then precast', hold_message},
            gs_test(gs, 'precast Cure III'))
    end)

    it('is also gs t', function()
        local gs = boot_actions()
        gs:console('gs t precast Cure III')
        assert.same({'precast'}, names(calls(gs)))
    end)

    it('takes the action\'s name in any case, with or without quotes', function()
        local gs = boot_actions()
        gs_test(gs, 'precast "cure iii"')
        gs_test(gs, 'precast CURE III')
        assert.same({'precast', 'precast'}, names(calls(gs)))
    end)

    it('hands the hooks the spell, flagged as a test, aimed at the target the spell can be cast on', function()
        local gs = boot_actions()
        gs_test(gs, 'precast Dia II')
        gs_test(gs, 'precast Haste')
        local got = calls(gs)
        assert.same({'Dia II', 'Apex Toad', true, 'Magic'}, {got[1].name, got[1].target, got[1].test, got[1].action_type})
        assert.same({'Haste', 'Testy', true}, {got[2].name, got[2].target, got[2].test})
    end)

    it('aims a spell that can\'t be cast on a monster at the player, as it is cast', function()
        local gs = boot_actions()
        gs_test(gs, 'precast Haste')
        local got = calls(gs)[1]
        assert.same({'Testy', 'SELF', '<me>'}, {got.target, got.target_type, got.raw})
    end)

    it('aims a spell that can be cast on a monster at the monster when there is one targeted', function()
        local gs = boot_actions()
        gs_test(gs, 'precast Cure III')
        local got = calls(gs)[1]
        assert.same({'Apex Toad', '<t>'}, {got.target, got.raw})
    end)

    it('aims a spell at the player when nothing is targeted', function()
        local gs = boot_actions()
        gs.game:target(nil)
        gs_test(gs, 'precast Dia II')
        assert.equal('Testy', calls(gs)[1].target)
    end)

    it('takes a weapon skill, with the type WeaponSkill', function()
        local gs = boot_actions()
        gs_test(gs, 'precast Black Halo')
        local got = calls(gs)[1]
        assert.same({'Black Halo', 'WeaponSkill', 'Apex Toad'}, {got.name, got.type, got.target})
    end)

    it('takes a job ability', function()
        local gs = boot_actions()
        gs_test(gs, 'precast Divine Seal')
        local got = calls(gs)[1]
        assert.same({'Divine Seal', 'JobAbility', 'Testy'}, {got.name, got.type, got.target})
    end)

    it('sends no action packet', function()
        local gs = boot_actions()
        gs_test(gs, 'Cure III')
        assert.same({}, gs.game.actions)
    end)

    it('says so when there is no such action, and changes nothing', function()
        local gs = boot_actions()
        assert.same({'GearSwap: Test: no spell, ability or weapon skill called "nothing at all".'}, gs_test(gs, 'precast nothing at all'))
        assert.same({}, gs:traffic())
        assert.is_false(gs.env.gearswap_disabled)
    end)

    it('says how to use it when the action has no name', function()
        local gs = boot_actions()
        assert.same({'GearSwap: Usage: //gs test set <set>  or  //gs test [precast|midcast] <action>'}, gs_test(gs, 'precast'))
    end)

    it('keeps what the hooks send out of the game while it runs, but not once they run for a real cast after it', function()
        local gs = boot_actions()
        gs.user.knobs.echo_in_precast = true
        gs_test(gs, 'precast Cure III')
        assert.same({}, gs:typed())
        assert.is_nil(gs:log():find('command: input /echo precast ran', 1, true))
        gs:advance(31)
        gs:type('/ma "Cure III" <me>')
        assert.matches('command: input /echo precast ran', gs:log())
        assert.same({'/echo precast ran', '/echo precast chat'}, gs:typed())
    end)

    it('leaves no action in progress', function()
        local gs = boot_actions()
        gs_test(gs, 'Cure III')
        assert.is_false(gs.user.midaction())
    end)

    it('raises the error a hook raises', function()
        local gs = boot_actions()
        gs.user.precast = function() error('the hook failed') end
        assert.error_matches(function() gs:console('gs test precast Cure III') end, 'the hook failed')
    end)
end)

describe('the hold after gs test', function()
    it('leaves a spell to the game', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        assert.is_true(gs.env.gearswap_disabled)
        assert.equal('/ma "Cure III" <me>', gs:type('/ma "Cure III" <me>'))
        assert.same({}, calls(gs))
    end)

    it('keeps the gear on while it lasts', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        gs:advance(29)
        assert.same({head = "Bunzi's Hat", neck = 'Loricate Torque +1', left_ring = 'Kishar Ring'}, gs:worn())
        assert.is_true(gs.env.gearswap_disabled)
    end)

    it('ends after 30 seconds: the user file is on again, and says so', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        gs:advance(30.1)
        assert.is_false(gs.env.gearswap_disabled)
        assert.same({'GearSwap: Test: user file back on.'}, gs:chat())
    end)

    it('ends with a status change to the status the player is in, which dresses the player', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        gs:advance(30.1)
        local got = calls(gs)[1]
        assert.same({'status_change', {new = 'Idle', old = 'Idle'}}, {got.event, got.extra})
        local testy = require('testy')
        assert.same(testy.worn_by(testy.whm_idle), gs:worn())
    end)

    it('ends with the engaged set when the player is engaged', function()
        local gs = boot()
        gs:engage()
        calls(gs)
        gs_test(gs, 'set sets.precast.FastCast')
        gs:advance(30.1)
        assert.equal("Bunzi's Rod", gs:worn().main)
    end)

    it('is not ended with a status change when the player is dead', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        gs.game.player.status = 2
        gs:advance(30.1)
        assert.same({}, calls(gs))
        assert.is_false(gs.env.gearswap_disabled)
    end)

    it('is started over by another gs test, whose own 30 seconds count', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        gs:advance(20)
        gs_test(gs, 'set sets.midcast.Cure')
        gs:advance(15)
        assert.is_true(gs.env.gearswap_disabled)
        gs:advance(15.1)
        assert.is_false(gs.env.gearswap_disabled)
    end)

    it('is ended by a bare gs enable, which leaves the user file on for good', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        gs:console('gs enable')
        assert.is_false(gs.env.gearswap_disabled)
        gs:chat_lines()
        gs:advance(31)
        assert.same({}, gs:chat())
        assert.same({}, calls(gs))
    end)

    it('is taken over by a bare gs disable, which leaves the user file off for good', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        gs:console('gs disable')
        gs:advance(31)
        assert.is_true(gs.env.gearswap_disabled)
        assert.same({}, calls(gs))
    end)

    it('lets a user file load turn the user file on', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        gs:console('gs load Testy_Events')
        assert.is_false(gs.env.gearswap_disabled)
    end)

    pending('is ended by a user file load, so 30 seconds on nothing is said and the new file is told of no status '
        .. 'change: load_user_files ends the audit and the gs naked hold but not this one, whose timer still says the '
        .. 'user file is back on and calls status_change')

    it('is not started over by gs enable with a slot, which leaves the hold as it is', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        gs:advance(20)
        gs:console('gs enable head')
        assert.is_true(gs.env.gearswap_disabled)
        gs:advance(10.1)
        assert.is_false(gs.env.gearswap_disabled)
    end)

    it('is not entered when the user file was already disabled: nothing is tested', function()
        local gs = boot()
        gs:console('gs disable')
        gs:chat_lines()
        assert.same({'GearSwap: Cannot test while the user file is disabled.'}, gs_test(gs, 'set sets.precast.FastCast'))
        assert.same({}, gs:traffic())
    end)

    it('is not entered when no file is loaded', function()
        local gs = plain.boot_without_a_file()
        assert.same({'GearSwap: There is nothing to test because there is no file loaded.'}, gs_test(gs, 'set sets.idle'))
    end)

    it('lets gs test run again during the hold, as the user file is only off for the test', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        gs:chat_lines()
        assert.same({'GearSwap: Test: naked, then sets.midcast.Cure', hold_message}, gs_test(gs, 'set sets.midcast.Cure'))
    end)

    it('is taken over by gs naked, whose own timeless hold follows', function()
        local gs = boot()
        gs_test(gs, 'set sets.precast.FastCast')
        gs:console('gs naked')
        gs:advance(31)
        assert.is_true(gs.env.gearswap_disabled)
    end)
end)
