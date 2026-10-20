local autoy = require('autoy')

-- Autoy as a red mage with the sub job given, engaged with the TP given, the mode set as the line given sets it.
local function engaged(sub_job, tp, line, options)
    options = options or {}
    options.sub_job = sub_job
    local gs = autoy.boot(options)
    gs:console(line)
    gs:engage()
    gs.game.player.vitals.tp = tp
    gs:traffic()
    return gs
end

-- Sel refuses an ability on recast with an "Abort: ..." line, so a test of a recast holding a mode back reads the
-- chat too.

describe('AutoJumpMode, with a dragoon sub', function()
    local function jumper(tp, options)
        return engaged('DRG', tp, 'gs c toggle AutoJumpMode', options)
    end

    it('jumps on the target while engaged under 501 TP', function()
        local gs = jumper(500)
        gs:play(1)
        assert.same({{action = 'Jump', target = 'Apex Toad'}}, gs:action_entries())
    end)

    it('high jumps while Jump is on recast', function()
        local gs = jumper(0)
        gs.game:start_ability_recast('Jump', 60)
        gs:play(1)
        assert.same({{action = 'High Jump', target = 'Apex Toad'}}, gs:action_entries())
    end)

    it('jumps not at all while both jumps are on recast', function()
        local gs = jumper(0)
        gs.game:start_ability_recast('Jump', 60)
        gs.game:start_ability_recast('High Jump', 60)
        gs:chat()
        gs:play(3)
        assert.same({}, gs:action_entries())
        assert.same({}, gs:chat())
    end)

    it('jumps not at all at 501 TP', function()
        local gs = jumper(501)
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('jumps not at all while idle', function()
        local gs = jumper(0)
        gs:disengage()
        gs:traffic()
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('jumps not at all without a dragoon sub', function()
        local gs = engaged('WHM', 0, 'gs c toggle AutoJumpMode')
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)
end)

describe('AutoSambaMode, with a dancer sub', function()
    local function dancer(tp, options)
        return engaged('DNC', tp, 'gs c set AutoSambaMode Haste Samba', options)
    end

    it('uses the mode\'s samba on itself while engaged with 400 TP', function()
        local gs = dancer(400)
        gs:play(1)
        assert.same({{action = 'Haste Samba', target = 'Autoy'}}, gs:action_entries())
    end)

    it('uses none under 400 TP', function()
        local gs = dancer(399)
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('uses none while a samba is up', function()
        local gs = dancer(1000, {buffs = {'Haste Samba'}})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('uses none while sambas are on recast', function()
        local gs = dancer(1000)
        gs.game:start_ability_recast('Haste Samba', 60)
        gs:chat()
        gs:play(3)
        assert.same({}, gs:action_entries())
        assert.same({}, gs:chat())
    end)

    it('uses none while idle', function()
        local gs = dancer(1000)
        gs:disengage()
        gs:traffic()
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)
end)

describe('AutoSubMode, with a scholar sub', function()
    local function scholar(options)
        options = options or {}
        options.sub_job = options.sub_job or 'SCH'
        local gs = autoy.boot(options)
        gs:console('gs c toggle AutoSubMode')
        gs:traffic()
        return gs
    end

    local sublimation = {{action = 'Sublimation', target = 'Autoy'}}

    it('starts Sublimation when none is going', function()
        local gs = scholar()
        gs:play(1)
        assert.same(sublimation, gs:action_entries())
    end)

    it('leaves it while it charges', function()
        local gs = scholar({buffs = {'Sublimation: Activated'}})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('takes it in once it is complete and MP is under 65%', function()
        local gs = scholar({buffs = {'Sublimation: Complete'}})
        gs.game.player.vitals.mpp = 64
        gs:play(1)
        assert.same(sublimation, gs:action_entries())
    end)

    it('leaves it complete at 65% MP', function()
        local gs = scholar({buffs = {'Sublimation: Complete'}})
        gs.game.player.vitals.mpp = 65
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('leaves it while it is on recast', function()
        local gs = scholar()
        gs.game:start_ability_recast('Sublimation', 30)
        gs:chat()
        gs:play(3)
        assert.same({}, gs:action_entries())
        assert.same({}, gs:chat())
    end)

    it('uses none under SJ Restriction', function()
        local gs = scholar({buffs = {'SJ Restriction'}})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('uses none without a scholar sub', function()
        local gs = scholar({sub_job = 'WHM'})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('uses none in town', function()
        local gs = scholar({zone = 230})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)
end)
