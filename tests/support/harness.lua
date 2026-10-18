-------------------------------------------------------------------------------------------------------------------
-- Boots GearSwap for a test, as Windower loads an addon, on the stand-in game in game.lua.
--
-- Each boot gets a Lua environment of its own, as each Windower addon gets a Lua state of its own: GearSwap's
-- globals, the libraries it requires and the user file it loads live there and nowhere else, so one test can't see
-- what another left behind. The standard libraries GearSwap or Windower's libraries change are copies (table, math,
-- os, io, coroutine), except string: Windower's string functions have to land on the string table that strings'
-- methods come from.
--
-- GearSwap reads its files from a copy of a Windower install that this module builds in the temp folder once per
-- run: the repo's GearSwap (its Lua, libs/ and data/, with the fixture characters' files from tests/fixture/data
-- added to data/), Windower's own libraries from docs/windower/libs and the test resources from tests/fixture/res.
-- What GearSwap or Sel write while a test runs lands in that copy, never in the repo. Paths in an error are given
-- back as the repo's.
-------------------------------------------------------------------------------------------------------------------

local lfs = require('lfs')
local Game = require('game')
local dialect = require('dialect')

local harness = {}

local real = {loadfile = loadfile, coroutine = coroutine, os = os, io = io}

local function repo_root()
    local source = debug.getinfo(1, 'S').source:sub(2):gsub('\\', '/')
    local folder = source:match('^(.*)/tests/support/[^/]+$')
    if folder == nil or folder == '' then
        folder = '.'
    end
    return folder
end

harness.repo = repo_root()

local function join(...)
    return (table.concat({...}, '/'):gsub('//+', '/'))
end

local function is_directory(path)
    return lfs.attributes(path, 'mode') == 'directory'
end

local function make_folders(path)
    local built = path:sub(1, 1) == '/' and '' or '.'
    for part in path:gmatch('[^/]+') do
        built = built .. '/' .. part
        if not lfs.attributes(built) then
            assert(lfs.mkdir(built))
        end
    end
end

local function copy_file(from, to)
    local source = assert(io.open(from, 'rb'))
    local content = source:read('*a')
    source:close()
    local target = assert(io.open(to, 'wb'))
    target:write(content)
    target:close()
end

-- Copies the files under a folder whose names the filter accepts, keeping the folders between.
local function copy_tree(from, to, accept)
    make_folders(to)
    for entry in lfs.dir(from) do
        if entry ~= '.' and entry ~= '..' then
            local path = join(from, entry)
            if is_directory(path) then
                copy_tree(path, join(to, entry), accept)
            elseif not accept or accept(entry) then
                copy_file(path, join(to, entry))
            end
        end
    end
end

local function remove_tree(path)
    if not lfs.attributes(path) then
        return
    end
    if is_directory(path) then
        for entry in lfs.dir(path) do
            if entry ~= '.' and entry ~= '..' then
                remove_tree(join(path, entry))
            end
        end
        lfs.rmdir(path)
    else
        os.remove(path)
    end
end

local function temp_folder()
    local base = (os.getenv('TMPDIR') or os.getenv('TEMP') or os.getenv('TMP') or '/tmp'):gsub('\\', '/')
    math.randomseed(os.time() + math.floor(os.clock() * 1000000))
    for _ = 1, 100 do
        local path = join(base, ('gearswap-tests-%08x'):format(math.random(0, 0x7FFFFFFF)))
        if not lfs.attributes(path) and lfs.mkdir(path) then
            return path
        end
    end
    error('could not make a temp folder for the Windower install in ' .. base)
end

local tree

-- The temp folders of the copies this run made. busted loads this module again for each spec file, so the list is
-- kept in the Lua registry, which every copy of the module shares, for the cleanup at the end to find them all.
local function made_trees()
    local registry = debug.getregistry()
    registry.gearswap_test_trees = registry.gearswap_test_trees or {}
    return registry.gearswap_test_trees
end

-- The copy of a Windower install GearSwap runs from, made on first use.
function harness.tree()
    if tree then
        return tree
    end
    local root = temp_folder()
    table.insert(made_trees(), root)
    local windower = join(root, 'Windower') .. '/'
    local addon = join(root, 'Windower', 'addons', 'GearSwap') .. '/'
    local repo = harness.repo
    local libs = join(repo, 'docs', 'windower', 'libs')
    assert(is_directory(libs), 'Windower\'s Lua libraries aren\'t in docs/windower/libs. Run: dotnet run .claude/gear.cs -- windower-libs')
    copy_tree(libs, join(windower, 'addons', 'libs'))
    copy_tree(join(repo, 'tests', 'fixture', 'res'), join(windower, 'res'))
    make_folders(addon)
    for entry in lfs.dir(repo) do
        if entry:match('%.lua$') then
            copy_file(join(repo, entry), join(addon, entry))
        end
    end
    copy_tree(join(repo, 'libs'), join(addon, 'libs'))
    copy_tree(join(repo, 'data'), join(addon, 'data'), function(name) return name:match('%.lua$') end)
    copy_tree(join(repo, 'tests', 'fixture', 'data'), join(addon, 'data'))
    tree = {
        root = root,
        windower = windower,
        addon = addon,
        -- Where each part of the copy came from, the more specific first.
        sources = {
            {join(addon, 'data', 'Testy') .. '/', 'tests/fixture/data/Testy/'},
            {join(windower, 'addons', 'libs') .. '/', 'docs/windower/libs/'},
            {join(windower, 'res') .. '/', 'tests/fixture/res/'},
            {addon, ''},
        },
    }
    return tree
end

-- Removes every copy of the Windower install this run made.
function harness.cleanup()
    local trees = made_trees()
    while #trees > 0 do
        remove_tree(table.remove(trees))
    end
    tree = nil
end

-- The repo's own path for each path into the copy that the text mentions.
function harness.repo_paths(text)
    if not tree or type(text) ~= 'string' then
        return text
    end
    for _, source in ipairs(tree.sources) do
        local escaped = source[1]:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%0')
        text = text:gsub(escaped, (source[2]:gsub('%%', '%%%%')))
    end
    return text
end

local resources

-- The test resources as Windower's resource files hold them, read once.
function harness.resources()
    if resources then
        return resources
    end
    resources = {}
    local folder = join(harness.repo, 'tests', 'fixture', 'res')
    for entry in lfs.dir(folder) do
        local name = entry:match('^(.*)%.lua$')
        if name then
            resources[name] = assert(real.loadfile(join(folder, entry)))()
        end
    end
    return resources
end

-------------------------------------------------------------------------------------------------------------------
-- The Lua environment of one addon.
-------------------------------------------------------------------------------------------------------------------

local function shallow_copy(t)
    local result = {}
    for k, v in pairs(t) do
        result[k] = v
    end
    return result
end

local support_folder = join(harness.repo, 'tests', 'support')

-- Modules Windower has in C, and so the test runner's Lua lacks: these stand in for them.
local function stand_in(env, name)
    if name == 'pack' then
        local chunk = assert(real.loadfile(join(support_folder, 'pack.lua')))
        return chunk()
    elseif name == 'bit' then
        return env.bit
    elseif name == 'socket' then
        return {gettime = function() return env.os.clock() end, sleep = function() end}
    elseif name == 'mime' then
        return {}
    end
end

function harness.environment(game, paths)
    local env = {}
    local loaded = {}
    local search = {paths.addon .. '?.lua', paths.addon .. 'libs/?.lua', paths.windower .. 'addons/libs/?.lua'}

    for _, name in ipairs({'assert', 'collectgarbage', 'error', 'getfenv', 'getmetatable', 'ipairs', 'load', 'next',
        'pairs', 'pcall', 'rawequal', 'rawget', 'rawset', 'select', 'setfenv', 'setmetatable', 'tonumber',
        'tostring', 'type', 'unpack', 'xpcall', '_VERSION', 'newproxy', 'gcinfo', 'module'}) do
        env[name] = _G[name]
    end
    env._G = env
    env.string = string
    env.debug = debug
    env.table = shallow_copy(table)
    env.math = shallow_copy(math)
    env.bit = assert(real.loadfile(join(support_folder, 'bit.lua')))()
    env.windower = game.windower
    env.printed = {}
    env.print = function(...)
        local parts = {}
        for i = 1, select('#', ...) do
            parts[i] = tostring(select(i, ...))
        end
        env.printed[#env.printed + 1] = table.concat(parts, ' ')
    end

    -- Chunks loaded through these run with this environment as their globals, as they would in the addon's state.
    env.loadfile = function(path)
        local resolved = path and Game.resolve(path)
        if not resolved then
            return nil, 'cannot open ' .. tostring(path)
        end
        local chunk, problem = dialect.load(resolved)
        if chunk then
            setfenv(chunk, env)
        end
        return chunk, problem
    end
    env.loadstring = function(text, name)
        local chunk, problem = loadstring(text, name)
        if chunk then
            setfenv(chunk, env)
        end
        return chunk, problem
    end
    env.dofile = function(path)
        local chunk = assert(env.loadfile(path))
        return chunk()
    end

    env.io = shallow_copy(io)
    env.io.open = function(path, mode)
        if mode and mode:find('[wa]') then
            return real.io.open(path, mode)
        end
        local resolved = Game.resolve(path)
        if not resolved then
            return nil, path .. ': No such file or directory'
        end
        return real.io.open(resolved, mode)
    end
    env.io.lines = function(path)
        return real.io.lines(path and Game.resolve(path) or path)
    end

    local epoch = 1760000000
    env.os = shallow_copy(os)
    env.os.clock = function() return game.clock end
    env.os.time = function(when)
        if when then
            return real.os.time(when)
        end
        return epoch + math.floor(game.clock)
    end
    env.os.exit = function() error('the addon called os.exit', 2) end

    env.coroutine = shallow_copy(coroutine)
    env.coroutine.schedule = function(fn, delay, ...) return game:schedule(fn, delay, ...) end
    env.coroutine.sleep = function(seconds) return real.coroutine.yield(seconds) end
    env.coroutine.close = function(co) game:cancel(co) end

    env.package = {loaded = loaded, preload = {}, path = table.concat(search, ';'), cpath = '', loaders = {}}
    for _, name in ipairs({'string', 'table', 'math', 'os', 'io', 'coroutine', 'debug', 'bit'}) do
        loaded[name] = env[name]
    end
    loaded._G = env

    env.require = function(name)
        if loaded[name] ~= nil then
            return loaded[name]
        end
        local module = stand_in(env, name)
        if module == nil then
            local file = name:gsub('%.', '/')
            local chunk
            for _, pattern in ipairs(search) do
                local path = Game.resolve((pattern:gsub('%?', file)))
                if path then
                    chunk = assert(dialect.load(path))
                    break
                end
            end
            if not chunk then
                error(('module %q not found in the Windower install the tests run on'):format(name), 2)
            end
            setfenv(chunk, env)
            module = chunk(name)
        end
        if loaded[name] == nil then
            loaded[name] = module == nil and true or module
        end
        return loaded[name]
    end

    return env
end

-------------------------------------------------------------------------------------------------------------------
-- Augments, as the export prints them, written into an item's extdata.
-------------------------------------------------------------------------------------------------------------------

local augment_codes = {}
local augment_tools

-- The extdata of a piece with these system 1 augments (the kind on most augmented gear), at most five of them.
function harness.extdata(augments)
    if not augment_tools then
        local game = Game.new({res = harness.resources(), paths = {addon = harness.tree().addon, windower = harness.tree().windower}})
        local env = harness.environment(game, {addon = harness.tree().addon, windower = harness.tree().windower})
        env._addon = {name = 'augments', language = 'english'}
        env.require('extdata')
        augment_tools = env.tools.aug
    end
    assert(#augments <= 5, 'a piece has at most five augments')
    local bytes = {2, 3}
    for _, augment in ipairs(augments) do
        local code = augment_codes[augment]
        if not code then
            for id = 1, 0x7FF do
                for value = 0, 31 do
                    if augment_tools.string_augment(1, id, value) == augment then
                        code = {id, value}
                        break
                    end
                end
                if code then
                    break
                end
            end
            augment_codes[augment] = assert(code, ('no system 1 augment reads %q'):format(augment))
        end
        bytes[#bytes + 1] = code[1] % 256
        bytes[#bytes + 1] = math.floor(code[1] / 256) + 8 * code[2]
    end
    local data = string.char(unpack(bytes))
    return data .. string.char(0):rep(24 - #data)
end

-------------------------------------------------------------------------------------------------------------------
-- A booted GearSwap and the game it plays.
-------------------------------------------------------------------------------------------------------------------

local Session = {}
Session.__index = Session

local action_names = {[3] = 'spells', [7] = 'weapon_skills', [9] = 'job_abilities', [25] = 'monster_skills'}
-- The category of the action packet that ends an action, by the category of the request that began it.
local finishing_category = {[3] = 4, [7] = 3, [9] = 6, [16] = 2, [25] = 11}
-- The category of the action packet that begins one, which an interruption comes in.
local beginning_category = {[3] = 8, [7] = 7, [16] = 12}

-- options, all of them optional:
--   character      the character's name, Testy unless given
--   main_job, sub_job, main_job_level, sub_job_level
--   items          {name=, bag=, augments=} for each piece the character has; bag is the API name ('wardrobe2')
--   wearing        slot name to the name of an item in items, worn when GearSwap loads
--   buffs          the names of the buffs up when GearSwap loads
--   spells, abilities   the names the character knows; every one the test resources hold unless given
--   expect_file    the user file GearSwap should load, by its name in data/
function harness.boot(options)
    options = options or {}
    local paths = harness.tree()
    local res = harness.resources()

    local items, wearing = {}, {}
    for i, item in ipairs(options.items or {}) do
        items[i] = {name = item.name, bag = item.bag, count = item.count, extdata = item.augments and harness.extdata(item.augments)}
    end
    for slot, name in pairs(options.wearing or {}) do
        for i, item in ipairs(options.items or {}) do
            if item.name == name then
                wearing[slot] = i
                break
            end
        end
        assert(wearing[slot], ('%s is worn but not among the items'):format(name))
    end

    local game = Game.new({
        res = res, paths = {addon = paths.addon, windower = paths.windower},
        name = options.character or 'Testy',
        main_job = options.main_job or 'WHM', sub_job = options.sub_job or 'RDM',
        main_job_level = options.main_job_level, sub_job_level = options.sub_job_level,
        items = items, wearing = wearing, buffs = options.buffs,
        spells = options.spells, abilities = options.abilities and (function()
            local known = {}
            for _, name in ipairs(options.abilities) do known[name] = true end
            return known
        end)(),
    })
    local env = harness.environment(game, paths)
    game.invoke = function(name, ...)
        local fn = env[name]
        assert(type(fn) == 'function', ('lua i gearswap %s: GearSwap has no such function'):format(tostring(name)))
        return fn(...)
    end

    local session = setmetatable({game = game, env = env, seen = 0}, Session)
    -- Windower hands each addon this table to describe itself in.
    env._addon = {}
    session:run(function()
        local chunk = assert(env.loadfile(paths.addon .. 'gearswap.lua'))
        chunk()
        game:fire('load')
        game:send_buffs()
        game:settle()
    end)
    if not env.user_env then
        error('GearSwap loaded no user file. It printed:\n' .. harness.repo_paths(table.concat(env.printed, '\n')), 2)
    end
    if options.expect_file and env.current_file ~= options.expect_file then
        error(('GearSwap loaded %s, not %s'):format(tostring(env.current_file), options.expect_file), 2)
    end
    session.user = env.user_env
    session.seen = #game.sent
    return session
end

-- Runs fn, and gives any error it raises the repo's paths.
function Session:run(fn, ...)
    local results = {xpcall(fn, debug.traceback, ...)}
    if not results[1] then
        error(harness.repo_paths(results[2]), 0)
    end
    return unpack(results, 2)
end

-- Types a line into the chat, as the player does, and lets the game catch up.
function Session:type(line)
    return self:run(function()
        local result = self.game:input(line)
        self.game:settle()
        return result
    end)
end

-- Runs a line in Windower's console: 'gs c cycle IdleMode', 'gs equip sets.idle'.
function Session:console(line)
    self:run(function()
        self.game:run_command(line)
        self.game:settle()
    end)
end

function Session:advance(seconds)
    self:run(function() self.game:advance(seconds) end)
end

-- The name of the item in each slot, by Windower's slot names.
function Session:worn()
    return self.game:worn()
end

-- What GearSwap printed and put in the chat log, and the commands it ran, a line each.
function Session:log()
    local lines = {}
    for _, line in ipairs(self.env.printed) do
        lines[#lines + 1] = 'print: ' .. line
    end
    for _, entry in ipairs(self.game.chat_log) do
        lines[#lines + 1] = ('chat %s: %s'):format(tostring(entry.color), tostring(entry.text))
    end
    for _, command in ipairs(self.game.commands) do
        lines[#lines + 1] = 'command: ' .. command
    end
    for _, text in ipairs(self.game.typed) do
        lines[#lines + 1] = 'typed: ' .. text
    end
    return harness.repo_paths(table.concat(lines, '\n'))
end

-- What GearSwap sent since this was last asked, in order: {equip = {slot = item}} for each run of equip requests,
-- with 'empty' for a slot it emptied, and {action = name, target = name} for each action.
function Session:traffic()
    local traffic = {}
    local game = self.game
    for i = self.seen + 1, #game.sent do
        local packet = game.sent[i]
        if packet.id == 0x050 or packet.id == 0x051 then
            local last = traffic[#traffic]
            if not (last and last.equip) then
                last = {equip = {}}
                traffic[#traffic + 1] = last
            end
            for slot, item in pairs(game:equip_request(packet)) do
                last.equip[slot] = item
            end
        elseif packet.action then
            traffic[#traffic + 1] = self:describe(packet.action)
        end
    end
    self.seen = #game.sent
    return traffic
end

function Session:describe(action)
    local res = harness.resources()
    local resource = res[action_names[action.category] or '']
    local target = self.game:mob_by_id(action.target_id)
    return {
        action = resource and resource[action.param] and resource[action.param].en or ('category %d'):format(action.category),
        target = target and target.name,
    }
end

-- Answers the last action GearSwap sent with the packet the server sends when it is done.
function Session:finish_action(fields)
    fields = fields or {}
    local action = assert(self.game.actions[#self.game.actions], 'GearSwap sent no action to finish')
    self:run(function()
        self.game:send_action_packet({
            category = finishing_category[action.category], param = action.param, recast = 0,
            targets = {{id = action.target_id, actions = {{message = fields.message or 0, param = fields.value or 0,
                reaction = 0, animation = 0, effect = 0, stagger = 0}}}},
        })
        self.game:settle()
    end)
end

-- Answers the last action GearSwap sent with the packet that says it was interrupted.
function Session:interrupt_action()
    local action = assert(self.game.actions[#self.game.actions], 'GearSwap sent no action to interrupt')
    self:run(function()
        self.game:send_action_packet({
            category = assert(beginning_category[action.category], 'that action can\'t be interrupted'), param = 28787,
            targets = {{id = action.target_id, actions = {{message = 0, param = action.param, reaction = 0,
                animation = 0, effect = 0, stagger = 0}}}},
        })
        self.game:settle()
    end)
end

function Session:engage()
    self:run(function()
        self.game:set_status(1)
        self.game:settle()
    end)
end

function Session:disengage()
    self:run(function()
        self.game:set_status(0)
        self.game:settle()
    end)
end

function Session:gain_buff(name)
    self:run(function()
        self.game:gain_buff(name)
        self.game:settle()
    end)
end

function Session:lose_buff(name)
    self:run(function()
        self.game:lose_buff(name)
        self.game:settle()
    end)
end

return harness
