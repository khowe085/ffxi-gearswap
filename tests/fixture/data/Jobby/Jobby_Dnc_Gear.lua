-- A small Sel gear file for the tests of data/DNC.lua. Each kind of dancer's ability has a set of its own, over the idle
-- or engaged set, and the buffs a dancer keeps up have theirs.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.IdleMode:options('Normal')
	state.PhysicalDefenseMode:options('PDT')
	state.Weapons:options('None')
end

function init_gear_sets()
	sets.idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring',
		ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1'}

	sets.engaged = set_combine(sets.idle, {head = 'Volte Cap', body = 'Volte Jupon'})
	sets.engaged.Saber = set_combine(sets.idle, {head = 'Volte Cap', body = 'Volte Jupon', hands = 'Volte Bracers'})
	sets.engaged.Fan = set_combine(sets.idle, {head = 'Volte Cap', body = 'Volte Jupon', legs = 'Volte Hose'})
	sets.defense.PDT = {neck = 'Weike Torque'}

	sets.precast.Waltz = {head = 'Null Masque'}
	sets.precast.Waltz['Healing Waltz'] = {head = 'Malignance Chapeau'}
	sets.Self_Waltz = {hands = 'Volte Bracers'}
	sets.precast.Samba = {legs = 'Volte Hose'}
	sets.precast.Step = {head = 'Volte Cap', feet = 'Horos T. Shoes +2'}
	sets.precast.Flourish1 = {back = 'Prodigious Mantle'}
	sets.precast.Flourish2 = {waist = 'Wanion Belt'}
	sets.precast.Flourish3 = {neck = 'Orunmila\'s Torque'}

	sets.precast.WS['Rudra\'s Storm'] = {head = 'Null Masque', ear1 = 'Moonshade Earring'}
	sets.MaxTP = {ear1 = 'Sortiarius Earring', ear2 = 'Pensee Earring'}
	sets.AccMaxTP = {ear1 = 'Beatific Earring', ear2 = 'Pensee Earring'}

	sets.buff['Saber Dance'] = {feet = 'Volte Boots'}
	sets.buff['Climactic Flourish'] = {body = 'Adamantite Armor'}
end
