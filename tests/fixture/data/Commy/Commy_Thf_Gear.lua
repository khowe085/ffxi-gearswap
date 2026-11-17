-- Commy's thief gear file, loaded by the real data/THF.lua, for the tests of what Sel does for a thief whatever it
-- wears: its Treasure Hunter modes, their line in the status box, and the spells a thief can't cast. It has no sets.

function user_job_setup()
	state.OffenseMode:options('Normal')
	state.IdleMode:options('Normal')
	state.Weapons:options('None')
	state.AmbushMode = M(false, 'Ambush Mode')
end

function init_gear_sets()
end
