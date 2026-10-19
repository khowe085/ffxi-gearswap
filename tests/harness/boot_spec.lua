local harness = require('harness')
local testy = require('testy')

describe('a boot', function()
    it('finds the string functions as Lua has them, not wrapped by an earlier boot\'s libraries', function()
        harness.boot(testy.whm())
        local gs = harness.boot(testy.whm())
        -- Windower's strings.lua keeps the find it found in _raw before putting its own over it.
        assert.equal('C', debug.getinfo(gs.env._raw.string.find, 'S').what)
    end)
end)
