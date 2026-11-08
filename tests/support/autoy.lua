-------------------------------------------------------------------------------------------------------------------
-- Autoy, the made-up character the tests of Sel's automatic actions play: a red mage on the real data/RDM.lua
-- with tests/fixture/data/Autoy/Autoy_Rdm_Gear.lua (or the WAR one), the gear those files name, its boots, and a
-- count of the lines those tests look for.
-------------------------------------------------------------------------------------------------------------------

local harness = require('harness')

local autoy = {}

-- The gear Autoy's gear files name.
autoy.gear = {
    {name = 'Naegling'}, {name = 'Crocea Mors'}, {name = 'Ammurapi Shield'}, {name = 'Nyame Helm'},
    {name = "Bunzi's Hat"}, {name = "Judge's Bow"},
    {name = 'Malignance Chapeau'}, {name = 'Daybreak'},
}

-- Boots Autoy, a red mage with a white mage sub unless the options say otherwise.
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
    return harness.boot(merged)
end

-- Boots Autoy and plays on past what Sel and User-Globals.lua do in the seconds after a load, so a test sets its
-- modes on a settled game whose tick is running, with everything so far taken as read.
function autoy.boot(options)
    local gs = autoy.load(options)
    gs:play(harness.sel_load_time + 1)
    gs:forget()
    return gs
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

return autoy
