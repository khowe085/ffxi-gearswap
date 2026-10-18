local lfs = require('lfs')

describe('the copy of a Windower install a run makes', function()
    it('is removed by the cleanup at the end of the run, from any copy of the harness busted loaded', function()
        local root = require('harness').tree().root
        assert.equal('directory', lfs.attributes(root, 'mode'))
        -- busted loads the modules again for each spec file, so the cleanup's harness isn't the one that made the copy.
        package.loaded.harness = nil
        require('harness').cleanup()
        assert.is_nil(lfs.attributes(root))
    end)
end)
