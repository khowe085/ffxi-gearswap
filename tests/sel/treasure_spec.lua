local commy = require('commy')

local idle = commy.rdm_idle

-- Whether sets.TreasureHunter of Commy_Rdm_Gear.lua is on.
local function wearing_th(gs)
    local worn = gs:worn()
    return worn.head == 'Volte Cap' and worn.legs == 'Volte Hose'
end

-- Casts Dia at the monster and returns whether sets.TreasureHunter was on for it, once it was out.
local function dia_wears_th(gs)
    local sent = #gs.game.actions
    gs:type('/ma "Dia" <t>')
    assert.equal(sent + 1, #gs.game.actions, 'Dia didn\'t go out')
    return wearing_th(gs)
end

-- Casts Dia at the monster and lets it land, which tags the monster.
local function tag_with_dia(gs)
    assert.is_true(dia_wears_th(gs))
    gs:finish_action()
    gs:advance(5)
end

describe('Sel\'s Treasure Hunter in Tag mode', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        assert.equal('Tag', gs.user.state.TreasureMode.value)
    end)

    it('lays sets.TreasureHunter over a spell\'s midcast set at a monster it hasn\'t tagged', function()
        assert.is_true(dia_wears_th(gs))
    end)

    it('leaves the spell\'s precast set as it is', function()
        gs:type('/ma "Dia" <t>')
        assert.same({head = "Bunzi's Hat", left_ring = 'Kishar Ring'}, gs:traffic()[1].equip)
    end)

    it('takes the monster for tagged once the spell lands, and leaves the set off the next one at it', function()
        tag_with_dia(gs)
        assert.is_false(dia_wears_th(gs))
    end)

    it('takes it off again after the spell', function()
        gs:type('/ma "Dia" <t>')
        gs:finish_action()
        assert.same(commy.worn_by(idle), gs:worn())
    end)

    it('lays it over a weapon skill\'s precast set at a monster it hasn\'t tagged', function()
        gs.game.player.vitals.tp = 1000
        gs:type('/ws "Savage Blade" <t>')
        assert.same({head = 'Volte Cap', body = 'Atrophy Tabard +3', legs = 'Volte Hose'}, gs:traffic()[1].equip)
    end)

    it('leaves it off a spell at Commy', function()
        gs:type('/ma "Cure III" <me>')
        assert.is_false(wearing_th(gs))
    end)

    it('forgets a monster that dies, and lays the set on for the next spell at that id', function()
        tag_with_dia(gs)
        commy.defeat(gs)
        assert.is_true(dia_wears_th(gs))
    end)

    it('forgets every monster on zoning', function()
        tag_with_dia(gs)
        commy.game(gs, 'change_zone', 288)
        assert.is_true(dia_wears_th(gs))
    end)

    it('forgets a monster three minutes after the last action on it or by it', function()
        tag_with_dia(gs)
        gs:advance(181)
        gs:type('/ma "Cure III" <me>')
        gs:finish_action()
        gs:advance(5)
        assert.is_true(dia_wears_th(gs))
    end)

    it('keeps a monster that acted in the last three minutes', function()
        tag_with_dia(gs)
        gs:advance(100)
        commy.monster_acts(gs, 1)
        gs:advance(100)
        gs:type('/ma "Cure III" <me>')
        gs:finish_action()
        gs:advance(5)
        assert.is_false(dia_wears_th(gs))
    end)

    it('doesn\'t take a monster for tagged by a spell cast in a defense mode', function()
        gs:console('gs c set DefenseMode Magical')
        gs:type('/ma "Dia" <t>')
        gs:finish_action()
        gs:advance(5)
        gs:console('gs c reset DefenseMode')
        assert.is_true(dia_wears_th(gs))
    end)
end)

describe('Sel\'s Treasure Hunter on engaging in Tag mode', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('holds sets.TreasureHunter on over the engaged set at a monster it hasn\'t tagged', function()
        gs:engage()
        assert.same(commy.worn_by(idle, {head = 'Volte Cap', body = 'Lethargy Sayon +3', legs = 'Volte Hose'}),
            gs:worn())
        gs:console('gs c update')
        assert.is_true(wearing_th(gs))
    end)

    it('lets it go once a melee hit lands', function()
        gs:engage()
        commy.hit(gs)
        assert.same(commy.worn_by(idle, {head = "Bunzi's Hat", body = 'Lethargy Sayon +3'}), gs:worn())
    end)

    it('lets it go on disengaging', function()
        gs:engage()
        gs:disengage()
        assert.same(commy.worn_by(idle), gs:worn())
    end)

    it('lets it go when TreasureMode goes to None', function()
        gs:engage()
        gs:console('gs c set TreasureMode None')
        assert.same(commy.worn_by(idle, {head = "Bunzi's Hat", body = 'Lethargy Sayon +3'}), gs:worn())
    end)

    it('lets it go while a defense mode is on, and holds it again once the defense mode is off', function()
        gs:engage()
        gs:console('gs c set DefenseMode Physical')
        assert.same(commy.worn_by(idle, {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard'}), gs:worn())
        gs:console('gs c reset DefenseMode')
        assert.is_true(wearing_th(gs))
    end)

    it('holds it on when TreasureMode goes from None to Tag', function()
        gs:console('gs c set TreasureMode None')
        gs:engage()
        assert.is_false(wearing_th(gs))
        gs:console('gs c set TreasureMode Tag')
        assert.is_true(wearing_th(gs))
    end)

    it('puts nothing on at a monster it tagged already', function()
        tag_with_dia(gs)
        gs:engage()
        assert.same(commy.worn_by(idle, {head = "Bunzi's Hat", body = 'Lethargy Sayon +3'}), gs:worn())
    end)
end)

describe('Sel\'s Treasure Hunter in None mode', function()
    it('leaves sets.TreasureHunter off spells and engaging', function()
        local gs = commy.boot_rdm()
        gs:console('gs c set TreasureMode None')
        assert.is_false(dia_wears_th(gs))
        gs:finish_action()
        gs:engage()
        assert.is_false(wearing_th(gs))
    end)
end)
