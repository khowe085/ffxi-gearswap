local plain = require('plain')
local testy = require('testy')

-- Testy as a white mage owning what Testy_WHM.lua names except the pieces left out, and the extra pieces.
local function boot(left_out, extra)
    local items = {}
    for _, item in ipairs(testy.whm().items) do
        if not (left_out or {})[item.name] then
            items[#items + 1] = item
        end
    end
    for _, item in ipairs(extra or {}) do
        items[#items + 1] = item
    end
    return plain.boot('Testy_WHM.lua', {items = items})
end

local function validate(gs, text)
    gs:console('gs validate' .. (text and ' ' .. text or ''))
    return gs:chat()
end

describe('gs validate', function()
    it('lists the items the sets name that the character doesn\'t have, and counts them', function()
        local gs = boot({['Kishar Ring'] = true, ['Kaykaus Mitra +1'] = true})
        assert.same({
            'GearSwap: Checking for items in gear sets that are not in your inventory.',
            'Kaykaus mitra +1',
            'Kishar ring',
            'GearSwap: Final count = 2',
        }, validate(gs))
    end)

    it('lists nothing when the character has every item the sets name', function()
        local gs = boot()
        assert.same({
            'GearSwap: Checking for items in gear sets that are not in your inventory.',
            'GearSwap: Final count = 0',
        }, validate(gs))
    end)

    it('is the same as gs validate sets, and gs validate set and gs validate s', function()
        local gs = boot({['Kishar Ring'] = true})
        local expected = validate(gs)
        assert.same(expected, validate(gs, 'sets'))
        assert.same(expected, validate(gs, 'set'))
        assert.same(expected, validate(gs, 's'))
    end)

    it('shows each missing item in the color for such lines', function()
        local gs = boot({['Kishar Ring'] = true})
        gs:console('gs validate')
        local lines = gs:chat_lines()
        assert.same({123, 120, 123}, {lines[1].color, lines[2].color, lines[3].color})
    end)

    it('counts an item in any equippable bag as owned, the wardrobes included', function()
        local gs = boot({['Kishar Ring'] = true}, {{name = 'Kishar Ring', bag = 'wardrobe3'}})
        assert.same({'GearSwap: Checking for items in gear sets that are not in your inventory.', 'GearSwap: Final count = 0'},
            validate(gs))
    end)

    it('doesn\'t count an item in a bag that gear can\'t be worn from', function()
        local gs = boot({['Kishar Ring'] = true}, {{name = 'Kishar Ring', bag = 'safe'}})
        assert.same('Kishar ring', validate(gs)[2])
    end)

    it('takes a word to look for among the items it lists', function()
        local gs = boot({['Kishar Ring'] = true, ['Kaykaus Mitra +1'] = true})
        assert.same({
            'GearSwap: Checking for items in gear sets that are not in your inventory.',
            'Kishar ring',
            'GearSwap: Final count = 1',
        }, validate(gs, 'kishar'))
    end)

    it('takes a word with a - in front to leave out the items that have it', function()
        local gs = boot({['Kishar Ring'] = true, ['Kaykaus Mitra +1'] = true})
        assert.same({
            'GearSwap: Checking for items in gear sets that are not in your inventory.',
            'Kaykaus mitra +1',
            'GearSwap: Final count = 1',
        }, validate(gs, 'sets -kishar'))
    end)

    pending('takes a word to look for and a word to leave out in either order, and lists only what has the one and '
        .. 'not the other: tryfilter in validate.lua sets pass to false at the first word with a - and never back, so '
        .. 'a word to look for after it leaves out what it finds, and its last line, return not pass, lets through an '
        .. 'item that has none of the words once any word has a -. With Kishar Ring, Kaykaus Mitra +1 and Nyame Helm '
        .. 'missing, gs validate kishar -mitra lists Kishar Ring and Nyame Helm, and gs validate -mitra kishar lists '
        .. 'Nyame Helm alone')

    it('says there is nothing to validate when no file is loaded', function()
        local gs = plain.boot_without_a_file()
        assert.same({'GearSwap: There is nothing to validate because there is no file loaded.'}, validate(gs))
    end)

    describe('of a bag', function()
        local extra = {{name = 'Naegling'}, {name = 'Remedy'}, {name = "Sucellos's Cape", bag = 'wardrobe'}}

        it('lists the items in it that no set names', function()
            local gs = boot(nil, extra)
            assert.same({
                'GearSwap: Checking for items in inventory that are not used in your gear sets.',
                'Naegling',
                'Remedy',
                'GearSwap: Final count = 2',
            }, validate(gs, 'inventory'))
        end)

        it('is gs validate inv, and gs validate i', function()
            local gs = boot(nil, extra)
            local expected = validate(gs, 'inventory')
            assert.same(expected, validate(gs, 'inv'))
            assert.same(expected, validate(gs, 'i'))
        end)

        it('names the bag it looks in, by any of its names', function()
            local gs = boot(nil, extra)
            assert.same({'GearSwap: Checking for items in wardrobe that are not used in your gear sets.', "Sucellos's Cape",
                'GearSwap: Final count = 1'}, validate(gs, 'wardrobe'))
            assert.same(validate(gs, 'wardrobe'), validate(gs, 'w'))
        end)

        it('has an alias for each bag: bank for the safe, ms2 for the second safe, ml for the locker', function()
            local gs = boot(nil, extra)
            for alias, bag in pairs({bank = 'safe', ms2 = 'safe2', ml = 'locker', sa = 'satchel', sk = 'sack', c = 'case',
                st = 'storage', w2 = 'wardrobe2', w8 = 'wardrobe8'}) do
                assert.equal('GearSwap: Checking for items in ' .. bag .. ' that are not used in your gear sets.',
                    validate(gs, alias)[1], alias)
            end
        end)

        it('takes a word to look for, and a word to leave out', function()
            local gs = boot(nil, extra)
            assert.same({'GearSwap: Checking for items in inventory that are not used in your gear sets.', 'Remedy',
                'GearSwap: Final count = 1'}, validate(gs, 'inventory remedy'))
            assert.same({'GearSwap: Checking for items in inventory that are not used in your gear sets.', 'Naegling',
                'GearSwap: Final count = 1'}, validate(gs, 'inventory -remedy'))
        end)

        local cape = {name = "Sucellos's Cape", augments = {'MND+20', 'Enmity+10'}}

        it('names an item that no set names with the augments it has', function()
            local gs = boot(nil, {cape})
            local lines = validate(gs, 'inventory')
            assert.same({"Sucellos's Cape {'MND+20','Enmity+10'}"}, {lines[2]})
        end)

        it('leaves out an item a set names with the augments it has', function()
            local gs = boot(nil, {cape})
            gs.user.sets.cape = {back = {name = "Sucellos's Cape", augments = {'MND+20', 'Enmity+10'}}}
            assert.same({'GearSwap: Checking for items in inventory that are not used in your gear sets.',
                'GearSwap: Final count = 0'}, validate(gs, 'inventory'))
        end)

        it('lists an item a set names with other augments than it has', function()
            local gs = boot(nil, {cape})
            gs.user.sets.cape = {back = {name = "Sucellos's Cape", augments = {'MND+20', '"Cure" potency +10%'}}}
            assert.equal("Sucellos's Cape {'MND+20','Enmity+10'}", validate(gs, 'inventory')[2])
        end)

        it('leaves out an item a set names by name alone, whatever augments it has', function()
            local gs = boot(nil, {cape})
            gs.user.sets.cape = {back = "Sucellos's Cape"}
            assert.same({'GearSwap: Checking for items in inventory that are not used in your gear sets.',
                'GearSwap: Final count = 0'}, validate(gs, 'inventory'))
        end)
    end)
end)
