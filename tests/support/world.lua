-------------------------------------------------------------------------------------------------------------------
-- More of the world for the stand-in game in game.lua: other mobs, a pet, party members, a Monstrosity species, the
-- game's info (Mog House, target arrow), bags that hold fewer items or can't be reached, items moving between bags,
-- and the packets the server sends, built from Windower's own field definitions so each lands where the real game
-- puts it.
--
-- Requiring this adds methods to the Game class. It changes none of Game's own functions: those it widens it wraps.
-------------------------------------------------------------------------------------------------------------------

local Game = require('game')

local world = {}

local copy = Game.copy

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

-------------------------------------------------------------------------------------------------------------------
-- Mobs: other players, NPCs, a pet, party members.
-------------------------------------------------------------------------------------------------------------------

local base_mobs = Game.mobs
local base_player_mob = Game.player_mob
local base_mob_by_target = Game.mob_by_target
local base_get_party = Game.get_party
local base_get_player = Game.get_player

-- A mob the game keeps besides the player and the monster to target. fields: name, index, id, spawn_type, is_npc,
-- distance (in yalms), x, y, z, hpp, status, race, claim_id. Without an index it takes the next from 0x500. Returns the
-- mob as the game holds it.
function Game:add_mob(fields)
    self.extra_mobs = self.extra_mobs or {}
    local index = fields.index or self.next_mob_index or 0x500
    self.next_mob_index = math.max(self.next_mob_index or 0x500, index) + 1
    local distance = fields.distance or 5
    local mob = {
        id = fields.id or 0x01000000 + index, index = index, name = fields.name or 'Mob', is_npc = fields.is_npc ~= false,
        spawn_type = fields.spawn_type or 2, race = fields.race or 0, status = fields.status or 0, hpp = fields.hpp or 100,
        mpp = fields.mpp or 100, tp = fields.tp, distance = distance ^ 2, x = fields.x or distance, y = fields.y or 0,
        z = fields.z or 0, facing = 0, claim_id = fields.claim_id or 0, valid_target = true, model_size = 1,
        target_index = 0, in_party = false, in_alliance = false,
    }
    self.extra_mobs[index] = mob
    return mob
end

function Game:remove_mob(index)
    self.extra_mobs[index] = nil
end

function Game:mobs()
    local mobs = base_mobs(self)
    for index, mob in pairs(self.extra_mobs or {}) do
        mobs[index] = copy(mob)
    end
    return mobs
end

function Game:player_mob()
    local mob = base_player_mob(self)
    mob.pet_index = self.pet_index
    return mob
end

function Game:get_player()
    local player = base_get_player(self)
    player.pet_index = self.pet_index
    return player
end

-- Makes the mob at that index the target, or the subtarget.
function Game:target(index)
    self.target_index = index
end

function Game:subtarget(index)
    self.subtarget_index = index
end

-- A pet the player owns: it follows the player, its mob is the one the player's pet_index names. fields as add_mob.
function Game:summon_pet(fields)
    fields = copy(fields or {})
    fields.name = fields.name or 'Carbuncle'
    fields.distance = fields.distance or 2
    local pet = self:add_mob(fields)
    self.pet_index = pet.index
    return pet
end

function Game:dismiss_pet()
    if self.pet_index then
        self.extra_mobs[self.pet_index] = nil
        self.pet_index = nil
    end
end

-- A member of the player's party, in the next party slot (p1 on), or in the slot named (a10 to a25 for the alliance's
-- other parties). fields as add_mob, with hp, mp, tp and slot too.
function Game:add_party_member(fields)
    fields = copy(fields or {})
    fields.spawn_type = 13
    fields.is_npc = false
    fields.race = fields.race or 1
    local mob = self:add_mob(fields)
    mob.in_party, mob.in_alliance = true, true
    self.party_members = self.party_members or {}
    local member = {index = mob.index, hp = fields.hp or 1000, mp = fields.mp or 500, tp = fields.tp or 0, slot = fields.slot}
    self.party_members[#self.party_members + 1] = member
    return mob
end

function Game:get_party()
    local party = base_get_party(self)
    local own = 0
    for number, member in ipairs(self.party_members or {}) do
        local mob = self.extra_mobs[member.index]
        local slot = member.slot or 'p' .. number
        party[slot] = {name = mob.name, mob = copy(mob), hp = member.hp, mp = member.mp, tp = member.tp,
            hpp = mob.hpp, mpp = mob.mpp, zone = self.zone}
        if slot:sub(1, 1) == 'p' then
            own = own + 1
        end
    end
    party.party1_count = 1 + own
    return party
end

function Game:mob_by_target(target)
    local name = (target or ''):lower():gsub('^<(.*)>$', '%1')
    if name == 'pet' then
        return self.pet_index and self:mobs()[self.pet_index]
    elseif name == 'st' then
        return self.subtarget_index and self:mobs()[self.subtarget_index]
    end
    local slot = tonumber(name:match('^p(%d)$'))
    if slot == 0 then
        return self:player_mob()
    elseif slot then
        local member = (self.party_members or {})[slot]
        return member and self:mobs()[member.index]
    end
    return base_mob_by_target(self, target)
end

-------------------------------------------------------------------------------------------------------------------
-- Info, jobs and bags.
-------------------------------------------------------------------------------------------------------------------

local base_get_info = Game.get_info
local base_get_mjob_data = Game.mjob_data
local base_items_of = Game.items_of
local base_get_bag_info = Game.get_bag_info

-- Fields to change in what the game reports of itself (get_info): mog_house, weather, day, moon_phase and the rest.
function Game:set_info(fields)
    self.info = self.info or {}
    for key, value in pairs(fields) do
        self.info[key] = value
    end
end

function Game:get_info()
    local info = base_get_info(self)
    info.target_arrow = {x = 0, y = 0, z = 0}
    for key, value in pairs(self.info or {}) do
        info[key] = value
    end
    return info
end

-- A character in Monstrosity is a species, by its id in the monstrosity resources; a puppetmaster's automaton is
-- what the game has in automaton, the table of Windower's get_mjob_data for a puppetmaster.
function Game:mjob_data()
    if self.species then
        return {species = self.species}
    elseif self.automaton and self.player.main_job_id == 18 then
        return copy(self.automaton)
    end
    return base_get_mjob_data(self)
end

local function occupied(bag)
    local count = 0
    for _ in pairs(bag.items) do
        count = count + 1
    end
    return count
end

function Game:items_of(bag_id)
    local list = base_items_of(self, bag_id)
    list.count = occupied(self.bags[bag_id])
    list.enabled = not self.bags[bag_id].disabled
    return list
end

function Game:get_bag_info()
    local info = base_get_bag_info(self)
    for _, bag in pairs(self.bags) do
        info[bag.api].count = occupied(bag)
        info[bag.api].enabled = not bag.disabled
    end
    return info
end

-- Puts one more item in a bag, in its first empty slot. item as in the boot options: name, extdata, count. Returns
-- the slot.
function Game:add_item(bag_name, item)
    local bag_id = assert(self:bag_id(bag_name), ('no bag named %s'):format(tostring(bag_name)))
    local bag = self.bags[bag_id]
    local item_id
    for id, entry in pairs(self.res.items) do
        if type(entry) == 'table' and entry.en == item.name then
            item_id = id
        end
    end
    assert(item_id, ('the test resources have no item named %q'):format(item.name))
    for slot = 1, bag.max do
        if not bag.items[slot] then
            bag.items[slot] = {id = item_id, count = item.count or 1, status = 0, slot = slot, bazaar = 0,
                extdata = item.extdata or string.char(0):rep(24)}
            return slot
        end
    end
    error(('%s is full'):format(bag_name))
end

-- The slot of the first item with that name in a bag, or nil.
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

-------------------------------------------------------------------------------------------------------------------
-- Items moving between bags. The client asks with an outgoing 0x029 (count, from bag, to bag, slot, target slot);
-- the server moves the item to the first empty slot of the other bag, and tells the client with an item update for
-- the new slot (0x020) and a count of 0 for the old (0x01E). It takes nothing out of or into a bag that is closed,
-- a Mog House bag away from the Mog House and a moogle, or into one that is full, nothing that is worn, and nothing
-- that doesn't go through the inventory. A game with refuse_moves set takes no move at all.
-------------------------------------------------------------------------------------------------------------------

local base_inject_outgoing = Game.inject_outgoing

-- Whether bag_id is open to the client: not closed, and, for a Mog House bag, in the Mog House or at a moogle.
function Game:bag_reachable(bag_id)
    if self.bags[bag_id].disabled then
        return false
    end
    if self.res.bags[bag_id].access == 'Mog House' then
        local info = self:get_info()
        return info.mog_house or (self.moogle_menu and self.res.bags[bag_id].api ~= 'storage') or false
    end
    return true
end

function Game:move_item(count, from_id, to_id, index)
    local from, to = self.bags[from_id], self.bags[to_id]
    local item = from and from.items[index]
    if self.refuse_moves or not item or not to or item.status ~= 0 or (from_id ~= 0 and to_id ~= 0) then
        return false
    elseif not self:bag_reachable(from_id) or not self:bag_reachable(to_id) then
        return false
    end
    local target
    for slot = 1, to.max do
        if not to.items[slot] then
            target = slot
            break
        end
    end
    if not target then
        return false
    end
    from.items[index] = nil
    item.slot = target
    to.items[target] = item
    self:receive(0x01E, u32(0) .. string.char(from_id, index, 0, 0))
    self:receive(0x020, u32(item.count) .. u32(item.bazaar) .. u16(item.id) .. string.char(to_id, target, 0)
        .. item.extdata)
    return true
end

function Game:inject_outgoing(id, data)
    base_inject_outgoing(self, id, data)
    if id == 0x029 then
        self:move_item(read_u32(data, 5), data:byte(9), data:byte(10), data:byte(11))
    elseif id == 0x01A and read_u16(data, 11) == 0 then
        local moogle = self:mob_by_id(read_u32(data, 5))
        if moogle and moogle.name:find('Moogle') then
            self.moogle_menu = true
            self:receive(0x02E, u32(0))
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- The server's packets.
-------------------------------------------------------------------------------------------------------------------

local base_make_windower = Game.make_windower

-- get_mob_list takes the name of the mobs to list.
function Game:make_windower(paths)
    local windower = base_make_windower(self, paths)
    local game = self
    windower.ffxi.get_mob_list = function(name)
        local list = {}
        for index, mob in pairs(game:mobs()) do
            if not name or mob.name == name then
                list[index] = mob.name
            end
        end
        return list
    end
    return windower
end

-- The packet the server sends, as Windower's packets library builds it from its field definitions: fields are the
-- values by label. Returns the bytes after the 4-byte header.
function world.packet_body(gs, id, fields)
    local packets = gs.env.packets
    return packets.build(packets.new('incoming', id, fields or {})):sub(5)
end

-- Sends the packet to GearSwap, and lets the game catch up.
function world.send(gs, id, fields)
    local body = world.packet_body(gs, id, fields)
    gs:run(function()
        gs.game:receive(id, body)
        gs.game:settle()
    end)
end

-- Sends a packet's bytes as they are, with the header added.
function world.send_raw(gs, id, body)
    gs:run(function()
        gs.game:receive(id, body)
        gs.game:settle()
    end)
end

-- A packet GearSwap has no handler for. A pet's coming or going, and its change of status, wait for the packet that
-- follows the one that told of them.
function world.next_packet(gs)
    world.send_raw(gs, 0x0FF, '')
end

-- Sends a packet the game itself sent (as the player's client would, not GearSwap) out, header and all, as the body
-- after the 4-byte header says, and lets the game catch up.
function world.send_outgoing(gs, id, body)
    local data = string.char(id % 256, 0x02, 0, 0) .. body
    gs:run(function()
        gs.game:fire('outgoing chunk', id, data, data, false, false)
        gs.game:settle()
    end)
end

-- The zone-in packet (0x00A) for the game as it stands, with fields laid over it.
function world.zone_in(gs, fields)
    local game = gs.game
    local player = game.player
    local values = {
        ['Player'] = player.id, ['Player Index'] = player.index, ['Zone'] = game.zone,
        ['Player Name'] = player.name, ['Main Job'] = player.main_job_id, ['Sub Job'] = player.sub_job_id,
        ['Weather'] = 0, ['Race'] = player.race, ['MH Door Menu'] = 0,
        ['STR'] = 10, ['DEX'] = 10, ['VIT'] = 10, ['AGI'] = 10, ['INT'] = 10, ['MND'] = 10, ['CHR'] = 10,
        ['Max HP'] = player.vitals.max_hp, ['Max MP'] = player.vitals.max_mp,
    }
    for label, value in pairs(fields or {}) do
        values[label] = value
    end
    world.send(gs, 0x00A, values)
end

-- Moves the character to another zone, as the server does: the game's zone changes, and the zone-in packet comes.
function world.change_zone(gs, zone_id, fields)
    gs.game.zone = zone_id
    world.zone_in(gs, fields)
end

-- Changes the character's jobs, by their short names, as the server does when the player changes job: the game's jobs
-- change, and the zone-in packet comes.
function world.change_job(gs, main, sub)
    local game = gs.game
    local function job_id(short)
        for id, job in pairs(game.res.jobs) do
            if type(job) == 'table' and job.ens == short then
                return id
            end
        end
        error(('the test resources have no job %q'):format(short), 3)
    end
    game.player.main_job_id = job_id(main)
    if sub then
        game.player.sub_job_id = job_id(sub)
    end
    world.zone_in(gs)
end

-- The buff packet (0x063, type 9) for these buffs, each {name = , expires = }: when it wears off, in seconds on the
-- game's clock. The player's own list of buffs in the game becomes these.
function world.send_buffs(gs, buffs)
    local game = gs.game
    local ids, times, list = {}, {}, {}
    for i = 1, 32 do
        local buff = buffs[i]
        local id
        if buff then
            for buff_id, entry in pairs(game.res.buffs) do
                if type(entry) == 'table' and entry.en == buff.name then
                    id = buff_id
                end
            end
            assert(id, ('the test resources have no buff named %q'):format(buff.name))
            list[#list + 1] = id
        end
        ids[i] = u16(id or 255)
        times[i] = u32(buff and (buff.expires or game.clock + 600) * 60 or 0)
    end
    game.player.buffs = list
    world.send_raw(gs, 0x063, string.char(9, 0, 0, 0) .. table.concat(ids) .. table.concat(times))
end

-- The party buff packet (0x076) for up to five members, each {id = , index = , buffs = {buff ids}}.
function world.send_party_buffs(gs, members)
    local body = {}
    for i = 0, 4 do
        local member = members[i + 1]
        local mask, low = {0, 0, 0, 0, 0, 0, 0, 0}, {}
        for n = 1, 32 do
            local id = member and member.buffs and member.buffs[n] or 255
            low[n] = string.char(id % 256)
            local high = math.floor(id / 256)
            local byte = math.floor((n - 1) / 4) + 1
            mask[byte] = mask[byte] + high * 4 ^ ((n - 1) % 4)
        end
        body[#body + 1] = u32(member and member.id or 0) .. u16(member and member.index or 0) .. string.char(0, 0)
            .. string.char(unpack(mask)) .. table.concat(low)
    end
    world.send_raw(gs, 0x076, table.concat(body))
end

return world
