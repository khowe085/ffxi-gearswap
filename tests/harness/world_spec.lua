local plain = require('plain')
local testy = require('testy')
local world = require('world')

local function parse(gs, id)
    local data = gs.game.last_packets.incoming[id][1]
    return gs.env.packets.parse('incoming', data)
end

local function boot(items)
    local options = testy.whm()
    if items then
        options.items = items
        options.wearing = {}
    end
    return plain.boot(nil, options)
end

describe('the mobs the stand-in game adds', function()
    it('hold their distance squared, as the game does, and are at that many yalms on the x axis', function()
        local gs = boot()
        local mob = gs.game:add_mob({name = 'Moogle', distance = 4})
        local seen = gs.game.windower.ffxi.get_mob_by_index(mob.index)
        assert.same({16, 4, 'Moogle'}, {seen.distance, seen.x, seen.name})
    end)

    it('take the next index when they are given none, one game after another counting from 0x500', function()
        local gs = boot()
        assert.same({0x500, 0x501}, {gs.game:add_mob({}).index, gs.game:add_mob({}).index})
        assert.equal(0x500, boot().game:add_mob({}).index)
    end)

    it('are handed out as copies, which GearSwap may write into', function()
        local gs = boot()
        local mob = gs.game:add_mob({name = 'Moogle'})
        gs.game.windower.ffxi.get_mob_by_index(mob.index).name = 'Changed'
        assert.equal('Moogle', gs.game.windower.ffxi.get_mob_by_index(mob.index).name)
    end)

    it('are listed by name when asked for by name', function()
        local gs = boot()
        local moogle = gs.game:add_mob({name = 'Nomad Moogle'})
        gs.game:add_mob({name = 'Other'})
        assert.same({[moogle.index] = 'Nomad Moogle'}, gs.game.windower.ffxi.get_mob_list('Nomad Moogle'))
    end)

    it('are all listed when no name is given', function()
        local gs = boot()
        gs.game:add_mob({name = 'Other'})
        local count = 0
        for _ in pairs(gs.game.windower.ffxi.get_mob_list()) do
            count = count + 1
        end
        assert.equal(3, count)
    end)

    it('can be removed', function()
        local gs = boot()
        local mob = gs.game:add_mob({name = 'Moogle'})
        gs.game:remove_mob(mob.index)
        assert.is_nil(gs.game.windower.ffxi.get_mob_by_index(mob.index))
    end)

    it('are the target when the game is told to target them', function()
        local gs = boot()
        local mob = gs.game:add_mob({name = 'Moogle'})
        gs.game:target(mob.index)
        assert.equal('Moogle', gs.game.windower.ffxi.get_mob_by_target('<t>').name)
    end)
end)

describe('the pet the stand-in game gives', function()
    it('is the mob the player\'s pet_index names, in the player and in the player\'s mob', function()
        local gs = boot()
        local pet = gs.game:summon_pet({name = 'Carbuncle'})
        assert.equal(pet.index, gs.game.windower.ffxi.get_player().pet_index)
        assert.equal(pet.index, gs.game.windower.ffxi.get_mob_by_index(gs.game.player.index).pet_index)
    end)

    it('is the target of <pet>', function()
        local gs = boot()
        gs.game:summon_pet({name = 'Carbuncle'})
        assert.equal('Carbuncle', gs.game.windower.ffxi.get_mob_by_target('<pet>').name)
    end)

    it('is gone once it is dismissed', function()
        local gs = boot()
        local pet = gs.game:summon_pet({name = 'Carbuncle'})
        gs.game:dismiss_pet()
        assert.same({nil, nil}, {gs.game.windower.ffxi.get_mob_by_index(pet.index), gs.game.windower.ffxi.get_player().pet_index})
        assert.is_nil(gs.game.windower.ffxi.get_mob_by_target('<pet>'))
    end)

    it('has no TP of its own, as the game gives none for a mob', function()
        local gs = boot()
        local pet = gs.game:summon_pet({name = 'Carbuncle'})
        assert.is_nil(gs.game.windower.ffxi.get_mob_by_index(pet.index).tp)
    end)
end)

describe('the party the stand-in game gives', function()
    it('has the player as p0 and each member after, as p1 on, with the health the game gives', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Alice', hp = 800, mp = 300, tp = 1200})
        local party = gs.game.windower.ffxi.get_party()
        assert.same({'Testy', 'Alice', 800, 300, 1200, 2}, {party.p0.name, party.p1.name, party.p1.hp, party.p1.mp, party.p1.tp,
            party.party1_count})
    end)

    it('has a member of another party in the slot it is given, and not in the count of the first', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Carol', slot = 'a10'})
        local party = gs.game.windower.ffxi.get_party()
        assert.same({'Carol', 1}, {party.a10.name, party.party1_count})
    end)

    it('has members that are mobs the game knows, in the party and not NPCs', function()
        local gs = boot()
        local alice = gs.game:add_party_member({name = 'Alice'})
        local mob = gs.game.windower.ffxi.get_mob_by_index(alice.index)
        assert.same({false, true, true, 13}, {mob.is_npc, mob.in_party, mob.in_alliance, mob.spawn_type})
    end)

    it('are the target of <p1>, and <p0> is the player', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Alice'})
        assert.same({'Alice', 'Testy'}, {gs.game.windower.ffxi.get_mob_by_target('<p1>').name,
            gs.game.windower.ffxi.get_mob_by_target('<p0>').name})
    end)

    it('has no <p2> when there is only one other member', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Alice'})
        assert.is_nil(gs.game.windower.ffxi.get_mob_by_target('<p2>'))
    end)

    it('has the subtarget the game was told of as <st>', function()
        local gs = boot()
        local mob = gs.game:add_mob({name = 'Moogle'})
        gs.game:subtarget(mob.index)
        assert.equal('Moogle', gs.game.windower.ffxi.get_mob_by_target('<st>').name)
    end)
end)

describe('what the stand-in game reports of itself', function()
    it('has a target arrow with no offset', function()
        local gs = boot()
        assert.same({x = 0, y = 0, z = 0}, gs.game.windower.ffxi.get_info().target_arrow)
    end)

    it('takes the fields it is told to change, and keeps the others', function()
        local gs = boot()
        gs.game:set_info({mog_house = true, weather = 7})
        local info = gs.game.windower.ffxi.get_info()
        assert.same({true, 7, true}, {info.mog_house, info.weather, info.logged_in})
    end)

    it('counts the items in a bag by those that are there, not by the last slot', function()
        local gs = boot({{name = 'Nyame Helm', bag = 'safe'}, {name = 'Nyame Mail', bag = 'safe'}})
        gs.game.bags[1].items[1] = nil
        assert.equal(1, gs.game.windower.ffxi.get_bag_info('safe').count)
        assert.equal(1, gs.game.windower.ffxi.get_items('safe').count)
    end)

    it('says a bag it was closed is not enabled, and one that was not is', function()
        local gs = boot()
        gs.game.bags[1].disabled = true
        assert.same({false, true}, {gs.game.windower.ffxi.get_bag_info('safe').enabled, gs.game.windower.ffxi.get_bag_info('case').enabled})
    end)

    it('gives a species and an automaton as the data of the main job', function()
        local gs = boot()
        gs.game.species = 3
        assert.same({species = 3}, gs.game.windower.ffxi.get_mjob_data())
        gs.game.species = nil
        gs.game.automaton = {name = 'Faustus'}
        assert.same({}, gs.game.windower.ffxi.get_mjob_data())
        gs.game.player.main_job_id = 18
        assert.same({name = 'Faustus'}, gs.game.windower.ffxi.get_mjob_data())
    end)
end)

describe('items moving between bags in the stand-in game', function()
    local function move(gs, count, from, to, index)
        local data = string.char(0x29, 6, 0, 0) .. ('I'):pack(count) .. string.char(from, to, index, 0x52)
        gs.game.windower.packets.inject_outgoing(0x29, data)
        gs:advance(0)
    end

    local function game_with(items)
        return boot(items)
    end

    it('puts an item from a bag in the inventory, in the inventory\'s first empty slot', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}, {name = 'Nyame Mail'}})
        move(gs, 1, 7, 0, 1)
        assert.same({}, gs.game:bag_names('case'))
        assert.same({'Nyame Helm', 'Nyame Mail'}, gs.game:bag_names('inventory'))
        assert.equal('Nyame Helm', gs.game.res.items[gs.game.bags[0].items[2].id].en)
    end)

    it('puts an item from the inventory in another bag', function()
        local gs = game_with({{name = 'Nyame Helm'}})
        move(gs, 1, 0, 8, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('wardrobe'))
    end)

    it('takes nothing that is worn', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        gs.game.bags[7].items[1].status = 5
        move(gs, 1, 7, 0, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
    end)

    it('takes nothing from a slot with nothing in it', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        move(gs, 1, 7, 0, 2)
        assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
    end)

    it('takes nothing between two bags that are neither the inventory', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        move(gs, 1, 7, 6, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
    end)

    it('takes nothing into a bag that is full', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}, {name = 'Nyame Mail'}})
        gs.game.bags[0].max = 1
        move(gs, 1, 7, 0, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
    end)

    it('takes nothing from or into a bag that is closed', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        gs.game.bags[7].disabled = true
        move(gs, 1, 7, 0, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
    end)

    it('takes nothing when it is told to refuse', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        gs.game.refuse_moves = true
        move(gs, 1, 7, 0, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
    end)

    it('takes nothing from a Mog House bag away from the Mog House and a moogle', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'safe'}})
        move(gs, 1, 1, 0, 1)
        assert.same({'Nyame Helm'}, gs.game:bag_names('safe'))
    end)

    it('takes from a Mog House bag in the Mog House', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'safe'}})
        gs.game:set_info({mog_house = true})
        move(gs, 1, 1, 0, 1)
        assert.same({}, gs.game:bag_names('safe'))
    end)

    it('takes from a Mog House bag once a moogle has been talked to, but not from the storage', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'safe'}, {name = 'Nyame Mail', bag = 'storage'}})
        local moogle = gs.game:add_mob({name = 'Nomad Moogle', distance = 2})
        local talk = string.char(0x1A, 8, 0, 0) .. ('I'):pack(moogle.id) .. ('H'):pack(moogle.index) .. ('H'):pack(0) .. ('H'):pack(0)
        gs.game.windower.packets.inject_outgoing(0x1A, talk)
        gs:advance(0)
        move(gs, 1, 1, 0, 1)
        move(gs, 1, 2, 0, 1)
        assert.same({}, gs.game:bag_names('safe'))
        assert.same({'Nyame Mail'}, gs.game:bag_names('storage'))
    end)

    it('tells the client with the packets Windower defines: a count of 0 for the old slot, the item for the new', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        move(gs, 1, 7, 0, 1)
        local old = parse(gs, 0x01E)
        local new = parse(gs, 0x020)
        assert.same({0, 7, 1}, {old['Count'], old['Bag'], old['Index']})
        assert.same({1, 23761, 0, 1}, {new['Count'], new['Item'], new['Bag'], new['Index']})
    end)

    it('adds an item to the first empty slot of a bag, and finds it again by name', function()
        local gs = game_with({{name = 'Nyame Helm', bag = 'case'}})
        assert.equal(2, gs.game:add_item('case', {name = 'Nyame Mail'}))
        assert.same({2, 'Nyame Mail'}, {gs.game:find_item('case', 'Nyame Mail'), gs.game:bag_names('case')[2]})
    end)
end)

describe('the packets the server sends in the stand-in game', function()
    it('are built from Windower\'s field definitions, by the labels of their fields', function()
        local gs = boot()
        world.send(gs, 0x00A, {['Zone'] = 230, ['Player Name'] = 'Corey', ['Max HP'] = 1800})
        local packet = parse(gs, 0x00A)
        assert.same({230, 'Corey', 1800}, {packet['Zone'], packet['Player Name'], packet['Max HP']})
    end)

    it('are framed with the id and a sequence that goes up with each', function()
        local gs = boot()
        world.send(gs, 0x00B, {})
        local first = parse(gs, 0x00B)._sequence
        world.send(gs, 0x00B, {})
        assert.equal(first + 1, parse(gs, 0x00B)._sequence)
    end)

    it('zone in names the character the game has, by default', function()
        local gs = boot()
        world.zone_in(gs)
        local packet = parse(gs, 0x00A)
        assert.same({'Testy', 3, 5, 288}, {packet['Player Name'], packet['Main Job'], packet['Sub Job'], packet['Zone']})
    end)

    it('take a number for a field of bytes, as Windower\'s pack does, so a label two fields share can be built', function()
        local gs = boot()
        assert.equal('12', ('A4'):pack(12):sub(1, 2))
        assert.equal(4, #('A4'):pack(12))
        assert.has_no.errors(function()
            world.send(gs, 0x00A, {['_unknown12'] = 7})
        end)
    end)

    it('a buff packet has each buff in its slot and when it wears off, as the packet gives it', function()
        local gs = boot()
        world.send_buffs(gs, {{name = 'Haste', expires = 5000}, {name = 'Protect', expires = 6000}})
        local data = gs.game.last_packets.incoming[0x063][1]
        assert.same({9, 33, 40, 255}, {data:unpack('H', 5), data:unpack('H', 9), data:unpack('H', 11), data:unpack('H', 13)})
        assert.same({5000 * 60, 6000 * 60}, {data:unpack('I', 0x49), data:unpack('I', 0x4D)})
        assert.same({33, 40}, {gs.game.player.buffs[1], gs.game.player.buffs[2]})
    end)

    it('a party buff packet has the id and index of each member, and their buffs', function()
        local gs = boot()
        local alice = gs.game:add_party_member({name = 'Alice'})
        world.send_party_buffs(gs, {{id = alice.id, index = alice.index, buffs = {33, 419}}})
        local data = gs.game.last_packets.incoming[0x076][1]
        assert.same({alice.id, alice.index, 33}, {data:unpack('I', 5), data:unpack('H', 9), data:byte(0x15)})
        assert.same({419 % 256, math.floor(419 / 256)}, {data:byte(0x16), math.floor(data:byte(0x0D) / 4) % 4})
    end)
end)
