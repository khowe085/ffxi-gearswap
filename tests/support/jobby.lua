-------------------------------------------------------------------------------------------------------------------
-- Jobby, the made-up character the tests of the job files in data/ play (tests/jobs): the boot options for each job,
-- over the fixture gear file tests/fixture/data/Jobby/Jobby_<Job>_Gear.lua that job loads, the sets as they are worn,
-- and a look at what the job file sent, typed, ran and said.
-------------------------------------------------------------------------------------------------------------------

local harness = require('harness')
local testy = require('testy')

local jobby = {}

-- What every Jobby gear file's idle set wears, as the game shows it worn.
jobby.idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', left_ear = 'Etiolation Earring',
    right_ear = 'Loquac. Earring', left_ring = 'Defending Ring', right_ring = 'Stikini Ring +1'}

-- What the idle set of the gear files of WAR, MNK, WHM, BLM, RDM, THF, PLD and DRK wears: every gear file's, with an
-- ammo and a back.
jobby.full_idle = testy.worn_by(jobby.idle, {ammo = 'Staunch Tathlum +1', back = 'Moonbeam Cape'})

-- What the game shows worn once the idle set (jobby.idle unless another is given) is on and the changes are laid over
-- it: a slot named in the set's own terms (ring1) or the game's (left_ring), a piece or 'empty'.
function jobby.worn_by(changes, base)
    return testy.worn_by(base or jobby.idle, changes)
end

-- The pieces of the idle sets, which every job can wear.
local idle_items = {'Nyame Helm', 'Nyame Mail', 'Nyame Gauntlets', 'Nyame Flanchard', 'Nyame Sollerets',
    'Loricate Torque +1', 'Plat. Mog. Belt', 'Etiolation Earring', 'Loquac. Earring', 'Defending Ring',
    'Stikini Ring +1', 'Staunch Tathlum +1', 'Moonbeam Cape'}

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

-- Forgets what was sent, typed, run and said so far.
local function forget(gs)
    gs:traffic()
    gs.game.commands, gs.game.typed, gs.game.chat_log = {}, {}, {}
end

-- Boots Jobby as that job, with the pieces of the idle sets and the items given in the inventory and every gear file's
-- idle set on, and has Sel update the gear once, with nothing sent, typed, run or said since. options are a boot's
-- (see harness.boot), with these in place of the harness's:
--   items     the names of the pieces Jobby has besides the idle sets', or {name =, bag =, count =} for one that
--             needs more
--   wearing   slot name to the name of an item, worn when GearSwap loads over the idle set
--   sub_job   WHM unless given
function jobby.boot(job, options)
    local boot = {character = 'Jobby', main_job = job, sub_job = 'WHM', expect_file = job .. '.lua'}
    for key, value in pairs(options or {}) do
        boot[key] = value
    end
    boot.items = {}
    for _, name in ipairs(idle_items) do
        boot.items[#boot.items + 1] = {name = name}
    end
    for _, item in ipairs((options or {}).items or {}) do
        boot.items[#boot.items + 1] = type(item) == 'table' and item or {name = item}
    end
    boot.wearing = testy.worn_by(jobby.idle, (options or {}).wearing)
    local gs = harness.boot(boot)
    gs:console('gs c update')
    forget(gs)
    return gs
end

-- As boot, and past the five seconds Sel waits after loading before its tick acts, with nothing sent since.
function jobby.boot_ticking(job, options)
    local gs = jobby.boot(job, options)
    gs:play(6)
    forget(gs)
    return gs
end

-- What Jobby has targeted is another player, Pal, standing in front of him, who isn't in the party. fields are over
-- Pal's (see Game:add_party_member). Returns Pal as the game holds him.
function jobby.target_a_player(gs, fields)
    local pal = {name = 'Pal', in_party = false}
    for key, value in pairs(fields or {}) do
        pal[key] = value
    end
    pal = gs.game:add_party_member(pal)
    gs.game:target(pal.index)
    return pal
end

-- Plays the game on until the addon sends an action, and returns everything it sent as Session:traffic gives it; nil
-- when no action goes out in that many seconds (6 unless given, the time a spell and its aftercast hold Sel's tick).
function jobby.until_action(gs, seconds)
    for _ = 1, math.floor((seconds or 6) * 10 + 0.5) do
        gs:play(0.1)
        local traffic = gs:traffic()
        for _, entry in ipairs(traffic) do
            if entry.action then
                return traffic
            end
        end
    end
end

-- The names of the actions in what Session:traffic gave, in order.
function jobby.action_names(traffic)
    local names = {}
    for _, entry in ipairs(traffic or {}) do
        if entry.action then
            names[#names + 1] = entry.action
        end
    end
    return names
end

-- The names of the actions GearSwap sent since this was last asked, in order.
function jobby.actions(gs)
    return jobby.action_names(gs:traffic())
end

-- The actions GearSwap sent since this was last asked, in order, as {action = name, target = name}.
function jobby.action_entries(gs)
    local entries = {}
    for _, entry in ipairs(gs:traffic()) do
        if entry.action then
            entries[#entries + 1] = entry
        end
    end
    return entries
end

-- The lines typed into the chat since this was last asked that GearSwap let through to the game as they were.
function jobby.typed(gs)
    local lines = gs.game.typed
    gs.game.typed = {}
    return lines
end

-- The text of what the addon put in the chat log since this was last asked, without the color codes it wraps its
-- messages in.
function jobby.chat(gs)
    local lines = {}
    for _, entry in ipairs(gs.game.chat_log) do
        lines[#lines + 1] = (entry.text:gsub('^\31.', ''):gsub('\30\1$', ''))
    end
    gs.game.chat_log = {}
    return lines
end

-- The console commands run since this was last asked, as the game recorded them.
function jobby.commands(gs)
    local commands = gs.game.commands
    gs.game.commands = {}
    return commands
end

return jobby
