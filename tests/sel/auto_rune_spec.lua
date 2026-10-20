local autoy = require('autoy')

local function on_me(name)
    return {{action = name, target = 'Autoy'}}
end

-- The abilities a rune fencer sub job at 49 has: the runes, Vallation and Pflug, but not Valiance, which comes at 50.
local run_sub_abilities = {'Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda', 'Lux', 'Tenebrae', 'Vallation',
    'Pflug'}

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
        assert.same(on_me('Ignis'), gs:action_entries())
    end)

    it('calls another while only one is up', function()
        local gs = boot('Runes', {buffs = {'Ignis'}})
        gs:play(1)
        assert.same(on_me('Ignis'), gs:action_entries())
    end)

    it('calls none with two up, as many as a sub job holds', function()
        local gs = boot('Runes', {buffs = {'Ignis', 'Ignis'}})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    -- Sel refuses an ability on recast with an "Abort: ..." line, so this reads the chat too.
    it('calls none while runes are on recast', function()
        local gs = boot('Runes')
        gs.game:start_ability_recast('Ignis', 5)
        gs:chat()
        gs:play(3)
        assert.same({}, gs:action_entries())
        assert.same({}, gs:chat())
    end)

    it('calls none without a rune fencer', function()
        local gs = boot('Runes', {sub_job = 'WHM'})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('calls none while invisible', function()
        local gs = boot('Runes', {buffs = {'Invisible'}})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('goes on to Pflug in combat under Full once the runes are up', function()
        local gs = boot('Full', {buffs = {'Ignis', 'Ignis'}, abilities = run_sub_abilities})
        gs:monster_hits()
        gs:traffic()
        gs:play(1)
        assert.same(on_me('Pflug'), gs:action_entries())
    end)

    it('goes on to Vallation in combat under Full once Pflug is up, as Valiance is out of a sub job\'s reach', function()
        local gs = boot('Full', {buffs = {'Ignis', 'Ignis', 'Pflug'}, abilities = run_sub_abilities})
        gs:monster_hits()
        gs:traffic()
        gs:play(1)
        assert.same(on_me('Vallation'), gs:action_entries())
    end)

    it('uses no ward out of combat under Full', function()
        local gs = boot('Full', {buffs = {'Ignis', 'Ignis'}, abilities = run_sub_abilities})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('uses no ward in combat under Runes', function()
        local gs = boot('Runes', {buffs = {'Ignis', 'Ignis'}})
        gs:monster_hits()
        gs:traffic()
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    pending('lets the rest of the tick go on once three custom runes are up: check_rune in libs/Sel-Utility.lua '
        .. 'returns true from its third rune\'s branch whether or not it called one, so pre_tick stops the tick there '
        .. 'every frame, nothing after it acts (AutoTrustMode calls no trust) and in_combat is never reset')
end)
