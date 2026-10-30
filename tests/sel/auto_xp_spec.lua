local autoy = require('autoy')

-- Each test gives the character its own trust list (XP), buff list (XP) and AutoXP_Settings before Sel's tick first
-- acts, so none rests on User-Globals.lua's lists or a gear file's settings. Autoy, a red mage with a white mage sub,
-- pulls with Dia and heals with Cure IV; the monster to pull is the game's own, the Apex Toad, 3 yalms off and
-- targeted. A trust is in the party under its name without the (UC).
local trusts = {'Yoran-Oran (UC)', 'Koru-Moru', 'Qultada', 'Ulmia', 'Joachim'}
local in_party = {'Yoran-Oran', 'Koru-Moru', 'Qultada', 'Ulmia', 'Joachim'}

local function settings(extra)
    local s = {Trusts = 'XP', Healer = 'Yoran-Oran (UC)', HealerMPP = 10, Pull = 'Dia', PullRange = 20,
        Heal = 'Cure IV', HealHPP = 50, HealSeconds = 5}
    for key, value in pairs(extra or {}) do
        s[key] = value
    end
    return s
end

-- Boots Autoy with those settings (settings() unless given) and the trusts named in its party (all five unless given).
local function boot(s, members, options)
    options = options or {}
    options.user = function(user)
        user.trust_lists = {XP = trusts}
        user.state.AutoTrustMode:options('Off', 'XP')
        user.buff_spell_lists = {XP = {{Name = 'Haste II', Buff = 'Haste', SpellID = 511, When = 'Always'}}}
        user.state.AutoBuffMode:options('Off', 'XP')
        user.AutoXP_Settings = s or settings()
    end
    local gs = autoy.boot(options)
    for _, name in ipairs(members or in_party) do
        gs.game:add_party_member({name = name, mpp = 80})
    end
    return gs
end

local function member(gs, name)
    for _, other in ipairs(gs.game.others) do
        if other.name == name then
            return other
        end
    end
end

local function on_me(name)
    return {action = name, target = 'Autoy'}
end

-- The engage packet (an action of category 2) for the monster.
local engage = {action = 'category 2', target = 'Apex Toad'}

local function presses_f8(gs)
    return autoy.count(gs:commands(), 'setkey f8 down')
end

local function has_line(lines, text)
    return autoy.count(lines, text) > 0
end

describe('AutoXP', function()
    describe('turning on', function()
        it('refuses without AutoXP_Settings', function()
            local gs = boot()
            gs.user.AutoXP_Settings = nil
            gs:console('gs c toggle AutoXP')
            assert.is_false(gs.user.state.AutoXP.value)
            assert.is_true(has_line(gs:chat(), 'Auto XP: the gear file has no AutoXP_Settings table.'))
        end)

        it('refuses a Pull the character can\'t use', function()
            local gs = boot(nil, nil, {spells = {'Cure IV'}})
            gs:console('gs c toggle AutoXP')
            assert.is_false(gs.user.state.AutoXP.value)
            assert.is_true(has_line(gs:chat(), "Auto XP: you can't use Dia now."))
        end)

        it('refuses a Ranged pull with nothing to shoot', function()
            local gs = boot(settings({Pull = 'Ranged'}))
            gs:console('gs c toggle AutoXP')
            assert.is_false(gs.user.state.AutoXP.value)
        end)

        it('starts with a Heal the character can\'t use, and says nothing of it', function()
            local gs = boot(nil, nil, {spells = {'Dia'}})
            gs:console('gs c toggle AutoXP')
            assert.is_true(gs.user.state.AutoXP.value)
            for _, line in ipairs(gs:chat()) do
                assert.falsy(line:find('^Auto XP:'))
            end
        end)

        it('refuses a Healer without HealerMPP', function()
            local gs = boot(settings({HealerMPP = false}))
            gs:console('gs c toggle AutoXP')
            assert.is_false(gs.user.state.AutoXP.value)
            assert.is_true(has_line(gs:chat(), 'Auto XP: Healer needs HealerMPP.'))
        end)

        it('sets AutoTrustMode, AutoBuffMode and AutoWS from its settings, and puts them back when off', function()
            local gs = boot(settings({Buffs = 'XP', WS = 'Savage Blade 1000'}))
            gs:console('gs c set Weapons Naegling')
            gs:console('gs c toggle AutoXP')
            assert.equal('XP', gs.user.state.AutoTrustMode.value)
            assert.equal('XP', gs.user.state.AutoBuffMode.value)
            assert.equal('Savage Blade 1000', gs.user.state.AutoWS.value)
            gs:console('gs c toggle AutoXP')
            assert.equal('Off', gs.user.state.AutoTrustMode.value)
            assert.equal('Off', gs.user.state.AutoBuffMode.value)
            assert.equal('OFF', gs.user.state.AutoWS.value)
        end)

        it('passes over values the modes don\'t offer, and says nothing of them', function()
            local gs = boot(settings({Trusts = 'Gone', Buffs = 'Gone', WS = 'Gone 1000', Healer = 'Nobody'}))
            gs:console('gs c toggle AutoXP')
            assert.is_true(gs.user.state.AutoXP.value)
            assert.equal('Off', gs.user.state.AutoTrustMode.value)
            assert.equal('Off', gs.user.state.AutoBuffMode.value)
            assert.equal('OFF', gs.user.state.AutoWS.value)
            for _, line in ipairs(gs:chat()) do
                assert.falsy(line:find('^Auto XP:'))
            end
        end)

        it('puts back only the modes it set', function()
            local gs = boot()
            gs:console('gs c toggle AutoXP')
            gs:console('gs c set AutoBuffMode XP')
            gs:console('gs c toggle AutoXP')
            assert.equal('Off', gs.user.state.AutoTrustMode.value)
            assert.equal('XP', gs.user.state.AutoBuffMode.value)
        end)

        it('does nothing when the mode is set without a toggle', function()
            local gs = boot()
            gs.user.state.AutoXP:set(true)
            gs:play(2)
            assert.equal(0, presses_f8(gs))
            assert.same({}, gs:action_entries())
        end)

        it('shows Auto XP in the status box while on', function()
            local gs = boot()
            gs:console('gs c toggle AutoXP')
            assert.truthy(gs.user.stateBox:text():find('Auto XP', 1, true))
            gs:console('gs c toggle AutoXP')
            assert.falsy(gs.user.stateBox:text():find('Auto XP', 1, true))
        end)
    end)

    describe('pulling', function()
        it('presses F8, uses Pull on the target, and engages it once the pull claims it', function()
            local gs = boot()
            gs:console('gs c toggle AutoXP')
            gs:play(1)
            assert.equal(1, presses_f8(gs))
            assert.same({{action = 'Dia', target = 'Apex Toad'}}, gs:action_entries())
            gs:finish_action()
            gs:play(4)
            assert.same({engage}, gs:action_entries())
        end)

        it('leaves a monster someone outside the party has claimed', function()
            local gs = boot()
            gs.game.monster.claim_id = 0x0FFFFFF
            gs:console('gs c toggle AutoXP')
            gs:play(2)
            assert.same({}, gs:action_entries())
            assert.is_true(has_line(gs:chat(), 'Auto XP: F8 picked no unclaimed monster within 20 yalms.'))
        end)

        it('leaves a monster past PullRange', function()
            local gs = boot(settings({PullRange = 2}))
            gs:console('gs c toggle AutoXP')
            gs:play(2)
            assert.same({}, gs:action_entries())
        end)

        it('engages a monster already on the party, without pressing F8', function()
            local gs = boot()
            gs:console('gs c toggle AutoXP')
            gs:monster_hits()
            gs:play(1)
            assert.equal(0, presses_f8(gs))
            assert.same({engage}, gs:action_entries())
        end)

        it('holds pulls while HP is at or under HealHPP', function()
            local gs = boot()
            gs.game.player.vitals.hpp = 45
            gs:console('gs c toggle AutoXP')
            gs:play(2)
            assert.equal(0, presses_f8(gs))
            assert.is_true(has_line(gs:chat(), 'Auto XP: waiting for HP.'))
            gs.game.player.vitals.hpp = 80
            gs:play(1)
            assert.equal(1, presses_f8(gs))
        end)

        it('says why it waits on Pull, but not for a recast', function()
            local gs = boot()
            gs.game.player.vitals.mp = 0
            gs:console('gs c toggle AutoXP')
            gs:play(2)
            assert.equal(0, presses_f8(gs))
            assert.is_true(has_line(gs:chat(), 'Auto XP: Dia: not enough MP.'))

            local recast = boot()
            recast.game:start_spell_recast('Dia', 30)
            recast:console('gs c toggle AutoXP')
            recast:play(2)
            assert.equal(0, presses_f8(recast))
            for _, line in ipairs(recast:chat()) do
                assert.falsy(line:find('^Auto XP: Dia'))
            end
        end)
    end)

    describe('healing', function()
        it('uses Heal once HP has been at or under HealHPP for HealSeconds', function()
            local gs = boot()
            gs.game.monster.claim_id = 0x0FFFFFF
            gs:console('gs c toggle AutoXP')
            gs.game.player.vitals.hpp = 40
            gs:play(4)
            assert.same({}, gs:action_entries())
            gs:play(2)
            assert.same({on_me('Cure IV')}, gs:action_entries())
        end)

        it('lets Auto WS go while HP is fine', function()
            local gs = boot(settings({WS = 'Savage Blade 1000'}))
            gs:console('gs c set Weapons Naegling')
            gs:console('gs c toggle AutoXP')
            gs:engage()
            gs:forget()
            gs:set_tp(1000)
            assert.same({'Savage Blade'}, gs:actions())
        end)

        it('holds Auto WS while Heal is due and ready', function()
            local gs = boot(settings({WS = 'Savage Blade 1000'}))
            gs:console('gs c set Weapons Naegling')
            gs:console('gs c toggle AutoXP')
            gs:engage()
            gs.game.player.vitals.hpp = 40
            gs:play(0.5)
            gs:advance(5)
            gs:forget()
            gs:set_tp(1000)
            assert.same({}, gs:actions())
        end)
    end)

    describe('trusts', function()
        it('calls a missing trust before pulling', function()
            local gs = boot(nil, {'Yoran-Oran', 'Qultada', 'Ulmia', 'Joachim'})
            gs:console('gs c toggle AutoXP')
            gs:play(1)
            assert.same({on_me('Koru-Moru')}, gs:action_entries())
            assert.equal(0, presses_f8(gs))
        end)

        it('goes on without a missing trust on recast', function()
            local gs = boot(nil, {'Yoran-Oran', 'Qultada', 'Ulmia', 'Joachim'})
            gs.game:start_spell_recast('Koru-Moru', 60)
            gs:console('gs c toggle AutoXP')
            gs:play(1)
            assert.equal(1, presses_f8(gs))
        end)

        it('goes on without a trust after two calls bring nothing', function()
            local gs = boot(nil, {'Yoran-Oran', 'Qultada', 'Ulmia', 'Joachim'})
            gs.game.monster.claim_id = 0x0FFFFFF
            gs:console('gs c toggle AutoXP')
            gs:play(1)
            assert.same({on_me('Koru-Moru')}, gs:action_entries())
            gs:finish_action()
            gs:play(4)
            assert.same({on_me('Koru-Moru')}, gs:action_entries())
            gs:finish_action()
            gs:play(4)
            assert.same({}, gs:action_entries())
            assert.is_true(has_line(gs:chat(), "Auto XP: can't call Koru-Moru, going on without it."))
            assert.is_true(presses_f8(gs) > 0)
        end)

        it('keeps calling a trust that joins each time, with the party full in between', function()
            local gs = boot(nil, {'Yoran-Oran', 'Qultada', 'Ulmia', 'Joachim'})
            gs.game.monster.claim_id = 0x0FFFFFF
            gs:console('gs c toggle AutoXP')
            for _ = 1, 3 do
                gs:play(4)
                assert.same({on_me('Koru-Moru')}, gs:action_entries())
                gs:finish_action()
                local joined = gs.game:add_party_member({name = 'Koru-Moru', mpp = 80})
                gs:play(4)
                gs.game:remove_mob(joined.index)
            end
            for _, line in ipairs(gs:chat()) do
                assert.falsy(line:find("can't call", 1, true))
            end
        end)

        it('dismisses a healer under HealerMPP by its name between pulls', function()
            local gs = boot()
            member(gs, 'Yoran-Oran').mpp = 5
            gs:console('gs c toggle AutoXP')
            gs:play(1)
            assert.is_true(has_line(gs:typed(), '/refa Yoran-Oran'))
            assert.equal(0, presses_f8(gs))
        end)

        it('leaves a low healer the trust list no longer holds', function()
            local gs = boot()
            member(gs, 'Yoran-Oran').mpp = 5
            gs.user.trust_lists.XP = {'Koru-Moru', 'Qultada', 'Ulmia', 'Joachim'}
            gs:console('gs c toggle AutoXP')
            gs:play(1)
            assert.is_false(has_line(gs:typed(), '/refa Yoran-Oran'))
            assert.equal(1, presses_f8(gs))
        end)
    end)

    describe('weapon changes', function()
        it('sets its WS again after a change to a weapon set that has it', function()
            local gs = boot(settings({WS = 'Savage Blade 1000'}))
            gs:console('gs c set Weapons Naegling')
            gs:console('gs c toggle AutoXP')
            gs:console('gs c set Weapons Bow')
            assert.equal('OFF', gs.user.state.AutoWS.value)
            gs:console('gs c set Weapons Naegling')
            assert.equal('Savage Blade 1000', gs.user.state.AutoWS.value)
        end)

        it('sets its WS again after a weapon change that skips the state change', function()
            local gs = boot(settings({WS = 'Savage Blade 1000'}))
            gs:console('gs c set Weapons Naegling')
            gs:console('gs c toggle AutoXP')
            gs.user.state.Weapons:set('Bow')
            gs:set_tp(500)
            assert.equal('OFF', gs.user.state.AutoWS.value)
            gs.user.state.Weapons:set('Naegling')
            gs:set_tp(600)
            assert.equal('Savage Blade 1000', gs.user.state.AutoWS.value)
        end)
    end)

    describe('turning off by itself', function()
        it('turns off on death and puts the modes back', function()
            local gs = boot()
            gs:console('gs c toggle AutoXP')
            gs:set_status(2)
            gs:play(1)
            assert.is_false(gs.user.state.AutoXP.value)
            assert.equal('Off', gs.user.state.AutoTrustMode.value)
            assert.is_true(has_line(gs:chat(), 'Auto XP is now off: you died.'))
        end)

        it('turns off on zoning', function()
            local gs = boot()
            gs:console('gs c toggle AutoXP')
            gs:change_zone(230)
            assert.is_false(gs.user.state.AutoXP.value)
            assert.is_true(has_line(gs:chat(), 'Auto XP is now off: zoned.'))
        end)
    end)
end)
