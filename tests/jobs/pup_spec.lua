local jobby = require('jobby')

local pieces = {'Volte Cap', 'Volte Jupon', 'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Null Masque',
    'Adamantite Armor', 'Plumb Boots', "Orunmila's Torque", 'Weike Torque', 'Sortiarius Earring', 'Beatific Earring',
    'Pensee Earring', 'Moonshade Earring', 'Lunette Ring', 'Pernicious Ring', 'Gelatinous Ring', 'Wanion Belt',
    'Prodigious Mantle', 'Malignance Tabard'}

-- Jobby as a puppetmaster with the idle set on and an automaton out, Valoredge's, which fights. The options:
--   sub_job, tp, buffs     as for a boot
--   head, frame            the automaton's, Valoredge Head and Frame by default
--   pet                    the fields of the pet's mob over its defaults (status 1 is an engaged pet)
--   no_pet                 no pet is called out
--   oil                    false for no Automat. Oil +3 among the pieces
--   mp                     the automaton's MP, of a hundred
local function boot(options)
    options = options or {}
    local items = {}
    for _, name in ipairs(pieces) do
        items[#items + 1] = name
    end
    if options.oil ~= false then
        items[#items + 1] = 'Automat. Oil +3'
    end
    local gs = jobby.boot('PUP', {items = items, sub_job = options.sub_job or 'WHM', tp = options.tp,
        buffs = options.buffs})
    gs.game:set_automaton({name = 'Tin', head = options.head or 'Valoredge Head',
        frame = options.frame or 'Valoredge Frame', max_mp = 100, mp = options.mp or 100})
    gs:console('gs c update')
    if not options.no_pet then
        local pet = {name = 'Tin'}
        for key, value in pairs(options.pet or {}) do
            pet[key] = value
        end
        local tp = pet.tp
        pet.tp = nil
        gs:give_pet(pet)
        if tp then
            gs:set_pet_tp(tp)
            gs:console('gs c update')
        end
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

local function ran(gs, command)
    local count = 0
    for _, ran_command in ipairs(gs.game.commands) do
        if ran_command == command then
            count = count + 1
        end
    end
    return count
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

describe('the automaton\'s mode, from its head and frame', function()
    local cases = {
        {'Valoredge Head', 'Sharpshot Frame', 'HybridRanged'},
        {'Harlequin Head', 'Sharpshot Frame', 'HybridRanged'},
        {'Sharpshot Head', 'Sharpshot Frame', 'Ranged'},
        {'Soulsoother Head', 'Valoredge Frame', 'Tank'},
        {'Harlequin Head', 'Valoredge Frame', 'Melee'},
        {'Sharpshot Head', 'Harlequin Frame', 'Magic'},
        {'Stormwaker Head', 'Stormwaker Frame', 'Magic'},
        {'Spiritreaver Head', 'Harlequin Frame', 'Nuke'},
        {'Harlequin Head', 'Harlequin Frame', 'Melee'},
        {'Soulsoother Head', 'Harlequin Frame', 'LightTank'},
        {'Soulsoother Head', 'Stormwaker Frame', 'Heal'},
        {'Valoredge Head', 'Stormwaker Frame', 'Melee'},
        {'Harlequin Head', 'Stormwaker Frame', 'Magic'},
    }

    for _, case in ipairs(cases) do
        local head, frame, mode = unpack(case)
        it(('is %s with %s on %s'):format(mode, head, frame), function()
            local gs = boot({head = head, frame = frame})
            assert.equal(mode, gs.user.state.PetMode.value)
        end)
    end

    it('is left at None with the Auto Pet Mode off', function()
        local gs = boot({no_pet = true})
        gs:console('gs c toggle AutoPetMode')
        gs:give_pet({name = 'Tin'})
        assert.equal('None', gs.user.state.PetMode.value)
    end)

    it('is taken from the pet by gs c autopetmode', function()
        local gs = boot({no_pet = true})
        gs:console('gs c toggle AutoPetMode')
        gs:give_pet({name = 'Tin'})
        gs:console('gs c autopetmode')
        assert.equal('Melee', gs.user.state.PetMode.value)
    end)

    it('is not taken by gs c autopetmode with no pet', function()
        local gs = boot({no_pet = true})
        gs:console('gs c autopetmode')
        assert.equal('None', gs.user.state.PetMode.value)
        assert.is_true(said(gs, 'Error: No valid pet.'))
    end)

    it('is the idle custom group while the pet is out, and no more once it is gone', function()
        local gs = boot()
        assert.same({'Melee'}, {gs.user.classes.CustomIdleGroups[1]})
        gs:take_pet()
        assert.equal(0, #gs.user.classes.CustomIdleGroups)
    end)
end)

describe('the idle set of a puppetmaster', function()
    it('is sets.idle with no pet out', function()
        local gs = boot({no_pet = true})
        assert.same(jobby.worn_by({}), gs:worn())
    end)

    it('is sets.idle.Pet with an idle pet out', function()
        local gs = boot()
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet)), gs:worn())
    end)

    it('is the set of the automaton\'s mode under sets.idle.Pet.Engaged with the pet engaged', function()
        local gs = boot({pet = {status = 1}})
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee)), gs:worn())
    end)

    it('is sets.idle.Pet.Engaged for a mode it has no set for', function()
        local gs = boot({head = 'Soulsoother Head', pet = {status = 1}})
        assert.equal('Tank', gs.user.state.PetMode.value)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged)), gs:worn())
    end)

    it('follows the pet\'s status as the server changes it', function()
        local gs = boot()
        gs:set_pet_status(1)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee)), gs:worn())
        gs:set_pet_status(0)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet)), gs:worn())
    end)

    it('follows the pet out and back in', function()
        local gs = boot()
        gs:take_pet()
        assert.same(jobby.worn_by({}), gs:worn())
        gs:give_pet({name = 'Tin'})
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet)), gs:worn())
    end)

    it('wears the set of the automaton\'s PetWSGear over it from 1000 TP of the pet\'s', function()
        local gs = boot({pet = {status = 1, tp = 1500}})
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee, sets_of(gs).midcast.Pet.PetWSGear.Melee)),
            gs:worn())
    end)

    it('wears the base PetWSGear for a mode it has no set for', function()
        local gs = boot({head = 'Sharpshot Head', frame = 'Sharpshot Frame', pet = {status = 1, tp = 1500}})
        assert.equal('Ranged', gs.user.state.PetMode.value)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Ranged, sets_of(gs).midcast.Pet.PetWSGear)),
            gs:worn())
    end)

    it('keeps the engaged pet set under 1000 TP of the pet\'s', function()
        local gs = boot({pet = {status = 1, tp = 999}})
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee)), gs:worn())
    end)

    it('leaves PetWSGear off with the Pet WS Gear state off', function()
        local gs = boot({pet = {status = 1, tp = 1500}})
        gs:console('gs c toggle PetWSGear')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee)), gs:worn())
    end)

    it('wears sets.midcast.Pet.PetEnmityGear while a Light Maneuver is up and Flashbulb is ready', function()
        local gs = boot({pet = {status = 1}, buffs = {'Light Maneuver'}})
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee, sets_of(gs).midcast.Pet.PetEnmityGear)),
            gs:worn())
    end)

    it('wears sets.midcast.Pet.PetEnmityGear while a Fire Maneuver is up and Provoke is ready', function()
        local gs = boot({pet = {status = 1}, buffs = {'Fire Maneuver'}})
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee, sets_of(gs).midcast.Pet.PetEnmityGear)),
            gs:worn())
    end)

    it('wears no PetEnmityGear without the maneuvers', function()
        local gs = boot({pet = {status = 1}, buffs = {'Wind Maneuver'}})
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee)), gs:worn())
    end)

    it('wears no PetEnmityGear with the Pet Enmity Gear state off', function()
        local gs = boot({pet = {status = 1}, buffs = {'Light Maneuver'}})
        gs:console('gs c toggle PetEnmityGear')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee)), gs:worn())
    end)

    it('puts PetWSGear ahead of PetEnmityGear when the pet has the TP', function()
        local gs = boot({pet = {status = 1, tp = 1500}, buffs = {'Light Maneuver'}})
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee, sets_of(gs).midcast.Pet.PetWSGear.Melee)),
            gs:worn())
    end)

    it('wears sets.buff.Overdrive over the engaged pet set while Overdrive is up', function()
        local gs = boot({pet = {status = 1}, buffs = {'Overdrive'}})
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee, sets_of(gs).buff.Overdrive)), gs:worn())
    end)

    it('wears sets.latent_refresh under half MP with a mage as the sub job and no pet engaged', function()
        local gs = boot()
        gs.game.player.vitals.mpp = 40
        gs:console('gs c update')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet, sets_of(gs).latent_refresh)), gs:worn())
    end)

    it('wears no sets.latent_refresh with an engaged pet', function()
        local gs = boot({pet = {status = 1}})
        gs.game.player.vitals.mpp = 40
        gs:console('gs c update')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee)), gs:worn())
    end)

    it('wears no sets.latent_refresh without a mage as the sub job', function()
        local gs = boot({sub_job = 'WAR'})
        gs.game.player.vitals.mpp = 40
        gs:console('gs c update')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet)), gs:worn())
    end)

    it('wears no sets.latent_refresh above half MP', function()
        local gs = boot()
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet)), gs:worn())
    end)
end)

describe('the engaged set of a puppetmaster', function()
    local function engaged_worn(gs, ...)
        return jobby.worn_by(jobby.layer(sets_of(gs).engaged, ...))
    end

    it('is sets.engaged with the pet not engaged', function()
        local gs = boot()
        gs:engage()
        assert.same(engaged_worn(gs), gs:worn())
    end)

    it('wears PetWSGear over it when the pet has 1000 TP and the puppetmaster has not', function()
        local gs = boot({pet = {status = 1, tp = 1500}})
        gs:engage()
        assert.same(engaged_worn(gs, sets_of(gs).midcast.Pet.PetWSGear.Melee), gs:worn())
    end)

    it('wears no PetWSGear over it when the puppetmaster has 1000 TP as well', function()
        local gs = boot({pet = {status = 1, tp = 1500}, tp = 1000})
        gs:engage()
        assert.same(engaged_worn(gs), gs:worn())
    end)

    it('wears PetEnmityGear over it while a Light Maneuver is up and Flashbulb is ready', function()
        local gs = boot({pet = {status = 1}, buffs = {'Light Maneuver'}})
        gs:engage()
        assert.same(engaged_worn(gs, sets_of(gs).midcast.Pet.PetEnmityGear), gs:worn())
    end)

    it('wears no PetEnmityGear over it without the maneuver', function()
        local gs = boot({pet = {status = 1}})
        gs:engage()
        assert.same(engaged_worn(gs), gs:worn())
    end)
end)

describe('the pet\'s Flashbulb and Provoke', function()
    local function engaged_pet()
        return boot({pet = {status = 1}, buffs = {'Light Maneuver', 'Fire Maneuver'}})
    end

    it('end the PetEnmityGear of their maneuver until they are ready again', function()
        local gs = boot({pet = {status = 1}, buffs = {'Light Maneuver'}})
        local with_gear = jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee, sets_of(gs).midcast.Pet.PetEnmityGear))
        local without_gear = jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet.Engaged.Melee))
        assert.same(with_gear, gs:worn())
        gs:pet_finishes('Flashbulb')
        gs:console('gs c update')
        assert.same(without_gear, gs:worn())
        gs:advance(37)
        gs:console('gs c update')
        assert.same(without_gear, gs:worn())
        gs:advance(2)
        gs:console('gs c update')
        assert.same(with_gear, gs:worn())
    end)

    it('are timed from when the pet uses them: Flashbulb for 38 seconds', function()
        local gs = engaged_pet()
        local start = gs.game.clock
        gs:pet_finishes('Flashbulb')
        assert.near(start + 38, gs.user.PupFlashReady, 0.001)
    end)

    it('are timed from when the pet uses them: Provoke for 23 seconds', function()
        local gs = engaged_pet()
        local start = gs.game.clock
        gs:pet_finishes('Provoke')
        assert.near(start + 23, gs.user.PupVokeReady, 0.001)
    end)

    it('are the only moves of the pet\'s that start a timer', function()
        local gs = engaged_pet()
        gs:pet_finishes('Slapstick')
        assert.equal(0, gs.user.PupFlashReady)
        assert.equal(0, gs.user.PupVokeReady)
    end)
end)

describe('what the pet does', function()
    it('puts the pet\'s set for a spell it casts on, when it starts casting', function()
        local gs = boot()
        gs:pet_readies('Cure III', 'spell')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.Pet, sets_of(gs).midcast.Pet.Cure)), gs:worn())
    end)

    it('puts no set on for a weapon skill it readies, only for its spells', function()
        local gs = boot()
        local before = gs:worn()
        gs:pet_readies('Slapstick')
        assert.same(before, gs:worn())
    end)

    it('says its weapon skill in the party chat with the party chat state on', function()
        local gs = boot()
        gs:console('gs c toggle PartyChatWS')
        gs:pet_readies('Slapstick')
        gs:pet_finishes('Slapstick')
        assert.same({'/p ' .. gs.user.auto_translate('Automaton') .. ' ' .. gs.user.auto_translate('Weapon Skill')
            .. ' Slapstick'}, gs.game.typed)
    end)

    it('says nothing of its weapon skill with the party chat state off', function()
        local gs = boot()
        gs:pet_readies('Slapstick')
        gs:pet_finishes('Slapstick')
        assert.same({}, gs.game.typed)
    end)

    it('says nothing of a move that is not a weapon skill of the automaton\'s', function()
        local gs = boot()
        gs:console('gs c toggle PartyChatWS')
        gs:pet_readies('Flashbulb')
        gs:pet_finishes('Flashbulb')
        assert.same({}, gs.game.typed)
    end)
end)

describe('engaging', function()
    it('sends the pet in with Deploy when it is idle and the target is a monster close by', function()
        local gs = boot()
        gs:engage()
        assert.same({'Deploy'}, actions(gs))
    end)

    it('sends no pet in with the Auto Deploy Mode off', function()
        local gs = boot()
        gs:console('gs c toggle AutoDeployMode')
        gs:engage()
        assert.same({}, actions(gs))
    end)

    it('sends no pet in when it is engaged already', function()
        local gs = boot({pet = {status = 1}})
        gs:engage()
        assert.same({}, actions(gs))
    end)

    it('sends no pet in with none out', function()
        local gs = boot({no_pet = true})
        gs:engage()
        assert.same({}, actions(gs))
    end)

    it('sends no pet in when the target is 20 yalms away', function()
        local gs = boot()
        gs.game.monster.distance = 20 ^ 2
        gs:engage()
        assert.same({}, actions(gs))
    end)
end)

describe('gs c maneuver', function()
    local function maneuver(gs, argument)
        gs:console('gs c maneuver' .. (argument and (' ' .. argument) or ''))
        gs:advance(1)
        return actions(gs)
    end

    it('uses the first maneuver of the automaton\'s mode that is not up enough', function()
        local gs = boot()
        assert.same({'Fire Maneuver'}, maneuver(gs))
    end)

    it('goes on to the next once the first is up', function()
        local gs = boot({buffs = {'Fire Maneuver'}})
        assert.same({'Thunder Maneuver'}, maneuver(gs))
    end)

    it('counts the maneuvers of a kind: Wind Maneuver three times for a ranged automaton', function()
        local gs = boot({head = 'Sharpshot Head', frame = 'Sharpshot Frame', buffs = {'Wind Maneuver', 'Wind Maneuver'}})
        assert.same({'Wind Maneuver'}, maneuver(gs))
    end)

    it('uses none when they are up', function()
        local gs = boot({buffs = {'Fire Maneuver', 'Thunder Maneuver', 'Wind Maneuver'}})
        assert.same({}, maneuver(gs))
    end)

    it('uses the numbered maneuver of the list', function()
        local gs = boot()
        assert.same({'Thunder Maneuver'}, maneuver(gs, '2'))
    end)

    it('says so when the list has no maneuver that number', function()
        local gs = boot()
        assert.same({}, maneuver(gs, '5'))
        assert.is_true(said(gs, "Error: You don't have that many maneuvers listed."))
    end)

    it('says so when the argument is no number of one to eight', function()
        local gs = boot()
        assert.same({}, maneuver(gs, 'x'))
        assert.is_true(said(gs, 'Error: Maneuver command format is wrong.'))
    end)

    it('says so when there is no pet', function()
        local gs = boot({no_pet = true})
        assert.same({}, maneuver(gs))
        assert.is_true(said(gs, 'Error: No valid pet.'))
    end)
end)

describe('the tick of a puppetmaster', function()
    it('has the pet repaired under 45% HP when Automat. Oil +3 is at hand', function()
        local gs = boot({pet = {hpp = 30}})
        assert.same({'Repair'}, first_actions(gs))
    end)

    it('has no pet repaired at 45% HP', function()
        local gs = boot({pet = {hpp = 45}})
        assert.same({}, first_actions(gs))
    end)

    it('has no pet repaired without the oil', function()
        local gs = boot({pet = {hpp = 30}, oil = false})
        assert.same({}, first_actions(gs))
    end)

    it('has no pet repaired with the Auto Repair Mode off', function()
        local gs = boot({pet = {hpp = 30}})
        gs:console('gs c toggle AutoRepairMode')
        assert.same({}, first_actions(gs))
    end)

    it('has no pet repaired while Repair is on recast', function()
        local gs = boot({pet = {hpp = 30}})
        gs.game:start_ability_recast('Repair', 60)
        assert.same({}, first_actions(gs))
    end)

    describe('with the Auto Puppet Mode on', function()
        local function puppeteer(options)
            local gs = boot(options)
            gs:console('gs c toggle AutoPuppetMode')
            return gs
        end

        it('calls the automaton out with Activate when there is none', function()
            local gs = puppeteer({no_pet = true})
            assert.same({'Activate'}, first_actions(gs))
        end)

        it('calls it out with Deus Ex Automata while Activate is on recast', function()
            local gs = puppeteer({no_pet = true})
            gs.game:start_ability_recast('Activate', 600)
            assert.same({'Deus Ex Automata'}, first_actions(gs))
        end)

        it('calls nothing out when both are on recast', function()
            local gs = puppeteer({no_pet = true})
            gs.game:start_ability_recast('Activate', 600)
            gs.game:start_ability_recast('Deus Ex Automata', 600)
            assert.same({}, first_actions(gs))
        end)

        it('sends an idle pet in on a monster target with Deploy', function()
            local gs = puppeteer()
            assert.same({'Deploy'}, first_actions(gs))
        end)

        it('deactivates an idle pet that is out of MP, at full health', function()
            local gs = puppeteer({mp = 5})
            assert.same({'Deactivate'}, first_actions(gs))
        end)

        it('sends a hurt pet in rather than deactivating it', function()
            local gs = puppeteer({mp = 5, pet = {hpp = 99}})
            assert.same({'Deploy'}, first_actions(gs))
        end)

        it('leaves an engaged pet alone', function()
            local gs = puppeteer({pet = {status = 1}})
            assert.same({}, first_actions(gs))
        end)
    end)

    it('calls nothing out with the Auto Puppet Mode off', function()
        local gs = boot({no_pet = true})
        assert.same({}, first_actions(gs))
    end)

    describe('with AutoBuffMode on and the pet engaged', function()
        -- With the spells of Auto's list up, so the tick has nothing to cast but a maneuver.
        local function buffer(options)
            options = options or {}
            options.pet = {status = 1}
            options.buffs = options.buffs or {}
            for _, buff in ipairs({'Haste', 'Refresh', 'Phalanx'}) do
                options.buffs[#options.buffs + 1] = buff
            end
            local gs = boot(options)
            gs:console('gs c set AutoBuffMode Auto')
            return gs
        end

        it('uses the first maneuver of the automaton\'s mode that is not up enough', function()
            local gs = buffer()
            assert.same({'Fire Maneuver'}, first_actions(gs))
        end)

        it('goes on to the next once the first is up', function()
            local gs = buffer({buffs = {'Fire Maneuver'}})
            assert.same({'Thunder Maneuver'}, first_actions(gs))
        end)

        it('uses the list the Auto Maneuvers state names instead of the automaton\'s mode', function()
            local gs = buffer()
            gs:console('gs c set AutoManeuvers Magic')
            assert.same({'Light Maneuver'}, first_actions(gs))
        end)

        it('uses none while the maneuvers are on recast', function()
            local gs = buffer()
            gs.game:start_ability_recast('Fire Maneuver', 30)
            assert.same({}, first_actions(gs))
        end)

        it('uses none with the maneuvers up', function()
            local gs = buffer({buffs = {'Fire Maneuver', 'Thunder Maneuver', 'Wind Maneuver'}})
            assert.same({}, first_actions(gs))
        end)

        it('uses none with the pet idle', function()
            local gs = boot({buffs = {'Haste', 'Refresh', 'Phalanx'}})
            gs:console('gs c set AutoBuffMode Auto')
            assert.same({}, first_actions(gs))
        end)
    end)

    describe('with the pet\'s TP', function()
        it('asks for the gear to be updated when the pet reaches 1000', function()
            local gs = boot({pet = {status = 1}})
            gs:set_pet_tp(1500)
            gs.game.commands = {}
            gs:play(5.3)
            assert.equal(1, ran(gs, 'gs c update'))
        end)

        it('asks again when it falls back under 1000', function()
            local gs = boot({pet = {status = 1}})
            gs:set_pet_tp(1500)
            gs:play(5.3)
            gs.game.commands = {}
            gs:set_pet_tp(100)
            gs:play(1.5)
            assert.equal(1, ran(gs, 'gs c update'))
        end)

        it('asks for nothing while it stays under 1000', function()
            local gs = boot({pet = {status = 1}})
            gs:set_pet_tp(900)
            gs.game.commands = {}
            gs:play(5.3)
            assert.equal(0, ran(gs, 'gs c update'))
        end)

        it('asks for nothing with the Pet WS Gear state off', function()
            local gs = boot({pet = {status = 1}})
            gs:console('gs c toggle PetWSGear')
            gs:set_pet_tp(1500)
            gs.game.commands = {}
            gs:play(5.3)
            assert.equal(0, ran(gs, 'gs c update'))
        end)
    end)
end)

describe('a cure by a puppetmaster with a white mage as the sub job', function()
    local function cure(gs)
        gs:type('/ma "Cure III" <me>')
        return gs:worn()
    end

    it('wears sets.midcast.Cure', function()
        local gs = boot({no_pet = true})
        assert.equal('Gelatinous Ring', cure(gs).left_ring)
    end)

    it('wears sets.midcast.LightWeatherCure in light weather', function()
        local gs = boot({no_pet = true})
        gs:set_weather(16)
        assert.equal('Lunette Ring', cure(gs).left_ring)
    end)

    it('wears sets.midcast.LightDayCure on a Lightsday', function()
        local gs = boot({no_pet = true})
        gs:set_day(6)
        assert.equal('Pernicious Ring', cure(gs).left_ring)
    end)

    it('takes the weather ahead of the day', function()
        local gs = boot({no_pet = true})
        gs:set_day(6)
        gs:set_weather(16)
        assert.equal('Lunette Ring', cure(gs).left_ring)
    end)

    it('takes no light set in other weather', function()
        local gs = boot({no_pet = true})
        gs:set_day(3)
        gs:set_weather(6)
        assert.equal('Gelatinous Ring', cure(gs).left_ring)
    end)
end)

describe('a weapon skill by a puppetmaster at the TP cap', function()
    local function engaged(tp)
        local gs = boot({tp = tp, no_pet = true})
        gs:engage()
        gs:traffic()
        return gs
    end

    it('trades the Moonshade Earring for sets.MaxTP', function()
        local gs = engaged(3000)
        gs:type('/ws "Victory Smite" <t>')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).engaged, sets_of(gs).precast.WS['Victory Smite'],
            sets_of(gs).MaxTP)), gs:worn())
    end)

    it('trades it for sets.AccMaxTP in the Acc offense mode', function()
        local gs = engaged(3000)
        gs:console('gs c set OffenseMode Acc')
        gs:traffic()
        gs:type('/ws "Victory Smite" <t>')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).engaged, sets_of(gs).precast.WS['Victory Smite'],
            sets_of(gs).AccMaxTP)), gs:worn())
    end)

    it('keeps the Moonshade Earring under 2951 TP', function()
        local gs = engaged(2900)
        gs:type('/ws "Victory Smite" <t>')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).engaged, sets_of(gs).precast.WS['Victory Smite'])), gs:worn())
    end)
end)

describe('the automaton\'s call and its aftercast', function()
    it('leaves the gear of Activate on once it is done, as the job file handles it', function()
        local gs = boot({no_pet = true})
        gs:type('/ja "Activate" <me>')
        gs:finish_action()
        assert.equal('Null Masque', gs:worn().head)
    end)

    it('gives way to the idle set after another ability', function()
        local gs = boot()
        gs:type('/ja "Repair" <me>')
        gs:finish_action()
        assert.equal('Nyame Helm', gs:worn().head)
    end)
end)

describe('the status of the pet in the display', function()
    it('says its name, parts, mode, status, TP and HP', function()
        local gs = boot({pet = {hpp = 80}})
        gs:console('gs c update user')
        assert.is_true(said(gs, 'Tin [Valoredge Head][Valoredge Frame](Melee): Idle  TP=0  HP%=80'))
    end)

    it('adds the MP of a magic automaton', function()
        local gs = boot({head = 'Stormwaker Head', frame = 'Stormwaker Frame'})
        gs:console('gs c update user')
        assert.is_true(said(gs, 'Tin [Stormwaker Head][Stormwaker Frame](Magic): Idle  TP=0  HP%=100  MP%=100'))
    end)

    it('says nothing with no pet out', function()
        local gs = boot({no_pet = true})
        gs:console('gs c update user')
        assert.is_false(said(gs, 'TP='))
    end)
end)
