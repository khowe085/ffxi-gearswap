local harness = require('harness')
local lfs = require('lfs')
local plain = require('plain')
local testy = require('testy')

local function refresh(gs)
    gs:console('gs c refresh')
end

local function boot()
    local gs = plain.boot()
    refresh(gs)
    return gs
end

-- The user files GearSwap looks for by a job's name, in the order it tries them: for each folder of data it tries,
-- the names in this order.
describe('the user file GearSwap loads for a job', function()
    local made = {}

    local function data_folder()
        return harness.tree().addon .. 'data/'
    end

    -- Writes a user file that says where it is into a folder of data, making the folder if need be.
    local function install(folder, name)
        local path = data_folder() .. folder
        if folder ~= '' and not lfs.attributes(path) then
            assert(lfs.mkdir(path))
            made[#made + 1] = path
        end
        local file = path .. (folder ~= '' and '/' or '') .. name
        local handle = assert(io.open(file, 'wb'))
        handle:write(('loaded = %q\n'):format(folder .. '/' .. name))
        handle:close()
        made[#made + 1] = file
    end

    after_each(function()
        for i = #made, 1, -1 do
            os.remove(made[i])
            lfs.rmdir(made[i])
            made[i] = nil
        end
    end)

    local function loaded_for(character)
        local gs = harness.boot({character = character, main_job = 'WHM', sub_job = 'RDM'})
        return gs.env.user_env.loaded, gs.env.current_file
    end

    local names = {'Lookup_WHM.lua', 'Lookup-WHM.lua', 'Lookup_White Mage.lua', 'Lookup-White Mage.lua', 'Lookup.lua', 'WHM.lua',
        'White Mage.lua', 'default.lua'}

    it('tries each name in turn, the character and the job\'s short name first and default last', function()
        for first = 1, #names - 1 do
            install('Lookup', names[first])
            install('Lookup', names[first + 1])
        end
        for i, name in ipairs(names) do
            assert.equal('Lookup/' .. name, (loaded_for('Lookup')), 'the file the ' .. i .. 'th name should load')
            os.remove(data_folder() .. 'Lookup/' .. name)
            made[#made + 1] = nil
        end
    end)

    it('tells which file it loaded', function()
        install('Lookup', 'Lookup-WHM.lua')
        assert.equal('Lookup-WHM.lua', select(2, loaded_for('Lookup')))
    end)

    it('tries the character\'s own folder first, whatever the names it holds', function()
        install('Lookup', 'default.lua')
        install('common', 'Lookup_WHM.lua')
        install('', 'Lookup_WHM.lua')
        assert.equal('Lookup/default.lua', (loaded_for('Lookup')))
    end)

    it('then the common folder, before the data folder', function()
        install('common', 'default.lua')
        install('', 'Lookup_WHM.lua')
        assert.equal('common/default.lua', (loaded_for('Lookup')))
    end)

    it('then the data folder itself', function()
        install('', 'Lookup_WHM.lua')
        assert.equal('/Lookup_WHM.lua', (loaded_for('Lookup')))
    end)
end)

describe('refresh_player', function()
    it('gives the player its name, id, index and jobs', function()
        local gs = boot()
        local player = gs.user.player
        assert.same({'Testy', 0x100001, 0x400}, {player.name, player.id, player.index})
        assert.same({'WHM', 'RDM', 'White Mage', 'Red Mage', 'WHM/RDM'}, {player.main_job, player.sub_job, player.main_job_full,
            player.sub_job_full, player.job})
        assert.same({3, 5, 99, 49}, {player.main_job_id, player.sub_job_id, player.main_job_level, player.sub_job_level})
    end)

    it('gives the player its vitals, in the vitals table and out of it', function()
        local gs = boot()
        gs.game.player.vitals = {hp = 900, mp = 400, tp = 1500, hpp = 60, mpp = 40, max_hp = 1500, max_mp = 1000}
        refresh(gs)
        local player = gs.user.player
        assert.same({900, 400, 1500, 60, 40, 1500, 1000}, {player.hp, player.mp, player.tp, player.hpp, player.mpp,
            player.max_hp, player.max_mp})
        assert.same({900, 400, 1500}, {player.vitals.hp, player.vitals.mp, player.vitals.tp})
    end)

    it('gives the player its status by name, and by id', function()
        local gs = boot()
        assert.same({'Idle', 0}, {gs.user.player.status, gs.user.player.status_id})
        gs:engage()
        refresh(gs)
        assert.same({'Engaged', 1}, {gs.user.player.status, gs.user.player.status_id})
    end)

    it('gives the player its race by name, and by id, and its nation by name and id', function()
        local gs = boot()
        local player = gs.user.player
        assert.same({'Hume ♂', 1, "San d'Oria", 0}, {player.race, player.race_id, player.nation, player.nation_id})
    end)

    it('gives the player its name as the mob has it, and its place', function()
        local gs = boot()
        local player = gs.user.player
        assert.same({'Testy', 0, 0, 0}, {player.mob_name, player.x, player.y, player.z})
    end)

    it('gives the player the names of what it wears by slot, in any case, and empty for an empty slot', function()
        local gs = boot()
        local equipment = gs.user.player.equipment
        assert.same({'Nyame Helm', 'Nyame Helm', 'Daybreak', 'empty'}, {equipment.head, equipment.HEAD, equipment.main, equipment.range})
    end)

    it('gives the player the pieces it wears by the other names of a slot, once an action is on', function()
        local gs = plain.boot()
        gs:type('/ma "Cure III" <me>')
        local equipment = gs.user.player.equipment
        assert.same({'Etiolation Earring', 'Etiolation Earring', 'Loquac. Earring'}, {equipment.ear1, equipment.left_ear, equipment.ear2})
    end)

    it('has the pieces the player wears change when it puts others on', function()
        local gs = boot()
        gs:console('gs equip sets.precast.FastCast')
        refresh(gs)
        assert.equal("Bunzi's Hat", gs.user.player.equipment.head)
    end)

    it('gives the player the target as a table: name, id, type, health, distance and status', function()
        local gs = boot()
        local target = gs.user.player.target
        assert.same({'Apex Toad', gs.game.monster.id, 'MONSTER', 100, 3, 'Idle'}, {target.name, target.id, target.type, target.hpp,
            target.distance, target.status})
    end)

    it('gives the player the target by its race and id', function()
        local gs = boot()
        assert.same({'Precomposed NPC', 0}, {gs.user.player.target.race, gs.user.player.target.race_id})
    end)

    it('gives the player a target of type NONE with no name when nothing is targeted', function()
        local gs = boot()
        gs.game:target(nil)
        refresh(gs)
        assert.same({'NONE', nil}, {gs.user.player.target.type, gs.user.player.target.name})
    end)

    it('says the target is the player when it is', function()
        local gs = boot()
        gs.game:target(gs.game.player.index)
        refresh(gs)
        assert.same({'SELF', 'Testy'}, {gs.user.player.target.type, gs.user.player.target.name})
    end)

    it('says the target is a player when it is another player, and is of the party when it is', function()
        local gs = boot()
        local member = gs.game:add_party_member({name = 'Alice'})
        gs.game:target(member.index)
        refresh(gs)
        local target = gs.user.player.target
        assert.same({'PLAYER', true, true}, {target.type, target.ispartymember, target.isallymember})
    end)

    it('says the target is an NPC when its id is that of an NPC', function()
        local gs = boot()
        local npc = gs.game:add_mob({name = 'Moogle'})
        gs.game:target(npc.index)
        refresh(gs)
        assert.equal('NPC', gs.user.player.target.type)
    end)

    it('says the target is no ally when it is not in the party', function()
        local gs = boot()
        assert.is_false(gs.user.player.target.isallymember)
    end)

    it('gives the player the subtarget and the last one too', function()
        local gs = boot()
        local member = gs.game:add_party_member({name = 'Alice'})
        gs.game:subtarget(member.index)
        refresh(gs)
        assert.same({'Alice', 'NONE'}, {gs.user.player.subtarget.name, gs.user.player.last_subtarget.type})
    end)

    it('gives the player no subtarget of type NONE', function()
        local gs = boot()
        assert.equal('NONE', gs.user.player.subtarget.type)
    end)

    it('has no fellow, and says so', function()
        local gs = boot()
        assert.is_false(gs.user.fellow.isvalid)
    end)

    it('has no species when the player is not a Monipulator', function()
        local gs = boot()
        assert.is_nil(gs.user.player.species)
    end)

    it('is not done when the game has no player: the tables stay as they were', function()
        local gs = boot()
        gs.game.loading = 'player'
        assert.has_no.errors(function() refresh(gs) end)
        gs.game.loading = nil
        assert.equal('Testy', gs.user.player.name)
    end)
end)

describe('a puppetmaster\'s automaton', function()
    local function boot_puppetmaster()
        local gs = plain.boot()
        gs.game.player.main_job_id = 18
        gs.game:place_pet({name = 'Automaton'})
        gs.game:set_automaton({name = 'Faustus', hp = 800, mp = 300, max_hp = 1200, max_mp = 600, head = 'Potion',
            frame = 'Remedy', attachments = {'Defending Ring'}, available_attachments = {'Defending Ring', 'Loquac. Earring'}})
        refresh(gs)
        return gs
    end

    it('is the pet, under its own name and with its health', function()
        local gs = boot_puppetmaster()
        local pet = gs.user.pet
        assert.same({'Faustus', 800, 300, 1200, 600, 50}, {pet.name, pet.hp, pet.mp, pet.max_hp, pet.max_mp, pet.mpp})
    end)

    it('has its head and frame by name', function()
        local gs = boot_puppetmaster()
        assert.same({'Potion', 'Remedy'}, {gs.user.pet.head, gs.user.pet.frame})
    end)

    it('has the heads, frames and attachments the puppetmaster has, and the ones it wears', function()
        local gs = boot_puppetmaster()
        local pet = gs.user.pet
        assert.same({true, true, true, true}, {pet.available_heads.Potion, pet.available_frames.Remedy,
            pet.available_attachments['Defending Ring'], pet.available_attachments['Loquac. Earring']})
        assert.same({true, nil}, {pet.attachments['Defending Ring'], pet.attachments['Loquac. Earring']})
    end)

    it('has none of the mp percent when the automaton has no mp to have', function()
        local gs = boot_puppetmaster()
        gs.game.automaton.max_mp = 0
        refresh(gs)
        assert.equal(0, gs.user.pet.mpp)
    end)
end)

describe('the world', function()
    it('has the zone by name, as the zone and the area', function()
        local gs = boot()
        assert.same({"Escha - Zi'Tah", "Escha - Zi'Tah"}, {gs.user.world.zone, gs.user.world.area})
    end)

    it('has the day, and its element', function()
        local gs = boot()
        gs.game:set_info({day = 3})
        refresh(gs)
        assert.same({'Windsday', 'Wind'}, {gs.user.world.day, gs.user.world.day_element})
    end)

    it('has the moon, as a phase and a percentage', function()
        local gs = boot()
        gs.game:set_info({moon = 75, moon_phase = 6})
        refresh(gs)
        assert.same({75, 'Full Moon'}, {gs.user.world.moon_pct, gs.user.world.moon})
    end)

    it('has the weather, its element and its strength', function()
        local gs = boot()
        gs.game:set_info({weather = 7})
        refresh(gs)
        local world_table = gs.user.world
        assert.same({'Squalls', 'Water', 2, 7}, {world_table.weather, world_table.weather_element, world_table.weather_intensity,
            world_table.weather_id})
        assert.same({'Squalls', 'Water', 2, 7}, {world_table.real_weather, world_table.real_weather_element,
            world_table.real_weather_intensity, world_table.real_weather_id})
    end)

    it('has the weather a storm makes in place of the real weather, which it keeps under another name', function()
        local gs = boot()
        gs.game:set_info({weather = 7})
        gs.game.player.buffs = {178}
        refresh(gs)
        local world_table = gs.user.world
        assert.same({'Hot spells', 'Fire', 1, 4}, {world_table.weather, world_table.weather_element, world_table.weather_intensity,
            world_table.weather_id})
        assert.same({'Squalls', 7}, {world_table.real_weather, world_table.real_weather_id})
    end)

    it('has the weather each storm makes: one for each element, and the stronger one of the second spells', function()
        local expected = {[178] = 4, [179] = 12, [180] = 10, [181] = 8, [182] = 14, [183] = 6, [184] = 16, [185] = 18,
            [589] = 5, [590] = 13, [591] = 11, [592] = 9, [593] = 15, [594] = 7, [595] = 17, [596] = 19}
        local names = {[4] = 'Hot spells', [12] = 'Snow', [10] = 'Winds', [8] = 'Dust storms', [14] = 'Thunder', [6] = 'Rain',
            [16] = 'Auroras', [18] = 'Gloom', [5] = 'Heat waves', [13] = 'Blizzards', [11] = 'Gales', [9] = 'Sand storms',
            [15] = 'Thunderstorms', [7] = 'Squalls', [17] = 'Stellar glare', [19] = 'Darkness'}
        for buff, weather in pairs(expected) do
            local gs = boot()
            gs.game.player.buffs = {buff}
            refresh(gs)
            assert.same({weather, names[weather]}, {gs.user.world.weather_id, gs.user.world.weather}, 'buff ' .. buff)
        end
    end)

    it('has the rest of what the game says of itself', function()
        local gs = boot()
        assert.same({true, 'English'}, {gs.user.world.logged_in, gs.user.world.language})
    end)

    it('has no conquest when the player is in a zone that is in none', function()
        local gs = boot()
        assert.is_false(gs.user.world.conquest)
    end)
end)

describe('the party and the alliance', function()
    it('has the player as the first member of the party', function()
        local gs = boot()
        local party = gs.user.party
        assert.same({1, 'Testy'}, {party.count, party[1].name})
    end)

    it('has each member by name, with the health the game gives, and its mob', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Alice', hp = 800, mp = 300, tp = 1200, hpp = 55})
        refresh(gs)
        local alice = gs.user.party[2]
        assert.same({'Alice', 800, 300, 1200}, {alice.name, alice.hp, alice.mp, alice.tp})
        assert.same({'Alice', 'Hume ♂', 1}, {alice.mob.name, alice.mob.race, alice.mob.race_id})
    end)

    it('counts the members, in the party and in the alliance', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Alice'})
        gs.game:add_party_member({name = 'Bob'})
        refresh(gs)
        assert.same({3, 3, 0, 0}, {gs.user.party.count, gs.user.alliance.count, gs.user.alliance[2].count, gs.user.alliance[3].count})
    end)

    it('has the members of the other parties in the alliance', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Carol', slot = 'a10'})
        gs.game:add_party_member({name = 'Dave', slot = 'a21'})
        refresh(gs)
        local alliance = gs.user.alliance
        assert.same({'Carol', 'Dave', 3, 1, 1, 1}, {alliance[2][1].name, alliance[3][2].name, alliance.count, alliance[1].count,
            alliance[2].count, alliance[3].count})
    end)

    it('has the leader of the party, and of the alliance', function()
        local gs = boot()
        gs.game:add_party_member({name = 'Carol', slot = 'a10', leader = true, alliance_leader = true})
        refresh(gs)
        local alliance = gs.user.alliance
        assert.same({'Testy', 'Carol', 'Carol'},
            {alliance[1].leader.name, alliance[2].leader.name, alliance.leader.name})
    end)

    it('is the same table, kept up to date, for the user file that has it', function()
        local gs = boot()
        local party = gs.user.party
        gs.game:add_party_member({name = 'Alice'})
        refresh(gs)
        assert.equal(party, gs.user.alliance[1])
        assert.equal(2, party.count)
    end)

    it('forgets a member who has gone', function()
        local gs = boot()
        local member = gs.game:add_party_member({name = 'Alice'})
        refresh(gs)
        gs.game:remove_mob(member.index)
        refresh(gs)
        assert.same({1, nil}, {gs.user.party.count, gs.user.party[2]})
    end)

    it('gives the player\'s entry the buffs the player has', function()
        local gs = boot()
        gs:gain_buff('Haste')
        refresh(gs)
        assert.equal(1, gs.user.party[1].buffactive.haste)
    end)
end)

describe('reloading the user file', function()
    it('waits a second and tries again when the player has no job yet, as when the game has just started', function()
        local gs = boot()
        local old = gs.env.user_env
        gs.game.loading = 'job'
        gs:console('gs reload')
        assert.equal(old, gs.env.user_env)
        gs.game.loading = nil
        gs:advance(0.9)
        assert.equal(old, gs.env.user_env)
        gs:advance(0.2)
        assert.not_equal(old, gs.env.user_env)
        assert.equal('Testy_WHM.lua', gs.env.current_file)
    end)
end)

describe('refresh_globals', function()
    -- Notes what read gives, run among the user file's globals, each time the game raises zone change.
    local function watch(gs, read)
        local seen = {}
        setfenv(read, gs.user)
        gs.user.windower.register_event('zone change', function()
            seen[#seen + 1] = read()
        end)
        return seen
    end

    local function watch_hp(gs)
        return watch(gs, function() return player.hp end)
    end

    it('is done by an event the user file registered when the game raised it', function()
        local gs = boot()
        local seen = watch_hp(gs)
        gs:advance(1)
        gs.game.player.vitals.hp = 700
        gs.game:fire('zone change', 230, 100)
        assert.same({700}, seen)
    end)

    it('is not done by an event a twentieth of a second after the last', function()
        local gs = boot()
        local seen = watch(gs, function() return world.day end)
        gs:advance(1)
        gs.game:fire('zone change', 230, 100)
        gs.game:set_info({day = 1})
        gs:advance(0.04)
        gs.game:fire('zone change', 230, 100)
        gs:advance(0.02)
        gs.game:fire('zone change', 230, 100)
        assert.same({'Firesday', 'Firesday', 'Earthsday'}, seen)
    end)

    it('does the part that reads the player only when more than half a second has gone by', function()
        local gs = boot()
        local seen = watch_hp(gs)
        gs:advance(1)
        gs.game.player.vitals.hp = 700
        gs.game:fire('zone change', 230, 100)
        gs.game.player.vitals.hp = 650
        gs:advance(0.3)
        gs.game:fire('zone change', 230, 100)
        assert.same({700, 700}, seen)
        gs:advance(0.6)
        gs.game:fire('zone change', 230, 100)
        assert.same({700, 700, 650}, seen)
    end)

    it('is always done for GearSwap\'s own events, whatever has gone by', function()
        local gs = boot()
        gs.game.player.vitals.hp = 700
        gs:console('gs c refresh')
        gs.game.player.vitals.hp = 600
        gs:console('gs c refresh')
        assert.equal(600, gs.user.player.hp)
    end)
end)
