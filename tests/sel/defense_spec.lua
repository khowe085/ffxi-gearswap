local harness = require('harness')
local testy = require('testy')

local engaged = {head = "Bunzi's Hat", body = 'Lethargy Sayon +3'}
local pdt = {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard'}

-- Testy as a red mage with the idle set on.
local function boot()
    local gs = harness.boot(testy.rdm())
    gs:console('gs c update')
    gs:traffic()
    return gs
end

describe('Sel\'s defense mode', function()
    it('Physical lays sets.defense.PDT over the idle set', function()
        local gs = boot()
        gs:console('gs c set DefenseMode Physical')
        assert.same(testy.worn_by(testy.rdm_idle, pdt), gs:worn())
    end)

    it('Physical puts sets.defense.PDT on while engaged', function()
        local gs = boot()
        gs:engage()
        assert.same(testy.worn_by(testy.rdm_idle, engaged), gs:worn())
        gs:console('gs c set DefenseMode Physical')
        assert.same(testy.worn_by(testy.rdm_idle, pdt), gs:worn())
    end)

    it('Magical lays sets.defense.MDT over the idle set', function()
        local gs = boot()
        gs:console('gs c set DefenseMode Magical')
        assert.same(testy.worn_by(testy.rdm_idle, {body = 'Lethargy Sayon +3'}), gs:worn())
    end)

    it('takes the defense set off again when reset', function()
        local gs = boot()
        gs:console('gs c set DefenseMode Physical')
        gs:console('gs c reset DefenseMode')
        assert.equal('None', gs.user.state.DefenseMode.value)
        assert.same(testy.worn_by(testy.rdm_idle), gs:worn())
    end)

    it('lays the defense set over the idle mode\'s set', function()
        local gs = boot()
        gs:console('gs c set IdleMode Refresh')
        gs:console('gs c set DefenseMode Magical')
        assert.same(testy.worn_by(testy.rdm_idle, {head = 'Kaykaus Mitra +1', body = 'Lethargy Sayon +3'}), gs:worn())
    end)

    it('has sets.Kiting laid over the defense set', function()
        local gs = boot()
        gs:console('gs c set DefenseMode Physical')
        gs:console('gs c toggle Kiting')
        assert.same(testy.worn_by(testy.rdm_idle, {head = 'Kaykaus Mitra +1', body = 'Atrophy Tabard +3'}), gs:worn())
    end)

    it('leaves a spell\'s own precast and midcast sets on out of combat', function()
        local gs = boot()
        gs:console('gs c set DefenseMode Physical')
        gs:traffic()
        gs:type('/ma "Cure III" <me>')
        assert.same({
            {equip = {head = "Bunzi's Hat", left_ring = 'Kishar Ring'}},
            {action = 'Cure III', target = 'Testy'},
            {equip = {main = "Bunzi's Rod", head = 'Kaykaus Mitra +1'}},
        }, gs:traffic())
    end)
end)

describe('a spell in combat with a defense mode on', function()
    local gs
    before_each(function()
        gs = boot()
        -- A spell that lands on a monster puts Sel in combat.
        gs:type('/ma "Slow" <t>')
        gs:finish_action()
        assert.is_true(gs.user.in_combat)
        gs:advance(5)
        gs:console('gs c set DefenseMode Physical')
        gs:traffic()
    end)

    it('takes sets.precast.FC.DT over the precast set', function()
        gs:type('/ma "Cure III" <me>')
        assert.same({head = 'Malignance Chapeau', left_ring = 'Kishar Ring'}, gs:traffic()[1].equip)
    end)

    it('keeps the idle set, with the defense set, through midcast when there is no FastRecast.DT', function()
        gs:type('/ma "Cure III" <me>')
        assert.same(testy.worn_by(testy.rdm_idle, pdt), gs:worn())
    end)
end)
