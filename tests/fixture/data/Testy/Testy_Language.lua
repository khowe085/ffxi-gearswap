-- A GearSwap user file that sets the language GearSwap reads the game's names in, to the one the test names in
-- gearswap.test_language before it loads, in get_sets as set_language wants. It sets a head piece to say get_sets
-- went on after.

function get_sets()
    set_language(gearswap.test_language)
    sets.after_language = {head = 'Nyame Helm'}
end

function self_command(command)
    if command == 'set_language' then
        set_language('english')
    end
end
