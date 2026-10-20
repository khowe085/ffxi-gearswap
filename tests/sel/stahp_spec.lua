local commy = require('commy')

local idle = commy.rdm_idle

describe('Sel\'s AutoDefenseMode', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        gs:console('gs c toggle AutoDefenseMode')
    end)

    it('puts the physical defense set on when the monster readies a physical move at Commy', function()
        gs:monster_acts(7, 'Ripper Fang')
        assert.equal('Physical', gs.user.state.DefenseMode.value)
        assert.same(commy.worn_by(idle, {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard'}), gs:worn())
    end)

    it('puts the magical defense set on for a magical move', function()
        gs:monster_acts(7, 'Foul Breath')
        assert.equal('Magical', gs.user.state.DefenseMode.value)
        assert.same(commy.worn_by(idle, {body = 'Volte Jupon'}), gs:worn())
    end)

    it('puts the resist defense set on for a move that would put a status on Commy', function()
        gs:monster_acts(7, 'Sweet Breath')
        assert.equal('Resist', gs.user.state.DefenseMode.value)
        assert.same(commy.worn_by(idle, {back = 'Null Shawl'}), gs:worn())
    end)

    it('leaves the defense mode as it is for a move it doesn\'t list', function()
        gs:monster_acts(7, 'Spore')
        assert.equal('None', gs.user.state.DefenseMode.value)
    end)

    it('leaves it as it is for a move at the monster itself, unless the move reaches round it', function()
        gs:monster_acts(7, 'Ripper Fang', gs.game.monster.id)
        assert.equal('None', gs.user.state.DefenseMode.value)
        gs:monster_acts(7, 'Foul Breath', gs.game.monster.id)
        assert.equal('Magical', gs.user.state.DefenseMode.value)
    end)

    it('takes the defense set off again once the monster Commy targets has used the move', function()
        gs:monster_acts(7, 'Ripper Fang')
        gs:monster_acts(11, 'Ripper Fang')
        assert.equal('None', gs.user.state.DefenseMode.value)
        assert.same(commy.worn_by(idle), gs:worn())
    end)

    it('with TankAutoDefense on, goes back to the physical defense set after a move', function()
        gs:console('gs c toggle TankAutoDefense')
        gs:monster_acts(7, 'Foul Breath')
        gs:monster_acts(11, 'Foul Breath')
        assert.equal('Physical', gs.user.state.DefenseMode.value)
    end)
end)

describe('Sel with AutoDefenseMode off', function()
    it('leaves the defense mode alone whatever the monster readies', function()
        local gs = commy.boot_rdm()
        gs:monster_acts(7, 'Ripper Fang')
        assert.equal('None', gs.user.state.DefenseMode.value)
        assert.same(commy.worn_by(idle), gs:worn())
    end)
end)

describe('Sel\'s AutoAcceptRaiseMode', function()
    -- The server's offer of a raise (0x0F9): Commy, and the kind of raise.
    local function offer_raise(gs)
        local player = gs.game.player
        gs:receive(0x0F9, string.char(player.id % 256, math.floor(player.id / 256) % 256,
            math.floor(player.id / 65536) % 256, 0, player.index % 256, math.floor(player.index / 256), 1, 0))
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
        gs:change_zone(132)
        gs.game.monster.claim_id = gs.game.player.id
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
        gs:change_zone(288)
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
        gs:monster_acts(1)
        assert.is_true(gs.user.in_combat)
    end)

    it('takes Commy to be in combat once the monster begins a spell at Commy', function()
        gs:monster_acts(8, 'Slow')
        assert.is_true(gs.user.in_combat)
    end)

    it('puts the gear Sel picks back on when the monster hits Commy idle', function()
        gs:console('gs equip sets.TreasureHunter')
        gs:monster_acts(1)
        assert.same(commy.worn_by(idle), gs:worn())
    end)
end)
