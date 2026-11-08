-- Corey's white mage file, a plain GearSwap user file the tests find by job name. It says which file it is, and notes
-- the files it is told to unload.

loaded = 'Corey_WHM.lua'
unloaded = {}

function get_sets()
    sets.idle = {head = 'Nyame Helm'}
end

function file_unload(name)
    unloaded[#unloaded + 1] = name
end
