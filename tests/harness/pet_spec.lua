local harness = require('harness')
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

    it('has the head and frame of the automaton the game gives a puppetmaster', function()
        local gs = harness.boot({character = 'Jobby', main_job = 'PUP', sub_job = 'WAR'})
        gs.game:set_automaton({name = 'Tin', head = 'Harlequin Head', frame = 'Valoredge Frame'})
        gs:give_pet({name = 'Tin'})
        gs.env.refresh_globals()
        assert.equal('Harlequin Head', gs.env.pet.head)
        assert.equal('Valoredge Frame', gs.env.pet.frame)
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

describe('a command a user file sends', function()
    it('runs when it starts with more than one @, as GearSwap\'s send_command makes of one that has its own', function()
        local gs = boot()
        gs.game:enqueue('command', '@@input /echo hello')
        gs.game:settle()
        assert.same({'hello'}, {gs.game.typed[1] and gs.game.typed[1]:match('/echo (.*)')})
    end)
end)
