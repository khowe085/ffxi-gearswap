local autoy = require('autoy')
local harness = require('harness')

local function locks(gs)
    return autoy.count(gs.game.typed, '/lockstyle on')
end

-- Autoy as it loads, with AutoLockstyle on, which is up to User-Globals.lua unless a test sets it.
local function load()
    return autoy.load({user = function(user)
        user.state.AutoLockstyle:set(true)
    end})
end

describe('AutoLockstyle', function()
    it('locks the style five seconds after GearSwap loads', function()
        local gs = load()
        gs:play(harness.sel_load_time - 0.1)
        assert.equal(0, locks(gs))
        gs:play(0.2)
        assert.equal(1, locks(gs))
    end)

    it('runs gs validate along with it', function()
        local gs = load()
        gs:play(harness.sel_load_time - 0.1)
        assert.equal(0, autoy.count(gs.game.commands, 'gs validate'))
        gs:play(0.2)
        assert.equal(1, autoy.count(gs.game.commands, 'gs validate'))
    end)

    it('leaves the style alone when turned off', function()
        local gs = load()
        gs:console('gs c set AutoLockstyle false')
        gs:play(20)
        assert.equal(0, locks(gs))
    end)

    it('locks it again from the tick after a weapon change, once 15 seconds have passed since the last lock', function()
        local gs = load()
        gs:play(harness.sel_load_time + 1)
        gs:console('gs c set Weapons Naegling')
        gs:play(13.9)
        assert.equal(1, locks(gs))
        gs:play(0.5)
        assert.equal(2, locks(gs))
    end)

    it('locks it once for a weapon change, not on every tick after', function()
        local gs = load()
        gs:play(harness.sel_load_time + 1)
        gs:console('gs c set Weapons Naegling')
        gs:play(40)
        assert.equal(2, locks(gs))
    end)

    it('leaves the style alone after a weapon change when turned off', function()
        local gs = load()
        gs:play(harness.sel_load_time + 1)
        gs:console('gs c set AutoLockstyle false')
        gs:console('gs c set Weapons Naegling')
        gs:play(20)
        assert.equal(1, locks(gs))
    end)

    it('calls the gear file\'s user_job_lockstyle in place of /lockstyle on', function()
        local gs = load()
        local calls = 0
        gs.user.user_job_lockstyle = function()
            calls = calls + 1
        end
        gs:play(harness.sel_load_time + 1)
        gs:console('gs c set Weapons Naegling')
        gs:play(15)
        assert.equal(2, calls)
        assert.equal(0, locks(gs))
    end)
end)
