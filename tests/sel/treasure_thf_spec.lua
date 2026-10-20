local commy = require('commy')

describe('Sel\'s Treasure Hunter modes for a thief', function()
    local gs
    before_each(function()
        gs = commy.boot_thf()
    end)

    it('are None, Tag, SATA and Fulltime for a thief, starting at Tag', function()
        local mode = gs.user.state.TreasureMode
        assert.same({'None', 'Tag', 'SATA', 'Fulltime'}, {mode[1], mode[2], mode[3], mode[4]})
        assert.equal('Tag', mode.value)
    end)
end)
