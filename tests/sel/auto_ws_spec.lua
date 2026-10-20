local autoy = require('autoy')

-- Autoy with Naegling locked in hand, engaged on the toad three yalms off, Auto WS set to the choice given.
local function boot(choice)
    local gs = autoy.boot()
    gs:console('gs c set Weapons Naegling')
    gs:engage()
    if choice then
        gs:console('gs c set AutoWS ' .. choice)
    end
    gs:traffic()
    return gs
end

local savage_blade = {{action = 'Savage Blade', target = 'Apex Toad'}}

describe('Auto WS, User-Globals.lua\'s weapon skill on TP', function()
    it('offers OFF, then a choice for each AutoWS_List entry of the weapon set, named for its weapon skill and TP', function()
        local gs = boot()
        local seen = {gs.user.state.AutoWS.value}
        for _ = 1, 4 do
            gs:console('gs c cycle AutoWS')
            seen[#seen + 1] = gs.user.state.AutoWS.value
        end
        assert.same({'OFF', 'Savage Blade 1000', 'Savage Blade 1750', 'Savage Blade AM2', 'Savage Blade AM3'}, seen)
    end)

    it('uses the weapon skill at the target once TP reaches the choice\'s', function()
        local gs = boot('Savage Blade 1000')
        gs:set_tp(1000)
        assert.same(savage_blade, autoy.actions(gs))
    end)

    it('holds back under the choice\'s TP', function()
        local gs = boot('Savage Blade 1750')
        gs:set_tp(1500)
        assert.same({}, autoy.actions(gs))
        gs:set_tp(1750)
        assert.same(savage_blade, autoy.actions(gs))
    end)

    it('holds back while OFF', function()
        local gs = boot()
        gs:set_tp(3000)
        assert.same({}, autoy.actions(gs))
    end)

    it('holds back while not engaged', function()
        local gs = boot('Savage Blade 1000')
        gs:disengage()
        gs:traffic()
        gs:set_tp(1000)
        assert.same({}, autoy.actions(gs))
    end)

    -- Sel's MiniQueue holds a weapon skill sent too soon after the last action and sends it from its tick once
    -- it may, so each TP change is followed by a few seconds' play to let a held one out.
    it('waits two seconds after one weapon skill before sending another', function()
        local gs = boot('Savage Blade 1000')
        gs:set_tp(1000)
        gs:finish_action()
        gs:traffic()
        gs:advance(1.9)
        gs:set_tp(1100)
        gs:play(3)
        assert.same({}, autoy.actions(gs))
        gs:set_tp(1200)
        gs:play(3)
        assert.same(savage_blade, autoy.actions(gs))
    end)

    it('sends another on a TP change just past the two seconds', function()
        local gs = boot('Savage Blade 1000')
        gs:set_tp(1000)
        gs:finish_action()
        gs:traffic()
        gs:advance(2.1)
        gs:set_tp(1100)
        gs:play(3)
        assert.same(savage_blade, autoy.actions(gs))
    end)

    it('holds back while another action is under way', function()
        local gs = boot('Savage Blade 1000')
        gs:type('/ma "Haste" <me>')
        gs:traffic()
        gs:set_tp(1000)
        gs:play(5)
        assert.same({}, autoy.actions(gs))
    end)

    -- The toad's size is 1 yalm.
    it('holds back when the target is farther than 19.7 yalms past its size, even for a ranged weapon skill', function()
        local gs = boot()
        gs:console('gs c set Weapons Bow')
        gs:console('gs c set AutoWS Flaming Arrow 1000')
        gs.game.monster.distance = 20.8 ^ 2
        gs:traffic()
        gs:set_tp(1000)
        assert.same({}, autoy.actions(gs))
        gs.game.monster.distance = 20.6 ^ 2
        gs:set_tp(1100)
        assert.same({{action = 'Flaming Arrow', target = 'Apex Toad'}}, autoy.actions(gs))
    end)

    it('holds back out of melee range, 3.2 yalms past the target\'s size, for a melee weapon skill', function()
        local gs = boot('Savage Blade 1000')
        gs.game.monster.distance = 4.3 ^ 2
        gs:set_tp(1000)
        assert.same({}, autoy.actions(gs))
        gs.game.monster.distance = 4.1 ^ 2
        gs:set_tp(1100)
        assert.same(savage_blade, autoy.actions(gs))
    end)

    it('holds back when the target is dead', function()
        local gs = boot('Savage Blade 1000')
        gs.game.monster.hpp = 0
        gs:set_tp(1000)
        assert.same({}, autoy.actions(gs))
    end)

    it('holds back when the target isn\'t a monster', function()
        local gs = boot('Savage Blade 1000')
        gs.game.target_index = gs.game.player.index
        gs:set_tp(1000)
        assert.same({}, autoy.actions(gs))
    end)

    it('holds back while amnesic', function()
        local gs = boot('Savage Blade 1000')
        gs:gain_buff('amnesia')
        gs:traffic()
        gs:set_tp(1000)
        assert.same({}, autoy.actions(gs))
    end)

    it('waits for 3000 TP on an AM3 choice, to build Aftermath: Lv.3', function()
        local gs = boot('Savage Blade AM3')
        gs:set_tp(2900)
        assert.same({}, autoy.actions(gs))
        gs:set_tp(3000)
        assert.same(savage_blade, autoy.actions(gs))
    end)

    it('uses an AM3 choice at 1000 TP while Aftermath: Lv.3 is up', function()
        local gs = boot('Savage Blade AM3')
        gs:gain_buff('Aftermath: Lv.3')
        gs:traffic()
        gs:set_tp(1000)
        assert.same(savage_blade, autoy.actions(gs))
    end)

    it('doesn\'t take Aftermath: Lv.2 for an AM3 choice', function()
        local gs = boot('Savage Blade AM3')
        gs:gain_buff('Aftermath: Lv.2')
        gs:traffic()
        gs:set_tp(2000)
        assert.same({}, autoy.actions(gs))
    end)

    it('takes Aftermath: Lv.3, a higher level, for an AM2 choice', function()
        local gs = boot('Savage Blade AM2')
        gs:gain_buff('Aftermath: Lv.3')
        gs:traffic()
        gs:set_tp(1000)
        assert.same(savage_blade, autoy.actions(gs))
    end)

    it('waits for 2000 TP on an AM2 choice with no Aftermath up', function()
        local gs = boot('Savage Blade AM2')
        gs:set_tp(1900)
        assert.same({}, autoy.actions(gs))
        gs:set_tp(2000)
        assert.same(savage_blade, autoy.actions(gs))
    end)

    it('goes back to OFF when the weapon set changes, and says so', function()
        local gs = boot('Savage Blade 1000')
        gs:console('gs c set Weapons Crocea')
        assert.equal('OFF', gs.user.state.AutoWS.value)
        assert.equal(1, autoy.count(autoy.chat(gs), 'Auto WS is now OFF.'))
    end)

    it('uses a ranged weapon skill out of melee range', function()
        local gs = boot()
        gs:console('gs c set Weapons Bow')
        gs:console('gs c set AutoWS Flaming Arrow 1000')
        gs.game.monster.distance = 15 ^ 2
        gs:traffic()
        gs:set_tp(1000)
        assert.same({{action = 'Flaming Arrow', target = 'Apex Toad'}}, autoy.actions(gs))
    end)

    it('offers only OFF for a weapon set AutoWS_List has no entry for', function()
        local gs = boot()
        gs:console('gs c set Weapons Crocea')
        gs:console('gs c cycle AutoWS')
        assert.equal('OFF', gs.user.state.AutoWS.value)
    end)
end)

describe('AutoWSRestore under Auto WS', function()
    it('uses Sanguine Blade in place of the choice under 41% HP', function()
        local gs = boot('Savage Blade 1000')
        gs.game.player.vitals.hpp = 40
        gs:set_tp(1000)
        assert.same({{action = 'Sanguine Blade', target = 'Apex Toad'}}, autoy.actions(gs))
    end)

    it('uses Entropy in place of the choice under 31% MP', function()
        local gs = boot('Savage Blade 1000')
        gs.game.player.vitals.mpp = 30
        gs:set_tp(1000)
        assert.same({{action = 'Entropy', target = 'Apex Toad'}}, autoy.actions(gs))
    end)

    it('uses Mystic Boon in place of the choice under 31% MP when it doesn\'t know Entropy', function()
        local gs = boot('Savage Blade 1000')
        for i, id in ipairs(gs.game.weapon_skills) do
            if gs.game.res.weapon_skills[id].en == 'Entropy' then
                table.remove(gs.game.weapon_skills, i)
            end
        end
        gs.game.player.vitals.mpp = 30
        gs:set_tp(1000)
        assert.same({{action = 'Mystic Boon', target = 'Apex Toad'}}, autoy.actions(gs))
    end)

    it('keeps to the choice at 41% HP and 31% MP', function()
        local gs = boot('Savage Blade 1000')
        gs.game.player.vitals.hpp = 41
        gs.game.player.vitals.mpp = 31
        gs:set_tp(1000)
        assert.same(savage_blade, autoy.actions(gs))
    end)

    it('keeps to the choice when turned off', function()
        local gs = boot('Savage Blade 1000')
        gs:console('gs c toggle AutoWSRestore')
        gs.game.player.vitals.hpp = 40
        gs:set_tp(1000)
        assert.same(savage_blade, autoy.actions(gs))
    end)
end)

describe('Sel\'s own auto weapon skill under User-Globals.lua', function()
    it('stays off without RngHelper, and says where melee auto-ws went', function()
        local gs = boot()
        gs:console('gs c toggle AutoWSMode')
        assert.is_false(gs.user.state.AutoWSMode.value)
        assert.equal(1, autoy.count(autoy.chat(gs),
            'Auto Weaponskill Mode only drives RngHelper ranged auto-ws now; melee auto-ws is gs c cycle AutoWS.'))
    end)

    it('uses no weapon skill from the tick, whatever the TP', function()
        local gs = boot()
        gs.user.state.AutoWSMode:set(true)
        gs.game.player.vitals.tp = 3000
        gs:play(2)
        assert.same({}, autoy.actions(gs))
    end)

    it('gs c autows says melee auto-ws is set per weapon now', function()
        local gs = boot()
        gs:console('gs c autows Savage Blade')
        assert.equal(1, autoy.count(autoy.chat(gs),
            'Melee auto-ws is set per weapon in AutoWS_List; cycle it with gs c cycle AutoWS.'))
    end)
end)
