local harness = require('harness')
local plain = require('plain')
local testy = require('testy')

-- Testy with GearSwap's equip_sets watched, so what GearSwap takes for an event shows: each call is {event, args}.
local function boot()
    local gs = harness.boot(testy.whm())
    local events = {}
    local original = gs.env.equip_sets
    gs.env.equip_sets = function(event, ts, ...)
        events[#events + 1] = {event, ...}
        return original(event, ts, ...)
    end
    return gs, events
end

local function names(events)
    local result = {}
    for _, entry in ipairs(events) do
        result[#result + 1] = entry[1]
    end
    return result
end

-- Testy as a summoner, on a plain user file whose pet hooks note what they were handed.
local function boot_summoner(options)
    options = options or {}
    options.main_job, options.sub_job, options.expect_file = 'SMN', 'RDM', 'Testy_SMN.lua'
    return harness.boot(options)
end

local calls = plain.calls

describe('the stand-in game\'s pet', function()
    it('is none until given', function()
        local gs = boot()
        gs.env.refresh_globals()
        assert.is_false(gs.env.pet.isvalid)
        assert.is_nil(gs.game.windower.ffxi.get_mob_by_target('pet'))
    end)

    it('arrives in GearSwap\'s pet table, and as a pet change, once the packets after the update come', function()
        local gs, events = boot()
        gs:give_pet({name = 'Luopan', hpp = 80})
        assert.same({'pet_change'}, names(events))
        assert.is_true(events[1][3])
        gs.env.refresh_globals()
        assert.is_true(gs.env.pet.isvalid)
        assert.equal('Luopan', gs.env.pet.name)
        assert.equal(80, gs.env.pet.hpp)
        assert.equal('Idle', gs.env.pet.status)
    end)

    it('is found as the target pet, and among the mobs, by the player\'s pet index', function()
        local gs = boot()
        gs:give_pet({name = 'Luopan'})
        local ffxi = gs.game.windower.ffxi
        assert.equal('Luopan', ffxi.get_mob_by_target('pet').name)
        assert.equal('Luopan', ffxi.get_mob_by_index(ffxi.get_mob_by_target('me').pet_index).name)
    end)

    it('leaves as a pet change with the pet that went, and is no pet after', function()
        local gs, events = boot()
        gs:give_pet({name = 'Luopan'})
        for i = #events, 1, -1 do
            events[i] = nil
        end
        gs:take_pet()
        assert.same({'pet_change'}, names(events))
        assert.is_false(events[1][3])
        assert.equal('Luopan', events[1][2].name)
        gs.env.refresh_globals()
        assert.is_false(gs.env.pet.isvalid)
        assert.is_nil(gs.game.windower.ffxi.get_mob_by_target('pet'))
    end)

    it('changes status as a pet status change, with the status the pet has after', function()
        local gs, events = boot()
        gs:give_pet({name = 'Luopan'})
        for i = #events, 1, -1 do
            events[i] = nil
        end
        gs:set_pet_status(1)
        assert.same({'pet_status_change'}, names(events))
        assert.equal('Engaged', events[1][2])
        assert.equal('Idle', events[1][3])
        gs.env.refresh_globals()
        assert.equal('Engaged', gs.env.pet.status)
    end)

    it('has the TP the packet says', function()
        local gs = boot()
        gs:give_pet({name = 'Automaton'})
        gs:set_pet_tp(1500)
        gs.env.refresh_globals()
        assert.equal(1500, gs.env.pet.tp)
    end)

    it('has no TP in its mob, as the game gives none for a mob', function()
        local gs = boot()
        local pet = gs.game:place_pet({name = 'Carbuncle'})
        assert.is_nil(gs.game.windower.ffxi.get_mob_by_index(pet.index).tp)
    end)

    it('has the head and frame of the automaton the game gives a puppetmaster', function()
        local gs = harness.boot({character = 'Jobby', main_job = 'PUP', sub_job = 'WAR'})
        gs.game:set_automaton({name = 'Tin', head = 'Harlequin Head', frame = 'Valoredge Frame'})
        gs:give_pet({name = 'Tin'})
        gs.env.refresh_globals()
        assert.equal('Harlequin Head', gs.env.pet.head)
        assert.equal('Valoredge Frame', gs.env.pet.frame)
    end)
end)

describe('the stand-in game\'s pet, as a user file\'s hooks see it', function()
    it('is none until the server gives one', function()
        local gs = boot_summoner()
        assert.is_false(gs.env.pet.isvalid)
        assert.is_nil(gs.game:get_player().pet_index)
    end)

    it('is at the character\'s side when GearSwap loads, when the boot says so', function()
        local gs = boot_summoner({pet = {name = 'Ifrit'}})
        assert.is_true(gs.env.pet.isvalid)
        assert.equal('Ifrit', gs.env.pet.name)
        assert.equal('Fire', gs.env.pet.element)
        assert.equal(gs.game.pet.index, gs.game:get_player().pet_index)
        assert.same({}, calls(gs))
    end)

    it('stands as far along x as its distance, squared as Windower gives it, says', function()
        local gs = boot_summoner({pet = {name = 'Ifrit'}})
        local near = gs.game.windower.ffxi.get_mob_by_target('pet')
        gs:give_pet({name = 'Ifrit', distance = 5 ^ 2})
        local far = gs.game.windower.ffxi.get_mob_by_target('pet')
        assert.same({4, 2, 25, 5}, {near.distance, near.x, far.distance, far.x})
    end)

    it('is announced to GearSwap when the server gives one, which runs pet_change with the pet', function()
        local gs = boot_summoner()
        gs:give_pet({name = 'Garuda'})
        assert.same({{event = 'pet_change', pet_name = 'Garuda', pet_status = 'Idle',
            extra = {name = 'Garuda', gain = true, element = 'Wind', valid = true}}}, calls(gs))
        assert.equal(0, gs.env.pet.tp)
    end)

    it('is known by the status its mob has', function()
        local gs = boot_summoner()
        gs:give_pet({name = 'Garuda', status = 1, hpp = 40})
        assert.equal('Engaged', gs.env.pet.status)
        assert.equal(40, gs.env.pet.hpp)
    end)

    it('is gone when the server takes it, which runs pet_change with what GearSwap knew of it', function()
        local gs = boot_summoner()
        gs:give_pet({name = 'Garuda'})
        calls(gs)
        gs:take_pet()
        assert.same({{event = 'pet_change', extra = {name = 'Garuda', gain = false, element = 'Wind', valid = false}}},
            calls(gs))
        assert.is_false(gs.env.pet.isvalid)
        assert.is_nil(gs.game:get_player().pet_index)
    end)

    it('runs pet_status_change with the new status and the old when its status changes', function()
        local gs = boot_summoner({pet = {name = 'Garuda'}})
        gs:set_pet_status(1)
        assert.same({{event = 'pet_status_change', pet_name = 'Garuda', pet_status = 'Engaged',
            extra = {new = 'Engaged', old = 'Idle'}}}, calls(gs))
        gs:set_pet_status(0)
        assert.same({new = 'Idle', old = 'Engaged'}, calls(gs)[1].extra)
    end)

    it('readies a move, which runs pet_midcast with the move and the monster as its target', function()
        local gs = boot_summoner({pet = {name = 'Carbuncle'}})
        gs:pet_readies('Foot Kick')
        local called = calls(gs)
        assert.equal(1, #called)
        assert.equal('pet_midcast', called[1].event)
        assert.equal('Foot Kick', called[1].name)
        assert.equal('Apex Toad', called[1].target)
    end)

    it('finishes a move, which runs pet_aftercast with the move', function()
        local gs = boot_summoner({pet = {name = 'Carbuncle'}})
        gs:pet_readies('Foot Kick')
        calls(gs)
        gs:pet_finishes('Foot Kick')
        local called = calls(gs)
        assert.equal(1, #called)
        assert.equal('pet_aftercast', called[1].event)
        assert.equal('Foot Kick', called[1].name)
    end)

    it('readies and finishes a blood pact, a job ability, aimed at the monster or at the character', function()
        local gs = boot_summoner({pet = {name = 'Ifrit'}})
        gs:pet_readies('Flaming Crush', 'ability')
        local called = calls(gs)
        assert.same({'pet_midcast', 'Flaming Crush', 'Apex Toad'}, {called[1].event, called[1].name, called[1].target})
        gs:pet_finishes('Flaming Crush', 'ability')
        local finished = calls(gs)[1]
        assert.same({'pet_aftercast', 'Flaming Crush'}, {finished.event, finished.name})
        gs:pet_readies('Inferno Howl', 'ability', {target = 'player'})
        assert.equal('Testy', calls(gs)[1].target)
    end)

    it('readies and finishes a spell, as a spirit casts it', function()
        local gs = boot_summoner({pet = {name = 'FireSpirit'}})
        gs:pet_readies('Fire', 'spell')
        local called = calls(gs)
        assert.same({'pet_midcast', 'Fire', 'Magic'}, {called[1].event, called[1].name, called[1].action_type})
        gs:pet_finishes('Fire', 'spell')
        local finished = calls(gs)[1]
        assert.same({'pet_aftercast', 'Fire'}, {finished.event, finished.name})
    end)
end)

describe('the stand-in game\'s indicolure', function()
    it('shows in the player table with its element, size and target, as an indicolure change', function()
        local gs, events = boot()
        gs:set_indi({element = 0, size = 3, enemy = true})
        assert.same({'indi_change'}, names(events))
        assert.is_true(events[1][3])
        gs.env.refresh_globals()
        assert.same({element = 'Fire', element_id = 0, size = 3, target = 'Enemy'}, gs.env.player.indi)
    end)

    it('is for allies when not for enemies', function()
        local gs = boot()
        gs:set_indi({element = 6})
        gs.env.refresh_globals()
        assert.same({element = 'Light', element_id = 6, size = 1, target = 'Ally'}, gs.env.player.indi)
    end)

    it('ends as an indicolure change that says it is gone', function()
        local gs, events = boot()
        gs:set_indi({element = 4})
        for i = #events, 1, -1 do
            events[i] = nil
        end
        gs:set_indi()
        assert.same({'indi_change'}, names(events))
        assert.is_false(events[1][3])
        gs.env.refresh_globals()
        assert.is_nil(gs.env.player.indi)
    end)
end)
