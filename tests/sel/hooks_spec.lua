local testy = require('testy')

-- Testy as a red mage with the idle set on. Testy_Rdm_Gear.lua's hooks act on Cure IV, Stoneskin and Haste only.
local boot = testy.boot_rdm

describe('the gear file\'s hooks under Sel', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('user_job_filter_precast cancels a spell before any set goes on', function()
        assert.is_true(gs:type('/ma "Stoneskin" <me>'))
        assert.same({}, gs:traffic())
    end)

    it('user_job_precast runs before the precast set, which goes over what it equips', function()
        gs:type('/ma "Cure IV" <me>')
        local precast = gs:traffic()[1].equip
        assert.equal('Crocea Mors', precast.main)
        assert.equal("Bunzi's Hat", precast.head)
    end)

    it('user_job_post_precast equips over the precast set', function()
        gs:type('/ma "Cure IV" <me>')
        assert.equal('Lethargy Sayon +3', gs:traffic()[1].equip.body)
    end)

    it('user_job_post_midcast equips over the midcast set', function()
        gs:type('/ma "Cure IV" <me>')
        assert.same(testy.worn_by(testy.rdm_idle, {main = "Bunzi's Rod", head = "Bunzi's Hat",
            body = 'Lethargy Sayon +3', ring1 = 'Kishar Ring'}), gs:worn())
    end)

    it('leave nothing of theirs on once the spell is done', function()
        gs:type('/ma "Cure IV" <me>')
        gs:finish_action()
        assert.same(testy.worn_by(testy.rdm_idle), gs:worn())
    end)

    it('user_job_customize_melee_set changes the engaged set Sel built', function()
        gs:gain_buff('Haste')
        gs:engage()
        assert.same(testy.worn_by(testy.rdm_idle, {head = 'Kaykaus Mitra +1', body = 'Lethargy Sayon +3'}), gs:worn())
    end)
end)
