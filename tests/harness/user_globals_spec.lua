local autoy = require('autoy')
local jobby = require('jobby')
local user_globals = require('user_globals')

-- Autoy engaged with Naegling in hand and 1000 TP, as a red mage with the sub job given.
local function engaged(options)
    local gs = autoy.boot(options)
    gs:console('gs c set Weapons Naegling')
    gs:engage()
    gs:set_tp(1000)
    gs:traffic()
    return gs
end

describe('the buffs user_globals gives Auto WS Buff', function()
    it('are the ones it takes before a weapon skill, in place of the user\'s', function()
        local gs = engaged({sub_job = 'WAR', user = function(user)
            user_globals.give_ws_buffs(user, {{name = 'Warcry', job = 'WAR', level = 35, recast = 2}})
        end})
        gs:type('/ws "Savage Blade" <t>')
        assert.same({'Warcry'}, gs:actions())
    end)

    it('turn Auto WS Buff on', function()
        local gs = engaged({sub_job = 'WAR', user = function(user)
            user.state.AutoWSBuff:set(false)
            user_globals.give_ws_buffs(user, user_globals.ws_buffs)
        end})
        assert.is_true(gs.user.state.AutoWSBuff.value)
    end)

    -- The abilities of the list are the ones the tick of a job file's own buffing leaves to Auto WS Buff, which
    -- User-Globals.lua works out as it loads. With none given, Jobby's dark knight, whose gear file has an Auto WS Buff
    -- list, has Last Resort to use himself.
    it('are the only abilities the tick of a job file\'s own buffing leaves to it, in place of the user\'s', function()
        local gs = jobby.boot_ticking('DRK', {buffs = {'Dread Spikes'}, user = function(user)
            user_globals.give_ws_buffs(user, {})
        end})
        gs:console('gs c set AutoBuffMode Auto')
        gs:monster_hits()
        gs:play_until_action()
        assert.same({'Last Resort'}, gs:actions())
    end)
end)

describe('the restore weapon skills user_globals gives Auto WS', function()
    it('are the ones it takes in place of its choice when HP is low, in place of the user\'s', function()
        local gs = autoy.boot({abilities = {'Savage Blade', 'Sanguine Blade'}, user = function(user)
            user.state.AutoWSBuff:set(false)
        end})
        user_globals.give_restore_weaponskills(gs, {{id = 47, name = 'Sanguine Blade', hpp = 70}})
        gs:console('gs c set Weapons Naegling')
        gs:engage()
        gs:console('gs c set AutoWS Savage Blade 1000')
        gs:traffic()
        gs.game.player.vitals.hpp = 60
        gs:set_tp(1000)
        assert.same({'Sanguine Blade'}, gs:actions())
    end)
end)
