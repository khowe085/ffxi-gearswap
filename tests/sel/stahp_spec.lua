local commy = require('commy')

local idle = commy.rdm_idle

describe('Sel\'s AutoDefenseMode', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        gs:console('gs c toggle AutoDefenseMode')
    end)

    it('puts the physical defense set on when the monster readies a physical move at Commy', function()
        commy.monster_acts(gs, 7, 'Ripper Fang')
        assert.equal('Physical', gs.user.state.DefenseMode.value)
        assert.same(commy.worn_by(idle, {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard'}), gs:worn())
    end)

    it('puts the magical defense set on for a magical move', function()
        commy.monster_acts(gs, 7, 'Foul Breath')
        assert.equal('Magical', gs.user.state.DefenseMode.value)
        assert.same(commy.worn_by(idle, {body = 'Lethargy Sayon +3'}), gs:worn())
    end)

    it('puts the resist defense set on for a move that would put a status on Commy', function()
        commy.monster_acts(gs, 7, 'Sweet Breath')
        assert.equal('Resist', gs.user.state.DefenseMode.value)
        assert.same(commy.worn_by(idle, {body = 'Malignance Tabard'}), gs:worn())
    end)

    it('leaves the defense mode as it is for a move it doesn\'t list', function()
        commy.monster_acts(gs, 7, 'Spore')
        assert.equal('None', gs.user.state.DefenseMode.value)
    end)

    it('leaves it as it is for a move at the monster itself, unless the move reaches round it', function()
        commy.monster_acts(gs, 7, 'Ripper Fang', gs.game.monster.id)
        assert.equal('None', gs.user.state.DefenseMode.value)
        commy.monster_acts(gs, 7, 'Foul Breath', gs.game.monster.id)
        assert.equal('Magical', gs.user.state.DefenseMode.value)
    end)

    it('takes the defense set off again once the monster Commy targets has used the move', function()
        commy.monster_acts(gs, 7, 'Ripper Fang')
        commy.monster_acts(gs, 11, 'Ripper Fang')
        assert.equal('None', gs.user.state.DefenseMode.value)
        assert.same(commy.worn_by(idle), gs:worn())
    end)

    it('with TankAutoDefense on, goes back to the physical defense set after a move', function()
        gs:console('gs c toggle TankAutoDefense')
        commy.monster_acts(gs, 7, 'Foul Breath')
        commy.monster_acts(gs, 11, 'Foul Breath')
        assert.equal('Physical', gs.user.state.DefenseMode.value)
    end)
end)

describe('Sel with AutoDefenseMode off', function()
    it('leaves the defense mode alone whatever the monster readies', function()
        local gs = commy.boot_rdm()
        commy.monster_acts(gs, 7, 'Ripper Fang')
        assert.equal('None', gs.user.state.DefenseMode.value)
        assert.same(commy.worn_by(idle), gs:worn())
    end)
end)

describe('Sel\'s AutoStunMode', function()
    local gs, typed
    before_each(function()
        gs = commy.boot_war()
        gs:console('gs c toggle AutoStunMode')
        typed = commy.record_input(gs)
    end)

    it('casts Stun at the monster Commy targets when it readies a move worth stunning', function()
        commy.monster_acts(gs, 7, 'Death Scissors')
        assert.same({'/ma "Stun" <t>'}, typed)
    end)

    it('lets a move it doesn\'t list go', function()
        commy.monster_acts(gs, 7, 'Ripper Fang')
        assert.same({}, typed)
    end)

    it('lets a move go when it is off', function()
        gs:console('gs c toggle AutoStunMode')
        commy.monster_acts(gs, 7, 'Death Scissors')
        assert.same({}, typed)
    end)
end)

describe('Sel\'s AutoAcceptRaiseMode', function()
    -- The server's offer of a raise (0x0F9): Commy, and the kind of raise.
    local function offer_raise(gs)
        gs:run(function()
            local player = gs.game.player
            gs.game:receive(0x0F9, string.char(player.id % 256, math.floor(player.id / 256) % 256,
                math.floor(player.id / 65536) % 256, 0, player.index % 256, math.floor(player.index / 256), 1, 0))
            gs.game:settle()
        end)
    end

    it('accepts a raise when it is on', function()
        local gs = commy.boot_rdm()
        gs:console('gs c toggle AutoAcceptRaiseMode')
        offer_raise(gs)
        assert.same({{action = 'category 13', target = 'Commy'}}, gs:traffic())
    end)

    it('leaves the raise to the player while off, as it starts', function()
        local gs = commy.boot_rdm()
        offer_raise(gs)
        assert.same({}, gs:traffic())
    end)
end)

describe('Sel in Abyssea', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        commy.game(gs, 'change_zone', 132)
    end)

    -- A line of the game's in the chat log.
    local function game_says(text)
        gs:run(function()
            gs.game:fire('incoming text', text, text, 121, 121, false)
            gs.game:settle()
        end)
    end

    it('sets ElementalMode to the element a fiend is weak to with magic', function()
        game_says('The fiend appears vulnerable to ice elemental magic!')
        assert.equal('Ice', gs.user.state.ElementalMode.value)
    end)

    it('asks for the proc weapons of the element a fiend is weak to with weapon skills', function()
        game_says('The fiend appears vulnerable to fire elemental weapon skills!')
        assert.truthy(table.concat(gs.game.commands, '\n'):find('gs c weapons ProcSword', 1, true))
    end)

    it('heeds no such line outside Abyssea', function()
        commy.game(gs, 'change_zone', 288)
        game_says('The fiend appears vulnerable to ice elemental magic!')
        assert.equal('Fire', gs.user.state.ElementalMode.value)
    end)
end)

describe('Sel\'s combat tracking', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        assert.is_false(gs.user.in_combat)
    end)

    it('takes Commy to be in combat once the monster hits Commy', function()
        commy.monster_acts(gs, 1)
        assert.is_true(gs.user.in_combat)
    end)

    it('takes Commy to be in combat once the monster begins a spell at Commy', function()
        commy.monster_acts(gs, 8, 'Slow')
        assert.is_true(gs.user.in_combat)
    end)

    it('puts the gear Sel picks back on when the monster hits Commy idle', function()
        gs:console('gs equip sets.TreasureHunter')
        commy.monster_acts(gs, 1)
        assert.same(commy.worn_by(idle), gs:worn())
    end)

    it('takes Commy out of combat once the battle target has been dead six seconds', function()
        commy.monster_acts(gs, 1)
        commy.defeat(gs)
        gs:play(3)
        assert.is_true(gs.user.in_combat)
        gs:play(5)
        assert.is_false(gs.user.in_combat)
    end)

    it('keeps Commy in combat while the battle target lives', function()
        commy.monster_acts(gs, 1)
        gs:play(10)
        assert.is_true(gs.user.in_combat)
    end)

    it('turns AutoDefenseMode\'s defense mode off on leaving combat', function()
        gs:console('gs c toggle AutoDefenseMode')
        commy.monster_acts(gs, 7, 'Ripper Fang')
        assert.equal('Physical', gs.user.state.DefenseMode.value)
        commy.defeat(gs)
        gs:play(8)
        assert.equal('None', gs.user.state.DefenseMode.value)
        assert.same(commy.worn_by(idle), gs:worn())
    end)
end)
