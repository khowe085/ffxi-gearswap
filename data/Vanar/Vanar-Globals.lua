-- Vanar's settings for every job. BLU.lua and RDM.lua include this file right after the engine, so
-- anything here runs each time either job file loads. GearSwap finds it in data/Vanar/.

-- Windower aliases. Type //mappy, or mappy in the console, to launch Mappy. -runonce skips the launch
-- when Mappy is already running.
send_command('alias mappy run -runonce "G:/SquareEnix/Windower/mappy.exe"')

-- The library ranks Plat. Mog. Belt at 10, but an hp_gear number is the item's total HP, and the belt's
-- HP+10% is about 250 for Vanar. At 10 it equips after the pieces whose HP it outweighs, so a swap could
-- clamp current HP to a lower maximum on the way through. Both job files build their sets after this runs.
gear.platinumMoogleBelt = hp_gear("Plat. Mog. Belt", 250)
