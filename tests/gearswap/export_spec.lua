local harness = require('harness')
local lfs = require('lfs')
local plain = require('plain')
local testy = require('testy')

local cape_augments = {'MND+20', 'Enmity+10'}

-- Testy as a white mage with the augmented cape on in place of the plain one.
local function boot(overrides)
    local options = testy.whm()
    for i, item in ipairs(options.items) do
        if item.name == "Alaunus's Cape" then
            options.items[i] = {name = "Alaunus's Cape", augments = cape_augments}
        end
    end
    for key, value in pairs(overrides or {}) do
        options[key] = value
    end
    local gs = plain.boot('Testy_WHM.lua', options)
    gs:chat_lines()
    return gs
end

local function folder(gs)
    return gs.env.windower.addon_path .. 'data/export/'
end

-- The text of the file an export wrote, which is then removed.
local function exported(gs, name)
    local path = folder(gs) .. name
    local file = assert(io.open(path, 'rb'), name .. ' was not written')
    local text = file:read('*a')
    file:close()
    os.remove(path)
    return text
end

local function written(gs, name)
    return lfs.attributes(folder(gs) .. name) ~= nil
end

local function export(gs, options)
    gs:console('gs export ' .. options)
    return gs:chat()
end

local worn_lines = {
    '    main="Daybreak",',
    '    sub="Ammurapi Shield",',
    '    ammo="Staunch Tathlum +1",',
    '    head="Nyame Helm",',
    '    body="Nyame Mail",',
    '    hands="Nyame Gauntlets",',
    '    legs="Nyame Flanchard",',
    '    feet="Nyame Sollerets",',
    '    neck="Loricate Torque +1",',
    '    waist="Plat. Mog. Belt",',
    '    left_ear="Etiolation Earring",',
    '    right_ear="Loquac. Earring",',
    '    left_ring="Defending Ring",',
    '    right_ring="Stikini Ring +1",',
    '    back={ name="Alaunus\'s Cape", augments={\'MND+20\',\'Enmity+10\',}},',
}

local function lines_of(text)
    local lines = {}
    for line in (text .. '\n'):gmatch('(.-)\n') do
        lines[#lines + 1] = line
    end
    return lines
end

describe('gs export of what is worn', function()
    it('writes a set of every slot\'s piece, with the augments of the ones that have them', function()
        local gs = boot()
        export(gs, 'file worn')
        local expected = 'sets.exported = {\n' .. table.concat(worn_lines, '\n') .. '\n}'
        assert.equal(expected, exported(gs, 'Testy_worn.lua'))
    end)

    it('says what it does', function()
        local gs = boot()
        assert.same({'GearSwap: Exporting your currently equipped gear as a lua file. (Named: Character_worn)'},
            export(gs, 'file worn'))
    end)

    it('is also gs x', function()
        local gs = boot()
        gs:console('gs x file viax')
        assert.is_true(written(gs, 'Testy_viax.lua'))
    end)

    it('names the file with the character and the date when it is given no name', function()
        local gs = boot()
        gs:console('gs export')
        local found
        for entry in lfs.dir(folder(gs)) do
            if entry:match('^Testy %d%d%d%d%-%d%d%-%d%d %d%d%-%d%d%-%d%d%.lua$') then
                found = entry
            end
        end
        assert.is_not_nil(found, 'no file named for Testy and the date')
        os.remove(folder(gs) .. found)
    end)

    it('names the file with the character and the main job for mainjob', function()
        local gs = boot()
        assert.same({'GearSwap: Exporting your currently equipped gear as a lua file. (Naming format: Character_JOB)'},
            export(gs, 'mainjob'))
        assert.is_true(written(gs, 'Testy_WHM.lua'))
        os.remove(folder(gs) .. 'Testy_WHM.lua')
    end)

    it('names the file with the character and both jobs for mainsubjob', function()
        local gs = boot()
        assert.same({'GearSwap: Exporting your currently equipped gear as a lua file. (Naming format: Character_JOB_SUB)'},
            export(gs, 'mainsubjob'))
        assert.is_true(written(gs, 'Testy_WHM_RDM.lua'))
        os.remove(folder(gs) .. 'Testy_WHM_RDM.lua')
    end)

    it('names the set when it is given a name for it', function()
        local gs = boot()
        export(gs, 'name mine file named')
        assert.equal('sets["mine"] = {', lines_of(exported(gs, 'Testy_named.lua'))[1])
    end)

    it('writes the set on one line with mini', function()
        local gs = boot()
        export(gs, 'mini file one_line')
        local text = exported(gs, 'Testy_one_line.lua')
        assert.is_nil(text:find('\n', 1, true))
        assert.equal('sets.exported = {', text:sub(1, 17))
        assert.equal('    main="Daybreak",    sub="Ammurapi Shield",', text:sub(18, 63))
    end)

    it('leaves out the augments with noaugments', function()
        local gs = boot()
        assert.matches('(omitting augments)', export(gs, 'noaugments file plain')[1], 1, true)
        local text = exported(gs, 'Testy_plain.lua')
        assert.is_truthy(text:find('    back="Alaunus\'s Cape",', 1, true))
        assert.is_nil(text:find('augments', 1, true))
    end)

    it('writes only the pieces that have augments with onlyaugmented', function()
        local gs = boot()
        assert.matches('(only augmented items)', export(gs, 'onlyaugmented file aug')[1], 1, true)
        local lines = {}
        for _, line in ipairs(lines_of(exported(gs, 'Testy_aug.lua'))) do
            if line ~= '' then
                lines[#lines + 1] = line
            end
        end
        assert.same({'sets.exported = {', worn_lines[15], '}'}, lines)
    end)

    it('refuses noaugments with onlyaugmented', function()
        local gs = boot()
        assert.same({'GearSwap: Cannot export: "noaugments" and "onlyaugmented" are mutually exclusive.'},
            export(gs, 'noaugments onlyaugmented file never'))
        assert.is_false(written(gs, 'Testy_never.lua'))
    end)

    it('writes four slots to a line with compact', function()
        local gs = boot()
        assert.matches('in compact format', export(gs, 'compact file compact')[1], 1, true)
        assert.same({
            'sets.exported = {',
            '    main="Daybreak", sub="Ammurapi Shield", ammo="Staunch Tathlum +1",',
            '    head="Nyame Helm", neck="Loricate Torque +1", left_ear="Etiolation Earring", right_ear="Loquac. Earring",',
            '    body="Nyame Mail", hands="Nyame Gauntlets", left_ring="Defending Ring", right_ring="Stikini Ring +1",',
            '    back={ name="Alaunus\'s Cape", augments={\'MND+20\',\'Enmity+10\',}}, waist="Plat. Mog. Belt", legs="Nyame Flanchard", feet="Nyame Sollerets",',
            '}',
        }, lines_of(exported(gs, 'Testy_compact.lua')))
    end)

    it('writes a wiki page as a text file with bgwiki', function()
        local gs = boot()
        assert.same({'GearSwap: Exporting your currently equipped gear in BG-Wiki Template format as a text file.'},
            export(gs, 'bgwiki file wiki'))
        local lines = lines_of(exported(gs, 'Testy_wiki.txt'))
        assert.equal('{{Guide Equipment Set', lines[1])
        assert.equal('|Set Name=Exported', lines[5])
        assert.matches('^|Equipment Set = Exported by Testy on  %d%d%d%d%-%d%d%-%d%d %d%d%-%d%d%-%d%d$', lines[7])
        local text = table.concat(lines, '\n')
        for _, expected in ipairs({'| Main = Daybreak', '| Ear1 = Etiolation Earring', '| Ear2 = Loquac. Earring',
            '| Ring1 = Defending Ring', '| Ring2 = Stikini Ring +1', "| Back = Alaunus's Cape",
            "| BackAug = 'MND+20','Enmity+10',"}) do
            assert.is_truthy(text:find(expected, 1, true), expected)
        end
    end)

    it('names the set in the wiki page when it is given a name for it', function()
        local gs = boot()
        export(gs, 'bgwiki name Wiki file wikinamed')
        local lines = lines_of(exported(gs, 'Testy_wikinamed.txt'))
        assert.same({'|Set Name=Wiki', '|CaptionTop = Wiki'}, {lines[5], lines[9]})
    end)

    it('puts the set in the clipboard with copy, and writes no file', function()
        local gs = boot()
        local copied
        gs.game.windower.copy_to_clipboard = function(text) copied = text end
        local before = {}
        for entry in lfs.dir(folder(gs)) do
            before[entry] = true
        end
        assert.same({'GearSwap: Exporting your currently equipped gear to clipboard.'}, export(gs, 'copy'))
        assert.equal('sets.exported = {\n' .. table.concat(worn_lines, '\n') .. '\n}', copied)
        for entry in lfs.dir(folder(gs)) do
            assert.is_true(before[entry], entry .. ' was written')
        end
    end)

    it('says so when it is given file with no name', function()
        local gs = boot()
        assert.same({'GearSwap: Cannot export to named file because a filename was not provided.'}, export(gs, 'file'))
    end)

    it('says so when it is given name with no name', function()
        local gs = boot()
        assert.same({'GearSwap: Cannot export to named set because a set name was not provided.'}, export(gs, 'name'))
    end)

    it('takes its flags in any case, and the file and set names by their short names: f and n', function()
        local gs = boot()
        export(gs, 'f Short n Brief MINIFY')
        local text = exported(gs, 'Testy_Short.lua')
        assert.equal('sets["Brief"] = {', text:sub(1, 17))
        assert.is_nil(text:find('\n', 1, true))
    end)

    it('names a second export of the same name by the time too, and writes over the first with overwrite', function()
        local gs = boot()
        local second = 'Testy_twice ' .. gs.game.clock .. '.lua'
        export(gs, 'file twice')
        export(gs, 'file twice')
        assert.is_true(written(gs, 'Testy_twice.lua'))
        assert.is_true(written(gs, second))
        os.remove(folder(gs) .. second)
        assert.matches('Will overwrite existing files with same name.', export(gs, 'file twice overwrite')[1], 1, true)
        assert.is_false(written(gs, second))
        os.remove(folder(gs) .. 'Testy_twice.lua')
    end)

    it('makes the folder it writes to when there is none', function()
        local gs = boot()
        for entry in lfs.dir(folder(gs)) do
            if entry ~= '.' and entry ~= '..' then
                os.remove(folder(gs) .. entry)
            end
        end
        lfs.rmdir(folder(gs))
        assert.is_nil(lfs.attributes(folder(gs)))
        export(gs, 'file made')
        assert.is_true(written(gs, 'Testy_made.lua'))
        os.remove(folder(gs) .. 'Testy_made.lua')
    end)

    it('says there is nothing to export when nothing is worn', function()
        local gs = boot({wearing = {}})
        assert.same({'GearSwap: Exporting your currently equipped gear as a lua file. (Named: Character_empty)',
            'GearSwap: There is nothing to export.'}, export(gs, 'file empty'))
        assert.is_false(written(gs, 'Testy_empty.lua'))
    end)

    pending('refuses compact with bgwiki: the check for it is given only compact, so it never counts two')
    pending('refuses two of a file name, copy, mainjob and mainsubjob together: the check counts what it filters with #, '
        .. 'which finds none in a list that starts with false (and a file name is a string it never counts)')
    pending('writes a compact set of the items of the inventory, the wearable pieces, all, or the sets table: for '
        .. 'items with no ranged piece among them, item_list.range is the table library\'s range function, whose name '
        .. 'it reads and raises an error, and for the sets table it calls rekey on a table that has no such method')
end)

-- Splits an export that groups its items by bag into the lines of each bag.
local function by_bag(text)
    local bags = {}
    for name, body in text:gmatch('\n    (%w+) = {\n(.-)\n    },') do
        bags[name] = body
    end
    return bags
end

describe('gs export of the items', function()
    it('of the inventory lists the items in it, each by its slot', function()
        local gs = boot()
        assert.same({'GearSwap: Exporting your current inventory as a lua file. (Named: Character_inv)'}, export(gs, 'inventory file inv'))
        local text = exported(gs, 'Testy_inv.lua')
        for _, expected in ipairs({'    head="Nyame Helm",', '    head="Bunzi\'s Hat",', '    head="Kaykaus Mitra +1",',
            '    body="Nyame Mail",', '    neck="Loricate Torque +1",', '    back={ name="Alaunus\'s Cape", augments={\'MND+20\',\'Enmity+10\',}},'}) do
            assert.is_truthy(text:find(expected, 1, true), expected)
        end
        assert.is_nil(text:find('Kishar Ring', 1, true), 'a piece in a wardrobe is not in the inventory')
    end)

    it('of inv is the same as of inventory, and of i', function()
        local gs = boot()
        export(gs, 'inventory file a')
        export(gs, 'inv file b')
        export(gs, 'i file c')
        local text = exported(gs, 'Testy_a.lua')
        assert.equal(text, exported(gs, 'Testy_b.lua'))
        assert.equal(text, exported(gs, 'Testy_c.lua'))
    end)

    it('of the wearable ones lists what is in the inventory and the wardrobes', function()
        local gs = boot()
        assert.same({'GearSwap: Exporting all your items in inventory and wardrobes as a lua file. (Named: Character_wear)'},
            export(gs, 'wearable file wear'))
        local text = exported(gs, 'Testy_wear.lua')
        assert.is_truthy(text:find('"Kishar Ring"', 1, true))
        assert.is_truthy(text:find('"Stikini Ring +1"', 1, true))
        assert.is_truthy(text:find('"Nyame Helm"', 1, true))
    end)

    it('of all groups them by bag', function()
        local gs = boot()
        assert.same({'GearSwap: Exporting all your items, grouped by bag and storage slip, as a lua file. (Named: Character_everything)'},
            export(gs, 'all file everything'))
        local bags = by_bag(exported(gs, 'Testy_everything.lua'))
        assert.is_truthy(bags.inventory:find('"Nyame Helm"', 1, true))
        assert.is_truthy(bags.wardrobe:find('"Stikini Ring +1"', 1, true))
        assert.is_truthy(bags.wardrobe2:find('"Kishar Ring"', 1, true))
        assert.is_nil(bags.inventory:find('Kishar', 1, true))
        assert.is_nil(bags.safe, 'a bag with nothing in it is left out')
    end)

    it('of all with the items in a safe puts them under the safe', function()
        local gs = boot()
        gs:send(0x020, {['Count'] = 1, ['Item'] = 21621, ['Bag'] = 1, ['Index'] = 1})
        export(gs, 'all file safe')
        local bags = by_bag(exported(gs, 'Testy_safe.lua'))
        assert.is_truthy(bags.safe:find('"Naegling"', 1, true))
    end)

    it('of all with noaugments leaves out the augments', function()
        local gs = boot()
        export(gs, 'all noaugments file noaug')
        assert.is_nil(exported(gs, 'Testy_noaug.lua'):find('augments', 1, true))
    end)

    it('of all with onlyaugmented lists only what has them', function()
        local gs = boot()
        export(gs, 'all onlyaugmented file onlyaug')
        local bags = by_bag(exported(gs, 'Testy_onlyaug.lua'))
        assert.equal('        back={ name="Alaunus\'s Cape", augments={\'MND+20\',\'Enmity+10\',}},', bags.inventory)
        assert.is_nil(bags.wardrobe)
    end)
end)

describe('gs export of the sets', function()
    local function names_in(text)
        local names = {}
        for name in text:gmatch('="(.-)"') do
            names[#names + 1] = name
        end
        table.sort(names)
        return names
    end

    it('lists each piece the sets name once, whichever set names it', function()
        local gs = boot()
        assert.same({'GearSwap: Exporting your current sets table as a lua file. (Named: Character_sets)'}, export(gs, 'sets file sets'))
        assert.same({"Alaunus's Cape", 'Ammurapi Shield', "Bunzi's Hat", "Bunzi's Rod", 'Daybreak', 'Defending Ring', 'Etiolation Earring',
            'Kaykaus Mitra +1', 'Kishar Ring', 'Loquac. Earring', 'Loricate Torque +1', 'Nyame Flanchard',
            'Nyame Gauntlets', 'Nyame Helm', 'Nyame Mail', 'Nyame Sollerets', 'Plat. Mog. Belt', 'Staunch Tathlum +1',
            'Stikini Ring +1'}, names_in(exported(gs, 'Testy_sets.lua')))
    end)

    it('is also gs export set, and s', function()
        local gs = boot()
        export(gs, 'set file a')
        export(gs, 's file b')
        assert.equal(exported(gs, 'Testy_a.lua'), exported(gs, 'Testy_b.lua'))
    end)

    it('writes a piece with the augments the set gives it', function()
        local gs = boot()
        gs.user.sets.cape = {back = {name = "Sucellos's Cape", augments = {'INT+20', 'Enmity+10'}}}
        export(gs, 'sets file sets_aug')
        assert.is_truthy(exported(gs, 'Testy_sets_aug.lua'):find('back={ name="Sucellos\'s Cape", augments={\'INT+20\',\'Enmity+10\',}},', 1, true))
    end)

    it('says so when no file is loaded', function()
        local gs = harness.boot({
            character = 'Corey', main_job = 'WHM', sub_job = 'RDM', expect_file = 'Corey_WHM.lua',
            items = {{name = 'Nyame Helm'}},
        })
        gs:change_main_job('MON')
        gs:chat_lines()
        assert.same({'GearSwap: Cannot export the sets table of the current file because there is no file loaded.'},
            export(gs, 'sets'))
    end)

    pending('writes a piece that has its augments under the key augment, a single one: unpack_names reads the augment '
        .. 'from a variable it never sets (export.lua names augment instead of tab_level.augment) and raises an error')

    pending('writes a piece the set names a bag for as the piece alone: unpack_names takes every string in a set for '
        .. 'a piece\'s name but the values augment, augments and priority, so the bag of {name = ..., bag = '
        .. '\'wardrobe2\'} is written as an item of its own, bag="wardrobe2"')
end)
