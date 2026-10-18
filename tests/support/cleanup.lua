-- Removes the copy of the Windower install a run made, as busted exits.
return function(busted)
    busted.subscribe({'exit'}, function()
        require('harness').cleanup()
        return nil, true
    end)
    return true
end
