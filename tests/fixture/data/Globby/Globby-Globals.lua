-- Globby's own Globals file, which Sel loads after User-Globals.lua's and before it works out the spell latency: it
-- sets the latency, turns AutoArts on, and gives AutoTrustMode and AutoFoodMode a list and an option each, turned on,
-- all of which a boot puts back as Sel defines them.

globals_marker = 'Globby-Globals.lua'

latency = 1
state.AutoArts:set(true)

trust_lists = {Long = {'Yoran-Oran (UC)'}}
state.AutoTrustMode:options('Off', 'Long')
state.AutoTrustMode:set('Long')

food_lists = {Snack = 'Grape Daifuku'}
state.AutoFoodMode:options('Off', 'Snack')
state.AutoFoodMode:set('Snack')
