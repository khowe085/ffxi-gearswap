-------------------------------------------------------------------------------------------------------------------
-- Boots GearSwap for a test, as Windower loads an addon, on the stand-in game in game.lua.
--
-- Each boot gets a Lua environment of its own, as each Windower addon gets a Lua state of its own: GearSwap's
-- globals, the libraries it requires and the user file it loads live there and nowhere else, so one test can't see
-- what another left behind. The standard libraries GearSwap or Windower's libraries change are copies (table, math,
-- os, io, coroutine), except string: Windower's string functions have to land on the string table that strings'
-- methods come from. That table and the metatables of strings, numbers, booleans and functions, which Windower's
-- libraries set for the whole state on top of what they found, are put back as Lua had them at each boot.
--
-- GearSwap reads its files from a copy of a Windower install that this module builds in the temp folder once per
-- spec file, as busted loads the module again for each: the repo's GearSwap (its Lua, libs/ and data/, with the
-- fixture characters' files from tests/fixture/data added to data/), Windower's own libraries from docs/windower/libs
-- and the test resources from tests/fixture/res.
-- What GearSwap or Sel write while a test runs lands in that copy, never in the repo. Paths in an error are given
-- back as the repo's.
-------------------------------------------------------------------------------------------------------------------

-- GearSwap needs setfenv and getfenv, which Lua 5.1 has and later Luas don't.
assert(_VERSION == 'Lua 5.1', ('GearSwap\'s tests run on Lua 5.1, and busted runs on %s. Install busted for 5.1: '
    .. 'luarocks --lua-version 5.1 install busted'):format(_VERSION))

local lfs = require('lfs')
local luassert = require('luassert')
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

-- Seconds after GearSwap loads a Sel file that Sel's tick first acts, that Sel sets up the weapon modes
-- (gs c weapons initialize) and that User-Globals.lua locks the style.
harness.sel_load_time = 5

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

-- A new, empty folder in the temp folder, named gearswap-<name>- and a random number.
function harness.temp_folder(name)
    local base = (os.getenv('TMPDIR') or os.getenv('TEMP') or os.getenv('TMP') or '/tmp'):gsub('\\', '/'):gsub('/+$', '')
    math.randomseed(os.time() + math.floor(os.clock() * 1000000))
    for _ = 1, 100 do
        local path = join(base, ('gearswap-%s-%08x'):format(name, math.random(0, 0x7FFFFFFF)))
        if not lfs.attributes(path) and lfs.mkdir(path) then
            return path
        end
    end
    error('could not make a temp folder in ' .. base)
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
    local root = harness.temp_folder('tests')
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
            {join(windower, 'addons', 'libs') .. '/', 'docs/windower/libs/'},
            {join(windower, 'res') .. '/', 'tests/fixture/res/'},
            {addon, ''},
        },
    }
    -- Each fixture character's folder, ahead of the addon's own, which it lies under.
    for entry in lfs.dir(join(repo, 'tests', 'fixture', 'data')) do
        if entry ~= '.' and entry ~= '..' and is_directory(join(repo, 'tests', 'fixture', 'data', entry)) then
            table.insert(tree.sources, 1, {join(addon, 'data', entry) .. '/', 'tests/fixture/data/' .. entry .. '/'})
        end
    end
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

-- The string table and the metatables of strings, numbers, booleans and functions, as Lua had them before any boot. Windower's
-- libraries change these for the whole Lua state, and each boot loads the libraries again, so each boot starts from
-- these; otherwise each would wrap the string functions the one before left. They are kept in the Lua registry, which
-- every copy of this module busted loads shares, so the ones kept are those from before the first boot.
local function as_lua_had_them()
    local registry = debug.getregistry()
    if not registry.gearswap_test_pristine then
        registry.gearswap_test_pristine = {
            string = shallow_copy(string),
            string_meta = debug.getmetatable(''),
            number_meta = debug.getmetatable(0),
            boolean_meta = debug.getmetatable(false),
            function_meta = debug.getmetatable(print),
        }
    end
    return registry.gearswap_test_pristine
end
as_lua_had_them()

local function put_back_as_lua_had_them()
    local saved = as_lua_had_them()
    for k in pairs(string) do
        if saved.string[k] == nil then
            string[k] = nil
        end
    end
    for k, v in pairs(saved.string) do
        string[k] = v
    end
    debug.setmetatable('', saved.string_meta)
    debug.setmetatable(0, saved.number_meta)
    debug.setmetatable(false, saved.boolean_meta)
    debug.setmetatable(print, saved.function_meta)
end

local support_folder = join(harness.repo, 'tests', 'support')

-- Modules Windower has in C, and so the test runner's Lua lacks: these stand in for them. bit is loaded with the
-- environment, as LuaJIT has it from the start. GearSwap requires socket and mime, and nothing calls them.
local function stand_in(name)
    if name == 'pack' then
        local chunk = assert(real.loadfile(join(support_folder, 'pack.lua')))
        return chunk()
    elseif name == 'socket' or name == 'mime' then
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
        local module = stand_in(name)
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

-- The category of the action packet that ends an action, by the category of the request that began it.
local finishing_category = {[3] = 4, [7] = 3, [9] = 6, [16] = 2, [25] = 11}
-- The category of the action packet that begins one, which an interruption comes in.
local beginning_category = {[3] = 8, [7] = 7, [16] = 12}

-- Loads GearSwap on a new game and returns the session, with what it sent, said, printed, typed and ran while loading
-- taken as read. options, all of them optional:
--   character      the character's name, Testy unless given
--   main_job, sub_job, main_job_level, sub_job_level
--   tp             the character's TP, 0 unless given
--   items          {name=, bag=, augments=} for each piece the character has; bag is the API name ('wardrobe2')
--   wearing        slot name to the name of an item in items, worn when GearSwap loads
--   buffs          the names of the buffs up when GearSwap loads
--   zone           the id of the zone the character is in, Escha - Zi'Tah (288) unless given
--   spells, abilities   the names the character knows; unless given, every spell and job ability the test resources
--                       hold, and the weapon skills of the weapons in hand (see Game:weapon_skills_in_hand)
--   merits         the character's merit levels by name, none unless given
--   pet            the fields of a pet at the character's side when GearSwap loads (see Game:place_pet)
--   expect_file    the user file GearSwap should load, by its name in data/
function harness.boot(options)
    options = options or {}
    local paths = harness.tree()
    local res = harness.resources()

    local items, wearing = {}, {}
    for i, item in ipairs(options.items or {}) do
        items[i] = {name = item.name, bag = item.bag, count = item.count, extdata = item.augments and harness.extdata(item.augments)}
    end
    -- Each slot, in the game's order, takes the first copy of its piece not worn already.
    local taken = {}
    for id = 0, 15 do
        local slot = Game.slot_names[id]
        local name = (options.wearing or {})[slot]
        if name then
            for i, item in ipairs(options.items or {}) do
                if item.name == name and not taken[i] then
                    wearing[slot], taken[i] = i, true
                    break
                end
            end
            assert(wearing[slot], ('%s is worn but not among the items'):format(name))
        end
    end
    for slot in pairs(options.wearing or {}) do
        assert(Game.slot_ids[slot], ('%s isn\'t a slot the game knows'):format(slot))
    end

    local game = Game.new({
        res = res, paths = {addon = paths.addon, windower = paths.windower},
        name = options.character or 'Testy',
        main_job = options.main_job or 'WHM', sub_job = options.sub_job or 'RDM',
        main_job_level = options.main_job_level, sub_job_level = options.sub_job_level, tp = options.tp,
        merits = options.merits,
        items = items, wearing = wearing, buffs = options.buffs,
        zone = options.zone,
        spells = options.spells, abilities = options.abilities and (function()
            local known = {}
            for _, name in ipairs(options.abilities) do known[name] = true end
            return known
        end)(),
    })
    if options.pet then
        game:place_pet(options.pet)
    end
    local env = harness.environment(game, paths)
    game.invoke = function(name, ...)
        local fn = env[name]
        assert(type(fn) == 'function', ('lua i gearswap %s: GearSwap has no such function'):format(tostring(name)))
        return fn(...)
    end

    local session = setmetatable({game = game, env = env, seen = 0, read = {}}, Session)
    -- Windower hands each addon this table to describe itself in.
    env._addon = {}
    -- After the augments are written, whose libraries change the string functions too.
    put_back_as_lua_had_them()
    session:run(function()
        local chunk = assert(env.loadfile(paths.addon .. 'gearswap.lua'))
        chunk()
        game.packets = env.packets
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
    session:forget()
    return session
end

-- Boots as harness.boot does, for a Sel character: runs before_update with the session when one is given, has Sel put
-- on the set it picks (gs c update), and takes everything so far as read.
function harness.boot_updated(options, before_update)
    local session = harness.boot(options)
    if before_update then
        before_update(session)
    end
    session:console('gs c update')
    session:forget()
    return session
end

-- Runs fn, and gives any error it raises the repo's paths.
function Session:run(fn)
    local results = {xpcall(fn, debug.traceback)}
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

-- Types a line that names its action in quotes ('/ma "Slow" <t>', '/ws "Savage Blade" <t>'), as type does, and fails
-- the test unless the actions GearSwap sent since they were last read are that action, once: none, another in its
-- place, or another besides it fails.
function Session:type_alone(line)
    local name = line:match('^/%a+ "(.-)"')
    luassert(name, 'an action is typed as /prefix "Name", not as ' .. line)
    self:type(line)
    luassert.same({name}, self:actions(), line .. ' didn\'t go out alone')
end

-- Runs a line in Windower's console: 'gs c cycle IdleMode', 'gs equip sets.idle'.
function Session:console(line)
    self:run(function()
        self.game:run_command(line)
        self.game:settle()
    end)
end

-- Moves the clock on without a frame: only timers run, so Sel's tick doesn't.
function Session:advance(seconds)
    self:run(function() self.game:advance(seconds) end)
end

-- Plays the game for a while, frame by frame, so Sel's tick runs and its automatic actions (AutoWS, AutoBuffMode
-- and the rest) can act.
function Session:play(seconds)
    self:run(function() self.game:play(seconds) end)
end

-- The name of the item in each slot, by Windower's slot names.
function Session:worn()
    return self.game:worn()
end

-- Everything GearSwap printed and put in the chat log, the commands run and the lines typed that reached the game,
-- a line each.
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

-- The readers below give what was added to one of the game's lists since that list was last read through them. They
-- keep their place in the session and leave the lists whole, for log() and for a test that reads one itself.

-- The entries of the list added since the reader called name last read it.
local function unread(session, name, list)
    local lines = {}
    for i = (session.read[name] or 0) + 1, #list do
        lines[#lines + 1] = list[i]
    end
    session.read[name] = #list
    return lines
end

-- An entry of the chat log as {color =, text =}: a line wrapped in the codes GearSwap's add_to_chat colors it with
-- gives that color and the text inside them.
function harness.chat_line(entry)
    local text = tostring(entry.text)
    local code = text:match('^\31(.)')
    return {color = code and code:byte() or entry.color, text = (text:gsub('^\31.', ''):gsub('\30\1$', ''))}
end

-- The lines put in the chat log since it was last read, each as harness.chat_line gives it.
function Session:chat_lines()
    local lines = {}
    for i, entry in ipairs(unread(self, 'chat', self.game.chat_log)) do
        lines[i] = harness.chat_line(entry)
    end
    return lines
end

-- The text of those lines.
function Session:chat()
    local texts = {}
    for i, line in ipairs(self:chat_lines()) do
        texts[i] = line.text
    end
    return texts
end

-- What GearSwap printed since this was last asked, a line each.
function Session:printed()
    return unread(self, 'printed', self.env.printed)
end

-- The lines typed into the chat since this was last asked that reached the game, as they reached it.
function Session:typed()
    return unread(self, 'typed', self.game.typed)
end

-- The console commands run since this was last asked.
function Session:commands()
    return unread(self, 'commands', self.game.commands)
end

-- What GearSwap sent since its traffic was last asked for, in order: {equip = {slot = item}} for each run of equip
-- requests, with 'empty' for a slot it emptied, and {action = name, target = name} for each action. Items and
-- targets are named as they were when the packet went.
function Session:traffic()
    local traffic = {}
    local game = self.game
    for i = self.seen + 1, #game.sent do
        local packet = game.sent[i]
        if packet.equip then
            local last = traffic[#traffic]
            if not (last and last.equip) then
                last = {equip = {}}
                traffic[#traffic + 1] = last
            end
            for slot, item in pairs(packet.equip) do
                last.equip[slot] = item
            end
        elseif packet.action then
            traffic[#traffic + 1] = {action = packet.action.name, target = packet.action.target}
        end
    end
    self.seen = #game.sent
    return traffic
end

-- The actions in what GearSwap sent since its traffic was last asked for, in order, as traffic gives them; or in
-- the traffic given, which traffic gave before.
function Session:action_entries(traffic)
    local entries = {}
    for _, entry in ipairs(traffic or self:traffic()) do
        if entry.action then
            entries[#entries + 1] = entry
        end
    end
    return entries
end

-- The names of those actions.
function Session:actions(traffic)
    local names = {}
    for i, entry in ipairs(self:action_entries(traffic)) do
        names[i] = entry.action
    end
    return names
end

-- Plays the game frame by frame until what GearSwap sent since its traffic was last asked for holds an action, for
-- at most that many seconds (6 unless given, the time a spell and its aftercast hold Sel's tick). Returns the clock
-- then, or nil when no action went out. The traffic is left for traffic, actions or action_entries to read.
function Session:play_until_action(seconds)
    for _ = 1, math.floor((seconds or 6) * 10 + 0.5) do
        self:play(0.1)
        for i = self.seen + 1, #self.game.sent do
            if self.game.sent[i].action then
                return self.game.clock
            end
        end
    end
end

-- Has every reader above start from here: what was sent, said, printed, typed and run so far is taken as read.
function Session:forget()
    self.seen = #self.game.sent
    self:chat_lines()
    self:printed()
    self:typed()
    self:commands()
end

-- Answers the last action GearSwap sent with the packet the server sends when it is done.
function Session:finish_action(fields)
    fields = fields or {}
    local action = assert(self.game.actions[#self.game.actions], 'GearSwap sent no action to finish')
    self:send_action_packet({
        category = finishing_category[action.category], param = action.param, recast = 0,
        targets = {{id = action.target_id, actions = {{message = fields.message or 0, param = fields.value or 0,
            reaction = 0, animation = 0, effect = 0, stagger = 0}}}},
    })
end

-- Answers the last action GearSwap sent with the packet that says it was interrupted.
function Session:interrupt_action()
    local action = assert(self.game.actions[#self.game.actions], 'GearSwap sent no action to interrupt')
    self:send_action_packet({
        category = assert(beginning_category[action.category], 'that action can\'t be interrupted'), param = 28787,
        targets = {{id = action.target_id, actions = {{message = 0, param = action.param, reaction = 0,
            animation = 0, effect = 0, stagger = 0}}}},
    })
end

-- The character's status changes (0 idle, 1 engaged, 33 resting), with the status change event.
function Session:set_status(status)
    self:run(function()
        self.game:set_status(status)
        self.game:settle()
    end)
end

function Session:engage()
    self:set_status(1)
end

function Session:disengage()
    self:set_status(0)
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

function Session:set_tp(tp)
    self:run(function()
        self.game:set_tp(tp)
        self.game:settle()
    end)
end

-- The server moves that many of the first item of that name in one bag into another, all of them unless given, as
-- for a move another addon asked for (see Game:move_item). Bags are named as the API names them.
function Session:move_item(name, from, to, count)
    self:run(function()
        local slot, item = self.game:find_item(from, name)
        assert(slot, ('there is no %s in the %s'):format(name, from))
        self.game:move_item(count or item.count, self.game:bag_id(from), self.game:bag_id(to), slot)
        self.game:settle()
    end)
end

function Session:change_zone(zone_id)
    self:run(function()
        self.game:change_zone(zone_id)
        self.game:settle()
    end)
end

-- The client leaves its zone (see Game:leave_zone).
function Session:leave_zone()
    self:run(function()
        self.game:leave_zone()
        self.game:settle()
    end)
end

-- The main job or the sub job changes, as at a Moogle (see Game:change_main_job and Game:change_sub_job).
function Session:change_main_job(short, level)
    self:run(function()
        self.game:change_main_job(short, level)
        self.game:settle()
    end)
end

function Session:change_sub_job(short, level)
    self:run(function()
        self.game:change_sub_job(short, level)
        self.game:settle()
    end)
end

-- Vana'diel's time (minutes past midnight), day or weather (by id) changes, with the event that says so.
function Session:set_time(minutes)
    self:run(function()
        self.game:set_time(minutes)
        self.game:settle()
    end)
end

function Session:set_day(id)
    self:run(function()
        self.game:set_day(id)
        self.game:settle()
    end)
end

function Session:set_weather(id)
    self:run(function()
        self.game:set_weather(id)
        self.game:settle()
    end)
end

-- The server sends a packet: built from its fields by label (send), or as the bytes after its header (receive).
function Session:send(id, fields)
    self:run(function()
        self.game:send(id, fields)
        self.game:settle()
    end)
end

function Session:receive(id, body)
    self:run(function()
        self.game:receive(id, body)
        self.game:settle()
    end)
end

-- The server tells of an action in the action packet (see Game:send_action_packet), or sends a message about one
-- (see Game:send_action_message).
function Session:send_action_packet(act)
    self:run(function()
        self.game:send_action_packet(act)
        self.game:settle()
    end)
end

function Session:send_action_message(fields)
    self:run(function()
        self.game:send_action_message(fields)
        self.game:settle()
    end)
end

-- A packet GearSwap has no handler for (see Game:next_packet).
function Session:next_packet()
    self:run(function()
        self.game:next_packet()
        self.game:settle()
    end)
end

-- The zone-in packet, with fields by label laid over it (see Game:send_zone_in).
function Session:send_zone_in(fields)
    self:run(function()
        self.game:send_zone_in(fields)
        self.game:settle()
    end)
end

-- The buff packet for these buffs, which become the player's (see Game:send_buffs).
function Session:send_buffs(buffs)
    self:run(function()
        self.game:send_buffs(buffs)
        self.game:settle()
    end)
end

-- The party buff packet (see Game:send_party_buffs).
function Session:send_party_buffs(members)
    self:run(function()
        self.game:send_party_buffs(members)
        self.game:settle()
    end)
end

-- A packet the client sends of its own, as the bytes after its header (see Game:send_from_client). Returns whether
-- a handler blocked it.
function Session:send_from_client(id, body)
    return self:run(function()
        local blocked = self.game:send_from_client(id, body)
        self.game:settle()
        return blocked
    end)
end

-- An action of the monster's (see Game:monster_acts).
function Session:monster_acts(category, name, target_id)
    self:run(function()
        self.game:monster_acts(category, name, target_id)
        self.game:settle()
    end)
end

function Session:monster_readies(name)
    self:run(function()
        self.game:monster_readies(name)
        self.game:settle()
    end)
end

function Session:monster_hits()
    self:run(function()
        self.game:monster_hits()
        self.game:settle()
    end)
end

-- The player's pet arrives, as the server tells it (see Game:give_pet for the fields), goes away, changes status
-- (0 idle, 1 engaged) or gains TP.
function Session:give_pet(fields)
    self:run(function() self.game:give_pet(fields) end)
end

function Session:take_pet()
    self:run(function() self.game:take_pet() end)
end

function Session:set_pet_status(status)
    self:run(function() self.game:set_pet_status(status) end)
end

function Session:set_pet_tp(tp)
    self:run(function() self.game:set_pet_tp(tp) end)
end

-- The player's indicolure changes (see Game:set_indi), or ends when given no fields.
function Session:set_indi(fields)
    self:run(function() self.game:set_indi(fields) end)
end

-- The kinds of move a pet makes, by the resource each is in and how the server sends it: a ready move of a
-- beastmaster's pet (a monster's skill, readied with message 43 and done in category 11), a blood pact or breath (a
-- job ability, readied with message 326 and done in category 13) and a spell a spirit casts (readied in category 8 and
-- done in category 4). A move interrupted is sent as the player's is (see Session:interrupt_action): in the category
-- it was readied in, with 28787 as its param and no message.
local pet_moves = {
    monster = {resource = 'monster_abilities', ready = {category = 7, message = 43},
        finish = {category = 11, message = 185}, interrupt = {category = 7, message = 0}},
    ability = {resource = 'job_abilities', ready = {category = 7, message = 326},
        finish = {category = 13, message = 110}, interrupt = {category = 7, message = 0}},
    spell = {resource = 'spells', ready = {category = 8, message = 327}, finish = {category = 4, message = 2},
        interrupt = {category = 8, message = 0}},
}

-- phase: 'ready', 'finish' or 'interrupt'. fields: category and message of the packet, target ('monster', or
-- 'player') for who it is aimed at, actor_id for a mob that acts in the pet's place.
function Session:pet_acts(name, kind, phase, fields)
    kind = pet_moves[kind or 'monster']
    fields = fields or {}
    local move = Game.find_by_name(self.game.res[kind.resource], name, kind.resource)
    local packet = kind[phase]
    local game = self.game
    local target = fields.target == 'player' and game.player or game.monster
    local action = {message = fields.message or packet.message, param = phase ~= 'finish' and move or 100,
        reaction = 0, animation = 0, effect = 0, stagger = 0}
    self:send_action_packet({
        actor_id = fields.actor_id or game.pet.id, category = fields.category or packet.category,
        param = phase == 'finish' and move or phase == 'interrupt' and 28787 or 0,
        targets = {{id = target.id, actions = {action}}},
    })
end

-- The pet readies a move of its own, as kind says ('monster', the default, 'ability' or 'spell'), on the monster.
function Session:pet_readies(name, kind, fields)
    self:pet_acts(name, kind, 'ready', fields)
end

-- The pet's move takes effect.
function Session:pet_finishes(name, kind, fields)
    self:pet_acts(name, kind, 'finish', fields)
end

return harness
