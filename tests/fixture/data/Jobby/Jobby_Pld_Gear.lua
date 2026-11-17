-- Jobby's paladin gear file, loaded by the real data/PLD.lua for the tests of what that file does on top of Sel.
-- Each set that the job file looks for wears pieces that tell it apart from the others. The engaged sets name the
-- same slots, so whichever was on before, the one chosen shows whole.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.IdleMode:options('Normal', 'DT')
	state.PhysicalDefenseMode:options('PDT')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.ExtraDefenseMode:options('None', 'Aegis')
	state.Weapons:options('None', 'Ragnarok', 'Kheshig', 'Swords', 'Shield')
end

function init_gear_sets()
	sets.weapons.Ragnarok = {main = 'Ragnarok'}
	sets.weapons.Kheshig = {main = 'Kheshig Blade', sub = 'Aegis'}
	sets.weapons.Swords = {main = 'Naegling', sub = 'Kheshig Blade'}
	sets.weapons.Shield = {main = 'Naegling', sub = 'Aegis'}

	sets.precast.JA['Divine Emblem'] = {head = 'Null Masque'}
	sets.precast.JA.Majesty = {head = 'Volte Cap'}
	sets.precast.FC = {neck = 'Fotia Gorget'}
	sets.midcast.Flash = {hands = 'Volte Bracers'}

	sets.precast.WS = {head = 'Volte Cap', neck = 'Fotia Gorget', ear1 = 'Moonshade Earring', ear2 = 'Brutal Earring'}
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {body = 'Volte Jupon'})
	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {hands = 'Volte Bracers'})
	sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS['Savage Blade'], {body = 'Volte Jupon'})
	sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {ear1 = 'Lugra Earring'})
	sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS['Requiescat'], {body = 'Volte Jupon'})
	sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {ear2 = 'Lugra Earring'})
	sets.precast.WS['Chant du Cygne'].Acc = set_combine(sets.precast.WS['Chant du Cygne'], {body = 'Volte Jupon'})
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
	sets.latent_regen = {ring1 = 'Karieyh Ring'}

	sets.engaged = {head = 'Volte Cap', body = 'Volte Jupon', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets'}
	sets.engaged.DW = set_combine(sets.engaged, {hands = 'Volte Bracers'})
	sets.engaged.Aegis = set_combine(sets.engaged, {legs = 'Volte Hose'})
	sets.engaged.Kheshig = set_combine(sets.engaged, {})

	sets.defense.PDT = {neck = "Combatant's Torque"}
	sets.defense.PDT['Kheshig Blade'] = {neck = 'Fotia Gorget'}
	sets.defense.MDT = {neck = 'Loricate Torque +1'}
	sets.Aegis = {feet = 'Volte Boots'}
end
