local harness = require('harness')
local testy = require('testy')

-- Testy as a red mage with the idle set on.
local function boot()
    local gs = harness.boot(testy.rdm())
    gs:console('gs c update')
    gs:traffic()
    return gs
end

-- What was sent before the spell went out: the precast set, as the pieces it changed.
local function precast(gs, line)
    gs:type(line)
    local traffic = gs:traffic()
    assert.is_truthy(traffic[2] and traffic[2].action, 'the spell didn\'t go out')
    return traffic[1].equip
end

-- What is worn once the spell is out: the midcast set over the precast set over the idle set.
local function midcast(gs, line)
    gs:type(line)
    return gs:worn()
end

describe('Sel\'s precast set for a spell', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is sets.precast.FC for a spell with no set of its own', function()
        assert.same({head = "Bunzi's Hat", left_ring = 'Kishar Ring'}, precast(gs, '/ma "Slow" <t>'))
    end)

    it('is sets.precast.FC[skill] for a spell of that skill', function()
        assert.same({head = "Bunzi's Hat", left_ring = 'Kishar Ring', body = 'Atrophy Tabard +3'},
            precast(gs, '/ma "Haste" <me>'))
    end)

    it('is sets.precast.FC[name] ahead of the skill\'s set', function()
        assert.same({head = "Bunzi's Hat", left_ring = 'Kishar Ring', body = 'Lethargy Sayon +3'},
            precast(gs, '/ma "Refresh" <me>'))
    end)

    it('is sets.precast.FC[spell map] for a spell Sel maps', function()
        assert.same({head = "Bunzi's Hat", left_ring = 'Kishar Ring', body = 'Malignance Tabard'},
            precast(gs, '/ma "Cure III" <me>'))
    end)

    it('is the Cure set for a Curaga', function()
        assert.same({head = "Bunzi's Hat", left_ring = 'Kishar Ring', body = 'Malignance Tabard'},
            precast(gs, '/ma "Curaga" <me>'))
    end)
end)

describe('Sel\'s midcast set for a spell', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is sets.midcast.FastRecast for a spell with no set of its own', function()
        assert.same(testy.worn_by(testy.rdm_idle, {head = 'Malignance Chapeau', ring1 = 'Kishar Ring'}),
            midcast(gs, '/ma "Fire III" <t>'))
    end)

    it('is sets.midcast[name], over FastRecast', function()
        assert.same(testy.worn_by(testy.rdm_idle, {head = 'Malignance Chapeau', body = 'Atrophy Tabard +3',
            ring1 = 'Kishar Ring'}), midcast(gs, '/ma "Refresh" <me>'))
    end)

    it('is sets.midcast[spell map] for a spell Sel maps', function()
        assert.same(testy.worn_by(testy.rdm_idle, {main = "Bunzi's Rod", head = 'Kaykaus Mitra +1',
            body = 'Malignance Tabard', ring1 = 'Kishar Ring'}), midcast(gs, '/ma "Cure III" <me>'))
    end)

    it('is the Cure set for a Curaga', function()
        assert.same(testy.worn_by(testy.rdm_idle, {main = "Bunzi's Rod", head = 'Kaykaus Mitra +1',
            body = 'Malignance Tabard', ring1 = 'Kishar Ring'}), midcast(gs, '/ma "Curaga" <me>'))
    end)

    it('is sets.midcast[skill] for a spell of that skill', function()
        assert.same(testy.worn_by(testy.rdm_idle, {head = 'Malignance Chapeau', body = 'Malignance Tabard',
            ring1 = 'Kishar Ring'}), midcast(gs, '/ma "Slow" <t>'))
    end)

    it('is sets.midcast[skill] for an enhancing spell with no set of its own', function()
        assert.same(testy.worn_by(testy.rdm_idle, {head = 'Malignance Chapeau', body = 'Lethargy Sayon +3',
            ring1 = 'Kishar Ring'}), midcast(gs, '/ma "Haste" <me>'))
    end)

    it('is the set\'s casting mode sub-table in that casting mode', function()
        gs:console('gs c set CastingMode Resistant')
        gs:traffic()
        assert.same(testy.worn_by(testy.rdm_idle, {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard',
            ring1 = 'Kishar Ring'}), midcast(gs, '/ma "Slow" <t>'))
    end)

    it('stays the set above in a casting mode it has no sub-table for', function()
        gs:console('gs c set CastingMode Resistant')
        gs:traffic()
        assert.same(testy.worn_by(testy.rdm_idle, {head = 'Malignance Chapeau', body = 'Lethargy Sayon +3',
            ring1 = 'Kishar Ring'}), midcast(gs, '/ma "Haste" <me>'))
    end)
end)

describe('a spell under Sel', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('goes out after the precast set, and the midcast set goes on after it, in one typed line', function()
        assert.is_true(gs:type('/ma "Cure III" <me>'))
        assert.same({
            {equip = {head = "Bunzi's Hat", left_ring = 'Kishar Ring', body = 'Malignance Tabard'}},
            {action = 'Cure III', target = 'Testy'},
            {equip = {main = "Bunzi's Rod", head = 'Kaykaus Mitra +1'}},
        }, gs:traffic())
    end)

    it('gives way to the idle set once the server says it is done', function()
        gs:type('/ma "Cure III" <me>')
        gs:finish_action()
        assert.same(testy.worn_by(testy.rdm_idle), gs:worn())
    end)

    it('gives way to the idle set when interrupted', function()
        gs:type('/ma "Cure III" <me>')
        gs:interrupt_action()
        assert.same(testy.worn_by(testy.rdm_idle), gs:worn())
    end)

    it('gives way to the engaged set when engaged, a slot it leaves out keeping the spell\'s piece', function()
        gs:engage()
        gs:type('/ma "Cure III" <me>')
        gs:finish_action()
        assert.same(testy.worn_by(testy.rdm_idle, {head = "Bunzi's Hat", body = 'Lethargy Sayon +3',
            ring1 = 'Kishar Ring'}), gs:worn())
    end)
end)
