local jobby = require('jobby')

local pieces = {'Volte Cap', 'Volte Jupon', 'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Null Masque',
    'Adamantite Armor', "Orunmila's Torque", 'Weike Torque', 'Sortiarius Earring', 'Beatific Earring',
    'Pensee Earring', 'Moonshade Earring', 'Wanion Belt', 'Prodigious Mantle', 'Malignance Chapeau', 'Setan Kober',
    'Horos T. Shoes +2'}

-- Jobby as a dancer with the idle set on. The options are those of a boot (sub_job, tp, buffs) and these besides:
--   engaged   true to engage the monster
--   hp        the HP of the 1500 he has
local function boot(options)
    options = options or {}
    local items = {}
    for _, name in ipairs(pieces) do
        items[#items + 1] = name
    end
    for _ = 1, (options.kobers or 1) - 1 do
        items[#items + 1] = 'Setan Kober'
    end
    local gs = jobby.boot('DNC', {items = items, sub_job = options.sub_job or 'NIN', tp = options.tp,
        buffs = options.buffs, wearing = options.wearing})
    if options.hp then
        gs.game.player.vitals.hp = options.hp
    end
    gs:console('gs c update')
    if options.engaged then
        gs:engage()
    end
    gs:traffic()
    gs.game.chat_log, gs.game.commands, gs.game.typed = {}, {}, {}
    return gs
end

local function sets_of(gs)
    return gs.user.sets
end

local function said(gs, text)
    for _, entry in ipairs(gs.game.chat_log) do
        if entry.text:find(text, 1, true) then
            return true
        end
    end
    return false
end

local function actions(gs)
    local names = {}
    for _, entry in ipairs(gs:traffic()) do
        names[#names + 1] = entry.action
    end
    return names
end

-- The actions the tick sent in its first moments (it starts five seconds after the file loads).
local function first_actions(gs)
    gs:play(5.3)
    return actions(gs)
end

local function engaged_worn(gs, ...)
    return jobby.worn_by(jobby.layer(sets_of(gs).engaged, ...))
end

describe('a step', function()
    it('wears sets.precast.Step', function()
        local gs = boot({tp = 0})
        gs:type('/ja "Box Step" <t>')
        local sent = gs:traffic()
        assert.same(jobby.request(sets_of(gs).precast.Step), sent[1].equip)
        assert.equal('Box Step', sent[2].action)
    end)

    describe('with Presto ready, engaged, with at least 100 TP and fewer than three finishing moves', function()
        it('is held back for Presto', function()
            local gs = boot({tp = 1200, engaged = true})
            gs:type('/ja "Box Step" <t>')
            assert.same({'Presto'}, actions(gs))
        end)

        it('goes out once Presto is on recast, a second later', function()
            local gs = boot({tp = 1200, engaged = true})
            gs:type('/ja "Box Step" <t>')
            gs:traffic()
            gs.game:start_ability_recast('Presto', 30)
            gs:advance(1.2)
            assert.same({'Box Step'}, actions(gs))
        end)

        it('goes out at once with the Auto Presto Mode off', function()
            local gs = boot({tp = 1200, engaged = true})
            gs:console('gs c toggle AutoPrestoMode')
            gs:type('/ja "Box Step" <t>')
            assert.same({'Box Step'}, actions(gs))
        end)

        it('goes out at once with 99 TP', function()
            local gs = boot({tp = 99, engaged = true})
            gs:type('/ja "Box Step" <t>')
            assert.same({'Box Step'}, actions(gs))
        end)

        it('goes out at once with three finishing moves', function()
            local gs = boot({tp = 1200, engaged = true, buffs = {'Finishing Move 3'}})
            gs:type('/ja "Box Step" <t>')
            assert.same({'Box Step'}, actions(gs))
        end)

        it('goes out at once while Presto is on recast', function()
            local gs = boot({tp = 1200, engaged = true})
            gs.game:start_ability_recast('Presto', 30)
            gs:type('/ja "Box Step" <t>')
            assert.same({'Box Step'}, actions(gs))
        end)

        it('is refused while the steps are on recast', function()
            local gs = boot({tp = 1200, engaged = true})
            gs.game:start_ability_recast('Quickstep', 30)
            gs:type('/ja "Box Step" <t>')
            assert.same({}, actions(gs))
            assert.is_true(said(gs, 'Abort: [Box Step] waiting on recast.'))
        end)
    end)

    it('engages the monster first when not engaged and close, as Sel\'s idle step does, then goes out', function()
        local gs = boot({tp = 1200})
        gs:type('/ja "Box Step" <t>')
        assert.same({'category 2', 'Box Step'}, actions(gs))
    end)
end)

describe('gs c step', function()
    local function step(gs, command)
        gs:console(command or 'gs c step')
        return actions(gs)
    end

    it('uses the main step on the target, Box Step to start with', function()
        local gs = boot({buffs = {'Finishing Move 3'}})
        assert.same({'Box Step'}, step(gs))
    end)

    it('uses the step the Main Step state names', function()
        local gs = boot({buffs = {'Finishing Move 3'}})
        gs:console('gs c set MainStep Quickstep')
        assert.same({'Quickstep'}, step(gs))
    end)

    it('uses the cycle step when the main step is Cycle Step', function()
        local gs = boot({buffs = {'Finishing Move 3'}})
        gs:console('gs c set MainStep Cycle Step')
        assert.same({'Box Step'}, step(gs))
    end)

    it('uses the cycle step on gs c cyclestep, whatever the main step', function()
        local gs = boot({buffs = {'Finishing Move 3'}})
        gs:console('gs c set CycleStep Feather Step')
        assert.same({'Feather Step'}, step(gs, 'gs c cyclestep'))
    end)

    it('moves the cycle step on to the next once that step is done within five seconds', function()
        local gs = boot({buffs = {'Finishing Move 3'}})
        gs:console('gs c cyclestep')
        gs:finish_action()
        assert.equal('Feather Step', gs.user.state.CycleStep.value)
    end)

    it('leaves the cycle step where it is when the step is done after five seconds', function()
        local gs = boot({buffs = {'Finishing Move 3'}})
        gs:console('gs c cyclestep')
        gs:advance(6)
        gs:finish_action()
        assert.equal('Box Step', gs.user.state.CycleStep.value)
    end)

    it('leaves the cycle step where it is for a step that is not the cycle step', function()
        local gs = boot({buffs = {'Finishing Move 3'}})
        gs:console('gs c cyclestep')
        gs:console('gs c set MainStep Stutter Step')
        gs:advance(1)
        gs:console('gs c step')
        gs:finish_action()
        assert.equal('Box Step', gs.user.state.CycleStep.value)
    end)

    it('is put back to the first step on leaving combat', function()
        local gs = boot({engaged = true, buffs = {'Finishing Move 3'}})
        gs:console('gs c set CycleStep Quickstep')
        gs.user.in_combat = true
        gs.user.last_in_combat = 0
        gs.game.monster.hpp = 0
        gs:play(5.3)
        assert.equal('Box Step', gs.user.state.CycleStep.value)
    end)
end)

describe('a weapon skill under AutoBuffMode with the TP to spare for a step', function()
    local function buffer(options)
        options = options or {}
        options.tp = options.tp or 1200
        options.engaged = true
        local gs = boot(options)
        gs:console('gs c set AutoBuffMode Auto')
        return gs
    end

    local function weaponskill(gs)
        gs:type('/ws "Rudra\'s Storm" <t>')
        return actions(gs)
    end

    it('is held back for a step with fewer than three finishing moves, and Presto goes first', function()
        local gs = buffer()
        assert.same({'Presto'}, weaponskill(gs))
    end)

    it('goes out while Presto is neither ready nor up', function()
        local gs = buffer()
        gs.game:start_ability_recast('Presto', 30)
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)

    it('is held back for the step itself with Presto up', function()
        local gs = buffer({buffs = {'Presto'}})
        gs.game:start_ability_recast('Presto', 30)
        assert.same({'Box Step'}, weaponskill(gs))
    end)

    it('goes out when the steps are on recast', function()
        local gs = buffer()
        gs.game:start_ability_recast('Quickstep', 30)
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)

    it('is held back for Climactic Flourish with three finishing moves', function()
        local gs = buffer({buffs = {'Finishing Move 3'}})
        assert.same({'Climactic Flourish'}, weaponskill(gs))
    end)

    it('is held back for Building Flourish when Climactic Flourish is on recast', function()
        local gs = buffer({buffs = {'Finishing Move 3'}})
        gs.game:start_ability_recast('Climactic Flourish', 30)
        assert.same({'Building Flourish'}, weaponskill(gs))
    end)

    it('is held back for Climactic Flourish when Building Flourish is on recast', function()
        local gs = buffer({buffs = {'Finishing Move 3'}})
        gs.game:start_ability_recast('Building Flourish', 30)
        assert.same({'Climactic Flourish'}, weaponskill(gs))
    end)

    it('goes out with Climactic Flourish up, its recast running, and Building Flourish not to be used on it', function()
        local gs = buffer({buffs = {'Finishing Move 3', 'Climactic Flourish'}})
        gs.game:start_ability_recast('Climactic Flourish', 30)
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)

    it('goes out with Building Flourish up, its recast running, and Climactic Flourish not to be used on it', function()
        local gs = buffer({buffs = {'Finishing Move 3', 'Building Flourish'}})
        gs.game:start_ability_recast('Building Flourish', 30)
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)

    it('goes out when both flourishes are on recast', function()
        local gs = buffer({buffs = {'Finishing Move 5'}})
        gs.game:start_ability_recast('Climactic Flourish', 30)
        gs.game:start_ability_recast('Building Flourish', 30)
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)

    it('goes out with both flourishes up at any finishing move count of three and up', function()
        for _, buff in ipairs({'Finishing Move 4', 'Finishing Move 5', 'Finishing Move (6+)'}) do
            local gs = buffer({buffs = {buff, 'Building Flourish', 'Climactic Flourish'}})
            assert.same({'Rudra\'s Storm'}, weaponskill(gs))
        end
    end)

    it('is held back for Sekkanoki over 1850 TP with the sub job Samurai', function()
        local gs = buffer({sub_job = 'SAM', tp = 1900})
        gs.game:start_ability_recast('Quickstep', 30)
        assert.same({'Sekkanoki'}, weaponskill(gs))
    end)

    it('is held back for Meditate at 1850 TP or less with the sub job Samurai', function()
        local gs = buffer({sub_job = 'SAM', tp = 1850})
        gs.game:start_ability_recast('Quickstep', 30)
        assert.same({'Meditate'}, weaponskill(gs))
    end)

    it('goes out with the sub job Samurai when neither is ready', function()
        local gs = buffer({sub_job = 'SAM', tp = 1900})
        gs.game:start_ability_recast('Quickstep', 30)
        gs.game:start_ability_recast('Sekkanoki', 30)
        gs.game:start_ability_recast('Meditate', 30)
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)

    it('goes out with the sub job Samurai when an SJ Restriction is on', function()
        local gs = buffer({sub_job = 'SAM', tp = 1900, buffs = {'SJ Restriction'}})
        gs.game:start_ability_recast('Quickstep', 30)
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)

    it('goes out at 1099 TP, the cost of a step being a hundred', function()
        local gs = buffer({tp = 1099})
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)

    pending('is held back at 1095 TP with Horos T. Shoes +2 in sets.precast.Step, which take 10 off the cost: '
        .. 'job_setup in data/DNC.lua works the reduction out before the gear file has built sets.precast.Step, so it is '
        .. 'nothing until a sub job change runs job_setup again')

    it('goes out at 1090 TP, a step costing a hundred', function()
        local gs = buffer({tp = 1090})
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)

    it('is held back at 1090 TP with a Setan Kober in hand, which takes 40 off the cost', function()
        local gs = buffer({tp = 1090, wearing = {main = 'Setan Kober'}})
        assert.same({'Presto'}, weaponskill(gs))
    end)

    it('is held back at 1030 TP with a Setan Kober in each hand, which takes 80 off the cost', function()
        local gs = buffer({tp = 1030, wearing = {main = 'Setan Kober', sub = 'Setan Kober'}, kobers = 2})
        assert.same({'Presto'}, weaponskill(gs))
    end)

    it('goes out with the AutoBuffMode off', function()
        local gs = boot({tp = 1200, engaged = true})
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)

    it('goes out when not engaged', function()
        local gs = boot({tp = 1200})
        gs:console('gs c set AutoBuffMode Auto')
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)
end)

describe('a weapon skill by a dancer', function()
    local function weaponskill(tp, ...)
        local gs = boot({tp = tp, engaged = true})
        for _, command in ipairs({...}) do
            gs:console(command)
        end
        gs:traffic()
        gs:type('/ws "Rudra\'s Storm" <t>')
        return gs
    end

    it('trades the Moonshade Earring for sets.MaxTP at the TP cap', function()
        local gs = weaponskill(3000)
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Rudra\'s Storm'], sets_of(gs).MaxTP), gs:worn())
    end)

    it('trades it for sets.AccMaxTP in the Acc offense mode', function()
        local gs = weaponskill(3000, 'gs c set OffenseMode Acc')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Rudra\'s Storm'], sets_of(gs).AccMaxTP), gs:worn())
    end)

    it('keeps the Moonshade Earring under the cap', function()
        local gs = weaponskill(2900)
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Rudra\'s Storm']), gs:worn())
    end)

    it('wears sets.buff["Climactic Flourish"] over the weapon skill set while that is up', function()
        local gs = boot({tp = 2000, engaged = true})
        gs:gain_buff('Climactic Flourish')
        gs:traffic()
        gs:type('/ws "Rudra\'s Storm" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Rudra\'s Storm'], sets_of(gs).buff['Climactic Flourish']),
            gs:worn())
    end)

    describe('with a Climactic Flourish up and AutoBuffMode on', function()
        local function finished(options)
            options.tp = options.tp or 2000
            options.engaged = true
            options.buffs = options.buffs or {}
            options.buffs[#options.buffs + 1] = 'Climactic Flourish'
            local gs = boot(options)
            gs:console('gs c set AutoBuffMode Auto')
            gs.game:start_ability_recast('Climactic Flourish', 30)
            gs.game:start_ability_recast('Presto', 30)
            gs.game:start_ability_recast('Quickstep', 30)
            gs:type('/ws "Rudra\'s Storm" <t>')
            gs:traffic()
            gs.game.player.vitals.tp = 0
            gs:finish_action()
            gs:play(7)
            return gs
        end

        it('is followed by Reverse Flourish a second and a half later, with three finishing moves and the TP spent', function()
            local gs = finished({buffs = {'Finishing Move 3'}})
            assert.same({'Reverse Flourish'}, actions(gs))
        end)

        it('is followed by no Reverse Flourish with fewer than three finishing moves', function()
            local gs = finished({})
            for _, name in ipairs(actions(gs)) do
                assert.are_not.equal('Reverse Flourish', name)
            end
        end)

        it('is followed by no Reverse Flourish while it is on recast', function()
            local gs = boot({tp = 2000, engaged = true, buffs = {'Climactic Flourish', 'Finishing Move 3'}})
            gs:console('gs c set AutoBuffMode Auto')
            gs.game:start_ability_recast('Climactic Flourish', 30)
            gs.game:start_ability_recast('Presto', 30)
            gs.game:start_ability_recast('Quickstep', 30)
            gs.game:start_ability_recast('Reverse Flourish', 30)
            gs:type('/ws "Rudra\'s Storm" <t>')
            gs:traffic()
            gs.game.player.vitals.tp = 0
            gs:finish_action()
            gs:play(7)
            assert.same({}, actions(gs))
        end)

        it('is followed by no Reverse Flourish with TP left', function()
            local gs = boot({tp = 2000, engaged = true, buffs = {'Climactic Flourish', 'Finishing Move 3'}})
            gs:console('gs c set AutoBuffMode Auto')
            gs.game:start_ability_recast('Climactic Flourish', 30)
            gs.game:start_ability_recast('Presto', 30)
            gs.game:start_ability_recast('Quickstep', 30)
            gs:type('/ws "Rudra\'s Storm" <t>')
            gs:traffic()
            gs:finish_action()
            gs:play(7)
            assert.same({}, actions(gs))
        end)
    end)

    it('is followed by no Reverse Flourish with AutoBuffMode off', function()
        local gs = boot({tp = 2000, engaged = true, buffs = {'Climactic Flourish', 'Finishing Move 3'}})
        gs:type('/ws "Rudra\'s Storm" <t>')
        gs:traffic()
        gs.game.player.vitals.tp = 0
        gs:finish_action()
        gs:play(7)
        assert.same({}, actions(gs))
    end)
end)

describe('the dancer\'s abilities of each kind', function()
    local function equip_of(line)
        local gs = boot()
        gs:type(line)
        return gs, gs:traffic()[1].equip
    end

    it('wear sets.precast.Samba for a samba', function()
        local gs, equip = equip_of('/ja "Haste Samba" <me>')
        assert.same(jobby.request(sets_of(gs).precast.Samba), equip)
    end)

    it('wear sets.precast.Flourish1 for Animated Flourish', function()
        local gs, equip = equip_of('/ja "Animated Flourish" <t>')
        assert.same(jobby.request(sets_of(gs).precast.Flourish1), equip)
    end)

    it('wear sets.precast.Flourish1 for Violent Flourish', function()
        local gs, equip = equip_of('/ja "Violent Flourish" <t>')
        assert.same(jobby.request(sets_of(gs).precast.Flourish1), equip)
    end)

    it('wear sets.precast.Flourish2 for Reverse Flourish', function()
        local gs, equip = equip_of('/ja "Reverse Flourish" <me>')
        assert.same(jobby.request(sets_of(gs).precast.Flourish2), equip)
    end)

    it('wear sets.precast.Flourish3 for Striking Flourish', function()
        local gs, equip = equip_of('/ja "Striking Flourish" <me>')
        assert.same(jobby.request(sets_of(gs).precast.Flourish3), equip)
    end)

    it('wear nothing for an ability with no set, such as Saber Dance', function()
        local gs = boot()
        gs:type('/ja "Saber Dance" <me>')
        assert.same({'Saber Dance'}, actions(gs))
    end)
end)

describe('the dances', function()
    it('put sets.engaged.Saber on the engaged dancer while Saber Dance is up', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Saber Dance')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).engaged.Saber)), gs:worn())
    end)

    it('put sets.engaged.Fan on the engaged dancer while Fan Dance is up', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Fan Dance')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).engaged.Fan)), gs:worn())
    end)

    it('put sets.engaged back when the dance ends', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Saber Dance')
        gs:lose_buff('Saber Dance')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).engaged)), gs:worn())
    end)

    it('put sets.buff["Saber Dance"] over the engaged set in a defense mode', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Saber Dance')
        gs:console('gs c set DefenseMode Physical')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).engaged.Saber, sets_of(gs).buff['Saber Dance'],
            sets_of(gs).defense.PDT)), gs:worn())
    end)

    it('put sets.buff["Climactic Flourish"] over the engaged set in a defense mode', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Climactic Flourish')
        gs:console('gs c set DefenseMode Physical')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).engaged, sets_of(gs).buff['Climactic Flourish'],
            sets_of(gs).defense.PDT)), gs:worn())
    end)

    it('put no buff set over the engaged set without a defense mode', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Climactic Flourish')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).engaged)), gs:worn())
    end)

    describe('kept up by the tick', function()
        local function stance(name, options)
            options = options or {}
            options.engaged = true
            local gs = boot(options)
            gs:console('gs c set DanceStance ' .. name)
            gs.user.in_combat = true
            return gs
        end

        it('begin with Saber Dance when the dance stance is Saber Dance and none is up', function()
            local gs = stance('Saber Dance')
            assert.same({'Saber Dance'}, first_actions(gs))
        end)

        it('begin with Fan Dance when the dance stance is Fan Dance and none is up', function()
            local gs = stance('Fan Dance')
            assert.same({'Fan Dance'}, first_actions(gs))
        end)

        it('begin with nothing while a dance is up', function()
            local gs = stance('Saber Dance', {buffs = {'Fan Dance'}})
            assert.same({}, first_actions(gs))
        end)

        it('begin with nothing out of combat', function()
            local gs = stance('Saber Dance')
            gs.user.in_combat = false
            assert.same({}, first_actions(gs))
        end)

        it('begin with nothing while the dance is on recast', function()
            local gs = stance('Saber Dance')
            gs.game:start_ability_recast('Saber Dance', 30)
            assert.same({}, first_actions(gs))
        end)

        it('begin with nothing when the stance is None', function()
            local gs = stance('None')
            assert.same({}, first_actions(gs))
        end)
    end)
end)

describe('the tick of a dancer', function()
    describe('under AutoBuffMode', function()
        local function buffer(options)
            local gs = boot(options)
            gs:console('gs c set AutoBuffMode Auto')
            return gs
        end

        it('uses No Foot Rise with no finishing move', function()
            local gs = buffer()
            assert.same({'No Foot Rise'}, first_actions(gs))
        end)

        for _, buff in ipairs({'Finishing Move 1', 'Finishing Move 2', 'Finishing Move 3', 'Finishing Move 4',
            'Finishing Move 5', 'Finishing Move (6+)'}) do
            it(('uses nothing with %s'):format(buff), function()
                local gs = buffer({buffs = {buff}})
                assert.same({}, first_actions(gs))
            end)
        end

        it('uses nothing while No Foot Rise is on recast', function()
            local gs = buffer()
            gs.game:start_ability_recast('No Foot Rise', 30)
            assert.same({}, first_actions(gs))
        end)

        it('uses nothing with AutoBuffMode off', function()
            local gs = boot()
            assert.same({}, first_actions(gs))
        end)

        it('uses Berserk, then Aggressor, in combat with the sub job Warrior', function()
            local gs = buffer({sub_job = 'WAR', buffs = {'Finishing Move 1'}})
            gs.user.in_combat = true
            assert.same({'Berserk'}, first_actions(gs))
            gs = buffer({sub_job = 'WAR', buffs = {'Finishing Move 1', 'Berserk'}})
            gs.user.in_combat = true
            assert.same({'Aggressor'}, first_actions(gs))
        end)

        it('uses neither out of combat', function()
            local gs = buffer({sub_job = 'WAR', buffs = {'Finishing Move 1'}})
            assert.same({}, first_actions(gs))
        end)

        it('uses neither with an SJ Restriction', function()
            local gs = buffer({sub_job = 'WAR', buffs = {'Finishing Move 1', 'SJ Restriction'}})
            gs.user.in_combat = true
            assert.same({}, first_actions(gs))
        end)

        it('uses neither once both are up', function()
            local gs = buffer({sub_job = 'WAR', buffs = {'Finishing Move 1', 'Berserk', 'Aggressor'}})
            gs.user.in_combat = true
            assert.same({}, first_actions(gs))
        end)
    end)

    describe('with an auto step mode', function()
        local function stepper(mode, options)
            options = options or {}
            options.engaged = true
            options.buffs = options.buffs or {'Finishing Move 3'}
            options.tp = options.tp or 1200
            local gs = boot(options)
            gs:console('gs c set AutoStepMode ' .. mode)
            gs.user.in_combat = true
            return gs
        end

        it('uses the main step, Box Step, in the Main mode', function()
            local gs = stepper('Main')
            assert.same({'Box Step'}, first_actions(gs))
        end)

        it('uses the step the Main Step state names', function()
            local gs = stepper('Main')
            gs:console('gs c set MainStep Quickstep')
            assert.same({'Quickstep'}, first_actions(gs))
        end)

        it('uses the cycle step in the Cycle mode', function()
            local gs = stepper('Cycle')
            gs:console('gs c set CycleStep Feather Step')
            assert.same({'Feather Step'}, first_actions(gs))
        end)

        it('uses no step in the Off mode', function()
            local gs = stepper('Off')
            assert.same({}, first_actions(gs))
        end)

        it('uses no step out of combat', function()
            local gs = stepper('Main')
            gs.user.in_combat = false
            assert.same({}, first_actions(gs))
        end)

        it('uses no step while the steps are on recast', function()
            local gs = stepper('Main')
            gs.game:start_ability_recast('Quickstep', 30)
            assert.same({}, first_actions(gs))
        end)

        it('uses no step with no monster targeted', function()
            local gs = stepper('Main')
            gs.game.target_index = nil
            assert.same({}, first_actions(gs))
        end)
    end)

    describe('with an auto samba mode', function()
        local function sambaer(mode, options)
            options = options or {}
            options.engaged = true
            options.tp = options.tp or 1200
            options.buffs = options.buffs or {'Finishing Move 3'}
            local gs = boot(options)
            gs:console('gs c set AutoSambaMode ' .. mode)
            return gs
        end

        it('uses the samba chosen, with 400 TP or more engaged', function()
            local gs = sambaer('Haste Samba', {tp = 400})
            assert.same({'Haste Samba'}, first_actions(gs))
            gs = sambaer('Aspir Samba')
            assert.same({'Aspir Samba'}, first_actions(gs))
        end)

        it('uses none with less TP', function()
            local gs = sambaer('Haste Samba', {tp = 399})
            assert.same({}, first_actions(gs))
        end)

        it('uses none with a samba up', function()
            local gs = sambaer('Haste Samba', {buffs = {'Finishing Move 3', 'Haste Samba'}})
            assert.same({}, first_actions(gs))
        end)

        it('uses none while the sambas are on recast', function()
            local gs = sambaer('Haste Samba')
            gs.game:start_ability_recast('Drain Samba II', 30)
            assert.same({}, first_actions(gs))
        end)

        it('uses none when not engaged', function()
            local gs = boot({tp = 1200, buffs = {'Finishing Move 3'}})
            gs:console('gs c set AutoSambaMode Haste Samba')
            assert.same({}, first_actions(gs))
        end)

        it('uses none in the Off mode', function()
            local gs = sambaer('Off')
            assert.same({}, first_actions(gs))
        end)
    end)
end)

describe('Curing Waltz by a dancer on himself', function()
    -- missing HP of the 1500 and TP; the waltz asked for, the one used when it differs
    local function waltz(missing, tp, asked, options)
        options = options or {}
        options.tp = tp
        options.hp = 1500 - missing
        local gs = boot(options)
        gs:type(('/ja "%s" <me>'):format(asked))
        return gs
    end

    local tiers = {
        {100, 'Curing Waltz'}, {400, 'Curing Waltz II'}, {900, 'Curing Waltz III'},
    }

    for _, tier in ipairs(tiers) do
        local missing, name = unpack(tier)
        it(('is %s for %d HP missing, whatever the tier asked for'):format(name, missing), function()
            local gs = waltz(missing, 1500, 'Curing Waltz V')
            assert.same({name}, actions(gs))
            assert.is_true(said(gs, ('Trying to cure %d HP using %s.'):format(missing, name)))
        end)
    end

    it('goes out as asked when it is the tier for the HP missing', function()
        local gs = waltz(400, 1500, 'Curing Waltz II')
        assert.same({'Curing Waltz II'}, actions(gs))
        assert.is_false(said(gs, 'Trying to cure'))
    end)

    it('is Curing Waltz IV for 1100 HP missing, once Contradance is on recast', function()
        local gs = boot({tp = 1500, hp = 400})
        gs.game:start_ability_recast('Contradance', 100)
        gs:type('/ja "Curing Waltz V" <me>')
        assert.same({'Curing Waltz IV'}, actions(gs))
    end)

    it('is Contradance first for 1100 HP or more missing, and the waltz of the tier half a second later', function()
        local gs = waltz(1200, 1500, 'Curing Waltz V')
        assert.same({'Contradance'}, actions(gs))
        gs.game:start_ability_recast('Contradance', 100)
        gs:play(7)
        assert.same({'Curing Waltz IV'}, actions(gs))
    end)

    it('is refused for under 40 HP missing', function()
        local gs = waltz(30, 1500, 'Curing Waltz')
        assert.same({}, actions(gs))
        assert.is_true(said(gs, 'Abort: You have full HP!'))
    end)

    it('is refused with under 200 TP', function()
        local gs = waltz(400, 199, 'Curing Waltz II')
        assert.same({}, actions(gs))
        assert.is_true(said(gs, 'Abort: Insufficient TP [199] to waltz.'))
    end)

    it('is downgraded to what the TP buys, with a word of it', function()
        local gs = boot({tp = 300, hp = 300})
        gs.game:start_ability_recast('Contradance', 100)
        gs:type('/ja "Curing Waltz IV" <me>')
        assert.same({'Curing Waltz'}, actions(gs))
        assert.is_true(said(gs, 'Insufficient TP [300]. Downgrading to Curing Waltz.'))
    end)

    it('is the one the recasts allow when the right tier is on recast', function()
        local gs = boot({tp = 1500, hp = 1100})
        gs.game:start_ability_recast('Curing Waltz II', 30)
        gs:type('/ja "Curing Waltz II" <me>')
        assert.same({'Curing Waltz III'}, actions(gs))
    end)

    it('is left as it is for Healing Waltz', function()
        local gs = boot({tp = 1500, hp = 1450})
        gs:type('/ja "Healing Waltz" <me>')
        assert.same({'Healing Waltz'}, actions(gs))
    end)

    it('wears sets.precast.Waltz and sets.Self_Waltz', function()
        local gs = waltz(400, 1500, 'Curing Waltz II')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).precast.Waltz, sets_of(gs).Self_Waltz)), gs:worn())
    end)

    it('wears the set of Healing Waltz for it, and no Self_Waltz', function()
        local gs = boot({tp = 1500, hp = 1450})
        gs:type('/ja "Healing Waltz" <me>')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).precast.Waltz['Healing Waltz'])), gs:worn())
    end)

    it('is not refined with the Refine Waltz state off', function()
        local gs = boot({tp = 1500, hp = 1100})
        gs:console('gs c toggle RefineWaltz')
        gs:type('/ja "Curing Waltz V" <me>')
        assert.same({'Curing Waltz V'}, actions(gs))
    end)
end)

describe('Curing Waltz by a dancer on a party member', function()
    local function waltz_on_friend(hp, asked)
        local gs = boot({tp = 1500})
        gs.game:add_party_member({name = 'Friend', hp = hp})
        gs:console('gs c update')
        gs:traffic()
        gs:type(('/ja "%s" Friend'):format(asked))
        return gs
    end

    local function targeted(gs)
        local sent = {}
        for _, entry in ipairs(gs:traffic()) do
            if entry.action then
                sent[#sent + 1] = entry.action .. ' ' .. entry.target
            end
        end
        return sent
    end

    it('is the tier for the HP he is estimated to miss: 400 of 1000 gives Curing Waltz II', function()
        local gs = waltz_on_friend(600, 'Curing Waltz V')
        assert.same({'Curing Waltz II Friend'}, targeted(gs))
    end)

    it('is not refused for his full HP, as it can wake him', function()
        local gs = waltz_on_friend(1000, 'Curing Waltz V')
        assert.same({'Curing Waltz Friend'}, targeted(gs))
    end)

    it('goes out as asked when it is the tier for the HP he misses', function()
        local gs = waltz_on_friend(600, 'Curing Waltz II')
        assert.same({'Curing Waltz II Friend'}, targeted(gs))
    end)

    it('is Curing Waltz III for 700 HP missing', function()
        local gs = waltz_on_friend(300, 'Curing Waltz V')
        assert.same({'Curing Waltz III Friend'}, targeted(gs))
    end)

    it('counts half the HP missing under Contradance: Curing Waltz II for 700', function()
        local gs = boot({tp = 1500, buffs = {'Contradance'}})
        gs.game:add_party_member({name = 'Friend', hp = 300})
        gs:console('gs c update')
        gs:traffic()
        gs:type('/ja "Curing Waltz V" Friend')
        assert.same({'Curing Waltz II Friend'}, targeted(gs))
    end)

    it('wears sets.precast.Waltz without the self waltz set', function()
        local gs = waltz_on_friend(600, 'Curing Waltz II')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).precast.Waltz)), gs:worn())
    end)
end)

describe('Curing Waltz by a blue mage with the sub job Dancer', function()
    local function waltz(missing, asked)
        local gs = jobby.boot('BLU', {sub_job = 'DNC', tp = 1500})
        gs.game.player.vitals.hp = 1500 - missing
        gs:console('gs c update')
        gs:traffic()
        gs:type(('/ja "%s" <me>'):format(asked))
        return gs
    end

    local tiers = {{100, 'Curing Waltz'}, {200, 'Curing Waltz II'}, {400, 'Curing Waltz III'}}

    for _, tier in ipairs(tiers) do
        local missing, name = unpack(tier)
        it(('is %s for %d HP missing'):format(name, missing), function()
            local gs = waltz(missing, 'Curing Waltz V')
            assert.same({name}, actions(gs))
        end)
    end

    it('is refused for under 40 HP missing', function()
        local gs = waltz(30, 'Curing Waltz')
        assert.same({}, actions(gs))
        assert.is_true(said(gs, 'Abort: You have full HP!'))
    end)
end)

describe('the display of a dancer\'s state', function()
    local function display(gs)
        gs:console('gs c update user')
    end

    it('says the offense mode and the weapon skill mode', function()
        local gs = boot()
        display(gs)
        assert.is_true(said(gs, 'Melee: Normal, WS: Match'))
    end)

    it('adds the hybrid mode when it is not Normal', function()
        local gs = boot()
        gs:console('gs c set HybridMode DT')
        display(gs)
        assert.is_true(said(gs, 'Melee: Normal/DT, WS: Match'))
    end)

    it('adds the defense mode and its set', function()
        local gs = boot()
        gs:console('gs c set DefenseMode Physical')
        display(gs)
        assert.is_true(said(gs, 'Melee: Normal, WS: Match, Defense: Physical (PDT)'))
    end)

    it('adds kiting', function()
        local gs = boot()
        gs:console('gs c toggle Kiting')
        display(gs)
        assert.is_true(said(gs, 'Melee: Normal, WS: Match, Kiting'))
    end)
end)
