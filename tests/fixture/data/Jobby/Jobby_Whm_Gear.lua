-- Jobby's white mage gear file, loaded by the real data/WHM.lua for the tests of what that file does on top of Sel.
-- Each set that the job file looks for wears pieces that tell it apart from the others. The cure and curaga sets
-- each wear a head of their own, which is how a test tells the spell map the job file chose.

function user_job_setup()
	state.OffenseMode:options('None')
	state.CastingMode:options('Normal', 'Proc')
	state.IdleMode:options('Normal', 'DT')
	state.Weapons:options('None', 'Daybreak')
end

function init_gear_sets()
	sets.weapons.Daybreak = {main = 'Daybreak', sub = 'Ammurapi Shield'}

	sets.precast.FC = {neck = 'Fotia Gorget'}
	sets.precast.FC.Proc = {neck = "Combatant's Torque"}
	sets.precast.WS = {ear1 = 'Moonshade Earring', ear2 = 'Brutal Earring'}
	sets.MaxTP = {ear1 = 'Cessance Earring'}

	sets.midcast.FastRecast = {feet = 'Volte Boots'}
	sets.midcast.Proc = {legs = 'Volte Hose'}

	sets.midcast.Cure = {head = 'Volte Cap'}
	sets.midcast.CureSolace = {head = 'Null Masque'}
	sets.midcast.LightWeatherCure = {head = 'Amin Turban'}
	sets.midcast.LightDayCure = {head = 'Ischkur Turban'}
	sets.midcast.LightWeatherCureSolace = {head = 'Azimuth Turban'}
	sets.midcast.LightDayCureSolace = {head = 'Blistering Sallet'}
	sets.midcast.MeleeCure = {head = 'Blistering Sallet +1'}
	sets.midcast.MeleeCureSolace = {head = 'Alhazen Hat'}
	sets.midcast.MeleeLightWeatherCure = {head = 'Alhazen Hat +1'}
	sets.midcast.MeleeLightDayCure = {head = 'Sukeroku Hachi.'}
	sets.midcast.MeleeLightWeatherCureSolace = {head = "Bendis's Hairpin"}
	sets.midcast.MeleeLightDayCureSolace = {head = 'Blacksh. Hairpin'}
	sets.midcast.Curaga = {head = 'Pixie Hairpin +1'}
	sets.midcast.LightWeatherCuraga = {head = "Theia's Hairpin +1"}
	sets.midcast.LightDayCuraga = {head = 'Imp. Wing Hairpin'}

	sets.midcast.StatusRemoval = {hands = 'Volte Bracers'}
	sets.midcast.BarElement = {body = 'Volte Jupon'}
	sets.midcast.BarElement.LightArts = {body = 'Adamantite Armor'}
	sets.buff['Divine Caress'] = {ring1 = 'Karieyh Ring'}

	sets.idle = {main = "Terra's Staff", ammo = 'Staunch Tathlum +1', head = 'Nyame Helm', body = 'Nyame Mail',
		hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1',
		waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring',
		ring2 = 'Stikini Ring +1', back = 'Moonbeam Cape'}
	sets.idle.DT = set_combine(sets.idle, {head = 'Null Masque'})

	sets.latent_refresh = {waist = 'Null Belt'}
	sets.latent_refresh_grip = {sub = 'Kupo Shield'}
	sets.TPEat = {ear1 = 'Cessance Earring'}
	sets.buff.Sublimation = {back = 'Null Shawl'}
	sets.buff.DTSublimation = {back = 'Null Shawl', neck = "Combatant's Torque"}
end
