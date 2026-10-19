local harness = require('harness')
local testy = require('testy')

local function actions(gs)
    local names = {}
    for _, entry in ipairs(gs:traffic()) do
        names[#names + 1] = entry.action
    end
    return names
end

describe('the stand-in game\'s commands', function()
    local gs
    before_each(function()
        gs = harness.boot(testy.whm())
        gs:traffic()
    end)

    it('run an input command as the line typed', function()
        gs:console('input /ma "Cure III" <me>')
        assert.same({'Cure III'}, actions(gs))
    end)

    it('run the same with any number of @ in front, which Windower takes off', function()
        gs:console('@@input /ma "Cure III" <me>')
        assert.same({'Cure III'}, actions(gs))
    end)
end)
