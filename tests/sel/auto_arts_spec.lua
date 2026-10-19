local autoy = require('autoy')

local function on_me(name)
    return {action = name, target = 'Autoy'}
end

-- Autoy as a red mage with AutoArts on, and in combat when asked: the toad has hit it.
local function boot(options, in_combat)
    local gs = autoy.boot(options)
    gs:console('gs c toggle AutoArts')
    if in_combat then
        gs:monster_hits()
    end
    gs:traffic()
    return gs
end

describe('AutoArts, data/RDM.lua\'s check_arts', function()
    it('uses Composure in combat', function()
        local gs = boot(nil, true)
        gs:play(1)
        assert.same({on_me('Composure')}, autoy.actions(gs))
    end)

    it('uses nothing out of combat', function()
        local gs = boot()
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('uses Composure out of combat under AutoBuffMode, ahead of its spells', function()
        local gs = boot()
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(1)
        assert.same({on_me('Composure')}, autoy.actions(gs))
    end)

    it('uses Composure ahead of gs c buffup\'s spells', function()
        local gs = boot()
        gs:console('gs c buffup')
        gs:play(1)
        assert.same({on_me('Composure')}, autoy.actions(gs))
    end)

    it('leaves Composure while it is up', function()
        local gs = boot({buffs = {'Composure'}}, true)
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('leaves Composure while it is on recast', function()
        local gs = boot(nil, true)
        gs.game:start_ability_recast('Composure', 300)
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('uses Light Arts with a scholar sub and no arts up', function()
        local gs = boot({sub_job = 'SCH', buffs = {'Composure'}}, true)
        gs:play(1)
        assert.same({on_me('Light Arts')}, autoy.actions(gs))
    end)

    it('leaves Light Arts while Dark Arts is up', function()
        local gs = boot({sub_job = 'SCH', buffs = {'Composure', 'Dark Arts'}}, true)
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('leaves Light Arts under SJ Restriction', function()
        local gs = boot({sub_job = 'SCH', buffs = {'Composure', 'SJ Restriction'}}, true)
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('uses nothing in town, under AutoBuffMode', function()
        local gs = boot({zone = 230})
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)
end)

describe('check_arts with AutoArts off, as User-Globals.lua has it', function()
    it('uses no Composure under AutoBuffMode, which goes straight to its spells', function()
        local gs = autoy.boot()
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(1)
        assert.same({on_me('Refresh III')}, autoy.actions(gs))
    end)

    it('uses no Composure under gs c buffup', function()
        local gs = autoy.boot()
        gs:console('gs c buffup')
        gs:play(1)
        assert.same({on_me('Haste II')}, autoy.actions(gs))
    end)
end)
