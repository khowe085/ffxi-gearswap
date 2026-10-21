-- Jobby's red mage gear file, loaded by the real data/RDM.lua for the tests of what that file does on top of Sel.
-- Each set that the job file looks for wears pieces that tell it apart from the others, in a slot of its own where
-- two of them can be on together. The engaged sets name the same slots, so whichever was on before, the one chosen
-- shows whole. The job file lays an enhancing spell's own set again over what Sel put on, so the sets of Haste,
-- Enspell and Refresh name the slots of the DW, SIRD and Self_Refresh sets Sel lays as well: those show only when the
-- job file lays them too. The sets of Convert, Haste and Phalanx II name a weapon, so that the weapon lock shows.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.CastingMode:options('Normal', 'Resistant', 'SIRD')
	state.IdleMode:options('Normal', 'DT', 'Sphere')
	state.Weapons:options('None', 'Naegling', 'Crocea', 'EnspellMelee', 'Ullr')
end

function init_gear_sets()
	sets.weapons.Naegling = {main = 'Naegling'}
	sets.weapons.Crocea = {main = 'Crocea Mors'}
	sets.weapons.EnspellMelee = {main = 'Crocea Mors', sub = 'Ammurapi Shield'}
	sets.weapons.Ullr = {main = 'Naegling', range = empty}

	sets.precast.FC = {neck = 'Fotia Gorget'}
	sets.precast.JA.Convert = {main = 'Murgleis', sub = 'Kupo Shield'}

	sets.precast.WS = {head = 'Volte Cap', ear1 = 'Moonshade Earring', ear2 = 'Brutal Earring'}
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {body = 'Volte Jupon'})
	sets.MaxTP = {ear1 = 'Cessance Earring'}
	sets.AccMaxTP = {ear1 = 'Odnowa Earring +1'}
	sets.MagicalMaxTP = {ear1 = 'Ishvara Earring'}
	sets.MagicalAccMaxTP = {ear1 = 'Telos Earring'}

	sets.midcast.FastRecast = {back = 'Null Shawl'}

	sets.midcast.Cure = {head = 'Blistering Sallet +1'}
	sets.midcast.LightWeatherCure = {head = 'Alhazen Hat'}
	sets.midcast.LightDayCure = {head = 'Alhazen Hat +1'}
	sets.midcast.MeleeCure = {head = 'Sukeroku Hachi.', range = 'Ullr'}
	sets.midcast.MeleeLightWeatherCure = {head = "Bendis's Hairpin"}
	sets.midcast.MeleeLightDayCure = {head = 'Blacksh. Hairpin'}

	sets.midcast.LowTierNuke = {head = 'Volte Cap', range = 'Ullr'}
	sets.midcast.HighTierNuke = {head = 'Amin Turban', range = 'Ullr'}
	sets.midcast['Enfeebling Magic'] = {head = 'Null Masque', range = 'Ullr'}
	sets.midcast['Enfeebling Magic'].Resistant = {head = 'Ischkur Turban'}
	sets.midcast['Dark Magic'] = {head = 'Azimuth Turban', range = 'Ullr'}
	sets.midcast['Slow'] = {body = 'Adamantite Armor'}
	sets.midcast['Slow'].Stymie = {body = 'Volte Jupon'}
	sets.buff.Stymie = {hands = 'Volte Bracers'}
	sets.buff.Saboteur = {legs = 'Volte Hose'}

	sets.midcast['Enhancing Magic'] = {head = 'Volte Cap'}
	sets.midcast['Haste'] = {main = 'Crocea Mors', body = 'Volte Jupon', neck = 'Loricate Torque +1'}
	sets.midcast['Haste'].SIRD = {body = 'Adamantite Armor'}
	sets.midcast['Haste'].DW = {neck = "Combatant's Torque"}
	sets.midcast.Enspell = {main = 'Crocea Mors', hands = 'Volte Bracers', body = 'Volte Jupon',
		legs = 'Nyame Flanchard'}
	sets.midcast.Enspell.SIRD = {main = 'Crocea Mors', hands = 'Volte Bracers', body = 'Adamantite Armor'}
	sets.midcast.Enspell.DW = {legs = 'Volte Hose'}
	sets.midcast['Temper II'] = {main = 'Crocea Mors'}
	sets.midcast['Phalanx II'] = {main = 'Crocea Mors'}
	sets.midcast.Refresh = {ring1 = 'Chirich Ring +1'}
	sets.midcast['Stoneskin'] = {legs = 'Volte Hose'}
	sets.Self_Phalanx = {main = 'Crocea Mors', waist = 'Null Belt'}
	sets.Self_Phalanx.DW = {neck = "Combatant's Torque"}
	sets.Self_Refresh = {ring1 = 'Karieyh Ring'}
	sets.buff.ComposureOther = {feet = 'Volte Boots'}

	sets.idle = {ammo = 'Staunch Tathlum +1', head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
		legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
		ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
		back = 'Moonbeam Cape'}
	sets.idle.DT = set_combine(sets.idle, {head = 'Null Masque'})
	sets.idle.Sphere = set_combine(sets.idle, {main = "Terra's Staff"})
	sets.latent_refresh = {waist = 'Null Belt'}
	sets.latent_refresh_grip = {sub = 'Enki Strap'}
	sets.TPEat = {ear1 = 'Cessance Earring'}
	sets.buff.Sublimation = {back = 'Null Shawl'}
	sets.buff.DTSublimation = {back = 'Null Shawl', ring1 = 'Karieyh Ring'}

	sets.engaged = {head = 'Volte Cap', body = 'Volte Jupon', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', waist = 'Plat. Mog. Belt'}
	sets.engaged.Acc = set_combine(sets.engaged, {body = 'Adamantite Armor'})
	sets.engaged.Enspell = set_combine(sets.engaged, {legs = 'Volte Hose'})
	sets.engaged.Enspell2 = set_combine(sets.engaged, {feet = 'Volte Boots'})
	sets.element.enspell = {}
	sets.element.enspell.Fire = {hands = 'Volte Bracers'}
	sets.element.enspell.Lightning = {hands = 'Volte Bracers', body = 'Adamantite Armor'}
end
