local plain = require('plain')

local calls, events = plain.calls, plain.names

local function boot(overrides)
    local gs = plain.boot('Testy_Actions.lua', overrides)
    calls(gs)
    return gs
end

-- The packet the server sends about an action of the player's, as the fields say.
local function server_act(gs, fields)
    local act = {category = fields.category, param = fields.param or 0, recast = 0,
        targets = {{id = fields.target_id or gs.game.player.id, actions = {{message = fields.message or 0,
            param = fields.value or 0, reaction = 0, animation = 0, effect = 0, stagger = 0}}}}}
    gs:run(function()
        gs.game:send_action_packet(act)
        gs.game:settle()
    end)
end

describe('the spell a hook is handed', function()
    it('has the names of its skill and element, and its cost and cast time', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        local got = calls(gs)[2]
        assert.same({'Healing Magic', 'Light', 46, 2.5, 3}, {got.skill, got.element, got.mp_cost, got.cast_time, got.spell_id})
    end)

    it('has the MP the player will have left', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        assert.equal(1000 - 46, calls(gs)[2].mpaftercast)
    end)

    it('has the MP the player has when the action costs none', function()
        local gs = boot()
        gs:type('/ja "Divine Seal" <me>')
        local got = calls(gs)[2]
        assert.same({0, 1000}, {got.mp_cost, got.mpaftercast})
    end)

    it('has the TP a weapon skill uses, which is all the player has, and none left', function()
        local gs = boot({tp = 1500})
        gs:type('/ws "Black Halo" <t>')
        local got = calls(gs)[2]
        assert.same({1500, 0}, {got.tp_cost, got.tpaftercast})
    end)

    it('has the TP the player has left when the action costs none', function()
        local gs = boot({tp = 1500})
        gs:type('/ma "Cure III" <me>')
        assert.equal(1500, calls(gs)[2].tpaftercast)
    end)

    pending('has the percentage of MP the player will have left, as mppaftercast, which is 0 to 100 as mpp is: for an '
        .. 'action that costs MP it is the MP left over the maximum, a fraction (one that costs none gets mpp), so a '
        .. 'check such as spell.mppaftercast > 50, in beta_examples_and_information/Byrth_BLM.lua and Byrth_GEO.lua, '
        .. 'is never true of a spell that costs MP')
end)

describe('a command typed with another name for its prefix', function()
    local function typed(command)
        local gs = boot()
        gs:type(command)
        return events(calls(gs)), gs:traffic()
    end

    it('/magic is /ma', function()
        local names, traffic = typed('/magic "Cure III" <me>')
        assert.same({'pretarget', 'precast', 'midcast'}, names)
        assert.equal('Cure III', traffic[2].action)
    end)

    it('/song is /ma', function()
        local names = typed('/song "Cure III" <me>')
        assert.same({'pretarget', 'precast', 'midcast'}, names)
    end)

    it('/nin is /ma', function()
        local names = typed('/nin "Cure III" <me>')
        assert.same({'pretarget', 'precast', 'midcast'}, names)
    end)

    it('/weaponskill is /ws', function()
        local _, traffic = typed('/weaponskill "Black Halo" <t>')
        assert.equal('Black Halo', traffic[2].action)
    end)

    it('/jobability is /ja', function()
        local _, traffic = typed('/jobability "Divine Seal" <me>')
        assert.equal('Divine Seal', traffic[2].action)
    end)

    it('is an action of the same kind to the hooks, whatever the name', function()
        local gs = boot()
        gs:type('/magic "Cure III" <me>')
        local got = calls(gs)[1]
        assert.same({'Magic', 'WhiteMagic'}, {got.action_type, got.type})
        gs:type('/jobability "Divine Seal" <me>')
        got = calls(gs)[1]
        assert.same({'Ability', 'JobAbility'}, {got.action_type, got.type})
    end)

    it('takes the action\'s name in lower case, and without quotes when it is one word', function()
        local gs = boot()
        gs:type('/ma "cure iii" <me>')
        gs:type('/ma Haste <me>')
        local got = calls(gs)
        assert.same({'Cure III', 'Haste'}, {got[1].name, got[4].name})
    end)

    it('is sent when a wait is in the line, as macros have them', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me> <wait 3>')
        assert.same({'pretarget', 'precast', 'midcast'}, events(calls(gs)))
    end)
end)

describe('a packet another addon injected', function()
    local function item_packet(gs)
        local body = gs.game:packet_body(0x020, {['Count'] = 1, ['Item'] = 26366, ['Bag'] = 0, ['Index'] = 70})
        return string.char(0x20, 0x0C, 1, 0) .. body
    end

    it('is not read by GearSwap', function()
        local gs = boot()
        local data = item_packet(gs)
        gs.game:fire('incoming chunk', 0x020, data, data, true, false)
        assert.equal(0, gs.env.items.inventory[70].id)
    end)

    it('is read when it comes from the game', function()
        local gs = boot()
        local data = item_packet(gs)
        gs.game:fire('incoming chunk', 0x020, data, data, false, false)
        assert.equal(26366, gs.env.items.inventory[70].id)
    end)
end)

describe('an action that never ends', function()
    -- GearSwap keeps a spell for its cast time and a tenth more, and two seconds: 4.75 for Cure III's 2.5.
    it('is forgotten after the time it should take, and a bit more', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        assert.is_true((gs.user.midaction()))
        gs:advance(5)
        plain.refresh(gs)
        assert.is_false(gs.user.midaction())
    end)

    it('is kept while it may still be going on, just under that time', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        gs:advance(4)
        plain.refresh(gs)
        assert.is_true((gs.user.midaction()))
    end)

    it('is kept longer for a long cast time, as a spell that takes 15 seconds', function()
        local gs = boot()
        gs:type('/ma "Raise" <me>')
        gs:advance(15)
        plain.refresh(gs)
        assert.is_true((gs.user.midaction()))
        gs:advance(10)
        plain.refresh(gs)
        assert.is_false(gs.user.midaction())
    end)

    it('is forgotten sooner for an ability, which has no cast time', function()
        local gs = boot()
        gs:type('/ja "Divine Seal" <me>')
        assert.is_true((gs.user.midaction()))
        gs:advance(4)
        plain.refresh(gs)
        assert.is_false(gs.user.midaction())
    end)
end)

describe('what the server says an action came to', function()
    it('for a spell that did its work gives aftercast its value', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        calls(gs)
        gs:finish_action({value = 482})
        local got = calls(gs)[1]
        assert.same({'aftercast', 'Cure III', 482}, {got.event, got.name, got.value})
    end)

    it('for a weapon skill gives aftercast the damage', function()
        local gs = boot()
        gs:type('/ws "Black Halo" <t>')
        calls(gs)
        gs:finish_action({value = 1200})
        assert.equal(1200, calls(gs)[1].value)
    end)

    it('for an action GearSwap never saw begin is none of its business', function()
        local gs = boot()
        server_act(gs, {category = 4, param = 3, value = 100})
        assert.same({}, calls(gs))
    end)

    it('for an action that is over already, once more, is not told to aftercast again', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        calls(gs)
        gs:finish_action()
        gs:finish_action()
        assert.same({'aftercast'}, events(calls(gs)))
    end)

    it('as a melee round is left alone', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        calls(gs)
        server_act(gs, {category = 1, param = 0, target_id = gs.game.monster.id, value = 50, message = 1})
        assert.same({}, calls(gs))
        assert.is_true((gs.user.midaction()))
    end)

    it('for Double-Up is told as the roll it rolled', function()
        local gs = boot()
        gs:type('/ja "Double-Up" <me>')
        calls(gs)
        server_act(gs, {category = 6, param = 98, value = 4})
        local got = calls(gs)[1]
        assert.same({'aftercast', "Fighter's Roll"}, {got.event, got.name})
    end)

    it('as a roll that is no Double-Up is not taken for one', function()
        local gs = boot()
        gs:type('/ja "Divine Seal" <me>')
        calls(gs)
        server_act(gs, {category = 6, param = 98, value = 4})
        assert.same({}, calls(gs))
    end)

    it('as a message of its own for Divine Seal is the ability, whatever its id', function()
        local gs = boot()
        gs:type('/ja "Divine Seal" <me>')
        calls(gs)
        server_act(gs, {category = 6, param = 0, value = 0, message = 303})
        local got = calls(gs)[1]
        assert.same({'aftercast', 'Divine Seal'}, {got.event, got.name})
    end)
end)

describe('a pet\'s command ended by the server', function()
    local function boot_with_pet()
        local gs = boot()
        gs.game:place_pet({name = 'Carbuncle'})
        plain.refresh(gs)
        gs:type('/pet "Assault" <t>')
        calls(gs)
        return gs
    end

    it('when the target dies is told to pet_aftercast', function()
        local gs = boot_with_pet()
        gs:run(function()
            gs.game:send_action_message({message_id = 6, actor_id = gs.game.player.id, target_id = gs.game.monster.id})
            gs.game:settle()
        end)
        assert.same({'pet_aftercast'}, events(calls(gs)))
    end)

    it('when the target is too far away is told to pet_aftercast, marked interrupted', function()
        local gs = boot_with_pet()
        server_act(gs, {category = 8, param = 0, value = 0, message = 78, target_id = gs.game.monster.id})
        local got = calls(gs)[1]
        assert.same({'pet_aftercast', true}, {got.event, got.interrupted})
    end)

    it('when the server says the player can\'t, from the pet, is told to pet_aftercast, marked interrupted', function()
        local gs = boot_with_pet()
        local pet = gs.game.pet
        gs:run(function()
            gs.game:send_action_message({message_id = 17, actor_id = pet.id, target_id = gs.game.monster.id})
            gs.game:settle()
        end)
        local got = calls(gs)[1]
        assert.same({'pet_aftercast', true}, {got.event, got.interrupted})
    end)
end)

describe('gear changes', function()
    local fast_cast = {head = "Bunzi's Hat"}

    it('are not made while the player is charmed, and neither is the action sent, but the hooks are called', function()
        local gs = boot()
        gs:gain_buff('charm')
        gs:traffic()
        gs:type('/ma "Cure III" <me>')
        assert.same({}, gs:traffic())
        assert.same({'pretarget', 'precast', 'midcast'}, events(calls(gs)))
    end)

    it('are made again once the charm ends', function()
        local gs = boot()
        gs:gain_buff('charm')
        gs:lose_buff('charm')
        gs:traffic()
        gs:type('/ma "Cure III" <me>')
        assert.same({equip = fast_cast}, gs:traffic()[1])
    end)

    pending('are not made while the player is dead or engaged dead: the check compares the status, a name by then, with '
        .. '2 and 3, which it never is')

    it('are not made, and the hooks run, for a player that is a monster', function()
        local gs = boot()
        gs.game.player.race = 0
        plain.refresh(gs)
        gs:traffic()
        gs:type('/ma "Cure III" <me>')
        assert.same({{action = 'Cure III', target = 'Testy'}}, gs:traffic())
        assert.same({'pretarget', 'precast', 'midcast'}, events(calls(gs)))
    end)
end)

describe('a delayed cast that GearSwap is asked for by the game\'s console', function()
    it('with an index that is no number sends nothing, and says nothing wrong', function()
        local gs = boot()
        assert.has_no.errors(function()
            gs:console('lua i gearswap pretarget_delayed_cast nonsense')
            gs:console('lua i gearswap precast_delayed_cast nonsense')
        end)
        assert.same({}, gs:traffic())
        assert.same({{}, {}}, {gs:chat(), gs:printed()})
    end)
end)
