local autoy = require('autoy')

-- Sel's tick, as AutoBuffMode shows it: under the Auto list, a red mage's first act is Refresh III on itself.
local refresh = {{action = 'Refresh III', target = 'Autoy'}}

local function boot(options)
    local gs = autoy.boot(options)
    gs:console('gs c set AutoBuffMode Auto')
    gs:traffic()
    return gs
end

describe('Sel\'s tick', function()
    it('does nothing for the first five seconds after GearSwap loads', function()
        local gs = autoy.load()
        gs:console('gs c set AutoBuffMode Auto')
        gs:traffic()
        gs:play(4.9)
        assert.same({}, autoy.actions(gs))
        gs:play(0.3)
        assert.same(refresh, autoy.actions(gs))
    end)

    it('holds back while the character walks, and acts once it stands', function()
        local gs = boot()
        gs.game:walk()
        gs:play(3)
        assert.same({}, autoy.actions(gs))
        gs.game:stand()
        gs:play(1)
        assert.same(refresh, autoy.actions(gs))
    end)

    it('holds back while invisible', function()
        local gs = boot({buffs = {'Invisible'}})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
        gs:lose_buff('Invisible')
        gs:play(1)
        assert.same(refresh, autoy.actions(gs))
    end)

    it('holds back while asleep', function()
        local gs = boot({buffs = {'sleep'}})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
        gs:lose_buff('sleep')
        gs:play(1)
        assert.same(refresh, autoy.actions(gs))
    end)

    it('holds back while resting', function()
        local gs = boot()
        gs:run(function()
            gs.game:set_status(33)
            gs.game:settle()
        end)
        gs:play(3)
        assert.same({}, autoy.actions(gs))
        gs:disengage()
        gs:play(1)
        assert.same(refresh, autoy.actions(gs))
    end)

    it('acts while engaged as it does while idle', function()
        local gs = boot()
        gs:engage()
        gs:traffic()
        gs:play(1)
        assert.same(refresh, autoy.actions(gs))
    end)

    it('runs the gear file\'s user_job_tick after pre_tick\'s checks and ahead of the rest, which it holds back by '
        .. 'returning true', function()
        local gs = boot()
        local ticks = 0
        gs.user.user_job_tick = function()
            ticks = ticks + 1
            return true
        end
        gs:play(2)
        assert.same({}, autoy.actions(gs))
        assert.is_true(ticks >= 3)
    end)

    it('goes on to the job\'s and Sel\'s own checks when user_job_tick returns false', function()
        local gs = boot()
        gs.user.user_job_tick = function() return false end
        gs:play(1)
        assert.same(refresh, autoy.actions(gs))
    end)

    it('skips user_job_tick while invisible', function()
        local gs = boot({buffs = {'Invisible'}})
        local ticks = 0
        gs.user.user_job_tick = function()
            ticks = ticks + 1
        end
        gs:play(2)
        assert.equal(0, ticks)
    end)

    pending('puts the weapon set back when no weapon is in hand under ReEquip, as User-Globals.lua says: nothing in '
        .. 'libs/ or data/ reads state.ReEquip')
end)
