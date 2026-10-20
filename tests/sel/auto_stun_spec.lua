local autoy = require('autoy')

local stun = {{action = 'Stun', target = 'Apex Toad'}}

-- Autoy as a red mage with a black mage sub, which can cast Stun, and AutoStunMode on. The abilities it knows are
-- only those named, so the job ability stuns Sel would try next are known only where a test says.
local function boot(options)
    options = options or {}
    options.sub_job = options.sub_job or 'BLM'
    options.abilities = options.abilities or {'Composure', 'Savage Blade'}
    local gs = autoy.boot(options)
    gs:console('gs c toggle AutoStunMode')
    gs:traffic()
    return gs
end

describe('AutoStunMode, Sel-Stahp.lua\'s stun on a monster\'s TP move', function()
    it('casts Stun at the target as it readies a TP move on Sel\'s stun list', function()
        local gs = boot()
        gs:monster_readies('Fulmination')
        assert.same(stun, gs:action_entries())
    end)

    it('leaves a TP move not on the list', function()
        local gs = boot()
        gs:monster_readies('Foot Kick')
        assert.same({}, gs:action_entries())
    end)

    it('leaves a monster it isn\'t targeting', function()
        local gs = boot()
        gs.game.target_index = gs.game.player.index
        gs:play(1)
        gs:monster_readies('Fulmination')
        assert.same({}, gs:action_entries())
    end)

    it('does nothing when turned off', function()
        local gs = boot()
        gs:console('gs c toggle AutoStunMode')
        gs:monster_readies('Fulmination')
        assert.same({}, gs:action_entries())
    end)

    it('does nothing while Stun is on recast and no other stun is to hand', function()
        local gs = boot()
        gs.game:start_spell_recast('Stun', 30)
        gs:monster_readies('Fulmination')
        assert.same({}, gs:action_entries())
    end)

    it('does nothing while silenced with no other stun to hand', function()
        local gs = boot({buffs = {'silence'}})
        gs:monster_readies('Fulmination')
        assert.same({}, gs:action_entries())
    end)

    it('uses Weapon Bash when Stun is on recast and a dark knight sub has it', function()
        local gs = boot({sub_job = 'DRK', abilities = {'Weapon Bash', 'Savage Blade'}})
        gs.game:start_spell_recast('Stun', 30)
        gs:monster_readies('Fulmination')
        assert.same({{action = 'Weapon Bash', target = 'Apex Toad'}}, gs:action_entries())
    end)
end)
