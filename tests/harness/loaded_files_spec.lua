local lfs = require('lfs')
local harness = require('harness')
local testy = require('testy')

local function lines_of(path)
    local file = io.open(path, 'rb')
    if not file then
        return nil
    end
    local lines = {}
    for line in file:lines() do
        lines[#lines + 1] = line
    end
    file:close()
    return lines
end

local function set_of(list)
    local set = {}
    for _, value in ipairs(list) do
        set[value] = true
    end
    return set
end

local function entries_of(folder)
    local entries = {}
    for entry in lfs.dir(folder) do
        if entry ~= '.' and entry ~= '..' then
            entries[#entries + 1] = entry
        end
    end
    table.sort(entries)
    return entries
end

-- Runs busted from the repo's root, as the runner does, on a spec file made for the purpose. GEARSWAP_TEST_DEPS, the
-- variable the runner names the dependency file by, is set to a file of that name in the run's temp folder; to nothing
-- when deps is the empty string; and taken out of the environment when deps is nil. Gives busted's output, the lines
-- of the dependency file, and what else the run left in the temp folder and the repo's root.
local function run(spec, deps)
    local folder = harness.temp_folder('loaded')
    local path = folder .. '/made_spec.lua'
    local file = assert(io.open(path, 'w'))
    file:write(spec)
    file:close()
    local variable = '-u GEARSWAP_TEST_DEPS'
    if deps then
        variable = 'GEARSWAP_TEST_DEPS=' .. (deps == '' and '' or ('%q'):format(folder .. '/' .. deps))
    end
    local root_before = entries_of('.')
    local pipe = assert(io.popen(('env %s TMPDIR=%q busted %q 2>&1'):format(variable, folder, path)))
    local output = pipe:read('*a')
    pipe:close()
    local written = deps and deps ~= '' and lines_of(folder .. '/' .. deps) or nil
    local left = entries_of(folder)
    for i = #left, 1, -1 do
        if left[i] == 'made_spec.lua' or left[i] == deps then
            table.remove(left, i)
        end
    end
    local added_to_root = {}
    local before = set_of(root_before)
    for _, entry in ipairs(entries_of('.')) do
        if not before[entry] then
            added_to_root[#added_to_root + 1] = entry
        end
    end
    os.remove(path)
    os.remove(folder .. '/' .. (deps or ''))
    lfs.rmdir(folder)
    return output, written, left, added_to_root
end

local boots_whm = "local harness, testy = require('harness'), require('testy')\n"
    .. "it('boots', function() harness.boot(testy.whm()) end)\n"
local boots_rdm = "local harness, testy = require('harness'), require('testy')\n"
    .. "it('boots', function() harness.boot(testy.rdm()) end)\n"

-- Boots the character in this process too. The runner's record of this spec file is made from the files this process
-- loaded, not from those of the busted runs it starts, so this fails unless every file the run wrote was loaded here
-- as well: the record then holds what the assertions on the run rest on.
local function boot_here(options, written)
    harness.boot(options)
    local loaded = set_of(harness.loaded_files())
    for _, path in ipairs(written) do
        assert.is_true(loaded[path], path .. ' was loaded by the run and not by this spec file')
    end
end

describe('the repo files a run loaded', function()
    it('are the files a boot read, named as the repo names them', function()
        harness.boot(testy.whm())
        local loaded = set_of(harness.loaded_files())
        assert.is_true(loaded['gearswap.lua'])
        assert.is_true(loaded['tests/fixture/data/Testy/Testy_WHM.lua'])
        assert.is_true(loaded['docs/windower/libs/strings.lua'])
    end)

    it('are also the files the addon opened to read or read the lines of, and not one it wrote or could not find', function()
        local gs = harness.boot(testy.whm())
        local folder = gs.env.windower.addon_path
        local text, xml = 'libs/Mote-documentation.txt', 'libs/Snaps-RngHelper_Settings.xml'
        local loaded = set_of(harness.loaded_files())
        assert.is_nil(loaded[text])
        assert.is_nil(loaded[xml])
        gs.env.io.open(folder .. text, 'rb'):close()
        for _ in gs.env.io.lines(folder .. xml) do
            break
        end
        loaded = set_of(harness.loaded_files())
        assert.is_true(loaded[text])
        assert.is_true(loaded[xml])
        local count = #harness.loaded_files()
        assert.is_nil(gs.env.io.open(folder .. 'libs/No-such-file.lua', 'rb'))
        gs.env.io.open(folder .. 'data/written-by-the-addon.txt', 'w'):close()
        assert.equal(count, #harness.loaded_files())
    end)

    it('are written, a path to a line, to the file GEARSWAP_TEST_DEPS names as busted exits', function()
        local output, written = run(boots_whm, 'deps.txt')
        assert.is_table(written, output)
        local loaded = set_of(written)
        assert.is_true(loaded['gearswap.lua'])
        assert.is_true(loaded['tests/fixture/data/Testy/Testy_WHM.lua'])
        assert.is_nil(loaded['data/RDM.lua'])
        assert.is_nil(loaded['tests/fixture/data/Testy/Testy_Rdm_Gear.lua'])
    end)

    it('hold a Sel character\'s job file and gear file, and not those of another job', function()
        local output, written = run(boots_rdm, 'deps.txt')
        assert.is_table(written, output)
        boot_here(testy.rdm(), written)
        local loaded = set_of(written)
        assert.is_true(loaded['data/RDM.lua'])
        assert.is_true(loaded['libs/Sel-Include.lua'])
        assert.is_true(loaded['tests/fixture/data/Testy/Testy_Rdm_Gear.lua'])
        assert.is_nil(loaded['data/WHM.lua'])
        assert.is_nil(loaded['tests/fixture/data/Testy/Testy_WHM.lua'])
    end)

    it('are listed once each, in order, and none by a path in the copy of the Windower install', function()
        local output, written = run(boots_rdm, 'deps.txt')
        assert.is_table(written, output)
        boot_here(testy.rdm(), written)
        local sorted = {}
        for i, path in ipairs(written) do
            sorted[i] = path
            assert.is_nil(path:find('^/'), path)
        end
        table.sort(sorted)
        assert.same(sorted, written)
        for i = 2, #written do
            assert.is_not.equal(written[i - 1], written[i])
        end
    end)

    it('are written for a spec that boots nothing as a file with no line, which tells the runner it from a run that '
        .. 'never got to exit', function()
        local output, written = run("it('does nothing', function() end)\n", 'deps.txt')
        assert.same({}, written, output)
    end)

    for _, case in ipairs({{name = 'not set'}, {name = 'empty', setting = ''}}) do
        it('are written nowhere when the variable is ' .. case.name, function()
            local output, _, left, added_to_root = run(boots_whm, case.setting)
            assert.is_truthy(output:find('1 success', 1, true), output)
            assert.same({}, left, output)
            assert.same({}, added_to_root, output)
        end)
    end
end)
