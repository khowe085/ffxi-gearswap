-- A small Sel gear file for the tests of data/SMN.lua. Each set wears pieces that tell it apart from the others, from
-- the gear the tests give Jobby, and names the slots of its own so that whichever set was on before, the one chosen
-- shows whole.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.CastingMode:options('Normal', 'Resistant', 'Proc')
	state.IdleMode:options('Normal', 'DT')
	state.PhysicalDefenseMode:options('PDT')
end

function init_gear_sets()
	sets.idle = {main = "Judge's Sword", head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
		legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
		ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
		back = 'Mecisto. Mantle'}
	sets.idle.DT = set_combine(sets.idle, {body = 'Sapphire Platemail'})
	sets.idle.Pet = set_combine(sets.idle, {back = 'Aptitude Mantle'})
	sets.idle.Pet.Engaged = set_combine(sets.idle.Pet, {waist = 'Prosilio Belt'})
	sets.idle.Pet.Avatar = set_combine(sets.idle.Pet, {feet = 'Sapphire Leggings'})
	sets.idle.Pet.Spirit = set_combine(sets.idle.Pet, {feet = 'Jadeite Jambeaux'})
	sets.idle.Pet.Engaged.Avatar = set_combine(sets.idle.Pet.Engaged, {feet = 'Diamond Sune-Ate'})

	sets.idle.Avatar = {}
	sets.idle.Avatar.Favor = {neck = "Orunmila's Torque"}
	sets.idle.Avatar.Engaged = {hands = 'Sapphire Gauntlets'}
	sets.idle.Avatar.Engaged.Ifrit = {hands = 'Jadeite Gloves'}

	sets.perp = {}
	sets.perp.Day = {head = "Bendis's Hairpin"}
	sets.perp.Weather = {ring1 = "Tyrant's Ring"}
	sets.perp.Ifrit = {legs = 'Sapphire Trousers'}

	sets.latent_refresh = {ear1 = 'Ishvara Earring'}
	sets.buff.Sublimation = {ear2 = 'Brutal Earring'}

	sets.precast.FC = {head = "Bendis's Hairpin"}
	sets.precast.FC.Proc = {head = "Theia's Hairpin"}
	sets.midcast.Proc = {body = 'Ruby Robe'}

	sets.midcast.Pet = {}
	sets.midcast.Pet.PhysicalBloodPactRage = {body = 'Sapphire Platemail'}
	sets.midcast.Pet.PhysicalBloodPactRage.Ifrit = {legs = 'Sapphire Trousers'}
	sets.midcast.Pet.PhysicalBloodPactRage.AM = {hands = 'Jadeite Gloves'}
	sets.midcast.Pet.PhysicalBloodPactRage.Acc = {feet = 'Sapphire Leggings'}
	sets.midcast.Pet.MagicalBloodPactRage = {body = 'Jadeite Cuirie'}
	sets.midcast.Pet.MagicalBloodPactRage.Ifrit = {legs = 'Jadeite Chausses'}
	sets.midcast.Pet.MagicalBloodPactRage.Acc = {feet = 'Jadeite Jambeaux'}
	sets.midcast.Pet.BloodPactWard = {body = 'Diamond Haramaki'}
	sets.midcast.Pet.BloodPactWard.Ifrit = {legs = 'Diamond Hiza.'}
	sets.midcast.Pet['Flaming Crush'] = {hands = 'Diamond Kote'}
	sets.midcast.Pet['Flaming Crush'].AM = {waist = 'Prosilio Belt'}
	sets.midcast.Pet['Flaming Crush'].Acc = {back = 'Aptitude Mantle'}
	sets.midcast.Pet['Elemental Magic'] = {neck = "Orunmila's Torque"}
	sets.midcast.Pet['Elemental Magic'].Resistant = {neck = 'Phrenic Torque'}
end
