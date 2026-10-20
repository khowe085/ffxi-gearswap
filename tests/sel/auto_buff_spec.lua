local autoy = require('autoy')

-- Autoy as a red mage, with AutoBuffMode set to the list given. data/RDM.lua's Auto list is Refresh III, Haste II,
-- Aurorastorm while idle, then Reraise; AutoMage starts Phalanx II, Haste II, Refresh III, Refresh III, Gain-INT.
local function boot(list, options)
    local gs = autoy.boot(options)
    gs:console('gs c set AutoBuffMode ' .. list)
    gs:traffic()
    return gs
end

local function on_me(name)
    return {action = name, target = 'Autoy'}
end

describe('AutoBuffMode, User-Globals.lua\'s check_buff on Sel\'s tick', function()
    it('casts the first spell of the list whose buff is down, on Autoy', function()
        local gs = boot('Auto')
        gs:play(1)
        assert.same({on_me('Refresh III')}, gs:action_entries())
    end)

    it('goes on to the next spell while the first one\'s buff is up', function()
        local gs = boot('Auto', {buffs = {'Refresh'}})
        gs:play(1)
        assert.same({on_me('Haste II')}, gs:action_entries())
    end)

    it('goes on to the next spell while the first is on recast', function()
        local gs = boot('Auto')
        gs.game:start_spell_recast('Refresh III', 30)
        gs:play(1)
        assert.same({on_me('Haste II')}, gs:action_entries())
    end)

    it('goes on past spells it hasn\'t the MP for', function()
        local gs = boot('AutoMage', {buffs = {'Phalanx'}})
        gs.game.player.vitals.mp = 50
        gs:play(1)
        assert.same({on_me('Gain-INT')}, gs:action_entries())
    end)

    it('goes on past a spell the job can\'t cast: Aurorastorm with no scholar sub', function()
        local gs = boot('Auto', {buffs = {'Refresh', 'Haste'}})
        gs:play(1)
        assert.same({on_me('Reraise')}, gs:action_entries())
    end)

    it('casts a spell meant for Idle while idle', function()
        local gs = boot('Auto', {sub_job = 'SCH', buffs = {'Refresh', 'Haste', 'Reraise'}})
        gs:play(1)
        assert.same({on_me('Aurorastorm')}, gs:action_entries())
    end)

    it('leaves a spell meant for Idle while engaged', function()
        local gs = boot('Auto', {sub_job = 'SCH', buffs = {'Refresh', 'Haste', 'Reraise'}})
        gs:engage()
        gs:traffic()
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('casts nothing once every buff it can give is up', function()
        local gs = boot('Auto', {buffs = {'Refresh', 'Haste', 'Reraise'}})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('casts nothing while Off', function()
        local gs = boot('Auto')
        gs:console('gs c set AutoBuffMode Off')
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    -- Refresh III's cast time is 5 seconds; Sel waits a quarter of that and 3 seconds more from the precast, and
    -- 2.4 seconds from the end of a spell, then a tenth of a second on top of either, before its tick acts again.
    it('waits a quarter of a spell\'s cast time and 3 seconds before the next, however soon the spell ends', function()
        local gs = boot('Auto')
        local cast = gs:play_until_action(2)
        assert.same({on_me('Refresh III')}, gs:action_entries())
        gs:play(0.5)
        gs:finish_action()
        gs:gain_buff('Refresh')
        local next_cast = gs:play_until_action(6)
        assert.same({on_me('Haste II')}, gs:action_entries())
        assert.near(4.4, next_cast - cast, 0.05)
    end)

    it('waits 2.4 seconds after a spell that ends later than that', function()
        local gs = boot('Auto')
        local cast = gs:play_until_action(2)
        gs:traffic()
        gs:play(4)
        gs:finish_action()
        gs:gain_buff('Refresh')
        local next_cast = gs:play_until_action(6)
        assert.same({on_me('Haste II')}, gs:action_entries())
        assert.near(6.55, next_cast - cast, 0.11)
    end)

    it('casts nothing in town', function()
        local gs = boot('Auto', {zone = 230})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)
end)
