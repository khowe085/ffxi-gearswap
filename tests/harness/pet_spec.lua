local harness = require('harness')

local function boot(options)
    options = options or {}
    options.main_job, options.sub_job, options.expect_file = 'SMN', 'RDM', 'Testy_SMN.lua'
    return harness.boot(options)
end

-- The hooks GearSwap called on the user file since the last ask.
local function calls(gs)
    local list = gs.user.calls
    gs.user.calls = {}
    return list
end

describe('the stand-in game\'s pet', function()
    it('is none until the server gives one', function()
        local gs = boot()
        assert.is_false(gs.env.pet.isvalid)
        assert.is_nil(gs.game:get_player().pet_index)
    end)

    it('is at the character\'s side when GearSwap loads, when the boot says so', function()
        local gs = boot({pet = {name = 'Ifrit'}})
        assert.is_true(gs.env.pet.isvalid)
        assert.equal('Ifrit', gs.env.pet.name)
        assert.equal('Fire', gs.env.pet.element)
        assert.equal(gs.game.pet.index, gs.game:get_player().pet_index)
        assert.same({}, calls(gs))
    end)

    it('is announced to GearSwap when the server gives one, which runs pet_change with the pet', function()
        local gs = boot()
        gs:summon_pet({name = 'Garuda'})
        assert.same({{event = 'pet_change', pet_name = 'Garuda', pet_status = 'Idle',
            extra = {name = 'Garuda', gain = true, element = 'Wind', valid = true}}}, calls(gs))
        assert.equal(0, gs.env.pet.tp)
    end)

    it('is known by the status its mob has', function()
        local gs = boot()
        gs:summon_pet({name = 'Garuda', status = 1, hpp = 40})
        assert.equal('Engaged', gs.env.pet.status)
        assert.equal(40, gs.env.pet.hpp)
    end)

    it('is gone when the server dismisses it, which runs pet_change with what GearSwap knew of it', function()
        local gs = boot()
        gs:summon_pet({name = 'Garuda'})
        calls(gs)
        gs:dismiss_pet()
        assert.same({{event = 'pet_change', extra = {name = 'Garuda', gain = false, element = 'Wind', valid = false}}},
            calls(gs))
        assert.is_false(gs.env.pet.isvalid)
        assert.is_nil(gs.game:get_player().pet_index)
    end)

    it('runs pet_status_change with the new status and the old when its status changes', function()
        local gs = boot({pet = {name = 'Garuda'}})
        gs:set_pet_status(1)
        assert.same({{event = 'pet_status_change', pet_name = 'Garuda', pet_status = 'Engaged',
            extra = {new = 'Engaged', old = 'Idle'}}}, calls(gs))
        gs:set_pet_status(0)
        assert.same({new = 'Idle', old = 'Engaged'}, calls(gs)[1].extra)
    end)

    it('has the TP its update gave', function()
        local gs = boot({pet = {name = 'Garuda'}})
        gs:set_pet_tp(1500)
        gs.env.refresh_globals()
        assert.equal(1500, gs.env.pet.tp)
    end)

    it('readies a move, which runs pet_midcast with the move and the monster as its target', function()
        local gs = boot({pet = {name = 'Carbuncle'}})
        gs:pet_readies('Foot Kick')
        local called = calls(gs)
        assert.equal(1, #called)
        assert.equal('pet_midcast', called[1].event)
        assert.equal('Foot Kick', called[1].name)
        assert.equal('Apex Toad', called[1].target)
    end)

    it('finishes a move, which runs pet_aftercast with the move', function()
        local gs = boot({pet = {name = 'Carbuncle'}})
        gs:pet_readies('Foot Kick')
        calls(gs)
        gs:pet_finishes('Foot Kick')
        local called = calls(gs)
        assert.equal(1, #called)
        assert.equal('pet_aftercast', called[1].event)
        assert.equal('Foot Kick', called[1].name)
    end)

    it('readies and finishes a blood pact, a job ability, aimed at the monster or at the character', function()
        local gs = boot({pet = {name = 'Ifrit'}})
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
        local gs = boot({pet = {name = 'FireSpirit'}})
        gs:pet_readies('Fire', 'spell')
        local called = calls(gs)
        assert.same({'pet_midcast', 'Fire', 'Magic'}, {called[1].event, called[1].name, called[1].action_type})
        gs:pet_finishes('Fire', 'spell')
        local finished = calls(gs)[1]
        assert.same({'pet_aftercast', 'Fire'}, {finished.event, finished.name})
    end)
end)
