-- A small Sel gear file for the tests of Sel's set selection, loaded by the real data/RDM.lua. Each set wears pieces
-- that tell it apart from the others, from the gear the tests give Testy.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.CastingMode:options('Normal', 'Resistant')
	state.IdleMode:options('Normal', 'DT')
	state.PhysicalDefenseMode:options('PDT')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.Weapons:options('None', 'Naegling', 'Crocea')
end

function init_gear_sets()
	sets.weapons.Naegling = {main = 'Naegling', sub = 'Ammurapi Shield'}
	sets.weapons.Crocea = {main = 'Crocea Mors', sub = 'Ammurapi Shield'}

	sets.precast.FC = {head = "Bunzi's Hat", ring1 = 'Kishar Ring'}
	sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {body = 'Atrophy Tabard +3'})
	sets.precast.FC.Refresh = set_combine(sets.precast.FC, {ear2 = 'Loquac. Earring'})

	sets.precast.JA.Composure = {body = 'Lethargy Sayon +3'}

	sets.precast.WS = {head = 'Nyame Helm', body = 'Nyame Mail', neck = 'Loricate Torque +1'}
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {body = 'Malignance Tabard'})
	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {ring1 = 'Stikini Ring +1'})
	sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS['Savage Blade'], {body = 'Malignance Tabard'})

	sets.midcast.FastRecast = {head = 'Malignance Chapeau'}
	sets.midcast.Cure = {main = "Bunzi's Rod", head = 'Kaykaus Mitra +1'}
	sets.midcast['Enhancing Magic'] = {body = 'Lethargy Sayon +3'}
	sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {body = 'Atrophy Tabard +3'})
	sets.midcast['Enfeebling Magic'] = {head = 'Malignance Chapeau', body = 'Malignance Tabard'}
	sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {ring1 = 'Kishar Ring'})

	sets.idle = {main = 'Daybreak', sub = 'Ammurapi Shield', ammo = 'Staunch Tathlum +1', head = 'Nyame Helm',
		body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard', feet = 'Nyame Sollerets',
		neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring',
		ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1', back = "Sucellos's Cape"}
	sets.idle.DT = set_combine(sets.idle, {head = 'Malignance Chapeau', body = 'Malignance Tabard'})

	sets.defense.PDT = {head = 'Malignance Chapeau', ring1 = 'Defending Ring'}
	sets.defense.MDT = {body = 'Malignance Tabard'}
	sets.defense.MEVA = {body = 'Malignance Tabard'}
	sets.Kiting = {legs = 'Nyame Flanchard'}

	sets.engaged = {head = 'Nyame Helm', body = 'Lethargy Sayon +3', ring1 = 'Stikini Ring +1'}
	sets.engaged.Acc = set_combine(sets.engaged, {body = 'Malignance Tabard'})
	sets.engaged.DT = set_combine(sets.engaged, {head = 'Malignance Chapeau'})
	sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, {head = 'Malignance Chapeau'})
end
