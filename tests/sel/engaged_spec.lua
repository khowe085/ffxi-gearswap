local harness = require('harness')
local testy = require('testy')

-- Testy as a red mage with the idle set on.
local function boot()
    local gs = harness.boot(testy.rdm())
    gs:console('gs c update')
    gs:traffic()
    return gs
end

-- What is worn with this engaged set on over the idle set.
local function engaged_in(head, body)
    return testy.worn_by(testy.rdm_idle, {head = head, body = body})
end

describe('Sel\'s engaged set', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is sets.engaged in the Normal offense and hybrid modes', function()
        gs:engage()
        assert.same(engaged_in("Bunzi's Hat", 'Lethargy Sayon +3'), gs:worn())
    end)

    it('is sets.engaged[offense mode]', function()
        gs:console('gs c set OffenseMode Acc')
        gs:engage()
        assert.same(engaged_in("Bunzi's Hat", 'Malignance Tabard'), gs:worn())
    end)

    it('is sets.engaged[hybrid mode] in the Normal offense mode', function()
        gs:console('gs c set HybridMode DT')
        gs:engage()
        assert.same(engaged_in('Malignance Chapeau', 'Lethargy Sayon +3'), gs:worn())
    end)

    it('is sets.engaged[offense mode][hybrid mode] in both', function()
        gs:console('gs c set OffenseMode Acc')
        gs:console('gs c set HybridMode DT')
        gs:engage()
        assert.same(engaged_in('Malignance Chapeau', 'Malignance Tabard'), gs:worn())
    end)

    it('follows a mode changed while engaged', function()
        gs:engage()
        gs:console('gs c set OffenseMode Acc')
        assert.same(engaged_in("Bunzi's Hat", 'Malignance Tabard'), gs:worn())
        gs:console('gs c set HybridMode DT')
        assert.same(engaged_in('Malignance Chapeau', 'Malignance Tabard'), gs:worn())
        gs:console('gs c set OffenseMode Normal')
        assert.same(engaged_in('Malignance Chapeau', 'Lethargy Sayon +3'), gs:worn())
    end)

    it('stays sets.engaged in an offense mode it has no set for', function()
        gs:console('gs c set OffenseMode Att')
        gs:engage()
        assert.same(engaged_in("Bunzi's Hat", 'Lethargy Sayon +3'), gs:worn())
    end)

    it('skips an offense mode it has no set for and goes on to the hybrid mode', function()
        gs:console('gs c set OffenseMode Att')
        gs:console('gs c set HybridMode DT')
        gs:engage()
        assert.same(engaged_in('Malignance Chapeau', 'Lethargy Sayon +3'), gs:worn())
    end)

    it('stays at the offense mode\'s set when that has no set for the hybrid mode', function()
        gs:console('gs c set HybridMode Tank')
        gs:engage()
        assert.same(engaged_in('Kaykaus Mitra +1', 'Lethargy Sayon +3'), gs:worn())
        gs:console('gs c set OffenseMode Acc')
        assert.same(engaged_in("Bunzi's Hat", 'Malignance Tabard'), gs:worn())
    end)

    it('gives way to the idle set on disengaging', function()
        gs:engage()
        gs:disengage()
        assert.same(testy.worn_by(testy.rdm_idle), gs:worn())
    end)

    it('isn\'t worn out of melee range, where the idle set stays on', function()
        gs.game.monster.distance = 20 ^ 2
        gs:engage()
        assert.same(testy.worn_by(testy.rdm_idle), gs:worn())
    end)
end)

describe('Sel\'s engaged set for a weapon set', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set Weapons Crocea')
    end)

    it('takes the place of sets.engaged', function()
        gs:engage()
        assert.same(testy.worn_by(testy.rdm_idle, {main = 'Crocea Mors', head = 'Kaykaus Mitra +1',
            body = 'Atrophy Tabard +3'}), gs:worn())
    end)

    it('stays on in an offense mode it has no set for', function()
        gs:console('gs c set OffenseMode Acc')
        gs:engage()
        assert.same(testy.worn_by(testy.rdm_idle, {main = 'Crocea Mors', head = 'Kaykaus Mitra +1',
            body = 'Atrophy Tabard +3'}), gs:worn())
    end)
end)
