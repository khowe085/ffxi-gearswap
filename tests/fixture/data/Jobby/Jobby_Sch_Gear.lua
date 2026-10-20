-- A small Sel gear file for the tests of data/SCH.lua. The sets a scholar's job file lays over a spell's, one for each
-- stratagem and each of the spell maps it makes, wear pieces that tell them apart.

function user_job_setup()
	state.OffenseMode:options('Normal')
	state.HybridMode:options('Normal')
	state.CastingMode:options('Normal', 'Resistant', 'Proc', 'OccultAcumen')
	state.IdleMode:options('Normal', 'DT')
	state.Weapons:options('None', 'Staff')
end

function init_gear_sets()
	gear.obi_cure_back = 'Prodigious Mantle'
	gear.obi_cure_waist = 'Wanion Belt'
	gear.obi_low_nuke_waist = 'Plat. Mog. Belt'
	gear.obi_high_nuke_waist = 'Hachirin-no-Obi'

	sets.weapons.Staff = {main = 'Bunzi\'s Rod'}

	sets.idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring',
		ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1'}
	sets.idle.DT = set_combine(sets.idle, {body = 'Volte Jupon'})
	sets.latent_refresh = {waist = 'Wanion Belt'}
	sets.latent_refresh_grip = {ring2 = 'Gelatinous Ring'}
	sets.TPEat = {neck = 'Weike Torque'}
	sets.buff.Sublimation = {ring2 = 'Lunette Ring'}
	sets.buff.DTSublimation = {ring2 = 'Pernicious Ring'}

	sets.precast.FC = {head = 'Volte Cap'}
	sets.precast.FC.Arts = {body = 'Volte Jupon'}
	sets.precast.FC.Arts['Enhancing Magic'] = {body = 'Adamantite Armor'}
	sets.precast.FC.Arts.Cure = {legs = 'Volte Hose'}
	sets.precast.FC.Arts.Dispel = {waist = 'Wanion Belt'}
	sets.precast.FC.Proc = {head = 'Null Masque'}
	sets.precast.FC.OccultAcumen = {head = 'Kaykaus Mitra +1'}

	sets.midcast.Cure = {ring1 = 'Gelatinous Ring'}
	sets.midcast.MeleeCure = {ring1 = 'Cacoethic Ring'}
	sets.midcast.LightWeatherCure = {ring1 = 'Lunette Ring'}
	sets.midcast.LightDayCure = {ring1 = 'Pernicious Ring'}
	sets.midcast.MeleeLightWeatherCure = {ring1 = 'Petrov Ring'}
	sets.midcast.MeleeLightDayCure = {ring1 = 'Fortified Ring'}
	sets.midcast.LowTierNuke = {ring1 = 'Vertigo Ring'}
	sets.midcast.HighTierNuke = {ring1 = 'Dhanurveda Ring'}
	sets.midcast.Helix = {ring1 = 'Gelatinous Ring', ear1 = 'Pensee Earring'}
	sets.midcast.ElementalEnfeeble = {ring1 = 'Kishar Ring'}
	sets.midcast['Elemental Magic'] = {ear1 = 'Choleric Earring'}
	sets.midcast['Enfeebling Magic'] = {ear1 = 'Beatific Earring'}
	sets.midcast['Enhancing Magic'] = {ear1 = 'Sortiarius Earring'}
	sets.midcast.Regen = {ear1 = 'Sortiarius Earring'}

	sets.buff['Light Arts'] = {hands = 'Volte Bracers'}
	sets.buff['Dark Arts'] = {legs = 'Volte Hose'}
	sets.buff.Perpetuance = {feet = 'Volte Boots'}
	sets.buff.Rapture = {head = 'Null Masque'}
	sets.buff.Focalization = {head = 'Kaykaus Mitra +1'}
	sets.buff.Penury = {neck = 'Orunmila\'s Torque'}
	sets.buff.Parsimony = {neck = 'Weike Torque'}
	sets.buff.Celerity = {waist = 'Wanion Belt'}
	sets.buff.Alacrity = {back = 'Prodigious Mantle'}
	sets.buff.Klimaform = {feet = 'Plumb Boots'}
	sets.buff.Ebullience = {hands = 'Volte Bracers', head = 'Null Masque'}
	sets.buff.Immanence = {hands = 'Volte Bracers', legs = 'Volte Hose'}
end
