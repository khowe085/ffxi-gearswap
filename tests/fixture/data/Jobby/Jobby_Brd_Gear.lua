-- A small Sel gear file for the tests of data/BRD.lua. Each set wears pieces that tell it apart from the others, from
-- the gear the tests give Jobby, so that what is worn shows which sets were laid over which.

function user_job_setup()
	info.ExtraSongs = 1
	info.ExtraSongInstrument = 'Daurdabla'

	state.OffenseMode:options('Normal')
	state.CastingMode:options('Normal', 'Resistant')
	state.IdleMode:options('Normal', 'DT')
	state.Weapons:options('None', 'Sword')
end

function init_gear_sets()
	sets.weapons.Sword = {main = "Judge's Sword"}

	sets.idle = {main = "Judge's Sword", head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
		legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
		ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
		back = 'Mecisto. Mantle'}
	sets.idle.DT = set_combine(sets.idle, {body = 'Sapphire Platemail'})
	sets.latent_refresh = {waist = 'Prosilio Belt'}
	sets.TPEat = {neck = "Orunmila's Torque"}
	sets.buff.Sublimation = {back = 'Aptitude Mantle'}
	sets.buff.DTSublimation = {back = 'Aptitude Mantle', neck = "Orunmila's Torque"}

	sets.precast.FC = {head = "Bendis's Hairpin"}
	sets.precast.FC.SongDebuff = {head = "Theia's Hairpin"}
	sets.precast.FC['Mage\'s Ballad'] = {head = "Bendis's Hairpin", ring1 = 'Tyrant\'s Ring'}
	sets.precast.FC['Horde Lullaby'] = {head = 'Bendis\'s Hairpin', ring1 = "Tyrant's Ring"}
	sets.precast.FC.Cure = {head = "Bendis's Hairpin"}

	sets.midcast.SongEffect = {main = 'Carnwenhan', body = 'Sapphire Platemail', legs = 'Volte Brais'}
	sets.midcast.SongEffect.Resistant = {main = 'Carnwenhan', body = 'Ruby Robe'}
	sets.midcast.SongDebuff = {main = 'Carnwenhan', body = 'Diamond Haramaki', hands = 'Volte Bracers'}
	sets.midcast.SongDebuff.Resistant = {main = 'Carnwenhan', body = 'Jadeite Cuirie'}
	sets.midcast.SongDebuff.DW = {waist = 'Prosilio Belt'}
	sets.midcast.DaurdablaDummy = {body = 'Rage Platemail'}
	sets.midcast.Daurdabla = {range = 'Daurdabla'}

	sets.midcast.Ballad = {legs = 'Sapphire Trousers'}
	sets.midcast.March = {legs = 'Jadeite Chausses'}
	sets.midcast.March.Pianissimo = {legs = 'Diamond Hiza.'}
	sets.midcast.March['Soul Voice'] = {feet = 'Diamond Sune-Ate'}
	sets.midcast.Lullaby = {legs = 'Sapphire Trousers'}
	sets.midcast.Lullaby.Resistant = {legs = 'Jadeite Chausses'}
	sets.midcast['Foe Lullaby'] = {hands = 'Sapphire Gauntlets'}
	sets.midcast['Foe Lullaby'].Resistant = {hands = 'Jadeite Gloves'}
	sets.midcast.Pianissimo = {hands = 'Jadeite Gloves'}
	sets.midcast['Soul Voice'] = {hands = 'Diamond Kote'}

	sets.midcast.Cure = {hands = 'Sapphire Gauntlets'}
	sets.midcast.LightWeatherCure = {hands = 'Jadeite Gloves'}
	sets.midcast.LightDayCure = {hands = 'Diamond Kote'}
end
