local autoy = require('autoy')

-- Autoy with AutoTrustMode on, hit by the toad: in combat, which holds the trusts back until Sel's tick takes it
-- out of combat again.
local function hit(options)
    local gs = autoy.boot(options)
    gs:console('gs c set AutoTrustMode Default')
    gs:monster_hits()
    gs:traffic()
    return gs
end

local yoran_oran = {{action = 'Yoran-Oran (UC)', target = 'Autoy'}}

describe('Sel\'s tick, as it takes the character out of combat', function()
    it('keeps it in combat while the battle target lives', function()
        local gs = hit()
        gs:play(8)
        assert.same({}, gs:action_entries())
    end)

    it('takes it out of combat six seconds after the last hit once the battle target is dead', function()
        local gs = hit()
        gs.game.monster.hpp = 0
        gs:play(5.5)
        assert.same({}, gs:action_entries())
        gs:play(1.5)
        assert.same(yoran_oran, gs:action_entries())
    end)

    it('counts the six seconds from the last hit', function()
        local gs = hit()
        gs:play(4)
        gs:monster_hits()
        gs.game.monster.hpp = 0
        gs:play(5.5)
        assert.same({}, gs:action_entries())
        gs:play(1.5)
        assert.same(yoran_oran, gs:action_entries())
    end)

    it('turns the defense mode off then under AutoDefenseMode, and takes its set off', function()
        local gs = hit()
        gs:console('gs c toggle AutoDefenseMode')
        gs:console('gs c set DefenseMode Physical')
        assert.equal('Malignance Chapeau', gs:worn().head)
        gs.game.monster.hpp = 0
        gs:play(7)
        assert.equal('None', gs.user.state.DefenseMode.value)
        assert.equal('Nyame Helm', gs:worn().head)
    end)

    it('leaves the defense mode on without AutoDefenseMode', function()
        local gs = hit()
        gs:console('gs c set DefenseMode Physical')
        gs.game.monster.hpp = 0
        gs:play(7)
        assert.equal('Physical', gs.user.state.DefenseMode.value)
    end)
end)
