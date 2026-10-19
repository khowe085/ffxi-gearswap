-- Jobby's dark knight gear file, loaded by the real data/DRK.lua for the tests of what that file does on top of Sel.
-- Each set that the job file looks for wears pieces that tell it apart from the others. The engaged sets name the
-- same slots, so whichever was on before, the one chosen shows whole.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.CastingMode:options('Normal')
	state.IdleMode:options('Normal', 'DT')
	state.PhysicalDefenseMode:options('PDT')
	state.Weapons:options('None', 'Ragnarok', 'Naegling')

	ws_buff_list = S{'Resolution'}
end

function init_gear_sets()
	sets.weapons.Ragnarok = {main = 'Ragnarok'}
	sets.weapons.Naegling = {main = 'Naegling'}

	sets.precast.FC = {neck = 'Fotia Gorget'}
	sets.midcast['Dark Magic'] = {head = 'Volte Cap'}
	sets.buff['Dark Seal'] = {hands = 'Volte Bracers'}
	sets.buff['Nether Void'] = {legs = 'Volte Hose'}
	sets.DrainWeapon = {main = 'Apocalypse', ring1 = 'Karieyh Ring'}
	sets.AbsorbWeapon = {main = 'Apocalypse', ring1 = 'Chirich Ring +1'}
	sets.DreadWeapon = {main = 'Apocalypse', ring1 = "Cornelia's Ring"}

	sets.precast.WS = {head = 'Volte Cap', neck = 'Fotia Gorget', ear1 = 'Moonshade Earring', ear2 = 'Brutal Earring'}
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {body = 'Volte Jupon'})
	sets.precast.WS['Resolution'] = set_combine(sets.precast.WS, {hands = 'Nyame Gauntlets'})
	sets.precast.WS['Resolution'].Acc = set_combine(sets.precast.WS['Resolution'], {body = 'Volte Jupon'})
	sets.precast.WS['Entropy'] = set_combine(sets.precast.WS, {feet = 'Volte Boots'})
	sets.precast.WS['Torcleaver'] = set_combine(sets.precast.WS, {ear1 = 'Lugra Earring'})
	sets.precast.WS['Torcleaver'].Acc = set_combine(sets.precast.WS['Torcleaver'], {body = 'Volte Jupon'})
	sets.precast.WS['Cross Reaper'] = set_combine(sets.precast.WS, {ear2 = 'Lugra Earring'})
	sets.precast.WS['Cross Reaper'].Acc = set_combine(sets.precast.WS['Cross Reaper'], {body = 'Volte Jupon'})
	sets.MaxTP = {ear1 = 'Lugra Earring'}
	sets.DayMaxTPWSEars = {ear1 = 'Cessance Earring'}
	sets.AccMaxTP = {ear1 = 'Lugra Earring', body = 'Adamantite Armor'}
	sets.AccDayMaxTPWSEars = {ear1 = 'Odnowa Earring +1', body = 'Adamantite Armor'}
	sets.DayWSEars = {ear1 = 'Cessance Earring'}
	sets.AccDayWSEars = {ear1 = 'Odnowa Earring +1'}

	sets.idle = {ammo = 'Staunch Tathlum +1', head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
		legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
		ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
		back = 'Moonbeam Cape'}
	sets.latent_refresh = {waist = 'Null Belt'}

	sets.engaged = {head = 'Volte Cap', body = 'Volte Jupon', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', waist = 'Plat. Mog. Belt', neck = 'Loricate Torque +1'}
	sets.engaged.DT = set_combine(sets.engaged, {head = 'Null Masque'})
	sets.buff.Souleater = {neck = "Combatant's Torque"}
	sets.defense.PDT = {head = 'Null Masque', waist = 'Null Belt'}
end
