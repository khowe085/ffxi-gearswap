local plain = require('plain')
local world = require('world')

local function item_update(gs, fields)
    world.send(gs, 0x020, fields)
end

describe('the item packets', function()
    it('an item update (0x020) puts the item in its slot of the bag, with its count, bazaar price, status and extdata', function()
        local gs = plain.boot()
        local extdata = ('\1'):rep(24)
        item_update(gs, {['Count'] = 3, ['Bazaar'] = 500, ['Item'] = 26184, ['Bag'] = 0, ['Index'] = 70, ['Status'] = 0, ['ExtData'] = extdata})
        local item = gs.env.items.inventory[70]
        assert.same({26184, 3, 500, 0, extdata, 70}, {item.id, item.count, item.bazaar, item.status, item.extdata, item.slot})
    end)

    it('an item update reaches the bag it names, by the bag\'s name without its spaces', function()
        local gs = plain.boot()
        item_update(gs, {['Count'] = 1, ['Item'] = 23761, ['Bag'] = 10, ['Index'] = 4})
        assert.equal(23761, gs.env.items.wardrobe2[4].id)
        assert.not_equal(23761, gs.env.items.wardrobe[4].id)
    end)

    it('an item update marks the item worn when its status is 5', function()
        local gs = plain.boot()
        item_update(gs, {['Count'] = 1, ['Item'] = 23761, ['Bag'] = 0, ['Index'] = 71, ['Status'] = 5})
        assert.equal(5, gs.env.items.inventory[71].status)
    end)

    it('an item assignment (0x01F) gives a slot its item, count and status', function()
        local gs = plain.boot()
        world.send(gs, 0x01F, {['Count'] = 2, ['Item'] = 26188, ['Bag'] = 8, ['Index'] = 9, ['Status'] = 0})
        local item = gs.env.items.wardrobe[9]
        assert.same({26188, 2, 0}, {item.id, item.count, item.status})
    end)

    it('an item count (0x01E) changes the count and status of the item in a slot', function()
        local gs = plain.boot()
        item_update(gs, {['Count'] = 3, ['Item'] = 26184, ['Bag'] = 0, ['Index'] = 70})
        world.send(gs, 0x01E, {['Count'] = 5, ['Bag'] = 0, ['Index'] = 70, ['Status'] = 5})
        local item = gs.env.items.inventory[70]
        assert.same({26184, 5, 5}, {item.id, item.count, item.status})
    end)

    it('a count of 0 empties the slot', function()
        local gs = plain.boot()
        item_update(gs, {['Count'] = 1, ['Bazaar'] = 100, ['Item'] = 26184, ['Bag'] = 0, ['Index'] = 70, ['Status'] = 5})
        world.send(gs, 0x01E, {['Count'] = 0, ['Bag'] = 0, ['Index'] = 70, ['Status'] = 5})
        local item = gs.env.items.inventory[70]
        assert.same({0, 0, 0, 0}, {item.id, item.count, item.bazaar, item.status})
    end)

    it('a count for a slot GearSwap has no table for makes the table', function()
        local gs = plain.boot()
        gs.env.items.inventory[75] = nil
        world.send(gs, 0x01E, {['Count'] = 2, ['Bag'] = 0, ['Index'] = 75, ['Status'] = 0})
        assert.equal(2, gs.env.items.inventory[75].count)
        assert.equal(75, gs.env.items.inventory[75].slot)
    end)

    it('shows in player.inventory by the item\'s short and long names', function()
        local gs = plain.boot()
        item_update(gs, {['Count'] = 1, ['Item'] = 26366, ['Bag'] = 0, ['Index'] = 70})
        gs:console('gs c refresh')
        local inventory = gs.user.player.inventory
        assert.equal(26366, inventory['Plat. Mog. Belt'].id)
        assert.equal(inventory['Plat. Mog. Belt'], inventory['Platinum Moogle Belt'])
        assert.equal('platinum moogle belt', inventory['Plat. Mog. Belt'].longname)
    end)

    it('adds the counts of the stacks of one item in player.inventory', function()
        local gs = plain.boot()
        local owned = 1
        item_update(gs, {['Count'] = 1, ['Item'] = 26366, ['Bag'] = 0, ['Index'] = 70})
        item_update(gs, {['Count'] = 4, ['Item'] = 26366, ['Bag'] = 0, ['Index'] = 71})
        gs:console('gs c refresh')
        assert.equal(owned + 1 + 4, gs.user.player.inventory['Plat. Mog. Belt'].count)
    end)

    it('shows in the list of the bag it is in, and not in another', function()
        local gs = plain.boot()
        item_update(gs, {['Count'] = 1, ['Item'] = 26366, ['Bag'] = 10, ['Index'] = 3})
        gs:console('gs c refresh')
        assert.is_not_nil(gs.user.player.wardrobe2['Plat. Mog. Belt'])
        assert.is_nil(gs.user.player.wardrobe['Plat. Mog. Belt'])
    end)

    it('a zone-out packet (0x00B) blanks the temporary bag', function()
        local gs = plain.boot()
        item_update(gs, {['Count'] = 1, ['Item'] = 26366, ['Bag'] = 3, ['Index'] = 2})
        assert.equal(26366, gs.env.items.temporary[2].id)
        world.send(gs, 0x00B, {})
        assert.equal(0, gs.env.items.temporary[2].id)
    end)
end)

describe('a piece the server says can\'t be put on right now', function()
    local function boot_with_status(status)
        local gs = plain.boot()
        gs.game:add_item('inventory', {name = "Bunzi's Hat"})
        local slot = gs.game:find_item('inventory', "Bunzi's Hat")
        item_update(gs, {['Count'] = 1, ['Item'] = 23760, ['Bag'] = 0, ['Index'] = slot, ['Status'] = status})
        gs:console('gs debugmode')
        plain.chat(gs)
        return gs
    end

    it('because it is in a bazaar is not put on, and debug mode says so', function()
        local gs = boot_with_status(25)
        gs:console('gs equip sets.precast.FastCast')
        local text = table.concat(plain.texts(plain.chat(gs)), '\n')
        assert.is_truthy(text:find('Debug Mode (error list)', 1, true))
        assert.is_truthy(text:find("head Bunzi's Hat (bazaared)", 1, true))
        assert.equal('Nyame Helm', gs:worn().head)
    end)

    it('for another reason is not put on, and debug mode says the status', function()
        local gs = boot_with_status(7)
        gs:console('gs equip sets.precast.FastCast')
        assert.is_truthy(table.concat(plain.texts(plain.chat(gs)), '\n'):find("head Bunzi's Hat (status unknown: 7 )", 1, true))
        assert.equal('Nyame Helm', gs:worn().head)
    end)

    it('is put on when its status is that of a piece in the bag, 0', function()
        local gs = boot_with_status(0)
        gs:console('gs equip sets.precast.FastCast')
        assert.equal("Bunzi's Hat", gs:worn().head)
    end)
end)

describe('the equip packets from the game itself', function()
    it('an equipment change the game made (0x050) is taken as worn, and the item as equipped', function()
        local gs = plain.boot()
        gs.game:add_item('inventory', {name = "Bunzi's Hat"})
        local slot = gs.game:find_item('inventory', "Bunzi's Hat")
        item_update(gs, {['Count'] = 1, ['Item'] = 23760, ['Bag'] = 0, ['Index'] = slot})
        world.send_raw(gs, 0x050, string.char(slot, 4, 0, 0))
        assert.same({bag_id = 0, slot = slot}, gs.env.items.equipment.head)
        assert.equal(5, gs.env.items.inventory[slot].status)
    end)

    it('an unequip the game made takes the item out of the slot and marks it unequipped', function()
        local gs = plain.boot()
        local before = gs.env.items.equipment.head
        world.send_raw(gs, 0x050, string.char(0, 4, 0, 0))
        assert.is_true(gs.env.items.equipment.head.slot == gs.env.empty)
        assert.equal(0, gs.env.items[gs.game.bags[before.bag_id].api][before.slot].status)
    end)

    it('an equipment list from the game (0x117) says what is worn in each slot', function()
        local gs = plain.boot()
        gs.game:add_item('inventory', {name = "Bunzi's Hat"})
        local slot = gs.game:find_item('inventory', "Bunzi's Hat")
        item_update(gs, {['Count'] = 1, ['Item'] = 23760, ['Bag'] = 0, ['Index'] = slot})
        local body = string.char(0, 0, 0, 0):rep(1) .. ('\0'):rep(0x44 - 4)
        for id = 0, 15 do
            body = body .. (id == 4 and string.char(slot, 4, 0, 0) or string.char(0, id, 0, 0))
        end
        world.send_raw(gs, 0x117, body)
        assert.same({bag_id = 0, slot = slot}, gs.env.items.equipment.head)
        assert.is_true(gs.env.items.equipment.body.slot == gs.env.empty)
    end)
end)
