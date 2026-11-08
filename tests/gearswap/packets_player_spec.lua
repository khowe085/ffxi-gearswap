local plain = require('plain')

local refresh = plain.refresh

describe('the player update packet (0x037)', function()
    it('gives the player its status id', function()
        local gs = plain.boot()
        gs:send(0x037, {['Status'] = 33})
        assert.equal(33, gs.env.player.status_id)
    end)

    describe('with an indi spell', function()
        local fire_indi = 64
        local function indi(element, size, enemy)
            return 64 + element + (enemy and 8 or 0) + 16 * (size - 1)
        end

        it('tells the user file an indi spell came up, with its element, target and size', function()
            local gs = plain.boot('Testy_Events.lua')
            gs:send(0x037, {['Indi Buff'] = indi(0, 1)})
            assert.same({{event = 'indi_change', element = 'Fire', target = 'Ally', size = 1, gain = true}}, plain.events(gs))
        end)

        it('knows an indi spell aimed at enemies, of the largest size', function()
            local gs = plain.boot('Testy_Events.lua')
            gs:send(0x037, {['Indi Buff'] = indi(7, 4, true)})
            assert.same({{event = 'indi_change', element = 'Dark', target = 'Enemy', size = 4, gain = true}}, plain.events(gs))
        end)

        it('says nothing when the same indi spell is still up', function()
            local gs = plain.boot('Testy_Events.lua')
            gs:send(0x037, {['Indi Buff'] = fire_indi})
            plain.events(gs)
            gs:send(0x037, {['Indi Buff'] = fire_indi})
            assert.same({}, plain.events(gs))
        end)

        it('says the old spell is gone and the new one is up when the indi spell changed', function()
            local gs = plain.boot('Testy_Events.lua')
            gs:send(0x037, {['Indi Buff'] = indi(0, 1)})
            plain.events(gs)
            gs:send(0x037, {['Indi Buff'] = indi(1, 2)})
            assert.same({
                {event = 'indi_change', element = 'Fire', target = 'Ally', size = 1, gain = false},
                {event = 'indi_change', element = 'Ice', target = 'Ally', size = 2, gain = true},
            }, plain.events(gs))
        end)

        it('says the indi spell is gone when the packet no longer has one', function()
            local gs = plain.boot('Testy_Events.lua')
            gs:send(0x037, {['Indi Buff'] = indi(4, 3)})
            plain.events(gs)
            gs:send(0x037, {['Indi Buff'] = 0})
            assert.same({{event = 'indi_change', element = 'Lightning', target = 'Ally', size = 3, gain = false}}, plain.events(gs))
        end)

        it('says nothing of an indi spell while the user file is disabled', function()
            local gs = plain.boot('Testy_Events.lua')
            gs:console('gs disable')
            gs:send(0x037, {['Indi Buff'] = fire_indi})
            assert.same({}, plain.events(gs))
        end)
    end)
end)

describe('the character stats packet (0x061)', function()
    it('gives the player its maximum HP and MP, and its main job and level', function()
        local gs = plain.boot()
        gs:send(0x061, {['Maximum HP'] = 1700, ['Maximum MP'] = 1100, ['Main Job'] = 3, ['Main Job Level'] = 90,
            ['Sub Job'] = 5})
        local player = gs.env.player
        assert.same({1700, 1100, 1700, 1100, 3, 90}, {player.max_hp, player.max_mp, player.vitals.max_hp,
            player.vitals.max_mp, player.main_job_id, player.main_job_level})
    end)

    it('gives the player its stats, attack, defense and nation once GearSwap refreshes', function()
        local gs = plain.boot()
        gs:send(0x061, {['Sub Job'] = 5, ['Base STR'] = 40, ['Added STR'] = 12, ['Base INT'] = 70, ['Added INT'] = -4,
            ['Attack'] = 812, ['Defense'] = 1103, ['Nation'] = 1})
        refresh(gs)
        local player = gs.user.player
        assert.same({40, 12, 52, 70, -4, 66}, {player.base_str, player.add_str, player.str, player.base_int, player.add_int, player.int})
        assert.same({812, 1103, 'Bastok', 1}, {player.attack, player.defense, player.nation, player.nation_id})
    end)

    it('tells the user file the sub job changed, with the new sub job and the old', function()
        local gs = plain.boot('Testy_Events.lua')
        gs.game.player.sub_job_id, gs.game.player.sub_job_level = 4, 40
        gs:send(0x061, {['Main Job'] = 3, ['Sub Job'] = 4, ['Sub Job Level'] = 40})
        assert.same({{event = 'sub_job_change', new = 'BLM', old = 'RDM'}}, plain.events(gs))
        local player = gs.env.player
        assert.same({4, 40, 'WHM/BLM'}, {player.sub_job_id, player.sub_job_level, player.job})
    end)

    it('says nothing when the sub job is the same', function()
        local gs = plain.boot('Testy_Events.lua')
        gs:send(0x061, {['Main Job'] = 3, ['Sub Job'] = 5})
        assert.same({}, plain.events(gs))
    end)

    it('says nothing of a sub job change while the user file is disabled, and still notes the new sub job', function()
        local gs = plain.boot('Testy_Events.lua')
        gs:console('gs disable')
        gs:send(0x061, {['Main Job'] = 3, ['Sub Job'] = 4})
        assert.same({}, plain.events(gs))
        assert.equal('BLM', gs.env.player.sub_job)
    end)

    pending('gives the player each elemental resistance under its own name: GearSwap reads the eight resistances in the '
        .. 'order fire, wind, lightning, light, ice, earth, water, dark, and the packet has fire, ice, wind, earth, '
        .. 'lightning, water, light, dark')
end)

describe('the skills packet (0x062)', function()
    it('gives the player the level of each skill', function()
        local gs = plain.boot()
        gs:send(0x062, {['Healing Magic Level'] = 300, ['Enhancing Magic Level'] = 285, ['Club Level'] = 261})
        local skills = gs.env.player.skills
        assert.same({300, 285, 261}, {skills.healing_magic, skills.enhancing_magic, skills.club})
    end)

    it('leaves the capped flag out of the level', function()
        local gs = plain.boot()
        gs:send(0x062, {['Healing Magic Level'] = 300, ['Healing Magic Capped'] = 1})
        assert.equal(300, gs.env.player.skills.healing_magic)
    end)
end)

describe('the vitals packets', function()
    it('0x0DF gives the player its HP, MP, TP and percentages', function()
        local gs = plain.boot()
        local id = gs.env.player.id
        gs:send(0x0DF, {['ID'] = id, ['HP'] = 900, ['MP'] = 450, ['TP'] = 1500, ['HPP'] = 60, ['MPP'] = 45})
        local player = gs.env.player
        assert.same({900, 450, 1500, 60, 45}, {player.hp, player.mp, player.tp, player.hpp, player.mpp})
        assert.same({900, 450, 1500, 60, 45}, {player.vitals.hp, player.vitals.mp, player.vitals.tp, player.vitals.hpp, player.vitals.mpp})
    end)

    it('0x0DF for someone else leaves the player\'s vitals as they are', function()
        local gs = plain.boot()
        local before = gs.env.player.hp
        gs:send(0x0DF, {['ID'] = gs.env.player.id + 1, ['HP'] = 1, ['MP'] = 1, ['TP'] = 1, ['HPP'] = 1, ['MPP'] = 1})
        assert.equal(before, gs.env.player.hp)
    end)

    it('0x0E2 gives the player its HP, TP and percentages', function()
        local gs = plain.boot()
        gs:send(0x0E2, {['ID'] = gs.env.player.id, ['HP'] = 800, ['MP'] = 300, ['TP'] = 2000, ['HPP'] = 53, ['MPP'] = 30})
        local player = gs.env.player
        assert.same({800, 2000, 53, 30}, {player.hp, player.tp, player.hpp, player.mpp})
    end)

    pending('0x0E2 gives the player its MP: GearSwap reads the MP from byte 0xB, which is inside the HP, and the packet '
        .. 'has it at byte 0xD')

    pending('0x0DF and 0x0E2 give a party member its vitals: GearSwap looks for the member by an id field its entry '
        .. 'in get_party does not have (the id is in its mob)')
end)

describe('the outgoing job change packet (0x100)', function()
    local function change_to(gs, main, sub)
        gs.game.player.main_job_id = main
        gs:send_from_client(0x100, string.char(main, sub, 0, 0))
    end

    it('loads the file of the new main job', function()
        local gs = plain.boot_corey()
        change_to(gs, 4, 5)
        assert.equal('Corey_BLM.lua', gs.env.current_file)
    end)

    pending('enables every slot, so the new job starts with none held: the code that does it asks whether the main job '
        .. 'in the packet differs from the main job after the same handler has set it, so it never runs')

    it('forgets what was held back for the old job\'s slots', function()
        local gs = plain.boot_corey()
        gs.env.not_sent_out_equip.head = 'Nyame Helm'
        change_to(gs, 4, 5)
        assert.is_nil(gs.env.not_sent_out_equip.head)
    end)

    it('changes nothing when the job it names is the one the player has', function()
        local gs = plain.boot_corey()
        local user = gs.env.user_env
        change_to(gs, 3, 5)
        assert.equal(user, gs.env.user_env)
    end)

    it('changes nothing when it names no job', function()
        local gs = plain.boot_corey()
        local user = gs.env.user_env
        gs:send_from_client(0x100, string.char(0, 5, 0, 0))
        assert.equal(user, gs.env.user_env)
    end)

    pending('leaves the user file as it is while the user file is disabled, as the zone-in packet does: the handler '
        .. 'in packet_parsing.lua queues the new job\'s load_user_files with send_command before it looks at '
        .. 'gearswap_disabled, and the queued load turns the user file on again')
end)

describe('the system message packet (0x053)', function()
    it('ends a trust summon that was refused, as an interrupted action', function()
        local gs = plain.boot()
        gs:type('/ma "Joachim" <me>')
        plain.calls(gs)
        gs:send(0x053, {['Message ID'] = 0x12D})
        local calls = plain.calls(gs)
        local last = calls[#calls]
        assert.same({'aftercast', 'Joachim', true}, {last.event, last.name, last.interrupted})
    end)

    it('says nothing for another message', function()
        local gs = plain.boot()
        gs:type('/ma "Cure III" <me>')
        plain.calls(gs)
        gs:send(0x053, {['Message ID'] = 0x100})
        assert.same({}, plain.calls(gs))
    end)
end)

describe('the conquest packet (0x05E)', function()
    local function conquest_packet(gs, strengths, nation, percents)
        local body = ('\0'):rep(180)
        local function put(position, value)
            local at = position - 4
            body = body:sub(1, at - 1) .. string.char(value) .. body:sub(at + 1)
        end
        put(29, strengths)
        put(30, nation)
        put(0x87, percents[1])
        put(0x88, percents[2])
        put(0x89, percents[3])
        gs:receive(0x05E, body)
    end

    it('gives the world the strength of each nation and beastmen in the region, its owner and the shares', function()
        local gs = plain.boot()
        gs:change_zone(100)
        conquest_packet(gs, 0 + 1 * 4 + 2 * 16 + 3 * 64, 2, {40, 30, 20})
        local conquest = gs.env.world.conquest
        assert.same({sandoria = 'Minimal', bastok = 'Minor', windurst = 'Major', beastmen = 'Dominant'}, conquest.strengths)
        assert.same({'Bastok', 40, 30, 20, 10}, {conquest.nation, conquest.sandoria, conquest.bastok, conquest.windurst, conquest.beastmen})
    end)

    it('is left alone when the zone is in no conquest region', function()
        local gs = plain.boot()
        gs:change_zone(230)
        conquest_packet(gs, 0, 1, {1, 2, 3})
        assert.is_false(gs.env.world.conquest)
    end)
end)
