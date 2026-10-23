-- Globby's own Globals file, which Sel loads after User-Globals.lua's and before it works out the spell latency: it
-- sets the latency and turns AutoArts on, which a boot puts back as Sel defines them.

globals_marker = 'Globby-Globals.lua'

latency = 1
state.AutoArts:set(true)
