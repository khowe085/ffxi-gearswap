-- A small Sel gear file for the tests of data/DRG.lua. Each set wears pieces that tell it apart from the others, from
-- the gear the tests give Jobby, and names the slots of its own so that whichever set was on before, the one chosen
-- shows whole.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.IdleMode:options('Normal')
	state.PhysicalDefenseMode:options('PDT')
end

function init_gear_sets()
	sets.idle = {main = 'Pitchfork +1', head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
		legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
		ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
		back = 'Mecisto. Mantle'}

	sets.engaged = {head = "Bendis's Hairpin", body = 'Sapphire Platemail', feet = 'Nyame Sollerets'}
	sets.engaged.Pet = {head = "Bendis's Hairpin", body = 'Jadeite Cuirie', feet = 'Nyame Sollerets'}
	sets.engaged.Pet.SpiritSurge = {head = "Bendis's Hairpin", body = 'Diamond Haramaki', feet = 'Nyame Sollerets'}
	sets.engaged.SpiritSurge = {head = "Bendis's Hairpin", body = 'Sapphire Platemail', feet = 'Sapphire Leggings'}

	sets.precast.JA.Jump = {hands = 'Sapphire Gauntlets'}
	sets.precast.JA.Jump.Acc = {hands = 'Jadeite Gloves'}
	sets.precast.JA['High Jump'] = {legs = 'Sapphire Trousers'}
	sets.precast.JA['Spirit Jump'] = {hands = 'Diamond Kote'}
	sets.precast.JA['Spirit Jump'].Acc = {hands = 'Diamond Kote', legs = 'Jadeite Chausses'}
	sets.precast.JA['Spirit Link'] = {legs = 'Diamond Hiza.'}
	sets.precast.JA['Spirit Link'].Acc = {legs = 'Jadeite Chausses'}

	sets.precast.WS = {head = "Theia's Hairpin", neck = "Orunmila's Torque"}
	sets.precast.WS['Stardiver'] = {head = "Theia's Hairpin", ear1 = 'Moonshade Earring', ear2 = 'Etiolation Earring'}
	sets.MaxTP = {ear1 = 'Ishvara Earring'}
	sets.AccMaxTP = {ear1 = 'Brutal Earring'}

	sets.midcast.HB_Trigger = {head = "Theia's Hairpin"}
	sets.HealingBreath = {neck = "Orunmila's Torque"}
	sets.SmitingBreath = {back = 'Aptitude Mantle'}
end
