-- Corey's black mage file, a plain GearSwap user file the tests find by job name.

loaded = 'Corey_BLM.lua'
unloaded = {}

function get_sets()
    sets.idle = {body = 'Nyame Mail'}
end

function file_unload(name)
    unloaded[#unloaded + 1] = name
end
