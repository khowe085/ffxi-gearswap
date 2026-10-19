-- Jobby's monk gear file, loaded by the real data/MNK.lua for the tests of what that file does on top of Sel.
-- Each set that the job file looks for wears pieces that tell it apart from the others. The engaged sets name the
-- same slots, so whichever was on before, the one chosen shows whole.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc', 'FullAcc')
	state.HybridMode:options('Normal')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.IdleMode:options('Normal')
	state.PhysicalDefenseMode:options('PDT')
	state.Weapons:options('None')
end

function init_gear_sets()
	sets.precast.JA.Boost = {hands = 'Volte Bracers'}
	sets.precast.JA.Boost.OutOfCombat = {feet = 'Volte Boots'}
	sets.precast.JA.Chakra = {head = 'Null Masque'}

	sets.precast.WS = {head = 'Volte Cap', neck = 'Fotia Gorget', ear1 = 'Moonshade Earring', ear2 = 'Brutal Earring'}
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {body = 'Volte Jupon'})
	sets.precast.WS['Victory Smite'] = set_combine(sets.precast.WS, {waist = 'Fotia Belt'})
	sets.precast.WS['Victory Smite'].Acc = set_combine(sets.precast.WS['Victory Smite'], {body = 'Volte Jupon'})

	sets.MaxTP = {ear1 = 'Cessance Earring'}
	sets.AccMaxTP = {ear1 = 'Odnowa Earring +1'}

	sets.buff.Impetus = {back = 'Null Shawl'}
	sets.buff.ImpetusWS = {neck = "Combatant's Torque"}
	sets.buff.Footwork = {feet = 'Volte Boots'}
	sets.buff.Boost = {ring1 = 'Karieyh Ring'}

	sets.idle = {ammo = 'Staunch Tathlum +1', head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
		legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
		ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
		back = 'Moonbeam Cape'}

	sets.engaged = {head = 'Volte Cap', body = 'Volte Jupon', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', waist = 'Plat. Mog. Belt', ring1 = 'Defending Ring', back = 'Moonbeam Cape'}
	sets.engaged.Acc = set_combine(sets.engaged, {body = 'Adamantite Armor'})
	sets.engaged.FullAcc = set_combine(sets.engaged, {head = 'Null Masque'})
	sets.engaged.HF = set_combine(sets.engaged, {legs = 'Volte Hose'})
	sets.engaged.Footwork = set_combine(sets.engaged, {waist = 'Null Belt'})
	sets.engaged.HF.Footwork = set_combine(sets.engaged.HF, {waist = 'Null Belt', hands = 'Volte Bracers'})
	sets.defense.PDT = {neck = "Combatant's Torque"}
end
