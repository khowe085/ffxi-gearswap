-------------------------------------------------------------------------------------------------------------------
-- What the specs of GearSwap itself share: Testy as a white mage on one of the plain user files in data/Testy, and
-- a look at the list of events such a file notes.
-------------------------------------------------------------------------------------------------------------------

local assert = require('luassert')
local harness = require('harness')
local testy = require('testy')

local plain = {}

-- Testy as a white mage with every piece Testy_WHM.lua names, switched to the user file in data/Testy if one is
-- named. overrides are boot options.
function plain.boot(file, overrides)
    local gs = harness.boot(testy.whm(overrides))
    if file then
        plain.load(gs, file)
    end
    gs:traffic()
    return gs
end

-- Loads the user file as gs load does, and has gs.user be its globals.
function plain.load(gs, file)
    gs:console('gs load ' .. file)
    assert.equal(file, gs.env.current_file, 'GearSwap did not load ' .. file .. '. It printed:\n' .. gs:log())
    gs.user = gs.env.user_env
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

-- The error fn raises when called with the arguments. Fails when it raises none.
function plain.error_of(fn, ...)
    local ok, err = pcall(fn, ...)
    assert.is_false(ok, 'expected an error')
    return err
end

-- What GearSwap put in the chat since the last ask: the color and text of each line, without the codes it wraps a
-- colored line in. The chat is then empty.
function plain.chat(gs)
    local lines = {}
    for i, entry in ipairs(gs.game.chat_log) do
        local color, text = entry.text:match('^\31(.)(.*)\30\1$')
        lines[i] = {color = color and color:byte() or entry.color, text = text or entry.text}
    end
    gs.game.chat_log = {}
    return lines
end

-- The text of each of those lines.
function plain.texts(lines)
    local result = {}
    for i, line in ipairs(lines) do
        result[i] = line.text
    end
    return result
end

-- What GearSwap printed since the last ask, a line each. The prints are then empty.
function plain.printed(gs)
    local lines = gs.env.printed
    gs.env.printed = {}
    return lines
end

return plain
