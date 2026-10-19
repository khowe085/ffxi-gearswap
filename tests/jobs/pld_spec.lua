local jobby = require('jobby')

local gear = {'Naegling', 'Ragnarok', 'Kheshig Blade', 'Aegis', 'Volte Cap', 'Null Masque', 'Volte Jupon',
    'Adamantite Armor', 'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Fotia Gorget', "Combatant's Torque",
    'Null Belt', 'Moonshade Earring', 'Brutal Earring', 'Lugra Earring', 'Cessance Earring', 'Odnowa Earring +1',
    'Karieyh Ring'}

local actions_of = jobby.action_names

local function boot(options)
    options = options or {}
    options.items = gear
    options.sub_job = options.sub_job or 'WHM'
    return jobby.boot('PLD', options)
end

local function boot_ticking(options)
    options = options or {}
    options.items = gear
    options.sub_job = options.sub_job or 'WHM'
    return jobby.boot_ticking('PLD', options)
end

local function weaponskill(gs, line)
    gs:type(line)
    local traffic = gs:traffic()
    assert.is_truthy(traffic[#traffic] and traffic[#traffic].action, 'the weapon skill didn\'t go out')
    return gs:worn()
end

-- What is worn with the idle set on and the engaged set over it.
local function engaged_with(changes)
    local set = {head = 'Volte Cap', body = 'Volte Jupon'}
    for slot, item in pairs(changes or {}) do
        set[slot] = item
    end
    return jobby.worn_by(set, jobby.full_idle)
end

describe('PLD\'s weapon skill filter', function()
    -- A club in hand gives the weapon skill Flash Nova.
    local club = {'Flash Nova', 'Realmrazer', 'True Strike'}

    local function sent(known, typed)
        local gs = boot({tp = 1000, abilities = known})
        gs:type('/ws "' .. typed .. '" <t>')
        return actions_of(gs:traffic())
    end

    it('sends Realmrazer in place of Savage Blade with a club\'s weapon skills', function()
        assert.same({'Realmrazer'}, sent(club, 'Savage Blade'))
    end)

    it('sends True Strike in place of Chant du Cygne with a club\'s weapon skills', function()
        assert.same({'True Strike'}, sent(club, 'Chant du Cygne'))
    end)

    it('sends Flash Nova in place of Sanguine Blade with a club\'s weapon skills', function()
        assert.same({'Flash Nova'}, sent(club, 'Sanguine Blade'))
    end)

    it('sends nothing in place of another weapon skill with a club\'s weapon skills', function()
        assert.same({}, sent(club, 'Requiescat'))
    end)

    it('sends nothing in place of Savage Blade without Flash Nova', function()
        assert.same({}, sent({'Realmrazer'}, 'Savage Blade'))
    end)

    it('lets a weapon skill Jobby has go out as it is', function()
        assert.same({'Savage Blade'}, sent({'Flash Nova', 'Savage Blade'}, 'Savage Blade'))
    end)
end)

describe('PLD\'s Flash', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is held for Divine Emblem when it is ready', function()
        gs:type('/ma "Flash" <t>')
        assert.same({
            {equip = {head = 'Null Masque'}},
            {action = 'Divine Emblem', target = 'Jobby'},
        }, gs:traffic())
    end)

    it('goes out a second after Divine Emblem, with its midcast set', function()
        gs:type('/ma "Flash" <t>')
        gs:traffic()
        gs:finish_action()
        gs.game:start_ability_recast('Divine Emblem', 60)
        gs:advance(0.95)
        assert.same({}, actions_of(gs:traffic()))
        gs:advance(0.1)
        assert.same({'Flash'}, actions_of(gs:traffic()))
        assert.equal('Volte Bracers', gs:worn().hands)
    end)

    it('goes out at once while Divine Emblem is on recast', function()
        gs.game:start_ability_recast('Divine Emblem', 60)
        gs:type('/ma "Flash" <t>')
        assert.same({'Flash'}, actions_of(gs:traffic()))
    end)

    it('goes out at once with Auto Emblem off', function()
        gs:console('gs c toggle AutoEmblem')
        gs:type('/ma "Flash" <t>')
        assert.same({'Flash'}, actions_of(gs:traffic()))
    end)

    it('goes out at once under amnesia', function()
        gs:gain_buff('amnesia')
        gs:type('/ma "Flash" <t>')
        assert.same({'Flash'}, actions_of(gs:traffic()))
    end)

    it('goes out at once with Divine Emblem up and its own recast ready', function()
        gs.game:start_ability_recast('Divine Emblem', 60)
        gs:gain_buff('Divine Emblem')
        gs:type('/ma "Flash" <t>')
        assert.same({'Flash'}, actions_of(gs:traffic()))
    end)
end)

describe('PLD\'s weapon skill set', function()
    local function ws(tp, line, setup)
        local gs = boot({tp = tp})
        if setup then
            setup(gs)
        end
        return weaponskill(gs, line)
    end

    local function acc(gs)
        gs:console('gs c set OffenseMode Acc')
    end

    local function at_night(gs)
        gs:set_time(22 * 60)
    end

    it('is sets.precast.WS[name] with no cap TP, Moonshade Earring in it', function()
        local worn = ws(1000, '/ws "Savage Blade" <t>')
        assert.equal('Moonshade Earring', worn.left_ear)
        assert.equal('Volte Bracers', worn.hands)
    end)

    it('swaps Moonshade Earring for sets.DayMaxTPWSEars by day when TP, with Moonshade\'s 250, is over 3200', function()
        assert.equal('Cessance Earring', ws(2951, '/ws "Savage Blade" <t>').left_ear)
    end)

    it('keeps Moonshade Earring on at 2950 TP', function()
        assert.equal('Moonshade Earring', ws(2950, '/ws "Savage Blade" <t>').left_ear)
    end)

    it('swaps Moonshade Earring for sets.MaxTP at night', function()
        assert.equal('Lugra Earring', ws(3000, '/ws "Savage Blade" <t>', at_night).left_ear)
    end)

    it('swaps in sets.AccDayMaxTPWSEars by day in an accuracy offense mode', function()
        local worn = ws(3000, '/ws "Savage Blade" <t>', acc)
        assert.equal('Odnowa Earring +1', worn.left_ear)
        assert.equal('Adamantite Armor', worn.body)
    end)

    it('swaps in sets.AccMaxTP at night in an accuracy offense mode', function()
        local worn = ws(3000, '/ws "Savage Blade" <t>', function(gs) at_night(gs) acc(gs) end)
        assert.equal('Lugra Earring', worn.left_ear)
        assert.equal('Adamantite Armor', worn.body)
    end)

    it('swaps in sets.MaxTP, not sets.AccMaxTP, under Sneak Attack in an accuracy offense mode', function()
        local worn = ws(3000, '/ws "Savage Blade" <t>', function(gs)
            acc(gs)
            gs:gain_buff('Sneak Attack')
        end)
        assert.equal('Cessance Earring', worn.left_ear)
    end)

    it('has Lugra Earring in the set swapped for sets.DayWSEars by day', function()
        assert.equal('Cessance Earring', ws(1000, '/ws "Requiescat" <t>').left_ear)
    end)

    it('keeps Lugra Earring on at night', function()
        assert.equal('Lugra Earring', ws(1000, '/ws "Requiescat" <t>', at_night).left_ear)
    end)

    it('swaps in sets.AccDayWSEars with Lugra Earring by day in an accuracy offense mode', function()
        assert.equal('Odnowa Earring +1', ws(1000, '/ws "Requiescat" <t>', acc).left_ear)
    end)

    it('swaps in sets.DayWSEars by day below the cap when the set has Moonshade Earring and Lugra Earring', function()
        local worn = ws(1000, '/ws "Chant du Cygne" <t>')
        assert.equal('Cessance Earring', worn.left_ear)
        assert.equal('Lugra Earring', worn.right_ear)
    end)

    it('keeps Moonshade Earring on below the cap at night, with Lugra Earring in the set', function()
        assert.equal('Moonshade Earring', ws(1000, '/ws "Chant du Cygne" <t>', at_night).left_ear)
    end)

    it('swaps in sets.AccDayWSEars by day below the cap in an accuracy offense mode, with both earrings in the set', function()
        assert.equal('Odnowa Earring +1', ws(1000, '/ws "Chant du Cygne" <t>', acc).left_ear)
    end)

    it('swaps in sets.DayWSEars, not sets.AccDayWSEars, under Sneak Attack in an accuracy offense mode', function()
        local worn = ws(1000, '/ws "Chant du Cygne" <t>', function(gs)
            acc(gs)
            gs:gain_buff('Sneak Attack')
        end)
        assert.equal('Cessance Earring', worn.left_ear)
    end)
end)

describe('PLD\'s steps', function()
    it('start with Box Step as the current step', function()
        assert.equal('Box Step', boot().user.state.CurrentStep.value)
    end)

    it('change the current step to the other one once a step is used', function()
        local gs = boot()
        gs:engage()
        gs:type('/ja "Box Step" <t>')
        gs:finish_action()
        assert.equal('Quickstep', gs.user.state.CurrentStep.value)
        gs:advance(5)
        gs:type('/ja "Quickstep" <t>')
        gs:finish_action()
        assert.equal('Box Step', gs.user.state.CurrentStep.value)
    end)

    it('leave the current step alone for another ability', function()
        local gs = boot()
        gs:engage()
        gs:type('/ja "Provoke" <t>')
        gs:finish_action()
        assert.equal('Box Step', gs.user.state.CurrentStep.value)
    end)
end)

describe('PLD\'s extra defense mode', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('puts sets.engaged.Aegis on, engaged', function()
        gs:engage()
        gs:console('gs c set ExtraDefenseMode Aegis')
        assert.same(engaged_with({legs = 'Volte Hose'}), gs:worn())
    end)

    it('puts sets.engaged back when it goes back to None', function()
        gs:engage()
        gs:console('gs c set ExtraDefenseMode Aegis')
        gs:console('gs c set ExtraDefenseMode None')
        assert.same(engaged_with({}), gs:worn())
    end)

    it('lays sets.Aegis over the defense set while a defense mode is on', function()
        gs:console('gs c set ExtraDefenseMode Aegis')
        gs:console('gs c set DefenseMode Physical')
        assert.same(jobby.worn_by({neck = "Combatant's Torque", feet = 'Volte Boots'}, jobby.full_idle), gs:worn())
    end)

    it('lays no extra set over the idle set without a defense mode', function()
        gs:console('gs c set ExtraDefenseMode Aegis')
        assert.same(jobby.worn_by({}, jobby.full_idle), gs:worn())
    end)
end)

describe('PLD\'s defense set', function()
    it('is sets.defense.PDT in the Physical defense mode', function()
        local gs = boot()
        gs:console('gs c set DefenseMode Physical')
        assert.same(jobby.worn_by({neck = "Combatant's Torque"}, jobby.full_idle), gs:worn())
    end)

    it('is sets.defense.PDT[\'Kheshig Blade\'] with Kheshig Blade in hand after an update', function()
        local gs = boot()
        gs:console('gs c set Weapons Kheshig')
        gs:console('gs c update')
        gs:console('gs c set DefenseMode Physical')
        assert.equal('Fotia Gorget', gs:worn().neck)
    end)

    it('has the dual wield engaged set with a Dancer sub job and a weapon, not a shield, in the sub slot', function()
        local gs = boot({sub_job = 'DNC', wearing = {main = 'Naegling', sub = 'Kheshig Blade'}})
        gs:engage()
        assert.equal('Volte Bracers', gs:worn().hands)
    end)

    it('has the plain engaged set with a Dancer sub job and a shield in the sub slot', function()
        local gs = boot({sub_job = 'DNC', wearing = {main = 'Naegling', sub = 'Aegis'}})
        gs:engage()
        assert.equal('Nyame Gauntlets', gs:worn().hands)
    end)

    it('has the dual wield engaged set with a Ninja sub job and a weapon in the sub slot', function()
        local gs = boot({sub_job = 'NIN', wearing = {main = 'Naegling', sub = 'Kheshig Blade'}})
        gs:engage()
        assert.equal('Volte Bracers', gs:worn().hands)
    end)

    it('is sets.defense.PDT without Kheshig Blade in hand', function()
        local gs = boot()
        gs:console('gs c set Weapons Ragnarok')
        gs:console('gs c update')
        gs:console('gs c set DefenseMode Physical')
        assert.equal("Combatant's Torque", gs:worn().neck)
    end)
end)

describe('PLD\'s rune element', function()
    local expected = {
        Ignis = {'Ice', 'Fire'}, Gelus = {'Wind', 'Ice'}, Flabra = {'Earth', 'Wind'}, Tellus = {'Lightning', 'Earth'},
        Sulpor = {'Water', 'Lightning'}, Unda = {'Fire', 'Water'}, Lux = {'Darkness', 'Light'},
        Tenebrae = {'Light', 'Darkness'},
    }

    for rune, pair in pairs(expected) do
        it(('has %s resist and %s damage after an update with %s'):format(pair[1], pair[2], rune), function()
            local gs = boot()
            gs:console('gs c set RuneElement ' .. rune)
            gs:console('gs c update')
            assert.equal(pair[1], gs.user.RuneResist)
            assert.equal(pair[2], gs.user.RuneDamage)
        end)
    end
end)

describe('PLD\'s stance', function()
    it('is set to None on an update without Samurai as the sub job', function()
        assert.equal('None', boot({sub_job = 'WHM'}).user.state.Stance.value)
    end)

    it('is left alone on an update with Samurai as the sub job', function()
        assert.equal('Hasso', boot({sub_job = 'SAM'}).user.state.Stance.value)
    end)
end)

describe('PLD\'s idle set', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('has sets.latent_refresh over it under 51% MP', function()
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 400, 40
        gs:console('gs c update')
        assert.same(jobby.worn_by({waist = 'Null Belt'}, jobby.full_idle), gs:worn())
    end)

    it('has no latent refresh set over it at 51% MP', function()
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 510, 51
        gs:console('gs c update')
        assert.same(jobby.worn_by({}, jobby.full_idle), gs:worn())
    end)

    it('has sets.latent_regen over it under 71% HP', function()
        gs.game.player.vitals.hp, gs.game.player.vitals.hpp = 1000, 70
        gs:console('gs c update')
        assert.same(jobby.worn_by({ring1 = 'Karieyh Ring'}, jobby.full_idle), gs:worn())
    end)

    it('has no latent regen set over it at 71% HP', function()
        gs.game.player.vitals.hp, gs.game.player.vitals.hpp = 1065, 71
        gs:console('gs c update')
        assert.same(jobby.worn_by({}, jobby.full_idle), gs:worn())
    end)

    it('has neither over it in the DT idle mode', function()
        gs:console('gs c set IdleMode DT')
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 400, 40
        gs.game.player.vitals.hp, gs.game.player.vitals.hpp = 1000, 70
        gs:console('gs c update')
        assert.same(jobby.worn_by({}, jobby.full_idle), gs:worn())
    end)
end)

describe('PLD\'s Majesty', function()
    it('is used in a fight with Auto Majesty on, which it is', function()
        local gs = boot_ticking()
        gs:monster_hits()
        assert.same({'Majesty'}, actions_of(jobby.until_action(gs)))
    end)

    it('wears sets.precast.JA.Majesty', function()
        local gs = boot_ticking()
        gs:monster_hits()
        local traffic = jobby.until_action(gs)
        assert.same({equip = {head = 'Volte Cap'}}, traffic[1])
    end)

    it('is not used out of a fight', function()
        local gs = boot_ticking()
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)

    it('is not used with Majesty up', function()
        local gs = boot_ticking()
        gs:monster_hits()
        gs:gain_buff('Majesty')
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)

    it('is not used while it is on recast', function()
        local gs = boot_ticking()
        gs:monster_hits()
        gs.game:start_ability_recast('Majesty', 60)
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)

    it('is not used under amnesia', function()
        local gs = boot_ticking()
        gs:monster_hits()
        gs:gain_buff('amnesia')
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)

    it('is left to Auto Buff Mode, which uses nothing more, when Majesty is up in a fight', function()
        local gs = boot_ticking({buffs = {'Majesty', 'Enmity Boost', 'Reprisal', 'Phalanx'}})
        gs:console('gs c set AutoBuffMode Auto')
        gs:monster_hits()
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)

    it('is not used with Auto Majesty off', function()
        local gs = boot_ticking()
        gs:console('gs c toggle AutoMajesty')
        gs:monster_hits()
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)

    it('is used by Auto Buff Mode with Auto Majesty off, once the buff spells are up', function()
        local gs = boot_ticking({buffs = {'Enmity Boost', 'Reprisal', 'Phalanx'}})
        gs:console('gs c toggle AutoMajesty')
        gs:console('gs c set AutoBuffMode Auto')
        gs:monster_hits()
        assert.same({'Majesty'}, actions_of(jobby.until_action(gs)))
    end)
end)

describe('PLD\'s Cover', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c toggle AutoCover')
        gs:traffic()
    end)

    -- Windower's mob distance is squared. The party member, who isn't in the game, is named in the line Cover goes
    -- out in, which GearSwap lets through as it is.
    local function protectee(hpp, distance)
        return {name = 'Pal', hpp = hpp, distance = distance}
    end

    local function cover(...)
        gs.user.check_cover(protectee(...))
        gs.game:settle()
        return jobby.typed(gs)
    end

    it('is used for a party member under 85% HP within 10 yalms', function()
        assert.same({'/ja Cover Pal'}, cover(84, 99))
    end)

    it('is not used for a party member at 85% HP', function()
        assert.same({}, cover(85, 99))
    end)

    it('is not used for a party member 10 yalms away', function()
        assert.same({}, cover(50, 100))
    end)

    it('is not used while it is on recast', function()
        gs.game:start_ability_recast('Cover', 60)
        assert.same({}, cover(50, 25))
    end)

    it('is not used with Auto Cover off', function()
        gs:console('gs c toggle AutoCover')
        assert.same({}, cover(50, 25))
    end)

    it('is not used in the middle of an action', function()
        gs:type('/ja "Provoke" <t>')
        gs:traffic()
        jobby.typed(gs)
        assert.same({}, cover(50, 25))
    end)
end)

-- Nothing in the job file or in Sel calls check_flash; a macro could.
describe('PLD\'s check_flash', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c toggle AutoEmblem')
    end)

    it('casts Flash on the target when it is ready, and says it did', function()
        assert.is_true(gs.user.check_flash())
        gs.game:settle()
        assert.same({'Flash'}, jobby.actions(gs))
    end)

    it('casts nothing while Flash is on recast, and says so', function()
        gs.game:start_spell_recast('Flash', 10)
        assert.is_false(gs.user.check_flash())
        gs.game:settle()
        assert.same({}, jobby.actions(gs))
    end)
end)

describe('PLD\'s tick with Samurai as the sub job', function()
    local function boot_hasso()
        local gs = boot_ticking({sub_job = 'SAM'})
        gs:console('gs c toggle AutoMajesty')
        gs:console('gs c set Weapons Ragnarok')
        gs:engage()
        gs:traffic()
        return gs
    end

    it('uses Hasso engaged with a two-handed weapon', function()
        assert.same({'Hasso'}, actions_of(jobby.until_action(boot_hasso())))
    end)

    it('uses Seigan when the Stance is Seigan', function()
        local gs = boot_hasso()
        gs:console('gs c set Stance Seigan')
        assert.same({'Seigan'}, actions_of(jobby.until_action(gs)))
    end)

    it('uses nothing when the Stance is None', function()
        local gs = boot_hasso()
        gs:console('gs c set Stance None')
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)

    it('uses nothing while Hasso is on recast', function()
        local gs = boot_hasso()
        gs.game:start_ability_recast('Hasso', 30)
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)

    pending('uses nothing with Hasso up: check_hasso in data/PLD.lua looks at state.Buff.Hasso and state.Buff.Seigan, '
        .. 'which PLD\'s job_setup never defines, so Sel never keeps them and only the recast holds Hasso back')

    it('uses nothing with a one-handed weapon', function()
        local gs = boot_hasso()
        gs:console('gs c set Weapons Kheshig')
        gs:traffic()
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)
end)

describe('PLD\'s Auto Tank Mode', function()
    local function tanking()
        local gs = boot_ticking()
        gs:console('gs c toggle AutoMajesty')
        gs:console('gs c toggle AutoTankMode')
        gs:monster_hits()
        return gs
    end

    it('uses Flash on the target in a fight, with Auto Emblem off', function()
        local gs = tanking()
        gs:console('gs c toggle AutoEmblem')
        assert.same({'Flash'}, actions_of(jobby.until_action(gs)))
    end)

    it('starts the Flash with Divine Emblem, with Auto Emblem on', function()
        assert.same({'Divine Emblem'}, actions_of(jobby.until_action(tanking())))
    end)

    it('uses nothing with Auto Tank Mode off', function()
        local gs = tanking()
        gs:console('gs c toggle AutoTankMode')
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)

    it('uses nothing out of a fight', function()
        local gs = boot_ticking()
        gs:console('gs c toggle AutoMajesty')
        gs:console('gs c toggle AutoTankMode')
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)

    it('uses nothing with no monster targeted', function()
        local gs = tanking()
        gs.game.target_index = nil
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)
end)

describe('PLD\'s Auto Buff Mode', function()
    local function buffing(options)
        options = options or {}
        options.buffs = options.buffs or {'Majesty'}
        local gs = boot_ticking(options)
        gs:console('gs c set AutoBuffMode Auto')
        return gs
    end

    it('starts with Crusade', function()
        assert.same({'Crusade'}, actions_of(jobby.until_action(buffing())))
    end)

    it('goes on to Reprisal with Crusade up', function()
        local gs = buffing()
        gs:gain_buff('Enmity Boost')
        assert.same({'Reprisal'}, actions_of(jobby.until_action(gs)))
    end)

    it('goes on to Phalanx with Crusade and Reprisal up', function()
        local gs = buffing({buffs = {'Majesty', 'Enmity Boost', 'Reprisal'}})
        assert.same({'Phalanx'}, actions_of(jobby.until_action(gs)))
    end)

    it('uses nothing once all three are up', function()
        local gs = buffing({buffs = {'Majesty', 'Enmity Boost', 'Reprisal', 'Phalanx'}})
        gs:play(3)
        assert.same({}, actions_of(gs:traffic()))
    end)
end)

describe('PLD\'s buff up', function()
    it('casts the Default list in order, Crusade first', function()
        local gs = boot_ticking()
        gs:console('gs c buffup')
        assert.same({'Crusade'}, actions_of(jobby.until_action(gs)))
    end)

    it('goes on to Haste after Crusade and Reprisal', function()
        local gs = boot_ticking({buffs = {'Enmity Boost', 'Reprisal'}})
        gs:console('gs c buffup')
        assert.same({'Haste'}, actions_of(jobby.until_action(gs)))
    end)
end)

describe('PLD\'s status line', function()
    local function status(setup)
        local gs = boot()
        if setup then
            setup(gs)
        end
        jobby.chat(gs)
        gs:console('gs c update user')
        local lines = jobby.chat(gs)
        return lines[#lines]
    end

    it('says the melee modes and the weapon skill mode', function()
        assert.equal('Melee: Normal, WS: Match', status())
    end)

    it('names the hybrid mode in use', function()
        assert.equal('Melee: Acc/DT, WS: Normal', status(function(gs)
            gs:console('gs c set OffenseMode Acc')
            gs:console('gs c set HybridMode DT')
            gs:console('gs c set WeaponskillMode Normal')
        end))
    end)

    it('names the defense mode and the extra defense mode', function()
        assert.equal('Melee: Normal, WS: Match, Defense: Physical (PDT), Extra: Aegis', status(function(gs)
            gs:console('gs c set DefenseMode Physical')
            gs:console('gs c set ExtraDefenseMode Aegis')
        end))
    end)

    it('says when kiting is on', function()
        assert.equal('Melee: Normal, WS: Match, Kiting', status(function(gs)
            gs:console('gs c toggle Kiting')
        end))
    end)

    it('names the combat form, which a weapon set with an engaged set of its name gives', function()
        assert.equal('Melee (Kheshig): Normal, WS: Match', status(function(gs)
            gs:console('gs c set Weapons Kheshig')
        end))
    end)

    it('names the player targeting mode', function()
        assert.equal('Melee: Normal, WS: Match, Target PC: stal', status(function(gs)
            gs:console('gs c set PCTargetMode stal')
        end))
    end)

    it('says when non-player characters are targeted', function()
        assert.equal('Melee: Normal, WS: Match, Target NPCs', status(function(gs)
            gs:console('gs c toggle SelectNPCTargets')
        end))
    end)

    it('says when Auto Defense Mode is on', function()
        assert.equal('Melee: Normal, WS: Match, Auto Defense: On', status(function(gs)
            gs:console('gs c toggle AutoDefenseMode')
        end))
    end)
end)

describe('PLD\'s buff states', function()
    it('follow the buffs as they come and go', function()
        local gs = boot()
        gs:gain_buff('Sentinel')
        assert.is_true(gs.user.state.Buff.Sentinel)
        gs:lose_buff('Sentinel')
        assert.is_false(gs.user.state.Buff.Sentinel)
    end)

    it('start with Auto Emblem and Auto Majesty on and Auto Cover off', function()
        local gs = boot()
        assert.is_true(gs.user.state.AutoEmblem.value)
        assert.is_true(gs.user.state.AutoMajesty.value)
        assert.is_false(gs.user.state.AutoCover.value)
    end)
end)
