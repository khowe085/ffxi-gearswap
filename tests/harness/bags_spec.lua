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

    it('tells the client with the packets Windower defines: a count of 0 for the old slot, the item for the new', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        move(gs, 1, 7, 0, 1)
        local old = parse(gs, 0x01E)
        local new = parse(gs, 0x020)
        assert.same({0, 7, 1}, {old['Count'], old['Bag'], old['Index']})
        assert.same({1, 23761, 0, 1}, {new['Count'], new['Item'], new['Bag'], new['Index']})
    end)
end)
