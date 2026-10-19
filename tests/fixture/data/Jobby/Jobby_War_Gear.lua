-- Jobby's warrior gear file, loaded by the real data/WAR.lua for the tests of what that file does on top of Sel.
-- Each set that the job file looks for wears pieces that tell it apart from the others, from the gear the tests give
-- Jobby. The sets of one kind (engaged, weapon skill) each name the same slots, so whichever was on before, the
-- one chosen shows whole.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.IdleMode:options('Normal')
	state.Weapons:options('None', 'Naegling', 'Conqueror')
end

function init_gear_sets()
	sets.weapons.Naegling = {main = 'Naegling'}
	sets.weapons.Conqueror = {main = 'Conqueror'}

	sets.precast.JA.Berserk = {main = 'Conqueror', body = 'Volte Jupon'}
	sets.precast.JA.Warcry = {head = 'Null Masque'}
	sets.precast.JA.Retaliation = {hands = 'Volte Bracers'}

	sets.precast.WS = {head = 'Volte Cap', neck = 'Fotia Gorget', ear1 = 'Moonshade Earring', ear2 = 'Brutal Earring'}
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {body = 'Volte Jupon'})
	sets.precast.WS['Resolution'] = set_combine(sets.precast.WS, {hands = 'Volte Bracers'})
	sets.precast.WS['Resolution'].Acc = set_combine(sets.precast.WS['Resolution'], {body = 'Volte Jupon'})
	sets.precast.WS['Ground Strike'] = set_combine(sets.precast.WS, {ear1 = 'Lugra Earring'})
	sets.precast.WS['Ground Strike'].Acc = set_combine(sets.precast.WS['Ground Strike'], {body = 'Volte Jupon'})
	sets.precast.WS['Upheaval'] = set_combine(sets.precast.WS, {ear2 = 'Lugra Earring'})
	sets.precast.WS['Upheaval'].Acc = set_combine(sets.precast.WS['Upheaval'], {body = 'Volte Jupon'})

	sets.MaxTP = {ear1 = 'Lugra Earring'}
	sets.DayMaxTPWSEars = {ear1 = 'Cessance Earring'}
	sets.AccMaxTP = {ear1 = 'Lugra Earring', body = 'Adamantite Armor'}
	sets.AccDayMaxTPWSEars = {ear1 = 'Odnowa Earring +1', body = 'Adamantite Armor'}
	sets.DayWSEars = {ear1 = 'Cessance Earring'}
	sets.AccDayWSEars = {ear1 = 'Odnowa Earring +1'}
	sets.WSMighty = {legs = 'Volte Hose'}
	sets.WSCharge = {hands = 'Volte Bracers'}
	sets.WSMightyCharge = {feet = 'Volte Boots'}
	sets.ACCWSMighty = {}
	sets.AccWSMighty = {ring2 = 'Chirich Ring +1'}
	sets.ACCWSCharge = {waist = 'Null Belt'}
	sets.ACCWSMightyCharge = {ring1 = 'Karieyh Ring'}

	sets.idle = {ammo = 'Staunch Tathlum +1', head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
		legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
		ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
		back = 'Moonbeam Cape'}

	sets.engaged = {head = 'Volte Cap', body = 'Volte Jupon', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', waist = 'Plat. Mog. Belt', ring1 = 'Defending Ring'}
	sets.engaged.Acc = set_combine(sets.engaged, {body = 'Adamantite Armor'})
	sets.engaged.DT = set_combine(sets.engaged, {head = 'Null Masque'})
	sets.engaged.Charge = set_combine(sets.engaged, {hands = 'Volte Bracers'})
	sets.engaged.Charge.Mighty = set_combine(sets.engaged.Charge, {feet = 'Volte Boots'})
	sets.engaged.Mighty = set_combine(sets.engaged, {legs = 'Volte Hose'})

	sets.buff.Retaliation = {waist = 'Null Belt'}
	sets.buff.Restraint = {ring1 = 'Karieyh Ring'}
end
