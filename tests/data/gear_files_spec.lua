local lfs = require('lfs')
local harness = require('harness')

-- The characters, as the launcher's data checks find them: each folder under data/ that holds the character's
-- notes or gear list.
local function characters()
    local data = harness.repo .. '/data'
    local found = {}
    for name in lfs.dir(data) do
        if name ~= '.' and name ~= '..' and lfs.attributes(data .. '/' .. name, 'mode') == 'directory'
            and (lfs.attributes(('%s/%s/%s_notes.md'):format(data, name, name))
                or lfs.attributes(('%s/%s/%s_gear_list.md'):format(data, name, name))) then
            found[#found + 1] = name
        end
    end
    table.sort(found)
    return found
end

-- A character's Sel gear files, <Character>_<Job>_Gear.lua, with the job each is for.
local function gear_files(character)
    local folder = ('%s/data/%s'):format(harness.repo, character)
    local found = {}
    for name in lfs.dir(folder) do
        local who, job = name:match('^([^_]+)_(%a%a%a)_[Gg]ear%.lua$')
        if who and who:lower() == character:lower() then
            found[#found + 1] = {path = ('data/%s/%s'):format(character, name), job = job:upper()}
        end
    end
    table.sort(found, function(a, b) return a.path < b.path end)
    return found
end

-- The sub job each job plays, WAR unless named.
local sub_jobs = {RDM = 'WHM', WAR = 'WHM'}

-- A spell each job casts. One not named uses the first weapon skill the game lists for the weapons in hand.
local spells = {
    BLU = {'/ma', 'Subduction', '<t>'},
    RDM = {'/ma', 'Refresh', '<me>'},
}

-- Whether the test resources hold an item of that name, as the game can make no other.
local function known_item(gs, name)
    for _, item in pairs(gs.game.res.items) do
        if type(item) == 'table' and item.en and item.en:lower() == name:lower() then
            return true
        end
    end
    return false
end

-- The pieces that decide which weapon skills the game lists, main and range, of the weapon set the gear file starts
-- in (sets.weapons, by state.Weapons as the file loads), those the test resources hold, by slot. None when it starts
-- with no weapon set, and the hands are empty.
local function starting_weapons(gs)
    local set = gs.user.state.Weapons and gs.user.sets.weapons[gs.user.state.Weapons.value]
    local held = {}
    for _, slot in ipairs({'main', 'range'}) do
        local piece = type(set) == 'table' and set[slot]
        local name = type(piece) == 'table' and piece.name or piece
        if type(name) == 'string' and known_item(gs, name) then
            held[slot] = name
        end
    end
    return held
end

-- The sets init_gear_sets in the gear file assigns by a plain dotted name ('precast.FC', 'idle'), each once. Only
-- the function's own statements count, those as little indented as any, so a set made only under an if, as for one
-- sub job, isn't looked for; nor is one in a comment.
local function sets_assigned(path)
    local file = assert(io.open(harness.repo .. '/' .. path, 'rb'))
    local source = '\n' .. file:read('*a') .. '\nfunction '
    file:close()
    -- The function ends at the first end at the start of a line; those inside it are indented.
    local body = assert(source:match('\nfunction init_gear_sets%(%)(.-)\nend'), path .. ' has no init_gear_sets')
    -- ---[[ starts a line comment, not a block one, so what follows it is code.
    body = body:gsub('%-%-%-[^\n]*', ''):gsub('%-%-%[(=*)%[.-%]%1%]', ''):gsub('%-%-[^\n]*', '')
    local assignments, least = {}, math.huge
    for indent, name in body:gmatch('\n([ \t]*)sets%.([%w_%.]+)%s*=[^=]') do
        assignments[#assignments + 1] = {indent = #indent, name = name}
        least = math.min(least, #indent)
    end
    local names, seen = {}, {}
    for _, assignment in ipairs(assignments) do
        if assignment.indent == least and not seen[assignment.name] then
            seen[assignment.name] = true
            names[#names + 1] = assignment.name
        end
    end
    return names
end

-- The names of those sets that GearSwap's sets don't hold a table for.
local function missing_sets(sets, names)
    local missing = {}
    for _, name in ipairs(names) do
        local set = sets
        for part in name:gmatch('[^%.]+') do
            set = type(set) == 'table' and set[part] or nil
        end
        if type(set) ~= 'table' then
            missing[#missing + 1] = name
        end
    end
    return missing
end

-- What GearSwap printed or put in the chat that reads as an error. Sel's notices of optional files it found
-- missing say they are not errors.
local function errors(gs)
    local found = {}
    for line in gs:log():gmatch('[^\n]+') do
        if not line:find('this is not an error', 1, true)
            and (line:lower():find('error') or line:find('attempt to') or line:find('traceback')
                or line:find('%.lua:%d+:')) then
            found[#found + 1] = line
        end
    end
    return found
end

describe('the gear file', function()
    -- Without this, a change to how characters or gear files are found could leave nothing tested, and pass.
    it('finder finds at least one character\'s gear file', function()
        local found = 0
        for _, character in ipairs(characters()) do
            found = found + #gear_files(character)
        end
        assert.is_true(found > 0)
    end)

    for _, character in ipairs(characters()) do
        for _, file in ipairs(gear_files(character)) do
            it(file.path .. ' loads, builds its sets and gets through a status change and an action without an '
                .. 'error', function()
                local spell = spells[file.job]
                local function boot(weapons)
                    local items = {}
                    for _, name in pairs(weapons) do
                        items[#items + 1] = {name = name}
                    end
                    -- User-Globals.lua holds back a weapon skill under 1000 TP.
                    return harness.boot({
                        character = character, main_job = file.job, sub_job = sub_jobs[file.job] or 'WAR',
                        expect_file = file.job .. '.lua', tp = not spell and 1000 or nil, items = items,
                        wearing = weapons,
                    })
                end
                local gs = boot(starting_weapons(boot({})))
                assert.same({}, errors(gs))
                local defined_in = debug.getinfo(gs.user.init_gear_sets, 'S').source
                assert.equal(file.path, harness.repo_paths(defined_in:sub(2)))
                assert.is_table(gs.user.sets.idle)
                assert.is_table(gs.user.sets.precast)
                local names = sets_assigned(file.path)
                assert.is_true(#names > 0)
                assert.same({}, missing_sets(gs.user.sets, names))

                gs:console('gs c update')
                gs:engage()
                gs:disengage()
                gs:traffic()
                local action = spell
                if not action then
                    local in_hand = assert(gs.game:weapon_skills_in_hand()[1],
                        'the test resources hold no weapon skill of the weapons in hand')
                    action = {'/ws', gs.game.res.weapon_skills[in_hand].en, '<t>'}
                end
                assert.is_true(gs:type(('%s "%s" %s'):format(unpack(action))))
                assert.same({action[2]}, gs:actions())
                gs:finish_action()
                assert.same({}, errors(gs))
            end)
        end
    end
end)
