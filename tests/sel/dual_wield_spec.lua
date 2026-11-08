local harness = require('harness')
local commy = require('commy')

local function sent_initialize(gs)
    return table.concat(gs:commands(), '\n'):find('gs c weapons initialize', 1, true) ~= nil
end

describe('Sel\'s check for dual wield', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        gs:advance(harness.sel_load_time + 0.1)
        gs:console('gs c set Weapons Naegling')
        gs:commands()
    end)

    it('takes the trait from a job abilities packet, and leaves the weapons chosen alone', function()
        gs.game:set_job_traits({'Dual Wield'})
        gs:run(function()
            gs.game:receive(0x0AC, string.rep('\0', 64))
            gs.game:settle()
        end)
        assert.is_true(gs.user.can_dual_wield)
        assert.is_false(sent_initialize(gs))
        assert.equal('Naegling', gs.user.state.Weapons.value)
    end)

    it('starts the weapons over on its next look after a sub job change', function()
        gs:change_sub_job('NIN', 49)
        gs:commands()
        gs:advance(harness.sel_load_time + 0.1)
        assert.is_true(sent_initialize(gs))
    end)
end)
