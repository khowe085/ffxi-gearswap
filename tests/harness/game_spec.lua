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

    it('has the monster act with the message the server sends for each kind of action', function()
        local game = Game.new({res = harness.resources()})
        local messages = {}
        game:register('action', function(act) messages[#messages + 1] = act.targets[1].actions[1].message end)
        game:monster_acts(1)
        game:monster_acts(7, 'Fulmination')
        game:monster_acts(11, 'Fulmination')
        game:monster_acts(8, 'Slow')
        game:monster_acts(4, 'Slow')
        game:settle()
        assert.same({1, 43, 185, 327, 2}, messages)
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

    it('takes every piece off on a change of main job', function()
        local game = Game.new({res = harness.resources(), main_job = 'WAR', items = {{name = 'Nyame Helm'}},
            wearing = {head = 1}})
        game:change_main_job('MNK')
        game:settle()
        assert.same({}, game:worn())
        assert.same({0, 0}, {game.windower.ffxi.get_items().equipment.head, game.bags[0].items[1].status})
    end)
end)

describe('what the client sends in the stand-in game', function()
    local function boot()
        return Game.new({res = harness.resources(), main_job = 'WAR', items = {{name = 'Nyame Helm'}}})
    end

    local function equip_head(game)
        game.windower.packets.inject_outgoing(0x050, string.char(0x50, 4, 0, 0, 1, 4, 0, 0))
    end

    it('reaches the server once the outgoing chunk handlers have seen it, as the game settles', function()
        local game = boot()
        local worn_then
        game:register('outgoing chunk', function(id)
            if id == 0x050 then worn_then = game:worn().head or 'nothing' end
        end)
        equip_head(game)
        assert.is_nil(game:worn().head)
        game:settle()
        assert.equal('nothing', worn_then)
        assert.equal('Nyame Helm', game:worn().head)
    end)

    it('never reaches the server when a handler blocks it, and the handlers after it are told so', function()
        local game = boot()
        local blocked_after
        game:register('outgoing chunk', function(id) return id == 0x050 end)
        game:register('outgoing chunk', function(_, _, _, _, blocked) blocked_after = blocked end)
        equip_head(game)
        game:settle()
        assert.is_true(blocked_after)
        assert.is_nil(game:worn().head)
        assert.is_nil(game.last_packets.incoming[0x050])
    end)

    it('of its own says whether a handler blocked it', function()
        local game = boot()
        game:register('outgoing chunk', function(id) return id == 0x0B6 end)
        assert.same({true, false}, {game:send_from_client(0x0B6, ''), game:send_from_client(0x0B7, '')})
    end)

    it('names what it asks for as it stood when it went, whatever happens to the item after', function()
        local gs = harness.boot(testy.whm())
        local slot = gs.game:find_item('inventory', "Bunzi's Hat")
        gs.game.windower.packets.inject_outgoing(0x050, string.char(0x50, 4, 0, 0, slot, 4, 0, 0))
        gs.game.bags[0].items[slot] = nil
        assert.same({{equip = {head = "Bunzi's Hat"}}}, gs:traffic())
    end)

    it('names the target of an action as it stood when it went', function()
        local gs = harness.boot(testy.whm())
        local friend = gs.game:add_party_member({name = 'Friend'})
        gs:type('/ma "Cure III" Friend')
        gs.game:remove_mob(friend.index)
        assert.same({{action = 'Cure III', target = 'Friend'}}, gs:action_entries())
    end)
end)

describe('a packet the addon hands Windower as one from the server, in the stand-in game', function()
    it('reaches the incoming chunk handlers as injected', function()
        local game = Game.new({res = harness.resources()})
        local seen
        game:register('incoming chunk', function(id, _, _, injected) seen = {id, injected} end)
        game.windower.packets.inject_incoming(0x0FF, string.char(0xFF, 2, 0, 0, 0, 0, 0, 0))
        game:settle()
        assert.same({0x0FF, true}, seen)
    end)
end)

describe('the server\'s answer to an equip request in the stand-in game', function()
    -- Testy, a level 99 Hume white mage wearing Nyame Mail, asks the server for the item in that bag (the inventory
    -- unless named) in that slot, as GearSwap would. Returns how many equip packets (0x050) the server answered with.
    local function ask(game, name, slot, bag)
        local bag_id = game:bag_id(bag or 'inventory')
        local bag_slot = assert(game:find_item(bag or 'inventory', name))
        local replies = 0
        game:register('incoming chunk', function(id) if id == 0x050 then replies = replies + 1 end end)
        game.windower.packets.inject_outgoing(0x050, string.char(0x50, 4, 0, 0, bag_slot, Game.slot_ids[slot], bag_id, 0))
        game:settle()
        return replies
    end

    local function boot(options)
        options = options or {}
        local items = {{name = 'Nyame Mail'}, {name = 'Nyame Helm'}, {name = 'Naegling'}, {name = 'Decennial Dress'},
            {name = 'Nyame Helm', bag = 'case'}}
        return Game.new({res = harness.resources(), main_job = 'WHM', main_job_level = options.level, items = items,
            wearing = {body = 1}})
    end

    it('puts on a piece the character can wear, and says so', function()
        local game = boot()
        assert.equal(1, ask(game, 'Nyame Helm', 'head'))
        assert.same({body = 'Nyame Mail', head = 'Nyame Helm'}, game:worn())
    end)

    it('refuses a piece of another job\'s', function()
        local game = boot()
        assert.equal(0, ask(game, 'Naegling', 'main'))
        assert.same({body = 'Nyame Mail'}, game:worn())
    end)

    it('refuses a piece of a higher level than the character\'s', function()
        local game = boot({level = 98})
        assert.equal(0, ask(game, 'Nyame Helm', 'head'))
        assert.same({body = 'Nyame Mail'}, game:worn())
    end)

    it('refuses a piece another race wears', function()
        local game = boot()
        assert.equal(0, ask(game, 'Decennial Dress', 'body'))
        assert.same({body = 'Nyame Mail'}, game:worn())
    end)

    it('refuses a piece in a slot it doesn\'t go in', function()
        local game = boot()
        assert.equal(0, ask(game, 'Nyame Helm', 'body'))
        assert.same({body = 'Nyame Mail'}, game:worn())
    end)

    it('refuses a piece in a bag gear can\'t be worn from', function()
        local game = boot()
        assert.equal(0, ask(game, 'Nyame Helm', 'head', 'case'))
        assert.same({body = 'Nyame Mail'}, game:worn())
    end)
end)

describe('the server\'s answer to an equip request for the sub slot in the stand-in game', function()
    -- Testy, a level 99 white mage holding that main weapon, with the job traits given (none unless given), asks the
    -- server for the item in the sub slot. Returns what is worn.
    local function sub(main, item, traits)
        local game = Game.new({res = harness.resources(), main_job = 'WHM', items = {{name = main}, {name = item}},
            wearing = {main = 1}})
        game:set_job_traits(traits or {})
        local bag_slot = assert(game:find_item('inventory', item))
        game.windower.packets.inject_outgoing(0x050,
            string.char(0x50, 4, 0, 0, bag_slot, Game.slot_ids.sub, game:bag_id('inventory'), 0))
        game:settle()
        return game:worn()
    end

    it('refuses a weapon without the Dual Wield trait', function()
        assert.same({main = 'Daybreak'}, sub('Daybreak', "Bunzi's Rod"))
    end)

    it('puts a weapon on with the Dual Wield trait', function()
        assert.same({main = 'Daybreak', sub = "Bunzi's Rod"}, sub('Daybreak', "Bunzi's Rod", {'Dual Wield'}))
    end)

    it('puts a shield on without the Dual Wield trait', function()
        assert.same({main = 'Daybreak', sub = 'Ammurapi Shield'}, sub('Daybreak', 'Ammurapi Shield'))
    end)

    it('puts a grip on without the Dual Wield trait', function()
        assert.same({main = "Terra's Staff", sub = 'Enki Strap'}, sub("Terra's Staff", 'Enki Strap'))
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
