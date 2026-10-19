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

-- An action each job types, Savage Blade unless named.
local actions = {
    BLU = {'/ma', 'Subduction', '<t>'},
    RDM = {'/ma', 'Refresh', '<me>'},
    THF = {'/ws', 'Rudra\'s Storm', '<t>'},
}
local default_action = {'/ws', 'Savage Blade', '<t>'}

-- The names of the actions GearSwap sent since the traffic was last asked for.
local function actions_sent(gs)
    local names = {}
    for _, entry in ipairs(gs:traffic()) do
        names[#names + 1] = entry.action
    end
    return names
end

-- The sets init_gear_sets in the gear file assigns by a plain dotted name ('precast.FC', 'idle'), each once. Only
-- the function's own statements count, those as little indented as any, so a set made only under an if, as for one
-- sub job, isn't looked for; nor is one in a comment.
local function sets_assigned(path)
    local file = assert(io.open(harness.repo .. '/' .. path, 'rb'))
    local source = '\n' .. file:read('*a') .. '\nfunction '
    file:close()
    local body = assert(source:match('\nfunction init_gear_sets%(%)(.-)\nfunction '), path .. ' has no init_gear_sets')
    body = body:gsub('%-%-%[(=*)%[.-%]%1%]', ''):gsub('%-%-[^\n]*', '')
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
            it(file.path .. ' loads and builds its sets', function()
                local action = actions[file.job] or default_action
                -- User-Globals.lua holds back a weapon skill under 1000 TP.
                local gs = harness.boot({
                    character = character, main_job = file.job, sub_job = sub_jobs[file.job] or 'WAR',
                    expect_file = file.job .. '.lua', tp = action[1] == '/ws' and 1000 or nil,
                })
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
                assert.is_true(gs:type(('%s "%s" %s'):format(unpack(action))))
                assert.same({action[2]}, actions_sent(gs))
                gs:finish_action()
                assert.same({}, errors(gs))
            end)
        end
    end
end)
