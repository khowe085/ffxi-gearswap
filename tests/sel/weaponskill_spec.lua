local testy = require('testy')

-- Testy as a red mage with Naegling locked in hand, engaged, with 1000 TP: User-Globals.lua drops a weapon skill
-- under that before any set goes on.
local function boot()
    local gs = testy.boot_rdm()
    gs:console('gs c set Weapons Naegling')
    gs:engage()
    gs:set_tp(1000)
    gs:traffic()
    return gs
end

-- What is worn once the weapon skill is out: its set over the engaged set.
local function weaponskill(gs, line)
    gs:type(line)
    local traffic = gs:traffic()
    assert.is_truthy(traffic[#traffic] and traffic[#traffic].action, 'the weapon skill didn\'t go out')
    return gs:worn()
end

local function worn_with(head, body)
    return testy.worn_by(testy.rdm_idle, {main = 'Naegling', head = head, body = body})
end

describe('Sel\'s weapon skill set', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is sets.precast.WS for a weapon skill with no set of its own', function()
        assert.same(worn_with('Kaykaus Mitra +1', 'Atrophy Tabard +3'), weaponskill(gs, '/ws "Requiescat" <t>'))
    end)

    it('is sets.precast.WS[name]', function()
        assert.same(worn_with('Malignance Chapeau', 'Atrophy Tabard +3'), weaponskill(gs, '/ws "Savage Blade" <t>'))
    end)

    it('takes the offense mode\'s name in the Match weapon skill mode', function()
        gs:console('gs c set OffenseMode Acc')
        assert.equal('Match', gs.user.state.WeaponskillMode.value)
        assert.same(worn_with('Malignance Chapeau', 'Malignance Tabard'), weaponskill(gs, '/ws "Savage Blade" <t>'))
    end)

    it('takes the offense mode\'s name in Match for a weapon skill with no set of its own', function()
        gs:console('gs c set OffenseMode Acc')
        assert.same(worn_with('Kaykaus Mitra +1', 'Malignance Tabard'), weaponskill(gs, '/ws "Requiescat" <t>'))
    end)

    it('is Normal in Match when the offense mode isn\'t a weapon skill mode', function()
        gs:console('gs c set OffenseMode Att')
        assert.same(worn_with('Malignance Chapeau', 'Atrophy Tabard +3'), weaponskill(gs, '/ws "Savage Blade" <t>'))
    end)

    it('takes a weapon skill mode set by name, whatever the offense mode', function()
        gs:console('gs c set WeaponskillMode Acc')
        assert.same(worn_with('Malignance Chapeau', 'Malignance Tabard'), weaponskill(gs, '/ws "Savage Blade" <t>'))
    end)

    it('stays at the weapon skill\'s set in the Normal weapon skill mode, whatever the offense mode', function()
        gs:console('gs c set OffenseMode Acc')
        gs:console('gs c set WeaponskillMode Normal')
        assert.same(worn_with('Malignance Chapeau', 'Atrophy Tabard +3'), weaponskill(gs, '/ws "Savage Blade" <t>'))
    end)

    it('gives way to the engaged set once the weapon skill is done', function()
        weaponskill(gs, '/ws "Savage Blade" <t>')
        gs:finish_action()
        assert.same(worn_with("Bunzi's Hat", 'Lethargy Sayon +3'), gs:worn())
    end)

    it('doesn\'t go on to a set named for the weapon set', function()
        local ws = gs.user.sets.precast.WS['Savage Blade']
        ws.Naegling = gs.user.set_combine(ws, {body = 'Lethargy Sayon +3'})
        assert.same(worn_with('Malignance Chapeau', 'Atrophy Tabard +3'), weaponskill(gs, '/ws "Savage Blade" <t>'))
    end)
end)

describe('User-Globals.lua\'s weapon_set_ws_mode, as a gear file\'s get_custom_wsmode', function()
    local gs, ws
    before_each(function()
        gs = boot()
        gs.user.get_custom_wsmode = gs.user.weapon_set_ws_mode
        ws = gs.user.sets.precast.WS['Savage Blade']
    end)

    it('takes the weapon skill\'s set named for the weapon set in the Normal weapon skill mode', function()
        ws.Naegling = gs.user.set_combine(ws, {body = 'Lethargy Sayon +3'})
        assert.same(worn_with('Malignance Chapeau', 'Lethargy Sayon +3'), weaponskill(gs, '/ws "Savage Blade" <t>'))
    end)

    it('takes it in Match when the offense mode isn\'t a weapon skill mode', function()
        ws.Naegling = gs.user.set_combine(ws, {body = 'Lethargy Sayon +3'})
        gs:console('gs c set OffenseMode Att')
        assert.same(worn_with('Malignance Chapeau', 'Lethargy Sayon +3'), weaponskill(gs, '/ws "Savage Blade" <t>'))
    end)

    it('keeps the weapon skill\'s set when it has none named for the weapon set', function()
        ws.Crocea = gs.user.set_combine(ws, {body = 'Lethargy Sayon +3'})
        assert.same(worn_with('Malignance Chapeau', 'Atrophy Tabard +3'), weaponskill(gs, '/ws "Savage Blade" <t>'))
    end)

    it('leaves a weapon skill mode set by name to Sel', function()
        ws.Naegling = gs.user.set_combine(ws, {body = 'Lethargy Sayon +3'})
        gs:console('gs c set WeaponskillMode Acc')
        assert.same(worn_with('Malignance Chapeau', 'Malignance Tabard'), weaponskill(gs, '/ws "Savage Blade" <t>'))
    end)

    it('leaves the offense mode\'s name in Match to Sel', function()
        ws.Naegling = gs.user.set_combine(ws, {body = 'Lethargy Sayon +3'})
        gs:console('gs c set OffenseMode Acc')
        assert.same(worn_with('Malignance Chapeau', 'Malignance Tabard'), weaponskill(gs, '/ws "Savage Blade" <t>'))
    end)

    it('takes sets.precast.WS named for the weapon set for a weapon skill with no set of its own', function()
        gs.user.sets.precast.WS.Naegling = gs.user.set_combine(gs.user.sets.precast.WS, {body = 'Lethargy Sayon +3'})
        assert.same(worn_with('Kaykaus Mitra +1', 'Lethargy Sayon +3'), weaponskill(gs, '/ws "Requiescat" <t>'))
    end)
end)
