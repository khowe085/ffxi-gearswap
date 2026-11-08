-- Removes the copy of the Windower install a run made, as busted exits, and tells the runner which repo files the run
-- read from it.
return function(busted)
    busted.subscribe({'exit'}, function()
        local harness = require('harness')
        harness.cleanup()
        harness.write_loaded_files()
        return nil, true
    end)
    return true
end
