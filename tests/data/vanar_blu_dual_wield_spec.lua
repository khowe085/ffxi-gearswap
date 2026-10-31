local harness = require('harness')

describe('Vanar\'s blue mage when AzureSets sets a spell that gives Dual Wield', function()
    it('rechecks the trait and starts the weapons over', function()
        local gs = harness.boot({character = 'Vanar', main_job = 'BLU', sub_job = 'WAR', expect_file = 'BLU.lua'})
        gs:advance(harness.sel_load_time + 0.1)
        gs:run(function() gs.user.queue_azure_set(0) end)
        gs:advance(1.1)
        gs:commands()

        gs.game:set_job_traits({'Dual Wield'})
        gs:advance(1.1)

        assert.is_true(gs.user.can_dual_wield)
        assert.truthy(table.concat(gs:commands(), '\n'):find('gs c weapons initialize', 1, true))
    end)
end)
