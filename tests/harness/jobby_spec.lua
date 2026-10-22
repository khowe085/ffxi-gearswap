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

describe('Jobby\'s weapon', function()
    local function copies(gs, name)
        local count = 0
        for _, item in pairs(gs.game.bags[gs.game:bag_id('inventory')].items) do
            if gs.game.res.items[item.id].en == name then
                count = count + 1
            end
        end
        return count
    end

    it('is the job\'s, in hand over the idle set from the boot', function()
        local gs = jobby.boot('WAR')
        assert.same(jobby.worn_by(jobby.full_idle, {main = 'Ragnarok'}), gs:worn())
        assert.equal(1, copies(gs, 'Ragnarok'))
    end)

    it('is in the inventory once when the items name it too', function()
        assert.equal(1, copies(jobby.boot('WAR', {items = {'Ragnarok'}}), 'Ragnarok'))
    end)

    it('gives way to the weapon a boot wears, or to none', function()
        local axe = jobby.boot('WAR', {items = {'Conqueror'}, wearing = {main = 'Conqueror'}})
        assert.equal('Conqueror', axe:worn().main)
        assert.is_nil(jobby.boot('WAR', {wearing = {main = 'empty'}}):worn().main)
    end)

    it('is none for a job that has none named, whose hands are empty', function()
        assert.is_nil(jobby.weapons.MNK)
        assert.is_nil(jobby.boot('MNK'):worn().main)
    end)
end)

describe('a weapon skill Jobby types', function()
    it('gives what is worn once it has gone out', function()
        local gs = jobby.boot('WAR', {tp = 1000, items = {'Volte Bracers'}})
        assert.same(jobby.worn_by(jobby.full_idle, {main = 'Ragnarok', hands = 'Volte Bracers'}),
            jobby.weaponskill(gs, '/ws "Resolution" <t>'))
    end)

    it('gives what is worn once it has gone out with the TP given, which Jobby has as he types it, told as the game '
        .. 'tells a change of TP', function()
        local gs = jobby.boot('WAR', {items = {'Volte Bracers'}})
        local told
        gs.game:register('tp change', function(new) told = new end)
        assert.same(jobby.worn_by(jobby.full_idle, {main = 'Ragnarok', hands = 'Volte Bracers'}),
            jobby.weaponskill(gs, '/ws "Resolution" <t>', 1000))
        assert.equal(1000, told)
    end)

    it('fails the test when it doesn\'t go out', function()
        local gs = jobby.boot('WAR', {tp = 999})
        local ok, failure = pcall(jobby.weaponskill, gs, '/ws "Resolution" <t>')
        assert.is_false(ok)
        assert.matches('/ws "Resolution" <t> didn\'t go out alone', tostring(failure), 1, true)
    end)

    it('fails the test when another action went out since the actions were last read, though the weapon skill went '
        .. 'out too', function()
        local gs = jobby.boot('WAR', {tp = 1000})
        gs:type('/ja "Berserk" <me>')
        gs:finish_action()
        -- Past the moment after an ability in which Sel holds the next action back.
        gs:advance(1)
        local ok, failure = pcall(jobby.weaponskill, gs, '/ws "Resolution" <t>')
        assert.is_false(ok)
        assert.matches('/ws "Resolution" <t> didn\'t go out alone', tostring(failure), 1, true)
        local served = {}
        for i, action in ipairs(gs.game.actions) do
            served[i] = action.name
        end
        assert.same({'Berserk', 'Resolution'}, served)
    end)

    it('fails the test for a line not in the /ws "Name" form, though nothing went out', function()
        local gs = jobby.boot('WAR', {tp = 999})
        local ok, failure = pcall(jobby.weaponskill, gs, '/weaponskill "Resolution" <t>')
        assert.is_false(ok)
        assert.matches('a weapon skill is typed as /ws "Name", not as /weaponskill "Resolution" <t>', tostring(failure),
            1, true)
    end)
end)

describe('the pieces asked for in Jobby\'s sub slot', function()
    -- Jobby as a red mage, with his one-handed sword in hand, and a set that puts a grip beside it, which the server
    -- refuses: a grip goes only beside a two-handed weapon.
    local function with_a_grip_set()
        local gs = jobby.boot('RDM', {items = {'Enki Strap', 'Kupo Shield'}})
        gs.user.sets.grip = {sub = 'Enki Strap'}
        return gs
    end

    it('are those GearSwap asked for, though the server refused them', function()
        local gs = with_a_grip_set()
        gs:console('gs equip sets.grip')
        assert.same({'Enki Strap'}, jobby.subs_asked(gs))
        assert.same({"Judge's Sword"}, {gs:worn().main, gs:worn().sub})
    end)

    it('are each request, in order, though nothing was sent between two of them', function()
        local gs = with_a_grip_set()
        gs.user.sets.shield = {sub = 'Kupo Shield'}
        gs:console('gs equip sets.grip')
        gs:console('gs equip sets.shield')
        assert.same({'Enki Strap', 'Kupo Shield'}, jobby.subs_asked(gs))
        assert.equal('Kupo Shield', gs:worn().sub)
    end)

    it('take the traffic as read', function()
        local gs = with_a_grip_set()
        gs:console('gs equip sets.grip')
        jobby.subs_asked(gs)
        assert.same({}, gs:traffic())
    end)
end)

describe('the job abilities Jobby is given', function()
    local function set_of(names)
        local set = {}
        for _, name in ipairs(names) do
            set[name] = true
        end
        return set
    end

    it('are all the main job\'s and those of the sub job up to 49: Curing Waltz III and no IV for a blue mage with '
        .. 'Dancer as the sub job', function()
        local names = set_of(jobby.abilities('BLU', 'DNC'))
        assert.is_true(names['Unbridled Learning'] and names['Azure Lore'] and names['Curing Waltz III'])
        assert.is_nil(names['Curing Waltz IV'] or names['Saber Dance'])
    end)

    it('have the names given besides, a pet\'s moves', function()
        local names = set_of(jobby.abilities('BST', 'WAR', 'Foot Kick'))
        assert.is_true(names['Foot Kick'] and names['Reward'] and names['Provoke'])
    end)

    it('are each a job ability the test resources hold', function()
        local res = harness.resources()
        for _, job in ipairs({'BLU', 'BST', 'DNC', 'NIN', 'PLD', 'RDM', 'SMN', 'WAR', 'WHM'}) do
            for _, name in ipairs(jobby.abilities(job, job == 'WAR' and 'WHM' or 'WAR')) do
                assert.has_no.errors(function() Game.find_by_name(res.job_abilities, name, 'job ability') end, name)
            end
        end
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
