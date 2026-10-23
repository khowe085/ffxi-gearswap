local Game = require('game')
local harness = require('harness')
local testy = require('testy')

describe('the stand-in game\'s party', function()
    it('has the character alone in its party until another player joins', function()
        local gs = harness.boot(testy.whm())
        local party = gs.game.windower.ffxi.get_party()
        assert.equal(1, party.party1_count)
        assert.is_nil(party.p1)
    end)

    it('has the first who joins as p1 and <p1>, among the mobs in the party, and in GearSwap\'s alliance', function()
        local gs = harness.boot(testy.whm())
        gs.game:add_party_member({name = 'Friend'})
        local ffxi = gs.game.windower.ffxi
        local party = ffxi.get_party()
        assert.same({'Friend', 2}, {party.p1.name, party.party1_count})
        assert.equal('Friend', ffxi.get_mob_by_target('<p1>').name)
        local mob = ffxi.get_mob_by_name('Friend')
        assert.same({party.p1.mob.id, true}, {mob.id, mob.in_party})
        gs.env.refresh_globals()
        assert.equal('Friend', gs.env.alliance[1][2].name)
    end)

    it('lists the members after the character, in the order they joined', function()
        local game = Game.new({res = harness.resources()})
        game:add_party_member({name = 'Koru-Moru'})
        game:add_party_member({name = 'Qultada'})
        local party = game.windower.ffxi.get_party()
        assert.equal('Koru-Moru', party.p1.name)
        assert.equal('Qultada', party.p2.name)
        assert.is_nil(party.p3)
        assert.equal(3, party.party1_count)
    end)

    it('has the player as p0 and each member after, as p1 on, with the health the game gives', function()
        local gs = harness.boot(testy.whm())
        gs.game:add_party_member({name = 'Alice', hp = 800, mp = 300, tp = 1200})
        local party = gs.game.windower.ffxi.get_party()
        assert.same({'Testy', 'Alice', 800, 300, 1200, 2}, {party.p0.name, party.p1.name, party.p1.hp, party.p1.mp, party.p1.tp,
            party.party1_count})
    end)

    it('has the HP percent of the HP a member has', function()
        local gs = harness.boot(testy.whm())
        local friend = gs.game:add_party_member({hp = 250})
        assert.equal(25, friend.hpp)
    end)

    it('gives a member\'s HP, MP and TP on the party list only: their mob has the HP percent and no HP or MP, as '
        .. 'Windower\'s has, and no TP, the stand-in\'s choice', function()
        local gs = harness.boot(testy.whm())
        gs.game:add_party_member({name = 'Alice', hp = 800, mp = 300, tp = 1200})
        local ffxi = gs.game.windower.ffxi
        for _, mob in ipairs({ffxi.get_mob_by_name('Alice'), ffxi.get_mob_by_target('<p1>'), ffxi.get_party().p1.mob}) do
            assert.equal(80, mob.hpp)
            assert.same({}, {hp = mob.hp, max_hp = mob.max_hp, mp = mob.mp, max_mp = mob.max_mp, tp = mob.tp})
        end
    end)

    it('gives the player\'s TP in the player and the party list, and the player\'s mob no HP or MP, as Windower\'s '
        .. 'has, and no TP, the stand-in\'s choice', function()
        local gs = harness.boot(testy.whm({tp = 1000}))
        local ffxi = gs.game.windower.ffxi
        local mob = ffxi.get_mob_by_target('<me>')
        assert.same({1000, 1000}, {ffxi.get_player().vitals.tp, ffxi.get_party().p0.tp})
        assert.same({}, {hp = mob.hp, mp = mob.mp, tp = mob.tp})
    end)

    it('has a member of another party in the slot it is given, and not in the count of the first', function()
        local gs = harness.boot(testy.whm())
        gs.game:add_party_member({name = 'Carol', slot = 'a10'})
        local party = gs.game.windower.ffxi.get_party()
        assert.same({'Carol', 1}, {party.a10.name, party.party1_count})
    end)

    it('is led by the player unless a member is said to lead it, as the other parties and the alliance are', function()
        local gs = harness.boot(testy.whm())
        local party = gs.game.windower.ffxi.get_party()
        assert.same({gs.game.player.id}, {party.party1_leader, party.party2_leader, party.alliance_leader})
        local dave = gs.game:add_party_member({name = 'Dave', leader = true})
        local carol = gs.game:add_party_member({name = 'Carol', slot = 'a10', leader = true, alliance_leader = true})
        party = gs.game.windower.ffxi.get_party()
        assert.same({dave.id, carol.id, carol.id}, {party.party1_leader, party.party2_leader, party.alliance_leader})
    end)

    it('has members that are mobs the game knows, in the party and not NPCs', function()
        local gs = harness.boot(testy.whm())
        local alice = gs.game:add_party_member({name = 'Alice'})
        local mob = gs.game.windower.ffxi.get_mob_by_index(alice.index)
        assert.same({false, true, true, 13}, {mob.is_npc, mob.in_party, mob.in_alliance, mob.spawn_type})
    end)

    it('has its members as the targets <p1> on, and <p0> is the player', function()
        local gs = harness.boot(testy.whm())
        gs.game:add_party_member({name = 'Alice'})
        assert.same({'Alice', 'Testy'}, {gs.game.windower.ffxi.get_mob_by_target('<p1>').name,
            gs.game.windower.ffxi.get_mob_by_target('<p0>').name})
    end)

    it('has no <p2> when there is only one other member', function()
        local gs = harness.boot(testy.whm())
        gs.game:add_party_member({name = 'Alice'})
        assert.is_nil(gs.game.windower.ffxi.get_mob_by_target('<p2>'))
    end)

    it('has no player in it with in_party false, but a mob that is found', function()
        local gs = harness.boot(testy.whm())
        gs.game:add_party_member({name = 'Stranger', in_party = false})
        local ffxi = gs.game.windower.ffxi
        assert.is_nil(ffxi.get_party().p1)
        assert.is_nil(ffxi.get_mob_by_target('<p1>'))
        assert.equal('Stranger', ffxi.get_mob_by_name('Stranger').name)
    end)

    it('has a member GearSwap finds by name as a target', function()
        local gs = harness.boot(testy.whm())
        gs.game:add_party_member({name = 'Friend'})
        gs:type('/ma "Cure III" Friend')
        assert.same({action = 'Cure III', target = 'Friend'}, gs:traffic()[2])
    end)
end)
