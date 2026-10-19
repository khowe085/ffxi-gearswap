local autoy = require('autoy')

-- data/RDM.lua's Default list starts Haste II, Refresh III, Gain-MND, Aquaveil; its MageBuff list starts Haste II,
-- Refresh III, Gain-INT.
local function on_me(name)
    return {action = name, target = 'Autoy'}
end

describe('gs c buffup', function()
    it('casts the Default list\'s first spell whose buff is down, on Autoy', function()
        local gs = autoy.boot()
        gs:console('gs c buffup')
        gs:play(1)
        assert.same({on_me('Haste II')}, autoy.actions(gs))
    end)

    it('goes on down the list past the buffs that are up', function()
        local gs = autoy.boot({buffs = {'Haste', 'Refresh'}})
        gs:console('gs c buffup')
        gs:play(1)
        assert.same({on_me('Gain-MND')}, autoy.actions(gs))
    end)

    it('casts from the list it is given', function()
        local gs = autoy.boot({buffs = {'Haste', 'Refresh'}})
        gs:console('gs c buffup MageBuff')
        gs:play(1)
        assert.same({on_me('Gain-INT')}, autoy.actions(gs))
    end)

    it('goes on past a spell on recast', function()
        local gs = autoy.boot()
        gs.game:start_spell_recast('Haste II', 20)
        gs:console('gs c buffup')
        gs:play(1)
        assert.same({on_me('Refresh III')}, autoy.actions(gs))
    end)

    it('casts each in turn as its buff comes up', function()
        local gs = autoy.boot()
        gs:console('gs c buffup')
        local cast = {}
        for _, buff in ipairs({'Haste', 'Refresh', 'MND Boost'}) do
            local actions = autoy.play_until_action(gs, 6)
            cast[#cast + 1] = actions[1] and actions[1].action
            gs:finish_action()
            gs:gain_buff(buff)
        end
        assert.same({'Haste II', 'Refresh III', 'Gain-MND'}, cast)
    end)

    it('says so and stops once every buff of the list is up', function()
        local gs = autoy.boot({buffs = {'Haste', 'Refresh', 'MND Boost', 'Aquaveil', 'Phalanx', 'Stoneskin', 'Blink',
            'Shell', 'Protect'}})
        gs:console('gs c buffup')
        gs:play(1)
        assert.same({}, autoy.actions(gs))
        assert.equal(1, autoy.count(autoy.chat(gs), 'All Default buffs are up!'))
        assert.equal('', gs.user.buffup)
    end)

    it('refuses a list there is none of', function()
        local gs = autoy.boot()
        gs:console('gs c buffup Nope')
        gs:play(1)
        assert.same({}, autoy.actions(gs))
        assert.equal(1, autoy.count(autoy.chat(gs), 'Nope is not a buff list!'))
    end)

    it('is called off when the character walks, and says so', function()
        local gs = autoy.boot()
        gs:console('gs c buffup')
        gs.game:walk()
        gs:play(1)
        gs.game:stand()
        gs:play(2)
        assert.same({}, autoy.actions(gs))
        assert.equal(1, autoy.count(autoy.chat(gs), 'Buffup cancelled due to movement.'))
    end)
end)
