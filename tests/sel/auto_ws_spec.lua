local autoy = require('autoy')

-- Autoy with Naegling locked in hand, engaged on the toad three yalms off, Auto WS set to the choice given. The
-- options: abilities, the abilities and weapon skills Autoy knows (as for a boot), and weapons, another weapon set
-- to lock in hand.
local function boot(choice, options)
    options = options or {}
    local gs = autoy.boot({abilities = options.abilities})
    gs:console('gs c set Weapons ' .. (options.weapons or 'Naegling'))
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
        assert.same(savage_blade, gs:action_entries())
    end)

    it('holds back under the choice\'s TP', function()
        local gs = boot('Savage Blade 1750')
        gs:set_tp(1500)
        assert.same({}, gs:action_entries())
        gs:set_tp(1750)
        assert.same(savage_blade, gs:action_entries())
    end)

    it('holds back while OFF', function()
        local gs = boot()
        gs:set_tp(3000)
        assert.same({}, gs:action_entries())
    end)

    it('holds back while not engaged', function()
        local gs = boot('Savage Blade 1000')
        gs:disengage()
        gs:traffic()
        gs:set_tp(1000)
        assert.same({}, gs:action_entries())
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
        assert.same({}, gs:action_entries())
        gs:set_tp(1200)
        gs:play(3)
        assert.same(savage_blade, gs:action_entries())
    end)

    it('sends another on a TP change just past the two seconds', function()
        local gs = boot('Savage Blade 1000')
        gs:set_tp(1000)
        gs:finish_action()
        gs:traffic()
        gs:advance(2.1)
        gs:set_tp(1100)
        gs:play(3)
        assert.same(savage_blade, gs:action_entries())
    end)

    it('holds back while another action is under way', function()
        local gs = boot('Savage Blade 1000')
        gs:type('/ma "Haste" <me>')
        gs:traffic()
        gs:set_tp(1000)
        gs:play(5)
        assert.same({}, gs:action_entries())
    end)

    -- The toad's size is 1 yalm.
    it('holds back when the target is farther than 19.7 yalms past its size, even for a ranged weapon skill', function()
        local gs = boot()
        gs:console('gs c set Weapons Bow')
        gs:console('gs c set AutoWS Flaming Arrow 1000')
        gs.game.monster.distance = 20.8 ^ 2
        gs:traffic()
        gs:set_tp(1000)
        assert.same({}, gs:action_entries())
        gs.game.monster.distance = 20.6 ^ 2
        gs:set_tp(1100)
        assert.same({{action = 'Flaming Arrow', target = 'Apex Toad'}}, gs:action_entries())
    end)

    it('holds back out of melee range, 3.2 yalms past the target\'s size, for a melee weapon skill', function()
        local gs = boot('Savage Blade 1000')
        gs.game.monster.distance = 4.3 ^ 2
        gs:set_tp(1000)
        assert.same({}, gs:action_entries())
        gs.game.monster.distance = 4.1 ^ 2
        gs:set_tp(1100)
        assert.same(savage_blade, gs:action_entries())
    end)

    it('holds back when the target is dead', function()
        local gs = boot('Savage Blade 1000')
        gs.game.monster.hpp = 0
        gs:set_tp(1000)
        assert.same({}, gs:action_entries())
    end)

    it('holds back when the target isn\'t a monster', function()
        local gs = boot('Savage Blade 1000')
        gs.game.target_index = gs.game.player.index
        gs:set_tp(1000)
        assert.same({}, gs:action_entries())
    end)

    -- Sel refuses a weapon skill typed while amnesic with an "Abort: ..." line, so this reads the chat too.
    it('holds back while amnesic', function()
        local gs = boot('Savage Blade 1000')
        gs:gain_buff('amnesia')
        gs:traffic()
        gs:chat()
        gs:set_tp(1000)
        assert.same({}, gs:action_entries())
        assert.same({}, gs:chat())
    end)

    it('waits for 3000 TP on an AM3 choice, to build Aftermath: Lv.3', function()
        local gs = boot('Savage Blade AM3')
        gs:set_tp(2900)
        assert.same({}, gs:action_entries())
        gs:set_tp(3000)
        assert.same(savage_blade, gs:action_entries())
    end)

    it('uses an AM3 choice at 1000 TP while Aftermath: Lv.3 is up', function()
        local gs = boot('Savage Blade AM3')
        gs:gain_buff('Aftermath: Lv.3')
        gs:traffic()
        gs:set_tp(1000)
        assert.same(savage_blade, gs:action_entries())
    end)

    it('doesn\'t take Aftermath: Lv.2 for an AM3 choice', function()
        local gs = boot('Savage Blade AM3')
        gs:gain_buff('Aftermath: Lv.2')
        gs:traffic()
        gs:set_tp(2000)
        assert.same({}, gs:action_entries())
    end)

    it('takes Aftermath: Lv.3, a higher level, for an AM2 choice', function()
        local gs = boot('Savage Blade AM2')
        gs:gain_buff('Aftermath: Lv.3')
        gs:traffic()
        gs:set_tp(1000)
        assert.same(savage_blade, gs:action_entries())
    end)

    it('waits for 2000 TP on an AM2 choice with no Aftermath up', function()
        local gs = boot('Savage Blade AM2')
        gs:set_tp(1900)
        assert.same({}, gs:action_entries())
        gs:set_tp(2000)
        assert.same(savage_blade, gs:action_entries())
    end)

    it('goes back to OFF when the weapon set changes, and says so', function()
        local gs = boot('Savage Blade 1000')
        gs:console('gs c set Weapons Crocea')
        assert.equal('OFF', gs.user.state.AutoWS.value)
        assert.equal(1, autoy.count(gs:chat(), 'Auto WS is now OFF.'))
    end)

    it('uses a ranged weapon skill out of melee range', function()
        local gs = boot()
        gs:console('gs c set Weapons Bow')
        gs:console('gs c set AutoWS Flaming Arrow 1000')
        gs.game.monster.distance = 15 ^ 2
        gs:traffic()
        gs:set_tp(1000)
        assert.same({{action = 'Flaming Arrow', target = 'Apex Toad'}}, gs:action_entries())
    end)

    it('offers only OFF for a weapon set AutoWS_List has no entry for', function()
        local gs = boot()
        gs:console('gs c set Weapons Crocea')
        gs:console('gs c cycle AutoWS')
        assert.equal('OFF', gs.user.state.AutoWS.value)
    end)
end)

describe('AutoWSRestore under Auto WS', function()
    -- The game lists only the weapon skills of the weapon in hand: of those the restore picks from, Sanguine Blade
    -- is a sword's, which the bow set's Naegling gives. Mystic Boon comes only with Yagrush, a white mage's club, so
    -- the boot names it among the abilities, and Daybreak is there for its AutoWS_List choice.
    local sword = {abilities = {'Savage Blade', 'Sanguine Blade'}}
    local bow = {weapons = 'Bow', abilities = {'Flaming Arrow', 'Sanguine Blade'}}
    local club = {weapons = 'Daybreak', abilities = {'Black Halo', 'Mystic Boon'}}

    it('uses Sanguine Blade in place of the choice under 41% HP', function()
        local gs = boot('Savage Blade 1000', sword)
        gs.game.player.vitals.hpp = 40
        gs:set_tp(1000)
        assert.same({{action = 'Sanguine Blade', target = 'Apex Toad'}}, gs:action_entries())
    end)

    it('keeps to the choice under 31% MP with a sword, which has no MP weapon skill', function()
        local gs = boot('Savage Blade 1000', sword)
        gs.game.player.vitals.mpp = 30
        gs:set_tp(1000)
        assert.same(savage_blade, gs:action_entries())
    end)

    it('keeps to the choice at 41% HP', function()
        local gs = boot('Savage Blade 1000', sword)
        gs.game.player.vitals.hpp = 41
        gs:set_tp(1000)
        assert.same(savage_blade, gs:action_entries())
    end)

    it('keeps to a ranged choice under 41% HP out of melee range, where it restores nothing', function()
        local gs = boot('Flaming Arrow 1000', bow)
        gs.game.monster.distance = 15 ^ 2
        gs.game.player.vitals.hpp = 40
        gs:set_tp(1000)
        assert.same({{action = 'Flaming Arrow', target = 'Apex Toad'}}, gs:action_entries())
    end)

    it('uses Mystic Boon in place of the choice under 31% MP when the game lists Mystic Boon', function()
        local gs = boot('Black Halo 1000', club)
        gs.game.player.vitals.mpp = 30
        gs:set_tp(1000)
        assert.same({{action = 'Mystic Boon', target = 'Apex Toad'}}, gs:action_entries())
    end)

    it('keeps to the choice at 31% MP when the game lists Mystic Boon', function()
        local gs = boot('Black Halo 1000', club)
        gs.game.player.vitals.mpp = 31
        gs:set_tp(1000)
        assert.same({{action = 'Black Halo', target = 'Apex Toad'}}, gs:action_entries())
    end)

    it('keeps to the choice when turned off', function()
        local gs = boot('Savage Blade 1000', sword)
        gs:console('gs c toggle AutoWSRestore')
        gs.game.player.vitals.hpp = 40
        gs:set_tp(1000)
        assert.same(savage_blade, gs:action_entries())
    end)
end)

describe('Sel\'s own auto weapon skill under User-Globals.lua', function()
    it('stays off without RngHelper, and says where melee auto-ws went', function()
        local gs = boot()
        gs:console('gs c toggle AutoWSMode')
        assert.is_false(gs.user.state.AutoWSMode.value)
        assert.equal(1, autoy.count(gs:chat(),
            'Auto Weaponskill Mode only drives RngHelper ranged auto-ws now; melee auto-ws is gs c cycle AutoWS.'))
    end)

    it('uses no weapon skill from the tick, whatever the TP', function()
        local gs = boot()
        gs.user.state.AutoWSMode:set(true)
        gs:set_tp(3000)
        gs:play(2)
        assert.same({}, gs:action_entries())
    end)

    it('gs c autows says melee auto-ws is set per weapon now', function()
        local gs = boot()
        gs:console('gs c autows Savage Blade')
        assert.equal(1, autoy.count(gs:chat(),
            'Melee auto-ws is set per weapon in AutoWS_List; cycle it with gs c cycle AutoWS.'))
    end)
end)
