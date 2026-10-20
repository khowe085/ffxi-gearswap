-------------------------------------------------------------------------------------------------------------------
-- What the specs of GearSwap itself share: Testy as a white mage on one of the plain user files in
-- tests/fixture/data/Testy, a refresh of GearSwap's globals, and a look at the events and the hooks' calls such a file
-- notes, and at their names.
-------------------------------------------------------------------------------------------------------------------

local assert = require('luassert')
local harness = require('harness')
local testy = require('testy')

local plain = {}

-- Testy as a white mage with every piece Testy_WHM.lua names, switched to the user file in tests/fixture/data/Testy
-- if one is named, with everything up to then taken as read. overrides are boot options.
function plain.boot(file, overrides)
    local gs = harness.boot(testy.whm(overrides))
    if file then
        plain.load(gs, file)
        gs:forget()
    end
    return gs
end

-- Loads the user file as gs load does, and has gs.user be its globals.
function plain.load(gs, file)
    gs:console('gs load ' .. file)
    assert.equal(file, gs.env.current_file, 'GearSwap did not load ' .. file .. '. It printed:\n' .. gs:log())
    gs.user = gs.env.user_env
end

-- Has GearSwap bring its globals up to date, as it does before it hands the user file a command (gs c refresh). The
-- events and calls the user file noted until then, the command among them, are taken as read.
function plain.refresh(gs)
    gs:console('gs c refresh')
    if gs.user.events then
        plain.events(gs)
    end
    if gs.user.calls then
        plain.calls(gs)
    end
end

-- The events the user file noted in its events list since the last ask, in order.
function plain.events(gs)
    local list = gs.user.events
    gs.user.events = {}
    return list
end

-- The name of each of those events.
function plain.names(list)
    local result = {}
    for i, entry in ipairs(list) do
        result[i] = entry.event
    end
    return result
end

-- The hooks the user file noted in its calls list since the last ask, in order, with what they were handed. Their
-- names are plain.names of the list.
function plain.calls(gs)
    local list = gs.user.calls
    gs.user.calls = {}
    return list
end

return plain
