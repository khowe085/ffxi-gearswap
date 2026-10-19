local plain = require('plain')

local fast_cast = {head = "Bunzi's Hat", left_ring = 'Kishar Ring'}

local function boot()
    local gs = plain.boot()
    gs:traffic()
    return gs
end

local function refuse_equips(gs)
    gs.game.equip_chunk = function() return nil end
end

describe('an equip request the server doesn\'t answer', function()
    it('is taken as worn for a while, and the piece is not sent again', function()
        local gs = boot()
        refuse_equips(gs)
        gs:console('gs equip sets.precast.FastCast')
        assert.same({{equip = fast_cast}}, gs:traffic())
        gs:advance(1)
        gs:console('gs equip sets.precast.FastCast')
        assert.same({}, gs:traffic())
    end)

    it('is taken as worn in what the user file sees of the gear', function()
        local gs = boot()
        refuse_equips(gs)
        gs:console('gs equip sets.precast.FastCast')
        gs:console('gs c anything')
        assert.equal("Bunzi's Hat", gs.user.player.equipment.head)
    end)

    it('is dropped after three seconds, and the piece is sent again', function()
        local gs = boot()
        refuse_equips(gs)
        gs:console('gs equip sets.precast.FastCast')
        gs:traffic()
        gs:advance(3.1)
        gs:console('gs equip sets.precast.FastCast')
        assert.same({{equip = fast_cast}}, gs:traffic())
    end)

    it('is dropped from what the user file sees of the gear too', function()
        local gs = boot()
        refuse_equips(gs)
        gs:console('gs equip sets.precast.FastCast')
        gs:advance(3.1)
        gs:console('gs c anything')
        assert.equal('Nyame Helm', gs.user.player.equipment.head)
    end)

    it('is dropped slot by slot: another slot\'s request, newer, is kept', function()
        local gs = boot()
        refuse_equips(gs)
        gs:console('gs equip sets.precast.FastCast')
        gs:advance(2)
        gs:console('gs equip sets.engaged')
        gs:traffic()
        gs:advance(1.5)
        gs:console('gs equip sets.precast.FastCast')
        assert.same({{equip = fast_cast}}, gs:traffic())
    end)
end)

describe('an equip request the server answers', function()
    it('is taken off the list of those waiting, so the piece is worn as the game says', function()
        local gs = boot()
        gs:console('gs equip sets.precast.FastCast')
        assert.equal(0, gs.env.injected_equipment_registry[4].n)
        assert.same({bag_id = 0, slot = gs.game.equipment[4].slot}, gs.env.items.equipment.head)
    end)

    it('lets a piece be sent again for a slot once another piece has been, as the game says it is worn', function()
        local gs = boot()
        local mark = #gs.game.sent
        gs:console('gs equip sets.precast.FastCast')
        gs:console('gs equip sets.midcast.Cure')
        gs:console('gs equip sets.precast.FastCast')
        local head_requests = 0
        for i = mark + 1, #gs.game.sent do
            local packet = gs.game.sent[i]
            if packet.id == 0x050 and packet.data:byte(6) == 4 then
                head_requests = head_requests + 1
            end
        end
        assert.equal(3, head_requests)
        assert.equal("Bunzi's Hat", gs:worn().head)
    end)
end)

describe('a piece the player puts on by hand', function()
    it('is counted as worn from the request the game sends, before the server answers', function()
        local gs = boot()
        gs.game:add_item('inventory', {name = "Bunzi's Hat"})
        local slot = gs.game:find_item('inventory', "Bunzi's Hat")
        gs:send(0x020, {['Count'] = 1, ['Item'] = 23760, ['Bag'] = 0, ['Index'] = slot})
        gs:send_from_client(0x050, string.char(slot, 4, 0, 0))
        gs:console('gs c anything')
        assert.equal("Bunzi's Hat", gs.user.player.equipment.head)
    end)

    it('is not sent again by a set that names it', function()
        local gs = boot()
        gs.game:add_item('inventory', {name = "Bunzi's Hat"})
        local slot = gs.game:find_item('inventory', "Bunzi's Hat")
        gs:send(0x020, {['Count'] = 1, ['Item'] = 23760, ['Bag'] = 0, ['Index'] = slot})
        gs:send_from_client(0x050, string.char(slot, 4, 0, 0))
        gs:console('gs equip sets.precast.FastCast')
        assert.same({{equip = {left_ring = 'Kishar Ring'}}}, gs:traffic())
    end)

    it('is counted as worn from an equipment set the game sends too', function()
        local gs = boot()
        gs.game:add_item('inventory', {name = "Bunzi's Hat"})
        local slot = gs.game:find_item('inventory', "Bunzi's Hat")
        gs:send(0x020, {['Count'] = 1, ['Item'] = 23760, ['Bag'] = 0, ['Index'] = slot})
        gs:send_from_client(0x051, string.char(1, 0, 0, 0) .. string.char(slot, 4, 0, 0))
        gs:console('gs equip sets.precast.FastCast')
        assert.same({{equip = {left_ring = 'Kishar Ring'}}}, gs:traffic())
    end)
end)
