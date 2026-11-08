local Game = require('game')
local plain = require('plain')

-- Testy on the plain user file Testy_WHM.lua with only these items, then switched to Testy_Equip.lua, whose sets
-- the tests put on with gs equip.
local function boot(items, wearing)
    return plain.boot('Testy_Equip.lua', {items = items, wearing = wearing or {}})
end

local function equip(gs, set)
    gs:console('gs equip sets.' .. set)
    assert.is_nil(gs:log():find('That set does not exist', 1, true), 'GearSwap has no set sets.' .. set)
end

-- The bag and the place in it of the copy worn in a slot.
local function worn_copy(gs, slot)
    local spot = assert(gs.game.equipment[Game.slot_ids[slot]], slot .. ' is empty')
    return {bag = gs.game.bags[spot.bag].api, slot = spot.slot}
end

-- The slots GearSwap asked for, in the order it sent them.
local function slots_in_sent_order(gs, set)
    local before = #gs.game.sent
    equip(gs, set)
    local order = {}
    for i = before + 1, #gs.game.sent do
        local packet = gs.game.sent[i]
        if packet.id == 0x050 then
            order[#order + 1] = Game.slot_names[packet.data:byte(6)]
        elseif packet.id == 0x051 then
            for n = 1, packet.data:byte(5) do
                order[#order + 1] = Game.slot_names[packet.data:byte(6 + 4 * n)]
            end
        end
    end
    return order
end

local cure_cape = {'MND+20', 'Mag. Acc+20 /Mag. Dmg.+20', '"Cure" potency +10%', 'Phys. dmg. taken-10%'}
local enmity_cape = {'MND+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Enmity+10', 'Phys. dmg. taken-10%'}

describe('a piece named in a set', function()
    local items = {{name = 'Loquac. Earring'}, {name = 'Plat. Mog. Belt'}}
    local on = {right_ear = 'Loquac. Earring', waist = 'Plat. Mog. Belt'}

    it('goes on by its short name', function()
        local gs = boot(items)
        equip(gs, 'short_names')
        assert.same(on, gs:worn())
        assert.same({{equip = on}}, gs:traffic())
    end)

    it('goes on by its long name', function()
        local gs = boot(items)
        equip(gs, 'log_names')
        assert.same(on, gs:worn())
        assert.same({{equip = on}}, gs:traffic())
    end)

    it('goes on by its short name in lower case', function()
        local gs = boot(items)
        equip(gs, 'short_names_lower_case')
        assert.same(on, gs:worn())
    end)

    it('goes on by its long name in upper case', function()
        local gs = boot(items)
        equip(gs, 'log_names_upper_case')
        assert.same(on, gs:worn())
    end)
end)

describe('a piece named in a set with augments', function()
    it('is the copy that has them, when two copies are owned', function()
        local gs = boot({{name = "Alaunus's Cape", augments = cure_cape}, {name = "Alaunus's Cape", augments = enmity_cape}})
        equip(gs, 'cure_cape')
        assert.same({bag = 'inventory', slot = 1}, worn_copy(gs, 'back'))
    end)

    it('is the second copy when only that one has them', function()
        local gs = boot({{name = "Alaunus's Cape", augments = cure_cape}, {name = "Alaunus's Cape", augments = enmity_cape}})
        equip(gs, 'enmity_cape')
        assert.same({bag = 'inventory', slot = 2}, worn_copy(gs, 'back'))
    end)

    it('takes the place of a worn copy that lacks them', function()
        local gs = boot({{name = "Alaunus's Cape", augments = cure_cape}, {name = "Alaunus's Cape", augments = enmity_cape}},
            {back = "Alaunus's Cape"})
        equip(gs, 'enmity_cape')
        assert.same({bag = 'inventory', slot = 2}, worn_copy(gs, 'back'))
        assert.same({{equip = {back = "Alaunus's Cape"}}}, gs:traffic())
    end)

    it('is left on when the worn copy has them', function()
        local gs = boot({{name = "Alaunus's Cape", augments = enmity_cape}, {name = "Alaunus's Cape", augments = cure_cape}},
            {back = "Alaunus's Cape"})
        equip(gs, 'enmity_cape')
        assert.same({bag = 'inventory', slot = 1}, worn_copy(gs, 'back'))
        assert.same({}, gs:traffic())
    end)

    it('isn\'t worn when the only copy has other augments', function()
        local gs = boot({{name = "Alaunus's Cape", augments = cure_cape}})
        equip(gs, 'enmity_cape')
        assert.same({}, gs:worn())
        assert.same({}, gs:traffic())
    end)

    it('leaves a worn copy that lacks them on when it is the only one', function()
        local gs = boot({{name = "Alaunus's Cape", augments = cure_cape}}, {back = "Alaunus's Cape"})
        equip(gs, 'enmity_cape')
        assert.same({back = "Alaunus's Cape"}, gs:worn())
        assert.same({}, gs:traffic())
    end)

    it('goes on anyway when it is Rare and the augments differ', function()
        local gs = boot({{name = 'Kishar Ring', augments = {'Enmity+10'}}})
        equip(gs, 'rare_ring_with_other_augments')
        assert.same({left_ring = 'Kishar Ring'}, gs:worn())
    end)

    it('goes on from the first copy when the set names no augments', function()
        local gs = boot({{name = "Alaunus's Cape", augments = enmity_cape}, {name = "Alaunus's Cape", augments = cure_cape}})
        equip(gs, 'cape_by_name')
        assert.same({bag = 'inventory', slot = 1}, worn_copy(gs, 'back'))
    end)
end)

describe('a piece named in a set with a bag', function()
    local copies = {{name = 'Nyame Helm'}, {name = 'Nyame Helm', bag = 'wardrobe2'}}

    it('is the copy in that bag', function()
        local gs = boot(copies)
        equip(gs, 'helm_from_wardrobe2')
        assert.same({bag = 'wardrobe2', slot = 1}, worn_copy(gs, 'head'))
    end)

    it('is the first copy found when the set names no bag', function()
        local gs = boot(copies)
        equip(gs, 'helm_by_name')
        assert.same({bag = 'inventory', slot = 1}, worn_copy(gs, 'head'))
    end)

    it('takes the place of a worn copy in another bag', function()
        local gs = boot(copies, {head = 'Nyame Helm'})
        equip(gs, 'helm_from_wardrobe2')
        assert.same({bag = 'wardrobe2', slot = 1}, worn_copy(gs, 'head'))
        assert.same({{equip = {head = 'Nyame Helm'}}}, gs:traffic())
    end)

    it('isn\'t worn when no copy is in that bag', function()
        local gs = boot(copies)
        equip(gs, 'helm_from_wardrobe')
        assert.same({}, gs:worn())
        assert.same({}, gs:traffic())
    end)
end)

describe('a slot in a set', function()
    local items = {{name = 'Nyame Helm'}, {name = 'Loricate Torque +1'}}
    local worn = {head = 'Nyame Helm', neck = 'Loricate Torque +1'}

    it('set to empty takes off what is worn there', function()
        local gs = boot(items, worn)
        equip(gs, 'no_head')
        assert.same({neck = 'Loricate Torque +1'}, gs:worn())
        assert.same({{equip = {head = 'empty'}}}, gs:traffic())
    end)

    it('set to empty sends nothing when nothing is worn there', function()
        local gs = boot(items, {neck = 'Loricate Torque +1'})
        equip(gs, 'no_head')
        assert.same({neck = 'Loricate Torque +1'}, gs:worn())
        assert.same({}, gs:traffic())
    end)

    it('that the set leaves out stays as it is', function()
        local gs = boot(items, worn)
        equip(gs, 'neck_only')
        assert.same(worn, gs:worn())
        assert.same({}, gs:traffic())
    end)

    it('that the set leaves out stays empty', function()
        local gs = boot(items)
        equip(gs, 'neck_only')
        assert.same({neck = 'Loricate Torque +1'}, gs:worn())
    end)
end)

describe('the slot names in a set', function()
    it('ear1 and ear2 are the left and right ears', function()
        local items = {{name = 'Etiolation Earring'}, {name = 'Loquac. Earring'}}
        local on = {left_ear = 'Etiolation Earring', right_ear = 'Loquac. Earring'}
        local gs = boot(items)
        equip(gs, 'ears_numbered')
        assert.same(on, gs:worn())
        gs = boot(items)
        equip(gs, 'ears_named')
        assert.same(on, gs:worn())
    end)

    it('ring1 and ring2 are the left and right rings', function()
        local items = {{name = 'Defending Ring'}, {name = 'Kishar Ring'}}
        local on = {left_ring = 'Defending Ring', right_ring = 'Kishar Ring'}
        local gs = boot(items)
        equip(gs, 'rings_numbered')
        assert.same(on, gs:worn())
        gs = boot(items)
        equip(gs, 'rings_named')
        assert.same(on, gs:worn())
    end)

    it('range is ranged', function()
        local items = {{name = "Judge's Bow"}}
        local gs = boot(items)
        equip(gs, 'range_short')
        assert.same({range = "Judge's Bow"}, gs:worn())
        gs = boot(items)
        equip(gs, 'range_long')
        assert.same({range = "Judge's Bow"}, gs:worn())
    end)
end)

describe('set_combine', function()
    local items = {{name = 'Nyame Helm'}, {name = "Bunzi's Hat"}, {name = 'Kaykaus Mitra +1'}, {name = 'Nyame Mail'},
        {name = 'Loricate Torque +1'}, {name = 'Plat. Mog. Belt'}}

    it('gives the set its own pieces, and a later set\'s where it names the same slot', function()
        local gs = boot(items)
        equip(gs, 'combined')
        assert.same({head = "Bunzi's Hat", body = 'Nyame Mail', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt'}, gs:worn())
    end)

    it('lets the last of three sets win a slot they all name', function()
        local gs = boot(items)
        equip(gs, 'combined_three')
        assert.same({head = 'Kaykaus Mitra +1', body = 'Nyame Mail', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt'}, gs:worn())
    end)

    it('leaves the sets it combined as they were', function()
        local gs = boot(items)
        local sets = gs.env.user_env.sets
        assert.same({head = 'Nyame Helm', body = 'Nyame Mail', neck = 'Loricate Torque +1'}, sets.base)
        assert.same({head = "Bunzi's Hat", waist = 'Plat. Mog. Belt'}, sets.overrides)
        assert.same({head = 'Kaykaus Mitra +1'}, sets.last_override)
    end)

    it('makes a set of its own, which changes none of them when it is put on', function()
        local gs = boot(items)
        local sets = gs.env.user_env.sets
        equip(gs, 'combined_three')
        assert.is_not.equal(sets.base, sets.combined)
        assert.same({head = 'Nyame Helm', body = 'Nyame Mail', neck = 'Loricate Torque +1'}, sets.base)
        assert.same({head = "Bunzi's Hat", waist = 'Plat. Mog. Belt'}, sets.overrides)
        assert.same({head = 'Kaykaus Mitra +1'}, sets.last_override)
    end)
end)

describe('two copies of a ring', function()
    local ring = 'Stikini Ring +1'

    it('go on as two different copies when the set names the ring twice', function()
        local gs = boot({{name = ring}, {name = ring, bag = 'wardrobe'}})
        equip(gs, 'stikini_twice')
        assert.same({left_ring = ring, right_ring = ring}, gs:worn())
        assert.same({bag = 'inventory', slot = 1}, worn_copy(gs, 'left_ring'))
        assert.same({bag = 'wardrobe', slot = 1}, worn_copy(gs, 'right_ring'))
    end)

    it('put the second on beside the first when one is worn already', function()
        local gs = boot({{name = ring}, {name = ring, bag = 'wardrobe'}}, {left_ring = ring})
        equip(gs, 'stikini_twice')
        assert.same({left_ring = ring, right_ring = ring}, gs:worn())
        assert.same({bag = 'inventory', slot = 1}, worn_copy(gs, 'left_ring'))
        assert.same({bag = 'wardrobe', slot = 1}, worn_copy(gs, 'right_ring'))
        assert.same({{equip = {right_ring = ring}}}, gs:traffic())
    end)
end)

describe('one copy of a ring', function()
    local ring = 'Stikini Ring +1'

    it('goes on one ring slot when the set names the ring twice', function()
        local gs = boot({{name = ring}})
        equip(gs, 'stikini_twice')
        assert.same({left_ring = ring}, gs:worn())
    end)

    it('stays where it is when the set names the ring twice', function()
        local gs = boot({{name = ring}}, {right_ring = ring})
        equip(gs, 'stikini_twice')
        assert.same({right_ring = ring}, gs:worn())
        assert.same({}, gs:traffic())
    end)

    pending('stays where it is when the set names the ring twice and another piece is found before it: GearSwap '
        .. 'sends it to the other ring slot and leaves its own empty, the right ring for one worn in the left and the '
        .. 'left for one worn in the right (unpack_equip_list reassigns used_list)')
end)

describe('a piece GearSwap can\'t put on', function()
    it('because it isn\'t owned leaves the slot as it was', function()
        local gs = boot({{name = 'Nyame Helm'}}, {head = 'Nyame Helm'})
        equip(gs, 'mitra')
        assert.same({head = 'Nyame Helm'}, gs:worn())
        assert.same({}, gs:traffic())
    end)

    it('because the job can\'t wear it leaves the slot as it was', function()
        local gs = boot({{name = 'Daybreak'}, {name = 'Naegling'}}, {main = 'Daybreak'})
        equip(gs, 'naegling')
        assert.same({main = 'Daybreak'}, gs:worn())
        assert.same({}, gs:traffic())
    end)

    pending('because the job can\'t wear it, debug mode says why: unpack_equip_list matches the name against '
        .. 'item_id, which nothing sets, instead of item_tab.id, so no reason reaches the error list and the piece is '
        .. 'only listed among the gear not equipped; with item_tab.id there, the same loop would hand name_match the '
        .. 'nil name of each slot the set leaves out, which raises an error')

    it('because it is only in the safe leaves the slot as it was', function()
        local gs = boot({{name = 'Nyame Helm'}, {name = 'Kaykaus Mitra +1', bag = 'safe'}}, {head = 'Nyame Helm'})
        equip(gs, 'mitra')
        assert.same({head = 'Nyame Helm'}, gs:worn())
        assert.same({}, gs:traffic())
    end)

    it('because the set names the safe for a copy that is in the safe leaves the slot empty', function()
        local gs = boot({{name = 'Nyame Helm', bag = 'safe'}})
        equip(gs, 'helm_from_safe')
        assert.same({}, gs:worn())
        assert.same({}, gs:traffic())
    end)

    it('because the set names the safe for a copy that is in the inventory leaves the slot empty', function()
        local gs = boot({{name = 'Nyame Helm'}})
        equip(gs, 'helm_from_safe')
        assert.same({}, gs:worn())
        assert.same({}, gs:traffic())
    end)

    it('doesn\'t stop the other pieces in the set going on', function()
        local gs = boot({{name = 'Nyame Mail'}, {name = 'Nyame Helm', bag = 'safe'}})
        equip(gs, 'wardrobe_and_inventory')
        assert.same({body = 'Nyame Mail'}, gs:worn())
        assert.same({{equip = {body = 'Nyame Mail'}}}, gs:traffic())
    end)
end)

describe('a piece in a wardrobe', function()
    it('goes on like one in the inventory', function()
        local gs = boot({{name = 'Nyame Helm', bag = 'wardrobe'}, {name = 'Nyame Mail'}})
        equip(gs, 'wardrobe_and_inventory')
        assert.same({head = 'Nyame Helm', body = 'Nyame Mail'}, gs:worn())
        assert.same({{equip = {head = 'Nyame Helm', body = 'Nyame Mail'}}}, gs:traffic())
        assert.same({bag = 'wardrobe', slot = 1}, worn_copy(gs, 'head'))
    end)

    it('goes on from the second wardrobe the same way', function()
        local gs = boot({{name = 'Nyame Helm', bag = 'wardrobe2'}})
        equip(gs, 'helm_by_name')
        assert.same({head = 'Nyame Helm'}, gs:worn())
        assert.same({bag = 'wardrobe2', slot = 1}, worn_copy(gs, 'head'))
    end)
end)

describe('a set that gives priorities', function()
    local items = {{name = 'Nyame Helm'}, {name = 'Nyame Mail'}, {name = 'Nyame Gauntlets'},
        {name = 'Nyame Flanchard'}, {name = 'Nyame Sollerets'}}

    it('has its pieces sent highest priority first, whatever the slot', function()
        local gs = boot(items)
        assert.same({'body', 'head', 'hands', 'legs'}, slots_in_sent_order(gs, 'prioritized'))
    end)

    it('has its pieces sent highest priority first when there are too few for one request', function()
        local gs = boot(items)
        assert.same({'feet', 'head'}, slots_in_sent_order(gs, 'prioritized_pair'))
    end)

    it('has pieces with no priority sent in the order of the slots', function()
        local gs = boot(items)
        assert.same({'head', 'body', 'hands'}, slots_in_sent_order(gs, 'unprioritized'))
    end)

    it('still puts every piece on', function()
        local gs = boot(items)
        equip(gs, 'prioritized')
        assert.same({head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard'}, gs:worn())
    end)
end)
