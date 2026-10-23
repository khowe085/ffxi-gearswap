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

    -- busted keeps a failed test as it was when it failed, before its time is known, so the times are taken when
    -- each test ends, by the trace the kept copy shares with the test.
    local durations = {}
    busted.subscribe({'test', 'end'}, function(element)
        if type(element.trace) == 'table' then
            durations[element.trace] = element.duration
        end
        return nil, true
    end)

    -- dkjson writes a table with nothing in it as a list; these stay objects, as LuaSpecs.cs reads them.
    local function object(t)
        return setmetatable(t, {__jsontype = 'object'})
    end

    local function plain(entry)
        local trace = type(entry.trace) == 'table' and entry.trace or {}
        local element = type(entry.element) == 'table' and entry.element or {}
        local element_trace = type(element.trace) == 'table' and element.trace or {}
        local duration = element.duration or durations[element.trace]
        local message = entry.message
        if message ~= nil and type(message) ~= 'string' then
            message = tostring(message)
        end
        return object({
            name = entry.name,
            message = message,
            isError = entry.isError or nil,
            element = object({duration = duration, trace = object({currentline = element_trace.currentline})}),
            trace = object({currentline = trace.currentline or element_trace.currentline, traceback = trace.traceback}),
        })
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
