local plain = require('plain')
local testy = require('testy')

local chat, texts = plain.chat, plain.texts

local worn_names = {}
for _, name in pairs(testy.whm_idle) do
    worn_names[name] = true
end

-- Testy as a white mage with the pieces the white mage file names: what is worn in the wardrobe, the rest in the
-- second wardrobe, and the extra items given. changes maps a piece's name to the bag it is in instead.
local function boot(extra, changes)
    local items = {}
    for _, item in ipairs(testy.whm().items) do
        local bag = (changes or {})[item.name] or (worn_names[item.name] and 'wardrobe' or 'wardrobe2')
        items[#items + 1] = {name = item.name, bag = bag}
    end
    for _, item in ipairs(extra or {}) do
        items[#items + 1] = item
    end
    local gs = plain.boot('Testy_WHM.lua', {items = items})
    chat(gs)
    return gs
end

-- Runs the command, lets the game run until the moves are done, and gives what GearSwap said.
local function run(gs, command, seconds)
    gs:console(command)
    gs:advance(seconds or 20)
    return texts(chat(gs))
end

local unworn = {"Bunzi's Hat", "Bunzi's Rod", 'Kaykaus Mitra +1', 'Kishar Ring'}

describe('gs stash', function()
    it('moves the pieces of a job\'s file that are in the wardrobes and not worn to the case', function()
        local gs = boot()
        run(gs, 'gs stash whm')
        assert.same(unworn, gs.game:bag_names('case'))
    end)

    it('leaves the worn pieces and what the file doesn\'t name where they are', function()
        local gs = boot({{name = 'Naegling', bag = 'wardrobe2'}})
        run(gs, 'gs stash whm')
        assert.same({'Naegling'}, gs.game:bag_names('wardrobe2'))
        assert.equal(15, #gs.game:bag_names('wardrobe'))
    end)

    it('says what it found and did', function()
        local gs = boot()
        assert.same({
            'GearSwap: Testy_WHM.lua uses 19 pieces.',
            "GearSwap: Equipped, so they stay: Alaunus's Cape, Ammurapi Shield, Daybreak, Defending Ring, Etiolation Earring, "
                .. 'Loricate Torque +1, Nyame Flanchard, Nyame Gauntlets, Nyame Helm, Nyame Mail, Nyame Sollerets, '
                .. 'Staunch Tathlum +1, Stikini Ring +1, loquacious earring and platinum moogle belt.',
            'GearSwap: stash is moving 4 pieces out of wardrobe and wardrobe2.',
            'GearSwap: stash moved 4 pieces: 4 to case.',
        }, run(gs, 'gs stash whm'))
    end)

    it('says it stays, not they stay, of the one piece that is worn', function()
        local gs = boot()
        gs.game.equipment = {}
        for _, bag in pairs(gs.game.bags) do
            for _, item in pairs(bag.items) do
                item.status = 0
            end
        end
        local _, daybreak = gs.game:find_item('wardrobe', 'Daybreak')
        daybreak.status = 5
        assert.equal('GearSwap: Equipped, so it stays: Daybreak.', run(gs, 'gs stash whm')[2])
    end)

    it('says there is nothing to move when everything is already out of the wardrobes', function()
        local gs = boot()
        run(gs, 'gs stash whm')
        assert.same({'GearSwap: Testy_WHM.lua uses 19 pieces.',
            "GearSwap: Equipped, so they stay: Alaunus's Cape, Ammurapi Shield, Daybreak, Defending Ring, Etiolation Earring, "
                .. 'Loricate Torque +1, Nyame Flanchard, Nyame Gauntlets, Nyame Helm, Nyame Mail, Nyame Sollerets, '
                .. 'Staunch Tathlum +1, Stikini Ring +1, loquacious earring and platinum moogle belt.',
            'GearSwap: stash: nothing to move.'}, run(gs, 'gs stash whm'))
    end)

    it('says how to use it when it is given no job', function()
        local gs = boot()
        assert.same({'GearSwap: Usage: gs stash <jobs> [unused]'}, run(gs, 'gs stash'))
        assert.same({'GearSwap: Usage: gs stash <jobs> [unused]'}, run(gs, 'gs stash unused'))
    end)

    it('says so when a word is no job, and moves nothing', function()
        local gs = boot()
        assert.same({'GearSwap: stash: foo is not a job. Nothing moved.'}, run(gs, 'gs stash whm foo'))
        assert.same({}, gs.game:bag_names('case'))
    end)

    it('says so when the job has no file, and moves nothing', function()
        local gs = require('harness').boot({
            character = 'Corey', main_job = 'WHM', sub_job = 'RDM', expect_file = 'Corey_WHM.lua',
            items = {{name = 'Nyame Helm', bag = 'wardrobe2'}},
        })
        chat(gs)
        assert.same({'GearSwap: stash cannot read the MON file: GearSwap finds no file for it. Nothing moved.'},
            run(gs, 'gs stash mon'))
        assert.same({}, gs.game:bag_names('case'))
    end)

    it('says so when the job\'s file raises an error, and moves nothing', function()
        local gs = boot()
        local lines = run(gs, 'gs stash drk')
        assert.matches('^GearSwap: stash cannot read the DRK file: ', lines[1])
        assert.matches('the dark knight file is broken', lines[1])
        assert.matches('Nothing moved%.$', lines[1])
        assert.same({}, gs.game:bag_names('case'))
    end)

    it('takes the job by its short name, in any case', function()
        local gs = boot()
        run(gs, 'gs stash Whm')
        assert.same(unworn, gs.game:bag_names('case'))
    end)

    it('takes the job by its long name, in any case', function()
        local gs = boot({{name = 'Naegling', bag = 'wardrobe2'}})
        assert.equal('GearSwap: Testy_PLD.lua uses 6 pieces.', run(gs, 'gs stash PALADIN')[1])
        assert.same({'Naegling'}, gs.game:bag_names('case'))
    end)

    it('takes a long name of two words in quotes', function()
        local gs = boot()
        run(gs, 'gs stash "White Mage"')
        assert.same(unworn, gs.game:bag_names('case'))
    end)

    it('takes the pieces of two jobs\' files, and names both files', function()
        local gs = boot({{name = 'Naegling', bag = 'wardrobe2'}})
        local lines = run(gs, 'gs stash whm pld')
        assert.equal('GearSwap: Testy_WHM.lua and Testy_PLD.lua use 22 pieces.', lines[1])
        assert.same({"Bunzi's Hat", "Bunzi's Rod", 'Kaykaus Mitra +1', 'Kishar Ring', 'Naegling'}, gs.game:bag_names('case'))
    end)

    it('names one file once when two words name the same job', function()
        local gs = boot()
        assert.equal('GearSwap: Testy_WHM.lua uses 19 pieces.', run(gs, 'gs stash whm WHM')[1])
    end)

    it('with unused moves what the file doesn\'t name, and leaves the pieces', function()
        local gs = boot({{name = 'Naegling', bag = 'wardrobe2'}})
        local lines = run(gs, 'gs stash whm unused')
        assert.same({'Naegling'}, gs.game:bag_names('case'))
        assert.equal('GearSwap: stash is moving 1 piece out of wardrobe and wardrobe2.', lines[#lines - 1])
        assert.equal('GearSwap: stash moved 1 piece: 1 to case.', lines[#lines])
        assert.equal(4, #gs.game:bag_names('wardrobe2'))
    end)

    it('with unused says it would empty the wardrobes when the file names no piece', function()
        local gs = boot()
        assert.same({'GearSwap: Testy_MON.lua uses 0 pieces.',
            'GearSwap: stash unused stopped: with no pieces to keep, it would empty the wardrobes.'},
            run(gs, 'gs stash mon unused'))
        assert.equal(4, #gs.game:bag_names('wardrobe2'))
    end)

    it('moves what doesn\'t fit in the case to the sack, after it', function()
        local gs = boot()
        gs.game.bags[7].max = 2
        local lines = run(gs, 'gs stash whm')
        assert.equal(2, #gs.game:bag_names('case'))
        assert.equal(2, #gs.game:bag_names('sack'))
        assert.equal('GearSwap: stash moved 4 pieces: 2 to case and 2 to sack.', lines[#lines])
    end)

    it('says why it stopped when there is no room, and how many did not move', function()
        local gs = boot()
        gs.game.bags[7].max = 1
        gs.game.bags[6].max = 1
        local lines = run(gs, 'gs stash whm')
        assert.same({
            'GearSwap: stash moved 2 pieces: 1 to case and 1 to sack.',
            'GearSwap: stash stopped: case and sack are full, and safe, safe2, storage and locker are out of reach. 2 pieces did not move.',
        }, {lines[#lines - 1], lines[#lines]})
    end)

    it('says the bags are out of reach when none can be reached', function()
        local gs = boot()
        gs.game.bags[7].disabled = true
        gs.game.bags[6].disabled = true
        assert.same({'GearSwap: stash stopped: case, sack, safe, safe2, storage and locker are all out of reach.'},
            run(gs, 'gs stash whm'))
        assert.same({}, gs.game:bag_names('case'))
    end)

    it('leaves a bag that is closed and uses the next', function()
        local gs = boot()
        gs.game.bags[7].disabled = true
        run(gs, 'gs stash whm')
        assert.same(unworn, gs.game:bag_names('sack'))
    end)

    it('says it needs a character logged in when none is', function()
        local gs = boot()
        gs.game:set_info({logged_in = false})
        assert.same({'GearSwap: stash needs a character logged in.'}, run(gs, 'gs stash whm'))
    end)

    it('says a stash is still moving when another is asked for', function()
        local gs = boot()
        gs:console('gs stash whm')
        gs:advance(0.1)
        chat(gs)
        gs:console('gs pull whm')
        assert.same({'GearSwap: A stash or pull is still moving gear.'}, texts(chat(gs)))
        gs:advance(20)
    end)

    it('can be asked for again once the first is done', function()
        local gs = boot()
        run(gs, 'gs stash whm')
        local lines = run(gs, 'gs pull whm')
        assert.same({'GearSwap: pull is moving 4 pieces into wardrobe and wardrobe2.', 'GearSwap: pull moved 4 pieces: 4 to wardrobe.'},
            {lines[2], lines[3]})
    end)

    it('says the server did not take the last moves when it takes none', function()
        local gs = boot()
        gs.game.refuse_moves = true
        local lines = run(gs, 'gs stash whm')
        assert.equal('GearSwap: stash stopped: the server did not take the last moves. 4 pieces did not move.', lines[#lines])
    end)

    it('says the inventory is full when the pieces have no room to pass through it', function()
        local gs = boot()
        gs.game.bags[0].max = 1
        gs.game:add_item('inventory', {name = 'Remedy'})
        local lines = run(gs, 'gs stash whm')
        assert.equal('GearSwap: stash stopped: the inventory is full, and every piece passes through it. 4 pieces did not move.', lines[#lines])
    end)

    it('says you changed zones when the zone changes while it moves', function()
        local gs = boot()
        gs:console('gs stash whm')
        gs:advance(0.3)
        gs.game.zone = 230
        gs:advance(20)
        local lines = texts(chat(gs))
        assert.matches('stopped: you changed zones%.', lines[#lines])
    end)

    describe('at a Nomad Moogle', function()
        it('can use the safe and the lockers too, not only the bags that are always there', function()
            local gs = boot()
            gs.game.bags[7].max = 1
            gs.game.bags[6].max = 1
            gs.game:add_mob({name = 'Nomad Moogle', distance = 3 ^ 2})
            local lines = run(gs, 'gs stash whm')
            assert.equal('GearSwap: stash moved 4 pieces: 1 to case, 1 to sack and 2 to safe.', lines[#lines])
            assert.equal(2, #gs.game:bag_names('safe'))
        end)

        it('talks to the moogle first, and the moogle is a Pilgrim Moogle just the same', function()
            local gs = boot()
            gs.game:add_mob({name = 'Pilgrim Moogle', distance = 3 ^ 2})
            local mark = #gs.game.sent
            run(gs, 'gs stash whm')
            assert.is_true(gs.game.moogle_menu)
            assert.equal(0x01A, gs.game.sent[mark + 1].id)
        end)

        it('can\'t use the storage, which only the Mog House has', function()
            local gs = boot()
            for _, id in ipairs({7, 6, 1, 9, 4}) do
                gs.game.bags[id].max = 0
            end
            gs.game:add_mob({name = 'Nomad Moogle', distance = 3 ^ 2})
            local lines = run(gs, 'gs stash whm')
            assert.same({}, gs.game:bag_names('storage'))
            assert.matches('stopped: case, sack, safe, safe2 and locker are full, and storage is out of reach%.', lines[#lines])
        end)

        it('too far to talk to is no help', function()
            local gs = boot()
            gs.game.bags[7].max = 1
            gs.game.bags[6].max = 1
            gs.game:add_mob({name = 'Nomad Moogle', distance = 10 ^ 2})
            local mark = #gs.game.sent
            local lines = run(gs, 'gs stash whm')
            assert.same({}, gs.game:bag_names('safe'))
            assert.is_nil(gs.game.moogle_menu)
            for i = mark + 1, #gs.game.sent do
                assert.not_equal(0x01A, gs.game.sent[i].id, 'GearSwap talked to the moogle')
            end
            assert.matches('out of reach', lines[#lines])
        end)
    end)

    describe('in the Mog House', function()
        it('can use every bag there, the storage too', function()
            local gs = boot()
            for _, id in ipairs({7, 6, 1, 9, 4}) do
                gs.game.bags[id].max = 0
            end
            gs.game:set_info({mog_house = true})
            run(gs, 'gs stash whm')
            assert.same(unworn, gs.game:bag_names('storage'))
        end)

        it('doesn\'t talk to a moogle', function()
            local gs = boot()
            gs.game:set_info({mog_house = true})
            gs.game:add_mob({name = 'Nomad Moogle', distance = 3 ^ 2})
            run(gs, 'gs stash whm')
            assert.is_nil(gs.game.moogle_menu)
        end)
    end)

    describe('reading a file it is not running', function()
        it('sends nothing to the game for it, and has none of its commands, chat or events run', function()
            local gs = boot()
            local commands, typed = #gs.game.commands, #gs.game.typed
            local lines = run(gs, 'gs stash pld')
            assert.equal(commands + 1, #gs.game.commands)
            assert.equal(typed, #gs.game.typed)
            for _, line in ipairs(lines) do
                assert.is_nil(line:find('from the paladin file', 1, true), line)
                assert.is_nil(line:find('from windower', 1, true), line)
            end
        end)

        it('reads it as the main job it is for', function()
            local gs = boot({{name = 'Nyame Helm', bag = 'wardrobe2'}})
            run(gs, 'gs stash pld')
            assert.same({'Nyame Helm'}, gs.game:bag_names('case'))
            assert.is_not_nil(gs.game:find_item('wardrobe2', "Bunzi's Hat"))
        end)

        it('leaves the loaded file alone', function()
            local gs = boot()
            local user = gs.env.user_env
            run(gs, 'gs stash pld')
            assert.equal(user, gs.env.user_env)
            assert.equal('Testy_WHM.lua', gs.env.current_file)
            assert.same({}, gs.env.registered_user_events)
        end)

        it('puts on no gear for it', function()
            local gs = boot()
            gs:traffic()
            run(gs, 'gs stash pld')
            assert.same({}, gs:traffic())
        end)

        it('has no event of it run when the game raises it', function()
            local gs = boot()
            run(gs, 'gs stash pld')
            gs.game:fire('zone change', 230, 100)
            assert.is_nil(gs.env.sandbox_event_ran)
        end)
    end)
end)

describe('gs pull', function()
    it('moves the pieces of a job\'s file that are in other bags into the wardrobes', function()
        local gs = boot(nil, {["Bunzi's Hat"] = 'case', ['Kishar Ring'] = 'sack'})
        local lines = run(gs, 'gs pull whm')
        assert.same({"Bunzi's Hat", 'Kishar Ring'}, {gs.game:find_item('wardrobe', "Bunzi's Hat") and "Bunzi's Hat",
            gs.game:find_item('wardrobe', 'Kishar Ring') and 'Kishar Ring'})
        assert.same({}, gs.game:bag_names('case'))
        assert.same({}, gs.game:bag_names('sack'))
        assert.same({'GearSwap: Testy_WHM.lua uses 19 pieces.', 'GearSwap: pull is moving 2 pieces into wardrobe and wardrobe2.',
            'GearSwap: pull moved 2 pieces: 2 to wardrobe.'}, lines)
    end)

    it('takes a piece from the inventory without a stop in between', function()
        local gs = boot(nil, {['Kishar Ring'] = 'inventory'})
        run(gs, 'gs pull whm')
        assert.is_not_nil(gs.game:find_item('wardrobe', 'Kishar Ring'))
        assert.same({}, gs.game:bag_names('inventory'))
    end)

    it('fills the first wardrobe, then the second', function()
        local gs = boot(nil, {["Bunzi's Hat"] = 'case', ['Kishar Ring'] = 'case'})
        gs.game.bags[8].max = 15
        run(gs, 'gs pull whm')
        assert.is_not_nil(gs.game:find_item('wardrobe2', "Bunzi's Hat"))
        assert.is_not_nil(gs.game:find_item('wardrobe2', 'Kishar Ring'))
    end)

    it('says how many went to each wardrobe', function()
        local gs = boot(nil, {["Bunzi's Hat"] = 'case', ['Kishar Ring'] = 'case'})
        gs.game.bags[8].max = 16
        local lines = run(gs, 'gs pull whm')
        assert.equal('GearSwap: pull moved 2 pieces: 1 to wardrobe and 1 to wardrobe2.', lines[#lines])
    end)

    it('says there is nothing to move when the wardrobes have every piece', function()
        local gs = boot()
        assert.same({'GearSwap: Testy_WHM.lua uses 19 pieces.', 'GearSwap: pull: nothing to move.'}, run(gs, 'gs pull whm'))
    end)

    it('says which pieces are in no bag it can reach', function()
        local gs = boot(nil, {['Kishar Ring'] = 'safe', ["Bunzi's Hat"] = 'case'})
        local lines = run(gs, 'gs pull whm')
        assert.equal('GearSwap: In no bag in reach: Kishar Ring.', lines[2])
        assert.equal('GearSwap: pull moved 1 piece: 1 to wardrobe.', lines[#lines])
    end)

    it('takes from the safe at a moogle that is within reach', function()
        local gs = boot(nil, {['Kishar Ring'] = 'safe'})
        gs.game:add_mob({name = 'Nomad Moogle', distance = 3 ^ 2})
        run(gs, 'gs pull whm')
        assert.is_not_nil(gs.game:find_item('wardrobe', 'Kishar Ring'))
    end)

    it('takes from the safe in the Mog House', function()
        local gs = boot(nil, {['Kishar Ring'] = 'safe'})
        gs.game:set_info({mog_house = true})
        run(gs, 'gs pull whm')
        assert.is_not_nil(gs.game:find_item('wardrobe', 'Kishar Ring'))
    end)

    it('takes from another wardrobe, which is a bag in reach too', function()
        local gs = boot(nil, {['Kishar Ring'] = 'wardrobe3'})
        run(gs, 'gs pull whm')
        assert.is_not_nil(gs.game:find_item('wardrobe2', 'Kishar Ring') or gs.game:find_item('wardrobe', 'Kishar Ring'))
        assert.same({}, gs.game:bag_names('wardrobe3'))
    end)

    it('says a piece that is worn in another bag stays there', function()
        local gs = boot(nil, {['Defending Ring'] = 'case'})
        local slot, item = gs.game:find_item('case', 'Defending Ring')
        item.status = 5
        local lines = run(gs, 'gs pull whm')
        assert.equal('GearSwap: Equipped, so it stays: Defending Ring.', lines[2])
        assert.is_not_nil(gs.game:find_item('case', 'Defending Ring'))
    end)

    it('takes as many copies of a piece as one set wears at once', function()
        local gs = boot({{name = 'Stikini Ring +1', bag = 'case'}, {name = 'Stikini Ring +1', bag = 'case'}, {name = 'Naegling', bag = 'case'}})
        local lines = run(gs, 'gs pull pld')
        assert.equal('GearSwap: Testy_PLD.lua uses 6 pieces.', lines[1])
        local copies = 0
        for _, name in ipairs(gs.game:bag_names('wardrobe')) do
            if name == 'Stikini Ring +1' then
                copies = copies + 1
            end
        end
        assert.equal(2, copies)
    end)

    it('takes the copy of a piece that has the augments the file names', function()
        local wanted, other = {'MND+20', 'Enmity+10'}, {'MND+20', '"Cure" potency +10%'}
        local gs = boot({{name = "Alaunus's Cape", bag = 'case', augments = other},
            {name = "Alaunus's Cape", bag = 'case', augments = wanted}})
        run(gs, 'gs pull pld')
        local _, left_in_case = gs.game:find_item('case', "Alaunus's Cape")
        assert.equal(require('harness').extdata(other), left_in_case.extdata)
        local pulled = {}
        for _, bag in ipairs({'wardrobe', 'wardrobe2'}) do
            for _, item in pairs(gs.game.bags[gs.game:bag_id(bag)].items) do
                if item.extdata == require('harness').extdata(wanted) then
                    pulled[#pulled + 1] = bag
                end
            end
        end
        assert.same({'wardrobe'}, pulled)
    end)

    it('says it stopped when the wardrobes are full', function()
        local gs = boot(nil, {['Kishar Ring'] = 'case'})
        gs.game.bags[8].max = 15
        gs.game.bags[10].max = 3
        local lines = run(gs, 'gs pull whm')
        assert.equal('GearSwap: pull stopped: wardrobe and wardrobe2 are full. 1 piece did not move.', lines[#lines])
    end)

    it('says the wardrobes are out of reach when they are closed', function()
        local gs = boot(nil, {['Kishar Ring'] = 'case'})
        gs.game.bags[8].disabled = true
        gs.game.bags[10].disabled = true
        assert.same({'GearSwap: pull stopped: wardrobe and wardrobe2 are all out of reach.'}, run(gs, 'gs pull whm'))
    end)

    it('says unused goes with stash, not pull', function()
        local gs = boot()
        assert.same({'GearSwap: unused goes with stash, not pull. Nothing moved.'}, run(gs, 'gs pull whm unused'))
    end)

    it('says how to use it when it is given no job', function()
        local gs = boot()
        assert.same({'GearSwap: Usage: gs pull <jobs>'}, run(gs, 'gs pull'))
    end)
end)
