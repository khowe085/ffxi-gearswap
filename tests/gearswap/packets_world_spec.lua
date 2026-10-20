local harness = require('harness')
local plain = require('plain')

local function boot_corey()
    return harness.boot({
        character = 'Corey', main_job = 'WHM', sub_job = 'RDM', expect_file = 'Corey_WHM.lua',
        items = {{name = 'Nyame Helm'}, {name = 'Nyame Mail'}},
    })
end

describe('the zone-in packet', function()
    it('gives the player its id, index, name and jobs', function()
        local gs = plain.boot()
        gs:send_zone_in({['Player'] = 0x2222, ['Player Index'] = 0x300, ['Main Job'] = 3, ['Sub Job'] = 5})
        local player = gs.env.player
        assert.same({0x2222, 0x300, 'Testy', 3, 5}, {player.id, player.index, player.name, player.main_job_id, player.sub_job_id})
        assert.same({'WHM', 'RDM', 'WHM/RDM'}, {player.main_job, player.sub_job, player.job})
    end)

    it('gives the world its zone, by id and by name', function()
        local gs = plain.boot()
        gs:change_zone(230)
        local world_table = gs.env.world
        assert.same({230, "Southern San d'Oria", "Southern San d'Oria"}, {world_table.zone_id, world_table.zone, world_table.area})
    end)

    it('marks the player logged in', function()
        local gs = plain.boot()
        gs.env.world.logged_in = false
        gs:send_zone_in()
        assert.is_true(gs.env.world.logged_in)
    end)

    it('gives the player its maximum HP and MP', function()
        local gs = plain.boot()
        gs:send_zone_in({['Max HP'] = 1800, ['Max MP'] = 1200})
        local player = gs.env.player
        assert.same({1800, 1200, 1800, 1200}, {player.max_hp, player.max_mp, player.vitals.max_hp, player.vitals.max_mp})
    end)

    it('gives the player its stats, the base and what gear and buffs add', function()
        local gs = plain.boot()
        gs:send_zone_in({['STR'] = 50, ['STR Bonus'] = 5, ['MND'] = 90, ['MND Bonus'] = -3})
        local player = gs.env.player
        assert.same({50, 5, 55, 90, -3, 87}, {player.base_str, player.add_str, player.str, player.base_mnd, player.add_mnd, player.mnd})
    end)

    it('says the player is in a conquest region when the zone is in one', function()
        local gs = plain.boot()
        gs:change_zone(100)
        assert.same({region_id = 4, region_name = 'Ronfaure'}, gs.env.world.conquest)
    end)

    it('says the player is in no conquest region when the zone is in none', function()
        local gs = plain.boot()
        gs:change_zone(100)
        gs:change_zone(230)
        assert.is_false(gs.env.world.conquest)
    end)

    it('forgets an action in progress', function()
        local gs = plain.boot()
        gs:type('/ma "Cure III" <me>')
        assert.is_true((gs.user.midaction()))
        gs:send_zone_in()
        assert.is_false(gs.user.midaction())
    end)

    it('says the player is in the Mog House when its flag is set', function()
        local gs = plain.boot()
        gs:send_zone_in({['_unknown7'] = ('\0'):rep(20) .. '\1'})
        assert.is_true(gs.env.world.in_mog_house)
    end)

    it('says the player is out of the Mog House when the flag is clear', function()
        local gs = plain.boot()
        gs:send_zone_in({['_unknown7'] = ('\0'):rep(20) .. '\1'})
        gs:send_zone_in()
        assert.is_false(gs.env.world.in_mog_house)
    end)

    it('loads the file of the new job when the job changed', function()
        local gs = boot_corey()
        local old_user = gs.user
        gs:send_zone_in({['Main Job'] = 4})
        assert.equal('Corey_BLM.lua', gs.env.current_file)
        assert.equal('Corey_BLM.lua', gs.env.user_env.loaded)
        assert.same({'Corey_WHM.lua'}, old_user.unloaded)
    end)

    it('keeps the file when the job is the same', function()
        local gs = boot_corey()
        local user = gs.env.user_env
        gs:send_zone_in()
        assert.equal(user, gs.env.user_env)
        assert.same({}, user.unloaded)
    end)

    it('leaves the file as it is when the user file is disabled and the job changed', function()
        local gs = boot_corey()
        gs:console('gs disable')
        gs:send_zone_in({['Main Job'] = 4})
        assert.equal('Corey_WHM.lua', gs.env.current_file)
        assert.equal(4, gs.env.player.main_job_id)
    end)
end)

describe('the packets the game sent before GearSwap loaded', function()
    local function remember(gs, id, fields, at)
        local body = gs.game:packet_body(id, fields)
        local data = string.char(id % 256, 0x40, 1, 0) .. body
        gs.game.last_packets.incoming[id] = {data, at}
    end

    it('are read when GearSwap loads, the oldest first, so the newest says how things are', function()
        local gs = plain.boot()
        remember(gs, 0x00A, {['Player'] = 0x100001, ['Player Index'] = 0x400, ['Player Name'] = 'Testy', ['Main Job'] = 3,
            ['Sub Job'] = 5, ['Max HP'] = 1111, ['Zone'] = 230}, 5)
        remember(gs, 0x061, {['Maximum HP'] = 2222, ['Main Job'] = 3, ['Sub Job'] = 5}, 6)
        gs:console('lua i gearswap initialize_packet_parsing')
        assert.equal(2222, gs.env.player.vitals.max_hp)
        assert.equal(230, gs.env.world.zone_id)
    end)

    it('are read in the order they came, not the order of their ids', function()
        local gs = plain.boot()
        remember(gs, 0x00A, {['Player'] = 0x100001, ['Player Index'] = 0x400, ['Player Name'] = 'Testy', ['Main Job'] = 3,
            ['Sub Job'] = 5, ['Max HP'] = 1111}, 6)
        remember(gs, 0x061, {['Maximum HP'] = 2222, ['Main Job'] = 3, ['Sub Job'] = 5}, 5)
        gs:console('lua i gearswap initialize_packet_parsing')
        assert.equal(1111, gs.env.player.vitals.max_hp)
    end)

    it('are not read when the game has none of them', function()
        local gs = plain.boot()
        gs.game.last_packets.incoming = {}
        local before = gs.env.player.vitals.max_hp
        assert.has_no.errors(function()
            gs:console('lua i gearswap initialize_packet_parsing')
        end)
        assert.equal(before, gs.env.player.vitals.max_hp)
    end)
end)

describe('the job packet (0x01B)', function()
    local helm_slot_flag = 0x10

    it('holds back a piece for a slot that is locked, and puts it on when the slot unlocks', function()
        local gs = plain.boot()
        gs:send(0x01B, {['Encumbrance Flags'] = helm_slot_flag})
        gs:type('/ma "Cure III" <me>')
        assert.same({
            {equip = {left_ring = 'Kishar Ring'}},
            {action = 'Cure III', target = 'Testy'},
        }, gs:traffic())
        assert.equal('Nyame Helm', gs:worn().head)
        gs:send(0x01B, {['Encumbrance Flags'] = 0})
        assert.same({{equip = {head = 'Kaykaus Mitra +1'}}}, gs:traffic())
        assert.equal('Kaykaus Mitra +1', gs:worn().head)
    end)

    it('puts on nothing for a slot that stays locked', function()
        local gs = plain.boot()
        gs:send(0x01B, {['Encumbrance Flags'] = helm_slot_flag})
        gs:type('/ma "Cure III" <me>')
        gs:traffic()
        gs:send(0x01B, {['Encumbrance Flags'] = helm_slot_flag})
        assert.same({}, gs:traffic())
    end)

    it('puts on nothing when a slot unlocks that nothing was held back for', function()
        local gs = plain.boot()
        gs:send(0x01B, {['Encumbrance Flags'] = helm_slot_flag})
        gs:send(0x01B, {['Encumbrance Flags'] = 0})
        assert.same({}, gs:traffic())
    end)

    pending('gives the player each job\'s level: GearSwap reads the level of job n from byte n + 72, one byte before '
        .. 'where Windower\'s field definition puts it (0x49 for job 1, which is byte 74 for data:byte), so each job '
        .. 'gets the level of the job before it')
end)
