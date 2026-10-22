local Game = require('game')
local harness = require('harness')
local testy = require('testy')

local function parse(gs, id)
    local data = gs.game.last_packets.incoming[id][1]
    return gs.env.packets.parse('incoming', data)
end

-- Testy with only these items, and nothing on.
local function game_with(items)
    return harness.boot(testy.whm({items = items, wearing = {}}))
end

describe('the stand-in game\'s bags', function()
    it('count each bag\'s items and room in get_items, as Windower does', function()
        local game = Game.new({res = harness.resources(), items = {{name = 'Naegling'}, {name = 'Daybreak', bag = 'sack'}}})
        local items = game.windower.ffxi.get_items()
        assert.equal(1, items.count_inventory)
        assert.equal(1, items.count_sack)
        assert.equal(0, items.count_satchel)
        assert.equal(80, items.max_sack)
        assert.is_true(items.enabled_sack)
    end)

    it('count the items in a bag by those that are there, not by the last slot', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'safe'}, {name = 'Nyame Mail', bag = 'safe'}})
        gs.game.bags[1].items[1] = nil
        assert.equal(1, gs.game.windower.ffxi.get_bag_info('safe').count)
        assert.equal(1, gs.game.windower.ffxi.get_items('safe').count)
    end)

    it('say a bag that was closed is not enabled, and one that was not is', function()
        local gs = harness.boot(testy.whm())
        gs.game.bags[1].disabled = true
        assert.same({false, true}, {gs.game.windower.ffxi.get_bag_info('safe').enabled,
            gs.game.windower.ffxi.get_bag_info('case').enabled})
    end)

    it('take an item in the first empty slot of a bag, which is found again by name', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        assert.equal(2, gs.game:add_item('case', {name = 'Nyame Mail'}))
        assert.same({2, 'Nyame Mail'}, {gs.game:find_item('case', 'Nyame Mail'), gs.game:bag_names('case')[2]})
    end)
end)

describe('items moving between bags in the stand-in game', function()
    local function move(gs, count, from, to, index)
        local data = string.char(0x29, 6, 0, 0) .. ('I'):pack(count) .. string.char(from, to, index, 0x52)
        gs.game.windower.packets.inject_outgoing(0x29, data)
        gs:advance(0)
    end

    it('puts an item from a bag in the inventory, in the inventory\'s first empty slot', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}, {name = 'Nyame Mail'}})
        move(gs, 1, 7, 0, 1)
        assert.same({}, gs.game:bag_names('case'))
        assert.same({'Nyame Helm', 'Nyame Mail'}, gs.game:bag_names('inventory'))
        assert.equal('Nyame Helm', gs.game.res.items[gs.game.bags[0].items[2].id].en)
    end)

    it('puts an item from the inventory in another bag', function()
        local gs = game_with({{name = 'Nyame Helm'}})
        move(gs, 1, 0, 8, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('wardrobe'))
    end)

    it('takes nothing that is worn', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        gs.game.bags[7].items[1].status = 5
        move(gs, 1, 7, 0, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
    end)

    it('takes nothing from a slot with nothing in it', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        move(gs, 1, 7, 0, 2)
        assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
    end)

    it('takes nothing between two bags that are neither the inventory', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        move(gs, 1, 7, 6, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
    end)

    it('takes nothing into a bag that is full', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}, {name = 'Nyame Mail'}})
        gs.game.bags[0].max = 1
        move(gs, 1, 7, 0, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
    end)

    it('takes nothing from or into a bag that is closed', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        gs.game.bags[7].disabled = true
        move(gs, 1, 7, 0, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
    end)

    it('takes nothing when it is told to refuse', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        gs.game.refuse_moves = true
        move(gs, 1, 7, 0, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
    end)

    it('takes nothing from a Mog House bag away from the Mog House and a moogle', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'safe'}})
        move(gs, 1, 1, 0, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('safe'))
    end)

    it('takes from a Mog House bag in the Mog House', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'safe'}})
        gs.game:set_info({mog_house = true})
        move(gs, 1, 1, 0, 1)
        assert.same({}, gs.game:bag_names('safe'))
    end)

    it('takes from a Mog House bag once a moogle has been talked to, but not from the storage', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'safe'}, {name = 'Nyame Mail', bag = 'storage'}})
        local moogle = gs.game:add_mob({name = 'Nomad Moogle', distance = 2 ^ 2})
        local talk = string.char(0x1A, 8, 0, 0) .. ('I'):pack(moogle.id) .. ('H'):pack(moogle.index) .. ('H'):pack(0) .. ('H'):pack(0)
        gs.game.windower.packets.inject_outgoing(0x1A, talk)
        gs:advance(0)
        move(gs, 1, 1, 0, 1)
        move(gs, 1, 2, 0, 1)
        assert.same({}, gs.game:bag_names('safe'))
        assert.same({'Nyame Mail'}, gs.game:bag_names('storage'))
    end)

    it('moves as many of a stack as it is asked to, and leaves the rest', function()
        local gs = game_with({{name = 'Bronze Bullet', bag = 'case', count = 20}})
        move(gs, 5, 7, 0, 1)
        assert.same({5, 15}, {gs.game.bags[0].items[1].count, gs.game.bags[7].items[1].count})
        assert.same({15, 7, 1}, {parse(gs, 0x01E)['Count'], parse(gs, 0x01E)['Bag'], parse(gs, 0x01E)['Index']})
        assert.same({5, 0, 1}, {parse(gs, 0x020)['Count'], parse(gs, 0x020)['Bag'], parse(gs, 0x020)['Index']})
    end)

    it('moves part of a stack onto a stack of the same item, and leaves the rest', function()
        local gs = game_with({{name = 'Bronze Bullet', count = 20}, {name = 'Bronze Bullet', bag = 'case', count = 20}})
        move(gs, 5, 7, 0, 1)
        assert.same({'Bronze Bullet'}, gs.game:bag_names('inventory'))
        assert.same({25, 15}, {gs.game.bags[0].items[1].count, gs.game.bags[7].items[1].count})
        assert.same({25, 0, 1}, {parse(gs, 0x020)['Count'], parse(gs, 0x020)['Bag'], parse(gs, 0x020)['Index']})
    end)

    it('keeps a stack apart from one of the same item with other extdata', function()
        local gs = game_with({{name = 'Bronze Bullet', count = 20}})
        local extdata = string.char(1) .. string.char(0):rep(23)
        gs.game:add_item('case', {name = 'Bronze Bullet', count = 10, extdata = extdata})
        move(gs, 10, 7, 0, 1)
        assert.same({20, 10}, {gs.game.bags[0].items[1].count, gs.game.bags[0].items[2].count})
        assert.equal(string.char(1), gs.game.bags[0].items[2].extdata:sub(1, 1))
    end)

    it('tells the client a stack that is worn stays worn once more of the item joins it', function()
        local gs = harness.boot(testy.whm({items = {{name = 'Bronze Bullet', count = 20},
            {name = 'Bronze Bullet', bag = 'case', count = 10}}, wearing = {ammo = 'Bronze Bullet'}}))
        move(gs, 10, 7, 0, 1)
        assert.same({30, 5}, {parse(gs, 0x020)['Count'], parse(gs, 0x020)['Status']})
        assert.equal(5, gs.env.items.inventory[1].status)
    end)

    it('takes nothing when asked for more than the stack holds', function()
        local gs = game_with({{name = 'Bronze Bullet', bag = 'case', count = 20}})
        move(gs, 21, 7, 0, 1)
        assert.same({}, gs.game:bag_names('inventory'))
        assert.equal(20, gs.game.bags[7].items[1].count)
    end)

    it('puts what it moves on a stack of the same item with room for it, not in a slot of its own', function()
        local gs = game_with({{name = 'Bronze Bullet', count = 20}, {name = 'Bronze Bullet', bag = 'case', count = 10}})
        move(gs, 10, 7, 0, 1)
        assert.same({'Bronze Bullet'}, gs.game:bag_names('inventory'))
        assert.equal(30, gs.game.bags[0].items[1].count)
        assert.same({30, 0, 1}, {parse(gs, 0x020)['Count'], parse(gs, 0x020)['Bag'], parse(gs, 0x020)['Index']})
        assert.same({}, gs.game:bag_names('case'))
    end)

    it('puts what it moves in a slot of its own when the stack has no room for it', function()
        local gs = game_with({{name = 'Bronze Bullet', count = 95}, {name = 'Bronze Bullet', bag = 'case', count = 10}})
        move(gs, 10, 7, 0, 1)
        assert.same({95, 10}, {gs.game.bags[0].items[1].count, gs.game.bags[0].items[2].count})
    end)

    it('says a slot that filled with the add item event, and one that emptied with the remove item event', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}, {name = 'Bronze Bullet', count = 20},
            {name = 'Bronze Bullet', bag = 'case', count = 10}})
        local events = {}
        for _, event in ipairs({'add item', 'remove item'}) do
            gs.game:register(event, function(...) events[#events + 1] = {event, ...} end)
        end
        move(gs, 1, 7, 0, 1)
        move(gs, 10, 7, 0, 2)
        assert.same({{'remove item', 7, 1, 23761, 1}, {'add item', 0, 2, 23761, 1}, {'remove item', 7, 2, 17343, 10}},
            events)
    end)

    it('tells the client with the packets Windower defines: a count of 0 for the old slot, the item for the new', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        move(gs, 1, 7, 0, 1)
        local old = parse(gs, 0x01E)
        local new = parse(gs, 0x020)
        assert.same({0, 7, 1}, {old['Count'], old['Bag'], old['Index']})
        assert.same({1, 23761, 0, 1}, {new['Count'], new['Item'], new['Bag'], new['Index']})
    end)

    it('are moved by a session\'s move_item by name, the whole stack unless a count is given', function()
        local gs = game_with({{name = 'Bronze Bullet', bag = 'case', count = 10}, {name = 'Nyame Helm', bag = 'case'}})
        gs:move_item('Bronze Bullet', 'case', 'inventory', 4)
        gs:move_item('Nyame Helm', 'case', 'inventory')
        assert.same({'Bronze Bullet', 'Nyame Helm'}, gs.game:bag_names('inventory'))
        assert.same({4, 6}, {select(2, gs.game:find_item('inventory', 'Bronze Bullet')).count,
            select(2, gs.game:find_item('case', 'Bronze Bullet')).count})
        gs:move_item('Bronze Bullet', 'case', 'inventory')
        assert.equal(10, select(2, gs.game:find_item('inventory', 'Bronze Bullet')).count)
        assert.same({}, gs.game:bag_names('case'))
    end)
end)
