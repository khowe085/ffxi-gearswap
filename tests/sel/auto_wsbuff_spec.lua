local autoy = require('autoy')

-- Autoy engaged with Naegling in hand and 1000 TP, as a red mage with a warrior sub unless the options say
-- otherwise. The gear file's ws_buff_list holds Savage Blade.
local function boot(options)
    options = options or {}
    options.sub_job = options.sub_job or 'WAR'
    local gs = autoy.boot(options)
    gs:console('gs c set Weapons Naegling')
    gs:engage()
    gs.game.player.vitals.tp = 1000
    gs:traffic()
    return gs
end

local savage_blade = {action = 'Savage Blade', target = 'Apex Toad'}

local function buff(name)
    return {action = name, target = 'Autoy'}
end

-- Types the weapon skill, answers the buff Auto WS Buff used in its place, and plays on until the weapon skill
-- has gone out again: what was sent, in order.
local function weaponskill_after_buff(gs, line)
    gs:type(line or '/ws "Savage Blade" <t>')
    local sent = gs:action_entries()
    if #sent == 1 and sent[1].target == 'Autoy' then
        gs:finish_action()
        gs:gain_buff(sent[1].action)
        gs:advance(1.2)
        for _, action in ipairs(gs:action_entries()) do
            sent[#sent + 1] = action
        end
    end
    return sent
end

describe('Auto WS Buff, User-Globals.lua\'s buff before a weapon skill', function()
    it('uses Berserk in place of a weapon skill on ws_buff_list, and sends the weapon skill 1.1 seconds later', function()
        local gs = boot()
        assert.is_true(gs:type('/ws "Savage Blade" <t>'))
        assert.same({buff('Berserk')}, gs:action_entries())
        gs:finish_action()
        gs:gain_buff('Berserk')
        gs:advance(1)
        assert.same({}, gs:action_entries())
        gs:advance(0.2)
        assert.same({savage_blade}, gs:action_entries())
    end)

    it('takes Warcry while Berserk is up', function()
        local gs = boot({buffs = {'Berserk'}})
        assert.same({buff('Warcry'), savage_blade}, weaponskill_after_buff(gs))
    end)

    it('takes Warcry while Berserk is on recast', function()
        local gs = boot()
        gs.game:start_ability_recast('Berserk', 300)
        assert.same({buff('Warcry'), savage_blade}, weaponskill_after_buff(gs))
    end)

    it('takes Warcry while Defender is up, which Berserk would cancel', function()
        local gs = boot({buffs = {'Defender'}})
        assert.same({buff('Warcry'), savage_blade}, weaponskill_after_buff(gs))
    end)

    it('takes Aggressor once Berserk and Warcry are both up', function()
        local gs = boot({buffs = {'Berserk', 'Warcry'}})
        assert.same({buff('Aggressor'), savage_blade}, weaponskill_after_buff(gs))
    end)

    it('uses Last Resort first with a dark knight sub', function()
        local gs = boot({sub_job = 'DRK'})
        assert.same({buff('Last Resort'), savage_blade}, weaponskill_after_buff(gs))
    end)

    it('takes only the buffs the sub job\'s level reaches', function()
        local gs = boot({sub_job_level = 30, buffs = {'Berserk'}})
        assert.same({savage_blade}, weaponskill_after_buff(gs))
    end)

    it('sends the weapon skill straight once every buff is up', function()
        local gs = boot({buffs = {'Berserk', 'Warcry', 'Aggressor'}})
        assert.same({savage_blade}, weaponskill_after_buff(gs))
    end)

    it('sends the weapon skill straight once every buff is on recast', function()
        local gs = boot()
        for _, name in ipairs({'Berserk', 'Warcry', 'Aggressor'}) do
            gs.game:start_ability_recast(name, 300)
        end
        assert.same({savage_blade}, weaponskill_after_buff(gs))
    end)

    it('sends a weapon skill not on ws_buff_list straight', function()
        local gs = boot()
        assert.same({{action = 'Requiescat', target = 'Apex Toad'}}, weaponskill_after_buff(gs, '/ws "Requiescat" <t>'))
    end)

    it('sends the weapon skill straight when turned off', function()
        local gs = boot()
        gs:console('gs c toggle AutoWSBuff')
        assert.same({savage_blade}, weaponskill_after_buff(gs))
    end)

    it('sends the weapon skill straight under SJ Restriction', function()
        local gs = boot({buffs = {'SJ Restriction'}})
        assert.same({savage_blade}, weaponskill_after_buff(gs))
    end)

    it('drops another press of the weapon skill while the buff and its weapon skill are pending', function()
        local gs = boot()
        gs:type('/ws "Savage Blade" <t>')
        gs:type('/ws "Savage Blade" <t>')
        assert.same({buff('Berserk')}, gs:action_entries())
        gs:finish_action()
        gs:gain_buff('Berserk')
        gs:advance(1.2)
        assert.same({savage_blade}, gs:action_entries())
    end)

    it('lets the next press through once the weapon skill it sent is done', function()
        local gs = boot()
        weaponskill_after_buff(gs)
        gs:finish_action()
        gs.game.player.vitals.tp = 1000
        gs:advance(3)
        gs:traffic()
        gs:type('/ws "Savage Blade" <t>')
        assert.same({buff('Warcry')}, gs:action_entries())
    end)
end)

describe('User-Globals.lua\'s TP check on a weapon skill', function()
    it('drops a weapon skill typed under 1000 TP before any set goes on', function()
        local gs = boot()
        gs.game.player.vitals.tp = 999
        assert.is_true(gs:type('/ws "Requiescat" <t>'))
        assert.same({}, gs:traffic())
    end)
end)

describe('Auto WS Buff for a warrior', function()
    local function warrior()
        return boot({main_job = 'WAR', sub_job = 'WHM'})
    end

    it('uses Berserk as for any job while AutoBuffMode is off', function()
        local gs = warrior()
        assert.same({buff('Berserk'), savage_blade}, weaponskill_after_buff(gs))
    end)

    it('steps aside under AutoBuffMode, where data/WAR.lua uses Warcry before a weapon skill itself', function()
        local gs = warrior()
        gs:console('gs c set AutoBuffMode Auto')
        gs:traffic()
        assert.same({buff('Warcry'), savage_blade}, weaponskill_after_buff(gs))
    end)
end)
