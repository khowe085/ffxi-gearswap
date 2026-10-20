local Game = require('game')
local harness = require('harness')
local jobby = require('jobby')

describe('the stand-in game for the job files\' tests', function()
    it('gives a blue mage every blue spell it knows in its set, past twenty', function()
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

    it('gives a Monipulator its species and a puppetmaster its automaton as the data of the main job', function()
        local game = Game.new({res = harness.resources(), main_job = 'MON'})
        game:set_species(3)
        assert.same({species = 3}, game.windower.ffxi.get_mjob_data())
        game = Game.new({res = harness.resources(), main_job = 'WHM'})
        game:set_automaton({name = 'Faustus'})
        assert.same({}, game.windower.ffxi.get_mjob_data())
        game.player.main_job_id = 18
        assert.equal('Faustus', game.windower.ffxi.get_mjob_data().name)
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
