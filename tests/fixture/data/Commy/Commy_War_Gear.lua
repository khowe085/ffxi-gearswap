-- Commy's warrior gear file, loaded by the real data/WAR.lua, for the tests of how Sel follows the game's clock,
-- zones and sub job, and of the commands a job file leaves to Sel. Each set wears a piece that tells it apart from
-- the others.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.IdleMode:options('Normal', 'DT')
	state.Weapons:options('None')
end

function init_gear_sets()
	sets.idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring',
		ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1'}
	sets.idle.DT = set_combine(sets.idle, {ring2 = "Medada's Ring"})
	sets.DayIdle = {waist = 'Chaac Belt'}
	sets.NightIdle = {waist = 'Reiki Yotai'}
	sets.DuskIdle = {neck = 'Sanctity Necklace'}
	sets.ExtraRegen = {back = 'Moonlight Cape'}
	sets.Kiting = {feet = 'Volte Boots'}
	sets.Town = {head = 'Volte Cap'}

	sets.engaged = {legs = 'Volte Hose'}
end

-- Notes each sub job change Sel hands the gear file.
function user_job_sub_job_change(newSubjob, oldSubjob)
	sub_job_changes = (sub_job_changes or 0) + 1
	sub_job_changed_to = newSubjob
end
