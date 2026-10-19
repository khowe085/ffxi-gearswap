local harness = require('harness')
local testy = require('testy')

describe('a boot', function()
    it('finds the string functions as Lua has them, not wrapped by an earlier boot\'s libraries', function()
        harness.boot(testy.whm())
        local gs = harness.boot(testy.whm())
        -- Windower's strings.lua keeps the find it found in _raw before putting its own over it.
        assert.equal('C', debug.getinfo(gs.env._raw.string.find, 'S').what)
    end)

    it('finds them as Lua has them when it writes augments into an item first', function()
        harness.boot(testy.whm())
        -- The augments are written with Windower's own libraries, loaded for the purpose.
        local gs = harness.boot(testy.whm({items = {{name = "Alaunus's Cape", augments = {'MND+20'}}}, wearing = {}}))
        assert.equal('C', debug.getinfo(gs.env._raw.string.find, 'S').what)
    end)
end)
