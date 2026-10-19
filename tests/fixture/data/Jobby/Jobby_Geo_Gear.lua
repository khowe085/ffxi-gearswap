-- A small Sel gear file for the tests of data/GEO.lua. The sets for each of a geomancer's moments (an indicolure out,
-- Blaze of Glory, a Geo spell) wear pieces that tell them apart.

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
	sets.idle.Indi = set_combine(sets.idle, {legs = 'Volte Hose'})
	sets.idle.DT.Indi = set_combine(sets.idle.DT, {legs = 'Volte Hose', feet = 'Volte Boots'})
	sets.latent_refresh = {waist = 'Wanion Belt'}
	sets.latent_refresh_grip = {ring2 = 'Gelatinous Ring'}
	sets.buff.Sublimation = {ring2 = 'Lunette Ring'}
	sets.buff.DTSublimation = {ring2 = 'Pernicious Ring'}

	sets.precast.FC = {head = 'Volte Cap'}
	sets.precast.FC.Proc = {head = 'Null Masque'}

	sets.midcast.Geomancy = {hands = 'Volte Bracers', main = 'Daybreak'}
	sets.midcast.Geomancy.Indi = {hands = 'Volte Bracers', main = 'Daybreak', body = 'Adamantite Armor'}
	sets.buff['Blaze of Glory'] = {hands = 'Volte Bracers'}
	sets.buff.Entrust = {neck = 'Weike Torque'}

	sets.midcast.Cure = {ring1 = 'Gelatinous Ring'}
	sets.midcast.LightWeatherCure = {ring1 = 'Lunette Ring'}
	sets.midcast.LightDayCure = {ring1 = 'Pernicious Ring'}
	sets.midcast.LowTierNuke = {ring1 = 'Vertigo Ring'}
	sets.midcast.HighTierNuke = {ring1 = 'Dhanurveda Ring'}
	sets.midcast['Elemental Magic'] = {ear1 = 'Choleric Earring'}
	sets.midcast.Helix = {ring1 = 'Petrov Ring'}
end
