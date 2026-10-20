local harness = require('harness')
local testy = require('testy')

-- Testy as a red mage with the idle set on.
local function boot()
    local gs = harness.boot(testy.rdm())
    gs:console('gs c update')
    gs:traffic()
    return gs
end

-- The Cure III midcast set over its precast set over the idle set, with these weapons in hand.
local function curing_with(main)
    return testy.worn_by(testy.rdm_idle, {main = main, head = 'Kaykaus Mitra +1', body = 'Malignance Tabard',
        ring1 = 'Kishar Ring'})
end

describe('Sel\'s weapon lock', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('puts the weapon set\'s main on over the idle set\'s', function()
        gs:console('gs c set Weapons Naegling')
        assert.same(testy.worn_by(testy.rdm_idle, {main = 'Naegling'}), gs:worn())
    end)

    it('keeps the weapon set\'s main on when a spell\'s set names another', function()
        gs:console('gs c set Weapons Naegling')
        gs:type('/ma "Cure III" <me>')
        assert.same(curing_with('Naegling'), gs:worn())
        gs:finish_action()
        assert.same(testy.worn_by(testy.rdm_idle, {main = 'Naegling'}), gs:worn())
    end)

    it('swaps to another weapon set\'s main when the weapon set changes', function()
        gs:console('gs c set Weapons Naegling')
        gs:console('gs c set Weapons Crocea')
        assert.same(testy.worn_by(testy.rdm_idle, {main = 'Crocea Mors'}), gs:worn())
    end)

    it('locks nothing with Weapons None, so each set\'s weapons go on', function()
        assert.equal('None', gs.user.state.Weapons.value)
        gs:type('/ma "Cure III" <me>')
        assert.same(curing_with("Bunzi's Rod"), gs:worn())
        gs:finish_action()
        assert.same(testy.worn_by(testy.rdm_idle), gs:worn())
    end)

    it('lets the idle set\'s weapons back on when Weapons goes back to None', function()
        gs:console('gs c set Weapons Naegling')
        gs:console('gs c set Weapons None')
        assert.same(testy.worn_by(testy.rdm_idle), gs:worn())
    end)

    it('holds the main weapon in hand while engaged with Weapons None, as User-Globals.lua has it, so a spell\'s '
        .. 'set\'s main doesn\'t go on', function()
        gs:engage()
        gs:type('/ma "Cure III" <me>')
        local worn = gs:worn()
        assert.same({'Daybreak', 'Kaykaus Mitra +1'}, {worn.main, worn.head})
    end)

    pending('as docs/frameworks/sel.md:61 has it, lets each set\'s weapons go on with Weapons None or UnlockWeapons '
        .. 'on, with no exception while engaged: data/User/User-Globals.lua\'s engaged hold (hold_engaged_weapons) '
        .. 'keeps the weapons in hand while engaged, so the doc and the code disagree until one is settled')
end)

describe('Sel\'s weapon set with UnlockWeapons on', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set Weapons Naegling')
        gs:console('gs c toggle UnlockWeapons')
        assert.is_true(gs.user.state.UnlockWeapons.value)
    end)

    it('is laid over the idle set', function()
        assert.same(testy.worn_by(testy.rdm_idle, {main = 'Naegling'}), gs:worn())
    end)

    it('lets a spell\'s set change the weapons, and comes back after', function()
        gs:type('/ma "Cure III" <me>')
        assert.same(curing_with("Bunzi's Rod"), gs:worn())
        gs:finish_action()
        assert.same(testy.worn_by(testy.rdm_idle, {main = 'Naegling'}), gs:worn())
    end)

    it('has its main held in hand while engaged, as User-Globals.lua has it, so a spell\'s set\'s main '
        .. 'doesn\'t go on', function()
        gs:engage()
        gs:type('/ma "Cure III" <me>')
        local worn = gs:worn()
        assert.same({'Naegling', 'Kaykaus Mitra +1'}, {worn.main, worn.head})
    end)
end)
