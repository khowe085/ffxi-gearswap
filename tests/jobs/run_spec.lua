local jobby = require('jobby')

local pieces = {'Volte Cap', 'Volte Jupon', 'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Null Masque',
    'Adamantite Armor', "Orunmila's Torque", 'Weike Torque', 'Sortiarius Earring', 'Beatific Earring',
    'Pensee Earring', 'Moonshade Earring', 'Lunette Ring', 'Wanion Belt', 'Prodigious Mantle', 'Epeolatry'}

-- Jobby as a rune fencer with the idle set on. The options are those of a boot (sub_job, tp, buffs) and these
-- besides:
--   engaged    true to engage the monster
--   obi        true for a Hachirin-no-Obi among the pieces
--   hp, mp     the HP and MP of the 1500 and 1000 he has
--   wielding   true for Epeolatry, a two-handed sword, in hand
local function boot(options)
    options = options or {}
    local items = {}
    for _, name in ipairs(pieces) do
        items[#items + 1] = name
    end
    if options.obi then
        items[#items + 1] = 'Hachirin-no-Obi'
    end
    local wearing = {}
    for slot, name in pairs(jobby.idle) do
        wearing[slot] = name
    end
    if options.wielding then
        wearing.main = 'Epeolatry'
    end
    local gs = jobby.boot('RUN', items, {sub_job = options.sub_job or 'NIN', tp = options.tp, buffs = options.buffs,
        wearing = wearing})
    if options.hp then
        gs.game.player.vitals.hp = options.hp
        gs.game.player.vitals.hpp = math.floor(options.hp / 15)
    end
    if options.mp then
        gs.game.player.vitals.mp = options.mp
        gs.game.player.vitals.mpp = math.floor(options.mp / 10)
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

describe('Valiance', function()
    it('goes out as it is with both wards ready', function()
        local gs = boot()
        gs:type('/ja "Valiance" <me>')
        assert.same({'Valiance'}, actions(gs))
    end)

    it('is turned to Vallation while it is on recast and Vallation is ready', function()
        local gs = boot()
        jobby.set_recasts(gs, {abilities = {[113] = 100}})
        gs:type('/ja "Valiance" <me>')
        assert.same({'Vallation'}, actions(gs))
    end)

    it('is refused while it is on recast and Vallation is too', function()
        local gs = boot()
        jobby.set_recasts(gs, {abilities = {[113] = 100, [23] = 100}})
        gs:type('/ja "Valiance" <me>')
        assert.same({}, actions(gs))
        assert.is_true(said(gs, 'Abort: [Valiance] waiting on recast.'))
    end)

    it('is not turned to Vallation with Valiance up', function()
        local gs = boot({buffs = {'Valiance'}})
        jobby.set_recasts(gs, {abilities = {[113] = 100}})
        gs:type('/ja "Valiance" <me>')
        assert.same({}, actions(gs))
    end)

    it('wears sets.precast.JA.Valiance', function()
        local gs = boot()
        gs:type('/ja "Valiance" <me>')
        assert.same(jobby.request(sets_of(gs).precast.JA.Valiance), gs:traffic()[1].equip)
    end)

    it('wears sets.precast.JA.Vallation when turned to Vallation', function()
        local gs = boot()
        jobby.set_recasts(gs, {abilities = {[113] = 100}})
        gs:type('/ja "Valiance" <me>')
        assert.same(jobby.request(sets_of(gs).precast.JA.Vallation), gs:traffic()[1].equip)
    end)
end)

describe('Vivacious Pulse', function()
    local function pulse(element)
        local gs = boot()
        gs:console('gs c set RuneElement ' .. element)
        gs:traffic()
        gs:type('/ja "Vivacious Pulse" <me>')
        return gs, gs:traffic()[1].equip
    end

    for _, element in ipairs({'Ignis', 'Lux', 'Tenebrae'}) do
        it(('wears sets.precast.JA["Vivacious Pulse"].%s with the rune element %s'):format(element, element), function()
            local gs, equip = pulse(element)
            assert.same(jobby.request(sets_of(gs).precast.JA['Vivacious Pulse'][element]), equip)
        end)
    end
end)

describe('a rune', function()
    it('wears sets.precast.JA for the rune', function()
        local gs = boot()
        gs:type('/ja "Ignis" <me>')
        assert.same({jobby.request(sets_of(gs).precast.JA.Ignis), 'Ignis'},
            {gs:traffic()[1].equip, 'Ignis'})
    end)
end)

describe('an effusion', function()
    it('wears sets.precast.Effusion with sets.element for its element: Lunge', function()
        local gs = boot({engaged = true})
        gs:type('/ja "Lunge" <t>')
        assert.same(jobby.request(sets_of(gs).precast.Effusion, sets_of(gs).element.Light), gs:traffic()[1].equip)
    end)

    it('wears them for Swipe too', function()
        local gs = boot({engaged = true})
        gs:type('/ja "Swipe" <t>')
        assert.same(jobby.request(sets_of(gs).precast.Effusion, sets_of(gs).element.Light), gs:traffic()[1].equip)
    end)

    it('wears them with the Hachirin-no-Obi when a rune of the weather\'s element is up', function()
        local gs = boot({engaged = true, obi = true, buffs = {'Lux'}})
        jobby.set_world(gs, {weather = 16})
        gs:type('/ja "Lunge" <t>')
        assert.same(jobby.request(sets_of(gs).precast.Effusion, sets_of(gs).element.Light, {waist = 'Hachirin-no-Obi'}),
            gs:traffic()[1].equip)
    end)

    it('wears them with the Hachirin-no-Obi when a rune of the day\'s element is up', function()
        local gs = boot({engaged = true, obi = true, buffs = {'Lux'}})
        jobby.set_world(gs, {day = 6})
        gs:type('/ja "Lunge" <t>')
        assert.equal('Hachirin-no-Obi', jobby.layer(gs:worn()).waist)
    end)

    it('wears them without the Hachirin-no-Obi when no rune matches', function()
        local gs = boot({engaged = true, obi = true, buffs = {'Gelus'}})
        jobby.set_world(gs, {weather = 16})
        gs:type('/ja "Lunge" <t>')
        assert.same(jobby.request(sets_of(gs).precast.Effusion, sets_of(gs).element.Light), gs:traffic()[1].equip)
    end)

    it('wears them without the Hachirin-no-Obi when there is none among the gear', function()
        local gs = boot({engaged = true, buffs = {'Lux'}})
        jobby.set_world(gs, {weather = 16})
        gs:type('/ja "Lunge" <t>')
        assert.same(jobby.request(sets_of(gs).precast.Effusion, sets_of(gs).element.Light), gs:traffic()[1].equip)
    end)

    it('wears sets.precast.Effusion alone for an effusion that is no Lunge or Swipe: Gambit', function()
        local gs = boot({engaged = true})
        gs:type('/ja "Gambit" <t>')
        assert.same(jobby.request(sets_of(gs).precast.Effusion), gs:traffic()[1].equip)
    end)

    it('is turned to Swipe while Lunge is on recast and Swipe is ready', function()
        local gs = boot({engaged = true})
        jobby.set_recasts(gs, {abilities = {[25] = 60}})
        gs:type('/ja "Lunge" <t>')
        assert.same({'Swipe'}, actions(gs))
    end)

    it('is refused while Lunge and Swipe are on recast', function()
        local gs = boot({engaged = true})
        jobby.set_recasts(gs, {abilities = {[25] = 60, [241] = 60}})
        gs:type('/ja "Lunge" <t>')
        assert.same({}, actions(gs))
    end)

    it('engages the monster first from idle, as Sel\'s idle step does, and ends the engagement a second later', function()
        local gs = boot()
        gs:type('/ja "Lunge" <t>')
        assert.same({'category 2', 'Lunge'}, actions(gs))
        gs:advance(1.1)
        assert.same({'/attack off'}, gs.game.typed)
    end)
end)

describe('a spell cast under a ward', function()
    it('wears sets.precast.FC.Inspiration over the fast cast set under Valiance', function()
        local gs = boot({buffs = {'Valiance'}})
        gs:type('/ma "Flash" <t>')
        assert.same(jobby.request(sets_of(gs).precast.FC, sets_of(gs).precast.FC.Inspiration), gs:traffic()[1].equip)
    end)

    it('wears sets.precast.FC.Inspiration over the fast cast set under Vallation', function()
        local gs = boot({buffs = {'Vallation'}})
        gs:type('/ma "Flash" <t>')
        assert.same(jobby.request(sets_of(gs).precast.FC, sets_of(gs).precast.FC.Inspiration), gs:traffic()[1].equip)
    end)

    it('wears the fast cast set alone with no ward up', function()
        local gs = boot()
        gs:type('/ma "Flash" <t>')
        assert.same(jobby.request(sets_of(gs).precast.FC), gs:traffic()[1].equip)
    end)
end)

describe('Embolden', function()
    it('puts sets.buff.Embolden on when it comes', function()
        local gs = boot()
        gs:gain_buff('Embolden')
        assert.equal("Orunmila's Torque", gs:worn().neck)
    end)

    it('holds its slots against the sets of what is cast, while it is up', function()
        local gs = boot()
        gs:gain_buff('Embolden')
        gs:type('/ma "Flash" <t>')
        assert.equal("Orunmila's Torque", gs:worn().neck)
    end)

    it('lets those slots change again once it is gone', function()
        local gs = boot()
        gs:gain_buff('Embolden')
        gs:lose_buff('Embolden')
        gs:type('/ma "Flash" <t>')
        assert.equal('Weike Torque', gs:worn().neck)
    end)

    it('lets those slots change when Embolden was never up', function()
        local gs = boot()
        gs:type('/ma "Flash" <t>')
        assert.equal('Weike Torque', gs:worn().neck)
    end)
end)

describe('the engaged set of a rune fencer', function()
    it('wears sets.buff.Battuta over it under Battuta', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Battuta')
        assert.same(engaged_worn(gs, sets_of(gs).buff.Battuta), gs:worn())
    end)

    it('wears no Battuta set without it', function()
        local gs = boot({engaged = true})
        assert.same(engaged_worn(gs), gs:worn())
    end)

    it('is sets.engaged.MP while the extra defense mode is MP', function()
        local gs = boot({engaged = true})
        gs:console('gs c set ExtraDefenseMode MP')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).engaged.MP)), gs:worn())
    end)

    it('is sets.engaged again when the extra defense mode goes back to None', function()
        local gs = boot({engaged = true})
        gs:console('gs c set ExtraDefenseMode MP')
        gs:console('gs c set ExtraDefenseMode None')
        assert.same(engaged_worn(gs), gs:worn())
    end)

    it('is sets.engaged under a defense mode with the defense set over it, Battuta ahead of the defense set', function()
        local gs = boot({engaged = true})
        gs:gain_buff('Battuta')
        gs:console('gs c set DefenseMode Physical')
        assert.same(engaged_worn(gs, sets_of(gs).buff.Battuta, sets_of(gs).defense.PDT), gs:worn())
    end)

    it('wears sets.MP over the defense set under a defense mode in the MP extra defense mode', function()
        local gs = boot({engaged = true})
        gs:console('gs c set ExtraDefenseMode MP')
        gs:console('gs c set DefenseMode Physical')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).engaged.MP, sets_of(gs).defense.PDT, sets_of(gs).MP)),
            gs:worn())
    end)
end)

describe('the idle set of a rune fencer', function()
    local function low_mp(gs)
        gs.game.player.vitals.mpp = 40
        gs.game.player.vitals.mp = 400
        gs:console('gs c update')
    end

    it('wears sets.latent_refresh under half MP', function()
        local gs = boot()
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).latent_refresh)), gs:worn())
    end)

    it('wears sets.latent_refresh_grip too with a two-handed weapon in the idle set and the weapons free', function()
        local gs = boot()
        sets_of(gs).idle.main = 'Epeolatry'
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).latent_refresh, sets_of(gs).latent_refresh_grip,
            {main = 'Epeolatry'})), gs:worn())
    end)

    it('wears no sets.latent_refresh in the DT idle mode', function()
        local gs = boot()
        gs:console('gs c set IdleMode DT')
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.DT)), gs:worn())
    end)

    it('wears no sets.latent_refresh above half MP', function()
        local gs = boot()
        assert.same(jobby.worn_by({}), gs:worn())
    end)
end)

describe('the stance of a rune fencer', function()
    it('is Hasso with the sub job Samurai', function()
        local gs = boot({sub_job = 'SAM'})
        assert.equal('Hasso', gs.user.state.Stance.value)
    end)

    it('is put to None by an update with another sub job', function()
        local gs = boot({sub_job = 'NIN'})
        assert.equal('None', gs.user.state.Stance.value)
    end)

    it('stays what it is under an update with the sub job Samurai', function()
        local gs = boot({sub_job = 'SAM'})
        gs:console('gs c set Stance Seigan')
        gs:console('gs c update')
        assert.equal('Seigan', gs.user.state.Stance.value)
    end)
end)

describe('a weapon skill by a rune fencer at the TP cap', function()
    local function engaged(tp)
        local gs = boot({tp = tp, engaged = true})
        gs:traffic()
        return gs
    end

    it('trades the Moonshade Earring for sets.MaxTP', function()
        local gs = engaged(3000)
        gs:type('/ws "Resolution" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS.Resolution, sets_of(gs).MaxTP), gs:worn())
    end)

    it('trades it for sets.AccMaxTP in the Acc offense mode', function()
        local gs = engaged(3000)
        gs:console('gs c set OffenseMode Acc')
        gs:traffic()
        gs:type('/ws "Resolution" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS.Resolution, sets_of(gs).AccMaxTP), gs:worn())
    end)

    it('keeps the Moonshade Earring under the cap', function()
        local gs = engaged(2900)
        gs:type('/ws "Resolution" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS.Resolution), gs:worn())
    end)
end)

describe('a weapon skill under AutoBuffMode with the sub job Samurai', function()
    local function buffer(tp)
        local gs = boot({sub_job = 'SAM', tp = tp, engaged = true})
        gs:console('gs c set AutoBuffMode Auto')
        return gs
    end

    it('is held back for Sekkanoki over 1850 TP', function()
        local gs = buffer(1900)
        gs:type('/ws "Resolution" <t>')
        assert.same({'Sekkanoki'}, actions(gs))
    end)

    it('is held back for Meditate at 1850 TP or less', function()
        local gs = buffer(1850)
        gs:type('/ws "Resolution" <t>')
        assert.same({'Meditate'}, actions(gs))
    end)

    it('goes out when neither is ready', function()
        local gs = buffer(1900)
        jobby.set_recasts(gs, {abilities = {[140] = 30, [134] = 30}})
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, actions(gs))
    end)

    it('goes out with an SJ Restriction', function()
        local gs = boot({sub_job = 'SAM', tp = 1900, engaged = true, buffs = {'SJ Restriction'}})
        gs:console('gs c set AutoBuffMode Auto')
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, actions(gs))
    end)

    it('goes out with AutoBuffMode off', function()
        local gs = boot({sub_job = 'SAM', tp = 1900, engaged = true})
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, actions(gs))
    end)

    it('goes out with another sub job', function()
        local gs = boot({sub_job = 'NIN', tp = 1900, engaged = true})
        gs:console('gs c set AutoBuffMode Auto')
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, actions(gs))
    end)
end)

describe('the tick of a rune fencer', function()
    describe('with a sub job Samurai, two-handed, engaged', function()
        local function stance(name, options)
            options = options or {}
            options.sub_job = 'SAM'
            options.wielding = true
            options.engaged = true
            local gs = boot(options)
            gs:console('gs c set Stance ' .. name)
            return gs
        end

        it('takes Hasso up when the stance is Hasso', function()
            local gs = stance('Hasso')
            assert.same({'Hasso'}, first_actions(gs))
        end)

        it('takes Seigan up when the stance is Seigan', function()
            local gs = stance('Seigan')
            assert.same({'Seigan'}, first_actions(gs))
        end)

        it('takes none up when the stance is None', function()
            local gs = stance('None')
            assert.same({}, first_actions(gs))
        end)

        it('takes none up with Hasso up', function()
            local gs = stance('Hasso', {buffs = {'Hasso'}})
            assert.same({}, first_actions(gs))
        end)

        it('takes none up with Seigan up', function()
            local gs = stance('Hasso', {buffs = {'Seigan'}})
            assert.same({}, first_actions(gs))
        end)

        it('takes none up while it is on recast', function()
            local gs = stance('Hasso')
            jobby.set_recasts(gs, {abilities = {[138] = 30}})
            assert.same({}, first_actions(gs))
        end)

        it('takes none up with an SJ Restriction', function()
            local gs = stance('Hasso', {buffs = {'SJ Restriction'}})
            assert.same({}, first_actions(gs))
        end)

        it('takes none up with amnesia', function()
            local gs = stance('Hasso', {buffs = {'amnesia'}})
            assert.same({}, first_actions(gs))
        end)
    end)

    it('takes none up with a one-handed weapon', function()
        local gs = boot({sub_job = 'SAM', engaged = true})
        gs:console('gs c set Stance Hasso')
        assert.same({}, first_actions(gs))
    end)

    it('takes none up when not engaged', function()
        local gs = boot({sub_job = 'SAM', wielding = true})
        gs:console('gs c set Stance Hasso')
        assert.same({}, first_actions(gs))
    end)

    describe('under AutoBuffMode', function()
        local function buffer(options)
            options = options or {}
            local gs = boot(options)
            gs:console('gs c set AutoBuffMode Auto')
            return gs
        end

        it('casts Phalanx first, for its list asks for it always', function()
            local gs = buffer()
            assert.same({'Phalanx'}, first_actions(gs))
        end)

        it('casts Refresh when idle once Phalanx is up', function()
            local gs = buffer({buffs = {'Phalanx'}})
            assert.same({'Refresh'}, first_actions(gs))
        end)

        it('casts Temper when engaged once those are up', function()
            local gs = buffer({buffs = {'Phalanx', 'Refresh'}, engaged = true})
            assert.same({'Temper'}, first_actions(gs))
        end)

        it('casts Crusade in combat ahead of the others', function()
            local gs = buffer({buffs = {'Phalanx', 'Refresh'}})
            gs.user.in_combat = true
            assert.same({'Crusade'}, first_actions(gs))
        end)

        it('casts nothing with all of them up', function()
            local gs = buffer({buffs = {'Phalanx', 'Refresh', 'Enmity Boost', 'Multi Strikes'}, engaged = true})
            gs.user.in_combat = true
            assert.same({}, first_actions(gs))
        end)
    end)

    describe('with AutoTankMode on, in combat', function()
        local function tank(options)
            options = options or {}
            local gs = boot(options)
            gs:console('gs c toggle AutoTankMode')
            gs.user.in_combat = true
            return gs
        end

        it('casts Flash on the monster, the first of the enmity spells a rune fencer has', function()
            local gs = tank()
            assert.same({'Flash'}, first_actions(gs))
        end)

        it('goes on to Foil while Flash is on recast', function()
            local gs = tank()
            jobby.set_recasts(gs, {spells = {[112] = 6000}})
            assert.same({'Foil'}, first_actions(gs))
        end)

        it('casts nothing out of combat', function()
            local gs = tank()
            gs.user.in_combat = false
            assert.same({}, first_actions(gs))
        end)

        it('casts nothing with no monster targeted', function()
            local gs = tank()
            gs.game.target_index = nil
            assert.same({}, first_actions(gs))
        end)
    end)
end)

describe('AutoRuneMode', function()
    local function runer(mode, options)
        options = options or {}
        local gs = boot(options)
        gs:console('gs c set AutoRuneMode ' .. mode)
        return gs
    end

    it('takes the rune of the rune element up when there are none: Ignis', function()
        local gs = runer('Runes')
        assert.same({'Ignis'}, first_actions(gs))
    end)

    it('takes the rune of the element chosen', function()
        local gs = runer('Runes')
        gs:console('gs c set RuneElement Lux')
        assert.same({'Lux'}, first_actions(gs))
    end)

    it('takes runes up until there are three', function()
        local gs = runer('Runes', {buffs = {'Ignis', 'Ignis'}})
        assert.same({'Ignis'}, first_actions(gs))
    end)

    it('takes no more with three up', function()
        local gs = runer('Runes', {buffs = {'Ignis', 'Ignis', 'Ignis'}})
        assert.same({}, first_actions(gs))
    end)

    it('takes none while the runes are on recast', function()
        local gs = runer('Runes')
        jobby.set_recasts(gs, {abilities = {[10] = 30}})
        assert.same({}, first_actions(gs))
    end)

    it('takes none with the mode off', function()
        local gs = runer('Off')
        assert.same({}, first_actions(gs))
    end)

    describe('in the Full mode with three runes up', function()
        local function full(options)
            options = options or {}
            options.buffs = options.buffs or {}
            for _ = 1, 3 do
                options.buffs[#options.buffs + 1] = 'Ignis'
            end
            return runer('Full', options)
        end

        it('uses Vivacious Pulse under half HP', function()
            local gs = full({hp = 600})
            assert.same({'Vivacious Pulse'}, first_actions(gs))
        end)

        it('uses Vivacious Pulse under 75% MP with Tenebrae the element', function()
            local gs = runer('Full', {mp = 700, buffs = {'Tenebrae', 'Tenebrae', 'Tenebrae'}})
            gs:console('gs c set RuneElement Tenebrae')
            assert.same({'Vivacious Pulse'}, first_actions(gs))
        end)

        it('uses nothing out of combat when the pulse is not needed', function()
            local gs = full()
            assert.same({}, first_actions(gs))
        end)

        it('uses Pflug in combat', function()
            local gs = full()
            gs.user.in_combat = true
            assert.same({'Pflug'}, first_actions(gs))
        end)

        it('uses Valiance in combat once Pflug is up', function()
            local gs = full({buffs = {'Pflug'}})
            gs.user.in_combat = true
            assert.same({'Valiance'}, first_actions(gs))
        end)

        it('uses Vallation in combat while Valiance is on recast', function()
            local gs = full({buffs = {'Pflug'}})
            gs.user.in_combat = true
            jobby.set_recasts(gs, {abilities = {[113] = 100}})
            assert.same({'Vallation'}, first_actions(gs))
        end)

        it('uses neither with a ward up', function()
            local gs = full({buffs = {'Pflug', 'Vallation'}})
            gs.user.in_combat = true
            assert.same({}, first_actions(gs))
        end)
    end)
end)
