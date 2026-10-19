-- A small Sel gear file for the tests of data/PUP.lua. The sets for the automaton in each mode and for each of the
-- moments the job file lays one over another wear pieces that tell them apart.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.IdleMode:options('Normal', 'DT')
	state.Weapons:options('None')

	defaultManeuvers = {
		Melee = {
			{Name = 'Fire Maneuver', Amount = 1},
			{Name = 'Thunder Maneuver', Amount = 1},
			{Name = 'Wind Maneuver', Amount = 1},
			{Name = 'Light Maneuver', Amount = 0},
		},
		Ranged = {
			{Name = 'Wind Maneuver', Amount = 3},
			{Name = 'Fire Maneuver', Amount = 0},
		},
		Magic = {
			{Name = 'Light Maneuver', Amount = 1},
			{Name = 'Ice Maneuver', Amount = 1},
			{Name = 'Dark Maneuver', Amount = 1},
		},
	}
end

function init_gear_sets()
	sets.idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring',
		ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1'}
	sets.idle.DT = set_combine(sets.idle, {body = 'Malignance Tabard'})
	sets.idle.Pet = set_combine(sets.idle, {neck = 'Weike Torque'})
	sets.idle.Pet.Engaged = set_combine(sets.idle, {neck = 'Orunmila\'s Torque'})
	sets.idle.Pet.Engaged.Melee = set_combine(sets.idle.Pet.Engaged, {hands = 'Volte Bracers'})
	sets.idle.Pet.Engaged.Ranged = set_combine(sets.idle.Pet.Engaged, {legs = 'Volte Hose'})
	sets.idle.Pet.Engaged.Magic = set_combine(sets.idle.Pet.Engaged, {feet = 'Volte Boots'})
	sets.latent_refresh = {waist = 'Wanion Belt'}
	sets.buff.Overdrive = {ear1 = 'Sortiarius Earring'}

	sets.engaged = set_combine(sets.idle, {head = 'Volte Cap', body = 'Volte Jupon'})

	sets.midcast.Pet.PetWSGear = {head = 'Null Masque'}
	sets.midcast.Pet.PetWSGear.Melee = {head = 'Null Masque', body = 'Adamantite Armor'}
	sets.midcast.Pet.PetEnmityGear = {waist = 'Wanion Belt'}
	sets.midcast.Pet.Cure = {back = 'Prodigious Mantle'}

	sets.precast.FC = {head = 'Volte Cap'}
	sets.precast.JA.Activate = {head = 'Null Masque'}
	sets.precast.JA.Repair = {head = 'Null Masque'}
	sets.precast.WS['Victory Smite'] = {head = 'Null Masque', ear1 = 'Moonshade Earring'}
	sets.MaxTP = {ear1 = 'Sortiarius Earring', ear2 = 'Pensee Earring'}
	sets.AccMaxTP = {ear1 = 'Beatific Earring', ear2 = 'Pensee Earring'}

	sets.midcast.Cure = {ring1 = 'Gelatinous Ring'}
	sets.midcast.LightWeatherCure = {ring1 = 'Lunette Ring'}
	sets.midcast.LightDayCure = {ring1 = 'Pernicious Ring'}
end
