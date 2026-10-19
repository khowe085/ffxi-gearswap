-- A small Sel gear file for the tests of data/NIN.lua. Each set wears pieces that tell it apart from the others, from
-- the gear the tests give Jobby, and names the slots of its own so that whichever set was on before, the one chosen
-- shows whole.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Fodder', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal')
	state.CastingMode:options('Normal', 'Proc')
	state.IdleMode:options('Normal', 'DT')
	state.PhysicalDefenseMode:options('PDT')
end

function init_gear_sets()
	sets.idle = {main = "Judge's Sword", head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
		legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
		ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
		back = 'Mecisto. Mantle'}

	sets.engaged = {head = "Bendis's Hairpin", body = 'Sapphire Platemail'}
	sets.engaged.Acc = {head = "Bendis's Hairpin", body = 'Jadeite Cuirie'}

	sets.defense.PDT = {legs = 'Jadeite Chausses'}

	sets.precast.FC = {head = "Bendis's Hairpin"}
	sets.precast.FC.Utsusemi = {head = "Theia's Hairpin"}

	sets.midcast.Utsusemi = {hands = 'Sapphire Gauntlets'}
	sets.midcast.ElementalNinjutsu = {hands = 'Jadeite Gloves'}
	sets.midcast.NinjutsuBuff = {hands = 'Diamond Kote'}
	sets.midcast.NinjutsuDebuff = {legs = 'Sapphire Trousers'}

	sets.buff.Futae = {feet = 'Diamond Sune-Ate'}
	sets.buff.Yonin = {body = 'Diamond Haramaki'}
	sets.buff.Innin = {body = 'Jadeite Cuirie'}
	sets.buff.Migawari = {neck = "Orunmila's Torque"}
end
