local Game = require('game')
local harness = require('harness')
local testy = require('testy')

-- Testy as a level 99 warrior wearing those pieces (slot to name), with the fields given laid over the game's options
-- (tp, abilities and the like).
local function warrior(wearing, fields)
    local options = {res = harness.resources(), main_job = 'WAR', items = {}, wearing = {}}
    for slot, name in pairs(wearing or {}) do
        options.items[#options.items + 1] = {name = name}
        options.wearing[slot] = #options.items
    end
    for key, value in pairs(fields or {}) do
        options[key] = value
    end
    return Game.new(options)
end

-- The TP the last char update (0x0DF) the server sent gives, nil when it sent none.
local function char_update_tp(game)
    local sent = game.last_packets.incoming[0x0DF]
    if sent then
        local b1, b2, b3, b4 = sent[1]:byte(0x11, 0x14)
        return b1 + 256 * b2 + 65536 * b3 + 16777216 * b4
    end
end

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
        game:settle()
        assert.same({1000, 400}, seen)
        assert.equal(1000, game.windower.ffxi.get_player().vitals.tp)
    end)

    it('tells of a TP change with the char update first, so GearSwap has the new TP by the tp change event', function()
        local gs = harness.boot(testy.whm())
        local seen
        gs.game:register('tp change', function() seen = {char_update_tp(gs.game), gs.env.player.tp} end)
        gs:set_tp(1500)
        assert.same({1500, 1500}, seen)
    end)

    it('tells nothing of a TP that stays as it was', function()
        local game = Game.new({res = harness.resources(), tp = 400})
        local told = 0
        game:register('tp change', function() told = told + 1 end)
        game:set_tp(400)
        game:settle()
        assert.equal(0, told)
        assert.is_nil(char_update_tp(game))
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

    -- Testy, a warrior with 1000 TP wearing those pieces (slot to name), changes his main job to monk. Returns the TP
    -- then and the tp change events the change fired, each {new TP, old TP}.
    local function change_job(wearing)
        local game = warrior(wearing, {tp = 1000})
        local told = {}
        game:register('tp change', function(new, old) told[#told + 1] = {new, old} end)
        game:change_main_job('MNK')
        game:settle()
        return game.windower.ffxi.get_player().vitals.tp, told, game
    end

    it('takes the TP with the weapon on a change of main job, as the char update and the tp change event tell', function()
        local tp, told, game = change_job({main = 'Ragnarok', head = 'Nyame Helm'})
        assert.same({0, 0, {{0, 1000}}}, {tp, char_update_tp(game), told})
    end)

    it('keeps the TP on a change of main job with no main or sub weapon to take off, the stand-in\'s choice where the '
        .. 'doc names only weapons taken off', function()
        local tp, told = change_job({head = 'Nyame Helm'})
        assert.same({1000, {}}, {tp, told})
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
    -- Testy, a level 99 white mage (or of the job given) holding that main weapon (nothing when nil), with the job
    -- traits given (none unless given), asks the server for the item in the sub slot. Returns what is worn.
    local function sub(main, item, traits, job)
        local items, wearing = {{name = item}}, {}
        if main then
            items[2], wearing.main = {name = main}, 2
        end
        local game = Game.new({res = harness.resources(), main_job = job or 'WHM', items = items, wearing = wearing})
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

    it('refuses a shield with a two-handed weapon', function()
        assert.same({main = "Terra's Staff"}, sub("Terra's Staff", 'Kupo Shield'))
    end)

    it('refuses a weapon with a two-handed weapon, whatever the Dual Wield trait', function()
        assert.same({main = "Terra's Staff"}, sub("Terra's Staff", "Bunzi's Rod", {'Dual Wield'}))
    end)

    it('refuses a grip with a one-handed weapon', function()
        assert.same({main = 'Daybreak'}, sub('Daybreak', 'Enki Strap'))
    end)

    it('refuses a grip with nothing in the main hand', function()
        assert.same({}, sub(nil, 'Enki Strap'))
    end)

    it('refuses a shield, a grip and a weapon with a hand-to-hand weapon', function()
        assert.same({{main = 'Glanzfaust'}, {main = 'Glanzfaust'}, {main = 'Glanzfaust'}},
            {sub('Glanzfaust', 'Kupo Shield', {}, 'MNK'), sub('Glanzfaust', 'Mephitis Grip', {}, 'MNK'),
            sub('Glanzfaust', 'Qutrub Knife', {'Dual Wield'}, 'MNK')})
    end)
end)

describe('the TP after an equip request in the stand-in game', function()
    -- Testy, a level 99 ranger with the TP given (1000 unless given) holding Judge's Sword and Kupo Shield, with
    -- Judge's Bow and Chrono Arrow on and Qutrub Knife, Gandiva and Hauksbok Arrow in the inventory. Returns the game
    -- and the tp change events it fires from then on, each {new TP, old TP}.
    local function boot(tp)
        local items = {{name = "Judge's Sword"}, {name = 'Kupo Shield'}, {name = "Judge's Bow"}, {name = 'Chrono Arrow'},
            {name = 'Qutrub Knife'}, {name = 'Gandiva'}, {name = 'Hauksbok Arrow'}}
        local game = Game.new({res = harness.resources(), main_job = 'RNG', tp = tp or 1000, items = items,
            wearing = {main = 1, sub = 2, range = 3, ammo = 4}})
        local told = {}
        game:register('tp change', function(new, old) told[#told + 1] = {new, old} end)
        return game, told
    end

    -- The bytes of one equip request: the inventory slot of the item named in that slot, or 0 for 'empty'.
    local function chunk(game, slot, name)
        local bag_slot = name == 'empty' and 0 or assert(game:find_item('inventory', name))
        return string.char(bag_slot, Game.slot_ids[slot], game:bag_id('inventory'), 0)
    end

    -- Asks the server for each {slot, item name or 'empty'} in an equip request (0x050) of its own, as GearSwap does
    -- for fewer than three, and lets the game settle.
    local function ask(game, ...)
        for _, request in ipairs({...}) do
            game.windower.packets.inject_outgoing(0x050, string.char(0x50, 4, 0, 0) .. chunk(game, request[1], request[2]))
        end
        game:settle()
    end

    local function tp(game)
        return game.windower.ffxi.get_player().vitals.tp
    end

    it('goes to 0 when a piece goes in the main hand, as the char update tells, and Windower\'s tp change event '
        .. 'follows', function()
        local game, told = boot()
        local told_when_the_event_came
        game:register('tp change', function() told_when_the_event_came = char_update_tp(game) end)
        ask(game, {'main', 'Qutrub Knife'})
        assert.equal('Qutrub Knife', game:worn().main)
        assert.same({0, 0, {{0, 1000}}, 0}, {tp(game), char_update_tp(game), told, told_when_the_event_came})
    end)

    it('goes to 0 when a piece goes in the sub slot or the range slot', function()
        local game = boot()
        game:set_job_traits({'Dual Wield'})
        ask(game, {'sub', 'Qutrub Knife'})
        local ranged = boot()
        ask(ranged, {'range', 'Gandiva'})
        assert.same({'Qutrub Knife', 'Gandiva'}, {game:worn().sub, ranged:worn().range})
        assert.same({0, 0}, {tp(game), tp(ranged)})
    end)

    it('goes to 0 when the main or the sub weapon is taken off', function()
        local game = boot()
        ask(game, {'main', 'empty'})
        local shield = boot()
        ask(shield, {'sub', 'empty'})
        assert.same({0, 0}, {tp(game), tp(shield)})
    end)

    it('stays when the ammo changes or is taken off', function()
        local game, told = boot()
        ask(game, {'ammo', 'Hauksbok Arrow'})
        assert.equal('Hauksbok Arrow', game:worn().ammo)
        ask(game, {'ammo', 'empty'})
        assert.same({1000, {}}, {tp(game), told})
    end)

    it('stays when the ranged weapon is taken off, the stand-in\'s choice where the doc names only the main and sub '
        .. 'weapons', function()
        local game = boot()
        ask(game, {'range', 'empty'})
        assert.is_nil(game:worn().range)
        assert.equal(1000, tp(game))
    end)

    it('stays when the pieces in the weapon slots are asked for again where they are', function()
        local game, told = boot()
        ask(game, {'main', "Judge's Sword"}, {'sub', 'Kupo Shield'}, {'range', "Judge's Bow"})
        assert.same({1000, {}}, {tp(game), told})
    end)

    it('stays when the server refuses the request', function()
        local game = boot()
        game.refuse_equips = true
        ask(game, {'main', 'Qutrub Knife'})
        assert.equal("Judge's Sword", game:worn().main)
        assert.equal(1000, tp(game))
    end)

    it('stays at 0, with nothing told, when there is none to lose', function()
        local game, told = boot(0)
        ask(game, {'main', 'Qutrub Knife'})
        assert.same({0, {}}, {tp(game), told})
        assert.is_nil(char_update_tp(game))
    end)

    it('goes to 0 once for an equipset that changes two weapons', function()
        local game, told = boot()
        local chunks = chunk(game, 'main', 'Qutrub Knife') .. chunk(game, 'range', 'Gandiva')
            .. chunk(game, 'ammo', 'Hauksbok Arrow')
        game.windower.packets.inject_outgoing(0x051, string.char(0x51, 0x24, 0, 0, 3, 0, 0, 0) .. chunks)
        game:settle()
        assert.same({main = 'Qutrub Knife', sub = 'Kupo Shield', range = 'Gandiva', ammo = 'Hauksbok Arrow'},
            game:worn())
        assert.same({0, {{0, 1000}}}, {tp(game), told})
    end)

    -- Testy as a white mage with 1000 TP, 1234 HP (82%) and 567 MP (57%), which the boot doesn't give.
    local function boot_with_vitals()
        local gs = harness.boot(testy.whm({tp = 1000}))
        local vitals = gs.game.player.vitals
        vitals.hp, vitals.mp, vitals.hpp, vitals.mpp = 1234, 567, 82, 57
        return gs
    end

    it('goes to 0 for GearSwap too, which the char update tells with the HP and MP as they are', function()
        local gs = boot_with_vitals()
        gs:console('gs equip sets.engaged')
        assert.equal("Bunzi's Rod", gs:worn().main)
        local player = gs.env.player
        assert.same({hp = 1234, mp = 567, max_hp = 1500, max_mp = 1000, hpp = 82, mpp = 57, tp = 0}, player.vitals)
        assert.same({1234, 567, 82, 57, 0}, {player.hp, player.mp, player.hpp, player.mpp, player.tp})
    end)

    it('is told in a char update with each field where Windower\'s definitions put it', function()
        local gs = boot_with_vitals()
        gs:console('gs equip sets.engaged')
        local player = gs.game.player
        local update = gs.env.packets.parse('incoming', gs.game.last_packets.incoming[0x0DF][1])
        assert.same({player.id, 1234, 567, 0, player.index, 82, 57, player.main_job_id, 99, player.sub_job_id, 49},
            {update['ID'], update['HP'], update['MP'], update['TP'], update['Index'], update['HPP'], update['MPP'],
            update['Main job'], update['Main job level'], update['Sub job'], update['Sub job level']})
    end)
end)

describe('the weapon skills the stand-in game lists', function()
    -- Testy, a level 99 warrior wearing those pieces (slot to name), knowing the abilities given (a set of names),
    -- or, unless given, those the game finds for what he wears.
    local function boot(wearing, abilities)
        return warrior(wearing, {abilities = abilities})
    end

    local function names(ids)
        local res = harness.resources()
        local found = {}
        for _, id in ipairs(ids) do
            found[#found + 1] = res.weapon_skills[id].en
        end
        table.sort(found)
        return found
    end

    local function listed(game)
        return names(game.windower.ffxi.get_abilities().weapon_skills)
    end

    -- The names of the weapon skills of those skills (by id) that the test resources hold.
    local function of_skills(...)
        local skills = {}
        for _, skill in ipairs({...}) do
            skills[skill] = true
        end
        local ids = {}
        for id, entry in pairs(harness.resources().weapon_skills) do
            if type(entry) == 'table' and skills[entry.skill] then
                ids[#ids + 1] = id
            end
        end
        return names(ids)
    end

    local hand_to_hand, dagger, sword, staff, archery = 1, 2, 3, 12, 25

    it('are those of the main hand\'s weapon', function()
        assert.same(of_skills(sword), listed(boot({main = "Judge's Sword"})))
    end)

    it('are hand-to-hand\'s with nothing in the main hand', function()
        assert.same(of_skills(hand_to_hand), listed(boot()))
    end)

    it('are the ranged weapon\'s besides the main hand\'s', function()
        assert.same(of_skills(sword, archery), listed(boot({main = "Judge's Sword", range = "Judge's Bow"})))
    end)

    it('are hand-to-hand\'s and the ranged weapon\'s with nothing in the main hand', function()
        assert.same(of_skills(hand_to_hand, archery), listed(boot({range = "Judge's Bow"})))
    end)

    it('take nothing from the ammo', function()
        assert.same(of_skills(hand_to_hand), listed(boot({ammo = 'Bronze Bullet'})))
    end)

    it('follow the main hand when it changes', function()
        local game = Game.new({res = harness.resources(), main_job = 'WAR',
            items = {{name = "Judge's Sword"}, {name = 'Qutrub Knife'}}, wearing = {main = 1}})
        local bag_slot = assert(game:find_item('inventory', 'Qutrub Knife'))
        game.windower.packets.inject_outgoing(0x050,
            string.char(0x50, 4, 0, 0, bag_slot, Game.slot_ids.main, game:bag_id('inventory'), 0))
        game:settle()
        assert.same({main = 'Qutrub Knife'}, game:worn())
        assert.same(of_skills(dagger), listed(game))
    end)

    it('are those the boot names, whatever is in hand', function()
        local known = {['Savage Blade'] = true, ["Rudra's Storm"] = true}
        assert.same({"Rudra's Storm", 'Savage Blade'}, listed(boot({main = "Terra's Staff"}, known)))
        assert.same({"Rudra's Storm", 'Savage Blade'}, listed(boot({}, known)))
        assert.same(of_skills(staff), listed(boot({main = "Terra's Staff"})))
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
