-------------------------------------------------------------------------------------------------------------------
-- A busted output handler that writes a spec file's results as one line of JSON at the end, as busted's json
-- handler does, but with only the fields .claude/tools/lib/LuaSpecs.cs reads: busted's own handler gives up on a
-- pending test declared outside an it, whose element holds a function. Each list holds, for each test, its name, its
-- message, whether it is an error, its time and line, and the traceback of an error.
-------------------------------------------------------------------------------------------------------------------

local json = require('dkjson')

return function(options)
    local busted = require('busted')
    local handler = require('busted.outputHandlers.base')()

    local function plain(entry)
        local trace = type(entry.trace) == 'table' and entry.trace or {}
        local element = type(entry.element) == 'table' and entry.element or {}
        local element_trace = type(element.trace) == 'table' and element.trace or {}
        local message = entry.message
        if message ~= nil and type(message) ~= 'string' then
            message = tostring(message)
        end
        return {
            name = entry.name,
            message = message,
            isError = entry.isError or nil,
            element = {duration = element.duration, trace = {currentline = element_trace.currentline}},
            trace = {currentline = trace.currentline or element_trace.currentline, traceback = trace.traceback},
        }
    end

    local function plain_list(entries)
        local list = {}
        for i, entry in ipairs(entries) do
            list[i] = plain(entry)
        end
        return list
    end

    handler.suiteEnd = function()
        -- On a line of its own, even after a test that wrote text with no line end.
        io.write('\n', json.encode({
            successes = plain_list(handler.successes),
            failures = plain_list(handler.failures),
            errors = plain_list(handler.errors),
            pendings = plain_list(handler.pendings),
            duration = handler.getDuration(),
        }), '\n')
        io.flush()
        return nil, true
    end

    busted.subscribe({'suite', 'end'}, handler.suiteEnd)
    return handler
end
