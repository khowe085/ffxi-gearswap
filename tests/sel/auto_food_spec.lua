local autoy = require('autoy')

-- User-Globals.lua's food_lists: Attack is Grape Daifuku, Oden is Oden.
local daifuku = {{item = 'Grape Daifuku', target = 'Autoy'}}

local function boot(options, mode)
    local gs = autoy.boot(options)
    gs:console('gs c set AutoFoodMode ' .. (mode or 'Attack'))
    return gs
end

local function in_inventory(name)
    return {items = {{name = name, count = 3}}}
end

describe('AutoFoodMode', function()
    it('eats the mode\'s food from the inventory', function()
        local gs = boot(in_inventory('Grape Daifuku'))
        gs:play(1)
        assert.same(daifuku, gs.game:items_used())
    end)

    it('eats the food of the mode set', function()
        local gs = boot(in_inventory('Oden'), 'Oden')
        gs:play(1)
        assert.same({{item = 'Oden', target = 'Autoy'}}, gs.game:items_used())
    end)

    it('fetches the food from the satchel when the inventory has none', function()
        local gs = boot({items = {{name = 'Grape Daifuku', bag = 'satchel', count = 3}}})
        gs:play(1)
        assert.same({}, gs.game:items_used())
        assert.equal(1, autoy.count(gs.game.commands, 'get "Grape Daifuku" satchel'))
    end)

    it('eats nothing while a food is up', function()
        local gs = boot({items = {{name = 'Grape Daifuku', count = 3}}, buffs = {'Food'}})
        gs:play(3)
        assert.same({}, gs.game:items_used())
    end)

    it('eats nothing and fetches nothing with none of the food to hand', function()
        local gs = boot(in_inventory('Oden'))
        gs:play(3)
        assert.same({}, gs.game:items_used())
        assert.equal(0, autoy.count(gs.game.commands, 'get "Grape Daifuku" satchel'))
    end)

    it('eats nothing while Off', function()
        local gs = boot(in_inventory('Grape Daifuku'), 'Off')
        gs:play(3)
        assert.same({}, gs.game:items_used())
    end)

    it('eats nothing in town', function()
        local gs = boot({items = {{name = 'Grape Daifuku', count = 3}}, zone = 230})
        gs:play(3)
        assert.same({}, gs.game:items_used())
    end)

    it('eats nothing while invisible', function()
        local gs = boot({items = {{name = 'Grape Daifuku', count = 3}}, buffs = {'Invisible'}})
        gs:play(3)
        assert.same({}, gs.game:items_used())
    end)

    it('eats under Sneak, which only holds back the checks after it', function()
        local gs = boot({items = {{name = 'Grape Daifuku', count = 3}}, buffs = {'Sneak'}})
        gs:play(1)
        assert.same(daifuku, gs.game:items_used())
    end)

    it('tries again two seconds later while no food is up', function()
        local gs = boot(in_inventory('Grape Daifuku'))
        local used_at = {}
        for _ = 1, 50 do
            gs:play(0.1)
            if #gs.game:items_used() > #used_at then
                used_at[#used_at + 1] = gs.game.clock
            end
        end
        assert.is_true(#used_at >= 2)
        assert.near(2, used_at[2] - used_at[1], 0.11)
    end)
end)
