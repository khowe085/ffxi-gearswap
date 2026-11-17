local commy = require('commy')

local said = commy.said_for

describe('gs c cycle', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('moves a mode to its next option and says so by the mode\'s description', function()
        assert.same({'Idle Mode is now DT.'}, said(gs, 'gs c cycle IdleMode'))
        assert.equal('DT', gs.user.state.IdleMode.value)
    end)

    it('goes from the last option back to the first', function()
        said(gs, 'gs c set IdleMode Refresh')
        assert.same({'Idle Mode is now Normal.'}, said(gs, 'gs c cycle IdleMode'))
    end)

    it('finds the mode by its name in any case', function()
        gs:console('gs c cycle idlemode')
        assert.equal('DT', gs.user.state.IdleMode.value)
    end)

    it('goes the other way with reverse, backwards or r after the mode', function()
        gs:console('gs c cycle IdleMode reverse')
        assert.equal('Refresh', gs.user.state.IdleMode.value)
        gs:console('gs c cycle IdleMode backwards')
        assert.equal('DT', gs.user.state.IdleMode.value)
        gs:console('gs c cycle IdleMode r')
        assert.equal('Normal', gs.user.state.IdleMode.value)
    end)

    it('flips a boolean mode', function()
        assert.same({'Kiting is now on.'}, said(gs, 'gs c cycle Kiting'))
    end)

    it('puts on the set the new option picks', function()
        assert.same(commy.worn_by(commy.rdm_idle), gs:worn())
        gs:console('gs c cycle IdleMode')
        assert.same(commy.worn_by(commy.rdm_idle, {head = 'Malignance Chapeau', body = 'Malignance Tabard'}), gs:worn())
    end)

    it('says when it is given no mode, or one Sel doesn\'t have', function()
        assert.same({'Sel-Libs: Cycle parameter failure: field not specified.'}, said(gs, 'gs c cycle'))
        assert.same({'Sel-Libs: Cycle: Unknown field [Bogus]'}, said(gs, 'gs c cycle Bogus'))
    end)
end)

describe('gs c cycleback', function()
    it('moves a mode to its option before, from the first to the last', function()
        local gs = commy.boot_rdm()
        assert.same({'Idle Mode is now Refresh.'}, said(gs, 'gs c cycleback IdleMode'))
        assert.same({'Idle Mode is now DT.'}, said(gs, 'gs c cycleback IdleMode'))
    end)
end)

describe('gs c set', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('sets a mode to the option named, in any case, and says so', function()
        assert.same({'Idle Mode is now Refresh.'}, said(gs, 'gs c set IdleMode refresh'))
        assert.equal('Refresh', gs.user.state.IdleMode.value)
    end)

    it('takes an option of several words', function()
        gs:console('gs c set AutoSambaMode Haste Samba')
        assert.equal('Haste Samba', gs.user.state.AutoSambaMode.value)
    end)

    it('sets a boolean mode by on or off', function()
        assert.same({'Kiting is now on.'}, said(gs, 'gs c set Kiting on'))
        assert.same({'Kiting is now off.'}, said(gs, 'gs c set Kiting off'))
    end)

    it('names the defense mode\'s set in what it says of the defense mode', function()
        assert.same({'Defense Mode is now Physical (PDT).'}, said(gs, 'gs c set DefenseMode Physical'))
        assert.same({'Defense Mode is now Magical (MDT).'}, said(gs, 'gs c set DefenseMode Magical'))
        assert.same({'Defense Mode is now None.'}, said(gs, 'gs c set DefenseMode None'))
    end)

    it('with toggle before the mode, sets it, and sets it back to its default when it is already there', function()
        said(gs, 'gs c set toggle IdleMode DT')
        assert.equal('DT', gs.user.state.IdleMode.value)
        assert.same({'Idle Mode is now Normal.'}, said(gs, 'gs c set toggle IdleMode DT'))
        assert.equal('Normal', gs.user.state.IdleMode.value)
    end)

    it('says when it is given no mode, or one Sel doesn\'t have', function()
        assert.same({'Sel-Libs: Set parameter failure: field not specified.'}, said(gs, 'gs c set'))
        assert.same({'Sel-Libs: Set: Unknown field [Bogus]'}, said(gs, 'gs c set Bogus On'))
    end)

    pending('sets a boolean mode on when given no value, as Sel-SelfCommands.lua says: handle_set hands the mode an '
        .. 'empty string, which a boolean mode refuses with the error "Unrecognized value: "')
end)

describe('gs c toggle', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('flips a boolean mode and says so', function()
        assert.same({'Kiting is now on.'}, said(gs, 'gs c toggle Kiting'))
        assert.same({'Kiting is now off.'}, said(gs, 'gs c toggle Kiting'))
    end)

    it('steps a list mode forward', function()
        gs:console('gs c toggle IdleMode')
        assert.equal('DT', gs.user.state.IdleMode.value)
    end)

    it('says when it is given no mode, or one Sel doesn\'t have', function()
        assert.same({'Sel-Libs: Toggle parameter failure: field not specified.'}, said(gs, 'gs c toggle'))
        assert.same({'Sel-Libs: Toggle: Unknown field [Bogus]'}, said(gs, 'gs c toggle Bogus'))
    end)
end)

describe('gs c unset', function()
    it('turns a boolean mode off and says so', function()
        local gs = commy.boot_rdm()
        said(gs, 'gs c toggle Kiting')
        assert.same({'Kiting is now off.'}, said(gs, 'gs c unset Kiting'))
        assert.is_false(gs.user.state.Kiting.value)
    end)
end)

describe('gs c reset', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('sets a mode back to its default and says so', function()
        said(gs, 'gs c set IdleMode Refresh')
        assert.same({'Idle Mode is now Normal.'}, said(gs, 'gs c reset IdleMode'))
        assert.same(commy.worn_by(commy.rdm_idle), gs:worn())
    end)

    it('says when it is given a mode Sel doesn\'t have', function()
        assert.same({'Sel-Libs: Reset: Unknown field [Bogus]'}, said(gs, 'gs c reset Bogus'))
    end)

    pending('with all, sets every mode back to its default: handle_reset reads _type of each value in state, and '
        .. 'state holds the boolean th_gear_is_locked, so it stops on the error "_type" is not defined for booleans; '
        .. 'without it, it would reset nothing, since it looks for a _type of mode, which is a mode\'s _class (its '
        .. '_type is list, boolean or string), and a mode it did reset would stop it on state_var.description, '
        .. 'state_var being nil there')
end)

describe('gs c value', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('shows a mode\'s description, options and current option', function()
        said(gs, 'gs c set IdleMode DT')
        assert.same({'Idle Mode: {Normal, DT, Refresh} (DT)'}, said(gs, 'gs c value IdleMode'))
    end)

    it('shows a global of Sel\'s by its name', function()
        assert.same({'autonuke = Fire'}, said(gs, 'gs c value autonuke'))
    end)

    it('says when there is no such mode or global', function()
        assert.same({'Global value not found.'}, said(gs, 'gs c value nothing_by_this_name'))
    end)
end)

describe('gs c help', function()
    it('prints Sel\'s commands, and with fields the modes it defines', function()
        local gs = commy.boot_rdm()
        gs:console('gs c help')
        local commands = gs:printed()
        assert.equal('Custom Library Self-commands:', commands[1])
        assert.truthy(table.concat(commands, '\n'):find('Cycle list:       gs c cycle [field] [(r)everse]', 1, true))
        gs:console('gs c help fields')
        local fields = gs:printed()
        assert.equal('Predefined Library Fields:', fields[1])
        assert.truthy(table.concat(fields, '\n'):find('DefenseMode, PhysicalDefenseMode, MagicalDefenseMode', 1, true))
    end)
end)

describe('a gs c command', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        gs:console('gs equip sets.TreasureHunter')
    end)

    it('goes to the gear file\'s user_job_self_command first, which can take it and stop Sel from acting on it', function()
        gs:console('gs c commy hello there')
        assert.equal('hello there', gs.user.own_command)
        assert.equal('Volte Cap', gs:worn().head)
    end)

    it('that Sel doesn\'t know still puts the set Sel picks back on', function()
        gs:console('gs c nothing_by_this_name')
        assert.same(commy.worn_by(commy.rdm_idle), gs:worn())
    end)
end)

describe('gs c test', function()
    it('hands its words to the gear file\'s user_test', function()
        local gs = commy.boot_rdm()
        gs:console('gs c test one two')
        assert.same({'one', 'two'}, gs.user.tested_with)
    end)
end)

describe('a change of mode', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('of ElementalMode says what the new element is strong and weak against', function()
        assert.same({'Elemental Mode is now Ice.', '<Ice> (Strong vs Wind, Weak vs Fire)'},
            said(gs, 'gs c cycle ElementalMode'))
    end)

    it('of RuneElement says what the new rune resists and deals', function()
        assert.same({'Rune Element is now Unda.',
            'Unda Resists: <Fire> (Addle, Amnesia, Plague), Deals: <Water> (Strong vs Fire, Weak vs Lightning)'},
            said(gs, 'gs c set RuneElement Unda'))
    end)

    it('of Weapons to one with no set warns of it and sets Weapons back to its default', function()
        assert.same({'sets.weapons.Club does not exist, resetting weapon state.', 'Weapons is now None.'},
            said(gs, 'gs c set Weapons Club'))
        assert.equal('None', gs.user.state.Weapons.value)
    end)

    it('of CraftingMode to a craft holds sets.crafting on, until it is back to None', function()
        gs:console('gs c set CraftingMode Cooking')
        gs:console('gs c update')
        assert.same(commy.worn_by(commy.rdm_idle, {neck = 'Sanctity Necklace'}), gs:worn())
        gs:console('gs c reset CraftingMode')
        assert.same(commy.worn_by(commy.rdm_idle), gs:worn())
    end)

    it('of CraftingMode with no sets.crafting says so and sets it back to None', function()
        local war = commy.boot_war()
        assert.same({'No crafting set available, resetting Crafting Mode.', 'Crafting Mode is now None.'},
            said(war, 'gs c set CraftingMode Cooking'))
        assert.equal('None', war.user.state.CraftingMode.value)
    end)

    pending('of Weapons to one with no set lets go of the weapons held before, as Weapons None does: '
        .. 'state_change resets the mode without freeing the Weapons slot lock, so Naegling stays in hand')
end)

describe('gs c display commands', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('DisplayElement says what the element is strong and weak against', function()
        said(gs, 'gs c set ElementalMode Lightning')
        assert.same({'<Lightning> (Strong vs Water, Weak vs Earth)'}, said(gs, 'gs c DisplayElement'))
    end)

    it('DisplayShot says the element and what its shot enhances', function()
        assert.same({'<Fire> (Strong vs Ice, Weak vs Water)', 'Shot Enhances: Burn.'}, said(gs, 'gs c DisplayShot'))
    end)

    it('DisplayRune says what the rune resists and deals', function()
        assert.same({'Ignis Resists: <Ice> (Bind, Paralyze), Deals: <Fire> (Strong vs Ice, Weak vs Water)'},
            said(gs, 'gs c DisplayRune'))
    end)
end)
