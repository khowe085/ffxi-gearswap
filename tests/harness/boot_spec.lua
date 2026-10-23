local autoy = require('autoy')
local harness = require('harness')
local testy = require('testy')

-- Boots Globby, whose own Globals file sets the latency to 1 and turns on AutoArts, AutoTrustMode and AutoFoodMode, the
-- last two with options of their own. Sel loads it after User-Globals.lua's and before it works out the spell latency,
-- so a boot that left them as the files made them would show them, whatever User-Globals.lua holds.
local function boot_globby()
    local gs = harness.boot({character = 'Globby', main_job = 'WAR', sub_job = 'WHM', expect_file = 'WAR.lua'})
    assert.equal('Globby-Globals.lua', gs.user.globals_marker)
    return gs
end

describe('a boot', function()
    it('finds the string functions as Lua has them, not wrapped by an earlier boot\'s libraries', function()
        harness.boot(testy.whm())
        local gs = harness.boot(testy.whm())
        -- Windower's strings.lua keeps the find it found in _raw before putting its own over it.
        assert.equal('C', debug.getinfo(gs.env._raw.string.find, 'S').what)
    end)

    it('finds them as Lua has them when it writes augments into an item first', function()
        harness.boot(testy.whm())
        -- The augments are written with Windower's own libraries, loaded for the purpose.
        local gs = harness.boot(testy.whm({items = {{name = "Alaunus's Cape", augments = {'MND+20'}}}, wearing = {}}))
        assert.equal('C', debug.getinfo(gs.env._raw.string.find, 'S').what)
    end)

    it('refuses abilities that name one the test resources hold as neither a job ability nor a weapon skill', function()
        assert.has_no.errors(function() harness.boot(testy.whm({abilities = {'Penury', 'Rock Crusher'}})) end)
        assert.has_error(function() harness.boot(testy.whm({abilities = {'Penury', 'Starburst'}})) end,
            'the test resources have no job ability or weapon skill named "Starburst"')
    end)

    it('starts the modes that act on their own off, with the options Sel defines them with', function()
        local state = boot_globby().user.state
        assert.same({'Off', 'Off', false}, {state.AutoTrustMode.value, state.AutoFoodMode.value, state.AutoArts.value})
        assert.same({1, 1}, {#state.AutoTrustMode, #state.AutoFoodMode})
    end)

    it('starts with the latency Sel defines, half a second, which its delays are written around', function()
        local user = boot_globby().user
        assert.same({0.5, 48}, {user.latency, user.spell_latency})
    end)

    it('gives a boot\'s user function the user environment, once the files are loaded', function()
        local given
        autoy.load({user = function(user)
            given = {state = user.state, sets = user.sets}
        end})
        assert.is_table(given.state.AutoTrustMode)
        assert.is_table(given.sets.weapons.Naegling)
    end)

    it('has what the user function sets in place for Sel\'s first tick', function()
        local gs = autoy.boot({items = {{name = 'Grape Daifuku', count = 3}}, user = function(user)
            user.food_lists = {Snack = 'Grape Daifuku'}
            user.state.AutoFoodMode:options('Snack', 'Off')
        end})
        assert.same({{item = 'Grape Daifuku', target = 'Autoy'}}, gs.game:items_used())
    end)
end)
