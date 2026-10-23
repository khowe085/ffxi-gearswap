-- A small Sel gear file for the tests of data/RNG.lua. Each set wears pieces that tell it apart from the others, from
-- the gear the tests give Jobby, so that what is worn shows which sets were laid over which.

function user_job_setup()
	state.OffenseMode:options('Normal')
	state.RangedMode:options('Normal', 'Acc')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.IdleMode:options('Normal')
	state.Weapons:options('None', 'Bow', 'Gun', 'Crossbow')

	DefaultAmmo.Gun.MagicAcc = 'Eminent Bullet'
end

function init_gear_sets()
	sets.weapons.Bow = {range = "Judge's Bow"}
	sets.weapons.Gun = {range = 'Armageddon'}
	sets.weapons.Crossbow = {range = 'Gastraphetes'}

	sets.idle = {main = "Judge's Sword", range = "Judge's Bow", head = 'Nyame Helm',
		body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard', feet = 'Nyame Sollerets',
		neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring',
		ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1', back = 'Mecisto. Mantle'}

	sets.precast.RA = {head = "Bendis's Hairpin"}
	sets.precast.RA.Flurry = {hands = 'Sapphire Gauntlets'}
	sets.precast.RA.Flurry2 = {hands = 'Jadeite Gloves'}
	sets.precast.RA.Gun = {head = "Theia's Hairpin"}
	sets.precast.RA.Gun.Flurry = {hands = 'Diamond Kote'}
	sets.precast.RA.Gun.Flurry2 = {hands = 'Diamond Kote', legs = 'Jadeite Chausses'}

	sets.midcast.RA = {body = 'Sapphire Platemail', hands = 'Volte Bracers', legs = 'Volte Hose', neck = 'Fotia Gorget',
		back = 'Moonbeam Cape'}
	sets.midcast.RA.Acc = {body = 'Jadeite Cuirie'}
	sets.midcast.RA.AM = {body = 'Diamond Haramaki'}
	sets.TrueShot = {feet = 'Sapphire Leggings'}
	sets.buff['Velocity Shot'] = {back = 'Aptitude Mantle'}
	sets.buff.Barrage = {legs = 'Diamond Hiza.'}
	sets.buff.Camouflage = {neck = "Orunmila's Torque"}
	sets.buff.Camouflage.Acc = {neck = 'Phrenic Torque'}
	sets.buff['Double Shot'] = {hands = 'Diamond Kote'}
	sets.buff['Double Shot'].Acc = {hands = 'Jadeite Gloves'}
	sets.buff['Double Shot'].AM = {hands = 'Sapphire Gauntlets'}
	sets.buff['Double Shot'].Gun = {legs = 'Jadeite Chausses'}
	sets.buff['Double Shot'].Gun.Acc = {legs = 'Sapphire Trousers'}
	sets.buff['Double Shot'].Gun.Acc.AM = {legs = 'Jadeite Chausses', hands = 'Sapphire Gauntlets'}

	sets.precast.WS = {neck = "Orunmila's Torque"}
	sets.precast.WS['Last Stand'] = {neck = "Orunmila's Torque", ear1 = 'Moonshade Earring', ear2 = 'Etiolation Earring'}
	sets.precast.WS['Wildfire'] = {neck = "Orunmila's Torque", ear1 = 'Moonshade Earring', ear2 = 'Etiolation Earring'}
	sets.precast.WS['Savage Blade'] = {neck = "Orunmila's Torque", ear1 = 'Moonshade Earring', ear2 = 'Etiolation Earring'}
	sets.RangedMaxTP = {ear1 = 'Ishvara Earring'}
	sets.RangedAccMaxTP = {ear1 = 'Brutal Earring'}
	sets.MagicalMaxTP = {ear1 = "Hecate's Earring"}
	sets.MagicalAccMaxTP = {ear1 = 'Pixie Earring'}
	sets.MaxTP = {ear1 = 'Beastly Earring'}
	sets.AccMaxTP = {ear1 = 'Stealth Earring'}
end
