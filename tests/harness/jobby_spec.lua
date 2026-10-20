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

describe('what Jobby types and is told', function()
    -- Every piece the WAR gear file names, so that the gs validate finds none missing.
    local gear = {'Naegling', 'Conqueror', 'Volte Cap', 'Null Masque', 'Volte Jupon', 'Adamantite Armor',
        'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Fotia Gorget', "Combatant's Torque", 'Null Belt',
        'Moonshade Earring', 'Brutal Earring', 'Lugra Earring', 'Cessance Earring', 'Odnowa Earring +1', 'Karieyh Ring',
        'Chirich Ring +1'}

    local gs
    before_each(function()
        gs = jobby.boot('WAR', {items = gear})
        gs:play(harness.sel_load_time + 1)
    end)

    it('leaves out the /lockstyle on User-Globals.lua types five seconds after the load, and keeps a later one',
        function()
        assert.equal('/lockstyle on', gs.game.typed[#gs.game.typed])
        assert.same({}, jobby.typed(gs))
        gs:console('input /lockstyle on')
        assert.same({'/lockstyle on'}, jobby.typed(gs))
    end)

    it('leaves out the report of the gs validate User-Globals.lua runs five seconds after the load, and keeps a later '
        .. 'one', function()
        assert.is_truthy(tostring(gs.game.chat_log[#gs.game.chat_log].text):find('GearSwap: Final count = 0', 1, true))
        assert.same({}, jobby.said(gs))
        gs:console('gs validate')
        assert.same({'GearSwap: Checking for items in gear sets that are not in your inventory.',
            'GearSwap: Final count = 0'}, jobby.said(gs))
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
