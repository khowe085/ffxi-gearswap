local autoy = require('autoy')

local function boot(items, options)
    options = options or {}
    options.items = {}
    for _, name in ipairs(items) do
        options.items[#options.items + 1] = {name = name, count = 5}
    end
    local gs = autoy.boot(options)
    gs:console('gs c toggle AutoCleanupMode')
    gs:traffic()
    return gs
end

describe('AutoCleanupMode, at the end of Sel\'s tick', function()
    it('opens a Bead Pouch from the inventory', function()
        local gs = boot({'Bead Pouch'})
        gs:play(1)
        assert.same({{item = 'Bead Pouch', target = 'Autoy'}}, gs.game:items_used())
    end)

    it('puts currency it finds in the inventory into the sack', function()
        local gs = boot({'Pellucid Stone'})
        gs:play(1)
        assert.equal(1, autoy.count(gs:commands(),'put "Pellucid Stone" sack all'))
    end)

    it('leaves the currency where it is with the sack full', function()
        local gs = boot({'Pellucid Stone'})
        gs.game.bags[gs.game:bag_id('sack')].max = 0
        gs:play(3)
        assert.equal(0, autoy.count(gs:commands(),'put "Pellucid Stone" sack all'))
    end)

    it('puts a capacity ring away in the satchel with Capacity off', function()
        local gs = boot({'Capacity Ring'})
        gs:play(1)
        assert.equal(1, autoy.count(gs:commands(),'put "Capacity Ring" satchel'))
    end)

    it('opens no pouch while invisible, but still puts currency away', function()
        local gs = boot({'Bead Pouch', 'Pellucid Stone'}, {buffs = {'Invisible'}})
        gs:play(1)
        assert.same({}, gs.game:items_used())
        assert.equal(1, autoy.count(gs:commands(),'put "Pellucid Stone" sack all'))
    end)

    it('opens a pouch ahead of putting currency away', function()
        local gs = boot({'Bead Pouch', 'Pellucid Stone'})
        gs:play(1)
        assert.same({{item = 'Bead Pouch', target = 'Autoy'}}, gs.game:items_used())
        assert.equal(0, autoy.count(gs:commands(),'put "Pellucid Stone" sack all'))
    end)

    it('does nothing while off', function()
        local gs = boot({'Bead Pouch', 'Pellucid Stone'})
        gs:console('gs c toggle AutoCleanupMode')
        gs:play(3)
        assert.same({}, gs.game:items_used())
        assert.equal(0, autoy.count(gs:commands(),'put "Pellucid Stone" sack all'))
    end)
end)
