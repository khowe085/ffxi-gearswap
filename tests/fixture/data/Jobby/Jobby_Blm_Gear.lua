-- Jobby's black mage gear file, loaded by the real data/BLM.lua for the tests of what that file does on top of Sel.
-- Each set that the job file looks for wears pieces that tell it apart from the others, in a slot of its own where
-- two of them can be on together.

function user_job_setup()
	state.OffenseMode:options('None')
	state.CastingMode:options('Normal', 'Resistant', 'Proc', 'OccultAcumen')
	state.IdleMode:options('Normal', 'DT', 'Sphere')
	state.PhysicalDefenseMode:options('PDT')
	state.Weapons:options('None', 'Staff')
end

function init_gear_sets()
	sets.weapons.Staff = {main = 'Daybreak', sub = 'Ammurapi Shield'}

	sets.precast.FC = {neck = 'Fotia Gorget'}
	sets.precast.FC.Death = {hands = 'Volte Bracers'}
	sets.precast.FC.Proc = {neck = "Combatant's Torque"}
	sets.precast.FC.OccultAcumen = {legs = 'Volte Hose'}
	sets.precast.FC['Fire'] = {ring1 = 'Chirich Ring +1'}
	sets.precast.FC['Fire'].Death = {ring1 = 'Karieyh Ring'}
	sets.precast.FC.HighTierNuke = {ring2 = 'Chirich Ring +1'}
	sets.precast.FC.HighTierNuke.Death = {ring2 = 'Karieyh Ring'}
	sets.precast.FC['Dark Magic'] = {waist = 'Null Belt'}
	sets.precast.FC['Dark Magic'].Death = {feet = 'Volte Boots'}

	sets.precast.WS = {ear1 = 'Moonshade Earring', ear2 = 'Brutal Earring'}
	sets.MaxTP = {ear1 = 'Cessance Earring'}

	sets.midcast.FastRecast = {back = 'Null Shawl'}
	sets.midcast.Death = {head = 'Blistering Sallet'}
	sets.midcast.Proc = {legs = 'Volte Hose'}
	sets.midcast.LowTierNuke = {head = 'Volte Cap'}
	sets.midcast.LowTierNuke.Death = {head = 'Null Masque'}
	sets.midcast['Stone'] = {head = 'Volte Cap'}
	sets.midcast['Stone'].Death = {head = 'Sukeroku Hachi.'}
	sets.midcast.HighTierNuke = {head = 'Amin Turban'}
	sets.midcast['Elemental Magic'] = {head = 'Ischkur Turban'}
	sets.midcast['Elemental Magic'].Death = {head = 'Azimuth Turban'}
	sets.midcast.Cure = {head = 'Blistering Sallet +1'}
	sets.midcast.LightWeatherCure = {head = 'Alhazen Hat'}
	sets.midcast.LightDayCure = {head = 'Alhazen Hat +1'}
	sets.midcast.MeleeCure = {head = 'Sukeroku Hachi.'}
	sets.midcast.MeleeLightWeatherCure = {head = "Bendis's Hairpin"}
	sets.midcast.MeleeLightDayCure = {head = 'Blacksh. Hairpin'}

	sets.MagicBurst = {hands = 'Volte Bracers'}
	sets.ResistantMagicBurst = {hands = 'Volte Bracers', body = 'Adamantite Armor'}
	sets.RecoverMP = {waist = 'Null Belt'}

	sets.idle = {ammo = 'Staunch Tathlum +1', head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
		legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
		ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
		back = 'Moonbeam Cape'}
	sets.idle.DT = set_combine(sets.idle, {head = 'Null Masque'})
	sets.idle.Death = {body = 'Adamantite Armor'}
	sets.idle.Sphere = set_combine(sets.idle, {main = "Terra's Staff"})
	sets.latent_refresh_grip = {sub = 'Kupo Shield'}
	sets.latent_refresh = {waist = 'Null Belt'}
	sets.buff.Sublimation = {back = 'Null Shawl'}
	sets.buff.DTSublimation = {back = 'Null Shawl', ring1 = 'Karieyh Ring'}
	sets.buff['Mana Wall'] = {neck = "Combatant's Torque"}

	sets.engaged = {head = 'Volte Cap', body = 'Volte Jupon', neck = 'Loricate Torque +1'}
	sets.defense.PDT = {head = 'Null Masque', neck = 'Loricate Torque +1'}
end
