local plain = require('plain')
local testy = require('testy')

local calls, events, error_of = plain.calls, plain.names, plain.error_of

local function boot(overrides)
    local gs = plain.boot('Testy_Actions.lua', overrides)
    calls(gs)
    return gs
end

-- The packets of that id GearSwap sent since the mark, a count of what had been sent.
local function sent_since(gs, mark, id)
    local found = {}
    for i = mark + 1, #gs.game.sent do
        if gs.game.sent[i].id == id then
            found[#found + 1] = gs.game.sent[i]
        end
    end
    return found
end

-- Notes each axis of the target arrow GearSwap reads from get_info, whose answers stay the game's. Returns the list.
local function watch_arrow(gs)
    local reads = {}
    local get_info = gs.game.get_info
    gs.game.get_info = function(game)
        local info = get_info(game)
        local arrow = info.target_arrow
        info.target_arrow = setmetatable({}, {__index = function(_, axis)
            reads[#reads + 1] = axis
            return arrow[axis]
        end})
        return info
    end
    return reads
end

local precast_gear = {head = "Bunzi's Hat"}
local midcast_gear = {head = 'Kaykaus Mitra +1'}

describe('an action aimed at a target typed as', function()
    it('a name goes at that player, who is told to the hooks as a member of the party', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Alice'})
        gs:type('/ma "Cure III" Alice')
        assert.same({
            {equip = precast_gear},
            {action = 'Cure III', target = 'Alice'},
            {equip = midcast_gear},
        }, gs:traffic())
        local got = calls(gs)
        assert.same({'pretarget', 'precast', 'midcast'}, events(got))
        assert.same({'Alice', true, 'PLAYER', 'Alice'}, {got[1].target, got[1].party, got[1].target_type, got[1].raw})
    end)

    it('a name is a player who is no party member, with no flag for the party', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Bob', in_party = false})
        gs:type('/ma "Cure III" Bob')
        local got = calls(gs)
        assert.same({'Bob', false}, {got[1].target, got[1].party or false})
        assert.same({{action = 'Cure III', target = 'Bob'}}, {gs:traffic()[2]})
    end)

    it('a name that is nobody\'s is left to the game', function()
        local gs = boot()
        assert.equal('/ma "Cure III" Nobody', gs:type('/ma "Cure III" Nobody'))
        assert.same({}, calls(gs))
        assert.same({'/ma "Cure III" Nobody'}, gs.game.typed)
    end)

    it('a monster\'s name is left to the game, which wants <t> for it', function()
        local gs = boot()
        gs.game:add_mob({name = 'Goblin', spawn_type = 16})
        assert.equal('/ma "Dia II" Goblin', gs:type('/ma "Dia II" Goblin'))
        assert.same({}, calls(gs))
        assert.same({'/ma "Dia II" Goblin'}, gs.game.typed)
    end)

    it('the name of a Trust in the party goes at the Trust', function()
        local gs = boot()
        gs.game:add_mob({name = 'Kupipi', spawn_type = 14})
        gs:type('/ma "Cure III" Kupipi')
        assert.same({'pretarget', 'precast', 'midcast'}, events(calls(gs)))
        assert.same({action = 'Cure III', target = 'Kupipi'}, gs:traffic()[2])
    end)

    it('its id skips pretarget and goes at that player', function()
        local gs = boot()
        gs:type('/ma "Cure III" 1048577')
        assert.same({'precast', 'midcast'}, events(calls(gs)))
        assert.same({
            {equip = precast_gear},
            {action = 'Cure III', target = 'Testy'},
            {equip = midcast_gear},
        }, gs:traffic())
    end)

    it('the id of a monster goes at the monster', function()
        local gs = boot()
        gs:type('/ma "Dia II" ' .. gs.game.monster.id)
        assert.same({{equip = precast_gear}, {action = 'Dia II', target = 'Apex Toad'}, {equip = midcast_gear}}, gs:traffic())
    end)

    it('its id has GearSwap read the target arrow, and goes at the target with no offset in its packet: precast '
        .. 'builds the packet again without it', function()
        local gs = boot()
        gs.game:set_info({target_arrow = {x = 5, y = 2, z = 1}})
        local reads = watch_arrow(gs)
        local mark = #gs.game.sent
        gs:type('/ma "Dia II" ' .. gs.game.monster.id)
        assert.is_true(#reads > 0)
        assert.same({action = 'Dia II', target = 'Apex Toad'}, gs:traffic()[2])
        assert.same({0, 0, 0}, {sent_since(gs, mark, 0x1A)[1].data:unpack('fff', 17)})
    end)

    it('<t> has GearSwap leave the target arrow alone for a spell with no Ge in its name', function()
        local gs = boot()
        local reads = watch_arrow(gs)
        gs:type('/ma "Dia II" <t>')
        assert.same({}, reads)
        assert.same({action = 'Dia II', target = 'Apex Toad'}, gs:traffic()[2])
    end)

    it('an id nobody has is left to the game', function()
        local gs = boot()
        gs:type('/ma "Cure III" 99999999')
        assert.same({}, calls(gs))
    end)

    it('<pet> goes at the pet', function()
        local gs = boot()
        gs.game:place_pet({name = 'Carbuncle'})
        gs:type('/ma "Cure III" <pet>')
        assert.same({'Carbuncle'}, {gs:traffic()[2].target})
    end)

    it('<p1> goes at the first other member of the party', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Alice'})
        gs:type('/ma "Cure III" <p1>')
        assert.equal('Alice', gs:traffic()[2].target)
    end)

    it('<t> with nothing targeted is left to the game, after pretarget: no one is there to aim at', function()
        local gs = boot()
        gs.game:target(nil)
        assert.equal('/ma "Dia II"  <t>', gs:type('/ma "Dia II" <t>'))
        assert.same({}, gs:traffic())
        assert.same({'pretarget'}, events(calls(gs)))
    end)
end)

describe('a line with nothing in it', function()
    it('is left to the game, which has nothing to do with it', function()
        local gs = boot()
        assert.equal('', gs:type(''))
        assert.equal('<wait 3>', gs:type('<wait 3>'))
        assert.same({}, calls(gs))
        assert.same({'<wait 3>'}, gs.game.typed)
    end)
end)

describe('an action aimed at the subtarget', function()
    it('goes to the game as typed, after pretarget, for the game to ask the player where', function()
        local gs = boot()
        assert.equal('/ma "Cure III"  <st>', gs:type('/ma "Cure III" <st>'))
        assert.same({'pretarget'}, events(calls(gs)))
        assert.same({}, gs:traffic())
        assert.same({'/ma "Cure III"  <st>'}, gs.game.typed)
    end)

    it('lets the line the game sends back through untouched, the once', function()
        local gs = boot()
        gs:type('/ma "Cure III" <st>')
        calls(gs)
        gs:type('/ma "Cure III" <me>')
        assert.same({}, calls(gs))
        gs:type('/ma "Cure III" <me>')
        assert.same({'pretarget', 'precast', 'midcast'}, events(calls(gs)))
    end)

    it('is the same for every kind of subtarget', function()
        for _, target in ipairs({'<stpc>', '<stal>', '<stnpc>', '<stpt>'}) do
            local gs = boot()
            gs:type('/ma "Cure III" ' .. target)
            assert.same({'pretarget'}, events(calls(gs)), target)
            assert.same({}, gs:traffic(), target)
        end
    end)
end)

describe('change_target', function()
    it('in pretarget turns the action to the target it names', function()
        local gs = boot()
        gs.user.knobs.change_target = '<me>'
        gs:type('/ma "Cure III" <t>')
        assert.same({{equip = precast_gear}, {action = 'Cure III', target = 'Testy'}, {equip = midcast_gear}}, gs:traffic())
    end)

    it('in pretarget hands precast and midcast the new target', function()
        local gs = boot()
        gs.user.knobs.change_target = '<me>'
        gs:type('/ma "Cure III" <t>')
        local got = calls(gs)
        assert.same({'Apex Toad', 'Testy', 'Testy'}, {got[1].target, got[2].target, got[3].target})
        assert.same({'<t>', '<me>', '<me>'}, {got[1].raw, got[2].raw, got[3].raw})
    end)

    it('can name a player', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Alice'})
        gs.user.knobs.change_target = 'Alice'
        gs:type('/ma "Cure III" <t>')
        assert.equal('Alice', gs:traffic()[2].target)
    end)

    it('to a name nobody has is an error', function()
        local gs = boot()
        gs.user.knobs.change_target = 'Nobody'
        assert.matches('change_target%(%) was passed an invalid value %(Nobody%)', error_of(gs.type, gs, '/ma "Cure III" <t>'))
    end)

    it('to something that is no name is an error', function()
        local gs = boot()
        gs.user.knobs.change_target = 42
        assert.matches('change_target%(%) was passed an invalid value %(42%)', error_of(gs.type, gs, '/ma "Cure III" <t>'))
    end)

    it('outside pretarget is an error', function()
        local gs = boot()
        assert.matches('change_target%(%) is only valid in the pretarget function', error_of(gs.user.change_target, '<me>'))
    end)
end)

describe('cast_delay', function()
    it('in pretarget holds the action back the seconds it names, then runs precast and midcast', function()
        local gs = boot()
        gs.user.knobs.pretarget_delay = 2
        assert.is_true(gs:type('/ma "Cure III" <me>'))
        assert.same({'pretarget'}, events(calls(gs)))
        assert.same({}, gs:traffic())
        gs:advance(1.9)
        assert.same({}, gs:traffic())
        gs:advance(0.2)
        assert.same({'precast', 'midcast'}, events(calls(gs)))
        assert.same({{equip = precast_gear}, {action = 'Cure III', target = 'Testy'}, {equip = midcast_gear}}, gs:traffic())
    end)

    it('in precast puts on the precast gear at once and sends the action after the seconds it names', function()
        local gs = boot()
        gs.user.knobs.precast_delay = 1.5
        gs:type('/ma "Cure III" <me>')
        assert.same({{equip = precast_gear}}, gs:traffic())
        assert.same({'pretarget', 'precast'}, events(calls(gs)))
        gs:advance(1.4)
        assert.same({}, gs:traffic())
        gs:advance(0.2)
        assert.same({{action = 'Cure III', target = 'Testy'}, {equip = midcast_gear}}, gs:traffic())
        assert.same({'midcast'}, events(calls(gs)))
    end)

    it('in pretarget and in precast holds the action back both times', function()
        local gs = boot()
        gs.user.knobs.pretarget_delay = 1
        gs.user.knobs.precast_delay = 2
        gs:type('/ma "Cure III" <me>')
        assert.same({}, gs:traffic())
        gs:advance(1.1)
        assert.same({{equip = precast_gear}}, gs:traffic())
        gs:advance(1.8)
        assert.same({}, gs:traffic())
        gs:advance(0.3)
        assert.same({{action = 'Cure III', target = 'Testy'}, {equip = midcast_gear}}, gs:traffic())
    end)

    it('of 0 holds nothing back', function()
        local gs = boot()
        gs.user.knobs.pretarget_delay = 0
        gs.user.knobs.precast_delay = 0
        gs:type('/ma "Cure III" <me>')
        assert.same({{equip = precast_gear}, {action = 'Cure III', target = 'Testy'}, {equip = midcast_gear}}, gs:traffic())
    end)

    it('that is not a number is an error', function()
        local gs = boot()
        gs.user.knobs.pretarget_delay = 'soon'
        assert.matches('cast_delay%(%) was passed an invalid value %(soon%)', error_of(gs.type, gs, '/ma "Cure III" <me>'))
    end)

    it('outside pretarget and precast is an error', function()
        local gs = boot()
        assert.matches('cast_delay%(%) is only valid in the precast and pretarget functions', error_of(gs.user.cast_delay, 1))
    end)

    pending('drops the action it holds back when the zone changes before it goes: the zone-in packet makes '
        .. 'command_registry anew, and pretarget_delayed_cast and send_action in flow.lua then index the entry that is '
        .. 'gone and raise an error')
end)

describe('cancel_spell', function()
    it('in pretarget stops the action before precast, and the line never reaches the game', function()
        local gs = boot()
        gs.user.knobs.cancel_in_pretarget = true
        assert.is_true(gs:type('/ma "Cure III" <me>'))
        assert.same({'pretarget'}, events(calls(gs)))
        assert.same({}, gs:traffic())
        assert.same({}, gs.game.typed)
    end)

    it('in filtered_action stops a line the game would have been given', function()
        local gs = boot({spells = {'Cure IV'}})
        gs.user.knobs.cancel_filtered = true
        assert.is_true(gs:type('/ma "Cure III" <me>'))
        assert.same({}, gs.game.typed)
    end)

    it('in precast stops the action after the precast gear is on', function()
        local gs = boot()
        gs.user.knobs.cancel_with = true
        assert.is_true(gs:type('/ma "Cure III" <me>'))
        assert.same({{equip = precast_gear}}, gs:traffic())
        assert.same({'pretarget', 'precast'}, events(calls(gs)))
    end)

    it('called with false takes back a cancel, and the action goes on', function()
        local gs = boot()
        gs.user.knobs.cancel_in_precast = true
        gs.user.knobs.cancel_with = false
        gs:type('/ma "Cure III" <me>')
        assert.same({{equip = precast_gear}, {action = 'Cure III', target = 'Testy'}, {equip = midcast_gear}}, gs:traffic())
    end)

    it('with something that is not a boolean is an error', function()
        local gs = boot()
        gs.user.knobs.cancel_with = 'yes'
        assert.matches('cancel_spell%(%) was passed an invalid value %(yes%)', error_of(gs.type, gs, '/ma "Cure III" <me>'))
    end)

    it('outside precast, pretarget and filtered_action is an error', function()
        local gs = boot()
        assert.matches('cancel_spell%(%) is only valid in the precast, pretarget, or filtered_action functions',
            error_of(gs.user.cancel_spell))
    end)
end)

describe('move_spell_target', function()
    it('in precast puts the offset in the action packet, as x, z, y', function()
        local gs = boot()
        gs.user.knobs.move_target = {x = 1, y = 2, z = 3}
        local mark = #gs.game.sent
        gs:type('/ma "Cure III" <me>')
        local packet = sent_since(gs, mark, 0x1A)[1]
        assert.same({1, 3, 2}, {packet.data:unpack('fff', 17)})
    end)

    it('is not in the packet when it is not called: the offset is none', function()
        local gs = boot()
        local mark = #gs.game.sent
        gs:type('/ma "Cure III" <me>')
        assert.same({0, 0, 0}, {sent_since(gs, mark, 0x1A)[1].data:unpack('fff', 17)})
    end)

    it('takes capital letters for the axes', function()
        local gs = boot()
        gs.user.knobs.move_target = {X = 4, Y = 5, Z = 6}
        local mark = #gs.game.sent
        gs:type('/ma "Cure III" <me>')
        assert.same({4, 6, 5}, {sent_since(gs, mark, 0x1A)[1].data:unpack('fff', 17)})
    end)

    it('is the offset of the target arrow from the target, for a geomancy spell, when the player has not moved it', function()
        local gs = boot()
        gs.game.player.main_job_id = 21
        gs.game:set_info({target_arrow = {x = 5, y = 2, z = 1}})
        local mark = #gs.game.sent
        gs:type('/ma "Geo-Frailty" <t>')
        assert.same({2, 1, 2}, {sent_since(gs, mark, 0x1A)[1].data:unpack('fff', 17)})
    end)

    it('is none for a geomancy spell when the target arrow is where it began', function()
        local gs = boot()
        gs.game.player.main_job_id = 21
        local mark = #gs.game.sent
        gs:type('/ma "Geo-Frailty" <t>')
        assert.same({0, 0, 0}, {sent_since(gs, mark, 0x1A)[1].data:unpack('fff', 17)})
    end)

    it('is the player\'s own offset, for a geomancy spell, when precast moves it', function()
        local gs = boot()
        gs.game.player.main_job_id = 21
        gs.game:set_info({target_arrow = {x = 5, y = 2, z = 1}})
        gs.user.knobs.move_target = {x = 9, y = 8, z = 7}
        local mark = #gs.game.sent
        gs:type('/ma "Geo-Frailty" <t>')
        assert.same({9, 7, 8}, {sent_since(gs, mark, 0x1A)[1].data:unpack('fff', 17)})
    end)

    pending('is none for an action that is no geomancy spell, such as Tachi: Gekko, when the target arrow is away from '
        .. 'the target: equip_sets in flow.lua looks for \'Geo-\' in the name as a Lua pattern, in which - repeats '
        .. 'the o it follows, so any name with Ge in it takes the offset')

    it('with something that is not a table of numbers is an error', function()
        local gs = boot()
        gs.user.knobs.move_target = {x = 1, y = 'two', z = 3}
        assert.matches('move_spell_target%(%) was passed an invalid value', error_of(gs.type, gs, '/ma "Cure III" <me>'))
    end)

    it('outside precast is an error', function()
        local gs = boot()
        assert.matches('move_spell_target%(%) is only valid in the precast function',
            error_of(gs.user.move_spell_target, {x = 1, y = 1, z = 1}))
    end)
end)

describe('target_type_check', function()
    local function checked(gs, line)
        gs.user.knobs.check_target = true
        gs:type(line)
        return gs.user.target_checked
    end

    it('says a spell that can be cast on the caster can be cast on the player', function()
        local gs = boot()
        assert.is_true(checked(gs, '/ma "Cure III" <me>'))
    end)

    it('says a spell that can be cast on the party can be cast on a member of it', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Alice'})
        assert.is_true(checked(gs, '/ma "Curaga" Alice'))
    end)

    it('says a spell that can be cast on the party can\'t be cast on someone who is in the alliance only', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Carol', slot = 'a10'})
        assert.is_false(checked(gs, '/ma "Curaga" Carol'))
    end)

    it('says a spell that can be cast on an ally can be cast on someone in the alliance', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Carol', slot = 'a10'})
        assert.is_true(checked(gs, '/ma "Cure III" Carol'))
    end)

    it('says a spell that can be cast on the fallen can be cast on a player at no health', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Alice', hpp = 0})
        assert.is_true(checked(gs, '/ma "Raise" Alice'))
    end)

    it('says a spell that can\'t be cast on the fallen can\'t be cast on a player at no health', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Alice', hpp = 0})
        assert.is_false(checked(gs, '/ma "Curaga" Alice'))
    end)

    it('says a spell that can be cast on an NPC can be cast on one', function()
        local gs = boot()
        local npc = gs.game:add_mob({name = 'Moogle', id = 0x01000800 + 5})
        gs.game:target(npc.index)
        assert.is_true(checked(gs, '/ma "Cure III" <t>'))
    end)

    pending('says a spell that can be cast on an enemy can be cast on a monster: it looks in the spell\'s targets for '
        .. 'Monster, where the resources say Enemy')
end)

describe('an action the player can\'t use', function()
    it('because the character doesn\'t know the spell goes to the game, after filtered_action', function()
        local gs = boot({spells = {'Cure IV'}})
        gs:type('/ma "Cure III" <me>')
        assert.same({'filtered_action'}, events(calls(gs)))
        assert.same({'/ma "Cure III" <me>'}, gs.game.typed)
        assert.same({}, gs:traffic())
    end)

    it('because the job is too low for the spell goes to the game, after filtered_action', function()
        local gs = boot({main_job_level = 10, sub_job_level = 5})
        gs:type('/ma "Cure III" <me>')
        assert.same({'filtered_action'}, events(calls(gs)))
        assert.same({}, gs:traffic())
    end)

    it('is cast when the main job is too low for it but the sub job is high enough', function()
        local gs = boot({main_job_level = 10, sub_job_level = 49})
        gs:type('/ma "Cure III" <me>')
        assert.same({'pretarget', 'precast', 'midcast'}, events(calls(gs)))
    end)

    it('because the character has no such weapon skill goes to the game, after filtered_action', function()
        local gs = boot({abilities = {'Divine Seal'}})
        gs:type('/ws "Black Halo" <t>')
        assert.same({'filtered_action'}, events(calls(gs)))
        assert.same({}, gs:traffic())
    end)

    it('because the character has no such job ability goes to the game, after filtered_action', function()
        local gs = boot({abilities = {'Black Halo'}})
        gs:type('/ja "Divine Seal" <me>')
        assert.same({'filtered_action'}, events(calls(gs)))
        assert.same({}, gs:traffic())
    end)

    it('in the Mog House goes to the game, after filtered_action', function()
        local gs = boot()
        gs:send_zone_in({['_unknown7'] = ('\0'):rep(20) .. '\1'})
        calls(gs)
        gs:traffic()
        gs:type('/ma "Cure III" <me>')
        assert.same({'filtered_action'}, events(calls(gs)))
        assert.same({'/ma "Cure III" <me>'}, gs.game.typed)
        assert.same({}, gs:traffic())
    end)

    it('is told to filtered_action as the spell it is', function()
        local gs = boot({spells = {'Cure IV'}})
        gs:type('/ma "Cure III" <me>')
        local got = calls(gs)[1]
        assert.same({'Cure III', 'Testy', 'Magic'}, {got.name, got.target, got.action_type})
    end)
end)

describe('a ranged attack', function()
    it('typed /ra goes at the target after the precast gear, and is a ranged attack to the hooks', function()
        local gs = boot()
        local mark = #gs.game.sent
        gs:type('/ra <t>')
        assert.same({{equip = precast_gear}, {action = 'category 16', target = 'Apex Toad'}, {equip = midcast_gear}}, gs:traffic())
        local got = calls(gs)
        assert.same({'pretarget', 'precast', 'midcast'}, events(got))
        assert.same({'Ranged', 'Ranged Attack', '/range', 'Apex Toad'}, {got[2].name, got[2].action_type, got[2].prefix, got[2].target})
        assert.equal(16, sent_since(gs, mark, 0x1A)[1].data:byte(11))
    end)

    it('gets the aftercast gear once the server says the shot is done', function()
        local gs = boot()
        gs:type('/ra <t>')
        calls(gs)
        gs:finish_action()
        assert.same({'aftercast'}, events(calls(gs)))
        assert.equal('Nyame Helm', gs:worn().head)
    end)

    it('gets the aftercast gear, marked interrupted, when the shot is interrupted', function()
        local gs = boot()
        gs:type('/ra <t>')
        calls(gs)
        gs:interrupt_action()
        local got = calls(gs)
        assert.same({'aftercast', true}, {got[1].event, got[1].interrupted})
    end)

    it('is in midaction from the typed line until its aftercast', function()
        local gs = boot()
        gs:type('/ra <t>')
        assert.is_true((gs.user.midaction()))
        gs:finish_action()
        assert.is_false(gs.user.midaction())
    end)

    it('typed with other names for the command is the same: /shoot and /throw', function()
        for _, command in ipairs({'/shoot', '/throw', '/range', '/rangedattack'}) do
            local gs = boot()
            gs:type(command .. ' <t>')
            assert.same({'pretarget', 'precast', 'midcast'}, events(calls(gs)), command)
        end
    end)
end)

describe('an item typed in the chat', function()
    local function with_remedy()
        local items = testy.whm().items
        items[#items + 1] = {name = 'Remedy'}
        return boot({items = items})
    end

    local function item_slot(gs)
        return (gs.game:find_item('inventory', 'Remedy'))
    end

    local function ids_since(gs, mark)
        local ids = {}
        for i = mark + 1, #gs.game.sent do
            ids[#ids + 1] = gs.game.sent[i].id
        end
        return ids
    end

    it('sends the use item packet (0x037), not an action, between the precast gear and the midcast gear', function()
        local gs = with_remedy()
        local mark = #gs.game.sent
        gs:type('/item "Remedy" <me>')
        assert.same({0x050, 0x037, 0x050}, ids_since(gs, mark))
        local packet = sent_since(gs, mark, 0x37)[1]
        assert.equal(gs.game.player.id, packet.data:unpack('I', 5))
        assert.equal(item_slot(gs), packet.data:byte(15))
    end)

    it('is an item to the hooks, with the player as its target', function()
        local gs = with_remedy()
        gs:type('/item "Remedy" <me>')
        local got = calls(gs)
        assert.same({'pretarget', 'precast', 'midcast'}, events(got))
        assert.same({'Remedy', 'Item', 'Item', 'Testy'}, {got[2].name, got[2].type, got[2].action_type, got[2].target})
    end)

    it('that the character doesn\'t have goes nowhere, and no packet is sent', function()
        local gs = boot()
        local mark = #gs.game.sent
        assert.is_true(gs:type('/item "Remedy" <me>'))
        assert.same({'pretarget'}, events(calls(gs)))
        assert.same({}, sent_since(gs, mark, 0x37))
    end)

    it('is over for GearSwap once the server says it was used', function()
        local gs = with_remedy()
        gs:type('/item "Remedy" <me>')
        calls(gs)
        gs:run(function()
            gs.game:send_action_packet({category = 5, param = 4155, recast = 0, targets = {{id = gs.game.player.id,
                actions = {{message = 28, param = 0, reaction = 0, animation = 0, effect = 0, stagger = 0}}}}})
            gs.game:settle()
        end)
        local got = calls(gs)
        assert.same({'aftercast', 'Remedy'}, {got[1].event, got[1].name})
        assert.is_false(gs.user.midaction())
    end)

    describe('aimed at a target by its id', function()
        it('sends the use item packet (0x037) for the player, without calling pretarget', function()
            local gs = with_remedy()
            local mark = #gs.game.sent
            assert.is_true(gs:type('/item "Remedy" 1048577'))
            assert.same({'precast', 'midcast'}, events(calls(gs)))
            assert.is_not_nil(sent_since(gs, mark, 0x37)[1])
        end)

        it('sends the trade packet (0x036) for an NPC that is near', function()
            local gs = with_remedy()
            local npc = gs.game:add_mob({name = 'Moogle', spawn_type = 2, distance = 4 ^ 2})
            local mark = #gs.game.sent
            gs:type('/item "Remedy" ' .. npc.id)
            assert.equal(npc.id, sent_since(gs, mark, 0x36)[1].data:unpack('I', 5))
        end)

        it('tells the player an NPC is too far away, and goes nowhere', function()
            local gs = with_remedy()
            local npc = gs.game:add_mob({name = 'Moogle', spawn_type = 2, distance = 10 ^ 2})
            local mark = #gs.game.sent
            assert.is_true(gs:type('/item "Remedy" ' .. npc.id))
            assert.same({}, sent_since(gs, mark, 0x36))
            assert.matches('Target out of range', gs.game.chat_log[1].text)
        end)

        it('that the character doesn\'t have is left to the game', function()
            local gs = boot()
            assert.equal('/item "Remedy" 1048577', gs:type('/item "Remedy" 1048577'))
            assert.same({}, calls(gs))
        end)
    end)

    describe('given to an NPC', function()
        local function with_npc(yalms)
            local gs = with_remedy()
            local npc = gs.game:add_mob({name = 'Moogle', spawn_type = 2, distance = yalms ^ 2})
            gs.game:target(npc.index)
            return gs, npc
        end

        it('sends the trade packet (0x036)', function()
            local gs, npc = with_npc(4)
            local mark = #gs.game.sent
            gs:type('/item "Remedy" <t>')
            local packet = sent_since(gs, mark, 0x36)[1]
            assert.is_not_nil(packet)
            assert.equal(npc.id, packet.data:unpack('I', 5))
        end)

        it('is a trade to the hooks', function()
            local gs = with_npc(4)
            gs:type('/item "Remedy" <t>')
            assert.equal('Trade', calls(gs)[2].action_type)
        end)

        it('too far away is told to the player and goes nowhere', function()
            local gs = with_npc(10)
            local mark = #gs.game.sent
            assert.is_true(gs:type('/item "Remedy" <t>'))
            assert.same({}, sent_since(gs, mark, 0x36))
            assert.same({'pretarget'}, events(calls(gs)))
            assert.same({1}, {#gs.game.chat_log})
            assert.matches('Target out of range', gs.game.chat_log[1].text)
        end)

        it('that the character doesn\'t have goes nowhere, and no packet is sent', function()
            local gs = with_npc(4)
            local slot = item_slot(gs)
            gs.game.bags[0].items[slot] = nil
            gs.env.items.inventory[slot].id = 0
            local mark = #gs.game.sent
            gs:type('/item "Remedy" <t>')
            assert.same({}, sent_since(gs, mark, 0x36))
        end)
    end)
end)

describe('the server telling the player an action can\'t be done', function()
    local function say(gs, fields)
        gs:run(function()
            gs.game:send_action_message(fields)
            gs.game:settle()
        end)
    end

    it('with a message that says the player can\'t cast ends the action as interrupted', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        calls(gs)
        say(gs, {message_id = 17})
        local got = calls(gs)
        assert.same({'aftercast', 'Cure III', true, 'Interruption'}, {got[1].event, got[1].name, got[1].interrupted, got[1].action_type})
        assert.is_false(gs.user.midaction())
        assert.equal('Nyame Helm', gs:worn().head)
    end)

    it('with any other message leaves the action as it was', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        calls(gs)
        say(gs, {message_id = 1})
        assert.same({}, calls(gs))
        assert.is_true((gs.user.midaction()))
    end)

    it('to someone else is none of the player\'s action', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        calls(gs)
        say(gs, {message_id = 17, actor_id = 0x2000, target_id = 0x2000})
        assert.same({}, calls(gs))
    end)

    it('that the target was defeated ends the action on it', function()
        local gs = boot()
        gs:type('/ma "Dia II" <t>')
        calls(gs)
        say(gs, {message_id = 6, actor_id = gs.game.player.id, target_id = gs.game.monster.id})
        local got = calls(gs)
        assert.same({'aftercast', 'Dia II'}, {got[1].event, got[1].name})
        assert.is_false(gs.user.midaction())
    end)

    it('that another was defeated leaves the action as it was', function()
        local gs = boot()
        gs:type('/ma "Dia II" <t>')
        calls(gs)
        say(gs, {message_id = 6, actor_id = gs.game.player.id, target_id = 0x2000})
        assert.same({}, calls(gs))
        assert.is_true((gs.user.midaction()))
    end)

    it('while the user file is disabled is left alone', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        gs:console('gs disable')
        calls(gs)
        say(gs, {message_id = 17})
        assert.same({}, calls(gs))
    end)

    it('that the action was paralyzed ends it as interrupted', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        calls(gs)
        gs:run(function()
            gs.game:send_action_packet({category = 8, param = 0, recast = 0, targets = {{id = gs.game.player.id,
                actions = {{message = 84, param = 0, reaction = 0, animation = 0, effect = 0, stagger = 0}}}}})
            gs.game:settle()
        end)
        local got = calls(gs)
        assert.same({'aftercast', 'Cure III', true}, {got[1].event, got[1].name, got[1].interrupted})
    end)

    it('that the target is too far away ends the action as interrupted', function()
        local gs = boot()
        gs:type('/ma "Dia II" <t>')
        calls(gs)
        gs:run(function()
            gs.game:send_action_packet({category = 8, param = 0, recast = 0, targets = {{id = gs.game.monster.id,
                actions = {{message = 78, param = 0, reaction = 0, animation = 0, effect = 0, stagger = 0}}}}})
            gs.game:settle()
        end)
        local got = calls(gs)
        assert.same({'aftercast', 'Dia II', true}, {got[1].event, got[1].name, got[1].interrupted})
    end)
end)
