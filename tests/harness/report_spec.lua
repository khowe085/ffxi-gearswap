local lfs = require('lfs')
local json = require('dkjson')
local harness = require('harness')

-- Runs busted with tests/support/report.lua on a spec file made for the purpose, and gives back the report, read
-- and as it was written.
local function report_of(spec)
    local folder = harness.temp_folder('report')
    local file = assert(io.open(folder .. '/made_spec.lua', 'w'))
    file:write(spec)
    file:close()
    local handler = lfs.currentdir() .. '/tests/support/report.lua'
    local pipe = assert(io.popen(('cd %q && busted --output=%q made_spec.lua 2>/dev/null'):format(folder, handler)))
    local output = pipe:read('*a')
    pipe:close()
    os.remove(folder .. '/made_spec.lua')
    lfs.rmdir(folder)
    local line = output:match('([^\n]*)\n*$')
    return assert(json.decode(line), 'busted wrote no report:\n' .. output), line
end

describe('the report the runner reads', function()
    it('gives a failed test its time, which busted learns only after the failure', function()
        local report = report_of(table.concat({
            "it('waits, then fails', function()",
            "    local finish = os.clock() + 0.05",
            "    while os.clock() < finish do end",
            "    assert.is_true(false)",
            "end)",
        }, '\n'))
        assert.equal(1, #report.failures)
        assert.is_true(report.failures[1].element.duration >= 0.05)
        assert.equal(1, report.failures[1].element.trace.currentline)
    end)

    it('writes each entry and its parts as objects, even with nothing in them, as LuaSpecs.cs reads them', function()
        local report, line = report_of("pending('later')\n")
        assert.equal('later', report.pendings[1].name)
        -- dkjson writes an empty table as a list unless told it is an object.
        assert.is_nil(line:find('"element":%['))
        assert.is_nil(line:find('"trace":%['))
    end)
end)
