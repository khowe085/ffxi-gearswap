local commy = require('commy')

-- Runs a gs c command, lets a moment pass, and returns what was typed for it and what was said in the chat log.
local function run(gs, command)
    local typed = commy.record_input(gs)
    gs:console(command)
    gs:advance(0.1)
    return typed, commy.chat(gs)
end

local function typed_for(gs, command)
    return (run(gs, command))
end

local function said_for(gs, command)
    local _, said = run(gs, command)
    return said
end

describe('gs c autorunes', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('sets two or three runes, by rune or element, and says which', function()
        assert.same({'Custom Runes currently set to: (Ignis, Gelus)'}, said_for(gs, 'gs c autorunes ignis gelus'))
        assert.same({'Custom Runes currently set to: (Ignis, Gelus, Flabra)'},
            said_for(gs, 'gs c autorunes fire ice wind'))
        assert.same({'Ignis', 'Gelus', 'Flabra'}, gs.user.custom_runes)
    end)

    it('says which runes are set when given none', function()
        gs:console('gs c autorunes tellus unda')
        commy.chat(gs)
        assert.same({'Custom Auto Runes currently set to: (Tellus, Unda)'}, said_for(gs, 'gs c autorunes'))
    end)

    it('clears them with clear or off', function()
        gs:console('gs c autorunes tellus unda')
        commy.chat(gs)
        assert.same({'Custom Runes cleared.'}, said_for(gs, 'gs c autorunes clear'))
        assert.same({}, gs.user.custom_runes)
    end)

    it('refuses one rune, or more than three', function()
        assert.same({'Autorunes requires two or three arguments.'}, said_for(gs, 'gs c autorunes ignis'))
        assert.same({'Autorunes requires two or three arguments.'}, said_for(gs, 'gs c autorunes lux lux lux lux'))
    end)

    it('refuses a word that is no rune or element', function()
        assert.same({'[bogus] is not a valid rune, setting custom runes failed.'},
            said_for(gs, 'gs c autorunes ignis bogus'))
    end)

    it('is also gs c customrunes', function()
        assert.same({'Custom Runes currently set to: (Lux, Tenebrae)'}, said_for(gs, 'gs c customrunes lux tenebrae'))
    end)
end)

describe('gs c runeelement', function()
    it('uses the rune of RuneElement', function()
        local gs = commy.boot_rdm()
        gs:console('gs c set RuneElement Lux')
        assert.same({'/ja "Lux" <me>'}, typed_for(gs, 'gs c runeelement'))
    end)
end)

describe('gs c smartws', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    -- The commands sent since the session began that name a weapon skill.
    local function sent(name)
        local found = {}
        for _, command in ipairs(gs.game.commands) do
            if command:find(name, 1, true) == 1 then
                found[#found + 1] = command
            end
        end
        return found
    end

    it('uses the job\'s weapon skill at the target in reach', function()
        gs:console('gs c smartws')
        assert.same({'Savage Blade ' .. gs.game.monster.id}, sent('Savage Blade'))
    end)

    it('says so when the target is far out of reach', function()
        gs.game.monster.distance = 17 ^ 2
        assert.same({'SmartWS Target out of range!'}, said_for(gs, 'gs c smartws'))
        assert.same({}, sent('Savage Blade'))
    end)

    pending('says so when the target is out of melee reach, at 10 yalms: handle_smartws takes the square root of '
        .. 'player.target.distance, which GearSwap already gives in yalms, so it reaches 16 yalms')

    it('says so when there is no target', function()
        gs.game.target_index = nil
        assert.same({'SmartWS Could not find a target!'}, said_for(gs, 'gs c smartws'))
    end)

    it('with ws, sets the weapon skill it uses from then on', function()
        assert.same({'SmartWS set to: Black Halo.'}, said_for(gs, 'gs c smartws ws Black Halo'))
        gs:console('gs c smartws')
        assert.same({'Black Halo ' .. gs.game.monster.id}, sent('Black Halo'))
    end)
end)

describe('gs c mount', function()
    it('rides the mount named', function()
        assert.same({'/mount Raptor'}, typed_for(commy.boot_rdm(), 'gs c mount raptor'))
    end)

    it('says so when no mount is named', function()
        assert.same({'You must specify a mount to ride.'}, said_for(commy.boot_rdm(), 'gs c mount'))
    end)

    it('gets off the mount Commy rides', function()
        local gs = commy.boot_rdm()
        gs.game.player.status = 85
        assert.same({'/dismount'}, typed_for(gs, 'gs c mount raptor'))
    end)
end)

describe('gs c autonuke', function()
    it('sets the spell AutoNukeMode casts, and says so', function()
        local gs = commy.boot_rdm()
        assert.same({'Your autonuke spell is set to Thunder.'}, said_for(gs, 'gs c autonuke thunder'))
        assert.equal('Thunder', gs.user.autonuke)
    end)

    it('says so when no spell is named', function()
        assert.same({'You must specify a spell to autonuke with.'}, said_for(commy.boot_rdm(), 'gs c autonuke'))
    end)
end)

describe('gs c autofood', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('sets the food of the AutoFoodMode it is in, and says so', function()
        gs:console('gs c set AutoFoodMode Attack')
        commy.chat(gs)
        assert.same({'Your Attack food is set to Miso Ramen.'}, said_for(gs, 'gs c autofood Miso Ramen'))
        assert.equal('Miso Ramen', gs.user.food_lists.Attack)
    end)

    it('says so while AutoFoodMode is Off', function()
        assert.same({'Auto Food is Off. Cycle AutoFoodMode to an entry first.'}, said_for(gs, 'gs c autofood Sushi'))
    end)

    it('says so when no food is named', function()
        assert.same({'You must specify a food to automatically eat.'}, said_for(gs, 'gs c autofood'))
    end)
end)

describe('gs c autows', function()
    it('points to gs c cycle AutoWS, which User-Globals.lua puts in its place without RngHelper', function()
        assert.same({'Melee auto-ws is set per weapon in AutoWS_List; cycle it with gs c cycle AutoWS.'},
            said_for(commy.boot_rdm(), 'gs c autows Savage Blade'))
    end)
end)

describe('gs c useitem', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('sets an item to use from a slot, and says how to cancel', function()
        assert.same({'Using Warp Ring, /heal to cancel.'}, said_for(gs, 'gs c useitem ring2 Warp Ring'))
        assert.same({true, 'Warp Ring', 'ring2'}, {gs.user.useItem, gs.user.useItemName, gs.user.useItemSlot})
    end)

    it('says nothing more when given the same item again', function()
        gs:console('gs c useitem ring2 Warp Ring')
        commy.chat(gs)
        assert.same({}, said_for(gs, 'gs c useitem ring2 Warp Ring'))
    end)

    it('refuses a slot that isn\'t one', function()
        assert.same({'Not a valid slot name for the UseItem command, cancelling.'},
            said_for(gs, 'gs c useitem pocket Warp Ring'))
        assert.is_false(gs.user.useItem)
    end)

    it('says how it is used when given nothing', function()
        assert.same({'Syntax error with UseItem command - Use: gs c UseItem equipslot Item Name (Use item for '
            .. 'non-equippable items).'}, said_for(gs, 'gs c useitem'))
    end)

    it('is cancelled by resting', function()
        gs:console('gs c useitem item Instant Warp')
        commy.chat(gs)
        gs:run(function()
            gs.game:set_status(33)
            gs.game:settle()
        end)
        assert.same({'Cancelling using Instant Warp.'}, commy.chat(gs))
        assert.is_false(gs.user.useItem)
    end)
end)

describe('gs c stna', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        gs.game.target_index = nil
    end)

    it('casts the spell that removes Commy\'s status when Commy has no target', function()
        gs:gain_buff('paralysis')
        assert.same({'/ma "Paralyna" Commy'}, typed_for(gs, 'gs c stna'))
    end)

    it('says so when there is nothing to remove', function()
        assert.same({'No statuses found that are removable by STNA.'}, said_for(gs, 'gs c stna'))
    end)
end)

describe('gs c facemob', function()
    it('turns Commy to face the monster Commy targets', function()
        local gs = commy.boot_rdm()
        gs.game.monster.x, gs.game.monster.y = 0, 3
        gs:console('gs c facemob')
        assert.equal(1, #gs.game.turns)
        assert.near(-math.pi / 2, gs.game.turns[1], 1e-9)
    end)
end)

describe('gs c killstatue', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        gs.game.monster.name = 'Lithicthrower Image'
        gs.game.monster.status = 1
    end)

    it('uses the job\'s statue weapon skill on a statue in reach in Bastok\'s Dynamis [D]', function()
        gs:change_zone(295)
        gs:console('gs c killstatue')
        gs:advance(0.5)
        assert.truthy(table.concat(gs.game.commands, '\n'):find('Sanguine Blade ' .. gs.game.monster.id, 1, true))
    end)

    it('does nothing outside Dynamis', function()
        gs:console('gs c killstatue')
        gs:advance(0.5)
        assert.falsy(table.concat(gs.game.commands, '\n'):find('Sanguine Blade', 1, true))
    end)
end)

describe('gs c subjobenmity', function()
    it('does as gs c enmity does', function()
        assert.same({'/ma "Flash" <t>'}, typed_for(commy.boot_rdm(), 'gs c subjobenmity'))
    end)
end)

describe('gs c buffup', function()
    it('starts the Default list of buffs when given none', function()
        local gs = commy.boot_rdm()
        gs:console('gs c buffup')
        assert.equal('Default', gs.user.buffup)
    end)

    it('starts the list of buffs named', function()
        local gs = commy.boot_rdm()
        gs:console('gs c buffup MageBuff')
        assert.equal('MageBuff', gs.user.buffup)
    end)

    it('says so when there is no list by that name', function()
        local gs = commy.boot_rdm()
        assert.same({'Bogus is not a buff list!'}, said_for(gs, 'gs c buffup Bogus'))
        assert.equal('', gs.user.buffup)
    end)
end)
