-- A small Sel gear file for the tests of data/SAM.lua. Each set wears pieces that tell it apart from the others, from
-- the gear the tests give Jobby, and names the slots of its own so that whichever set was on before, the one chosen
-- shows whole.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc', 'FullAcc')
	state.HybridMode:options('Normal', 'DT', 'Reraise')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.IdleMode:options('Normal', 'DT')
	state.PhysicalDefenseMode:options('PDT', 'PDTReraise')
	state.MagicalDefenseMode:options('MDT', 'MDTReraise')
	state.Weapons:options('None', 'Masamune', 'Sword')
end

function init_gear_sets()
	sets.weapons.Masamune = {main = 'Masamune'}
	sets.weapons.Sword = {main = "Judge's Sword"}

	sets.idle = {main = 'Masamune', head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
		legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
		ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
		back = 'Mecisto. Mantle'}

	sets.engaged = {head = "Bendis's Hairpin", body = 'Sapphire Platemail', feet = 'Nyame Sollerets'}
	sets.engaged.Acc = {head = "Bendis's Hairpin", body = 'Jadeite Cuirie', feet = 'Nyame Sollerets'}
	sets.engaged.DT = {head = "Theia's Hairpin", body = 'Sapphire Platemail', feet = 'Nyame Sollerets'}

	sets.defense.PDT = {hands = 'Sapphire Gauntlets'}
	sets.defense.PDTReraise = {hands = 'Jadeite Gloves'}
	sets.defense.MDT = {legs = 'Sapphire Trousers'}
	sets.defense.MDTReraise = {legs = 'Jadeite Chausses'}

	sets.Reraise = {body = 'Diamond Haramaki'}
	sets.buff.Hasso = {feet = 'Sapphire Leggings'}
	sets.buff['Third Eye'] = {feet = 'Jadeite Jambeaux'}
	sets.buff.Sekkanoki = {hands = 'Diamond Kote'}
	sets.buff.Sengikori = {legs = 'Diamond Hiza.'}
	sets.buff['Meikyo Shisui'] = {feet = 'Diamond Sune-Ate'}

	sets.precast.WS = {head = "Theia's Hairpin", neck = 'Orunmila\'s Torque'}
	sets.precast.WS['Tachi: Fudo'] = {head = "Theia's Hairpin", ear1 = 'Moonshade Earring', ear2 = 'Etiolation Earring'}
	sets.precast.WS['Tachi: Gekko'] = {head = "Theia's Hairpin", ear1 = 'Lugra Earring +1', ear2 = 'Etiolation Earring'}
	sets.MaxTP = {ear1 = 'Ishvara Earring'}
	sets.AccMaxTP = {ear1 = 'Brutal Earring'}
	sets.DayWSEars = {ear1 = 'Hecate\'s Earring'}
	sets.AccDayWSEars = {ear1 = 'Pixie Earring'}
	sets.DayMaxTPWSEars = {ear1 = 'Beastly Earring'}
	sets.AccDayMaxTPWSEars = {ear1 = 'Stealth Earring'}
end
