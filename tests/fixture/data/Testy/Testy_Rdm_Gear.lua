-- A small Sel gear file for the tests of Sel's set selection, loaded by the real data/RDM.lua. Sets a test tells apart
-- by what is worn wear pieces, from the gear the tests give Testy, that the others don't; sets no test sets against
-- each other may wear the same, as sets.defense.PDT and sets.precast.WS.Acc do. The sets of one kind (engaged, weapon
-- skill) each name the same slots, so whichever was on before, the one chosen shows whole.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc', 'Att')
	state.HybridMode:options('Normal', 'DT', 'Tank')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.CastingMode:options('Normal', 'Resistant')
	state.IdleMode:options('Normal', 'DT', 'Refresh', 'Regen')
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
	sets.precast.FC.Refresh = set_combine(sets.precast.FC, {body = 'Lethargy Sayon +3'})
	sets.precast.FC['Refresh II'] = set_combine(sets.precast.FC.Refresh, {head = 'Kaykaus Mitra +1'})
	sets.precast.FC.Cure = set_combine(sets.precast.FC, {body = 'Malignance Tabard'})
	sets.precast.FC.DT = {head = 'Malignance Chapeau'}

	sets.precast.JA.Composure = {body = 'Lethargy Sayon +3'}

	sets.precast.WS = {head = 'Kaykaus Mitra +1', body = 'Atrophy Tabard +3'}
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {body = 'Malignance Tabard'})
	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {head = 'Malignance Chapeau'})
	sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS['Savage Blade'], {body = 'Malignance Tabard'})

	sets.midcast.FastRecast = {head = 'Malignance Chapeau'}
	sets.midcast.Cure = {main = "Bunzi's Rod", head = 'Kaykaus Mitra +1'}
	sets.midcast['Cure II'] = {body = 'Atrophy Tabard +3'}
	sets.midcast['Enhancing Magic'] = {body = 'Lethargy Sayon +3'}
	sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {body = 'Atrophy Tabard +3'})
	sets.midcast['Enfeebling Magic'] = {body = 'Malignance Tabard'}
	sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {head = 'Kaykaus Mitra +1'})

	sets.idle = {main = 'Daybreak', sub = 'Ammurapi Shield', ammo = 'Staunch Tathlum +1', head = 'Nyame Helm',
		body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard', feet = 'Nyame Sollerets',
		neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring',
		ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1', back = "Sucellos's Cape"}
	sets.idle.DT = set_combine(sets.idle, {head = 'Malignance Chapeau', body = 'Malignance Tabard'})
	sets.idle.Refresh = set_combine(sets.idle, {head = 'Kaykaus Mitra +1'})

	sets.defense.PDT = {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard'}
	sets.defense.MDT = {body = 'Lethargy Sayon +3'}
	sets.defense.MEVA = {body = 'Malignance Tabard'}
	sets.Kiting = {body = 'Atrophy Tabard +3'}

	sets.engaged = {head = "Bunzi's Hat", body = 'Lethargy Sayon +3'}
	sets.engaged.Acc = set_combine(sets.engaged, {body = 'Malignance Tabard'})
	sets.engaged.DT = set_combine(sets.engaged, {head = 'Malignance Chapeau'})
	sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, {head = 'Malignance Chapeau'})
	sets.engaged.Tank = set_combine(sets.engaged, {head = 'Kaykaus Mitra +1'})
	sets.engaged.Crocea = {head = 'Kaykaus Mitra +1', body = 'Atrophy Tabard +3'}
end

function user_job_filter_precast(spell, spellMap, eventArgs)
	if spell.english == 'Stoneskin' then
		eventArgs.cancel = true
	end
end

function user_job_precast(spell, spellMap, eventArgs)
	if spell.english == 'Cure IV' then
		equip({main = 'Crocea Mors', head = 'Malignance Chapeau'})
	end
end

function user_job_post_precast(spell, spellMap, eventArgs)
	if spell.english == 'Cure IV' then
		equip({body = 'Lethargy Sayon +3'})
	end
end

function user_job_post_midcast(spell, spellMap, eventArgs)
	if spell.english == 'Cure IV' then
		equip({head = "Bunzi's Hat"})
	end
end

function user_job_customize_melee_set(meleeSet)
	if buffactive.Haste then
		meleeSet = set_combine(meleeSet, {head = 'Kaykaus Mitra +1'})
	end
	return meleeSet
end
