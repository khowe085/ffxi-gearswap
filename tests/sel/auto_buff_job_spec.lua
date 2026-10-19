local autoy = require('autoy')

local function on_me(name)
    return {action = name, target = 'Autoy'}
end

-- Autoy as the job given, with AutoBuffMode on and the toad having hit it, so it is in combat.
local function in_combat(options)
    local gs = autoy.boot(options)
    gs:console('gs c set AutoBuffMode Auto')
    gs:monster_hits()
    gs:traffic()
    return gs
end

describe('data/WAR.lua\'s job_check_buff under AutoBuffMode', function()
    local function warrior(buffs)
        return in_combat({main_job = 'WAR', sub_job = 'WHM', buffs = buffs})
    end

    it('uses Retaliation first in combat', function()
        local gs = warrior()
        gs:play(1)
        assert.same({on_me('Retaliation')}, autoy.actions(gs))
    end)

    it('goes on to Restraint while Retaliation is up', function()
        local gs = warrior({'Retaliation'})
        gs:play(1)
        assert.same({on_me('Restraint')}, autoy.actions(gs))
    end)

    it('goes on to Blood Rage once Retaliation and Restraint are up', function()
        local gs = warrior({'Retaliation', 'Restraint'})
        gs:play(1)
        assert.same({on_me('Blood Rage')}, autoy.actions(gs))
    end)

    it('leaves Blood Rage while Warcry is up, and goes on to Berserk', function()
        local gs = warrior({'Retaliation', 'Restraint', 'Warcry'})
        gs:play(1)
        assert.same({on_me('Berserk')}, autoy.actions(gs))
    end)

    it('goes on to Aggressor last', function()
        local gs = warrior({'Retaliation', 'Restraint', 'Blood Rage', 'Berserk'})
        gs:play(1)
        assert.same({on_me('Aggressor')}, autoy.actions(gs))
    end)

    it('goes on past an ability on recast', function()
        local gs = warrior()
        gs.game:start_ability_recast('Retaliation', 60)
        gs:play(1)
        assert.same({on_me('Restraint')}, autoy.actions(gs))
    end)

    it('uses nothing out of combat', function()
        local gs = autoy.boot({main_job = 'WAR', sub_job = 'WHM'})
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('uses nothing with AutoBuffMode off', function()
        local gs = autoy.boot({main_job = 'WAR', sub_job = 'WHM'})
        gs:monster_hits()
        gs:traffic()
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)
end)

describe('data/DRK.lua\'s buffing under AutoBuffMode, with a ws_buff_list', function()
    local function dark_knight(buffs)
        return in_combat({main_job = 'DRK', sub_job = 'WAR', buffs = buffs})
    end

    it('casts Dread Spikes first in combat, from the job\'s Auto list', function()
        local gs = dark_knight()
        gs:play(1)
        assert.same({on_me('Dread Spikes')}, autoy.actions(gs))
    end)

    it('casts no Dread Spikes, a spell meant for combat, out of combat', function()
        local gs = autoy.boot({main_job = 'DRK', sub_job = 'WAR'})
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('leaves Last Resort, Berserk and Aggressor to Auto WS Buff, and uses Scarlet Delirium', function()
        local gs = dark_knight({'Dread Spikes'})
        gs:play(1)
        assert.same({on_me('Scarlet Delirium')}, autoy.actions(gs))
    end)

    it('uses nothing once Scarlet Delirium is up too', function()
        local gs = dark_knight({'Dread Spikes', 'Scarlet Delirium'})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('uses Last Resort first with Auto WS Buff off', function()
        local gs = dark_knight({'Dread Spikes'})
        gs:console('gs c toggle AutoWSBuff')
        gs:play(1)
        assert.same({on_me('Last Resort')}, autoy.actions(gs))
    end)

    it('uses Berserk, a warrior sub\'s, with Auto WS Buff off once its own are up', function()
        local gs = dark_knight({'Dread Spikes', 'Last Resort', 'Scarlet Delirium'})
        gs:console('gs c toggle AutoWSBuff')
        gs:play(1)
        assert.same({on_me('Berserk')}, autoy.actions(gs))
    end)
end)
