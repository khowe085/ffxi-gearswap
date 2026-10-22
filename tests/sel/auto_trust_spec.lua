local autoy = require('autoy')

-- Each test gives the character trust_lists and AutoTrustMode's options itself, before Sel's tick first acts, so none
-- rests on User-Globals.lua's lists or on the names it gives the options. Long is Yoran-Oran (UC), Koru-Moru, Qultada,
-- Ulmia, Joachim; Short is Yoran-Oran (UC), Qultada, Ulmia. A trust is in the party under its name without the (UC).
local trust_lists = {
    Long = {'Yoran-Oran (UC)', 'Koru-Moru', 'Qultada', 'Ulmia', 'Joachim'},
    Short = {'Yoran-Oran (UC)', 'Qultada', 'Ulmia'},
}

local function boot(options, list)
    options = options or {}
    options.user = function(user)
        user.trust_lists = trust_lists
        user.state.AutoTrustMode:options('Off', 'Long', 'Short')
    end
    local gs = autoy.boot(options)
    gs:console('gs c set AutoTrustMode ' .. (list or 'Long'))
    gs:traffic()
    return gs
end

local function calls(name)
    return {{action = name, target = 'Autoy'}}
end

describe('AutoTrustMode', function()
    it('calls the list\'s first trust', function()
        local gs = boot()
        gs:play(1)
        assert.same(calls('Yoran-Oran (UC)'), gs:action_entries())
    end)

    it('goes on past a trust already in the party', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Yoran-Oran'})
        gs:play(1)
        assert.same(calls('Koru-Moru'), gs:action_entries())
    end)

    it('goes on past a trust on recast', function()
        local gs = boot()
        gs.game:start_spell_recast('Yoran-Oran (UC)', 60)
        gs:play(1)
        assert.same(calls('Koru-Moru'), gs:action_entries())
    end)

    it('calls from the list set', function()
        local gs = boot(nil, 'Short')
        gs.game:add_party_member({name = 'Yoran-Oran'})
        gs:play(1)
        assert.same(calls('Qultada'), gs:action_entries())
    end)

    it('calls none once every trust of the list is in the party', function()
        local gs = boot(nil, 'Short')
        for _, name in ipairs({'Yoran-Oran', 'Qultada', 'Ulmia'}) do
            gs.game:add_party_member({name = name})
        end
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('calls none with a full party', function()
        local gs = boot()
        for _, name in ipairs({'Mihli Aliapoh', 'Apururu', 'Selh\'teus', 'Monberaux', 'Arciela'}) do
            gs.game:add_party_member({name = name})
        end
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('calls none in combat', function()
        local gs = boot()
        gs:monster_hits()
        gs:traffic()
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('calls in combat under Elvorseal', function()
        local gs = boot({buffs = {'Elvorseal'}})
        gs:monster_hits()
        gs:traffic()
        gs:play(1)
        assert.same(calls('Yoran-Oran (UC)'), gs:action_entries())
    end)

    it('calls in combat under Reive Mark', function()
        local gs = boot({buffs = {'Reive Mark'}})
        gs:monster_hits()
        gs:traffic()
        gs:play(1)
        assert.same(calls('Yoran-Oran (UC)'), gs:action_entries())
    end)

    it('calls none while invisible', function()
        local gs = boot({buffs = {'Invisible'}})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('calls none in town', function()
        local gs = boot({zone = 230})
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('calls none while Off', function()
        local gs = boot(nil, 'Off')
        gs:play(3)
        assert.same({}, gs:action_entries())
    end)

    it('calls before AutoBuffMode casts, from the start of the tick', function()
        local gs = boot()
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(1)
        assert.same(calls('Yoran-Oran (UC)'), gs:action_entries())
    end)

    pending('lets the tick go on past a name in trust_lists that is no spell: check_trust in libs/Sel-Utility.lua gets '
        .. 'nil from get_spell_id_by_name and indexes res.spells[spell_id].party_name, which raises, so the tick ends '
        .. 'there, before the checks that follow it')
end)
