-- A small Sel gear file for the tests of data/BST.lua. Each set wears pieces that tell it apart from the others, from
-- the gear the tests give Jobby, and names the slots of its own so that whichever set was on before, the one chosen
-- shows whole.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.IdleMode:options('Normal')
	state.PhysicalDefenseMode:options('PDT')
	state.CorrelationMode = M{['description'] = 'Correlation Mode', 'Neutral', 'Favorable'}
	state.ExtraMeleeMode = M{['description'] = 'Extra Melee Mode', 'None'}
end

function init_gear_sets()
	sets.idle = {main = "Judge's Sword", head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
		legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
		ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
		back = 'Mecisto. Mantle'}
	sets.idle.Pet = set_combine(sets.idle, {back = 'Aptitude Mantle'})
	sets.idle.Pet.Tank = set_combine(sets.idle.Pet, {ring1 = "Tyrant's Ring"})
	sets.idle.Pet.DD = set_combine(sets.idle.Pet, {ring2 = 'Moepapa Ring'})
	sets.idle.Pet.Engaged = set_combine(sets.idle.Pet, {waist = 'Prosilio Belt'})
	sets.idle.Pet.Engaged.Tank = set_combine(sets.idle.Pet.Engaged, {ring1 = "Tyrant's Ring"})
	sets.idle.Pet.Engaged.DD = set_combine(sets.idle.Pet.Engaged, {ring2 = 'Moepapa Ring'})
	sets.idle.Pet.DW = {sub = 'Aern Sword'}
	sets.idle.Pet.Engaged.DW = {sub = 'Trainee Sword'}

	sets.engaged = {head = "Bendis's Hairpin", body = 'Diamond Haramaki'}

	sets.precast.JA.Reward = {legs = 'Sapphire Trousers'}
	sets.precast.JA.Reward.Theta = {ammo = 'Pet Food Theta', feet = 'Sapphire Leggings'}
	sets.precast.JA.Reward.Zeta = {ammo = 'Pet Food Zeta', feet = 'Jadeite Jambeaux'}
	sets.precast.JA.Reward.Eta = {ammo = 'Pet Food Eta', feet = 'Diamond Sune-Ate'}
	sets.precast.JA.Reward.DW = {sub = 'Aern Sword'}
	sets.precast.JA.Spur = {back = 'Aptitude Mantle'}
	sets.SpurAxe = {main = "Charmer's Merlin"}
	sets.SpurAxesDW = {main = "Charmer's Merlin", sub = 'Aern Sword'}
	sets.precast.JA['Bestial Loyalty'] = {head = "Bendis's Hairpin"}
	sets.precast.JA['Bestial Loyalty'].PonderingPeter = {hands = 'Sapphire Gauntlets'}
	sets.precast.JA['Bestial Loyalty'].BouncingBertha = {hands = 'Jadeite Gloves'}
	sets.precast.JA['Bestial Loyalty'].DroopyDortwin = {hands = 'Diamond Kote'}
	sets.precast.JA['Bestial Loyalty'].ScissorlegXerin = {hands = 'Diamond Kote', legs = 'Jadeite Chausses'}
	sets.precast.JA['Call Beast'] = sets.precast.JA['Bestial Loyalty']

	sets.precast.WS = {head = "Theia's Hairpin", neck = "Orunmila's Torque"}
	sets.precast.WS['Savage Blade'] = {head = "Theia's Hairpin", ear1 = 'Moonshade Earring', ear2 = 'Etiolation Earring'}
	sets.precast.WS['Cloudsplitter'] = {head = "Theia's Hairpin", ear1 = 'Lugra Earring +1', ear2 = 'Etiolation Earring'}
	sets.MaxTP = {ear1 = 'Ishvara Earring'}
	sets.AccMaxTP = {ear1 = 'Brutal Earring'}
	sets.DayWSEars = {ear1 = "Hecate's Earring"}
	sets.AccDayWSEars = {ear1 = 'Pixie Earring'}
	sets.buff['Killer Instinct'] = {back = 'Aptitude Mantle'}

	sets.midcast.Pet.WS = {body = 'Sapphire Platemail'}
	sets.midcast.Pet.Acc = {body = 'Jadeite Cuirie'}
	sets.midcast.Pet.MagicReady = {neck = "Orunmila's Torque"}
	sets.midcast.Pet.MagicReady.Acc = {neck = 'Phrenic Torque'}
	sets.midcast.Pet.DebuffReady = {hands = 'Sapphire Gauntlets'}
	sets.midcast.Pet.PhysicalDebuffReady = {hands = 'Jadeite Gloves'}
	sets.midcast.Pet.MultiHitReady = {hands = 'Diamond Kote'}
	sets.midcast.Pet.ReadyRecast = {legs = 'Sapphire Trousers'}
	sets.midcast.Pet.ReadyRecastDW = {sub = "Charmer's Merlin"}
	sets.midcast.Pet.Favorable = {head = "Theia's Hairpin"}
	sets.midcast.Pet.TPBonus = {feet = 'Sapphire Leggings'}
end
