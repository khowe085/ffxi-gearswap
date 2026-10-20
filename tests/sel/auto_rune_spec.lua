local autoy = require('autoy')

local function on_me(name)
    return {{action = name, target = 'Autoy'}}
end

-- Autoy as a red mage with a rune fencer sub unless the options say otherwise, AutoRuneMode set to the mode given.
-- The rune element is Ignis unless set.
local function boot(mode, options)
    options = options or {}
    options.sub_job = options.sub_job or 'RUN'
    local gs = autoy.boot(options)
    gs:console('gs c set AutoRuneMode ' .. mode)
    gs:traffic()
    return gs
end

describe('AutoRuneMode', function()
    it('calls a rune of the rune element with none up', function()
        local gs = boot('Runes')
        gs:play(1)
        assert.same(on_me('Ignis'), autoy.actions(gs))
    end)

    it('calls another while only one is up', function()
        local gs = boot('Runes', {buffs = {'Ignis'}})
        gs:play(1)
        assert.same(on_me('Ignis'), autoy.actions(gs))
    end)

    it('calls none with two up, as many as a sub job holds', function()
        local gs = boot('Runes', {buffs = {'Ignis', 'Ignis'}})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('calls none while runes are on recast', function()
        local gs = boot('Runes')
        gs.game:start_ability_recast('Ignis', 5)
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('calls none without a rune fencer', function()
        local gs = boot('Runes', {sub_job = 'WHM'})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('calls none while invisible', function()
        local gs = boot('Runes', {buffs = {'Invisible'}})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('goes on to Pflug in combat under Full once the runes are up', function()
        local gs = boot('Full', {buffs = {'Ignis', 'Ignis'}})
        gs:monster_hits()
        gs:traffic()
        gs:play(1)
        assert.same(on_me('Pflug'), autoy.actions(gs))
    end)

    it('goes on to Valiance in combat under Full once Pflug is up', function()
        local gs = boot('Full', {buffs = {'Ignis', 'Ignis', 'Pflug'}})
        gs:monster_hits()
        gs:traffic()
        gs:play(1)
        assert.same(on_me('Valiance'), autoy.actions(gs))
    end)

    it('goes on to Vallation instead while Valiance is on recast', function()
        local gs = boot('Full', {buffs = {'Ignis', 'Ignis', 'Pflug'}})
        gs.game:start_ability_recast('Valiance', 60)
        gs:monster_hits()
        gs:traffic()
        gs:play(1)
        assert.same(on_me('Vallation'), autoy.actions(gs))
    end)

    it('uses no ward out of combat under Full', function()
        local gs = boot('Full', {buffs = {'Ignis', 'Ignis'}})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('uses no ward in combat under Runes', function()
        local gs = boot('Runes', {buffs = {'Ignis', 'Ignis'}})
        gs:monster_hits()
        gs:traffic()
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    pending('lets the rest of the tick go on once three custom runes are up: check_rune in libs/Sel-Utility.lua '
        .. 'returns true from its third rune\'s branch whether or not it called one, so pre_tick stops the tick there '
        .. 'every frame, nothing after it acts (AutoTrustMode calls no trust) and in_combat is never reset')
end)
