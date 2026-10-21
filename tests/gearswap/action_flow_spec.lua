local plain = require('plain')
local testy = require('testy')

local calls, events = plain.calls, plain.names

describe('a spell typed in the chat', function()
    local gs
    before_each(function()
        gs = plain.boot()
        calls(gs)
    end)

    it('goes out after the precast set, and the midcast set goes on after it', function()
        assert.is_true(gs:type('/ma "Cure III" <me>'))
        assert.same({
            {equip = {head = "Bunzi's Hat", left_ring = 'Kishar Ring'}},
            {action = 'Cure III', target = 'Testy'},
            {equip = {head = 'Kaykaus Mitra +1'}},
        }, gs:traffic())
        assert.same({}, gs:typed())
    end)

    it('hands pretarget, precast and midcast the spell and its target', function()
        gs:type('/ma "Cure III" <me>')
        local expected = {name = 'Cure III', target = 'Testy', type = 'WhiteMagic', action_type = 'Magic'}
        local got = calls(gs)
        assert.same({'pretarget', 'precast', 'midcast'}, {got[1].event, got[2].event, got[3].event})
        for i = 1, 3 do
            got[i].event = nil
            assert.same(expected, got[i])
        end
    end)

    it('runs precast and midcast on the typed line, before the server has answered', function()
        gs:type('/ma "Cure III" <me>')
        assert.same({'pretarget', 'precast', 'midcast'}, events(calls(gs)))
        assert.equal(1, #gs.game.actions)
        assert.same(testy.worn_by(testy.whm_idle, {head = 'Kaykaus Mitra +1', ring1 = 'Kishar Ring'}), gs:worn())
    end)

    it('aimed at the monster with <t> has the monster as its target', function()
        gs:type('/ma "Dia II" <t>')
        assert.same({
            {equip = {head = "Bunzi's Hat", left_ring = 'Kishar Ring'}},
            {action = 'Dia II', target = 'Apex Toad'},
        }, gs:traffic())
        local got = calls(gs)
        assert.same({'pretarget', 'precast', 'midcast'}, events(got))
        assert.same({'Apex Toad', 'Apex Toad', 'Apex Toad'}, {got[1].target, got[2].target, got[3].target})
    end)

    it('is in midaction from the typed line until its aftercast', function()
        assert.is_false(gs.user.midaction())
        gs:type('/ma "Cure III" <me>')
        local midaction, spell = gs.user.midaction()
        assert.is_true(midaction)
        assert.equal('Cure III', spell.english)
        gs:finish_action()
        assert.is_false(gs.user.midaction())
    end)

    it('is no longer in midaction once it is interrupted', function()
        gs:type('/ma "Cure III" <me>')
        gs:interrupt_action()
        assert.is_false(gs.user.midaction())
    end)

    it('doesn\'t send a piece the set names that is already on', function()
        gs:type('/ma "Cure III" <me>')
        assert.is_nil(gs:traffic()[1].equip.neck)
        assert.equal('Loricate Torque +1', gs:worn().neck)
    end)

    it('gets the aftercast set once the server says the spell is done', function()
        gs:type('/ma "Cure III" <me>')
        calls(gs)
        gs:finish_action()
        local got = calls(gs)
        assert.same({'aftercast', 'Cure III'}, {got[1].event, got[1].name})
        assert.is_nil(got[1].interrupted)
        assert.same(testy.worn_by(testy.whm_idle), gs:worn())
    end)

    it('gets the aftercast set, marked interrupted, when the spell is interrupted', function()
        gs:type('/ma "Cure III" <me>')
        calls(gs)
        gs:interrupt_action()
        local got = calls(gs)
        assert.same({'aftercast', 'Cure III', true}, {got[1].event, got[1].name, got[1].interrupted})
        assert.same(testy.worn_by(testy.whm_idle), gs:worn())
    end)

    it('isn\'t sent when precast cancels it, and gets no midcast', function()
        gs.user.cancel_next = true
        assert.is_true(gs:type('/ma "Cure III" <me>'))
        assert.same({{equip = {head = "Bunzi's Hat", left_ring = 'Kishar Ring'}}}, gs:traffic())
        local got = calls(gs)
        assert.same({'pretarget', 'precast'}, {got[1].event, got[2].event, got[3] and got[3].event})
    end)
end)

describe('a weapon skill or job ability typed in the chat', function()
    local gs
    before_each(function()
        gs = plain.boot()
        calls(gs)
    end)

    it('goes out at the target after its precast set', function()
        gs:type('/ws "Black Halo" <t>')
        assert.same({
            {equip = {left_ring = 'Stikini Ring +1', right_ring = 'Defending Ring'}},
            {action = 'Black Halo', target = 'Apex Toad'},
        }, gs:traffic())
        local got = calls(gs)
        assert.same({'precast', 'WeaponSkill', 'Apex Toad'}, {got[2].event, got[2].type, got[2].target})
    end)

    it('takes a job ability the same way', function()
        gs:type('/ja "Divine Seal" <me>')
        assert.same({
            {equip = {head = "Bunzi's Hat"}},
            {action = 'Divine Seal', target = 'Testy'},
        }, gs:traffic())
    end)

    it('gets the aftercast set once the server says the weapon skill is done', function()
        gs:type('/ws "Black Halo" <t>')
        calls(gs)
        gs:finish_action()
        local got = calls(gs)
        assert.same({'aftercast', 'Black Halo', 'WeaponSkill', 'Apex Toad'}, {got[1].event, got[1].name, got[1].type, got[1].target})
        assert.same(testy.worn_by(testy.whm_idle), gs:worn())
    end)

    it('gets the aftercast set once the server says the job ability is done', function()
        gs:type('/ja "Divine Seal" <me>')
        calls(gs)
        gs:finish_action()
        local got = calls(gs)
        assert.same({'aftercast', 'Divine Seal', 'JobAbility', 'Testy'}, {got[1].event, got[1].name, got[1].type, got[1].target})
        assert.same(testy.worn_by(testy.whm_idle), gs:worn())
    end)
end)

describe('a line GearSwap has no action for', function()
    it('reaches the game as it was typed', function()
        local gs = plain.boot()
        assert.equal('/echo hello', gs:type('/echo hello'))
        assert.same({'/echo hello'}, gs:typed())
        assert.same({}, gs:traffic())
    end)
end)

describe('the player\'s status', function()
    it('changing calls status_change, which wears the set for it', function()
        local gs = plain.boot()
        calls(gs)
        gs:engage()
        assert.same({event = 'status_change', extra = {new = 'Engaged', old = 'Idle'}}, calls(gs)[1])
        assert.same({{equip = {main = "Bunzi's Rod"}}}, gs:traffic())
        gs:disengage()
        assert.same(testy.worn_by(testy.whm_idle), gs:worn())
    end)
end)

describe('a GearSwap command', function()
    local gs
    before_each(function()
        gs = plain.boot()
        calls(gs)
    end)

    it('gs equip wears the set it names, without calling a hook', function()
        gs:console('gs equip sets.engaged')
        assert.same({{equip = {main = "Bunzi's Rod"}}}, gs:traffic())
        assert.equal("Bunzi's Rod", gs:worn().main)
        assert.same({}, calls(gs))
    end)

    it('gs disable keeps a slot as it is until gs enable', function()
        gs:console('gs disable head')
        gs:type('/ma "Cure III" <me>')
        assert.same({
            {equip = {left_ring = 'Kishar Ring'}},
            {action = 'Cure III', target = 'Testy'},
        }, gs:traffic())
        gs:finish_action()
        gs:console('gs enable head')
        gs:type('/ma "Cure III" <me>')
        assert.equal('Kaykaus Mitra +1', gs:worn().head)
    end)
end)
