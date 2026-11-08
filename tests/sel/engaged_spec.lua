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

-- What is worn with Crocea Mors in hand and this engaged set on over the idle set.
local function crocea_engaged_in(head, body)
    return testy.worn_by(testy.rdm_idle, {main = 'Crocea Mors', head = head, body = body})
end

describe('Sel\'s engaged set for a weapon set', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set Weapons Crocea')
    end)

    it('takes the place of sets.engaged', function()
        gs:engage()
        assert.same(crocea_engaged_in('Kaykaus Mitra +1', 'Atrophy Tabard +3'), gs:worn())
    end)

    it('falls back to sets.engaged[offense mode] in an offense mode it has no set for', function()
        gs:console('gs c set OffenseMode Acc')
        gs:engage()
        assert.same(crocea_engaged_in("Bunzi's Hat", 'Malignance Tabard'), gs:worn())
    end)

    it('falls back to sets.engaged[hybrid mode] in a hybrid mode it has no set for', function()
        gs:console('gs c set HybridMode DT')
        gs:engage()
        assert.same(crocea_engaged_in('Malignance Chapeau', 'Lethargy Sayon +3'), gs:worn())
    end)

    it('is its own set for an offense mode it has one for', function()
        gs.user.sets.engaged.Crocea.Acc = {head = 'Malignance Chapeau', body = 'Atrophy Tabard +3'}
        gs:console('gs c set OffenseMode Acc')
        gs:engage()
        assert.same(crocea_engaged_in('Malignance Chapeau', 'Atrophy Tabard +3'), gs:worn())
    end)

    it('is its own set for a hybrid mode it has one for', function()
        gs.user.sets.engaged.Crocea.DT = {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard'}
        gs:console('gs c set HybridMode DT')
        gs:engage()
        assert.same(crocea_engaged_in('Kaykaus Mitra +1', 'Malignance Tabard'), gs:worn())
    end)

    it('falls back to sets.engaged[offense mode][hybrid mode] before its own set for the hybrid mode alone',
        function()
        gs.user.sets.engaged.Crocea.DT = {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard'}
        gs:console('gs c set OffenseMode Acc')
        gs:console('gs c set HybridMode DT')
        gs:engage()
        assert.same(crocea_engaged_in('Malignance Chapeau', 'Malignance Tabard'), gs:worn())
    end)
end)

-- Testy as a red mage with the sub job Ninja and the trait Dual Wield.
local function boot_dual_wield()
    local gs = require('harness').boot_updated(testy.rdm({sub_job = 'NIN'}))
    require('jobby').can_dual_wield(gs)
    return gs
end

describe('Sel\'s engaged set for a weapon set with a shield, with the trait Dual Wield', function()
    it('skips sets.engaged.DW', function()
        local gs = boot_dual_wield()
        gs.user.sets.engaged.DW = {head = "Bunzi's Hat", body = 'Atrophy Tabard +3'}
        gs.user.sets.engaged.DW.Acc = {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard'}
        gs:console('gs c set Weapons Crocea')
        gs:console('gs c set OffenseMode Acc')
        gs:engage()
        assert.same(crocea_engaged_in("Bunzi's Hat", 'Malignance Tabard'), gs:worn())
    end)
end)

-- What is worn dual wielding Crocea Mors and Naegling with this engaged set on over the idle set.
local function dual_engaged_in(head, body)
    return testy.worn_by(testy.rdm_idle, {main = 'Crocea Mors', sub = 'Naegling', head = head, body = body})
end

describe('Sel\'s engaged set for a weapon set that dual wields', function()
    local gs
    before_each(function()
        gs = boot_dual_wield()
        gs.user.sets.weapons.Crocea = {main = 'Crocea Mors', sub = 'Naegling'}
        gs.user.sets.engaged.DW = {head = "Bunzi's Hat", body = 'Atrophy Tabard +3'}
        gs:console('gs c set Weapons Crocea')
    end)

    it('is its own set before sets.engaged.DW', function()
        gs:engage()
        assert.same(dual_engaged_in('Kaykaus Mitra +1', 'Atrophy Tabard +3'), gs:worn())
    end)

    it('is its own set for the offense mode before sets.engaged.DW[offense mode]', function()
        gs.user.sets.engaged.DW.Acc = {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard'}
        gs.user.sets.engaged.Crocea.Acc = {head = 'Malignance Chapeau', body = 'Nyame Mail'}
        gs:console('gs c set OffenseMode Acc')
        gs:engage()
        assert.same(dual_engaged_in('Malignance Chapeau', 'Nyame Mail'), gs:worn())
    end)

    it('falls back to sets.engaged.DW[offense mode] before sets.engaged[offense mode]', function()
        gs.user.sets.engaged.DW.Acc = {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard'}
        gs:console('gs c set OffenseMode Acc')
        gs:engage()
        assert.same(dual_engaged_in('Kaykaus Mitra +1', 'Malignance Tabard'), gs:worn())
    end)

    it('falls back to sets.engaged[offense mode] when neither it nor sets.engaged.DW has one', function()
        gs:console('gs c set OffenseMode Acc')
        gs:engage()
        assert.same(dual_engaged_in("Bunzi's Hat", 'Malignance Tabard'), gs:worn())
    end)

    it('falls back to sets.engaged[offense mode] when there is no sets.engaged.DW', function()
        gs.user.sets.engaged.DW = nil
        gs:console('gs c set OffenseMode Acc')
        gs:engage()
        assert.same(dual_engaged_in("Bunzi's Hat", 'Malignance Tabard'), gs:worn())
    end)
end)

describe('Sel\'s engaged set for dual wielding weapons with no engaged set of their own', function()
    it('stays sets.engaged.DW in an offense mode it has no set for', function()
        local gs = boot_dual_wield()
        gs.user.sets.weapons.Naegling = {main = 'Naegling', sub = 'Crocea Mors'}
        gs.user.sets.engaged.DW = {head = "Bunzi's Hat", body = 'Atrophy Tabard +3'}
        gs:console('gs c set Weapons Naegling')
        gs:console('gs c set OffenseMode Acc')
        gs:engage()
        assert.same(testy.worn_by(testy.rdm_idle, {main = 'Naegling', sub = 'Crocea Mors', head = "Bunzi's Hat",
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
