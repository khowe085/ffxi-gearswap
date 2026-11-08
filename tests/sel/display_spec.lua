local commy = require('commy')

local yellow = '\\cs(255,192,0)'

-- The status box's text as it reads, without its colours.
local function box(gs)
    return (gs.user.stateBox:text():gsub('\\cs%(%d+,%d+,%d+%)', ''))
end

-- Whether the status box reads the text, without its colours.
local function shows(gs, text)
    return box(gs):find(text, 1, true) ~= nil
end

-- What the status box reads for the Auto WS mode of User-Globals.lua at the value it holds, and nothing where there is
-- no such mode.
local function auto_ws(gs)
    local mode = gs.user.state.AutoWS
    return mode and ('Auto WS: ' .. mode.value .. '    ') or ''
end

-- The first of the texts that the status box doesn't read after the one before it, or nil where it reads them all in
-- order.
local function first_out_of_order(gs, texts)
    local text, from = box(gs), 1
    for _, each in ipairs(texts) do
        local at = text:find(each, from, true)
        if not at then
            return each
        end
        from = at + #each
    end
end

describe('Sel\'s status box', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    -- Where the booleans that are on come: after the Weapons entry, and the Auto WS entry where there is one.
    local function booleans(text)
        return 'Weapons: None (L)    ' .. auto_ws(gs) .. text
    end

    it('shows the modes RDM.lua names, each at its option, once loaded', function()
        -- Where Treasure starts is up to User-Globals.lua: the box shows it unless it is None.
        gs:console('gs c set TreasureMode Tag')
        assert.equal('   Auto Trust: Off    Offense: Normal / Normal    '
            .. 'Weapons: None (L)    ' .. auto_ws(gs) .. 'Recover MP: 35%    Element: Fire    Casting: Normal    '
            .. 'Treasure: Tag    ', box(gs))
        assert.is_true(gs.user.stateBox:visible())
    end)

    it('shows Auto Trust, Auto Buff, Offense, Weapons, Auto WS, the booleans on, then the other modes', function()
        gs:console('gs c cycle AutoBuffMode')
        gs:console('gs c toggle AutoStunMode')
        assert.is_nil(first_out_of_order(gs, {'Auto Trust: ', 'Auto Buff: ', 'Offense: ', 'Weapons: ', auto_ws(gs),
            'Auto Stun    ', 'Recover MP: '}))
    end)

    it('shows Auto Trust, Auto Buff, Offense and Weapons only when the job lists them', function()
        gs:console('gs c cycle AutoBuffMode')
        gs.user.stateList = {'RecoverMode'}
        gs:console('gs c update')
        for _, text in ipairs({'Auto Trust:', 'Auto Buff:', 'Offense:', 'Weapons:'}) do
            assert.is_false(shows(gs, text), text)
        end
        assert.is_true(shows(gs, 'Recover MP:'))
    end)

    it('shows a mode in yellow once it is off its first option', function()
        assert.falsy(gs.user.stateBox:text():find('Casting: ' .. yellow, 1, true))
        gs:console('gs c cycle CastingMode')
        assert.truthy(gs.user.stateBox:text():find('Casting: ' .. yellow .. 'Resistant', 1, true))
    end)

    it('shows the weapon set by its name', function()
        gs:console('gs c set Weapons Naegling')
        assert.is_true(shows(gs, 'Weapons: Naegling (L)'))
    end)

    it('shows the weapons as (L), and as (U) while UnlockWeapons is on', function()
        assert.is_true(shows(gs, 'Weapons: None (L)'))
        gs:console('gs c toggle UnlockWeapons')
        assert.is_true(shows(gs, 'Weapons: None (U)'))
    end)

    it('shows the offense and hybrid modes', function()
        gs:console('gs c set OffenseMode Acc')
        gs:console('gs c set HybridMode DT')
        assert.is_true(shows(gs, 'Offense: Acc / DT'))
    end)

    it('shows the idle mode only once it isn\'t Normal', function()
        assert.is_false(shows(gs, 'Idle:'))
        gs:console('gs c set IdleMode Refresh')
        assert.is_true(shows(gs, 'Idle: Refresh'))
    end)

    it('shows Kiting while it is on', function()
        gs:console('gs c toggle Kiting')
        assert.is_true(shows(gs, 'Kiting: On'))
    end)

    it('shows the defense mode and its set in place of the offense mode and Treasure', function()
        gs:console('gs c set TreasureMode Tag')
        assert.is_true(shows(gs, 'Treasure: Tag'))
        gs:console('gs c set DefenseMode Physical')
        assert.is_true(shows(gs, 'Defense Active: Physical: PDT'))
        assert.is_false(shows(gs, 'Offense:'))
        assert.is_false(shows(gs, 'Treasure:'))
    end)

    it('shows the weapon skill mode only once it isn\'t Match', function()
        assert.is_false(shows(gs, 'Weaponskill:'))
        gs:console('gs c set WeaponskillMode Acc')
        assert.is_true(shows(gs, 'Weaponskill: Acc'))
    end)

    it('shows the element in the element\'s colour', function()
        gs:console('gs c set ElementalMode Ice')
        assert.truthy(gs.user.stateBox:text():find('Element: \\cs(140,160,255)Ice', 1, true))
    end)

    it('shows Magic Burst while it is on', function()
        gs:console('gs c set MagicBurstMode Single')
        assert.is_true(shows(gs, 'Casting: Normal    Magic Burst: Single'))
    end)

    it('shows the passive mode once it isn\'t None', function()
        gs:console('gs c set Passive Emp')
        assert.is_true(shows(gs, 'Passive: Emp'))
    end)

    it('shows the treasure mode only while it isn\'t None, for a job other than thief', function()
        gs:console('gs c set TreasureMode None')
        assert.is_false(shows(gs, 'Treasure:'))
    end)

    it('shows Auto Buff and Auto Food once they are on, Auto Food with its food', function()
        gs.user.food_lists = {Attack = 'Grape Daifuku'}
        gs.user.state.AutoFoodMode:options('Off', 'Attack')
        gs:console('gs c set AutoBuffMode Auto')
        gs:console('gs c set AutoFoodMode Attack')
        assert.is_true(shows(gs, 'Auto Buff: Auto'))
        assert.is_true(shows(gs, 'Auto Food: Attack (Grape Daifuku)'))
    end)

    it('shows a boolean mode by its label while it is on', function()
        gs:console('gs c toggle AutoStunMode')
        assert.is_true(shows(gs, booleans('Auto Stun    ')))
    end)

    it('shows Auto Defense while it is on, and that it keeps to tanking with TankAutoDefense', function()
        gs:console('gs c toggle AutoDefenseMode')
        assert.is_true(shows(gs, booleans('Auto Defense    ')))
        gs:console('gs c toggle TankAutoDefense')
        gs:console('gs c update')
        assert.is_true(shows(gs, booleans('Auto Defense: Tank    ')))
    end)

    it('shows Auto Nuke with the spell gs c autonuke set', function()
        gs:console('gs c toggle AutoNukeMode')
        gs:console('gs c autonuke Thunder')
        assert.is_true(shows(gs, 'Auto Nuke: Thunder'))
    end)

    it('shows only the crafting mode and quality while crafting', function()
        gs:console('gs c set CraftingMode Cooking')
        assert.equal('   Crafting Mode: Cooking    Crafting Quality: Normal', box(gs))
    end)

    it('hides on gs c update once DisplayMode is off, and shows again when it is turned on', function()
        gs:console('gs c toggle DisplayMode')
        gs:console('gs c update')
        assert.is_false(gs.user.stateBox:visible())
        gs:console('gs c toggle DisplayMode')
        assert.is_true(gs.user.stateBox:visible())
    end)

    pending('hides as soon as DisplayMode is turned off: state_change calls update_job_states only while DisplayMode '
        .. 'is on, so the box stays up until something else updates it, as gs c update does')

    it('hides when the client leaves the zone, as on logging out', function()
        gs:leave_zone()
        assert.is_false(gs.user.stateBox:visible())
    end)

    it('shows again on zoning in', function()
        gs:change_zone(248)
        assert.is_true(gs.user.stateBox:visible())
    end)

    it('stays hidden on zoning in while DisplayMode is off', function()
        gs:console('gs c toggle DisplayMode')
        gs:change_zone(248)
        assert.is_false(gs.user.stateBox:visible())
    end)

    it('shows a thief\'s treasure mode even at None', function()
        local thf = commy.boot_thf()
        thf:console('gs c set TreasureMode None')
        assert.is_true(shows(thf, 'Treasure: None'))
    end)

    it('shows the stance of a warrior with samurai as sub job while it isn\'t None', function()
        local war = commy.boot_war({sub_job = 'SAM'})
        assert.is_true(shows(war, 'Stance: Hasso'))
        war:console('gs c set Stance None')
        assert.is_false(shows(war, 'Stance:'))
    end)

    it('shows the rune with rune fencer as sub job, and the custom runes once two are set', function()
        local war = commy.boot_war({sub_job = 'RUN'})
        assert.is_true(shows(war, 'Rune: Ignis    '))
        war:console('gs c autorunes tellus unda')
        assert.is_true(shows(war, 'Rune: Ignis    Custom Autorunes: (Tellus, Unda)'))
    end)

    it('shows AutoRuneMode\'s rune, or its custom runes, with rune fencer as sub job once it is on', function()
        local war = commy.boot_war({sub_job = 'RUN'})
        war:console('gs c set AutoRuneMode Runes')
        assert.is_true(shows(war, 'Auto Rune (Runes): Ignis'))
        assert.is_false(shows(war, 'Rune: Ignis    '))
        war:console('gs c autorunes lux tenebrae lux')
        assert.is_true(shows(war, 'Custom Auto Rune (Runes): (Lux, Tenebrae, Lux)'))
    end)

    it('shows no rune without rune fencer as either job', function()
        assert.is_false(shows(commy.boot_war(), 'Rune'))
    end)

    pending('lays display.labels over its own labels: update_job_states combines them with set_combine, which keeps '
        .. 'only gear slots, so no label is left, display.labels\' or its own (passed as lables, a misspelt name that '
        .. 'is nil), and the box stops on an error at the first label it shows')
end)
