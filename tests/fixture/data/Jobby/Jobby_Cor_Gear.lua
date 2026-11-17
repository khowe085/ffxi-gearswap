-- A small Sel gear file for the tests of data/COR.lua. Each bullet a job file picks by the action has a name of its
-- own; the sets wear pieces that tell them apart.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.RangedMode:options('Normal', 'Acc')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc', 'Proc')
	state.CastingMode:options('Normal', 'Fodder', 'Proc')
	state.IdleMode:options('Normal')
	state.HybridMode:options('Normal', 'DT')
	state.Weapons:options('None', 'Ranged')

	gear.RAbullet = 'Eminent Bullet'
	gear.WSbullet = 'Orichalc. Bullet'
	gear.MAbullet = 'Living Bullet'
	gear.QDbullet = 'Animikii Bullet'
	options.ammo_warning_limit = 15
end

function init_gear_sets()
	sets.weapons.Ranged = {range = 'Death Penalty', ammo = 'Eminent Bullet'}

	sets.idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring',
		ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1'}

	sets.engaged = {head = 'Volte Cap', body = 'Volte Jupon'}

	sets.precast.RA = {head = 'Volte Cap'}
	sets.precast.RA.Flurry = {head = 'Null Masque'}
	sets.precast.RA.Flurry2 = {head = 'Malignance Chapeau'}
	sets.precast.RA['Death Penalty'] = {hands = 'Volte Bracers'}
	sets.precast.RA['Death Penalty'].AM = {hands = 'Volte Bracers', legs = 'Volte Hose'}
	sets.midcast.RA = {body = 'Volte Jupon'}
	sets.midcast.RA.Acc = {body = 'Adamantite Armor'}
	sets.buff['Triple Shot'] = {feet = 'Volte Boots'}
	sets.buff['Triple Shot'].Acc = {feet = 'Plumb Boots'}
	sets.TrueShot = {neck = 'Weike Torque'}

	sets.precast.CorsairShot = {head = 'Null Masque', ear1 = 'Sortiarius Earring'}
	sets.precast.CorsairShot.Damage = {head = 'Null Masque', ear1 = 'Beatific Earring'}
	sets.precast.CorsairShot.Proc = {head = 'Null Masque', ear1 = 'Choleric Earring'}
	sets.precast.CorsairShot['Light Shot'] = {head = 'Null Masque', ear1 = 'Pensee Earring'}

	sets.precast.CorsairRoll = {range = 'Compensator', neck = 'Orunmila\'s Torque'}
	sets.precast.CorsairRoll["Fighter's Roll"] = {range = 'Compensator', neck = 'Weike Torque'}
	sets.precast.CorsairRoll.Recast = {back = 'Prodigious Mantle'}
	sets.precast.CorsairRoll.Weak = {waist = 'Wanion Belt'}
	sets.precast.LuzafRing = {ring2 = 'Luzaf\'s Ring'}
	sets.precast.FoldDoubleBust = {legs = 'Volte Hose'}

	sets.precast.WS = {head = 'Null Masque', ear1 = 'Moonshade Earring'}
	sets.precast.WS['Last Stand'] = {head = 'Null Masque', ear2 = 'Moonshade Earring'}
	sets.precast.WS['Leaden Salute'] = {head = 'Null Masque', ear1 = 'Moonshade Earring'}
	sets.precast.WS.Evisceration = {head = 'Null Masque', ear1 = 'Moonshade Earring'}
	sets.MaxTP = {ear1 = 'Sortiarius Earring', ear2 = 'Pensee Earring'}
	sets.AccMaxTP = {ear1 = 'Beatific Earring', ear2 = 'Pensee Earring'}
	sets.MagicalMaxTP = {ear1 = 'Choleric Earring', ear2 = 'Pensee Earring'}
	sets.MagicalAccMaxTP = {ear1 = 'Sortiarius Earring', ear2 = 'Choleric Earring'}
	sets.RangedMaxTP = {ear1 = 'Beatific Earring', ear2 = 'Choleric Earring'}
	sets.RangedAccMaxTP = {ear1 = 'Pensee Earring', ear2 = 'Sortiarius Earring'}
end
