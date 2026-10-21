local harness = require('harness')
local jobby = require('jobby')

local pieces = {'Volte Cap', 'Volte Jupon', 'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Null Masque',
    'Adamantite Armor', "Orunmila's Torque", 'Weike Torque', 'Sortiarius Earring', 'Beatific Earring',
    'Pensee Earring', 'Moonshade Earring', 'Wanion Belt', 'Prodigious Mantle', 'Malignance Chapeau', 'Setan Kober',
    'Horos T. Shoes +2'}

-- Jobby as a dancer with the idle set on. The options are those of a boot (sub_job, tp, buffs, wearing) and these
-- besides:
--   engaged   true to engage the monster
--   hp        the HP of the 1500 he has
--   kobers    the number of Setan Kobers he has, one unless given
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
    gs:forget()
    return gs
end

-- What every Jobby gear file's idle set wears, as the game shows it worn, with the dancer's dagger in hand.
local idle = jobby.worn_by(jobby.idle, jobby.weapons.DNC)

local function sets_of(gs)
    return gs.user.sets
end

-- The actions the tick sent in its first moments (it starts five seconds after the file loads).
local function first_actions(gs)
    gs:play(harness.sel_load_time + 0.3)
    return gs:actions()
end

local function engaged_worn(gs, ...)
    return jobby.worn_by(idle, jobby.layer(sets_of(gs).engaged, ...))
end

describe('a step', function()
    it('wears sets.precast.Step', function()
        local gs = boot({tp = 0})
        gs:type('/ja "Box Step" <t>')
        local sent = gs:traffic()
        assert.same(jobby.layer(sets_of(gs).precast.Step), sent[1].equip)
        assert.equal('Box Step', sent[2].action)
    end)

    describe('with Presto ready, engaged, with at least 100 TP and fewer than three finishing moves', function()
        it('is held back for Presto', function()
            local gs = boot({tp = 1200, engaged = true})
            gs:type('/ja "Box Step" <t>')
            assert.same({'Presto'}, gs:actions())
        end)

        it('goes out once Presto is on recast, a second later', function()
            local gs = boot({tp = 1200, engaged = true})
            gs:type('/ja "Box Step" <t>')
            gs:traffic()
            gs.game:start_ability_recast('Presto', 30)
            gs:advance(1.2)
            assert.same({'Box Step'}, gs:actions())
        end)

        it('goes out at once with the Auto Presto Mode off', function()
            local gs = boot({tp = 1200, engaged = true})
            gs:console('gs c toggle AutoPrestoMode')
            gs:type('/ja "Box Step" <t>')
            assert.same({'Box Step'}, gs:actions())
        end)

        it('goes out at once with 99 TP', function()
            local gs = boot({tp = 99, engaged = true})
            gs:type('/ja "Box Step" <t>')
            assert.same({'Box Step'}, gs:actions())
        end)

        it('goes out at once with three finishing moves', function()
            local gs = boot({tp = 1200, engaged = true, buffs = {'Finishing Move 3'}})
            gs:type('/ja "Box Step" <t>')
            assert.same({'Box Step'}, gs:actions())
        end)

        it('goes out at once while Presto is on recast', function()
            local gs = boot({tp = 1200, engaged = true})
            gs.game:start_ability_recast('Presto', 30)
            gs:type('/ja "Box Step" <t>')
            assert.same({'Box Step'}, gs:actions())
        end)

        it('is refused while the steps are on recast', function()
            local gs = boot({tp = 1200, engaged = true})
            gs.game:start_ability_recast('Quickstep', 30)
            gs:type('/ja "Box Step" <t>')
            assert.same({}, gs:actions())
            assert.same({'Abort: [Box Step] waiting on recast. (0:00:30)'}, gs:chat())
        end)
    end)

    it('engages the monster first when not engaged and close, as Sel\'s idle step does, then goes out', function()
        local gs = boot({tp = 1200})
        gs:type('/ja "Box Step" <t>')
        assert.same({'category 2', 'Box Step'}, gs:actions())
    end)
end)

describe('gs c step', function()
    local function step(gs, command)
        gs:console(command or 'gs c step')
        return gs:actions()
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
        gs.game.monster.claim_id = gs.game.player.id
        gs.game.monster.hpp = 0
        gs:play(harness.sel_load_time + 0.3)
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
        return gs:actions()
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
        for _, buff in ipairs({'Finishing Move 3', 'Finishing Move 4', 'Finishing Move 5', 'Finishing Move (6+)'}) do
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

    pending('is held back at 1095 TP with Horos T. Shoes +2 in sets.precast.Step, which take 10 off the cost: '
        .. 'job_setup in data/DNC.lua works the reduction out before the gear file has built sets.precast.Step, so it is '
        .. 'nothing until a sub job change runs job_setup again')

    -- In a defense mode step_cost in data/DNC.lua counts no shoes, so the cost there is a hundred less the kobers'.
    local function defending(options)
        local gs = buffer(options)
        gs:console('gs c set DefenseMode Physical')
        return gs
    end

    it('goes out at 1099 TP and is held back at 1100 in a defense mode, a step costing a hundred', function()
        assert.same({'Rudra\'s Storm'}, weaponskill(defending({tp = 1099})))
        assert.same({'Presto'}, weaponskill(defending({tp = 1100})))
    end)

    it('goes out at 1059 TP and is held back at 1060 in a defense mode with a Setan Kober in hand, which takes 40 '
        .. 'off the cost', function()
        assert.same({'Rudra\'s Storm'}, weaponskill(defending({tp = 1059, wearing = {main = 'Setan Kober'}})))
        assert.same({'Presto'}, weaponskill(defending({tp = 1060, wearing = {main = 'Setan Kober'}})))
    end)

    it('goes out at 1019 TP and is held back at 1020 in a defense mode with a Setan Kober in each hand, which take 80 '
        .. 'off the cost', function()
        local kobers = {main = 'Setan Kober', sub = 'Setan Kober'}
        assert.same({'Rudra\'s Storm'}, weaponskill(defending({tp = 1019, wearing = kobers, kobers = 2})))
        assert.same({'Presto'}, weaponskill(defending({tp = 1020, wearing = kobers, kobers = 2})))
    end)

    it('goes out with the AutoBuffMode off', function()
        local gs = boot({tp = 1200, engaged = true})
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)

    it('is held back for no step when not engaged', function()
        local gs = boot({tp = 1200})
        gs:console('gs c set AutoBuffMode Auto')
        assert.same({'Rudra\'s Storm'}, weaponskill(gs))
    end)
end)

describe('a weapon skill by a dancer', function()
    -- Jobby engaged with that TP, once the commands given have run: the session, and what is worn once Rudra's Storm
    -- is out.
    local function ws(tp, ...)
        local gs = boot({tp = tp, engaged = true})
        for _, command in ipairs({...}) do
            gs:console(command)
        end
        gs:traffic()
        return gs, jobby.weaponskill(gs, '/ws "Rudra\'s Storm" <t>')
    end

    it('trades the Moonshade Earring for sets.MaxTP from 2951 TP', function()
        local gs, worn = ws(2951)
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Rudra\'s Storm'], sets_of(gs).MaxTP), worn)
    end)

    it('trades it for sets.AccMaxTP in the Acc offense mode', function()
        local gs, worn = ws(3000, 'gs c set OffenseMode Acc')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Rudra\'s Storm'], sets_of(gs).AccMaxTP), worn)
    end)

    it('keeps the Moonshade Earring at 2950 TP', function()
        local gs, worn = ws(2950)
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Rudra\'s Storm']), worn)
    end)

    it('wears sets.buff["Climactic Flourish"] over the weapon skill set while that is up', function()
        local gs = boot({tp = 2000, engaged = true})
        gs:gain_buff('Climactic Flourish')
        gs:traffic()
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Rudra\'s Storm'], sets_of(gs).buff['Climactic Flourish']),
            jobby.weaponskill(gs, '/ws "Rudra\'s Storm" <t>'))
    end)

    describe('with a Climactic Flourish up and AutoBuffMode on', function()
        -- Jobby, engaged with 2000 TP unless given, uses Rudra's Storm, which goes out at once; the server answers it,
        -- and seven seconds pass. The options are those of a boot and these besides:
        --   recasts   the abilities on recast besides Climactic Flourish, Presto and the steps
        --   tp_left   the TP the weapon skill leaves, 0 unless given
        local function finished(options)
            options.tp = options.tp or 2000
            options.engaged = true
            options.buffs = options.buffs or {}
            options.buffs[#options.buffs + 1] = 'Climactic Flourish'
            local gs = boot(options)
            gs:console('gs c set AutoBuffMode Auto')
            for _, name in ipairs({'Climactic Flourish', 'Presto', 'Quickstep', unpack(options.recasts or {})}) do
                gs.game:start_ability_recast(name, 30)
            end
            gs:type('/ws "Rudra\'s Storm" <t>')
            assert.same({'Rudra\'s Storm'}, gs:actions())
            gs:chat()
            gs.game.player.vitals.tp = options.tp_left or 0
            gs:finish_action()
            gs:play(7)
            return gs
        end

        it('is followed by Reverse Flourish, with three finishing moves and 998 TP left', function()
            local gs = finished({buffs = {'Finishing Move 3'}, tp_left = 998})
            assert.same({'Reverse Flourish'}, gs:actions())
        end)

        it('is followed by no Reverse Flourish with fewer than three finishing moves', function()
            local gs = finished({buffs = {'Finishing Move 2'}})
            assert.same({}, gs:actions())
        end)

        it('is followed by no Reverse Flourish while it is on recast', function()
            local gs = finished({buffs = {'Finishing Move 3'}, recasts = {'Reverse Flourish'}})
            assert.same({}, gs:actions())
            assert.same({}, jobby.said(gs))
        end)

        it('is followed by no Reverse Flourish with 999 TP left', function()
            local gs = finished({buffs = {'Finishing Move 3'}, tp_left = 999})
            assert.same({}, gs:actions())
        end)
    end)

    it('is followed by no Reverse Flourish with AutoBuffMode off', function()
        local gs = boot({tp = 2000, engaged = true, buffs = {'Climactic Flourish', 'Finishing Move 3'}})
        gs:type('/ws "Rudra\'s Storm" <t>')
        gs:traffic()
        gs.game.player.vitals.tp = 0
        gs:finish_action()
        gs:play(7)
        assert.same({}, gs:actions())
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
        assert.same(jobby.layer(sets_of(gs).precast.Samba), equip)
    end)

    it('wear sets.precast.Flourish1 for Animated Flourish', function()
        local gs, equip = equip_of('/ja "Animated Flourish" <t>')
        assert.same(jobby.layer(sets_of(gs).precast.Flourish1), equip)
    end)

    it('wear sets.precast.Flourish1 for Violent Flourish', function()
        local gs, equip = equip_of('/ja "Violent Flourish" <t>')
        assert.same(jobby.layer(sets_of(gs).precast.Flourish1), equip)
    end)

    it('wear sets.precast.Flourish2 for Reverse Flourish', function()
        local gs, equip = equip_of('/ja "Reverse Flourish" <me>')
        assert.same(jobby.layer(sets_of(gs).precast.Flourish2), equip)
    end)

    it('wear sets.precast.Flourish3 for Striking Flourish', function()
        local gs, equip = equip_of('/ja "Striking Flourish" <me>')
        assert.same(jobby.layer(sets_of(gs).precast.Flourish3), equip)
    end)

    it('wear nothing for an ability with no set, such as Saber Dance', function()
        local gs = boot()
        gs:type('/ja "Saber Dance" <me>')
        assert.same({{action = 'Saber Dance', target = 'Jobby'}}, gs:traffic())
    end)
end)

describe('the dances', function()
    it('put sets.engaged.Saber on the engaged dancer while Saber Dance is up', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Saber Dance')
        assert.same(jobby.worn_by(idle, jobby.layer(sets_of(gs).engaged.Saber)), gs:worn())
    end)

    it('put sets.engaged.Fan on the engaged dancer while Fan Dance is up', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Fan Dance')
        assert.same(jobby.worn_by(idle, jobby.layer(sets_of(gs).engaged.Fan)), gs:worn())
    end)

    it('put sets.engaged back when the dance ends', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Saber Dance')
        gs:lose_buff('Saber Dance')
        assert.same(jobby.worn_by(idle, jobby.layer(sets_of(gs).engaged)), gs:worn())
    end)

    it('put sets.buff["Saber Dance"] over the engaged set in a defense mode', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Saber Dance')
        gs:console('gs c set DefenseMode Physical')
        assert.same(jobby.worn_by(idle, jobby.layer(sets_of(gs).engaged.Saber, sets_of(gs).buff['Saber Dance'],
            sets_of(gs).defense.PDT)), gs:worn())
    end)

    it('put sets.buff["Climactic Flourish"] over the engaged set in a defense mode', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Climactic Flourish')
        gs:console('gs c set DefenseMode Physical')
        assert.same(jobby.worn_by(idle, jobby.layer(sets_of(gs).engaged, sets_of(gs).buff['Climactic Flourish'],
            sets_of(gs).defense.PDT)), gs:worn())
    end)

    it('put no buff set over the engaged set without a defense mode', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Climactic Flourish')
        assert.same(jobby.worn_by(idle, jobby.layer(sets_of(gs).engaged)), gs:worn())
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
            gs:chat()
            assert.same({}, first_actions(gs))
            assert.same({}, jobby.said(gs))
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
            gs:chat()
            assert.same({}, first_actions(gs))
            assert.same({}, jobby.said(gs))
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

        pending('uses no step while idle in combat, as autostep_engaged_only, which job_setup sets, means: check_step '
            .. 'in data/DNC.lua tests not player.status == \'Engaged\', which Lua reads as (not player.status) == '
            .. '\'Engaged\', never true, so the tick steps idle as engaged, and Sel engages the monster for the step')

        it('uses no step while the steps are on recast', function()
            local gs = stepper('Main')
            gs.game:start_ability_recast('Quickstep', 30)
            gs:chat()
            assert.same({}, first_actions(gs))
            assert.same({}, jobby.said(gs))
        end)

        it('uses no step with no monster targeted', function()
            local gs = stepper('Main')
            gs.game.target_index = nil
            assert.same({}, first_actions(gs))
            assert.same({}, jobby.typed(gs))
        end)
    end)

    -- Sel's tick uses the samba; tests/sel/auto_subjob_spec.lua tries the rest of it with a dancer sub job.
    it('uses the samba of the auto samba mode with 400 TP engaged, a dancer by main job', function()
        for _, samba in ipairs({'Haste Samba', 'Aspir Samba'}) do
            local gs = boot({engaged = true, tp = 400, buffs = {'Finishing Move 3'}})
            gs:console('gs c set AutoSambaMode ' .. samba)
            assert.same({samba}, first_actions(gs))
        end
    end)
end)

describe('Curing Waltz by a dancer on himself', function()
    -- missing HP of the 1500 and TP; the waltz asked for
    local function waltz(missing, tp, asked)
        local gs = boot({tp = tp, hp = 1500 - missing})
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
            assert.same({name}, gs:actions())
            assert.same({('Trying to cure %d HP using %s.'):format(missing, name)}, gs:chat())
        end)
    end

    it('goes out as asked when it is the tier for the HP missing', function()
        local gs = waltz(400, 1500, 'Curing Waltz II')
        assert.same({'Curing Waltz II'}, gs:actions())
        assert.same({}, gs:chat())
    end)

    it('is Curing Waltz IV for 1100 HP missing, once Contradance is on recast', function()
        local gs = boot({tp = 1500, hp = 400})
        gs.game:start_ability_recast('Contradance', 100)
        gs:type('/ja "Curing Waltz V" <me>')
        assert.same({'Curing Waltz IV'}, gs:actions())
    end)

    it('is Contradance first for 1100 HP or more missing, and the waltz of the tier half a second later', function()
        local gs = waltz(1200, 1500, 'Curing Waltz V')
        assert.same({'Contradance'}, gs:actions())
        gs.game:start_ability_recast('Contradance', 100)
        gs:finish_action()
        gs:play(0.4)
        assert.same({}, gs:actions())
        gs:play(0.2)
        assert.same({'Curing Waltz IV'}, gs:actions())
    end)

    it('is refused for under 40 HP missing', function()
        local gs = waltz(30, 1500, 'Curing Waltz')
        assert.same({}, gs:actions())
        assert.same({'Abort: You have full HP!'}, gs:chat())
    end)

    it('is refused with under 200 TP', function()
        local gs = waltz(400, 199, 'Curing Waltz II')
        assert.same({}, gs:actions())
        assert.same({'Abort: Insufficient TP [199] to waltz.'}, gs:chat())
    end)

    it('goes out with 200 TP, as Curing Waltz, the tier that buys', function()
        local gs = waltz(400, 200, 'Curing Waltz II')
        assert.same({'Curing Waltz'}, gs:actions())
    end)

    it('is downgraded to what the TP buys, with a word of it', function()
        local gs = boot({tp = 300, hp = 300})
        gs.game:start_ability_recast('Contradance', 100)
        gs:type('/ja "Curing Waltz IV" <me>')
        assert.same({'Curing Waltz'}, gs:actions())
        assert.same({'Insufficient TP [300]. Downgrading to Curing Waltz.', 'Trying to cure 1200 HP using Curing Waltz.'},
            gs:chat())
    end)

    it('is the one the recasts allow when the right tier is on recast', function()
        local gs = boot({tp = 1500, hp = 1100})
        gs.game:start_ability_recast('Curing Waltz II', 30)
        gs:type('/ja "Curing Waltz II" <me>')
        assert.same({'Curing Waltz III'}, gs:actions())
    end)

    it('is left as it is for Healing Waltz', function()
        local gs = boot({tp = 1500, hp = 1450})
        gs:type('/ja "Healing Waltz" <me>')
        assert.same({'Healing Waltz'}, gs:actions())
    end)

    it('wears sets.precast.Waltz and sets.Self_Waltz', function()
        local gs = waltz(400, 1500, 'Curing Waltz II')
        assert.same(jobby.worn_by(idle, jobby.layer(sets_of(gs).precast.Waltz, sets_of(gs).Self_Waltz)),
            gs:worn())
    end)

    it('wears the set of Healing Waltz for it, and no Self_Waltz', function()
        local gs = boot({tp = 1500, hp = 1450})
        gs:type('/ja "Healing Waltz" <me>')
        assert.same(jobby.worn_by(idle, jobby.layer(sets_of(gs).precast.Waltz['Healing Waltz'])), gs:worn())
    end)

    it('is not refined with the Refine Waltz state off', function()
        local gs = boot({tp = 1500, hp = 1100})
        gs:console('gs c toggle RefineWaltz')
        gs:type('/ja "Curing Waltz V" <me>')
        assert.same({'Curing Waltz V'}, gs:actions())
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
        for _, entry in ipairs(gs:action_entries()) do
            sent[#sent + 1] = entry.action .. ' ' .. entry.target
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
        assert.same(jobby.worn_by(idle, jobby.layer(sets_of(gs).precast.Waltz)), gs:worn())
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
            assert.same({name}, gs:actions())
        end)
    end

    it('is refused for under 40 HP missing', function()
        local gs = waltz(30, 'Curing Waltz')
        assert.same({}, gs:actions())
        assert.same({'Abort: You have full HP!'}, gs:chat())
    end)
end)

describe('the display of a dancer\'s state', function()
    -- What gs c update user puts in the chat.
    local function display(gs)
        gs:chat()
        gs:console('gs c update user')
        return gs:chat()
    end

    it('says the offense mode and the weapon skill mode', function()
        local gs = boot()
        assert.same({'Melee: Normal, WS: Match'}, display(gs))
    end)

    it('adds the hybrid mode when it is not Normal', function()
        local gs = boot()
        gs:console('gs c set HybridMode DT')
        assert.same({'Melee: Normal/DT, WS: Match'}, display(gs))
    end)

    it('adds the defense mode and its set', function()
        local gs = boot()
        gs:console('gs c set DefenseMode Physical')
        assert.same({'Melee: Normal, WS: Match, Defense: Physical (PDT)'}, display(gs))
    end)

    it('adds kiting', function()
        local gs = boot()
        gs:console('gs c toggle Kiting')
        assert.same({'Melee: Normal, WS: Match, Kiting'}, display(gs))
    end)
end)
