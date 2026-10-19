local commy = require('commy')

local idle = commy.war_idle

-- The idle set at noon: sets.idle with sets.DayIdle over it.
local noon = {waist = 'Chaac Belt'}

local function at(hour, minute)
    return hour * 60 + (minute or 0)
end

describe('Sel\'s idle set and the time of day', function()
    local gs
    before_each(function()
        gs = commy.boot_war()
    end)

    it('has sets.DayIdle laid over it in the daytime', function()
        assert.same(commy.worn_by(idle, noon), gs:worn())
    end)

    it('has sets.NightIdle and sets.DuskIdle laid over it at night, once the clock passes into it', function()
        commy.game(gs, 'set_time', at(20))
        assert.same(commy.worn_by(idle, {waist = 'Reiki Yotai', neck = 'Sanctity Necklace'}), gs:worn())
    end)

    it('takes 17:00 to 18:00 for both day and dusk', function()
        commy.game(gs, 'set_time', at(17, 30))
        assert.same(commy.worn_by(idle, {waist = 'Chaac Belt', neck = 'Sanctity Necklace'}), gs:worn())
    end)

    it('takes 6:00 to 7:00 for day and still dusk', function()
        commy.game(gs, 'set_time', at(20))
        commy.game(gs, 'set_time', at(6, 30))
        assert.same(commy.worn_by(idle, {waist = 'Chaac Belt', neck = 'Sanctity Necklace'}), gs:worn())
    end)

    it('takes 18:00 for night and dusk', function()
        commy.game(gs, 'set_time', at(18))
        assert.same(commy.worn_by(idle, {waist = 'Reiki Yotai', neck = 'Sanctity Necklace'}), gs:worn())
    end)

    it('changes no gear for a time that stays in the same part of the day', function()
        commy.game(gs, 'set_time', at(13))
        assert.same({}, gs:traffic())
    end)

    it('leaves the time of day\'s sets off in an idle mode other than Normal', function()
        gs:console('gs c set IdleMode DT')
        assert.same(commy.worn_by(idle, {ring2 = "Medada's Ring"}), gs:worn())
        commy.game(gs, 'set_time', at(20))
        assert.same(commy.worn_by(idle, {ring2 = "Medada's Ring"}), gs:worn())
    end)

    pending('has the time of day\'s set laid over it from the moment Sel loads: classes.Daytime starts false and only '
        .. 'a time change event sets it, so until the first one the idle set has sets.NightIdle over it at noon')
end)

describe('Sel\'s idle set and HP', function()
    local gs
    before_each(function()
        gs = commy.boot_war()
    end)

    it('has sets.ExtraRegen laid over it below 80% HP', function()
        gs.game.player.vitals.hpp = 79
        gs:console('gs c update')
        assert.same(commy.worn_by(idle, {waist = 'Chaac Belt', back = 'Moonlight Cape'}), gs:worn())
    end)

    it('is without sets.ExtraRegen at 80% HP and above', function()
        gs.game.player.vitals.hpp = 80
        gs:console('gs c update')
        assert.same(commy.worn_by(idle, noon), gs:worn())
    end)
end)

describe('Sel in a town', function()
    local gs
    before_each(function()
        gs = commy.boot_war()
    end)

    it('takes Commy to be in town on zoning into one', function()
        commy.game(gs, 'change_zone', 248)
        assert.is_true(gs.user.in_town)
        commy.game(gs, 'change_zone', 288)
        assert.is_false(gs.user.in_town)
    end)

    it('lays sets.Kiting and sets.Town over the idle set', function()
        commy.game(gs, 'change_zone', 248)
        gs:console('gs c update')
        assert.same(commy.worn_by(idle, {waist = 'Chaac Belt', feet = 'Volte Boots', head = 'Volte Cap'}), gs:worn())
    end)

    it('puts the nation\'s aketon on in San d\'Oria', function()
        commy.game(gs, 'change_zone', 230)
        gs:console('gs c update')
        assert.same(commy.worn_by(idle, {waist = 'Chaac Belt', feet = 'Volte Boots', head = 'Volte Cap',
            body = 'Kingdom Aketon'}), gs:worn())
    end)

    it('takes the town\'s sets off again once out of town', function()
        commy.game(gs, 'change_zone', 230)
        gs:console('gs c update')
        commy.game(gs, 'change_zone', 288)
        gs:console('gs c update')
        assert.same(commy.worn_by(idle, noon), gs:worn())
    end)
end)

describe('Sel on zoning', function()
    local gs
    before_each(function()
        gs = commy.boot_war()
    end)

    it('turns its automatic modes off', function()
        gs:console('gs c set AutoBuffMode Auto')
        gs:console('gs c set AutoFoodMode Attack')
        gs:console('gs c set AutoTrustMode Default')
        gs:console('gs c toggle AutoNukeMode')
        gs:console('gs c toggle AutoTankMode')
        gs:console('gs c toggle AutoSubMode')
        local state = gs.user.state
        local function auto_modes()
            return {state.AutoBuffMode.value, state.AutoFoodMode.value, state.AutoTrustMode.value,
                state.AutoNukeMode.value, state.AutoTankMode.value, state.AutoSubMode.value}
        end
        assert.same({'Auto', 'Attack', 'Default', true, true, true}, auto_modes())
        commy.game(gs, 'change_zone', 248)
        assert.same({'Off', 'Off', 'Off', false, false, false}, auto_modes())
    end)

    it('leaves the gear modes as they were', function()
        gs:console('gs c set IdleMode DT')
        gs:console('gs c set OffenseMode Acc')
        commy.game(gs, 'change_zone', 248)
        assert.same({'DT', 'Acc'}, {gs.user.state.IdleMode.value, gs.user.state.OffenseMode.value})
    end)

    it('stops waiting to use an item', function()
        gs:console('gs c useitem ring2 Warp Ring')
        assert.is_true(gs.user.useItem)
        commy.game(gs, 'change_zone', 248)
        assert.is_false(gs.user.useItem)
        assert.equal('', gs.user.useItemName)
    end)
end)

describe('Sel on a sub job change', function()
    local gs
    before_each(function()
        gs = commy.boot_war()
    end)

    it('hands the new sub job to the gear file\'s hook', function()
        commy.game(gs, 'change_sub_job', 'NIN', 49)
        assert.equal(1, gs.user.sub_job_changes)
        assert.equal('NIN', gs.user.sub_job_changed_to)
    end)

    it('runs the gear file\'s setup again, which starts its modes at their first options', function()
        gs:console('gs c set IdleMode DT')
        commy.game(gs, 'change_sub_job', 'NIN', 49)
        assert.equal('Normal', gs.user.state.IdleMode.value)
        assert.same(commy.worn_by(idle, noon), gs:worn())
    end)
end)

describe('Sel in Ghoyu\'s Reverie', function()
    it('sets itself to use a Revitalizer as soon as one comes into the inventory', function()
        local gs = commy.boot_war()
        commy.game(gs, 'change_zone', 129)
        gs:run(function()
            gs.game:fire('add item', 0, 1, 4146, 1)
            gs.game:settle()
        end)
        assert.same({true, 'Revitalizer', 'item'}, {gs.user.useItem, gs.user.useItemName, gs.user.useItemSlot})
        assert.same({'Revitalizer added to inventory, using, /heal to cancel.'}, commy.chat(gs))
    end)
end)

describe('Sel on Asura', function()
    -- The client sending a tell (0x0B6) to the player named: 3, the name in 15 bytes, and the message.
    local function tell(gs, name, message)
        gs:run(function()
            gs.game:send_from_client(0x0B6, string.char(3, 0) .. name .. string.char(0):rep(15 - #name) .. message
                .. string.char(0))
            gs.game:settle()
        end)
    end

    it('stops a tell to Mytha that names a third-party tool, and says why', function()
        local gs = commy.boot_war()
        gs.game:set_info({server = 31})
        tell(gs, 'Mytha', 'is there an addon for this?')
        assert.same({'Message Aborted: Please do not message me about anything third party ingame. -50DKP',
            'Contact me on Discord: KalesAndRancor#5410 or https://discord.gg/ug6xtvQ'}, commy.chat(gs))
    end)

    it('lets any other tell go', function()
        local gs = commy.boot_war()
        gs.game:set_info({server = 31})
        tell(gs, 'Mytha', 'hello')
        tell(gs, 'Vanar', 'is there an addon for this?')
        assert.same({}, commy.chat(gs))
    end)
end)

describe('Sel on loading', function()
    it('checks for dual wield five seconds on, and starts the weapons over', function()
        local gs = commy.boot_rdm()
        gs:console('gs c set Weapons Naegling')
        gs:advance(4.9)
        assert.equal('Naegling', gs.user.state.Weapons.value)
        gs:advance(0.2)
        assert.truthy(table.concat(gs.game.commands, '\n'):find('gs c weapons initialize', 1, true))
        assert.is_false(gs.user.can_dual_wield)
        assert.equal('None', gs.user.state.Weapons.value)
    end)
end)
