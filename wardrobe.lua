-------------------------------------------------------------------------------------------------------------------
-- gs stash <jobs> [unused] and gs pull <jobs>: move the gear the jobs' files use out of, or into, the wardrobes.
--
-- Each job's file is read in a sandbox. The file and everything it includes run as on a job change, but their
-- commands, events, timers, chat, text boxes and equip calls go nowhere, so neither the loaded file nor the game
-- sees them. Items move as the organizer addon moves them, with one 0x029 packet per hop and every hop to or from
-- the inventory. Each batch of moves waits for the server's replies before the next batch is planned.
-------------------------------------------------------------------------------------------------------------------

-- pull fills these, in this order, and stash empties them.
local wardrobe_bags = {'wardrobe', 'wardrobe2'}

-- stash fills these, in this order.
local stash_bags = {'case', 'sack', 'safe', 'safe2', 'storage', 'locker'}

-- Bags pull never takes from, besides the wardrobes above.
local never_pull_from = {temporary = true, recycle = true}

-- Libraries a sandbox loads a copy of its own, so what they draw and save goes through the sandbox. Every other
-- library a job file includes is GearSwap's copy, as on a normal load.
local own_copy_libs = {texts = true, config = true}

-- How often a batch checks for the server's replies, and how many checks it makes before it gives up (5 seconds).
local poll_interval = 0.25
local poll_limit = 20

-- True while a stash or pull is moving gear.
local busy = false

local function noop() end

-- 'a', 'a and b', 'a, b and c'.
local function and_list(words)
    if #words < 2 then return words[1] or '' end
    return table.concat(words, ', ', 1, #words - 1)..' and '..words[#words]
end

local function pieces_word(n)
    return n == 1 and 'piece' or 'pieces'
end

-------------------------------------------------------------------------------------------------------------------
-- Bags.
-------------------------------------------------------------------------------------------------------------------

local function bag_id(name)
    return bag_string_lookup[name]
end

local function bag_name(id)
    return to_windower_bag_api(res.bags[id].en)
end

local function bag_names(ids)
    local names = {}
    for i, id in ipairs(ids) do names[i] = bag_name(id) end
    return names
end

-- The items in a bag, read from the client: slot -> item, the number of slots in use and the bag's size.
local function bag_contents(id)
    local info = windower.ffxi.get_bag_info(id)
    local bag = windower.ffxi.get_items(id)
    local contents, used = {}, 0
    if info and bag then
        for index = 1, info.max do
            local item = bag[index]
            if item and item.id ~= 0 and item.id ~= 0xFFFF then
                contents[index] = item
                used = used + 1
            end
        end
    end
    return contents, used, info and info.max or 0
end

-- Whether gear can move into or out of a bag from where the player stands: the bag is unlocked, and a Mog House
-- bag needs the Mog House, or a Nomad or Pilgrim Moogle for all of them but Storage.
local function in_reach(id, at_moogle)
    local info = windower.ffxi.get_bag_info(id)
    if not (info and info.enabled) then return false end
    local access = res.bags[id].access
    if access == 'Everywhere' then
        return true
    elseif access == 'Mog House' then
        return windower.ffxi.get_info().mog_house or (at_moogle and id ~= bag_id('storage')) or false
    end
    return false
end

-- The Nomad or Pilgrim Moogle within six yalms of the player, if there is one.
local function moogle_in_reach()
    local me = windower.ffxi.get_mob_by_target('me')
    if not me then return end
    for _, name in ipairs({'Nomad Moogle', 'Pilgrim Moogle'}) do
        for index in pairs(windower.ffxi.get_mob_list(name)) do
            local moogle = windower.ffxi.get_mob_by_index(index)
            if moogle and (moogle.x - me.x)^2 + (moogle.y - me.y)^2 < 36 then
                return moogle
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Timing. GearSwap swaps in its own coroutine.sleep and coroutine.yield for user files, so each wait here is a chain
-- of coroutine.schedule calls, as the engine's timers are.
-------------------------------------------------------------------------------------------------------------------

-- Ends a run on an error with a message, so the run cannot stay busy.
local function stop_on_error(err)
    busy = false
    msg.addon_msg(123, 'stash/pull stopped on an error: '..tostring(err))
end

-- Runs fn after delay seconds.
local function later(delay, fn)
    coroutine.schedule(function()
        local ok, err = pcall(fn)
        if not ok then stop_on_error(err) end
    end, delay)
end

-- Checks test every poll_interval seconds until it passes or poll_limit checks fail, then calls then_do(passed).
local function wait_until(test, then_do)
    local checks = 0
    local function check()
        checks = checks + 1
        local passed = test()
        if passed or checks >= poll_limit then
            then_do(passed)
        else
            later(poll_interval, check)
        end
    end
    later(poll_interval, check)
end

-- Opens the Mog House bags at a Nomad or Pilgrim Moogle as organizer does it: it talks to the moogle and hides
-- the menu that opens. Calls then_do(true) once the menu has come, and then_do(false) in the Mog House, away from
-- a moogle, or when no menu comes.
local function open_moogle_bags(then_do)
    if windower.ffxi.get_info().mog_house then return then_do(false) end
    local moogle = moogle_in_reach()
    if not moogle then return then_do(false) end
    local menu_seen = false
    local event = windower.register_event('incoming chunk', function(id)
        if id == 0x02E and not menu_seen then
            menu_seen = true
            return true
        end
    end)
    packets.inject(packets.new('outgoing', 0x01A, {['Target'] = moogle.id, ['Target Index'] = moogle.index}))
    wait_until(function() return menu_seen end, function()
        windower.unregister_event(event)
        then_do(menu_seen)
    end)
end

-------------------------------------------------------------------------------------------------------------------
-- Reading job files.
-------------------------------------------------------------------------------------------------------------------

-- A user environment that reads a job's file without touching the game or the loaded file. The file sees the job
-- it is for as the main job. Commands, events, timers, chat, text boxes and equip, enable and disable calls do
-- nothing, and what the file writes into GearSwap's own tables stays in the sandbox.
local function new_sandbox(job_id)
    local env = new_user_env()

    local function nothing_table()
        return setmetatable({}, {__index = function() return noop end})
    end
    local last_event = 0
    local function register_event()
        last_event = last_event + 1
        return last_event
    end

    env.windower = setmetatable({register_event = register_event, raw_register_event = register_event,
        unregister_event = noop, send_command = noop, send_ipc_message = noop, add_to_chat = noop,
        play_sound = noop, text = nothing_table(), prim = nothing_table(),
        chat = setmetatable({input = noop}, {__index = windower.chat})}, {__index = windower})
    env.coroutine = setmetatable({schedule = noop, sleep = noop, close = noop}, {__index = coroutine})
    env.gearswap = setmetatable({}, {__index = _G})
    env._global = setmetatable({current_event = 'get_sets'}, {__index = _global})
    env._settings = setmetatable({}, {__index = _settings})
    env._libs = setmetatable({}, {__index = _libs})
    for _, name in ipairs({'equip', 'cancel_spell', 'change_target', 'cast_delay', 'print_set', 'disable',
            'enable', 'send_command', 'set_language', 'show_swaps', 'debug_mode', 'move_spell_target',
            'register_unhandled_command', 'print', 'add_to_chat'}) do
        env[name] = noop
    end
    env.midaction = function() return false end
    env.pet_midaction = function() return false end

    local main_job, main_job_full = get_job_names(job_id)
    env.player = setmetatable({main_job = main_job, main_job_full = main_job_full, main_job_id = job_id,
        job = main_job..'/'..tostring(player.sub_job)}, {__index = player})

    -- The sandbox's copies of texts and config run where GearSwap's own copies run, among GearSwap's globals, but
    -- with the sandbox's windower, coroutine, _libs and _meta. Their require gives them the sandbox's copies of
    -- each other and GearSwap's copies of the rest.
    --
    -- _meta holds the libraries' metatables, one per kind of object, each shared by every object of that kind.
    -- texts sets _meta.Text's __index and __newindex to itself as it loads, so on GearSwap's _meta the live text
    -- boxes would answer to the sandbox's copy, which has no record of them, and the next teardown would fail in
    -- texts.destroy. The copies get a _meta of their own, filled with copies of GearSwap's entries.
    local own_meta = {}
    for kind, mt in pairs(_meta) do
        if type(mt) == 'table' then
            local copy = {}
            for k, v in pairs(mt) do copy[k] = v end
            own_meta[kind] = setmetatable(copy, getmetatable(mt))
        else
            own_meta[kind] = mt
        end
    end
    local own_copies = {}
    local lib_env = setmetatable({windower = env.windower, coroutine = env.coroutine, _libs = env._libs,
        _meta = own_meta}, {__index = _G})
    lib_env._G = lib_env
    local function own_copy(name)
        if own_copies[name] == nil then
            local saved_dir = include_user_path
            include_user_path = nil
            local path = pathsearch({name..'.lua'})
            include_user_path = saved_dir
            local f, err = loadfile(path or name..'.lua')
            if not f then error(err, 0) end
            setfenv(f, lib_env)
            own_copies[name] = f()
        end
        return own_copies[name]
    end
    lib_env.require = function(name)
        if own_copy_libs[name] then return own_copy(name) end
        return require(name)
    end

    -- include and require as include_user does them, into this environment.
    local include_dir
    env.include_path = function(path)
        include_dir = type(path) == 'string' and path or nil
    end
    env.include = function(str, into)
        if type(str) ~= 'string' then
            error('\nGearSwap: include() was passed an invalid value ('..tostring(str)..'). (must be a string)', 2)
        end
        str = str:lower()
        if own_copy_libs[str] then
            return own_copy(str)
        elseif type(package.loaded[str]) == 'table' then
            return package.loaded[str]
        elseif str == 'pack' then
            return
        end
        local file_name = str:sub(-4) == '.lua' and str or str..'.lua'
        local saved_dir = include_user_path
        include_user_path = include_dir
        local path = pathsearch({file_name})
        include_user_path = saved_dir
        if not path then
            error('\nGearSwap: Cannot find the include file ('..file_name..').', 2)
        end
        local f, err = loadfile(path)
        if not f then
            error('\nGearSwap: Error loading file ('..file_name..'): '..err, 2)
        end
        if type(into) == 'table' then
            setmetatable(into, {__index = env})
            setfenv(f, into)
            pcall(f, into)
            return into
        end
        setfenv(f, env)
        return f()
    end
    env.require = env.include
    env.texts = own_copy('texts')
    return env
end

-- Reads a job's file in a sandbox. Returns its sets table and the file's name, or nil and the reason it could not.
local function read_job_sets(job_id)
    local saved_dir = include_user_path
    include_user_path = nil
    local path, _, filename = pathsearch(job_file_names(job_id))
    include_user_path = saved_dir
    if not path then
        return nil, 'GearSwap finds no file for it'
    end
    local f, err = loadfile(path)
    if not f then
        return nil, err
    end
    local ok, env = pcall(new_sandbox, job_id)
    if not ok then
        return nil, env
    end
    setfenv(f, env)
    ok, err = pcall(f)
    if ok and type(env.get_sets) == 'function' then
        ok, err = pcall(env.get_sets)
    end
    if not ok then
        return nil, err
    end
    return env.sets, filename
end

-------------------------------------------------------------------------------------------------------------------
-- Pieces of gear.
-------------------------------------------------------------------------------------------------------------------

-- An augment list as one string: each augment stripped the way extdata.compare_augments strips it, in sorted order.
local function augments_key(augments)
    local parts = {}
    for _, augment in pairs(augments) do
        if type(augment) == 'string' and augment ~= 'none' then
            parts[#parts+1] = (augment:lower():gsub('[^%-%w,]', ''))
        end
    end
    table.sort(parts)
    return table.concat(parts, '|')
end

-- Records each piece a sets table names, keyed by name and augments, with the most copies one set wears at once.
local function add_pieces(t, pieces, seen)
    if seen[t] then return end
    seen[t] = true
    local worn = {}
    for key, value in pairs(t) do
        if type(key) == 'string' and slot_map[key] then
            local name, augments = value, nil
            if type(value) == 'table' then
                name, augments = value.name, value.augments or value.augment
            end
            if type(name) == 'string' and name ~= '' and name:lower() ~= 'empty' then
                if type(augments) == 'string' then augments = {augments} end
                if type(augments) ~= 'table' or augments_key(augments) == '' then augments = nil end
                local piece_key = name:lower()..(augments and '#'..augments_key(augments) or '')
                pieces[piece_key] = pieces[piece_key] or {name = name, augments = augments, count = 0}
                worn[piece_key] = (worn[piece_key] or 0) + 1
            end
        elseif type(value) == 'table' then
            add_pieces(value, pieces, seen)
        end
    end
    for piece_key, n in pairs(worn) do
        pieces[piece_key].count = math.max(pieces[piece_key].count, n)
    end
end

-- An item's short name, lower case, and its log name, lower case.
local function item_names(item)
    local entry = res.items[item.id]
    if not entry then return end
    return entry[language]:lower(), entry[language..'_log']:lower()
end

-- Joins pieces that name one item two ways, by its short name and by its log name, using the items in the bags.
local function join_pieces(pieces, bags)
    local short_of = {}
    for _, id in ipairs(bags) do
        for _, item in pairs((bag_contents(id))) do
            local short, long = item_names(item)
            if short then
                short_of[short] = short
                short_of[long] = short
            end
        end
    end
    local joined = {}
    for _, piece in pairs(pieces) do
        local short = short_of[piece.name:lower()] or piece.name:lower()
        local piece_key = short..(piece.augments and '#'..augments_key(piece.augments) or '')
        if joined[piece_key] then
            joined[piece_key].count = math.max(joined[piece_key].count, piece.count)
        else
            joined[piece_key] = {name = piece.name, short = short, augments = piece.augments, count = piece.count}
        end
    end
    return joined
end

-- The pieces by short name. Pieces with augments come first, so they claim their own copies before a piece
-- without augments can.
local function pieces_by_name(pieces)
    local by_name = {}
    for _, piece in pairs(pieces) do
        by_name[piece.short] = by_name[piece.short] or {}
        table.insert(by_name[piece.short], piece)
    end
    for _, list in pairs(by_name) do
        table.sort(list, function(a, b) return a.augments ~= nil and b.augments == nil end)
    end
    return by_name
end

-- Whether an item is a piece: the name matches, and so do the piece's augments if it lists any.
local function is_piece(item, piece)
    if not piece.augments then return true end
    local ok, decoded = pcall(extdata.decode, item)
    return ok and type(decoded) == 'table' and decoded.augments ~= nil
        and extdata.compare_augments(piece.augments, decoded.augments) or false
end

-- The first piece an item is, among the pieces still wanted when wanted is given.
local function piece_for(item, by_name, wanted)
    local short = item_names(item)
    for _, piece in ipairs(short and by_name[short] or {}) do
        if (not wanted or wanted[piece] > 0) and is_piece(item, piece) then
            return piece
        end
    end
end

local function move_for(id, index, item)
    return {bag = id, index = index, id = item.id, count = item.count, extdata = item.extdata}
end

-- stash: the gear in the wardrobes that is a piece, or with unused that is not, and the pieces of it that are
-- equipped and stay.
local function stash_plan(by_name, unused, wardrobes)
    local moves, stayed = {}, {}
    for _, id in ipairs(wardrobes) do
        local contents, _, max = bag_contents(id)
        for index = 1, max do
            local item = contents[index]
            if item and (piece_for(item, by_name) ~= nil) ~= unused then
                if item.status == 0 then
                    moves[#moves+1] = move_for(id, index, item)
                else
                    stayed[#stayed+1] = item
                end
            end
        end
    end
    return moves, stayed
end

-- pull: the copies of each piece the wardrobes lack, from the bags in reach. Copies in the wardrobes count first,
-- then equipped copies elsewhere, which stay where they are. Also returns the pieces no bag in reach holds.
local function pull_plan(pieces, by_name, wardrobes, sources)
    local wanted = {}
    for _, piece in pairs(pieces) do wanted[piece] = piece.count end
    for _, id in ipairs(wardrobes) do
        for _, item in pairs((bag_contents(id))) do
            local piece = piece_for(item, by_name, wanted)
            if piece then wanted[piece] = wanted[piece] - 1 end
        end
    end
    local moves, stayed = {}, {}
    for _, equipped_pass in ipairs({true, false}) do
        for _, id in ipairs(sources) do
            local contents, _, max = bag_contents(id)
            for index = 1, max do
                local item = contents[index]
                if item and (item.status ~= 0) == equipped_pass then
                    local piece = piece_for(item, by_name, wanted)
                    if piece then
                        wanted[piece] = wanted[piece] - 1
                        if equipped_pass then
                            stayed[#stayed+1] = item
                        else
                            moves[#moves+1] = move_for(id, index, item)
                        end
                    end
                end
            end
        end
    end
    local missing = {}
    for piece, n in pairs(wanted) do
        if n > 0 then missing[#missing+1] = piece.name..(n > 1 and ' x'..n or '') end
    end
    table.sort(missing)
    return moves, stayed, missing
end

-------------------------------------------------------------------------------------------------------------------
-- Moving.
-------------------------------------------------------------------------------------------------------------------

-- Asks the server to move count of the item in slot index of one bag to another bag, the way organizer does.
-- One of the bags must be the inventory. Target slot 0x52 lets the server pick the first empty slot.
local function send_move(count, from, to, index)
    windower.packets.inject_outgoing(0x29, string.char(0x29, 6, 0, 0)..('I'):pack(count)..string.char(from, to, index, 0x52))
end

-- Moves each item to the first bag in targets with room, through the inventory, in batches the inventory and the
-- targets have room for. Calls finish(moved, reason, stranded) at the end: moved counts the items each target
-- took, reason says why it stopped early ('full', 'inventory', 'refused' or 'zone'), and stranded counts the items
-- it brought into the inventory and could not move on.
local function move_items(moves, targets, finish)
    local zone = windower.ffxi.get_info().zone
    local moved, stranded = {}, 0
    local next_move = 1
    local batch

    -- Sends each inventory slot in puts to a target with room and waits for the slots to empty.
    local function put_away(puts, room)
        local sent = {}
        for _, put in ipairs(puts) do
            for _, id in ipairs(targets) do
                if room[id] > 0 then
                    room[id] = room[id] - 1
                    send_move(put.count, 0, id, put.index)
                    sent[#sent+1] = {index = put.index, id = put.id, bag = id, from_bag = put.from_bag}
                    break
                end
            end
        end
        local function still_there(slot, inventory)
            local item = inventory[slot.index]
            return item ~= nil and item.id == slot.id
        end
        wait_until(function()
            local inventory = windower.ffxi.get_items(0)
            for _, slot in ipairs(sent) do
                if still_there(slot, inventory) then return false end
            end
            return true
        end, function()
            local inventory = windower.ffxi.get_items(0)
            local progress = 0
            for _, slot in ipairs(sent) do
                if still_there(slot, inventory) then
                    if slot.from_bag then stranded = stranded + 1 end
                else
                    moved[slot.bag] = (moved[slot.bag] or 0) + 1
                    progress = progress + 1
                end
            end
            if progress == 0 then
                finish(moved, 'refused', stranded)
            else
                batch()
            end
        end)
    end

    batch = function()
        local info = windower.ffxi.get_info()
        if not info.logged_in or info.zone ~= zone then
            return finish(moved, 'zone', stranded)
        elseif next_move > #moves then
            return finish(moved, nil, stranded)
        end

        local room, target_room = {}, 0
        for _, id in ipairs(targets) do
            local _, used, max = bag_contents(id)
            room[id] = max - used
            target_room = target_room + room[id]
        end
        local inventory, used, max = bag_contents(0)
        local puts, gets = {}, {}
        while next_move <= #moves and #puts + #gets < target_room do
            local move = moves[next_move]
            if move.bag == 0 then
                puts[#puts+1] = move
            elseif #gets < max - used then
                gets[#gets+1] = move
            else
                break
            end
            next_move = next_move + 1
        end
        if #puts + #gets == 0 then
            return finish(moved, target_room == 0 and 'full' or 'inventory', stranded)
        elseif #gets == 0 then
            return put_away(puts, room)
        end

        local before = {}
        for index in pairs(inventory) do before[index] = true end
        for _, move in ipairs(gets) do
            send_move(move.count, move.bag, 0, move.index)
        end
        wait_until(function()
            local bags = {}
            for _, move in ipairs(gets) do
                bags[move.bag] = bags[move.bag] or windower.ffxi.get_items(move.bag)
                local item = bags[move.bag][move.index]
                if item and item.id == move.id then return false end
            end
            return true
        end, function()
            -- Match each item that arrived to an inventory slot that filled: the same item and extdata first,
            -- then the same item.
            local new_slots = {}
            for index, item in pairs((bag_contents(0))) do
                if not before[index] then new_slots[#new_slots+1] = {index = index, item = item} end
            end
            table.sort(new_slots, function(a, b) return a.index < b.index end)
            local function take(same)
                for _, move in ipairs(gets) do
                    if not move.slot then
                        for i, slot in ipairs(new_slots) do
                            if same(slot.item, move) then
                                move.slot = slot.index
                                table.remove(new_slots, i)
                                break
                            end
                        end
                    end
                end
            end
            take(function(item, move) return item.id == move.id and item.extdata == move.extdata end)
            take(function(item, move) return item.id == move.id end)
            local bags = {}
            for _, move in ipairs(gets) do
                if move.slot then
                    puts[#puts+1] = {index = move.slot, id = move.id, count = move.count, from_bag = move.bag}
                else
                    -- Left its bag but filled no new slot, so it joined a stack in the inventory.
                    bags[move.bag] = bags[move.bag] or windower.ffxi.get_items(move.bag)
                    local item = bags[move.bag][move.index]
                    if not item or item.id ~= move.id then stranded = stranded + 1 end
                end
            end
            if #puts == 0 then
                return finish(moved, 'refused', stranded)
            end
            put_away(puts, room)
        end)
    end

    batch()
end

-------------------------------------------------------------------------------------------------------------------
-- The commands.
-------------------------------------------------------------------------------------------------------------------

local function item_list(items)
    local names = {}
    for i, item in ipairs(items) do
        names[i] = get_formal_name_by_item_id(item.id)..(item.status == 25 and ' (bazaar)' or '')
    end
    table.sort(names)
    return names
end

-- Reports what a run moved and why it stopped, then frees the commands for the next run.
local function report(command, targets, out_of_reach, total, moved, reason, stranded)
    busy = false
    local done, parts = 0, {}
    for _, id in ipairs(targets) do
        if moved[id] then
            done = done + moved[id]
            parts[#parts+1] = moved[id]..' to '..bag_name(id)
        end
    end
    local left = total - done
    if done > 0 or not reason then
        msg.addon_msg(123, command..' moved '..done..' '..pieces_word(done)..(done > 0 and ': '..and_list(parts) or '')..'.')
    end
    if reason then
        local why
        if reason == 'full' then
            why = and_list(bag_names(targets))..(#targets == 1 and ' is' or ' are')..' full'
            if #out_of_reach > 0 then
                why = why..', and '..and_list(bag_names(out_of_reach))..(#out_of_reach == 1 and ' is' or ' are')
                    ..' out of reach'
            end
        elseif reason == 'inventory' then
            why = 'the inventory is full, and every piece passes through it'
        elseif reason == 'refused' then
            why = 'the server did not take the last moves'
        else
            why = 'you changed zones'
        end
        msg.addon_msg(123, command..' stopped: '..why..'. '..left..' '..pieces_word(left)..' did not move.')
    elseif left > 0 then
        msg.addon_msg(123, left..' '..pieces_word(left)..' did not move: the server did not take '..(left == 1 and 'it' or 'them')..'.')
    end
    if stranded > 0 then
        msg.addon_msg(123, stranded..' '..pieces_word(stranded)..' stayed in the inventory.')
    end
end

-- Builds the plan once the bags in reach are known, and starts the moves.
local function plan_and_move(command, unused, pieces, files, at_moogle)
    local all_bags, wardrobes, sources, targets, out_of_reach = {}, {}, {}, {}, {}
    local is_wardrobe = {}
    for _, name in ipairs(wardrobe_bags) do
        is_wardrobe[bag_id(name)] = true
        if in_reach(bag_id(name), at_moogle) then wardrobes[#wardrobes+1] = bag_id(name) end
    end
    for id in pairs(res.bags) do
        all_bags[#all_bags+1] = id
    end
    table.sort(all_bags)
    for _, id in ipairs(all_bags) do
        if not is_wardrobe[id] and not never_pull_from[bag_name(id)] and in_reach(id, at_moogle) then
            sources[#sources+1] = id
        end
    end
    if command == 'stash' then
        for _, name in ipairs(stash_bags) do
            local id = bag_id(name)
            local info = windower.ffxi.get_bag_info(id)
            if in_reach(id, at_moogle) then
                targets[#targets+1] = id
            elseif info and info.enabled then
                out_of_reach[#out_of_reach+1] = id
            end
        end
    else
        targets = wardrobes
    end
    if #targets == 0 then
        busy = false
        msg.addon_msg(123, command..' stopped: '..and_list(command == 'stash' and stash_bags or wardrobe_bags)
            ..' are all out of reach.')
        return
    end

    pieces = join_pieces(pieces, all_bags)
    local total = 0
    for _, piece in pairs(pieces) do total = total + piece.count end
    local by_name = pieces_by_name(pieces)
    msg.addon_msg(123, and_list(files)..(#files == 1 and ' uses ' or ' use ')..total..' '..pieces_word(total)..'.')
    if total == 0 and unused then
        busy = false
        msg.addon_msg(123, 'stash unused stopped: with no pieces to keep, it would empty the wardrobes.')
        return
    end

    local moves, stayed, missing
    if command == 'stash' then
        moves, stayed = stash_plan(by_name, unused, wardrobes)
    else
        moves, stayed, missing = pull_plan(pieces, by_name, wardrobes, sources)
    end
    if #stayed > 0 then
        msg.addon_msg(123, 'Equipped, so '..(#stayed == 1 and 'it stays' or 'they stay')..': '..and_list(item_list(stayed))..'.')
    end
    if missing and #missing > 0 then
        msg.addon_msg(123, 'In no bag in reach: '..and_list(missing)..'.')
    end
    if #moves == 0 then
        busy = false
        msg.addon_msg(123, command..': nothing to move.')
        return
    end
    msg.addon_msg(123, command..' is moving '..#moves..' '..pieces_word(#moves)..' '..(command == 'stash' and 'out of ' or 'into ')
        ..and_list(bag_names(wardrobes))..'.')
    move_items(moves, targets, function(moved, reason, stranded)
        report(command, targets, out_of_reach, #moves, moved, reason, stranded)
    end)
end

-- gs stash <jobs> [unused] and gs pull <jobs>. words are the command's words after its name.
local function run(command, words)
    local job_ids, seen, unused = {}, {}, false
    for _, word in ipairs(words) do
        local lower = word:lower()
        if lower == 'unused' and command == 'stash' then
            unused = true
        elseif lower == 'unused' then
            msg.addon_msg(123, 'unused goes with stash, not pull. Nothing moved.')
            return
        else
            local job_id
            for id, job in pairs(res.jobs) do
                if id ~= 0 and (job.english_short:lower() == lower or job.english:lower() == lower) then
                    job_id = id
                end
            end
            if not job_id then
                msg.addon_msg(123, command..': '..word..' is not a job. Nothing moved.')
                return
            end
            if not seen[job_id] then
                seen[job_id] = true
                job_ids[#job_ids+1] = job_id
            end
        end
    end
    if #job_ids == 0 then
        msg.addon_msg(123, command == 'stash' and 'Usage: gs stash <jobs> [unused]' or 'Usage: gs pull <jobs>')
        return
    end

    refresh_globals()
    local pieces, files, file_seen = {}, {}, {}
    for _, job_id in ipairs(job_ids) do
        local job_sets, file_or_reason = read_job_sets(job_id)
        if not job_sets then
            msg.addon_msg(123, command..' cannot read the '..res.jobs[job_id].english_short..' file: '
                ..tostring(file_or_reason)..'. Nothing moved.')
            return
        end
        add_pieces(job_sets, pieces, {})
        if not file_seen[file_or_reason] then
            file_seen[file_or_reason] = true
            files[#files+1] = file_or_reason
        end
    end

    busy = true
    open_moogle_bags(function(at_moogle)
        plan_and_move(command, unused, pieces, files, at_moogle)
    end)
end

-- The entry point from GearSwap's addon command handler. command is 'stash' or 'pull'.
function move_job_gear(command, words)
    if busy then
        msg.addon_msg(123, 'A stash or pull is still moving gear.')
        return
    elseif not windower.ffxi.get_info().logged_in then
        msg.addon_msg(123, command..' needs a character logged in.')
        return
    end
    local ok, err = pcall(run, command, words)
    if not ok then stop_on_error(err) end
end
