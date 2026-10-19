local lfs = require('lfs')

local function temp_folder()
    math.randomseed(os.time() + math.floor(os.clock() * 1000000))
    local base = os.getenv('TMPDIR') or '/tmp'
    for _ = 1, 100 do
        local path = ('%s/gearswap-cleanup-%08x'):format(base, math.random(0, 0x7FFFFFFF))
        if lfs.mkdir(path) then
            return path
        end
    end
    error('could not make a temp folder in ' .. base)
end

describe('the copy of a Windower install a run makes', function()
    it('is removed as busted exits, by the helper .busted names', function()
        local temp = temp_folder()
        local spec = temp .. '/boots_spec.lua'
        local file = assert(io.open(spec, 'w'))
        file:write("print('made ' .. require('harness').tree().root)\nit('runs', function() end)\n")
        file:close()
        local pipe = assert(io.popen(('TMPDIR=%q busted %q 2>&1'):format(temp, spec)))
        local output = pipe:read('*a')
        pipe:close()
        os.remove(spec)
        local made = output:match('made ([^\n]+)')
        local left = made and lfs.attributes(made)
        lfs.rmdir(temp)
        assert.is_string(made, output)
        assert.equal(temp, made:sub(1, #temp))
        assert.is_nil(left)
    end)

    it('is removed by the cleanup at the end of the run, from any copy of the harness busted loaded', function()
        local root = require('harness').tree().root
        assert.equal('directory', lfs.attributes(root, 'mode'))
        -- busted loads the modules again for each spec file, so the cleanup's harness isn't the one that made the copy.
        package.loaded.harness = nil
        require('harness').cleanup()
        assert.is_nil(lfs.attributes(root))
    end)
end)
