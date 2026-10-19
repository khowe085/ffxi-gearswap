-- A small Sel gear file for the tests of data/BLU.lua. Each blue magic list's set wears its own ring and ear, so the
-- set a spell took shows from what is worn; the other sets wear pieces that tell them apart.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.CastingMode:options('Normal', 'Resistant', 'Proc')
	state.IdleMode:options('Normal', 'DT')
	state.Weapons:options('None', 'Naegling')
end

function init_gear_sets()
	sets.weapons.Naegling = {main = 'Naegling'}

	sets.idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring',
		ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1'}
	sets.idle.DT = set_combine(sets.idle, {body = 'Malignance Tabard'})
	sets.latent_refresh = {waist = 'Wanion Belt'}
	sets.Learning = {neck = 'Weike Torque'}

	sets.engaged = {head = 'Volte Cap', body = 'Volte Jupon'}
	sets.engaged.Acc = set_combine(sets.engaged, {body = 'Adamantite Armor'})

	sets.precast.FC = {head = 'Volte Cap'}
	sets.precast.FC['Blue Magic'] = set_combine(sets.precast.FC, {legs = 'Volte Hose'})
	sets.precast.FC.Proc = set_combine(sets.precast.FC, {feet = 'Volte Boots'})

	sets.precast.WS['Chant du Cygne'] = {head = 'Null Masque', ear1 = 'Moonshade Earring'}
	sets.precast.WS['Savage Blade'] = {head = 'Null Masque', ear2 = 'Moonshade Earring'}
	sets.precast.WS.Requiescat = {head = 'Null Masque'}
	sets.MaxTP = {ear1 = 'Sortiarius Earring', ear2 = 'Pensee Earring'}
	sets.AccMaxTP = {ear1 = 'Beatific Earring', ear2 = 'Pensee Earring'}

	sets.midcast['Blue Magic'] = {neck = 'Orunmila\'s Torque'}
	sets.midcast['Blue Magic'].Physical = {ring1 = 'Lunette Ring', ear1 = 'Sortiarius Earring'}
	sets.midcast['Blue Magic'].PhysicalAcc = {ring1 = 'Lunette Ring', ear1 = 'Beatific Earring'}
	sets.midcast['Blue Magic'].PhysicalStr = {ring1 = 'Lunette Ring', ear1 = 'Choleric Earring'}
	sets.midcast['Blue Magic'].PhysicalDex = {ring1 = 'Pernicious Ring', ear1 = 'Sortiarius Earring'}
	sets.midcast['Blue Magic'].PhysicalVit = {ring1 = 'Pernicious Ring', ear1 = 'Beatific Earring'}
	sets.midcast['Blue Magic'].PhysicalAgi = {ring1 = 'Pernicious Ring', ear1 = 'Choleric Earring'}
	sets.midcast['Blue Magic'].PhysicalInt = {ring1 = 'Gelatinous Ring', ear1 = 'Sortiarius Earring'}
	sets.midcast['Blue Magic'].PhysicalMnd = {ring1 = 'Gelatinous Ring', ear1 = 'Beatific Earring'}
	sets.midcast['Blue Magic'].PhysicalChr = {ring1 = 'Gelatinous Ring', ear1 = 'Choleric Earring'}
	sets.midcast['Blue Magic'].PhysicalHP = {ring1 = 'Cacoethic Ring', ear1 = 'Sortiarius Earring'}
	sets.midcast['Blue Magic'].Magical = {ring1 = 'Cacoethic Ring', ear1 = 'Beatific Earring'}
	sets.midcast['Blue Magic'].Magical.Resistant = {ring1 = 'Cacoethic Ring', ear1 = 'Choleric Earring'}
	sets.midcast['Blue Magic'].MagicalMnd = {ring1 = 'Petrov Ring', ear1 = 'Sortiarius Earring'}
	sets.midcast['Blue Magic'].MagicalChr = {ring1 = 'Petrov Ring', ear1 = 'Beatific Earring'}
	sets.midcast['Blue Magic'].MagicalVit = {ring1 = 'Petrov Ring', ear1 = 'Choleric Earring'}
	sets.midcast['Blue Magic'].MagicalDex = {ring1 = 'Fortified Ring', ear1 = 'Sortiarius Earring'}
	sets.midcast['Blue Magic'].MagicalAgi = {ring1 = 'Fortified Ring', ear1 = 'Beatific Earring'}
	sets.midcast['Blue Magic'].MagicAccuracy = {ring1 = 'Fortified Ring', ear1 = 'Choleric Earring'}
	sets.midcast['Blue Magic'].Breath = {ring1 = 'Vertigo Ring', ear1 = 'Sortiarius Earring'}
	sets.midcast['Blue Magic'].Stun = {ring1 = 'Vertigo Ring', ear1 = 'Beatific Earring'}
	sets.midcast['Blue Magic'].Healing = {ring1 = 'Vertigo Ring', ear1 = 'Choleric Earring'}
	sets.midcast['Blue Magic'].SkillBasedBuff = {ring1 = 'Dhanurveda Ring', ear1 = 'Sortiarius Earring'}
	sets.midcast['Blue Magic'].Buff = {ring1 = 'Dhanurveda Ring', ear1 = 'Beatific Earring'}
	sets.midcast['Blue Magic'].UnlockedHealing = {hands = 'Volte Bracers'}
	sets.midcast['Blue Magic'].UnlockedAoEHealing = {waist = 'Wanion Belt'}
	sets.midcast['Blue Magic'].AoEHealing = {back = 'Prodigious Mantle'}
	sets.Self_Healing = {body = 'Volte Jupon'}

	sets.buff['Chain Affinity'] = {head = 'Null Masque'}
	sets.buff['Burst Affinity'] = {body = 'Adamantite Armor'}
	sets.buff['Azure Lore'] = {feet = 'Plumb Boots'}
	sets.buff.Diffusion = {back = 'Prodigious Mantle'}
	sets.HPDown = {neck = 'Loricate Torque'}
end
