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

    it('takes the last recast started for an ability, whatever was left of the one before', function()
        local game = Game.new({res = harness.resources()})
        game:start_ability_recast('Berserk', 300)
        game:start_ability_recast('Berserk', 0)
        assert.equal(0, game.windower.ffxi.get_ability_recasts()[1])
    end)

    it('takes the merit levels the boot gives it', function()
        local gs = harness.boot(testy.whm({merits = {sic_recast = 3}}))
        assert.equal(3, gs.game.windower.ffxi.get_player().merits.sic_recast)
    end)

    it('has no merits unless the boot gives them', function()
        local gs = harness.boot(testy.whm())
        assert.same({}, gs.game.windower.ffxi.get_player().merits)
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

    it('zones: get_info reports the new zone, after the zone change event', function()
        local gs = harness.boot(testy.whm())
        local game = gs.game
        local seen
        game:register('zone change', function(new, old) seen = {new, old, game.windower.ffxi.get_info().zone} end)
        gs:change_zone(230)
        assert.same({230, 288, 230}, seen)
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
        local gs = harness.boot(testy.whm())
        local game = gs.game
        local seen = {}
        game:register('outgoing chunk', function(id, _, _, injected)
            if not injected then
                seen[#seen + 1] = {'out', id, injected}
            end
        end)
        game:register('incoming chunk', function(id, data)
            seen[#seen + 1] = {'in', id}
            if id == 0x00A then
                seen[#seen + 1] = {'zone', data:byte(0x31) + 256 * data:byte(0x32), 'job', data:byte(0xB5), data:byte(0xB8),
                    'name', data:sub(0x85, 0x89)}
            end
        end)
        game:register('zone change', function(new, old) seen[#seen + 1] = {'zone change', new, old} end)
        gs:change_zone(230)
        assert.same({{'out', 0x00D, false}, {'in', 0x00B}, {'in', 0x00A}, {'zone', 230, 'job', 3, 5, 'name', 'Testy'},
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

    it('changes the main job as at a Moogle: the job change packet out, then the char stats packet in', function()
        local game = Game.new({res = harness.resources(), main_job = 'WAR', sub_job = 'BLM'})
        local seen = {}
        game:register('outgoing chunk', function(id, data, _, injected)
            seen[#seen + 1] = {'out', id, data:byte(5), data:byte(6), injected}
        end)
        game:register('incoming chunk', function(id, data)
            seen[#seen + 1] = {'in', id, data:byte(13), data:byte(14), data:byte(15)}
        end)
        game:change_main_job('MNK', 90)
        game:settle()
        assert.same({{'out', 0x100, 2, 4, false}, {'in', 0x061, 2, 90, 4}}, seen)
        local player = game.windower.ffxi.get_player()
        assert.same({'MNK', 90, 'BLM'}, {player.main_job, player.main_job_level, player.sub_job})
    end)
end)

describe('what the stand-in game reports of itself', function()
    it('has a target arrow at rest, with no offset', function()
        local game = Game.new({res = harness.resources()})
        assert.same({x = 0, y = 0, z = 0}, game.windower.ffxi.get_info().target_arrow)
    end)

    it('takes the fields it is told to change, and keeps the others', function()
        local game = Game.new({res = harness.resources()})
        game:set_info({mog_house = true, weather = 7})
        local info = game.windower.ffxi.get_info()
        assert.same({true, 7, true}, {info.mog_house, info.weather, info.logged_in})
    end)
end)

describe('the packets the server sends in the stand-in game', function()
    local function parse(gs, id)
        local data = gs.game.last_packets.incoming[id][1]
        return gs.env.packets.parse('incoming', data)
    end

    it('are built from Windower\'s field definitions, by the labels of their fields', function()
        local gs = harness.boot(testy.whm())
        gs:send(0x00A, {['Zone'] = 230, ['Player Name'] = 'Corey', ['Max HP'] = 1800})
        local packet = parse(gs, 0x00A)
        assert.same({230, 'Corey', 1800}, {packet['Zone'], packet['Player Name'], packet['Max HP']})
    end)

    it('are framed with the id and a sequence that goes up with each', function()
        local gs = harness.boot(testy.whm())
        gs:send(0x00B, {})
        local first = parse(gs, 0x00B)._sequence
        gs:send(0x00B, {})
        assert.equal(first + 1, parse(gs, 0x00B)._sequence)
    end)

    it('zone in names the character the game has, by default', function()
        local gs = harness.boot(testy.whm())
        gs:send_zone_in()
        local packet = parse(gs, 0x00A)
        assert.same({'Testy', 3, 5, 288}, {packet['Player Name'], packet['Main Job'], packet['Sub Job'], packet['Zone']})
    end)

    it('take a number for a field of bytes, as Windower\'s pack does, so a label two fields share can be built', function()
        local gs = harness.boot(testy.whm())
        assert.equal('12', ('A4'):pack(12):sub(1, 2))
        assert.equal(4, #('A4'):pack(12))
        assert.has_no.errors(function()
            gs:send(0x00A, {['_unknown12'] = 7})
        end)
    end)

    it('a buff packet has each buff in its slot and when it wears off, as the packet gives it', function()
        local gs = harness.boot(testy.whm())
        gs:send_buffs({{name = 'Haste', expires = 5000}, {name = 'Protect', expires = 6000}})
        local data = gs.game.last_packets.incoming[0x063][1]
        assert.same({9, 33, 40, 255}, {data:unpack('H', 5), data:unpack('H', 9), data:unpack('H', 11), data:unpack('H', 13)})
        assert.same({5000 * 60, 6000 * 60}, {data:unpack('I', 0x49), data:unpack('I', 0x4D)})
        assert.same({33, 40}, {gs.game.player.buffs[1], gs.game.player.buffs[2]})
    end)

    it('a party buff packet has the id and index of each member, and their buffs', function()
        local gs = harness.boot(testy.whm())
        local alice = gs.game:add_party_member({name = 'Alice'})
        gs:send_party_buffs({{id = alice.id, index = alice.index, buffs = {33, 419}}})
        local data = gs.game.last_packets.incoming[0x076][1]
        assert.same({alice.id, alice.index, 33}, {data:unpack('I', 5), data:unpack('H', 9), data:byte(0x15)})
        assert.same({419 % 256, math.floor(419 / 256)}, {data:byte(0x16), math.floor(data:byte(0x0D) / 4) % 4})
    end)
end)
