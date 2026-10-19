local jobby = require('jobby')

local pieces = {'Volte Cap', 'Volte Jupon', 'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Null Masque',
    'Adamantite Armor', "Orunmila's Torque", 'Weike Torque', 'Choleric Earring', 'Lunette Ring', 'Pernicious Ring',
    'Gelatinous Ring', 'Wanion Belt', 'Daybreak', "Bunzi's Rod", 'Vertigo Ring', 'Dhanurveda Ring', 'Petrov Ring',
    'Gozuki Mezuki'}

-- Jobby as a geomancer with the idle set on. The options are those of a boot (sub_job, tp, buffs) and these besides:
--   mp       the MP of the 1000 he has
--   luopan   true for a luopan out
--   friend   true for a party member, Friend, and stranger for another player near him, Stranger, not in the party
local function boot(options)
    options = options or {}
    local gs = jobby.boot('GEO', pieces, {sub_job = options.sub_job or 'WHM', tp = options.tp, buffs = options.buffs})
    if options.mp then
        gs.game.player.vitals.mp = options.mp
        gs.game.player.vitals.mpp = math.floor(options.mp / 10)
    end
    if options.friend then
        gs.game:add_party_member({name = 'Friend'})
    end
    if options.stranger then
        gs.game:add_party_member({name = 'Stranger', in_party = false})
    end
    gs:console('gs c update')
    if options.luopan then
        gs:give_pet({name = 'Luopan', distance = options.luopan_distance})
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

local function ran(gs, start)
    local commands = {}
    for _, command in ipairs(gs.game.commands) do
        if command:sub(1, #start) == start then
            commands[#commands + 1] = command
        end
    end
    return commands
end

local function actions(gs)
    local sent = {}
    for _, entry in ipairs(gs:traffic()) do
        if entry.action then
            sent[#sent + 1] = entry.action .. ' ' .. entry.target
        end
    end
    return sent
end

-- The actions the tick sent in its first moments (it starts five seconds after the file loads).
local function first_actions(gs)
    gs:play(5.3)
    return actions(gs)
end

-- What the tick typed that reached the game untouched, in its first moments: Blaze of Glory and Ecliptic Attrition
-- are typed with a semicolon after the target, which GearSwap doesn't take for one.
local function first_typed(gs)
    gs:play(5.3)
    local typed = {}
    for _, line in ipairs(gs.game.typed) do
        if line ~= '/lockstyle on' then
            typed[#typed + 1] = line
        end
    end
    return typed
end

local function fast_cast(gs, ...)
    return jobby.worn_by(jobby.layer(sets_of(gs).precast.FC, ...))
end

describe('an indicolure spell', function()
    it('is cast on the caster when aimed at the monster targeted', function()
        local gs = boot()
        gs:type('/ma "Indi-Torpor" <t>')
        assert.same({'Indi-Torpor Jobby'}, actions(gs))
    end)

    it('is cast on the caster when aimed at him', function()
        local gs = boot()
        gs:type('/ma "Indi-Torpor" <me>')
        assert.same({'Indi-Torpor Jobby'}, actions(gs))
    end)

    it('is refused on himself while Entrust is up, with a word of it', function()
        local gs = boot({buffs = {'Entrust'}})
        gs:type('/ma "Indi-Torpor" <me>')
        assert.same({}, actions(gs))
        assert.is_true(said(gs, "Entrust active - You can't entrust yourself."))
    end)

    it('wears the fast cast set, then sets.midcast.Geomancy.Indi', function()
        local gs = boot()
        gs:type('/ma "Indi-Torpor" <me>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.Geomancy.Indi), gs:worn())
    end)
end)

describe('an indicolure spell on a party member', function()
    it('is cast on him as it is typed while Entrust is up, with sets.buff.Entrust over the spell\'s set', function()
        local gs = boot({friend = true, buffs = {'Entrust'}})
        gs:type('/ma "Indi-Fury" Friend')
        assert.same({'Indi-Fury Friend'}, actions(gs))
        assert.same(fast_cast(gs, sets_of(gs).midcast.Geomancy.Indi, sets_of(gs).buff.Entrust), gs:worn())
    end)

    it('is cast as typed without Entrust, wearing no Entrust set, when the AutoEntrust state is off', function()
        local gs = boot({friend = true})
        gs:type('/ma "Indi-Fury" Friend')
        assert.same({'Indi-Fury Friend'}, actions(gs))
        assert.same(fast_cast(gs, sets_of(gs).midcast.Geomancy.Indi), gs:worn())
    end)

    describe('with the AutoEntrust state on', function()
        local function auto_entrust(options)
            options = options or {}
            options.friend = true
            local gs = boot(options)
            gs:console('gs c toggle AutoEntrust')
            return gs
        end

        it('is held back for Entrust, which goes out, and is typed again once Entrust is up', function()
            local gs = auto_entrust()
            gs:type('/ma "Indi-Fury" Friend')
            assert.same({'Entrust Jobby'}, actions(gs))
            gs:advance(1.2)
            local commands = ran(gs, 'input')
            assert.same({'input /ja "Entrust" <me>', 'input /ma "Indi-Fury" Friend'}, {commands[1], commands[2]})
            gs:gain_buff('Entrust')
            gs:traffic()
            gs:type('/ma "Indi-Fury" Friend')
            assert.same({'Indi-Fury Friend'}, actions(gs))
        end)

        it('is refused while Entrust is on recast, saying so', function()
            local gs = auto_entrust()
            jobby.set_recasts(gs, {abilities = {[93] = 60}})
            gs:type('/ma "Indi-Fury" Friend')
            assert.same({}, actions(gs))
            assert.is_true(said(gs, 'Abort: [Entrust] waiting on recast. (0:01:00)'))
        end)

        it('is refused while the spell is on recast, saying so', function()
            local gs = auto_entrust()
            jobby.set_recasts(gs, {spells = {[779] = 600}})
            gs:type('/ma "Indi-Fury" Friend')
            assert.same({}, actions(gs))
            assert.is_true(said(gs, 'Abort: [Indi-Fury] waiting on recast. (0:00:10)'))
        end)

        it('is cast on the caster, as it is for a spell aimed at himself, when no party member is aimed at', function()
            local gs = auto_entrust()
            gs:type('/ma "Indi-Fury" <t>')
            assert.same({'Indi-Fury Jobby'}, actions(gs))
        end)
    end)

    it('is cast by gs c geo indi on the target named, while Entrust is up', function()
        local gs = boot({friend = true, buffs = {'Entrust'}})
        gs:console('gs c geo indi Friend')
        assert.same({'Indi-Torpor Friend'}, actions(gs))
    end)
end)

describe('a Geo spell aimed at another player', function()
    it('is cast on the party member it is aimed at, a helpful spell', function()
        local gs = boot({friend = true})
        gs:type('/ma "Geo-Fury" Friend')
        assert.same({'Geo-Fury Friend'}, actions(gs))
    end)

    it('is cast on the caster instead when the player is not in the party', function()
        local gs = boot({stranger = true})
        gs:type('/ma "Geo-Fury" Stranger')
        assert.same({'Geo-Fury Jobby'}, actions(gs))
    end)

    it('is cancelled when it is for an enemy and aimed at a party member', function()
        local gs = boot({friend = true})
        gs:type('/ma "Geo-Frailty" Friend')
        assert.same({}, actions(gs))
    end)
end)

describe('a Geo spell', function()
    it('is cast at the enemy it is aimed at', function()
        local gs = boot()
        gs:type('/ma "Geo-Frailty" <bt>')
        assert.same({'Geo-Frailty Apex Toad'}, actions(gs))
    end)

    it('is cast on the caster when it is a helpful one aimed at the monster targeted', function()
        local gs = boot()
        gs:type('/ma "Geo-Fury" <t>')
        assert.same({'Geo-Fury Jobby'}, actions(gs))
    end)

    it('wears the fast cast set, then sets.midcast.Geomancy', function()
        local gs = boot()
        gs:type('/ma "Geo-Frailty" <bt>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.Geomancy), gs:worn())
    end)

    it('leaves its gear on afterwards, as the job file handles the aftercast', function()
        local gs = boot()
        gs:type('/ma "Geo-Frailty" <bt>')
        gs:finish_action()
        assert.same(fast_cast(gs, sets_of(gs).midcast.Geomancy), gs:worn())
    end)

    it('is held back for Full Circle while a luopan is out, and cast a second and a bit later', function()
        local gs = boot({luopan = true})
        gs:type('/ma "Geo-Frailty" <bt>')
        assert.same({'Full Circle Jobby'}, actions(gs))
        gs:take_pet()
        gs:advance(3)
        assert.same({'Geo-Frailty Apex Toad'}, actions(gs))
    end)

    it('is cast at once with no luopan out', function()
        local gs = boot()
        gs:type('/ma "Geo-Torpor" <bt>')
        assert.same({'Geo-Torpor Apex Toad'}, actions(gs))
    end)
end)

describe('the weapons of a geomancer casting Geomancy', function()
    local function indi_with_staff(mode, tp)
        local gs = boot({tp = tp})
        gs:console('gs c set Weapons Staff')
        gs:console('gs c set UnlockGeomancy ' .. mode)
        gs:traffic()
        gs:type('/ma "Indi-Torpor" <me>')
        return gs
    end

    it('are freed for the spell\'s set in the Always mode, and back in hand once it is done', function()
        local gs = indi_with_staff('Always', 0)
        assert.equal('Daybreak', gs:worn().main)
        gs:finish_action()
        assert.equal("Bunzi's Rod", gs:worn().main)
    end)

    it('stay locked in the Never mode', function()
        local gs = indi_with_staff('Never', 0)
        assert.equal("Bunzi's Rod", gs:worn().main)
    end)

    it('are freed in a TP mode with less TP than it names', function()
        local gs = indi_with_staff('500', 300)
        assert.equal('Daybreak', gs:worn().main)
    end)

    it('stay locked in a TP mode with more TP than it names', function()
        local gs = indi_with_staff('500', 800)
        assert.equal("Bunzi's Rod", gs:worn().main)
    end)
end)

describe('a Geo spell cast under Blaze of Glory', function()
    it('keeps the Blaze of Glory set on through the gear changes after it', function()
        local gs = boot({buffs = {'Blaze of Glory'}})
        gs:type('/ma "Geo-Frailty" <bt>')
        gs:finish_action()
        gs:console('gs c update')
        assert.equal('Volte Bracers', gs:worn().hands)
    end)

    it('keeps no gear on without the buff', function()
        local gs = boot()
        gs:type('/ma "Geo-Frailty" <bt>')
        gs:finish_action()
        gs:console('gs c update')
        assert.equal('Nyame Gauntlets', gs:worn().hands)
    end)

    it('frees the gear again when the luopan is gone', function()
        local gs = boot({buffs = {'Blaze of Glory'}})
        gs:type('/ma "Geo-Frailty" <bt>')
        gs:finish_action()
        gs:give_pet({name = 'Luopan'})
        gs:take_pet()
        gs:console('gs c update')
        assert.equal('Nyame Gauntlets', gs:worn().hands)
    end)

    it('is not the case for an Indi spell', function()
        local gs = boot({buffs = {'Blaze of Glory'}})
        gs:type('/ma "Indi-Torpor" <me>')
        gs:finish_action()
        gs:console('gs c update')
        assert.equal('Nyame Gauntlets', gs:worn().hands)
    end)
end)

describe('Blaze of Glory and Ecliptic Attrition under Bolster', function()
    it('are refused, with a word that Bolster maxes the bubbles', function()
        local gs = boot({buffs = {'Bolster'}})
        gs:type('/ja "Blaze of Glory" <me>')
        assert.same({}, actions(gs))
        assert.is_true(said(gs, 'Abort: Bolster maxes the strength of bubbles.'))
        gs:advance(3)
        gs:type('/ja "Ecliptic Attrition" <me>')
        assert.same({}, actions(gs))
    end)

    it('are used without it', function()
        local gs = boot()
        gs:type('/ja "Blaze of Glory" <me>')
        assert.same({'Blaze of Glory Jobby'}, actions(gs))
    end)
end)

describe('the indicolure out', function()
    local function indi_out(options)
        local gs = boot(options)
        gs:set_indi({element = 1, size = 1})
        gs:gain_buff('Colure Active')
        return gs
    end

    it('puts the Indi group on the idle set when the buff comes', function()
        local gs = indi_out()
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Indi)), gs:worn())
    end)

    it('takes the group off again when it ends', function()
        local gs = indi_out()
        gs:set_indi()
        gs:lose_buff('Colure Active')
        assert.same(jobby.worn_by({}), gs:worn())
    end)

    it('puts the Indi group on the DT idle set in the DT idle mode', function()
        local gs = indi_out()
        gs:console('gs c set IdleMode DT')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.DT.Indi)), gs:worn())
    end)

    it('is the group after gs c update too', function()
        local gs = boot()
        gs:set_indi({element = 2, size = 2, enemy = true})
        gs:console('gs c update')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Indi)), gs:worn())
    end)

    it('is the group while the indicolure spell is cast, and after it', function()
        local gs = boot()
        gs:type('/ma "Indi-Torpor" <me>')
        gs:set_indi({element = 1, size = 1})
        gs:finish_action()
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Indi, {main = 'Daybreak'})), gs:worn())
    end)

    it('is no group after an indicolure spell that leaves none out', function()
        local gs = boot()
        gs:type('/ma "Indi-Torpor" <me>')
        gs:finish_action()
        assert.equal(0, #gs.user.classes.CustomIdleGroups)
    end)

    it('is remembered by name when cast on the caster', function()
        local gs = boot()
        gs:type('/ma "Indi-Fury" <me>')
        gs:finish_action()
        assert.equal('Fury', gs.user.last_indi)
    end)

    it('starts a timer, ending the one before it', function()
        local gs = boot()
        gs:type('/ma "Indi-Torpor" <me>')
        gs:set_indi({element = 1, size = 1})
        gs:finish_action()
        assert.same({'timers d "Jobby: "', 'timers c "Jobby: Indi-Torpor" 180 down spells/00136.png'}, ran(gs, 'timers'))
    end)

    it('starts no timer with the custom timers state off', function()
        local gs = boot()
        gs:console('gs c toggle UseCustomTimers')
        gs:type('/ma "Indi-Torpor" <me>')
        gs:finish_action()
        assert.same({}, ran(gs, 'timers'))
    end)
end)

describe('the luopan', function()
    it('is remembered by name when a Geo spell is done', function()
        local gs = boot()
        gs:type('/ma "Geo-Frailty" <bt>')
        gs:finish_action()
        assert.equal('Frailty', gs.user.last_geo)
    end)

    it('lets Ecliptic Attrition be used again when it is gone', function()
        local gs = boot({luopan = true})
        gs.user.used_ecliptic = true
        gs:take_pet()
        assert.is_false(gs.user.used_ecliptic)
    end)
end)

describe('a cure by a geomancer', function()
    local function cure(gs)
        gs:type('/ma "Cure III" <me>')
        return gs:worn()
    end

    it('wears sets.midcast.Cure', function()
        local gs = boot()
        assert.same(fast_cast(gs, sets_of(gs).midcast.Cure), cure(gs))
    end)

    it('wears sets.midcast.LightWeatherCure in light weather', function()
        local gs = boot()
        jobby.set_world(gs, {weather = 16})
        assert.same(fast_cast(gs, sets_of(gs).midcast.LightWeatherCure), cure(gs))
    end)

    it('wears sets.midcast.LightDayCure on a Lightsday', function()
        local gs = boot()
        jobby.set_world(gs, {day = 6})
        assert.same(fast_cast(gs, sets_of(gs).midcast.LightDayCure), cure(gs))
    end)
end)

describe('the obi entries a geomancer\'s precast fills', function()
    local function default_after(line)
        local gs = boot()
        gs:type(line)
        return gs.user.gear.default
    end

    it('are the cure ones for a cure', function()
        local default = default_after('/ma "Cure III" <me>')
        assert.equal('Prodigious Mantle', default.obi_back)
        assert.equal('Wanion Belt', default.obi_waist)
    end)

    it('are the low nuke ones for a low tier nuke', function()
        assert.equal('Plat. Mog. Belt', default_after('/ma "Stone" <t>').obi_waist)
    end)

    it('are the high nuke ones for a high tier nuke', function()
        assert.equal('Hachirin-no-Obi', default_after('/ma "Fire III" <t>').obi_waist)
    end)

    it('are left as they were for a Geomancy spell', function()
        assert.is_nil(default_after('/ma "Indi-Torpor" <me>').obi_waist)
    end)
end)

describe('the set of a geomancer\'s nuke', function()
    it('is sets.midcast.LowTierNuke for a low tier nuke', function()
        local gs = boot()
        gs:type('/ma "Stone" <t>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.LowTierNuke), gs:worn())
    end)

    it('is sets.midcast.HighTierNuke for a high tier nuke', function()
        local gs = boot()
        gs:type('/ma "Fire III" <t>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.HighTierNuke), gs:worn())
    end)

    it('is sets.midcast["Elemental Magic"] in an Occult casting mode, with no tier', function()
        local gs = boot()
        gs:console('gs c set CastingMode OccultAcumen')
        gs:traffic()
        gs:type('/ma "Stone" <t>')
        assert.same(fast_cast(gs, sets_of(gs).midcast['Elemental Magic']), gs:worn())
    end)

    it('wears sets.precast.FC.Proc ahead of a spell in the Proc casting mode', function()
        local gs = boot()
        gs:console('gs c set CastingMode Proc')
        gs:traffic()
        gs:type('/ma "Stone" <t>')
        assert.same(jobby.request(sets_of(gs).precast.FC.Proc), gs:traffic()[1].equip)
    end)
end)

describe('the idle set of a geomancer', function()
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

    it('wears no sets.latent_refresh in the DT idle mode', function()
        local gs = boot()
        gs:console('gs c set IdleMode DT')
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.DT)), gs:worn())
    end)

    it('wears sets.latent_refresh_grip too with a staff in the idle set and the weapons free', function()
        local gs = boot()
        sets_of(gs).idle.main = 'Gozuki Mezuki'
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).latent_refresh, sets_of(gs).latent_refresh_grip,
            {main = 'Gozuki Mezuki'})), gs:worn())
    end)

    it('wears sets.buff.Sublimation while Sublimation is charging', function()
        local gs = boot({buffs = {'Sublimation: Activated'}})
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).buff.Sublimation)), gs:worn())
    end)

    it('wears sets.buff.DTSublimation in the DT idle mode while it is', function()
        local gs = boot({buffs = {'Sublimation: Activated'}})
        gs:console('gs c set IdleMode DT')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.DT, sets_of(gs).buff.DTSublimation)), gs:worn())
    end)
end)

describe('gs c geo', function()
    local function geo(gs, command)
        gs:console('gs c ' .. command)
        return actions(gs)
    end

    it('says the subcommands when it is given none', function()
        local gs = boot()
        assert.same({}, geo(gs, 'geo'))
        assert.is_true(said(gs, 'The geo subcommands are: Geo, Indi, Entrust'))
    end)

    it('casts the automatic Geo spell on the battle target with geo geo', function()
        local gs = boot()
        assert.same({'Geo-Frailty Apex Toad'}, geo(gs, 'geo geo'))
    end)

    it('casts the automatic Indi spell on the caster with geo indi', function()
        local gs = boot()
        assert.same({'Indi-Torpor Jobby'}, geo(gs, 'geo indi'))
    end)

    it('uses Entrust, then the automatic entrust spell on the entrustee, with geo entrust', function()
        local gs = boot()
        gs:console('gs c geo entrust')
        gs:advance(1.2)
        assert.same({'input /ja "Entrust" <me>', 'input /ma "Indi-Fury" <p1>'}, ran(gs, 'input'))
        assert.same({'Entrust Jobby'}, actions(gs))
    end)

    it('names the target of geo entrust when given one', function()
        local gs = boot()
        gs:console('gs c geo entrust Someone')
        gs:advance(1.2)
        assert.same({'input /ja "Entrust" <me>', 'input /ma "Indi-Fury" Someone'}, ran(gs, 'input'))
    end)

    pending('casts the automatic Indi spell with geo indi while Entrust is up: that branch of job_self_command in '
        .. 'data/GEO.lua reads spell.target.type, and a self command has no spell, so the command stops in an error')
end)

describe('the automatic spells a geomancer names', function()
    it('are Torpor, Frailty and Fury by default, and say so', function()
        local gs = boot()
        gs:console('gs c autoindi')
        gs:console('gs c autogeo')
        gs:console('gs c autoentrust')
        assert.is_true(said(gs, 'Your Auto Indi- spell is set to Torpor.'))
        assert.is_true(said(gs, 'Your Auto Geo- spell is set to Frailty.'))
        assert.is_true(said(gs, 'Your Auto Entrust Indi- spell is set to Fury.'))
    end)

    it('are changed by naming another, with its first letter capitalized', function()
        local gs = boot()
        gs:console('gs c autoindi fury')
        gs:console('gs c autogeo torpor')
        gs:console('gs c autoentrust haste')
        assert.is_true(said(gs, 'Your Auto Indi- spell is set to Fury.'))
        assert.is_true(said(gs, 'Your Auto Geo- spell is set to Torpor.'))
        assert.is_true(said(gs, 'Your Auto Entrust Indi- spell is set to Haste.'))
        assert.equal('Fury', gs.user.autoindi)
        assert.equal('Torpor', gs.user.autogeo)
        assert.equal('Haste', gs.user.autoentrust)
    end)

    it('are the ones geo indi and geo geo then cast', function()
        local gs = boot()
        gs:console('gs c autoindi fury')
        gs:console('gs c autogeo torpor')
        gs:traffic()
        gs:console('gs c geo indi')
        assert.same({'Indi-Fury Jobby'}, actions(gs))
        gs:advance(6)
        gs:console('gs c geo geo')
        assert.same({'Geo-Torpor Apex Toad'}, actions(gs))
    end)

    it('include the entrustee, <p1> by default, set by name', function()
        local gs = boot()
        gs:console('gs c trustee someone')
        assert.is_true(said(gs, 'Your Auto Entrustee target is set to Someone.'))
        assert.equal('Someone', gs.user.autoentrustee)
    end)

    it('take the entrustee from a target in the party, else <p1>', function()
        local gs = boot()
        gs:console('gs c trustee')
        assert.is_true(said(gs, 'Your Auto Entrustee target is set to <p1>.'))
    end)
end)

describe('gs c elemental on a geomancer\'s nukes', function()
    local function nuke(gs, command)
        gs:console('gs c elemental ' .. (command or 'nuke'))
        return actions(gs)
    end

    it('casts the highest tier of the element\'s nuke the geomancer has, ready and affordable: Fire V', function()
        local gs = boot()
        assert.same({'Fire V Apex Toad'}, nuke(gs))
    end)

    it('casts the next tier down while that is on recast', function()
        local gs = boot()
        jobby.set_recasts(gs, {spells = {[148] = 6000}})
        assert.same({'Fire IV Apex Toad'}, nuke(gs))
    end)

    it('casts the highest tier the MP buys', function()
        local gs = boot({mp = 70})
        assert.same({'Fire III Apex Toad'}, nuke(gs))
    end)

    it('says so when nothing is ready and affordable', function()
        local gs = boot({mp = 3})
        assert.same({}, nuke(gs))
        assert.is_true(said(gs, 'Abort: All Fire nukes on cooldown or or not enough MP.'))
    end)

    it('casts Fire II for a small nuke', function()
        local gs = boot()
        assert.same({'Fire II Apex Toad'}, nuke(gs, 'smallnuke'))
    end)

    it('casts Banish II in the Light element, with a sub job that has it', function()
        local gs = boot()
        gs:console('gs c set ElementalMode Light')
        gs:traffic()
        assert.same({'Banish II Apex Toad'}, nuke(gs))
    end)

    it('says so in the Light element when neither Banish is ready', function()
        local gs = boot()
        gs:console('gs c set ElementalMode Light')
        jobby.set_recasts(gs, {spells = {[29] = 6000, [28] = 6000}})
        gs:traffic()
        assert.same({}, nuke(gs))
        assert.is_true(said(gs, 'Abort: Banishes on cooldown or not enough MP.'))
    end)
end)

describe('the tick of a geomancer', function()
    -- With the spells of Auto's list up, so the tick has none of them to cast.
    local function geomancer(options)
        options = options or {}
        options.buffs = options.buffs or {}
        for _, buff in ipairs({'Haste', 'Refresh', 'Stoneskin'}) do
            options.buffs[#options.buffs + 1] = buff
        end
        local gs = boot(options)
        gs:console('gs c set AutoBuffMode Auto')
        return gs
    end

    it('casts the automatic Indi spell with none out', function()
        local gs = geomancer()
        assert.same({'Indi-Torpor Jobby'}, first_actions(gs))
    end)

    it('casts it again when the one out is not the automatic one', function()
        local gs = geomancer()
        gs:set_indi({element = 1, size = 1})
        gs.user.last_indi = 'Fury'
        assert.same({'Indi-Torpor Jobby'}, first_actions(gs))
    end)

    it('casts no Indi spell with the automatic one out', function()
        local gs = geomancer()
        gs:set_indi({element = 1, size = 1})
        gs.user.last_indi = 'Torpor'
        gs.user.autoentrust = 'None'
        gs.user.autogeo = 'None'
        assert.same({}, first_actions(gs))
    end)

    it('uses Entrust for the automatic entrust spell in combat', function()
        local gs = geomancer()
        gs:set_indi({element = 1, size = 1})
        gs.user.last_indi = 'Torpor'
        gs.user.in_combat = true
        assert.same({'Entrust Jobby'}, first_actions(gs))
        gs:advance(1.2)
        assert.same({'input /ja "Entrust" <me>', 'input /ma "Indi-Fury" <p1>'}, ran(gs, 'input'))
    end)

    it('uses no Entrust out of combat with the combat only state on', function()
        local gs = geomancer()
        gs:set_indi({element = 1, size = 1})
        gs.user.last_indi = 'Torpor'
        gs.user.autogeo = 'None'
        assert.same({}, first_actions(gs))
    end)

    it('uses Entrust out of combat with the combat only state off', function()
        local gs = geomancer()
        gs:console('gs c toggle CombatEntrustOnly')
        gs:set_indi({element = 1, size = 1})
        gs.user.last_indi = 'Torpor'
        assert.same({'Entrust Jobby'}, first_actions(gs))
    end)

    it('casts the automatic Geo spell at the battle target', function()
        local gs = geomancer()
        gs:set_indi({element = 1, size = 1})
        gs.user.last_indi = 'Torpor'
        gs.user.autoentrust = 'None'
        assert.same({'Geo-Frailty Apex Toad'}, first_actions(gs))
    end)

    it('uses Blaze of Glory ahead of it in combat', function()
        local gs = geomancer()
        gs:set_indi({element = 1, size = 1})
        gs.user.last_indi = 'Torpor'
        gs.user.autoentrust = 'None'
        gs.user.in_combat = true
        assert.equal('/ja "Blaze of Glory" <me>;', first_typed(gs)[1])
    end)

    it('uses no Blaze of Glory with the Geo abilities state off', function()
        local gs = geomancer()
        gs:console('gs c toggle AutoGeoAbilities')
        gs:set_indi({element = 1, size = 1})
        gs.user.last_indi = 'Torpor'
        gs.user.autoentrust = 'None'
        gs.user.in_combat = true
        assert.same({'Geo-Frailty Apex Toad'}, first_actions(gs))
    end)

    it('uses no Blaze of Glory under Bolster', function()
        local gs = geomancer({buffs = {'Bolster'}})
        gs:set_indi({element = 1, size = 1})
        gs.user.last_indi = 'Torpor'
        gs.user.autoentrust = 'None'
        gs.user.in_combat = true
        assert.same({'Geo-Frailty Apex Toad'}, first_actions(gs))
    end)

    it('casts the automatic Geo spell with no monster to fight only when it is one for a friend', function()
        local gs = geomancer()
        gs:set_indi({element = 1, size = 1})
        gs.user.last_indi = 'Torpor'
        gs.user.autoentrust = 'None'
        gs.user.autogeo = 'Fury'
        gs.game.target_index = nil
        gs.game.monster = nil
        assert.same({'Geo-Fury Jobby'}, first_actions(gs))
    end)

    it('casts nothing for an enemy Geo spell with no monster to fight', function()
        local gs = geomancer()
        gs:set_indi({element = 1, size = 1})
        gs.user.last_indi = 'Torpor'
        gs.user.autoentrust = 'None'
        gs.game.target_index = nil
        gs.game.monster = nil
        assert.same({}, first_actions(gs))
    end)

    describe('with a luopan out', function()
        local function luopan(options)
            options = options or {}
            options.luopan = true
            local gs = geomancer(options)
            gs:set_indi({element = 1, size = 1})
            gs.user.last_indi = 'Torpor'
            gs.user.autoentrust = 'None'
            return gs
        end

        it('uses Ecliptic Attrition on it, once', function()
            local gs = luopan()
            assert.same({'/ja "Ecliptic Attrition" <me>;'}, first_typed(gs))
            assert.is_true(gs.user.used_ecliptic)
        end)

        it('uses it no more once it has', function()
            local gs = luopan()
            gs.user.used_ecliptic = true
            assert.same({}, first_actions(gs))
        end)

        it('uses it not at all with the Geo abilities state off', function()
            local gs = luopan()
            gs:console('gs c toggle AutoGeoAbilities')
            assert.same({}, first_actions(gs))
        end)

        it('uses it not at all under Bolster', function()
            local gs = luopan({buffs = {'Bolster'}})
            assert.same({}, first_actions(gs))
        end)

        it('uses Full Circle on a luopan out of reach, over 50 yalms away', function()
            local gs = luopan({luopan_distance = 51 ^ 2})
            assert.same({'Full Circle Jobby'}, first_actions(gs))
        end)

        it('keeps a luopan 50 yalms away', function()
            local gs = luopan({luopan_distance = 50 ^ 2})
            assert.same({'/ja "Ecliptic Attrition" <me>;'}, first_typed(gs))
        end)
    end)

    it('does nothing with AutoBuffMode off', function()
        local gs = boot()
        assert.same({}, first_actions(gs))
    end)
end)
