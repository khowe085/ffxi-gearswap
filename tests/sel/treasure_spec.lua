local commy = require('commy')

local idle = commy.rdm_idle

-- Whether sets.TreasureHunter of Commy_Rdm_Gear.lua is on.
local function wearing_th(gs)
    local worn = gs:worn()
    return worn.head == 'Volte Cap' and worn.legs == 'Volte Hose'
end

-- Casts the spell at the monster and returns whether sets.TreasureHunter was on for it, once it was out.
local function spell_wears_th(gs, name)
    commy.cast(gs, ('/ma "%s" <t>'):format(name))
    return wearing_th(gs)
end

local function dia_wears_th(gs)
    return spell_wears_th(gs, 'Dia')
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
        gs:console('gs c set Weapons Naegling')
        gs:set_tp(1000)
        gs:traffic()
        gs:type('/ws "Savage Blade" <t>')
        assert.same({
            {equip = {head = 'Volte Cap', body = 'Atrophy Tabard +3', legs = 'Volte Hose'}},
            {action = 'Savage Blade', target = 'Apex Toad'},
        }, gs:traffic())
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
        gs:change_zone(100)
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
        gs:monster_acts(1)
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

-- Commy with Dia and Savage Blade in TH_Whitelist, as a gear file names them in user_job_setup.
local function boot_with_whitelist()
    local gs = commy.boot_rdm()
    gs.user.TH_Whitelist = gs.user.S{'Dia', 'Savage Blade'}
    return gs
end

describe('User-Globals.lua\'s Treasure Hunter with a TH_Whitelist in Tag mode', function()
    local gs
    before_each(function()
        gs = boot_with_whitelist()
    end)

    it('lays sets.TreasureHunter over the midcast set of a spell on the list at a monster it hasn\'t tagged', function()
        assert.is_true(dia_wears_th(gs))
    end)

    it('leaves it off a spell not on the list', function()
        assert.is_false(spell_wears_th(gs, 'Bio'))
    end)

    it('takes the monster for tagged once a spell on the list lands', function()
        tag_with_dia(gs)
        assert.is_false(dia_wears_th(gs))
    end)

    it('doesn\'t take the monster for tagged by a spell not on the list', function()
        assert.is_false(spell_wears_th(gs, 'Bio'))
        gs:finish_action()
        gs:advance(5)
        assert.is_true(dia_wears_th(gs))
    end)

    it('keeps a tagged monster tagged when a spell not on the list lands on it', function()
        tag_with_dia(gs)
        assert.is_false(spell_wears_th(gs, 'Bio'))
        gs:finish_action()
        gs:advance(5)
        assert.is_false(dia_wears_th(gs))
    end)

    it('takes every monster an area spell on the list lands on for tagged', function()
        gs.user.TH_Whitelist = gs.user.S{'Dia', 'Diaga', 'Savage Blade'}
        local other = gs.game:add_mob({name = 'Apex Bat', monster = true, distance = 9})
        assert.is_true(spell_wears_th(gs, 'Diaga'))
        -- The server tells of Diaga landing on both monsters.
        local landed = {message = 2, param = 0, reaction = 0, animation = 0, effect = 0, stagger = 0}
        gs:send_action_packet({category = 4, param = 33, recast = 0,
            targets = {{id = gs.game.monster.id, actions = {landed}}, {id = other.id, actions = {landed}}}})
        gs:advance(5)
        gs.game:target(other.index)
        assert.is_false(dia_wears_th(gs))
    end)

    -- The gear put on before the weapon skill went out, with Naegling in hand.
    local function weaponskill_precast(line)
        gs:console('gs c set Weapons Naegling')
        gs:set_tp(1000)
        gs:traffic()
        gs:type(line)
        local traffic = gs:traffic()
        assert.is_truthy(traffic[2] and traffic[2].action, 'the weapon skill didn\'t go out')
        return traffic[1].equip
    end

    it('lays it over the precast set of a weapon skill on the list', function()
        assert.same({head = 'Volte Cap', body = 'Atrophy Tabard +3', legs = 'Volte Hose'},
            weaponskill_precast('/ws "Savage Blade" <t>'))
    end)

    it('leaves it off a weapon skill not on the list', function()
        assert.same({head = 'Kaykaus Mitra +1', body = 'Atrophy Tabard +3'},
            weaponskill_precast('/ws "Vorpal Blade" <t>'))
    end)

    it('lays it over a ranged attack\'s precast set at a monster it hasn\'t tagged', function()
        gs:type('/ra <t>')
        assert.same({
            {equip = {head = 'Volte Cap', legs = 'Volte Hose'}},
            {action = 'category 16', target = 'Apex Toad'},
        }, gs:traffic())
    end)

    it('leaves it off a ranged attack at a monster it tagged', function()
        tag_with_dia(gs)
        gs:traffic()
        gs:type('/ra <t>')
        assert.same({{action = 'category 16', target = 'Apex Toad'}}, gs:traffic())
    end)

    it('leaves it off when Commy engages', function()
        gs:engage()
        assert.same(commy.worn_by(idle, {head = "Bunzi's Hat", body = 'Lethargy Sayon +3'}), gs:worn())
    end)

    it('doesn\'t take the monster for tagged by a melee hit', function()
        gs:engage()
        commy.hit(gs)
        assert.is_true(dia_wears_th(gs))
    end)
end)

describe('User-Globals.lua\'s Treasure Hunter with a TH_Whitelist in None mode', function()
    it('leaves sets.TreasureHunter off a ranged attack', function()
        local gs = boot_with_whitelist()
        gs:console('gs c set TreasureMode None')
        gs:traffic()
        gs:type('/ra <t>')
        assert.same({{action = 'category 16', target = 'Apex Toad'}}, gs:traffic())
    end)
end)
