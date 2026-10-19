local Game = require('game')
local harness = require('harness')
local testy = require('testy')

describe('the stand-in game', function()
    it('stops a clock whose timers never run out, rather than running for ever', function()
        local game = Game.new({res = harness.resources()})
        local function again()
            game:schedule(again, 0)
        end
        game:schedule(again, 0)
        assert.has_error(function() game:advance(1) end, 'the game\'s timers never ran out; something keeps setting more')
    end)

    it('plays frames: the clock moves on a tenth of a second at a time, with prerender each frame', function()
        local game = Game.new({res = harness.resources()})
        local frames = {}
        game:register('prerender', function() frames[#frames + 1] = game.clock end)
        local start = game.clock
        game:play(1)
        assert.equal(10, #frames)
        assert.near(start + 0.1, frames[1], 1e-9)
        assert.near(start + 1, frames[10], 1e-9)
        assert.near(start + 1, game.clock, 1e-9)
    end)

    it('puts two copies of a piece named for two slots in those slots, one each', function()
        local gs = harness.boot(testy.whm({
            items = {{name = 'Stikini Ring +1'}, {name = 'Stikini Ring +1', bag = 'wardrobe'}},
            wearing = {left_ring = 'Stikini Ring +1', right_ring = 'Stikini Ring +1'},
        }))
        assert.same({left_ring = 'Stikini Ring +1', right_ring = 'Stikini Ring +1'}, gs:worn())
        assert.are_not.same(gs.game.equipment[13], gs.game.equipment[14])
    end)

    it('reports the target arrow, which GearSwap reads for an action typed at a target\'s id', function()
        local gs = harness.boot(testy.whm())
        gs:traffic()
        gs:type('/ma "Haste" ' .. gs.game.player.id)
        local traffic = gs:traffic()
        assert.same({action = 'Haste', target = 'Testy'}, traffic[#traffic])
    end)

    it('counts a recast down with the clock: abilities in seconds, spells in 60ths of a second', function()
        local game = Game.new({res = harness.resources()})
        game:start_ability_recast('Berserk', 300)
        game:advance(100)
        assert.near(200, game.windower.ffxi.get_ability_recasts()[1], 1e-9)
        assert.equal(0, game.windower.ffxi.get_ability_recasts()[2])
        game:start_spell_recast('Haste', 20)
        game:advance(15)
        assert.near(300, game.windower.ffxi.get_spell_recasts()[57], 1e-6)
        assert.equal(0, game.windower.ffxi.get_spell_recasts()[58])
        game:advance(10)
        assert.equal(0, game.windower.ffxi.get_spell_recasts()[57])
    end)

    it('sends Windower\'s tp change event with the new TP and the old', function()
        local game = Game.new({res = harness.resources(), tp = 400})
        local seen
        game:register('tp change', function(new, old) seen = {new, old} end)
        game:set_tp(1000)
        assert.same({1000, 400}, seen)
        assert.equal(1000, game.windower.ffxi.get_player().vitals.tp)
    end)

    it('moves the character on while it walks, and keeps it where it stood after', function()
        local game = Game.new({res = harness.resources()})
        local function x() return game.windower.ffxi.get_mob_by_target('me').x end
        game:advance(1)
        assert.equal(0, x())
        game:walk()
        game:advance(1)
        local walked = x()
        assert.is_true(walked > 0)
        game:stand()
        game:advance(1)
        assert.equal(walked, x())
    end)

    it('lists the party\'s members after the character, in the order they joined', function()
        local game = Game.new({res = harness.resources()})
        game:add_party_member({name = 'Koru-Moru'})
        game:add_party_member({name = 'Qultada'})
        local party = game.windower.ffxi.get_party()
        assert.equal('Koru-Moru', party.p1.name)
        assert.equal('Qultada', party.p2.name)
        assert.is_nil(party.p3)
        assert.equal(3, party.party1_count)
    end)

    it('zones: get_info reports the new zone, after the zone change event', function()
        local game = Game.new({res = harness.resources()})
        local seen
        game:register('zone change', function(new, old) seen = {new, old, game.windower.ffxi.get_info().zone} end)
        game:change_zone(230)
        assert.same({230, 288, 230}, seen)
    end)

    it('counts each bag\'s items and room in get_items, as Windower does', function()
        local game = Game.new({res = harness.resources(), items = {{name = 'Naegling'}, {name = 'Daybreak', bag = 'sack'}}})
        local items = game.windower.ffxi.get_items()
        assert.equal(1, items.count_inventory)
        assert.equal(1, items.count_sack)
        assert.equal(0, items.count_satchel)
        assert.equal(80, items.max_sack)
        assert.is_true(items.enabled_sack)
    end)

    it('lists the items GearSwap used, with their targets', function()
        local gs = harness.boot({items = {{name = 'Holy Water', count = 2}, {name = 'Grape Daifuku'}}})
        gs:type('/item "Grape Daifuku" <me>')
        assert.same({{item = 'Grape Daifuku', target = 'Testy'}}, gs.game:items_used())
    end)

    it('has the monster ready a TP move at the character in an action packet', function()
        local game = Game.new({res = harness.resources()})
        local seen
        game:register('action', function(act) seen = act end)
        game:monster_readies('Fulmination')
        game:settle()
        assert.equal(game.monster.id, seen.actor_id)
        assert.equal(7, seen.category)
        assert.equal(game.player.id, seen.targets[1].id)
        assert.equal(2028, seen.targets[1].actions[1].param)
    end)

    it('reports the target arrow at rest, so an action at a target given by its id goes out', function()
        local gs = harness.boot(testy.whm())
        gs:type('/ma "Cure III" ' .. gs.game.monster.id)
        local actions = {}
        for _, entry in ipairs(gs:traffic()) do
            actions[#actions + 1] = entry.action and entry
        end
        assert.same({{action = 'Cure III', target = 'Apex Toad'}}, actions)
    end)

    it('moves Vana\'diel\'s time, day and weather, as get_info reports them, with the events that say so', function()
        local game = Game.new({res = harness.resources()})
        local events = {}
        for _, event in ipairs({'time change', 'day change', 'weather change'}) do
            game:register(event, function(new, old) events[#events + 1] = {event, new, old} end)
        end
        game:set_time(17 * 60 + 30)
        game:set_day(6)
        game:set_weather(16)
        local info = game.windower.ffxi.get_info()
        assert.same({17 * 60 + 30, 6, 16}, {info.time, info.day, info.weather})
        assert.same({{'time change', 1050, 720}, {'day change', 6, 0}, {'weather change', 16, 0}}, events)
        assert.equal(288, info.zone)
    end)

    it('zones as the game does: leave-zone out, zone-out and zone-in in, then the zone change event', function()
        local game = Game.new({res = harness.resources(), name = 'Commy', main_job = 'RDM', sub_job = 'WHM'})
        local seen = {}
        game:register('outgoing chunk', function(id, _, _, injected) seen[#seen + 1] = {'out', id, injected} end)
        game:register('incoming chunk', function(id, data)
            seen[#seen + 1] = {'in', id}
            if id == 0x00A then
                seen[#seen + 1] = {'zone', data:byte(0x31) + 256 * data:byte(0x32), 'job', data:byte(0xB5), data:byte(0xB8),
                    'name', data:sub(0x85, 0x89)}
            end
        end)
        game:register('zone change', function(new, old) seen[#seen + 1] = {'zone change', new, old} end)
        game:change_zone(230)
        assert.same({{'out', 0x00D, false}, {'in', 0x00B}, {'in', 0x00A}, {'zone', 230, 'job', 5, 3, 'name', 'Commy'},
            {'in', 0x063}, {'zone change', 230, 288}}, seen)
        assert.equal(230, game.windower.ffxi.get_info().zone)
    end)

    it('changes the sub job with the char stats packet that carries it', function()
        local game = Game.new({res = harness.resources(), main_job = 'WAR', sub_job = 'BLM'})
        local packet
        game:register('incoming chunk', function(id, data) if id == 0x061 then packet = data end end)
        game:change_sub_job('NIN', 45)
        game:settle()
        assert.same({1, 99, 13, 45}, {packet:byte(13), packet:byte(14), packet:byte(15), packet:byte(16)})
        local player = game.windower.ffxi.get_player()
        assert.same({'NIN', 45}, {player.sub_job, player.sub_job_level})
    end)
end)
