local commy = require('commy')

local idle = commy.rdm_idle

-- What is worn once Slow is out at the monster: the enfeebling midcast set over the idle set, and what the buffs
-- Sel tracks add to it.
local function slow(gs)
    local sent = #gs.game.actions
    gs:type('/ma "Slow" <t>')
    assert.equal(sent + 1, #gs.game.actions, 'Slow didn\'t go out')
    return gs:worn()
end

describe('Sel\'s tracking of a buff the job file watches', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        gs:console('gs c set TreasureMode None')
    end)

    it('takes Saboteur for up once it is gained, so RDM.lua lays sets.buff.Saboteur over an enfeeble', function()
        assert.equal('Nyame Sollerets', slow(gs).feet)
        gs:finish_action()
        gs:advance(5)
        gs:gain_buff('Saboteur')
        assert.is_true(gs.user.state.Buff.Saboteur)
        assert.equal('Malignance Boots', slow(gs).feet)
    end)

    it('takes it for down once it wears off', function()
        gs:gain_buff('Saboteur')
        gs:lose_buff('Saboteur')
        assert.is_false(gs.user.state.Buff.Saboteur)
        assert.equal('Nyame Sollerets', slow(gs).feet)
    end)

    it('takes it for up as soon as the ability is done on Commy, before the buff comes', function()
        gs:type('/ja "Saboteur" <me>')
        gs:finish_action()
        gs:advance(5)
        assert.equal('Malignance Boots', slow(gs).feet)
    end)
end)

describe('Sel on gaining or losing a buff', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('puts the set it picks back on', function()
        gs:console('gs equip sets.TreasureHunter')
        gs:gain_buff('Haste')
        assert.same(commy.worn_by(idle), gs:worn())
    end)

    it('holds sets.buff.Doom on while doomed, and lets it go once the doom is gone', function()
        gs:gain_buff('doom')
        assert.same(commy.worn_by(idle, {neck = "Nicander's Necklace"}), gs:worn())
        gs:console('gs c update')
        assert.equal("Nicander's Necklace", gs:worn().neck)
        gs:lose_buff('doom')
        assert.same(commy.worn_by(idle), gs:worn())
    end)

    it('cancels Stoneskin on falling asleep, as CancelStoneskin is on', function()
        gs:gain_buff('sleep')
        assert.truthy(table.concat(gs.game.commands, '\n'):find('cancel stoneskin', 1, true))
    end)

    it('leaves Stoneskin up on falling asleep with CancelStoneskin off', function()
        gs:console('gs c toggle CancelStoneskin')
        gs:gain_buff('sleep')
        assert.falsy(table.concat(gs.game.commands, '\n'):find('cancel stoneskin', 1, true))
    end)

    it('tells the party of a buff NotifyBuffs names, with NotifyBuffs on', function()
        gs:console('gs c toggle NotifyBuffs')
        local typed = commy.record_input(gs)
        gs:gain_buff('doom')
        gs:lose_buff('doom')
        assert.same({'/p Doom on me!', '/p Doom is off now.'}, typed)
    end)

    it('tells the party nothing with NotifyBuffs off, as it starts', function()
        local typed = commy.record_input(gs)
        gs:gain_buff('doom')
        assert.same({}, typed)
    end)

    it('lays sets.defense.PDT over the idle set while petrified', function()
        gs:gain_buff('petrification')
        assert.same(commy.worn_by(idle, {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard'}), gs:worn())
        gs:lose_buff('petrification')
        assert.same(commy.worn_by(idle), gs:worn())
    end)

    it('refuses an action while petrified, and says so', function()
        gs:gain_buff('petrification')
        gs:traffic()
        gs:chat()
        assert.is_true(gs:type('/ma "Cure III" <me>'))
        assert.same({}, gs:traffic())
        assert.same({'Abort: You are petrified.'}, gs:chat())
    end)

    it('tracks the scholar\'s arts', function()
        gs:gain_buff('Dark Arts')
        assert.is_true(gs.user.state.Buff['Dark Arts'])
        gs:lose_buff('Dark Arts')
        assert.is_false(gs.user.state.Buff['Dark Arts'])
    end)
end)
