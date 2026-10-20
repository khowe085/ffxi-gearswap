-------------------------------------------------------------------------------------------------------------------
-- A stand-in for the game and for the Windower API an addon sees: one character in a field zone, its bags and
-- gear, a monster to target, the other mobs a test adds (members of the party and the alliance, other players,
-- NPCs, other monsters), a pet, and the server's side of equipping and of moving items between bags.
--
-- Nothing happens on its own. What the addon sends (packets, commands, chat input) waits in a queue, as it would
-- for the next frame, and settle() handles it: a packet goes through the outgoing chunk event, then, unless a handler
-- blocked it, the server carries out an equip request or a move between bags and confirms it with the packets it
-- answers with; a command runs; input goes through the outgoing text event.
-- advance(seconds) moves the clock on, runs the timers that fall due (coroutine.schedule, @wait) and settles after
-- each. The tests say when the server answers an action (finish_action, interrupt_action) and when a buff comes or
-- goes.
--
-- The game reads its items, spells and abilities from the resources it is given: the raw tables of Windower's
-- resource files, with jobs, slots and races still bit masks. It writes most of the packets the server sends byte by
-- byte; send() builds one from Windower's own field definitions, by the labels of its fields, with the packets
-- library of the addon it plays, which the harness hands it once GearSwap has loaded.
-------------------------------------------------------------------------------------------------------------------

local lfs = require('lfs')

local real_coroutine = coroutine

local Game = {}
Game.__index = Game

local slot_names = {[0] = 'main', 'sub', 'range', 'ammo', 'head', 'body', 'hands', 'legs', 'feet', 'neck', 'waist',
    'left_ear', 'right_ear', 'left_ring', 'right_ring', 'back'}
local slot_ids = {}
for id, name in pairs(slot_names) do
    slot_ids[name] = id
end
Game.slot_names = slot_names
Game.slot_ids = slot_ids

local function copy(value)
    if type(value) ~= 'table' then
        return value
    end
    local result = {}
    for k, v in pairs(value) do
        result[k] = copy(v)
    end
    return result
end

local function has_bit(mask, index)
    return math.floor((mask or 0) / 2 ^ index) % 2 == 1
end

-- The id of the entry of a resource (the raw table of a Windower resource file) with that name, short or long, in
-- any case, and the entry; of several, the one with the lowest id. kind names the resource in the error when none
-- has the name.
local function find_by_name(resource, name, kind)
    local lowered = name:lower()
    local found
    for id, entry in pairs(resource) do
        if type(entry) == 'table' and (entry.en and entry.en:lower() == lowered or entry.enl and entry.enl:lower() == lowered)
            and (not found or id < found) then
            found = id
        end
    end
    if not found then
        error(('the test resources have no %s named %q'):format(kind, name), 3)
    end
    return found, resource[found]
end
Game.find_by_name = find_by_name

-- Windower lists a path's entries by their names on disk. GearSwap runs on Windows, where a file's name matches in
-- any case, and asks for files by names it lowered; the files keep their case on disk.
local function resolve(path)
    if lfs.attributes(path) then
        return path
    end
    local absolute = path:sub(1, 1) == '/'
    local resolved = absolute and '' or '.'
    for part in path:gmatch('[^/\\]+') do
        local exact = resolved .. '/' .. part
        if lfs.attributes(exact) then
            resolved = exact
        else
            local found
            if lfs.attributes(resolved, 'mode') == 'directory' then
                for entry in lfs.dir(resolved) do
                    if entry:lower() == part:lower() then
                        found = resolved .. '/' .. entry
                        break
                    end
                end
            end
            if not found then
                return nil
            end
            resolved = found
        end
    end
    if not absolute then
        resolved = resolved:sub(3)
    end
    return resolved
end
Game.resolve = resolve

local function packet_header(id, size, sequence)
    local words = math.ceil(size / 4)
    return string.char(id % 256, math.floor(id / 256) % 2 + 2 * words, sequence % 256, math.floor(sequence / 256) % 256)
end

local function pad(data, size)
    return data .. string.char(0):rep(size - #data)
end

local function u16(value)
    return string.char(value % 256, math.floor(value / 256) % 256)
end

local function u32(value)
    value = value % 2 ^ 32
    return string.char(value % 256, math.floor(value / 256) % 256, math.floor(value / 65536) % 256, math.floor(value / 16777216) % 256)
end

local function read_u16(data, position)
    return data:byte(position) + 256 * data:byte(position + 1)
end

local function read_u32(data, position)
    return read_u16(data, position) + 65536 * read_u16(data, position + 2)
end

local function job_id(res, short)
    for id, job in pairs(res.jobs) do
        if type(job) == 'table' and job.ens == short then
            return id
        end
    end
    error(('the test resources have no job %q'):format(short), 3)
end

local function occupied(bag)
    local count = 0
    for _ in pairs(bag.items) do
        count = count + 1
    end
    return count
end

-- options: res (the raw resource tables), paths (addon and windower, for the API), name, id, index, main_job,
-- main_job_level, sub_job, sub_job_level, race, status, zone, items ({name=, bag=, extdata=, count=}, bag by its API
-- name, inventory unless given), wearing (slot name to the item's position in items), buffs (names), spells and
-- abilities (the names known; every one the resources hold unless given), tp (0 unless given), merits (the player's
-- merit levels by name, none unless given).
function Game.new(options)
    local game = setmetatable({}, Game)
    game.res = options.res
    -- os.clock in Windower counts from the game's start, long before an addon loads; Sel takes a clock near 0 for
    -- an action that has only just begun.
    game.clock = 1000
    game.sequence = 0
    game.next_event_id = 1
    game.handlers = {}
    game.timers = {}
    game.queue = {}
    game.sent = {}
    game.actions = {}
    game.typed = {}
    game.commands = {}
    game.chat_log = {}
    game.turns = {}
    game.last_packets = {incoming = {}, outgoing = {}}
    game.action_tables = {}
    game.info = {}
    game.others = {}
    game.next_index = 0x500

    local res = game.res
    local main_job_id = job_id(res, options.main_job or 'WHM')
    local sub_job_id = options.sub_job and job_id(res, options.sub_job) or 0
    local jobs = {}
    for id, job in pairs(res.jobs) do
        if type(job) == 'table' and job.ens then
            jobs[job.ens] = id == main_job_id and (options.main_job_level or 99)
                or id == sub_job_id and (options.sub_job_level or 49) or 1
        end
    end
    local job_points = {}
    for _, job in pairs(res.jobs) do
        if type(job) == 'table' and job.ens and job.ens ~= 'NON' then
            job_points[job.ens:lower()] = {jp = 0, jp_spent = 2100, cp = 0}
        end
    end

    game.player = {
        id = options.id or 0x100001,
        index = options.index or 0x400,
        name = options.name or 'Testy',
        main_job_id = main_job_id,
        main_job_level = options.main_job_level or 99,
        sub_job_id = sub_job_id,
        sub_job_level = sub_job_id ~= 0 and (options.sub_job_level or 49) or 0,
        jobs = jobs,
        job_points = job_points,
        superior_level = 5,
        item_level = 119,
        race = options.race or 1,
        status = options.status or 0,
        nation = 0,
        vitals = {hp = 1500, mp = 1000, max_hp = 1500, max_mp = 1000, hpp = 100, mpp = 100, tp = options.tp or 0},
        buffs = {},
        skills = {},
        merits = options.merits or {},
    }
    for _, name in ipairs(options.buffs or {}) do
        game.player.buffs[#game.player.buffs + 1] = (find_by_name(res.buffs, name, 'buff'))
    end

    game.zone = options.zone or 288
    game.monster = {
        id = 0x1069001, index = 0x001, name = 'Apex Toad', is_npc = true, spawn_type = 16, race = 0, status = 0,
        hpp = 100, distance = 9, x = 3, y = 0, z = 0, facing = 0, claim_id = 0, valid_target = true,
        model_size = 1, target_index = 0,
    }
    game.target_index = game.monster.index

    game.spells = {}
    if options.spells then
        for _, name in ipairs(options.spells) do
            game.spells[(find_by_name(res.spells, name, 'spell'))] = true
        end
    else
        for id in pairs(res.spells) do
            game.spells[id] = true
        end
    end
    game.job_abilities, game.weapon_skills, game.job_traits = {}, {}, {}
    local abilities = options.abilities
    for id, ability in pairs(res.job_abilities) do
        if type(ability) == 'table' and (not abilities or abilities[ability.en]) then
            game.job_abilities[#game.job_abilities + 1] = id
        end
    end
    for id, skill in pairs(res.weapon_skills) do
        if type(skill) == 'table' and (not abilities or abilities[skill.en]) then
            game.weapon_skills[#game.weapon_skills + 1] = id
        end
    end
    table.sort(game.job_abilities)
    table.sort(game.weapon_skills)

    game.bags = {}
    for id, bag in pairs(res.bags) do
        if type(bag) == 'table' then
            game.bags[id] = {api = bag.api, max = 80, items = {}}
        end
    end
    game.equipment = {}
    local placed = {}
    for position, item in ipairs(options.items or {}) do
        local bag_id = assert(game:bag_id(item.bag or 'inventory'), ('no bag named %s'):format(tostring(item.bag)))
        local item_id = find_by_name(res.items, item.name, 'item')
        local bag = game.bags[bag_id]
        local slot = #bag.items + 1
        bag.items[slot] = {id = item_id, count = item.count or 1, status = 0, slot = slot, bazaar = 0,
            extdata = item.extdata or string.char(0):rep(24)}
        placed[position] = {bag = bag_id, slot = slot}
    end
    for slot_name, position in pairs(options.wearing or {}) do
        local spot = placed[position]
        game.equipment[slot_ids[slot_name]] = spot
        game.bags[spot.bag].items[spot.slot].status = 5
    end

    game.windower = game:make_windower(options.paths)
    return game
end

-------------------------------------------------------------------------------------------------------------------
-- The state the Windower API reports. Each call hands out a new table, as Windower's do, since GearSwap writes into
-- the ones it gets.
-------------------------------------------------------------------------------------------------------------------

function Game:job_names(id)
    local job = self.res.jobs[id]
    return job and job.ens or 'NON', job and job.en or 'None'
end

-- What get_player reports: nothing while the game is still loading the character (loading = 'player'), and the
-- player without a main job id while it is still loading the job (loading = 'job'), as when the game has just started.
function Game:get_player()
    if self.loading == 'player' then
        return nil
    end
    local player = copy(self.player)
    player.main_job, player.main_job_full = self:job_names(player.main_job_id)
    if player.sub_job_id ~= 0 then
        player.sub_job, player.sub_job_full = self:job_names(player.sub_job_id)
    else
        player.sub_job_id, player.sub_job_level = nil, nil
    end
    player.target_index = self.target_index
    player.pet_index = self.pet and self.pet.index
    player.in_combat = self.player.status == 1
    if self.loading == 'job' then
        player.main_job_id = nil
    end
    return player
end

function Game:player_mob()
    local player = self.player
    return {
        id = player.id, index = player.index, name = player.name, is_npc = false, spawn_type = 13, race = player.race,
        status = player.status, hpp = player.vitals.hpp, mpp = player.vitals.mpp, tp = player.vitals.tp,
        distance = 0, x = self:player_x(), y = 0, z = 0, facing = 0, claim_id = 0, valid_target = true, in_party = true,
        in_alliance = true, model_size = 1, target_index = self.target_index or 0,
        pet_index = self.pet and self.pet.index,
    }
end

function Game:mobs()
    local mobs = {[self.player.index] = self:player_mob()}
    if self.monster then
        mobs[self.monster.index] = copy(self.monster)
    end
    if self.pet then
        mobs[self.pet.index] = copy(self.pet)
    end
    for _, other in ipairs(self.others) do
        mobs[other.index] = copy(other)
    end
    return mobs
end

-- The enemy the alliance has claimed, <bt>: the target if it is one, else the first such; nil when there is none.
function Game:battle_target()
    local claimants = {[self.player.id] = true}
    for _, other in ipairs(self.others) do
        if other.in_alliance then
            claimants[other.id] = true
        end
    end
    local mobs = self:mobs()
    local function claimed(index)
        local mob = index and mobs[index]
        return mob and mob.is_npc and claimants[mob.claim_id] and mob or nil
    end
    local found = claimed(self.target_index) or claimed(self.monster and self.monster.index)
    for _, other in ipairs(self.others) do
        found = found or claimed(other.index)
    end
    return found
end

-- The mob a target names: <me>, <t>, <bt>, <st>, <pet>, and the slots of the party and the alliance (<p0> to <p5>,
-- <a10> on).
function Game:mob_by_target(target)
    target = (target or ''):lower():gsub('^<(.*)>$', '%1')
    if target == 'me' or target == 'self' then
        return self:player_mob()
    elseif target == 'bt' then
        return self:battle_target()
    elseif target == 't' then
        return self.target_index and self:mobs()[self.target_index]
    elseif target == 'st' then
        return self.subtarget_index and self:mobs()[self.subtarget_index]
    elseif target == 'pet' then
        return self.pet and copy(self.pet)
    elseif target:match('^[pa]%d+$') then
        local member = self:get_party()[target]
        return member and member.mob
    end
end

function Game:mob_by_id(id)
    for _, mob in pairs(self:mobs()) do
        if mob.id == id then
            return mob
        end
    end
end

function Game:items_of(bag_id)
    local bag = self.bags[bag_id]
    local list = {max = bag.max, count = occupied(bag), enabled = not bag.disabled}
    for slot = 1, bag.max do
        list[slot] = copy(bag.items[slot]) or {id = 0, count = 0, status = 0, slot = slot, bazaar = 0, extdata = string.char(0):rep(24)}
    end
    return list
end

function Game:bag_id(name)
    if type(name) == 'number' then
        return name
    end
    for id, bag in pairs(self.bags) do
        if bag.api == name then
            return id
        end
    end
end

function Game:get_items(bag, index)
    if bag then
        local list = self:items_of(self:bag_id(bag))
        if index then
            return list[index]
        end
        return list
    end
    local all = {equipment = {}, gil = 0}
    for id, data in pairs(self.bags) do
        all[data.api] = self:items_of(id)
        all['count_' .. data.api], all['max_' .. data.api], all['enabled_' .. data.api] = occupied(data), data.max,
            not data.disabled
    end
    for id, name in pairs(slot_names) do
        local spot = self.equipment[id]
        all.equipment[name] = spot and spot.slot or 0
        all.equipment[name .. '_bag'] = spot and spot.bag or 0
    end
    return all
end

function Game:get_bag_info()
    local info = {}
    for _, bag in pairs(self.bags) do
        info[bag.api] = {max = bag.max, count = occupied(bag), enabled = not bag.disabled}
    end
    return info
end

-- What the game reports of itself, with the fields set_info changed laid over it.
function Game:get_info()
    local info = {logged_in = true, zone = self.zone, server = 1, language = 'English', weather = 0, day = 0,
        moon = 50, moon_phase = 0, time = 720, mog_house = false, menu_open = false, chat_open = false,
        target_arrow = {x = 0, y = 0, z = 0}}
    for key, value in pairs(self.info) do
        info[key] = copy(value)
    end
    return info
end

-- The party list: the player as p0, then each other player in the party in the order they joined, and those in the
-- slot they were given (a10 to a15 and a20 to a25 for the alliance's other parties). The player leads the party
-- unless a member who leads theirs (leader) is in it; another party's leader and the alliance's (alliance_leader)
-- are the members who lead them.
function Game:get_party()
    local player = self.player
    local party = {
        p0 = {name = player.name, mob = self:player_mob(), hp = player.vitals.hp, mp = player.vitals.mp,
            tp = player.vitals.tp, hpp = player.vitals.hpp, mpp = player.vitals.mpp, zone = self.zone},
        party1_leader = player.id, party1_count = 1, party2_count = 0, party3_count = 0,
    }
    for _, other in ipairs(self.others) do
        local slot = other.slot or other.in_party and 'p' .. party.party1_count
        if slot then
            party[slot] = {name = other.name, mob = copy(other), hp = other.hp, mp = other.mp, tp = other.tp,
                hpp = other.hpp, mpp = other.mpp, zone = self.zone}
            local number = slot:match('^p') and 1 or slot:match('^a1') and 2 or 3
            party['party' .. number .. '_count'] = party['party' .. number .. '_count'] + 1
            if other.leader then
                party['party' .. number .. '_leader'] = other.id
            end
            if other.alliance_leader then
                party.alliance_leader = other.id
            end
        end
    end
    return party
end

-- What get_mjob_data reports. A blue mage's spells are its 20 set slots, by spell id, 512 in an empty one: here
-- the blue magic it knows, the lowest ids first, all of it even past 20 so a spell added to the resources never falls
-- out of the set; a test that wants a spell out of it leaves it unknown. A puppetmaster's is its automaton, a
-- Monipulator's its species.
function Game:mjob_data()
    local job = self.res.jobs[self.player.main_job_id].ens
    if job == 'PUP' then
        return self:automaton_data()
    elseif job == 'MON' then
        return {species = self.species}
    elseif job ~= 'BLU' then
        return {}
    end
    local set = {}
    for id in pairs(self.spells) do
        if self.res.spells[id] and self.res.spells[id].type == 'BlueMagic' then
            set[#set + 1] = id
        end
    end
    table.sort(set)
    for slot = 1, 20 do
        set[slot] = set[slot] or 512
    end
    return {spells = set}
end

-- The recast of each job ability the character knows, by recast id, in seconds: every one ready.
function Game:ability_recasts()
    local recasts = {}
    for _, id in ipairs(self.job_abilities) do
        local ability = self.res.job_abilities[id]
        if ability.recast_id then
            recasts[ability.recast_id] = self:ability_recast(ability.recast_id)
        end
    end
    return recasts
end

-- Seconds left on the recast of the abilities with that recast id: 0 once they are ready again.
function Game:ability_recast(recast_id)
    local ready = self.abilities_ready_at and self.abilities_ready_at[recast_id]
    return ready and math.max(0, ready - self.clock) or 0
end

-- What get_spell_recasts reports for the spell: the time left on its recast in 60ths of a second, as Windower
-- counts it, 0 once it is ready again.
function Game:spell_recast(spell_id)
    local ready = self.spells_ready_at and self.spells_ready_at[spell_id]
    return ready and math.max(0, ready - self.clock) * 60 or 0
end

-- Where the character stands along x: walking (walk()) moves it on five yalms a second.
function Game:player_x()
    local x = self.walked or 0
    if self.walking_since then
        x = x + 5 * (self.clock - self.walking_since)
    end
    return x
end

-- Lays these fields over what get_info reports from here on: time (minutes past midnight), day and weather (by id),
-- mog_house, target_arrow and the like. No event says so; set_time, set_day and set_weather send theirs.
function Game:set_info(fields)
    for key, value in pairs(fields) do
        self.info[key] = value
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Events, the queue and the clock.
-------------------------------------------------------------------------------------------------------------------

-- Registers the handler, the last argument, for each event the arguments before it name, under one id.
function Game:register(...)
    local arguments = {...}
    local handler = table.remove(arguments)
    local id = self.next_event_id
    self.next_event_id = id + 1
    for _, event in ipairs(arguments) do
        self.handlers[event] = self.handlers[event] or {}
        table.insert(self.handlers[event], {id = id, handler = handler})
    end
    return id
end

function Game:unregister(id)
    for _, list in pairs(self.handlers) do
        for i = #list, 1, -1 do
            if list[i].id == id then
                table.remove(list, i)
            end
        end
    end
end

-- Calls each handler of the event in the order they were registered, and returns what the last one returned.
function Game:fire(event, ...)
    local result
    for _, entry in ipairs(copy(self.handlers[event] or {})) do
        result = entry.handler(...)
    end
    return result
end

-- Calls the outgoing chunk handlers on a packet the client sends, as Windower does: a handler that returns true
-- blocks it, and each after it is told so. Returns whether one did.
function Game:outgoing_chunk(id, data, injected)
    local blocked = false
    for _, entry in ipairs(copy(self.handlers['outgoing chunk'] or {})) do
        if entry.handler(id, data, data, injected, blocked) == true then
            blocked = true
        end
    end
    return blocked
end

function Game:enqueue(kind, ...)
    self.queue[#self.queue + 1] = {kind = kind, ...}
end

-- Handles what waits in the queue, and what that adds to it, until nothing is left.
function Game:settle()
    local handled = 0
    while #self.queue > 0 do
        handled = handled + 1
        if handled > 10000 then
            error('the game queue never emptied; something keeps adding to it', 2)
        end
        local entry = table.remove(self.queue, 1)
        if entry.kind == 'incoming' then
            self:deliver_incoming(entry[1], entry[2], entry[3])
        elseif entry.kind == 'outgoing' then
            if not self:outgoing_chunk(entry[1], entry[2], true) then
                self:serve(entry[1], entry[2], entry[3])
            end
        elseif entry.kind == 'event' then
            self:fire(unpack(entry))
        elseif entry.kind == 'command' then
            self:run_command(entry[1])
        elseif entry.kind == 'input' then
            self:input(entry[1])
        end
    end
end

-- Runs fn at the clock's time plus delay, inside a coroutine, as coroutine.schedule does. A coroutine that yields a
-- number of seconds (coroutine.sleep) is resumed that much later.
function Game:schedule(fn, delay, ...)
    local co = type(fn) == 'thread' and fn or real_coroutine.create(fn)
    self.timers[#self.timers + 1] = {at = self.clock + (delay or 0), co = co, arguments = {...}}
    return co
end

function Game:cancel(co)
    for i = #self.timers, 1, -1 do
        if self.timers[i].co == co then
            table.remove(self.timers, i)
        end
    end
end

function Game:advance(seconds)
    local finish = self.clock + (seconds or 0)
    self:settle()
    local ran = 0
    while true do
        ran = ran + 1
        if ran > 10000 then
            error('the game\'s timers never ran out; something keeps setting more', 2)
        end
        local due
        for i, timer in ipairs(self.timers) do
            if timer.at <= finish and (not due or timer.at < self.timers[due].at) then
                due = i
            end
        end
        if not due then
            break
        end
        local timer = table.remove(self.timers, due)
        self.clock = math.max(self.clock, timer.at)
        local results = {real_coroutine.resume(timer.co, unpack(timer.arguments))}
        if not results[1] then
            error(debug.traceback(timer.co, results[2]), 0)
        end
        if real_coroutine.status(timer.co) == 'suspended' then
            local wait = tonumber(results[2]) or tonumber(results[3]) or 0
            self.timers[#self.timers + 1] = {at = self.clock + wait, co = timer.co, arguments = {}}
        end
        self:settle()
    end
    self.clock = finish
    self:settle()
end

-- Moves the clock on as the game does, a frame at a time, each frame a tenth of a second: the timers due run, then
-- the prerender handlers, which Sel's tick and its checks of movement hang on, then the game settles.
function Game:play(seconds)
    local frames = math.floor((seconds or 0) * 10 + 0.5)
    for _ = 1, frames do
        self:advance(0.1)
        self:fire('prerender')
        self:settle()
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Commands and chat input.
-------------------------------------------------------------------------------------------------------------------

-- Splits a command line at its semicolons, leaving those inside quotes.
local function split_commands(line)
    local commands, current, quoted = {}, {}, false
    for char in line:gmatch('.') do
        if char == '"' then
            quoted = not quoted
        end
        if char == ';' and not quoted then
            commands[#commands + 1] = table.concat(current)
            current = {}
        else
            current[#current + 1] = char
        end
    end
    commands[#commands + 1] = table.concat(current)
    return commands
end

-- Splits a command's words at spaces, keeping a quoted phrase as one word without its quotes.
local function split_words(command)
    local words = {}
    local position = 1
    while true do
        local start = command:find('%S', position)
        if not start then
            return words
        end
        if command:sub(start, start) == '"' then
            local finish = command:find('"', start + 1, true) or #command + 1
            words[#words + 1] = command:sub(start + 1, finish - 1)
            position = finish + 1
        else
            local finish = command:find('%s', start) or #command + 1
            words[#words + 1] = command:sub(start, finish - 1)
            position = finish
        end
    end
end

-- Runs a line as Windower's console would: each command in turn, with a wait putting off the ones after it.
function Game:run_command(line)
    local commands = split_commands(line)
    for i, command in ipairs(commands) do
        command = command:gsub('^%s+', ''):gsub('%s+$', ''):gsub('^@+', '')
        local words = split_words(command)
        local verb = words[1] and words[1]:lower()
        if verb == 'wait' then
            local rest = table.concat(commands, ';', i + 1)
            if rest ~= '' then
                self:schedule(function()
                    self:enqueue('command', rest)
                end, tonumber(words[2]) or 0)
            end
            return
        elseif verb then
            self.commands[#self.commands + 1] = command
            if verb == 'gs' or verb == 'gearswap' then
                self:fire('addon command', select(2, unpack(words)))
            elseif verb == 'lua' and (words[2] == 'i' or words[2] == 'invoke') and words[3] and words[3]:lower() == 'gearswap' then
                self.invoke(words[4], select(5, unpack(words)))
            elseif verb == 'input' then
                self:input(command:match('^%S+%s+(.*)$') or '')
            end
        end
    end
end

-- Text typed into the chat line, or sent by chat.input: the outgoing text handlers see it first, and what they let
-- through the game would act on.
function Game:input(text)
    local modified = text
    for _, entry in ipairs(copy(self.handlers['outgoing text'] or {})) do
        local result = entry.handler(text, modified)
        if result == true then
            return true
        elseif type(result) == 'string' then
            modified = result
        end
    end
    if modified ~= '' then
        self.typed[#self.typed + 1] = modified
    end
    return modified
end

-------------------------------------------------------------------------------------------------------------------
-- Packets: what the addon injects, and the server's answers.
-------------------------------------------------------------------------------------------------------------------

function Game:next_sequence()
    self.sequence = (self.sequence + 1) % 65536
    return self.sequence
end

function Game:receive(id, body)
    local size = 4 + #body
    local data = pad(packet_header(id, size, self:next_sequence()) .. body, 4 * math.ceil(size / 4))
    self:enqueue('incoming', id, data)
    return data
end

function Game:deliver_incoming(id, data, injected)
    self.last_packets.incoming[id] = {data, self.clock}
    self:fire('incoming chunk', id, data, data, injected or false, false)
    if id == 0x028 then
        local act = self.action_tables[data]
        if act then
            self:fire('action', copy(act))
        end
    end
end

-- Whether the item in that bag and bag slot can go in the equipment slot, as the server judges it.
function Game:wearable(bag_id, bag_slot, slot_id)
    local bag = self.bags[bag_id]
    local item = bag and bag.items[bag_slot]
    local entry = item and self.res.items[item.id]
    if not entry or not entry.slots or not has_bit(entry.slots, slot_id) or not self.res.bags[bag_id].equippable then
        return false
    end
    -- A weapon in the sub slot takes the Dual Wield trait; a shield or a grip, which has no skill, doesn't.
    if slot_names[slot_id] == 'sub' and (entry.skill or 0) > 0 and not self:has_job_trait('Dual Wield') then
        return false
    end
    local player = self.player
    return has_bit(entry.jobs, player.main_job_id) and (entry.level or 0) <= player.main_job_level
        and has_bit(entry.races, player.race)
end

-- Carries out one equip request, as four bytes: bag slot, equipment slot, bag. Returns the bytes to confirm it
-- with, or nil when the server refuses it, as it refuses every one in a game with refuse_equips set.
function Game:equip_chunk(chunk)
    if self.refuse_equips then
        return nil
    end
    local bag_slot, slot_id, bag_id = chunk:byte(1), chunk:byte(2), chunk:byte(3)
    local current = self.equipment[slot_id]
    if bag_slot == 0 then
        if current then
            self.bags[current.bag].items[current.slot].status = 0
        end
        self.equipment[slot_id] = nil
        return string.char(0, slot_id, 0, 0)
    end
    if not self:wearable(bag_id, bag_slot, slot_id) then
        return nil
    end
    for other, spot in pairs(self.equipment) do
        if spot.bag == bag_id and spot.slot == bag_slot and other ~= slot_id then
            self.equipment[other] = nil
        end
    end
    if current then
        self.bags[current.bag].items[current.slot].status = 0
    end
    self.equipment[slot_id] = {bag = bag_id, slot = bag_slot}
    self.bags[bag_id].items[bag_slot].status = 5
    return string.char(bag_slot, slot_id, bag_id, 0)
end

-- The equipset reply (0x117): the request as it came, then what is worn in each slot.
function Game:equipset_reply(request)
    local count = request:byte(5)
    local body = string.char(count, 0, 0, 0) .. request:sub(9, 8 + 4 * count)
    body = pad(body, 0x44)
    for id = 0, 15 do
        local spot = self.equipment[id]
        body = body .. (spot and string.char(spot.slot, id, spot.bag, 0) or string.char(0, id, 0, 0))
    end
    return body
end

-- The resource an action request (0x01A) names its action from, by the request's category.
local action_resources = {[3] = 'spells', [7] = 'weapon_skills', [9] = 'job_abilities', [25] = 'monster_skills'}

-- A packet the addon sends. It is noted as sent at once, with what it asks for named as things stand when it goes:
-- equip (slot to item name, or 'empty') for an equip request, action ({target_id =, target_index =, category =,
-- param =, name =, target =}) for an action, used ({item =, target =}) for the use of an item. The outgoing chunk
-- handlers see it as the game settles, and the server's side follows.
function Game:inject_outgoing(id, data)
    self.last_packets.outgoing[id] = {data, self.clock}
    local packet = {id = id, data = data, at = self.clock}
    if id == 0x050 or id == 0x051 then
        packet.equip = self:equip_request(packet)
    elseif id == 0x01A then
        local action = {target_id = read_u32(data, 5), target_index = read_u16(data, 9), category = read_u16(data, 11),
            param = read_u16(data, 13)}
        local resource = self.res[action_resources[action.category] or '']
        local entry = resource and resource[action.param]
        local target = self:mob_by_id(action.target_id)
        action.name = entry and entry.en or ('category %d'):format(action.category)
        action.target = target and target.name
        packet.action = action
    elseif id == 0x037 then
        local bag = self.bags[data:byte(17)]
        local item = bag and bag.items[data:byte(15)]
        local target = self:mob_by_id(read_u32(data, 5))
        packet.used = {item = item and self.res.items[item.id].en, target = target and target.name}
    end
    self.sent[#self.sent + 1] = packet
    self:enqueue('outgoing', id, data, packet)
end

-- The server's side of a packet the addon sent and no handler blocked: an equip request carried out and confirmed,
-- or refused; an action taken in, and a moogle's menu opened for a talk to one; a move between bags made.
function Game:serve(id, data, packet)
    if id == 0x050 then
        local reply = self:equip_chunk(data:sub(5, 8))
        if reply then
            self:receive(0x050, reply)
        end
    elseif id == 0x051 then
        for i = 1, data:byte(5) do
            local reply = self:equip_chunk(data:sub(5 + 4 * i, 8 + 4 * i))
            if reply then
                self:receive(0x050, reply)
            end
        end
        self:receive(0x117, self:equipset_reply(data))
    elseif id == 0x01A then
        local action = packet.action
        self.actions[#self.actions + 1] = action
        local moogle = action.category == 0 and self:mob_by_id(action.target_id)
        if moogle and moogle.name:find('Moogle') then
            self.moogle_menu = true
            self:receive(0x02E, u32(0))
        end
    elseif id == 0x029 then
        self:move_item(read_u32(data, 5), data:byte(9), data:byte(10), data:byte(11))
    end
end

-- The categories of the action packet that begin an action rather than say what it did: a TP move or weapon skill
-- readied (7), a spell begun (8), an item begun (9) and a ranged attack begun (12).
local beginning_categories = {[7] = true, [8] = true, [9] = true, [12] = true}

-- A monster no one has claimed is claimed by the player when an action of theirs lands on it, or one of its own on
-- them.
function Game:claim(monster_id, player_id)
    local mobs = {self.monster}
    for _, other in ipairs(self.others) do
        mobs[#mobs + 1] = other
    end
    for _, mob in pairs(mobs) do
        if mob.id == monster_id and mob.is_npc and mob.spawn_type == 16 and mob.claim_id == 0 then
            mob.claim_id = player_id
        end
    end
end

-- The action packet (0x028) for an action of the player's, as Windower's parse_action gives it. The packet's bytes
-- only carry the header; parse_action and the action event hand out this table for them.
function Game:send_action_packet(act)
    act.actor_id = act.actor_id or self.player.id
    act.target_count = #act.targets
    if act.actor_id == self.player.id and not beginning_categories[act.category] then
        for _, target in ipairs(act.targets) do
            self:claim(target.id, self.player.id)
        end
    end
    local data = self:receive(0x028, u32(act.actor_id) .. string.char(#act.targets, act.category, 0, 0) .. u32(self.sequence))
    self.action_tables[data] = act
    return data
end

-- The action message packet (0x029), in the bytes GearSwap reads.
function Game:send_action_message(fields)
    local body = u32(fields.actor_id or self.player.id) .. u32(fields.target_id or self.player.id)
        .. u32(fields.param_1 or 0) .. u32(fields.param_2 or 0)
        .. u16(fields.actor_index or self.player.index) .. u16(fields.target_index or self.player.index)
        .. u16(fields.message_id or 0) .. u16(0)
    return self:receive(0x029, body)
end

-- The buff packet (0x063, type 9): the player's 32 buff slots, then when each wears off. Given buffs, each
-- {name = , expires = }, the player's buffs become those first; expires is when it wears off, in seconds on the
-- game's clock, 600 seconds on unless given. The times count from the game's clock, not from the epoch GearSwap
-- counts a buff's duration from, so the durations it works out are meaningless; a test of a duration sets the times
-- right first.
function Game:send_buffs(buffs)
    local expires = {}
    if buffs then
        self.player.buffs = {}
        for i, buff in ipairs(buffs) do
            self.player.buffs[i] = (find_by_name(self.res.buffs, buff.name, 'buff'))
            expires[i] = buff.expires
        end
    end
    local ids, times = {}, {}
    for i = 1, 32 do
        local id = self.player.buffs[i]
        ids[i] = u16(id or 255)
        times[i] = u32(id and (expires[i] or self.clock + 600) * 60 or 0)
    end
    return self:receive(0x063, string.char(9, 0, 0, 0) .. table.concat(ids) .. table.concat(times))
end

-- The party buff packet (0x076) for up to five members, each {id = , index = , buffs = {buff ids}}.
function Game:send_party_buffs(members)
    local body = {}
    for i = 1, 5 do
        local member = members[i]
        local mask, low = {0, 0, 0, 0, 0, 0, 0, 0}, {}
        for n = 1, 32 do
            local id = member and member.buffs and member.buffs[n] or 255
            low[n] = string.char(id % 256)
            local byte = math.floor((n - 1) / 4) + 1
            mask[byte] = mask[byte] + math.floor(id / 256) * 4 ^ ((n - 1) % 4)
        end
        body[i] = u32(member and member.id or 0) .. u16(member and member.index or 0) .. string.char(0, 0)
            .. string.char(unpack(mask)) .. table.concat(low)
    end
    return self:receive(0x076, table.concat(body))
end

-- The body of the packet the server sends, as Windower's packets library builds it from its field definitions:
-- fields are the values by label, and the rest are zeros.
function Game:packet_body(id, fields)
    local packets = assert(self.packets, 'the game builds a packet by its labels only with the packets library '
        .. 'of the addon it plays, which the harness hands it once GearSwap has loaded')
    return packets.build(packets.new('incoming', id, fields or {})):sub(5)
end

-- The server sends the packet, built from its fields by label.
function Game:send(id, fields)
    return self:receive(id, self:packet_body(id, fields))
end

-- A packet GearSwap has no handler for. The addon acts on a pet's coming or going, and on its change of status, with
-- the packet that follows the one that told of them.
function Game:next_packet()
    return self:receive(0x0FF, '')
end

-- A packet the client sends of its own: the outgoing chunk handlers see it as it goes, not as injected. Returns
-- whether one of them blocked it. One that none blocks goes no further: the server never answers it, so an equip
-- request sent this way is not carried out.
function Game:send_from_client(id, body)
    local size = 4 + #body
    local data = pad(packet_header(id, size, self:next_sequence()) .. body, 4 * math.ceil(size / 4))
    self.last_packets.outgoing[id] = {data, self.clock}
    return self:outgoing_chunk(id, data, false)
end

-- Writes bytes into a packet's body at a position counted, as GearSwap counts it, from the packet's first byte.
local function put(body, position, bytes)
    return body:sub(1, position - 5) .. bytes .. body:sub(position - 4 + #bytes)
end

-- The zone-in packet (0x00A) for the character and zone as the game holds them, with fields, by label, laid over
-- it: the Mog House flag is in _unknown7's last byte, for one.
function Game:send_zone_in(fields)
    local player = self.player
    local values = {
        ['Player'] = player.id, ['Player Index'] = player.index, ['Zone'] = self.zone, ['Player Name'] = player.name,
        ['Main Job'] = player.main_job_id, ['Sub Job'] = player.sub_job_id, ['Weather'] = self:get_info().weather,
        ['Race'] = player.race, ['MH Door Menu'] = 0, ['Max HP'] = player.vitals.max_hp,
        ['Max MP'] = player.vitals.max_mp,
        ['STR'] = 10, ['DEX'] = 10, ['VIT'] = 10, ['AGI'] = 10, ['INT'] = 10, ['MND'] = 10, ['CHR'] = 10,
    }
    for label, value in pairs(fields or {}) do
        values[label] = value
    end
    return self:send(0x00A, values)
end

-- The char stats packet (0x061), in the bytes GearSwap reads: maximum HP and MP, and the jobs and their levels.
function Game:send_char_stats()
    local player = self.player
    local body = string.char(0):rep(0x50)
    body = put(body, 0x05, u32(player.vitals.max_hp) .. u32(player.vitals.max_mp))
    body = put(body, 0x0D, string.char(player.main_job_id, player.main_job_level, player.sub_job_id, player.sub_job_level))
    return self:receive(0x061, body)
end

-------------------------------------------------------------------------------------------------------------------
-- The Windower API.
-------------------------------------------------------------------------------------------------------------------

local function noop() end

function Game:make_windower(paths)
    local game = self
    paths = paths or {}
    local text_objects = {}
    local windower
    windower = {
        addon_path = paths.addon,
        windower_path = paths.windower,
        version = '4.3.0.0',
        debug = noop,
        register_event = function(...) return game:register(...) end,
        raw_register_event = function(...) return game:register(...) end,
        unregister_event = function(id) game:unregister(id) end,
        send_command = function(command) game:enqueue('command', command) end,
        add_to_chat = function(color, text) game.chat_log[#game.chat_log + 1] = {color = color, text = text} end,
        chat = {input = function(text) game:enqueue('input', text) end},
        to_shift_jis = function(text) return text end,
        from_shift_jis = function(text) return text end,
        convert_auto_trans = function(text) return text end,
        -- Matches text to a pattern in which * stands for any run of characters and ? for any one.
        wc_match = function(text, pattern)
            local lua_pattern = '^' .. pattern:gsub('[%^%$%(%)%%%.%[%]%+%-]', '%%%0'):gsub('%*', '.*'):gsub('%?', '.') .. '$'
            return text:match(lua_pattern) ~= nil
        end,
        copy_to_clipboard = noop,
        get_windower_settings = function()
            return {ui_x_res = 1920, ui_y_res = 1080, x_res = 1920, y_res = 1080, window_x_pos = 0, window_y_pos = 0}
        end,
        file_exists = function(path)
            local resolved = resolve(path)
            return resolved ~= nil and lfs.attributes(resolved, 'mode') == 'file'
        end,
        dir_exists = function(path)
            local resolved = resolve((path:gsub('[/\\]$', '')))
            return resolved ~= nil and lfs.attributes(resolved, 'mode') == 'directory'
        end,
        create_dir = function(path)
            local built = path:sub(1, 1) == '/' and '' or '.'
            for part in path:gmatch('[^/\\]+') do
                built = built .. '/' .. part
                if not lfs.attributes(built) then
                    lfs.mkdir(built)
                end
            end
            return true
        end,
        get_dir = function(path)
            local names = {}
            local resolved = resolve((path:gsub('[/\\]$', '')))
            if resolved then
                for entry in lfs.dir(resolved) do
                    if entry ~= '.' and entry ~= '..' then
                        names[#names + 1] = entry
                    end
                end
            end
            table.sort(names)
            return names
        end,
        text = {
            create = function(name) text_objects[name] = {} end,
            delete = function(name) text_objects[name] = nil end,
        },
        prim = {create = noop, delete = noop},
        packets = {
            inject_outgoing = function(id, data) game:inject_outgoing(id, data) end,
            inject_incoming = function(id, data) game:enqueue('incoming', id, data, true) end,
            last_incoming = function(id) return unpack(game.last_packets.incoming[id] or {}) end,
            last_outgoing = function(id) return unpack(game.last_packets.outgoing[id] or {}) end,
            parse_action = function(data) return copy(game.action_tables[data]) end,
        },
        ffxi = {
            get_player = function() return game:get_player() end,
            get_mob_by_target = function(target) return game:mob_by_target(target) end,
            get_mob_by_id = function(id) return game:mob_by_id(id) end,
            get_mob_by_index = function(index) return game:mobs()[index] end,
            get_mob_by_name = function(name)
                for _, mob in pairs(game:mobs()) do
                    if mob.name == name then return mob end
                end
            end,
            get_mob_array = function() return game:mobs() end,
            get_mob_list = function(name)
                local list = {}
                for index, mob in pairs(game:mobs()) do
                    if not name or mob.name == name then list[index] = mob.name end
                end
                return list
            end,
            get_items = function(bag, index) return game:get_items(bag, index) end,
            get_bag_info = function(bag)
                local info = game:get_bag_info()
                if bag then return info[game.bags[game:bag_id(bag)].api] end
                return info
            end,
            get_info = function() return game:get_info() end,
            get_party = function() return game:get_party() end,
            get_spells = function() return copy(game.spells) end,
            get_abilities = function()
                return {job_abilities = copy(game.job_abilities), weapon_skills = copy(game.weapon_skills),
                    job_traits = copy(game.job_traits)}
            end,
            get_spell_recasts = function()
                local recasts = {}
                for id in pairs(game.res.spells) do recasts[id] = game:spell_recast(id) end
                return recasts
            end,
            get_ability_recasts = function() return game:ability_recasts() end,
            get_mjob_data = function() return game:mjob_data() end,
            get_sjob_data = function() return {} end,
            get_key_items = function() return {} end,
            get_position = function() return '(?-?)' end,
            turn = function(angle) game.turns[#game.turns + 1] = angle end,
            run = noop, follow = noop, toggle_walk = noop,
        },
    }
    for name in pairs({set_text = true, set_location = true, set_visibility = true, set_color = true,
        set_bg_color = true, set_bg_visibility = true, set_font = true, set_font_size = true, set_bold = true,
        set_italic = true, set_stroke_width = true, set_stroke_color = true, set_bg_border_size = true,
        set_right_justified = true, set_bottom_justified = true, set_pad = true, set_stroke_transparency = true,
        set_bg_transparency = true, set_transparency = true}) do
        windower.text[name] = noop
        windower.prim[name] = noop
    end
    windower.text.get_extents = function() return 0, 0 end
    windower.text.get_location = function() return 0, 0 end
    return windower
end

-------------------------------------------------------------------------------------------------------------------
-- What the tests ask of the game.
-------------------------------------------------------------------------------------------------------------------

-- The name of the item worn in each slot, by GearSwap's slot names; empty slots are left out.
function Game:worn()
    local worn = {}
    for id, spot in pairs(self.equipment) do
        local item = self.bags[spot.bag].items[spot.slot]
        worn[slot_names[id]] = self.res.items[item.id].en
    end
    return worn
end

-- What an equip packet (0x050 or 0x051) asks for, as {slot = item name, or 'empty'}.
function Game:equip_request(packet)
    local chunks = {}
    if packet.id == 0x050 then
        chunks[1] = packet.data:sub(5, 8)
    elseif packet.id == 0x051 then
        for n = 1, packet.data:byte(5) do
            chunks[n] = packet.data:sub(5 + 4 * n, 8 + 4 * n)
        end
    end
    local request = {}
    for _, chunk in ipairs(chunks) do
        local bag_slot, slot_id, bag_id = chunk:byte(1), chunk:byte(2), chunk:byte(3)
        local item = bag_slot ~= 0 and self.bags[bag_id].items[bag_slot]
        request[slot_names[slot_id]] = item and self.res.items[item.id].en or 'empty'
    end
    return request
end

function Game:gain_buff(name)
    local id = find_by_name(self.res.buffs, name, 'buff')
    table.insert(self.player.buffs, id)
    self:send_buffs()
    self:fire('gain buff', id)
end

function Game:lose_buff(name)
    local id = find_by_name(self.res.buffs, name, 'buff')
    for i, buff in ipairs(self.player.buffs) do
        if buff == id then
            table.remove(self.player.buffs, i)
            break
        end
    end
    self:send_buffs()
    self:fire('lose buff', id)
end

function Game:set_status(status)
    local old = self.player.status
    self.player.status = status
    self:fire('status change', status, old)
end

-- Puts the job ability on recast for that many seconds, as the server does once it is used.
function Game:start_ability_recast(name, seconds)
    local _, ability = find_by_name(self.res.job_abilities, name, 'job ability')
    self.abilities_ready_at = self.abilities_ready_at or {}
    self.abilities_ready_at[ability.recast_id] = self.clock + seconds
end

-- The job traits the character has from now on, by name, as get_abilities reports them; none unless set.
function Game:set_job_traits(names)
    self.job_traits = {}
    for i, name in ipairs(names) do
        self.job_traits[i] = (find_by_name(self.res.job_traits, name, 'job trait'))
    end
end

function Game:has_job_trait(name)
    for _, id in ipairs(self.job_traits) do
        if self.res.job_traits[id].en == name then
            return true
        end
    end
    return false
end

-- Puts the spell on recast for that many seconds, as the server does once it is cast.
function Game:start_spell_recast(name, seconds)
    local id = find_by_name(self.res.spells, name, 'spell')
    self.spells_ready_at = self.spells_ready_at or {}
    self.spells_ready_at[id] = self.clock + seconds
end

-- The character's TP changes, as it does with each hit and weapon skill, and Windower's tp change event follows.
function Game:set_tp(tp)
    local old = self.player.vitals.tp
    self.player.vitals.tp = tp
    self:fire('tp change', tp, old)
end

-- The character starts walking, and moves on until it stands again.
function Game:walk()
    self.walked = self:player_x()
    self.walking_since = self.clock
end

function Game:stand()
    self.walked = self:player_x()
    self.walking_since = nil
end

-- The message of each kind of action of a monster's, by its category: a melee hit (1), a spell cast (4), a TP move
-- readied (7, 'readies') and used (11), a spell begun (8, 'starts casting').
local monster_messages = {[1] = 1, [4] = 2, [7] = 43, [8] = 327, [11] = 185}

-- An action of the monster's at a target, the character unless given an id, as the action packet the server sends
-- of it. name is the TP move or spell, by its English name; a melee hit has none. The packet that begins an action
-- names it in its target's action, with 24931 as its own param. A monster no one has claimed is claimed by the
-- player it acts on.
function Game:monster_acts(category, name, target_id)
    local resource = (category == 7 or category == 11) and 'monster_abilities'
        or (category == 4 or category == 8) and 'spells'
    local id = resource and find_by_name(self.res[resource], name, resource) or 0
    local begins = category == 7 or category == 8
    target_id = target_id or self.player.id
    local target = self:mob_by_id(target_id)
    if target and not target.is_npc then
        self:claim(self.monster.id, target_id)
    end
    return self:send_action_packet({actor_id = self.monster.id, category = category, param = begins and 24931 or id,
        targets = {{id = target_id, actions = {{message = monster_messages[category],
            param = begins and id or 50, reaction = 0, animation = 0, effect = 0, stagger = 0}}}}})
end

-- The monster begins readying a TP move at the character.
function Game:monster_readies(name)
    return self:monster_acts(7, name)
end

-- The monster hits the character with a melee swing.
function Game:monster_hits()
    return self:monster_acts(1)
end

-- The items the addon used (the use item packet, 0x037), in order, as {item = name, target = name}.
function Game:items_used()
    local used = {}
    for _, packet in ipairs(self.sent) do
        if packet.used then
            used[#used + 1] = packet.used
        end
    end
    return used
end

-- Moves Vana'diel's clock to minutes past midnight, and fires the event that says so.
function Game:set_time(minutes)
    local old = self:get_info().time
    self:set_info({time = minutes})
    self:fire('time change', minutes, old)
end

-- Makes it the day of that id (res.days), and fires the event that says so.
function Game:set_day(id)
    local old = self:get_info().day
    self:set_info({day = id})
    self:fire('day change', id, old)
end

-- Makes the weather that of that id (res.weather), and fires the event that says so.
function Game:set_weather(id)
    local old = self:get_info().weather
    self:set_info({weather = id})
    self:fire('weather change', id, old)
end

-- The client leaving its zone, as on zoning or logging out: its leave-zone packet (0x00D).
function Game:leave_zone()
    self:send_from_client(0x00D, string.char(0):rep(4))
end

-- Zones the character into the zone of that id as the game does: the leave-zone packet out, the zone-out answer
-- (0x00B), the zone-in packet (0x00A) and the buff packet after it in, then the zone change event.
function Game:change_zone(zone_id)
    local old = self.zone
    self:leave_zone()
    self:receive(0x00B, string.char(0):rep(0x18))
    self.zone = zone_id
    self:send_zone_in()
    self:send_buffs()
    self:settle()
    self:fire('zone change', zone_id, old)
end

-- Changes the character's sub job (by its short name) and its level, as at a Moogle, with the char stats packet
-- that tells of it.
function Game:change_sub_job(short, level)
    self.player.sub_job_id = job_id(self.res, short)
    self.player.sub_job_level = level or 49
    self.player.jobs[short] = self.player.sub_job_level
    self:send_char_stats()
end

-- Changes the character's main job (by its short name) and its level, as at a Moogle: the client asks with the job
-- change packet (0x100), the server takes every piece off, and answers with the char stats packet.
function Game:change_main_job(short, level)
    local id = job_id(self.res, short)
    self:send_from_client(0x100, string.char(id, self.player.sub_job_id, 0, 0))
    for slot_id, spot in pairs(self.equipment) do
        self.bags[spot.bag].items[spot.slot].status = 0
        self.equipment[slot_id] = nil
    end
    self.player.main_job_id = id
    self.player.main_job_level = level or 99
    self.player.jobs[short] = self.player.main_job_level
    self:send_char_stats()
end

-------------------------------------------------------------------------------------------------------------------
-- A pet of the player's (a puppetmaster's automaton, a geomancer's luopan) and the geomancer's indicolure. A pet is a
-- mob the player's mob names by its pet_index. The addon learns of the pet from the character update (0x037), which
-- also carries the indicolure, and acts on it with the packet after; of its status from 0x00E and of its TP from
-- 0x068.
-------------------------------------------------------------------------------------------------------------------

-- The body of a packet of that many bytes, zeros but for the bytes put at the 1-based positions the packets library
-- reads them from.
local function bytes_body(size, bytes)
    local body = {}
    for position = 5, size do
        body[position - 4] = bytes[position] or 0
    end
    return string.char(unpack(body))
end

-- The character update the server sends when the player's pet or indicolure changes: the player's status, the
-- pet's index (times 8) and the indicolure's byte.
function Game:send_character_update(pet_index)
    pet_index = pet_index or self.pet and self.pet.index * 8 or 0
    return self:receive(0x037, bytes_body(0x68, {
        [0x31] = self.player.status, [0x35] = pet_index % 256, [0x36] = math.floor(pet_index / 256),
        [0x59] = self.indi_byte or 0,
    }))
end

-- The pet's info packet: the TP of the pet of the player at that index.
function Game:send_pet_info(tp)
    local owner = self.player.index
    tp = tp or self.pet and self.pet.tp or 0
    return self:receive(0x068, bytes_body(0x28, {
        [0x07] = owner % 256, [0x08] = math.floor(owner / 256), [0x11] = tp % 256, [0x12] = math.floor(tp / 256),
    }))
end

-- Puts a pet at the player's side, with no packet to tell of it, as one already out when GearSwap loads. fields over
-- the defaults: id, index, name, hpp, mpp, tp (3000 is full; the pet's mob has none unless given), status (0 idle,
-- 1 engaged), distance (squared, as Windower gives it; 2 yalms unless given), x (as far along x as the distance says
-- unless given), y, model_size. Returns the pet as the game holds it.
function Game:place_pet(fields)
    local pet = {
        id = 0x1069100, index = 0x402, name = 'Pet', is_npc = true, spawn_type = 16, race = 0, status = 0, hpp = 100,
        mpp = 100, distance = 4, y = 0, z = 0, facing = 0, claim_id = 0, valid_target = true, model_size = 1,
        target_index = 0,
    }
    for key, value in pairs(fields or {}) do
        pet[key] = value
    end
    pet.x = pet.x or math.sqrt(pet.distance)
    self.pet = pet
    return pet
end

-- Gives the player a pet (fields as place_pet) and tells the addon, as the server does: the character update, then
-- the pet's info, whose packet is the one the addon acts on the pet's arrival with.
function Game:give_pet(fields)
    self:place_pet(fields)
    self:send_character_update()
    self:send_pet_info(self.pet.tp)
    self:settle()
end

-- Takes the player's pet away, as the server tells: the character update without a pet index while the pet is
-- still there to be seen, then the pet gone and another packet.
function Game:take_pet()
    self:send_character_update(0)
    self:settle()
    self.pet = nil
    self:send_pet_info(0)
    self:settle()
end

-- The pet's status changes (0 idle, 1 engaged), and the addon is told in the packet for that and the one after.
function Game:set_pet_status(status)
    local index = self.pet.index
    self.pet.status = status
    self:receive(0x00E, bytes_body(0x30, {
        [9] = index % 256, [10] = math.floor(index / 256), [11] = 4, [32] = status,
    }))
    self:send_pet_info()
    self:settle()
end

-- The pet's TP changes.
function Game:set_pet_tp(tp)
    self.pet.tp = tp
    self:send_pet_info(tp)
    self:settle()
end

-- The automaton a puppetmaster has, as get_mjob_data tells it: the head, frame and attachments fitted, by item name,
-- those the puppetmaster has (the fitted ones unless given), and its HP and MP.
function Game:set_automaton(fields)
    fields = fields or {}
    local attachments = fields.attachments or {}
    self.automaton = {
        name = fields.name or 'Automaton', head = fields.head, frame = fields.frame, attachments = attachments,
        available_heads = fields.available_heads or {fields.head},
        available_frames = fields.available_frames or {fields.frame},
        available_attachments = fields.available_attachments or attachments,
        hp = fields.hp or 100, max_hp = fields.max_hp or 100, mp = fields.mp or 0, max_mp = fields.max_mp or 0,
    }
end

function Game:automaton_data()
    local automaton = self.automaton
    if not automaton then
        return {}
    end
    local function ids(names)
        local result = {}
        for _, name in ipairs(names) do
            result[#result + 1] = (find_by_name(self.res.items, name, 'item'))
        end
        return result
    end
    return {
        name = automaton.name, head = ids({automaton.head})[1], frame = ids({automaton.frame})[1],
        attachments = ids(automaton.attachments), available_heads = ids(automaton.available_heads),
        available_frames = ids(automaton.available_frames),
        available_attachments = ids(automaton.available_attachments),
        hp = automaton.hp, max_hp = automaton.max_hp, mp = automaton.mp, max_mp = automaton.max_mp,
    }
end

-- The species a Monipulator is, by its id in the monstrosity resources, as get_mjob_data tells it.
function Game:set_species(id)
    self.species = id
end

-- The indicolure the player has, as the character update tells it: the element (by its id in the resources), the
-- size (1 to 4) and whether it works on enemies; none when no fields are given.
function Game:set_indi(fields)
    if fields then
        self.indi_byte = 64 + 16 * ((fields.size or 1) - 1) + (fields.enemy and 8 or 0) + fields.element
    else
        self.indi_byte = nil
    end
    self:send_character_update()
    self:settle()
end

-------------------------------------------------------------------------------------------------------------------
-- The mobs besides the player, the monster and the pet: other players, in the party or not, NPCs and other
-- monsters. Each takes the next index from 0x500 unless given one, and stands along x as far as its distance says.
-------------------------------------------------------------------------------------------------------------------

local function add_other(game, defaults, fields)
    local index = fields.index or game.next_index
    game.next_index = math.max(game.next_index, index) + 1
    local mob = {index = index, status = 0, hpp = 100, mpp = 100, y = 0, z = 0, facing = 0, claim_id = 0,
        valid_target = true, model_size = 1, target_index = 0}
    for key, value in pairs(defaults(index)) do
        mob[key] = value
    end
    for key, value in pairs(fields) do
        mob[key] = value
    end
    mob.x = fields.x or math.sqrt(mob.distance)
    game.others[#game.others + 1] = mob
    return mob
end

-- Another player near the character: a member of the party (p1, p2 in the order they are added, or the slot given:
-- a10 to a15 and a20 to a25 for the alliance's other parties) unless in_party is false. fields over the defaults:
-- name, id, index, hp (of the 1000 they have), mp, tp, hpp (that of the HP unless given), status, distance (squared,
-- as Windower gives it), x, y, slot, leader (true for one who leads their party), alliance_leader (true for one who
-- leads the alliance). Returns the player as the game holds them.
function Game:add_party_member(fields)
    fields = fields or {}
    local own_party = fields.in_party ~= false and (not fields.slot or fields.slot:match('^p') ~= nil)
    local alliance = fields.in_party ~= false or fields.slot ~= nil
    local member = add_other(self, function(index)
        return {id = 0x100000 + index, name = 'Someone', is_npc = false, race = 1, hp = 1000, max_hp = 1000, mp = 500,
            tp = 0, distance = 16, spawn_type = own_party and 13 or alliance and 9 or 1}
    end, fields)
    member.in_party, member.in_alliance = own_party, alliance
    if not fields.hpp then
        member.hpp = math.floor(member.hp / member.max_hp * 100)
    end
    return member
end

-- An NPC near the character, or a monster with monster set. fields over the defaults: name, id, index, is_npc,
-- spawn_type, race, hpp, status, claim_id, distance (squared, as Windower gives it; 5 yalms unless given), x, y.
-- Returns the mob as the game holds it. An NPC's id has 0x800 set in its last twelve bits and its spawn type is 2; a
-- monster's id hasn't, and its spawn type is 16. GearSwap tells the two apart by the id, Sel and User-Globals.lua by
-- the spawn type.
function Game:add_mob(fields)
    fields = copy(fields or {})
    local monster = fields.monster
    fields.monster = nil
    return add_other(self, function(index)
        return {id = (monster and 0x01000000 or 0x01000800) + index, name = 'Mob', is_npc = true,
            spawn_type = monster and 16 or 2, race = 0, distance = 25, in_party = false, in_alliance = false}
    end, fields)
end

-- The mob at that index, a player, an NPC or a monster, is gone.
function Game:remove_mob(index)
    for i = #self.others, 1, -1 do
        if self.others[i].index == index then
            table.remove(self.others, i)
        end
    end
end

-- Makes the mob at that index the target, with the target change event, which Windower hands only the new target's
-- index, or the subtarget; none when given none.
function Game:target(index)
    local old = self.target_index
    self.target_index = index
    if index ~= old then
        self:fire('target change', index or 0)
    end
end

function Game:subtarget(index)
    self.subtarget_index = index
end

-------------------------------------------------------------------------------------------------------------------
-- Items in bags, and moving them. The client asks for a move with an outgoing 0x029 (count, from bag, to bag, slot,
-- target slot); the server moves that many of the item onto a stack of it in the other bag that has room for them,
-- else into the first empty slot, and tells the client with an item update for the slot they went to (0x020) and the
-- count left in the old (0x01E). The add item event follows for a slot that was empty, and the remove item event for
-- one that is now. It takes nothing out of or into a bag that is closed (a bag's disabled), a Mog House bag away
-- from the Mog House and a moogle, or into one that is full, nothing that is worn, more than there is, and nothing
-- that doesn't go through the inventory. A game with refuse_moves set takes no move at all.
-------------------------------------------------------------------------------------------------------------------

-- Puts one more item in a bag, in its first empty slot. item as in the boot options: name, extdata, count. Returns
-- the slot.
function Game:add_item(bag_name, item)
    local bag_id = assert(self:bag_id(bag_name), ('no bag named %s'):format(tostring(bag_name)))
    local bag = self.bags[bag_id]
    local item_id = find_by_name(self.res.items, item.name, 'item')
    for slot = 1, bag.max do
        if not bag.items[slot] then
            bag.items[slot] = {id = item_id, count = item.count or 1, status = 0, slot = slot, bazaar = 0,
                extdata = item.extdata or string.char(0):rep(24)}
            return slot
        end
    end
    error(('%s is full'):format(bag_name))
end

-- The slot of the first item with that name in a bag, and the item, or nil.
function Game:find_item(bag_name, name)
    local bag = self.bags[self:bag_id(bag_name)]
    for slot = 1, bag.max do
        local item = bag.items[slot]
        if item and self.res.items[item.id].en == name then
            return slot, item
        end
    end
end

-- The names of the items in a bag, sorted.
function Game:bag_names(bag_name)
    local names = {}
    for _, item in pairs(self.bags[self:bag_id(bag_name)].items) do
        names[#names + 1] = self.res.items[item.id].en
    end
    table.sort(names)
    return names
end

-- Whether bag_id is open to the client: not closed, and, for a Mog House bag, in the Mog House or at a moogle.
function Game:bag_reachable(bag_id)
    if self.bags[bag_id].disabled then
        return false
    end
    if self.res.bags[bag_id].access == 'Mog House' then
        return self:get_info().mog_house or (self.moogle_menu and self.res.bags[bag_id].api ~= 'storage') or false
    end
    return true
end

function Game:move_item(count, from_id, to_id, index)
    local from, to = self.bags[from_id], self.bags[to_id]
    local item = from and from.items[index]
    if self.refuse_moves or not item or not to or item.status ~= 0 or (from_id ~= 0 and to_id ~= 0) then
        return false
    elseif count < 1 or count > item.count then
        return false
    elseif not self:bag_reachable(from_id) or not self:bag_reachable(to_id) then
        return false
    end
    local stack = self.res.items[item.id].stack or 1
    local target, joined
    for slot = 1, to.max do
        local there = to.items[slot]
        if there and there.id == item.id and there.extdata == item.extdata and there.count + count <= stack then
            target, joined = slot, there
            break
        end
    end
    for slot = 1, to.max do
        if target then
            break
        elseif not to.items[slot] then
            target = slot
        end
    end
    if not target then
        return false
    end
    local left = item.count - count
    local moved = joined or left == 0 and item
        or {id = item.id, count = 0, status = 0, bazaar = 0, extdata = item.extdata}
    if moved ~= item then
        moved.count = moved.count + count
    end
    moved.slot = target
    to.items[target] = moved
    if left == 0 then
        from.items[index] = nil
    else
        item.count = left
    end
    self:receive(0x01E, u32(left) .. string.char(from_id, index, 0, 0))
    self:receive(0x020, u32(moved.count) .. u32(moved.bazaar) .. u16(moved.id)
        .. string.char(to_id, target, moved.status) .. moved.extdata)
    if left == 0 then
        self:enqueue('event', 'remove item', from_id, index, item.id, count)
    end
    if not joined then
        self:enqueue('event', 'add item', to_id, target, moved.id, count)
    end
    return true
end

return Game
