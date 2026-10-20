-------------------------------------------------------------------------------------------------------------------
-- Autoy, the made-up character the tests of Sel's automatic actions play: a red mage on the real data/RDM.lua
-- with tests/fixture/data/Autoy/Autoy_Rdm_Gear.lua (or another job's Autoy file), and what those tests look at,
-- which is what Sel sends on its own rather than what it wears.
-------------------------------------------------------------------------------------------------------------------

local harness = require('harness')

local autoy = {}

-- The gear Autoy's gear files name.
autoy.gear = {
    {name = 'Naegling'}, {name = 'Crocea Mors'}, {name = 'Ammurapi Shield'}, {name = 'Nyame Helm'},
    {name = "Bunzi's Hat"}, {name = "Judge's Bow"},
    {name = 'Malignance Chapeau'},
}

-- Seconds after GearSwap loads that Sel's tick first acts, and that Sel sets up the weapon modes
-- (gs c weapons initialize) and User-Globals.lua locks the style.
autoy.load_time = 5

-- Boots Autoy, a red mage with a white mage sub unless the options say otherwise, with what it sent at load
-- already looked at.
function autoy.load(options)
    local merged = {character = 'Autoy', main_job = 'RDM', sub_job = 'WHM', items = {}}
    for _, item in ipairs(autoy.gear) do
        merged.items[#merged.items + 1] = item
    end
    for k, v in pairs(options or {}) do
        if k == 'items' then
            for _, item in ipairs(v) do
                merged.items[#merged.items + 1] = item
            end
        else
            merged[k] = v
        end
    end
    local gs = harness.boot(merged)
    gs:traffic()
    return gs
end

-- Boots Autoy and plays on past what Sel and User-Globals.lua do in the seconds after a load, so a test sets its
-- modes on a settled game whose tick is running.
function autoy.boot(options)
    local gs = autoy.load(options)
    gs:play(autoy.load_time + 0.5)
    gs:traffic()
    return gs
end

-- The actions GearSwap sent since its traffic was last looked at, as {action =, target =}, without the equip
-- requests around them.
function autoy.actions(gs)
    local actions = {}
    for _, entry in ipairs(gs:traffic()) do
        if entry.action then
            actions[#actions + 1] = entry
        end
    end
    return actions
end

-- Plays frame by frame until GearSwap sends an action, for at most that many seconds: the actions it sent then,
-- and the clock when it did.
function autoy.play_until_action(gs, seconds)
    for _ = 1, math.floor(seconds * 10 + 0.5) do
        gs:play(0.1)
        local actions = autoy.actions(gs)
        if #actions > 0 then
            return actions, gs.game.clock
        end
    end
    return {}, gs.game.clock
end

-- The names of the actions GearSwap sent since its traffic was last looked at.
function autoy.action_names(gs)
    local names = {}
    for _, entry in ipairs(autoy.actions(gs)) do
        names[#names + 1] = entry.action
    end
    return names
end

-- How many times the line is among the lines given (typed text, commands, chat).
function autoy.count(lines, line)
    local count = 0
    for _, each in ipairs(lines) do
        if each == line then
            count = count + 1
        end
    end
    return count
end

-- The text of each line GearSwap or Sel put in the chat log, without the codes that color it.
function autoy.chat(gs)
    local lines = {}
    for _, entry in ipairs(gs.game.chat_log) do
        lines[#lines + 1] = (tostring(entry.text):gsub('^\31.', ''):gsub('\30\1$', ''))
    end
    return lines
end

return autoy
