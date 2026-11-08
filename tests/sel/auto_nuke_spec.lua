local autoy = require('autoy')

local function boot(options)
    local gs = autoy.boot(options)
    gs:console('gs c toggle AutoNukeMode')
    gs:traffic()
    return gs
end

describe('AutoNukeMode', function()
    it('casts Fire, the autonuke spell unless set, at the target from the tick', function()
        local gs = boot()
        gs:play(1)
        assert.same({{action = 'Fire', target = 'Apex Toad'}}, gs:action_entries())
    end)

    it('casts the spell gs c autonuke names', function()
        local gs = boot()
        gs:console('gs c autonuke paralyze')
        gs:play(1)
        assert.same({{action = 'Paralyze', target = 'Apex Toad'}}, gs:action_entries())
    end)

    -- Sel refuses a spell on recast with an "Abort: ..." line, so this reads the chat too.
    it('holds back while the spell is on recast', function()
        local gs = boot()
        gs.game:start_spell_recast('Fire', 10)
        gs:chat()
        gs:play(3)
        assert.same({}, gs:action_entries())
        assert.same({}, gs:chat())
    end)

    it('holds back with no monster targeted', function()
        local gs = boot()
        gs.game.target_index = gs.game.player.index
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('holds back under Sneak', function()
        local gs = boot({buffs = {'Sneak'}})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('casts nothing while off', function()
        local gs = boot()
        gs:console('gs c toggle AutoNukeMode')
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    pending('casts a spell of more than one word set with gs c autonuke: check_nuke in libs/Sel-Utility.lua types it '
        .. 'unquoted (/ma Thunder III <t>), which GearSwap doesn\'t take for a spell and lets through to the game '
        .. 'untouched, on every tick')
end)
