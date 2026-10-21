local harness = require('harness')
local plain = require('plain')

local calls, events = plain.calls, plain.names

local function boot()
    local gs = plain.boot('Testy_Actions.lua')
    calls(gs)
    return gs
end

describe('a pet command typed in the chat', function()
    it('goes out at the target as the ability it is, after the precast gear', function()
        local gs = boot()
        gs:type('/pet "Assault" <t>')
        assert.same({
            {equip = {head = "Bunzi's Hat"}},
            {action = 'Assault', target = 'Apex Toad'},
            {equip = {head = 'Kaykaus Mitra +1'}},
        }, gs:traffic())
    end)

    it('is a pet command to the hooks', function()
        local gs = boot()
        gs:type('/pet "Assault" <t>')
        local got = calls(gs)
        assert.same({'pretarget', 'precast', 'midcast'}, events(got))
        assert.same({'Assault', 'PetCommand', '/pet', 'Ability', 'Apex Toad'}, {got[2].name, got[2].type, got[2].prefix,
            got[2].action_type, got[2].target})
    end)

    it('gets the aftercast gear once the server says it is done', function()
        local gs = boot()
        gs:type('/pet "Assault" <t>')
        calls(gs)
        gs:finish_action()
        assert.same({'aftercast'}, events(calls(gs)))
    end)

    it('is not sent when the character has no such ability', function()
        local gs = boot()
        gs.game.job_abilities = {}
        gs:type('/pet "Assault" <t>')
        assert.same({'filtered_action'}, events(calls(gs)))
        assert.same({}, gs:traffic())
    end)
end)

describe('a beast pet command typed as /bstpet and a number', function()
    it('is the ability that number among the character\'s pet abilities', function()
        local gs = boot()
        gs:type('/bstpet 2 <t>')
        local got = calls(gs)
        assert.same({'Dust Cloud', '/pet'}, {got[2].name, got[2].prefix})
        assert.same({action = 'Dust Cloud', target = 'Apex Toad'}, gs:traffic()[2])
    end)

    it('the first is the first of them', function()
        local gs = boot()
        gs:type('/bstpet 1 <t>')
        assert.equal('Foot Kick', calls(gs)[2].name)
    end)

    it('with a number past the last is left to the game', function()
        local gs = boot()
        local range, known = gs.env.bstpet_range, 0
        for _, id in ipairs(gs.game.windower.ffxi.get_abilities().job_abilities) do
            if id >= range.min and id <= range.max then
                known = known + 1
            end
        end
        local line = ('/bstpet %d <t>'):format(known + 1)
        assert.equal(line, gs:type(line))
        assert.same({}, calls(gs))
    end)
end)

describe('a pet\'s action', function()
    local function boot_with_pet(name)
        local gs = boot()
        gs.game:place_pet({name = name or 'Carbuncle'})
        plain.refresh(gs)
        return gs
    end

    it('being readied tells the user file pet_midcast with the move and who it is for', function()
        local gs = boot_with_pet()
        gs:pet_readies('Foot Kick')
        local got = calls(gs)
        assert.same({{event = 'pet_midcast', name = 'Foot Kick', target = 'Apex Toad'}}, {{event = got[1].event, name = got[1].name, target = got[1].target}})
        assert.is_true((gs.user.pet_midaction()))
    end)

    it('being readied is a monster move to the hooks', function()
        local gs = boot_with_pet()
        gs:pet_readies('Dust Cloud')
        local got = calls(gs)[1]
        assert.same({'Dust Cloud', 'Monster Move'}, {got.name, got.action_type})
    end)

    it('being done tells the user file pet_aftercast, and the pet is no longer in midaction', function()
        local gs = boot_with_pet()
        gs:pet_readies('Foot Kick')
        calls(gs)
        gs:pet_finishes('Foot Kick')
        local got = calls(gs)
        assert.same({'pet_aftercast', 'Foot Kick'}, {got[1].event, got[1].name})
        assert.is_false(gs.user.pet_midaction())
    end)

    pending('being interrupted while it readies a move (a TP move or a blood pact) tells the user file '
        .. 'pet_aftercast, marked interrupted: the server\'s packet for an interruption carries no message, and '
        .. 'get_spell (helper_functions.lua) looks a category 7 action with none up among the weapon skills only, so '
        .. 'a TP move, a monster ability, or a blood pact, a job ability, is not found, nothing is told and the pet '
        .. 'stays in midaction until GearSwap drops the entry as stale, the next time it looks in its registry once 10 '
        .. 'seconds have passed for a TP move, or 5 for a blood pact')

    it('being interrupted while it casts a spell tells the user file pet_aftercast, marked interrupted', function()
        local gs = boot_with_pet('FireSpirit')
        gs:pet_readies('Fire', 'spell')
        calls(gs)
        gs:pet_acts('Fire', 'spell', 'interrupt')
        local got = calls(gs)
        assert.same({'pet_aftercast'}, events(got))
        assert.same({'Fire', true}, {got[1].name, got[1].interrupted})
        assert.is_false(gs.user.pet_midaction())
    end)

    it('is left alone when the player has no pet', function()
        local gs = boot()
        local pet_id = gs.game:place_pet({name = 'Carbuncle'}).id
        gs:take_pet()
        gs:pet_readies('Foot Kick', 'monster', {actor_id = pet_id})
        assert.same({}, calls(gs))
    end)

    it('is left alone while the user file is disabled', function()
        local gs = boot_with_pet()
        gs:console('gs disable')
        gs:pet_readies('Foot Kick')
        assert.same({}, calls(gs))
    end)

    it('is left alone when it is someone else\'s', function()
        local gs = boot_with_pet()
        local other = gs.game:add_mob({name = 'Stranger\'s pet'})
        gs:pet_readies('Foot Kick', 'monster', {actor_id = other.id})
        assert.same({}, calls(gs))
    end)

    pending('stops being in midaction when pet_midaction(false) is called: user_pet_midaction sets the flag on '
        .. 'command_registry itself, not on the entry it found, and the scan that follows (and every later pet_midaction) '
        .. 'indexes that boolean and raises an error')
end)

describe('a Monipulator\'s skill typed in the chat', function()
    local function boot_mon(level)
        local gs = harness.boot({main_job = 'MON', sub_job = 'NON', main_job_level = level or 99, expect_file = 'Testy_MON.lua',
            items = {}})
        plain.load(gs, 'Testy_Actions.lua')
        gs.game:set_species(1)
        plain.refresh(gs)
        gs:traffic()
        return gs
    end

    it('goes out at the target as the skill it is', function()
        local gs = boot_mon()
        gs:type('/ms "Foot Kick" <t>')
        assert.same({{action = 'Foot Kick', target = 'Apex Toad'}}, gs:traffic())
    end)

    it('is a skill of the species, with the hooks told it is a monster skill', function()
        local gs = boot_mon()
        gs:type('/ms "Foot Kick" <t>')
        local got = calls(gs)
        assert.same({'pretarget', 'precast', 'midcast'}, events(got))
        assert.same({'Foot Kick', 'MonsterSkill', '/monsterskill'}, {got[2].name, got[2].type, got[2].prefix})
    end)

    it('is sent as category 25', function()
        local gs = boot_mon()
        local mark = #gs.game.sent
        gs:type('/ms "Foot Kick" <t>')
        for i = mark + 1, #gs.game.sent do
            local packet = gs.game.sent[i]
            if packet.id == 0x1A then
                assert.equal(25, packet.data:byte(11))
                return
            end
        end
        error('no action packet was sent')
    end)

    pending('that the species has not learned yet is left to the game: GearSwap looks the skill up among the species\' '
        .. 'moves and, finding none, indexes the nil resource line it should have built (triggers.lua r_line)')

    it('that the species has learned at this level goes out', function()
        local gs = boot_mon(12)
        gs:type('/ms "Dust Cloud" <t>')
        assert.same({'pretarget', 'precast', 'midcast'}, events(calls(gs)))
    end)

    it('is in the player\'s species, with the moves it has at its level', function()
        local gs = boot_mon(12)
        assert.same({1, 'Rabbit'}, {gs.env.player.species.id, gs.env.player.species.en})
        local moves = {}
        for id in pairs(gs.env.player.species.tp_moves) do
            moves[#moves + 1] = id
        end
        table.sort(moves)
        assert.same({257, 258}, moves)
    end)
end)
