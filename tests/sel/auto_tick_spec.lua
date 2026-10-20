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
        assert.same({}, gs:action_entries())
        gs:play(0.3)
        assert.same(refresh, gs:action_entries())
    end)

    -- MiniQueue would hold a spell typed while walking and cast it once the character stands, so it is off here.
    it('holds back while the character walks, and acts once it stands', function()
        local gs = boot()
        gs:console('gs c toggle MiniQueue')
        gs:traffic()
        gs.game:walk()
        gs:play(3)
        assert.same({}, gs:action_entries())
        gs.game:stand()
        gs:play(1)
        assert.same(refresh, gs:action_entries())
    end)

    it('holds back while invisible', function()
        local gs = boot({buffs = {'Invisible'}})
        gs:play(3)
        assert.same({}, gs:action_entries())
        gs:lose_buff('Invisible')
        gs:play(1)
        assert.same(refresh, gs:action_entries())
    end)

    -- Sel refuses a spell typed while asleep or resting with an "Abort: ..." line, so these read the chat too.
    it('holds back while asleep', function()
        local gs = boot({buffs = {'sleep'}})
        gs:chat()
        gs:play(3)
        assert.same({}, gs:action_entries())
        assert.same({}, gs:chat())
        gs:lose_buff('sleep')
        gs:play(1)
        assert.same(refresh, gs:action_entries())
    end)

    it('holds back while resting', function()
        local gs = boot()
        gs:run(function()
            gs.game:set_status(33)
            gs.game:settle()
        end)
        gs:chat()
        gs:play(3)
        assert.same({}, gs:action_entries())
        assert.same({}, gs:chat())
        gs:disengage()
        gs:play(1)
        assert.same(refresh, gs:action_entries())
    end)

    it('acts while engaged as it does while idle', function()
        local gs = boot()
        gs:engage()
        gs:traffic()
        gs:play(1)
        assert.same(refresh, gs:action_entries())
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
        assert.same({}, gs:action_entries())
        assert.is_true(ticks >= 3)
    end)

    it('runs pre_tick\'s checks, such as check_trust, before user_job_tick, which can\'t hold them back', function()
        local gs = boot()
        gs:console('gs c set AutoTrustMode Default')
        gs:traffic()
        gs.user.user_job_tick = function() return true end
        gs:play(1)
        assert.same({{action = 'Yoran-Oran (UC)', target = 'Autoy'}}, gs:action_entries())
    end)

    it('goes on to the job\'s checks when user_job_tick returns false', function()
        local gs = boot()
        gs.user.user_job_tick = function() return false end
        gs:play(1)
        assert.same(refresh, gs:action_entries())
    end)

    -- With Refresh, Haste and Reraise up, data/RDM.lua's Auto list has nothing to cast, so AutoNukeMode's Fire,
    -- from Sel's default_tick, is the first act.
    it('goes on past the job\'s checks to Sel\'s own when user_job_tick returns false', function()
        local gs = boot({buffs = {'Refresh', 'Haste', 'Reraise'}})
        gs:console('gs c toggle AutoNukeMode')
        gs:traffic()
        gs.user.user_job_tick = function() return false end
        gs:play(1)
        assert.same({{action = 'Fire', target = 'Apex Toad'}}, gs:action_entries())
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
