-------------------------------------------------------------------------------------------------------------------
-- Jobby, the made-up character the tests of data/WAR.lua, MNK.lua, WHM.lua, BLM.lua, RDM.lua, THF.lua, PLD.lua and
-- DRK.lua play: the gear each job's fixture gear file wears, the boot options that give it to them, and the few
-- things a job file's tests ask of the stand-in game that the harness doesn't hold (a fight, recasts, the weather).
-------------------------------------------------------------------------------------------------------------------

local harness = require('harness')
local testy = require('testy')

local jobby = {}

jobby.worn_by = testy.worn_by

-- The idle set of every Jobby_<Job>_Gear.lua, by GearSwap's set slot names.
jobby.idle = {ammo = 'Staunch Tathlum +1', head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
    ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
    back = 'Moonbeam Cape'}

-- What the game shows worn with the idle set on and these changes over it.
function jobby.idle_with(changes)
    return jobby.worn_by(jobby.idle, changes)
end

-- The pieces of the idle set, which every job can wear.
local idle_items = {'Staunch Tathlum +1', 'Nyame Helm', 'Nyame Mail', 'Nyame Gauntlets', 'Nyame Flanchard',
    'Nyame Sollerets', 'Loricate Torque +1', 'Plat. Mog. Belt', 'Etiolation Earring', 'Loquac. Earring',
    'Defending Ring', 'Stikini Ring +1', 'Moonbeam Cape'}

-- Boots Jobby as that job with the idle set on, and the idle gear and these items in the bags.
-- options, all of them optional:
--   sub_job, main_job_level, sub_job_level, tp
--   items       names of the pieces Jobby has besides the idle set's, or {name=, bag=} for one in another bag
--   abilities   the names of the abilities and weapon skills Jobby knows; all the resources hold unless given
--   buffs       the names of the buffs up when GearSwap loads
--   wearing     slot name to the name of an item in items, worn when GearSwap loads
function jobby.boot(job, options)
    options = options or {}
    local items = {}
    for _, name in ipairs(idle_items) do
        items[#items + 1] = {name = name}
    end
    for _, item in ipairs(options.items or {}) do
        items[#items + 1] = type(item) == 'table' and item or {name = item}
    end
    local gs = harness.boot({
        character = 'Jobby', main_job = job, sub_job = options.sub_job or 'WHM', expect_file = job .. '.lua',
        main_job_level = options.main_job_level, sub_job_level = options.sub_job_level, tp = options.tp,
        items = items, abilities = options.abilities, buffs = options.buffs, wearing = options.wearing,
    })
    gs:console('gs c update')
    gs:traffic()
    gs.game.commands, gs.game.typed, gs.game.chat_log = {}, {}, {}
    return gs
end

-- As boot, and past the five seconds Sel waits after loading before its tick acts, with nothing sent since.
function jobby.boot_ticking(job, options)
    local gs = jobby.boot(job, options)
    gs:play(6)
    gs:traffic()
    gs.game.commands, gs.game.typed, gs.game.chat_log = {}, {}, {}
    return gs
end

-- The monster hits Jobby, which puts Sel in combat.
function jobby.fight(gs)
    local game = gs.game
    game:send_action_packet({category = 1, actor_id = game.monster.id, targets = {{id = game.player.id,
        actions = {{message = 1, param = 10, reaction = 8, animation = 0, effect = 0, stagger = 0}}}}})
    game:settle()
    gs:traffic()
end

-- Changes what the game reports for the rest of the test: the ability recasts (by recast id, in seconds), the spell
-- recasts (by spell id, in sixtieths of a second) or the world (windower.ffxi.get_info's weather and day ids).
local function overlay(gs, name, changes)
    local ffxi = gs.game.windower.ffxi
    local original = ffxi[name]
    ffxi[name] = function(...)
        local result = original(...)
        for key, value in pairs(changes) do
            result[key] = value
        end
        return result
    end
end

function jobby.set_ability_recasts(gs, changes)
    overlay(gs, 'get_ability_recasts', changes)
end

function jobby.set_spell_recasts(gs, changes)
    overlay(gs, 'get_spell_recasts', changes)
end

function jobby.set_world(gs, changes)
    overlay(gs, 'get_info', changes)
end

-- What Jobby has targeted is another player, standing in front of it.
function jobby.target_a_player(gs)
    local monster = gs.game.monster
    monster.is_npc, monster.spawn_type, monster.name = false, 1, 'Pal'
end

-- The game's clock strikes this hour (0 to 23), which Sel's time change handler hears.
function jobby.set_hour(gs, hour)
    gs.game:fire('time change', hour * 60, 12 * 60)
    gs.game:settle()
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
