-- Jobby's thief gear file, loaded by the real data/THF.lua for the tests of what that file does on top of Sel.
-- Each set that the job file looks for wears pieces that tell it apart from the others, in a slot of its own where
-- two of them can be on together. The engaged sets name the same slots, so whichever was on before, the one chosen
-- shows whole.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.IdleMode:options('Normal')
	state.Weapons:options('None', 'Knife')
	state.AmbushMode = M(false, 'Ambush Mode')
end

function init_gear_sets()
	sets.TreasureHunter = {head = 'Null Masque', waist = 'Null Belt'}
	sets.buff['Sneak Attack'] = {body = 'Adamantite Armor'}
	sets.buff['Trick Attack'] = {hands = 'Volte Bracers'}
	sets.buff.Feint = {legs = 'Volte Hose'}
	sets.Ambush = {feet = 'Volte Boots'}

	sets.precast.JA['Sneak Attack'] = {ring1 = 'Chirich Ring +1'}
	sets.precast.JA['Trick Attack'] = {ring1 = 'Chirich Ring +1'}

	sets.precast.WS = {neck = 'Fotia Gorget', ear1 = 'Moonshade Earring', ear2 = 'Brutal Earring'}
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {back = 'Null Shawl'})
	sets.precast.WS["Rudra's Storm"] = set_combine(sets.precast.WS, {waist = 'Fotia Belt'})
	sets.precast.WS["Rudra's Storm"].Acc = set_combine(sets.precast.WS["Rudra's Storm"], {back = 'Null Shawl'})
	sets.precast.WS["Rudra's Storm"].SA = set_combine(sets.precast.WS["Rudra's Storm"], {ring1 = 'Karieyh Ring'})
	sets.precast.WS["Rudra's Storm"].TA = set_combine(sets.precast.WS["Rudra's Storm"], {ring2 = 'Karieyh Ring'})
	sets.precast.WS["Rudra's Storm"].SATA = set_combine(sets.precast.WS["Rudra's Storm"],
		{ring1 = 'Karieyh Ring', ring2 = 'Chirich Ring +1'})
	sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS, {waist = 'Fotia Belt'})
	sets.MaxTP = {ear1 = 'Cessance Earring'}
	sets.AccMaxTP = {ear1 = 'Odnowa Earring +1'}

	sets.idle = {ammo = 'Staunch Tathlum +1', head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
		legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
		ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
		back = 'Moonbeam Cape'}

	sets.engaged = {head = 'Volte Cap', body = 'Volte Jupon', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt'}
	sets.engaged.Acc = set_combine(sets.engaged, {neck = 'Fotia Gorget'})
	sets.engaged.DT = set_combine(sets.engaged, {neck = "Combatant's Torque"})
	sets.engaged.Knife = set_combine(sets.engaged, {hands = 'Volte Bracers'})
	sets.weapons.Knife = {main = 'Qutrub Knife'}
end
