local testy = require('testy')

local boot = testy.boot_rdm

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

describe('gs test engaged under Sel', function()
    it('puts on, over a naked character, the engaged set Sel picks for the offense and hybrid modes, while the '
        .. 'player is idle', function()
        local gs = boot()
        gs:console('gs c set OffenseMode Acc')
        gs:console('gs c set HybridMode DT')
        gs:console('gs test engaged')
        assert.same({main = 'Daybreak', sub = 'Ammurapi Shield', head = 'Malignance Chapeau',
            body = 'Malignance Tabard'}, gs:worn())
    end)

    it('puts on the weapon set\'s engaged set with its weapons in hand', function()
        local gs = boot()
        gs:console('gs c set Weapons Crocea')
        gs:console('gs test engaged')
        assert.same({main = 'Crocea Mors', sub = 'Ammurapi Shield', head = 'Kaykaus Mitra +1',
            body = 'Atrophy Tabard +3'}, gs:worn())
    end)

    it('puts on the engaged set with nothing targeted, as User-Globals.lua has it for a test', function()
        local gs = boot()
        gs.game:target(nil)
        gs:console('gs c set OffenseMode Acc')
        gs:console('gs test engaged')
        assert.same({main = 'Daybreak', sub = 'Ammurapi Shield', head = "Bunzi's Hat", body = 'Malignance Tabard'},
            gs:worn())
    end)

    it('puts on the engaged set with the target out of melee range', function()
        local gs = boot()
        gs.game.monster.distance = 20 ^ 2
        gs:console('gs c set OffenseMode Acc')
        gs:console('gs test engaged')
        assert.same({main = 'Daybreak', sub = 'Ammurapi Shield', head = "Bunzi's Hat", body = 'Malignance Tabard'},
            gs:worn())
    end)

    it('puts the weapon set in hand with UnlockWeapons on, as the engaged hold would', function()
        local gs = boot()
        gs:console('gs c set Weapons Crocea')
        gs:console('gs c toggle UnlockWeapons')
        gs:console('gs test engaged')
        assert.same({main = 'Crocea Mors', sub = 'Ammurapi Shield', head = 'Kaykaus Mitra +1',
            body = 'Atrophy Tabard +3'}, gs:worn())
    end)

    it('leaves no engaged hold on the weapons once a bare gs enable ends it, with UnlockWeapons on', function()
        local gs = boot()
        gs:console('gs c set Weapons Naegling')
        gs:console('gs c toggle UnlockWeapons')
        gs:console('gs test engaged')
        gs:console('gs enable')
        gs:console('gs test set sets.midcast.Cure')
        assert.same({main = "Bunzi's Rod", head = 'Kaykaus Mitra +1'}, gs:worn())
    end)
end)
