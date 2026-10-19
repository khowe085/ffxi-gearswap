local autoy = require('autoy')

-- User-Globals.lua's trust_lists: Default is Yoran-Oran (UC), Koru-Moru, Qultada, Ulmia, Joachim; Limbus is
-- Yoran-Oran (UC), Qultada, Ulmia. A trust is in the party under its name without the (UC).
local function boot(options, list)
    local gs = autoy.boot(options)
    gs:console('gs c set AutoTrustMode ' .. (list or 'Default'))
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
        assert.same(calls('Yoran-Oran (UC)'), autoy.actions(gs))
    end)

    it('goes on past a trust already in the party', function()
        local gs = boot()
        gs.game:join_party('Yoran-Oran')
        gs:play(1)
        assert.same(calls('Koru-Moru'), autoy.actions(gs))
    end)

    it('goes on past a trust on recast', function()
        local gs = boot()
        gs.game:start_spell_recast('Yoran-Oran (UC)', 60)
        gs:play(1)
        assert.same(calls('Koru-Moru'), autoy.actions(gs))
    end)

    it('calls from the list set', function()
        local gs = boot(nil, 'Limbus')
        gs.game:join_party('Yoran-Oran')
        gs:play(1)
        assert.same(calls('Qultada'), autoy.actions(gs))
    end)

    it('calls none once every trust of the list is in the party', function()
        local gs = boot(nil, 'Limbus')
        for _, name in ipairs({'Yoran-Oran', 'Qultada', 'Ulmia'}) do
            gs.game:join_party(name)
        end
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('calls none with a full party', function()
        local gs = boot()
        for _, name in ipairs({'Mihli Aliapoh', 'Apururu', 'Selh\'teus', 'Monberaux', 'Arciela'}) do
            gs.game:join_party(name)
        end
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('calls none in combat', function()
        local gs = boot()
        gs:monster_hits()
        gs:traffic()
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('calls in combat under Elvorseal', function()
        local gs = boot({buffs = {'Elvorseal'}})
        gs:monster_hits()
        gs:traffic()
        gs:play(1)
        assert.same(calls('Yoran-Oran (UC)'), autoy.actions(gs))
    end)

    it('calls in combat under Reive Mark', function()
        local gs = boot({buffs = {'Reive Mark'}})
        gs:monster_hits()
        gs:traffic()
        gs:play(1)
        assert.same(calls('Yoran-Oran (UC)'), autoy.actions(gs))
    end)

    it('calls none while invisible', function()
        local gs = boot({buffs = {'Invisible'}})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('calls none in town', function()
        local gs = boot({zone = 230})
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('calls none while Off', function()
        local gs = boot(nil, 'Off')
        gs:play(3)
        assert.same({}, autoy.actions(gs))
    end)

    it('calls before AutoBuffMode casts, from the start of the tick', function()
        local gs = boot()
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(1)
        assert.same(calls('Yoran-Oran (UC)'), autoy.actions(gs))
    end)

    it('is turned off by a zone change', function()
        local gs = boot()
        gs:change_zone(230)
        assert.equal('Off', gs.user.state.AutoTrustMode.value)
    end)
end)
