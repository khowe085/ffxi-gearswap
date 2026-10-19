-------------------------------------------------------------------------------------------------------------------
-- Jobby, the made-up character the tests of the job files (data/BLU.lua, COR.lua, PUP.lua, DNC.lua, SCH.lua, GEO.lua
-- and RUN.lua) play: the boot options for each job, over the fixture gear file tests/fixture/data/Jobby/Jobby_<Job>_Gear.lua
-- that job loads, the sets as they are worn, and what a test of a job file needs besides: the world's day and
-- weather, recasts that aren't ready, and the actions of a pet.
-------------------------------------------------------------------------------------------------------------------

local harness = require('harness')
local testy = require('testy')

local jobby = {}

-- What every Jobby gear file's idle set wears, as the game shows it worn.
jobby.idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', left_ear = 'Etiolation Earring',
    right_ear = 'Loquac. Earring', left_ring = 'Defending Ring', right_ring = 'Stikini Ring +1'}

-- What the game shows worn once the idle set is on and the changes are laid over it: a slot named in the set's own
-- terms (ring1) or the game's (left_ring), a piece or 'empty'.
function jobby.worn_by(changes, base)
    return testy.worn_by(base or jobby.idle, changes)
end

-- The pieces Jobby wears in every gear file's idle set.
jobby.idle_items = {'Nyame Helm', 'Nyame Mail', 'Nyame Gauntlets', 'Nyame Flanchard', 'Nyame Sollerets',
    'Loricate Torque +1', 'Plat. Mog. Belt', 'Etiolation Earring', 'Loquac. Earring', 'Defending Ring', 'Stikini Ring +1'}

local slots = {main = true, sub = true, range = true, ammo = true, head = true, neck = true, left_ear = true,
    right_ear = true, body = true, hands = true, left_ring = true, right_ring = true, back = true, waist = true,
    legs = true, feet = true}

-- GearSwap's names for the slots of a set, by the game's: a set can say ear1 or left_ear, and set_combine says
-- the second.
local game_slots = {ear1 = 'left_ear', ear2 = 'right_ear', ring1 = 'left_ring', ring2 = 'right_ring', ranged = 'range',
    lear = 'left_ear', rear = 'right_ear', lring = 'left_ring', rring = 'right_ring'}

-- The sets laid one over another, as the pieces they hold by the game's slot names: only the slots, since a set a
-- gear file builds can hold the sets under it too.
function jobby.layer(...)
    local merged = {}
    for _, set in ipairs({...}) do
        for slot, item in pairs(set) do
            slot = game_slots[slot] or slot
            if slots[slot] then
                merged[slot] = item
            end
        end
    end
    return merged
end

-- The equip request GearSwap sends for the sets laid one over another.
function jobby.request(...)
    return jobby.layer(...)
end

-- Boot options for Jobby on a job: the pieces named (and the idle set's) in the inventory, the job's gear file
-- expected, over what the test gives.
--   job        the job's short name
--   items      the names of the pieces the gear file names beyond the idle set's, a {name =, count =, bag =} for one
--              that needs more
--   overrides  boot options that replace these
function jobby.options(job, items, overrides)
    local options = {character = 'Jobby', main_job = job, sub_job = 'NIN', expect_file = job .. '.lua', items = {}}
    for _, name in ipairs(jobby.idle_items) do
        options.items[#options.items + 1] = {name = name}
    end
    for _, item in ipairs(items or {}) do
        options.items[#options.items + 1] = type(item) == 'string' and {name = item} or item
    end
    options.wearing = {}
    for slot, name in pairs(jobby.idle) do
        options.wearing[slot] = name
    end
    for key, value in pairs(overrides or {}) do
        options[key] = value
    end
    return options
end

function jobby.boot(job, items, overrides)
    return harness.boot(jobby.options(job, items, overrides))
end

-- Makes the world's day and weather what the test says: day and weather by their ids in the resources
-- (day 6 is Lightsday, weather 16 is Auroras). The addon takes them up the next time it reads the world.
function jobby.set_world(gs, world)
    local game = gs.game
    local original = game.get_info
    game.get_info = function(self)
        local info = original(self)
        for key, value in pairs(world) do
            info[key] = value
        end
        return info
    end
end

-- An action packet of the pet's, as the server sends it. category 7 is a weapon skill (a monster ability, by its id in
-- the resources) readied, 11 the end of one, 8 a spell begun and 4 a spell cast (by spell id).
local function pet_action(gs, category, param, action_param, message)
    gs:run(function()
        gs.game:send_action_packet({
            actor_id = gs.game.pet.id, category = category, param = param, recast = 0,
            targets = {{id = category == 7 and gs.game.monster.id or gs.game.player.id,
                actions = {{message = message, param = action_param, reaction = 0, animation = 0, effect = 0, stagger = 0}}}},
        })
        gs.game:settle()
    end)
end

function jobby.pet_readies(gs, ability_id)
    pet_action(gs, 7, 24931, ability_id, 185)
end

function jobby.pet_uses(gs, ability_id)
    pet_action(gs, 11, ability_id, 100, 185)
end

function jobby.pet_starts_spell(gs, spell_id)
    pet_action(gs, 8, 24931, spell_id, 7)
end

function jobby.pet_casts(gs, spell_id)
    pet_action(gs, 4, spell_id, 100, 7)
end

-- Puts each ability recast (by recast id, in seconds) and each spell recast (by spell id, in frames of a sixtieth
-- of a second) at what the test says; every other one stays ready.
function jobby.set_recasts(gs, recasts)
    local game = gs.game
    game.ability_recast_overrides = recasts.abilities or game.ability_recast_overrides
    game.spell_recast_overrides = recasts.spells or game.spell_recast_overrides
    if not game.recasts_overridden then
        game.recasts_overridden = true
        local original_abilities = game.ability_recasts
        game.ability_recasts = function(self)
            local result = original_abilities(self)
            for id, seconds in pairs(self.ability_recast_overrides or {}) do
                result[id] = seconds
            end
            return result
        end
        local original_spells = game.windower.ffxi.get_spell_recasts
        game.windower.ffxi.get_spell_recasts = function()
            local result = original_spells()
            for id, frames in pairs(game.spell_recast_overrides or {}) do
                result[id] = frames
            end
            return result
        end
    end
end

return jobby
