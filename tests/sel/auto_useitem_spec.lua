local autoy = require('autoy')

local function boot(bag, options)
    options = options or {}
    options.items = bag and {{name = 'Grape Daifuku', bag = bag, count = 3}} or {}
    local gs = autoy.boot(options)
    gs:console('gs c useitem item Grape Daifuku')
    gs:traffic()
    return gs
end

describe('gs c useitem, from the start of Sel\'s tick', function()
    it('uses the item named from the inventory, and says so', function()
        local gs = boot('inventory')
        gs:play(1)
        assert.same({{item = 'Grape Daifuku', target = 'Autoy'}}, gs.game:items_used())
        assert.equal(1, autoy.count(autoy.chat(gs), 'Using Grape Daifuku, /heal to cancel.'))
    end)

    it('fetches the item from the satchel when the inventory has none', function()
        local gs = boot('satchel')
        gs:play(1)
        assert.same({}, gs.game:items_used())
        assert.equal(1, autoy.count(gs.game.commands, 'get "Grape Daifuku" satchel'))
    end)

    it('gives up on an item it can\'t find, and says so once', function()
        local gs = boot(nil)
        gs:play(3)
        assert.same({}, gs.game:items_used())
        assert.equal(1, autoy.count(autoy.chat(gs), 'Grape Daifuku not available or ready for use.'))
    end)

    it('uses the item while invisible', function()
        local gs = boot('inventory', {buffs = {'Invisible'}})
        gs:play(1)
        assert.same({{item = 'Grape Daifuku', target = 'Autoy'}}, gs.game:items_used())
    end)

    it('is called off by resting, which says so', function()
        local gs = boot('satchel')
        gs:run(function()
            gs.game:set_status(33)
            gs.game:settle()
        end)
        assert.equal(1, autoy.count(autoy.chat(gs), 'Cancelling using Grape Daifuku.'))
        gs:disengage()
        gs:play(3)
        assert.equal(0, autoy.count(gs.game.commands, 'get "Grape Daifuku" satchel'))
    end)
end)
