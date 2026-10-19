local autoy = require('autoy')

local blink = {{action = 'Blink', target = 'Autoy'}}

local function boot(options)
    local gs = autoy.boot(options)
    gs:console('gs c toggle AutoShadowMode')
    gs:traffic()
    return gs
end

describe('AutoShadowMode, for a red mage with no utsusemi', function()
    it('casts Blink with no shadows up', function()
        local gs = boot()
        gs:play(1)
        assert.same(blink, autoy.actions(gs))
    end)

    it('casts nothing while Blink is up', function()
        local gs = boot({buffs = {'Blink'}})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('casts nothing while a Copy Image is up', function()
        local gs = boot({buffs = {'Copy Image'}})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('casts nothing while Blink is on recast', function()
        local gs = boot()
        gs.game:start_spell_recast('Blink', 20)
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('casts Blink ahead of AutoBuffMode\'s spells', function()
        local gs = boot()
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(1)
        assert.same(blink, autoy.actions(gs))
    end)

    it('casts nothing in town', function()
        local gs = boot({zone = 230})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('casts nothing while invisible', function()
        local gs = boot({buffs = {'Invisible'}})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('casts nothing while off', function()
        local gs = autoy.boot()
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)
end)
