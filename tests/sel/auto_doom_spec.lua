local autoy = require('autoy')

-- Autoy doomed, as a red mage with the sub job given and the items given in its inventory. AutoRemoveDoomMode and
-- AutoHolyWaterMode are on unless a test turns them off.
local function doomed(sub_job, items, options)
    options = options or {}
    options.sub_job = sub_job
    options.items = {}
    for _, name in ipairs(items or {}) do
        options.items[#options.items + 1] = {name = name, count = 2}
    end
    local gs = autoy.boot(options)
    gs:gain_buff('doom')
    gs:traffic()
    return gs
end

describe('AutoRemoveDoomMode, from the start of Sel\'s tick', function()
    it('casts Cursna on itself with a white mage sub', function()
        local gs = doomed('WHM')
        gs:play(1)
        assert.same({{action = 'Cursna', target = 'Autoy'}}, gs:action_entries())
    end)

    it('uses Holy Water when it can\'t cast Cursna', function()
        local gs = doomed('WAR', {'Holy Water'})
        gs:play(1)
        assert.same({{item = 'Holy Water', target = 'Autoy'}}, gs.game:items_used())
    end)

    it('uses Hallowed Water ahead of Holy Water', function()
        local gs = doomed('WAR', {'Holy Water', 'Hallowed Water'})
        gs:play(1)
        assert.same({{item = 'Hallowed Water', target = 'Autoy'}}, gs.game:items_used())
    end)

    it('uses Holy Water while Cursna is on recast', function()
        local gs = doomed('WHM', {'Holy Water'})
        gs.game:start_spell_recast('Cursna', 10)
        gs:play(1)
        assert.same({}, gs:action_entries())
        assert.same({{item = 'Holy Water', target = 'Autoy'}}, gs.game:items_used())
    end)

    it('uses Holy Water while silenced', function()
        local gs = doomed('WHM', {'Holy Water'}, {buffs = {'silence'}})
        gs:play(1)
        assert.same({{item = 'Holy Water', target = 'Autoy'}}, gs.game:items_used())
    end)

    it('acts while invisible, ahead of the tick\'s other checks', function()
        local gs = doomed('WHM', nil, {buffs = {'Invisible'}})
        gs:play(1)
        assert.same({{action = 'Cursna', target = 'Autoy'}}, gs:action_entries())
    end)

    it('uses no water with AutoHolyWaterMode off', function()
        local gs = doomed('WAR', {'Holy Water'})
        gs:console('gs c toggle AutoHolyWaterMode')
        gs:play(3)
        assert.same({}, gs.game:items_used())
    end)

    it('does nothing when turned off', function()
        local gs = doomed('WHM', {'Holy Water'})
        gs:console('gs c toggle AutoRemoveDoomMode')
        gs:play(3)
        assert.same({}, gs:action_entries())
        assert.same({}, gs.game:items_used())
    end)

    it('does nothing without doom', function()
        local gs = autoy.boot({items = {{name = 'Holy Water', count = 2}}})
        gs:play(3)
        assert.same({}, gs:action_entries())
        assert.same({}, gs.game:items_used())
    end)
end)
