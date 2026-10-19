local Game = require('game')
local harness = require('harness')
local jobby = require('jobby')
local testy = require('testy')

describe('the stand-in game for the job files\' tests', function()
    it('gives a blue mage every blue spell it knows in its set, past twenty, with empty slots as 512 below that', function()
        local game = Game.new({res = harness.resources(), main_job = 'BLU'})
        local blue = 0
        for id in pairs(game.spells) do
            if game.res.spells[id].type == 'BlueMagic' then
                blue = blue + 1
            end
        end
        assert.is_true(blue > 20)
        assert.equal(blue, #game:mjob_data().spells)
    end)

    it('gives a blue mage that knows few spells a set of twenty slots, the empty ones 512', function()
        local game = Game.new({res = harness.resources(), main_job = 'BLU', spells = {'Subduction', 'Cocoon'}})
        local set = game:mjob_data().spells
        assert.equal(20, #set)
        assert.same({547, 708}, {set[1], set[2]})
        assert.equal(512, set[3])
    end)

    it('tells the target arrow with the world, as Windower does', function()
        local game = Game.new({res = harness.resources()})
        assert.same({x = 0, y = 0, z = 0}, game:get_info().target_arrow)
    end)
end)

describe('another player near the character', function()
    it('is the first member of the party, by p1, by name among the mobs and in GearSwap\'s alliance', function()
        local gs = harness.boot(testy.whm())
        gs.game:add_other_player({name = 'Friend'})
        local ffxi = gs.game.windower.ffxi
        assert.equal('Friend', ffxi.get_party().p1.name)
        assert.equal('Friend', ffxi.get_mob_by_target('<p1>').name)
        assert.equal('Friend', ffxi.get_mob_by_name('Friend').name)
        assert.equal(2, ffxi.get_party().party1_count)
        gs.env.refresh_globals()
        assert.equal('Friend', gs.env.alliance[1][2].name)
    end)

    it('is no member of the party with in_party false, but a mob that is found', function()
        local gs = harness.boot(testy.whm())
        gs.game:add_other_player({name = 'Stranger', in_party = false})
        local ffxi = gs.game.windower.ffxi
        assert.is_nil(ffxi.get_party().p1)
        assert.is_nil(ffxi.get_mob_by_target('<p1>'))
        assert.equal('Stranger', ffxi.get_mob_by_name('Stranger').name)
    end)

    it('has the HP percent of the HP it has', function()
        local gs = harness.boot(testy.whm())
        local friend = gs.game:add_other_player({hp = 250})
        assert.equal(25, friend.hpp)
    end)

    it('is the target of a spell by name', function()
        local gs = harness.boot(testy.whm())
        gs.game:add_other_player({name = 'Friend'})
        gs:type('/ma "Cure III" Friend')
        local sent = {}
        for _, entry in ipairs(gs:traffic()) do
            if entry.action then
                sent[#sent + 1] = entry
            end
        end
        assert.same({{action = 'Cure III', target = 'Friend'}}, sent)
    end)
end)

describe('what Jobby\'s tests change in the world', function()
    it('sets the day and the weather GearSwap reads on its next refresh', function()
        local gs = harness.boot(testy.whm())
        jobby.set_world(gs, {day = 6, weather = 16})
        gs.env.refresh_globals()
        assert.equal('Lightsday', gs.env.world.day)
        assert.equal('Light', gs.env.world.day_element)
        assert.equal('Light', gs.env.world.weather_element)
    end)

    it('puts the recasts at what it says, in seconds for abilities and sixtieths for spells', function()
        local gs = harness.boot(testy.whm())
        jobby.set_recasts(gs, {abilities = {[2] = 12}, spells = {[3] = 600}})
        local ffxi = gs.game.windower.ffxi
        assert.equal(12, ffxi.get_ability_recasts()[2])
        assert.equal(600, ffxi.get_spell_recasts()[3])
    end)

    it('leaves every other recast ready', function()
        local gs = harness.boot(testy.whm())
        jobby.set_recasts(gs, {abilities = {[2] = 12}, spells = {[3] = 600}})
        local ffxi = gs.game.windower.ffxi
        assert.equal(0, ffxi.get_ability_recasts()[1])
        assert.equal(0, ffxi.get_spell_recasts()[4])
    end)

    it('can change the recasts again', function()
        local gs = harness.boot(testy.whm())
        jobby.set_recasts(gs, {abilities = {[2] = 12}})
        jobby.set_recasts(gs, {abilities = {[2] = 0}})
        assert.equal(0, gs.game.windower.ffxi.get_ability_recasts()[2])
    end)
end)

describe('a layer of sets', function()
    it('names the slots as the game does, so a later set\'s ear1 takes the place of an earlier left_ear', function()
        assert.same({left_ear = 'B', head = 'H'}, jobby.layer({left_ear = 'A', head = 'H'}, {ear1 = 'B'}))
    end)

    it('leaves out what is no slot, such as the sets under a set', function()
        assert.same({head = 'H'}, jobby.layer({head = 'H', Acc = {head = 'X'}}))
    end)
end)
