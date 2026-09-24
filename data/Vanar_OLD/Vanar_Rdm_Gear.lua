local user = {}

user.options = {}
user.options.default = {}

user.aug = {}

user.sets = {}
user.sets.buffs = {}
user.sets.defense = {}
user.sets.weapons = {}
user.sets.precast = {}
user.sets.midcast = {}
user.sets.midcast.BlueMagic = {}
user.sets.capes = {}
user.options.trusts = { "Yoran-Oran (UC)", "Koru-Moru", "Qultada", "Joachim" }

-- Select default macro book on initial load or subjob change.
-- Default macro set/book
function select_default_macro_book()
	local macro_pages = {
		SCH = 2,
		BLM = 3,
		DRK = 4,
		DNC = 5,
		NIN = 6,
	}

	local page = macro_pages[player.sub_job] or 1
	set_macro_page(page, 1)

	windower.send_command('gs validate')
	windower.send_command('lua r xivcrossbar')
end

function user_job_keybindings()

end

function user_job_lockstyle()
	local cmd

	if player.sub_job == 'SCH' then
		if state.Buff['Light Arts'] or state.Buff['Addendum: White'] then
			cmd = '/lockstyleset 022'
		elseif state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
			cmd = '/lockstyleset 0023'
		else
			cmd = '/lockstyleset 021'
		end
	elseif player.sub_job == 'NIN' or player.sub_job == 'DNC' then
		cmd = '/lockstyleset 024'
	end

	if cmd then
		windower.send_command('du blinking self always off')
		windower.chat.input(cmd)
		windower.send_command('wait 5;du blinking self always on')
	end
end

function define_user_gearsets()
	-- Default options
	user.options.default.Weapon = 'Naegling'
	user.options.default.DualWeapon = 'DualWeapons'

	-- User sets
	local sets = user.sets

	-- Augmented gear
	local aug = user.aug

	aug.CureClub = { name = "Nibiru Cudgel", augments = { 'MND+10', 'Mag. Acc.+15', '"Cure" potency +15%', } }
	aug.DmgClubOffhand = "Kaja Rod"
	aug.CarmineCuisses = { name = "Carmine Cuisses +1", augments = { 'Accuracy+20', 'Attack+12', '"Dual Wield"+6' } }
	aug.RecastGloves = { name = "Telchine Gloves", augments = { 'Haste +3' } }
	aug.EnfeeblingLegs = { name = "Chironic Hose", augments = { 'Mag. Acc.+28', 'MND+12' } }
	aug.ElementalHead = { name = "Merlinic Hood", augments = { 'Mag. Acc.+20 "Mag.Atk.Bns."+20', '"Occult Acumen"+10', 'Mag. Acc.+15', '"Mag.Atk.Bns."+5' } }
	aug.ElementalLegs = { name = "Merlinic Shalwar", augments = { 'Mag. Acc.+25 "Mag.Atk.Bns."+25', 'Magic burst dmg.+1%', 'INT+7', 'Mag. Acc.+11', '"Mag.Atk.Bns."+13' } }
	aug.DarkRing1 = { name = "Dark Ring", augments = { 'Phys. dmg. taken -3%', 'Spell interruption rate down -3%' } }
	aug.DarkRing2 = "Warden's Ring"
	aug.RefreshWeapon = { name = "Colada", augments = { '"Refresh"+2', 'Mag. Acc.+11', '"Mag.Atk.Bns."+12', 'DMG:+1', } }
	aug.Daybreak = {
		--main="Daybreak",
		--sub="Ammurapi Shield"
	}
	aug.Crepuscular = {
		--head=empty,
		--body="Crepuscular Cloak"
	}

	-- JSE Ambuscade capes
	local capes = sets.capes
	capes.MND = {
		name = "Sucellos's Cape",
		augments = { 'MND+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', 'Haste+10' }
	}

	capes.INT = {
		name = "Sucellos's Cape",
		augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', '"Mag.Atk.Bns."+10' }
	}

	capes.GhostFyre = {
		name = "Ghostfyre Cape",
		augments = { 'Enfb.mag. skill +8', 'Enha.mag. skill +5', 'Mag. Acc.+8', 'Enh. Mag. eff. dur. +20' }
	}

	capes.Melee = {
		name = "Sucellos's Cape",
		augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Phys. dmg. taken-10%', }
	}

	capes.WeponSkill = {
		name = "Sucellos's Cape",
		augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%', }
	}

	-- Weapons
	sets.weapons.SavageBlade = { main = "Naegling", sub = "Ammurapi Shield", range = empty }
	sets.weapons.SanguineBlade = { main = "Naegling", sub = "Ammurapi Shield", range = empty }
	sets.weapons.Club = { main = "Kaja Rod", sub = "Ammurapi Shield", range = empty }
	sets.weapons.Dagger = { main = "Kaja Knife", sub = "Ammurapi Shield", range = empty }
	sets.weapons.DualWeapons = { main = "Naegling", sub = "Demers. Degen +1", range = empty }
	sets.weapons.DualWeaponsAcc = { main = "Naegling", sub = "Demers. Degen +1", range = empty }
	sets.weapons.DualSanguineBlade = { main = "Naegling", sub = "Demers. Degen +1", range = empty }
	sets.weapons.DualProcSword = { main = "Demers. Degen +1", sub = "Kaja Knife", range = empty }
	sets.weapons.DualProcClub = { main = "Kaja Rod", sub = "Demers. Degen +1", range = empty }
	sets.weapons.ProcSword = { main = "Demers. Degen +1", sub = "Ammurapi Shield", range = empty }
	sets.weapons.ProcDagger = { main = "Kaja Knife", sub = "Ammurapi Shield", range = empty }
	sets.weapons.DualProcDagger = { main = "Kaja Knife", sub = "Demers. Degen +1", range = empty }
	sets.weapons.EnspellOnly = { main = "Demers. Degen +1", sub = "Ammurapi Shield" }
	sets.weapons.DualEnspellOnly = { main = "Kaja Knife", sub = "Demers. Degen +1" }
	sets.weapons.DualClub = { main = "Kaja Rod", sub = aug.DmgClubOffhand, range = empty }
	sets.weapons.DualClubAcc = { main = "Kaja Rod", sub = aug.DmgClubOffhand, range = empty }

	--Temporary Weapon Sets for Dynamis RP
	user.sets.weapons.DualSanguineBladeSavageBlade = { main = "Naegling", sub = "Demers. Degen +1" }
	sets.weapons.DualDaggerSanguineBlade = { main = "Kaja Knife", sub = "Naegling" }

	-- Precast
	local precast = sets.precast

	-- Fast Cast
	precast.FastCast = {
		main = aug.RefreshWeapon,
		sub = "Archduke's Shield",
		ammo = "Impatiens",
		head = "Atro. Chapeau +1",
		left_ear = "Estq. Earring",
		right_ear = "Loquacious Earring",
		body = "Viti. Tabard +3",
		ring1 = "Weather. Ring",
		ring2 = "Prolix Ring",
		back = "Perimede Cape",
		waist = "Witful Belt",
		feet = "Chelona Boots",
	}

	precast.FastCast.DT = set_combine(precast.FastCast, {
		-- Damage Taken
	})

	precast.Impact = set_combine(precast.FastCast, aug.Crepuscular)
	precast.Dispelga = set_combine(precast.FastCast, aug.Daybreak)

	-- Midcast
	local midcast = sets.midcast

	midcast.FastRecast = set_combine(precast.FastCast, {
		ammo = "Hasty Pinion",
		hands = aug.RecastGloves,
		legs = "Atrophy Tights +1",
		back = capes.MND
	})

	-- Healing Magic

	midcast.Cure = set_combine(midcast.FastRecast, {
		main = aug.CureClub,
		sub = "Archduke's Shield",
		ear1 = "Estq. Earring",
		ear2 = "Mendi. Earring",
		neck = "Nodens Gorget",
		ring2 = "Naji's loop",
		hands = aug.RecastGloves,
		back = capes.GhostFyre
	})

	midcast.Cure.LightWeatherCure = set_combine(midcast.Cure, {
	})

	midcast.Cure.LightDayCure = set_combine(midcast.Cure, {
	})
	midcast.Cure.DT = set_combine(midcast.Cure, {
	})
	midcast.Cure.Cursna = set_combine(midcast.Cure, {
	})
	midcast.Cure.StatusRemoval = set_combine(midcast.FastRecast, {
	})

	-- Enhancing Magic

	midcast.EnhancingSkill = {
		neck = "Enhancing Torque",
		ear1 = "Andoaa Earring",
		ear2 = "Augmenting Earring",
		body = "Viti. Tabard +3",
		hands = "Viti. Gloves +3",
		ring1 = "Stikini Ring",
		ring2 = "Stikini Ring",
		back = "Perimede Cape",
		waist = "Olympus Sash",
		legs = aug.CarmineCuisses,
		feet = "Lethargy Houseaux +2"
	}

	-- Optimize for duration / recast
	midcast.EnhancingMagic = set_combine(midcast.FastRecast, {
		neck = "Dls. Torque +1",
		ear1 = "Andoaa Earring",
		ear2 = "Augmenting Earring",
		hands = "Atrophy Gloves +3",
		feet = "Lethargy Houseaux +2",
		back = capes.MND
	})

	-- Uncapped, based on skill at time of cast
	midcast.Temper = midcast.EnhancingSkill

	midcast.Enspell = midcast.EnhancingSkill

	-- Capped, focus on duration / effect / recast
	midcast.Aquaveil = {
		-- head="Amalric Coif +1",
		-- waist="Emphatikos Rope",
		-- legs="Shedir Seraweels",
		-- hands="Regal Cuffs"
	}

	midcast.BarElement = {
		--legs="Shedir Seraweels"
	}

	midcast.BarStatus = {
		--neck="Sroda Necklace"
	}

	midcast.BoostStat = {
		hands = "Viti. Gloves +3"
	}

	midcast.Refresh = {
		--head="Amalric Coif +1",
		body = "Atrophy Tabard +2",
	}

	midcast.Stoneskin = {
		neck = "Nodens Gorget",
		waist = "Siegel Sash",
		legs = "Doyen Pants"
		--ring2="Earthcry Earring"
	}

	midcast.Protect = {
		--ring2="Sheltered Ring"
	}

	midcast.Shell = {
		--ring2="Sheltered Ring"
	}

	midcast.Regen = {
		--main="Bolelabunga",
		--sub="Ammurapi Shield"
	}

	-- Enfeebling Magic

	midcast.EnfeeblingMagicSkill = {
		main = "Kaja Rod",
		sub = "Ammurapi Shield",
		head = "Viti. Chapeau +4",
		neck = "Dls. Torque +1",
		body = "Atrophy Tabard +2",
		legs = aug.EnfeeblingLegs,
		feet = "Vitiation Boots +4",
		hands = "Leth. Ganth. +2",
		left_ring = "Stikini Ring",
		right_ring = "Stikini Ring",
		waist = "Rumination Sash",
		back = capes.GhostFyre
	}

	-- General
	midcast.EnfeeblingMagic = set_combine(midcast.EnfeeblingMagicSkill, {
		ammo = "Pemphredo Tathlum",
		ear1 = "Lifestorm Earring",
		ear2 = "Psystorm Earring",
	})

	midcast.EnfeeblingMagic.Resistant = set_combine(midcast.EnfeeblingMagic, {
		body = "Jhakri Robe +2",
		back = capes.MND,
	})

	midcast.EnfeeblingMagic.DW = {
		--main="Bunzi's Rod",
		--sub="Maxentius"
	}

	-- Sleep / Bind / Break. Skill (Duration) > INT (Accuracy)
	midcast.EnfeeblingMagic.SleepBindBreak = set_combine(midcast.EnfeeblingMagic, {
		back = capes.INT
	})

	midcast.EnfeeblingMagic.SleepBindBreak.Resistant = set_combine(midcast.EnfeeblingMagic, {
		back = capes.INT
	})

	midcast.EnfeeblingMagic.SleepBindBreak.DW = {
		--main="Bunzi's Rod",
		--sub="Daybreak"
	}

	-- Dispel. Skill (Accuracy) > INT (Accuracy)
	midcast.EnfeeblingMagic.Dispel = set_combine(midcast.EnfeeblingMagic, {
		back = capes.INT
	})

	midcast.EnfeeblingMagic.Dispel.DW = {
		--main="Bunzi's Rod",
		--sub="Daybreak"
	}

	midcast.EnfeeblingMagic.Dispelga = set_combine(midcast.EnfeeblingMagic.Dispel, aug.Daybreak)
	midcast.EnfeeblingMagic.Dispelga.DW = set_combine(aug.Daybreak, {
		--sub="Bunzi's Rod"
	})

	-- Frazzle / Distract. Skill (Potentcy) > MND (Potentcy) > Effect (Potentcy)
	midcast.EnfeeblingMagic.FrazzleDistract = set_combine(midcast.EnfeeblingMagic, {
		back = capes.MND
	})

	midcast.EnfeeblingMagic.FrazzleDistract.Resistant = set_combine(midcast.EnfeeblingMagic, {
		back = capes.MND
	})

	midcast.EnfeeblingMagic.FrazzleDistract.DW = {
		--main="Bunzi's Rod",
		--sub="Daybreak"
	}

	-- Addle / Paralyze / Slow. Skill (Duration) > MND (Potentcy) > Effect (Potency)
	midcast.EnfeeblingMagic.AddleParalyzeSlow = set_combine(midcast.EnfeeblingMagic, {
		back = capes.MND
	})

	midcast.EnfeeblingMagic.AddleParalyzeSlow.Resistant = set_combine(midcast.EnfeeblingMagic, {
		back = capes.MND
	})

	midcast.EnfeeblingMagic.AddleParalyzeSlow.DW = {
		--main="Bunzi's Rod",
		--sub="Daybreak"
	}

	-- Gravity. Skill (Duration) > INT (Accuracy) > Effect (Potency)
	midcast.EnfeeblingMagic.GravityPoisonBlind = set_combine(midcast.EnfeeblingMagic, {
		back = capes.INT
	})

	midcast.EnfeeblingMagic.GravityPoisonBlind.Resistant = set_combine(midcast.EnfeeblingMagic, {
		back = capes.INT
	})

	midcast.EnfeeblingMagic.GravityPoisonBlind.DW = {
		--main="Bunzi's Rod",
		--sub="Maxentius"
	}

	-- Silence. Skill (Duration) > MND (Accuracy)
	midcast.EnfeeblingMagic.Silence = set_combine(midcast.EnfeeblingMagic, {
		back = capes.MND
	})

	midcast.EnfeeblingMagic.Silence.Resistant = set_combine(midcast.EnfeeblingMagic, {
		back = capes.MND
	})

	midcast.EnfeeblingMagic.Silence.DW = {
		--main="Bunzi's Rod",
		--sub="Daybreak"
	}

	-- Elemental Magic

	midcast.ElemetalMagic = {
		main = "Kaja Rod",
		sub = "Ammurapi Shield",
		ammo = "Pemphredo Tathlum",
		head = "Lethargy Chappel +2",
		neck = "Sanctity Necklace",
		ear1 = "Choleric Earring",
		ear2 = "Friomisi Earring",
		body = "Lethargy Sayon +3",
		hands = "Leth. Ganth. +2",
		ring1 = "Stikini Ring",
		ring2 = "Stikini Ring",
		back = capes.INT,
		waist = "Eschan Stone",
		legs = "Lethargy Fuseau +2",
		feet = "Leth. Houseaux +2"
	}

	midcast.ElemetalMagic.DT = set_combine(midcast.ElemetalMagic, {
	})

	midcast.ElemetalMagic.Resistant = set_combine(midcast.ElemetalMagic, {
	})

	midcast.ElemetalMagic.Proc = set_combine(midcast.ElemetalMagic, {
	})

	midcast.ElemetalMagic.HighTierNuke = set_combine(midcast.ElemetalMagic, {
	})

	midcast.ElemetalMagic.HighTierNuke.Resistant = set_combine(midcast.ElemetalMagic, {
	})

	midcast.ElemetalMagic.DW = {
		--main="Bunzi's Rod",
		--sub="Daybreak"
	}

	midcast.ElemetalMagic.Impact = set_combine(midcast.ElemetalMagic, aug.Crepuscular)

	-- Dark Magic

	midcast.DarkMagic = set_combine(midcast.ElemetalMagic.Resistant, {
		neck = "Aesir Torque",
		waist = "Casso Sash",
	})

	midcast.DarkMagic.DrainAspir = set_combine(midcast.DarkMagic, {
	})

	midcast.DarkMagic.AbsorbTP = set_combine(midcast.DarkMagic, {
	})

	midcast.DarkMagic.AbsorbTP.Resistant = set_combine(midcast.DarkMagic, {
	})

	midcast.DarkMagic.Stun = set_combine(midcast.DarkMagic, {
	})

	midcast.DarkMagic.Stun.Resistant = set_combine(midcast.DarkMagic, {
	})

	midcast.DarkMagic.Stun.DW = {
		--main="Bunzi's Rod",
		--sub="Maxentius"
	}

	-- Other

	local buffs = sets.buffs

	precast.Chainspell = { body = "Viti. Tabard +3" }

	-- Active buffs
	buffs.Saboteur = { hands = "Leth. Ganth. +2" }
	buffs.ComposureOther = {
		head = "Leth. Chappel +2",
		body = "Lethargy Sayon +3",
		hands = "Leth. Ganth. +2", --hands="Atrophy Gloves +3"
		legs = "Leth. Fuseau +2",
		feet = "Leth. Houseaux +2"
	}

	buffs.Sublimation = {
		--waist="Embla Sash"
	}
	buffs.DTSublimation = {
		--waist="Embla Sash"
	}

	sets.CureReceived = {
		--neck="Phalaina Locket",
		--ring2="Kunaji Ring",
		--waist="Gishdubar Sash"
	}

	sets.SelfHealing = {
		--neck="Phalaina Locket",
		--ring2="Kunaji Ring",
		--waist="Gishdubar Sash"
	}

	sets.SelfRefresh = {
		--waist="Gishdubar Sash"
	}

	sets.SelfPhalanx = {
		--ammo="Staunch Tathlum +1",
	}

	sets.SelfPhalanx.DW = {
		--main="Bunzi's Rod",
		--sub="Maxentius"
	}

	-- Idle
	sets.idle = {
		main = aug.RefreshWeapon,
		sub = "Archduke's Shield",
		ammo = "Impatiens",
		head = "Viti. Chapeau +4",
		neck = "Sibyl Scarf",
		ear1 = "Moonshade Earring",
		ear2 = "Etiolation Earring",
		body = "Lethargy Sayon +3",
		hands = "Serpentes Cuffs",
		ring1 = aug.DarkRing1,
		ring2 = aug.DarkRing2,
		back = capes.Melee,
		waist = "Flume Belt",
		legs = "Nares Trews",
		feet = "Serpentes Sabots"
	}

	sets.idle.PDT = set_combine(sets.idle, {
	})
	sets.idle.MDT = set_combine(sets.idle, {
	})
	sets.idle.MEVA = set_combine(sets.idle, {
	})
	sets.idle.Aminon = {}
	-- sets.idle.Aminon = set_combine(sets.idle, {
	-- })

	-- Defense sets
	sets.defense.PDT = set_combine(sets.idle, {
	})
	sets.defense.MDT = set_combine(sets.idle, {
	})
	sets.defense.MEVA = set_combine(sets.idle, {
	})

	sets.TreasureHunter = {

	}

	sets.resting = set_combine(sets.idle, {
		main = "Chatoyant Staff",
		feet = "Chelona Boots"
	})

	sets.Kiting = {
		legs = aug.CarmineCuisses
	}

	sets.latent_refresh = {
		waist = "Fucho-no-obi"
	}

	sets.latent_refresh_grip = {
		--sub="Oneiros Grip"
		back = capes.GhostFyre
	}

	-- Melee

	-- DNC
	precast.Steps = {
		-- Accuracy
	}

	precast.Waltz = {
		-- CHR and VIT
	}

	precast.HealingWaltz = {
		-- Don't need any special gear for Healing Waltz.
	}

	precast.ViolentFlourish = {
		-- ACC / MACC
	}

	-- Weaponskills
	precast.Weaponskill = {
		ammo = "Oshasha's Treatise",
		head = "Viti. Chapeau +4",
		body = "Jhakri Robe +2",
		hands = "Jhakri Cuffs +2",
		legs = aug.CarmineCuisses,
		feet = "Jhakri Pigaches +2",
		neck = "Fotia Gorget",
		waist = "Fotia Belt",
		left_ear = "Steelflash Earring",
		right_ear = "Bladeborn Earring",
		left_ring = "Apate Ring",
		right_ring = "Rajas Ring",
		back = capes.WeponSkill,
	}

	precast.Weaponskill.Proc = precast.Weaponskill
	precast.Weaponskill.Requiescat = precast.Weaponskill
	precast.Weaponskill.ChantDuCygne = precast.Weaponskill
	precast.Weaponskill.Evisceration = precast.Weaponskill.ChantDuCygne
	precast.Weaponskill.SavageBlade = precast.Weaponskill
	precast.Weaponskill.BlackHalo = precast.Weaponskill
	precast.Weaponskill.SanguineBlade = precast.Weaponskill
	precast.Weaponskill.SeraphBlade = precast.Weaponskill
	precast.Weaponskill.ShiningStrike = precast.Weaponskill.SeraphBlade
	precast.Weaponskill.FlashNova = precast.Weaponskill.SeraphBlade
	precast.Weaponskill.AeolianEdge = precast.Weaponskill
	precast.Weaponskill.RedLotusBlade = precast.Weaponskill.AeolianEdge

	-- TP

	-- Normal
	sets.engaged = {
		ammo = "Ginsen",
		head = "Aya. Zucchetto +2",
		body = "Ayanmo Corazza +2",
		hands = "Aya. Manopolas +2",
		legs = aug.CarmineCuisses,
		feet = "Aya. Gambieras +2",
		neck = "Asperity Necklace",
		waist = "Kentarch Belt +1",
		left_ear = "Steelflash Earring",
		right_ear = "Bladeborn Earring",
		left_ring = "Rajas Ring",
		right_ring = "Apate Ring",
		back = capes.Melee,
	}



	sets.engaged.Acc = set_combine(sets.engaged, {
		head = "Jhakri Coronal +2",
		body = "Jhakri Robe +2",
		hands = "Jhakri Cuffs +2",
		neck = "Fotia Gorget",
		waist = "Fotia Belt",
		back = capes.WeponSkill,
	})

	sets.engaged.DT = set_combine(sets.engaged, {
	})

	sets.engaged.Acc.DT = set_combine(sets.engaged, {
	})

	-- Dual Wield
	sets.engaged.DW = set_combine(sets.engaged, {

	})

	sets.engaged.DW.Acc = set_combine(sets.engaged.DW, {
	})

	sets.engaged.DW.DT = set_combine(sets.engaged.DW, {
	})

	sets.engaged.DW.Acc.DT = set_combine(sets.engaged.DW, {
	})

	-- Enspell

	sets.engaged.EnspellOnly = {
	}

	sets.engaged.EnspellOnly.Acc = set_combine(sets.engaged.EnspellOnly, {
	})

	sets.engaged.DualEnspellOnly = set_combine(sets.engaged.EnspellOnly, {
	})

	sets.engaged.DualEnspellOnly.Acc = set_combine(sets.engaged.EnspellOnly, {
	})
end

function character_user_job_setup()
	define_user_gearsets();

	-- Options: Override default values
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Proc')
	state.CastingMode:options('Normal', 'Resistant', 'Proc', 'SIRD')
	state.IdleMode:options('Normal', 'PDT', 'MDT', 'MEVA', 'Aminon')
	state.PhysicalDefenseMode:options('PDT', 'NukeLock')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.BuffWeaponsMode = M { 'Always', 'Never' }
	state.AutoBuffMode = M { ['description'] = 'Auto Buff Mode', 'Off', 'Auto', 'AutoMelee', 'AutoMage' }
	state.Weapons:options('None', 'SavageBlade', 'Club', 'SanguineBlade', 'Dagger', 'EnspellOnly', 'DualWeapons',
		'DualWeaponsAcc', 'DualClub', 'DualSanguineBlade', 'DualClubAcc', 'DualEnspellOnly', 'DualProcSword',
		'DualProcClub', 'Thibron')
	state.WeaponSets:options('Default', 'Dual', 'Proc', 'Dynamis')


	weapon_sets = {
		['Default'] = { 'None', 'Naegling', 'Club', 'SanguineBlade', 'Dagger', 'EnspellOnly' },
		['Dual'] = { 'DualWeapons', 'DualWeaponsAcc', 'DualClub', 'DualSanguineBlade', 'DualClubAcc', 'DualEnspellOnly','Thibron' },
		['Dynamis'] = { 'DualSanguineBladeSavageBlade', 'DualSanguineBlade', 'DualDaggerSanguineBlade' },
		['Proc'] = { 'ProcSword', 'ProcDagger', 'DualProcSword', 'DualProcDagger', 'DualProcClub' },
	}

	default_weapons = user.options.default.Weapon
	default_dual_weapons = user.options.default.DualWeapon

	autows_list = {
		['SavageBlade'] = 'Savage Blade',
		['Thibron'] = 'Savage Blade',
		['Club'] = 'Black Halo',
		['SanguineBlade'] = 'Sanguine Blade',
		['Dagger'] = 'Aeolian Edge',
		['DualWeapons'] = 'Savage Blade',
		['DualWeaponsAcc'] = 'Savage Blade',
		['DualClub'] = 'Black Halo',
		['DualClubAcc'] = 'Black Halo',
		['DualEvisceration'] = 'Evisceration',
		['DualSanguineBlade'] = 'Sanguine Blade',
		['DualClubs'] = 'Black Halo',
		['DualAeolian'] = 'Aeolian Edge',
		['DualPrime'] = 'Exenterator',
		['DualSanguineBladeSavageBlade'] = "Savage Blade",
		['SanguineBladeDaybreak'] = "Seraph Blade",
		["DualDaggerSanguineBlade"] = "Aeolian Edge"
	}

	trust_list = user.options.trusts

	select_default_macro_book()
end

function init_gear_sets()
	--------------------------------------
	-- Start defining the sets
	--------------------------------------
	-- Weapons sets
	sets.weapons.Naegling = user.sets.weapons.SavageBlade
	sets.weapons.SanguineBlade = user.sets.weapons.SanguineBlade
	sets.weapons.Club = user.sets.weapons.Club
	sets.weapons.Dagger = user.sets.weapons.Dagger
	sets.weapons.DualWeapons = user.sets.weapons.DualWeapons
	sets.weapons.DualWeaponsAcc = user.sets.weapons.DualWeaponsAcc
	sets.weapons.DualSanguineBlade = user.sets.weapons.DualSanguineBlade
	sets.weapons.DualProcSword = user.sets.weapons.DualProcSword
	sets.weapons.DualProcClub = sets.weapons.DualProcClub
	sets.weapons.ProcSword = user.sets.weapons.ProcSword
	sets.weapons.ProcDagger = user.sets.weapons.ProcDagger
	sets.weapons.DualProcDagger = user.sets.weapons.DualProcDagger
	sets.weapons.EnspellOnly = user.sets.weapons.EnspellOnly
	sets.weapons.DualEnspellOnly = user.sets.weapons.DualEnspellOnly
	sets.weapons.DualClub = user.sets.weapons.DualClub
	sets.weapons.DualClubAcc = user.sets.weapons.DualClubAcc
	sets.weapons.Thibron = { main='Machaera +2', sub='Demersal Degen +1' }

	--Temporary Weapon Sets for Dynamis RP
	sets.weapons.DualSanguineBladeSavageBlade = user.sets.weapons.DualSanguineBladeSavageBlade
	sets.weapons.DualDaggerSanguineBlade = user.sets.weapons.DualDaggerSanguineBlade

	-- Precast Sets

	-- Precast sets to enhance JAs
	sets.precast.JA['Chainspell'] = user.sets.precast.Chainspell

	-- Steps (Pure Acc)
	sets.precast.Step = user.sets.precast.Steps

	-- Violent Flourish (Macc & Acc)
	sets.precast.JA['Violent Flourish'] = user.sets.precast.ViolentFlourish

	-- Waltz set (chr and vit)
	sets.precast.Waltz = user.sets.precast.Waltz

	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = user.sets.precast.HealingWaltz

	-- Fast cast sets for spells
	sets.precast.FC = user.sets.precast.FastCast

	sets.precast.FC.DT = user.sets.precast.FastCast.DT

	sets.precast.FullFC = user.sets.precast.FastCast

	sets.precast.FC.Impact = user.sets.precast.Impact
	sets.precast.FC.Dispelga = user.sets.precast.Dispelga

	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = user.sets.precast.Weaponskill

	sets.precast.WS.Proc = user.sets.precast.Weaponskill.Proc

	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	sets.precast.WS['Requiescat'] = user.sets.precast.Weaponskill.Requiescat

	sets.precast.WS['Chant du Cygne'] = user.sets.precast.Weaponskill.ChantDuCygne

	sets.precast.WS['Evisceration'] = user.sets.precast.Weaponskill.Evisceration

	sets.precast.WS['Savage Blade'] = user.sets.precast.Weaponskill.SavageBlade

	sets.precast.WS['Black Halo'] = user.sets.precast.Weaponskill.BlackHalo

	sets.precast.WS['Sanguine Blade'] = user.sets.precast.Weaponskill.SanguineBlade

	sets.precast.WS['Seraph Blade'] = user.sets.precast.Weaponskill.SeraphBlade

	sets.precast.WS['Shining Strike'] = user.sets.precast.Weaponskill.ShiningStrike
	sets.precast.WS['Flash Nova'] = user.sets.precast.Weaponskill.FlashNova

	sets.precast.WS['Aeolian Edge'] = user.sets.precast.Weaponskill.AeolianEdge

	sets.precast.WS['Red Lotus Blade'] = user.sets.precast.Weaponskill.RedLotusBlade

	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {}      --{ear2="Brutal Earring"}
	sets.AccMaxTP = {}   -- {ear2="Telos Earring"}
	sets.MagicalMaxTP = {} --{ear2="Friomisi Earring"}

	-- Midcast Sets

	-- Gear that converts elemental damage done to recover MP.	
	sets.midcast.FastRecast = user.sets.midcast.FastRecast

	sets.midcast.Cure = user.sets.midcast.Cure

	sets.midcast.LightWeatherCure = user.sets.midcast.Cure.LightWeatherCure

	--Cureset for if it's not light weather but is light day.
	sets.midcast.LightDayCure = user.sets.midcast.Cure.LightDayCure

	sets.midcast.Cure.DT = user.sets.midcast.Cure.DT

	sets.midcast.Cursna = user.sets.midcast.Cure.Cursna

	sets.midcast.StatusRemoval = user.sets.midcast.Cure.StatusRemoval

	sets.midcast['Enhancing Magic'] = user.sets.midcast.EnhancingMagic

	sets.buff.ComposureOther = user.sets.buffs.ComposureOther

	--Red Mage enhancing sets are handled in a different way from most, layered on due to the way Composure works
	--Don't set combine a full set with these spells, they should layer on Enhancing Set > Composure (If Applicable) > Spell
	sets.EnhancingSkill = user.sets.midcast.EnhancingSkill

	sets.midcast.Refresh = user.sets.midcast.Refresh
	sets.midcast.Aquaveil = user.sets.midcast.Aquaveil
	sets.midcast.BarElement = user.sets.midcast.BarElement
	sets.midcast.BarStatus = user.sets.midcast.BarStatus
	sets.midcast.Temper = user.sets.midcast.Temper
	sets.midcast.Enspell = user.sets.midcast.Enspell
	sets.midcast.BoostStat = user.sets.midcast.BoostStat
	sets.midcast.Stoneskin = user.sets.midcast.Stoneskin
	sets.midcast.Protect = user.sets.midcast.Protect
	sets.midcast.Shell = user.sets.midcast.Shell
	sets.midcast.Regen = user.sets.midcast.Regen

	sets.midcast.Curaga = sets.midcast.Cure
	sets.Self_Healing = user.sets.SelfHealing
	sets.Cure_Received = user.sets.CureReceived
	sets.Self_Refresh = user.sets.SelfRefresh
	sets.Self_Phalanx = user.sets.SelfPhalanx
	sets.Self_Phalanx.DW = user.sets.SelfPhalanx.DW

	sets.midcast['Enfeebling Magic'] = user.sets.midcast.EnfeeblingMagic

	sets.midcast['Enfeebling Magic'].Resistant = user.sets.midcast.EnfeeblingMagic.Resistant

	sets.midcast['Enfeebling Magic'].DW = user.sets.midcast.EnfeeblingMagic.DW

	sets.midcast.Sleep = user.sets.midcast.EnfeeblingMagic.SleepBindBreak
	sets.midcast.Bind = sets.midcast.Sleep
	sets.midcast.Break = sets.midcast.Sleep

	sets.midcast['Dia II'] = sets.midcast.Sleep
	sets.midcast['Bio II'] = sets.midcast.Sleep
	sets.midcast['Dia III'] = sets.midcast.Sleep
	sets.midcast['Bio III'] = sets.midcast.Sleep
	sets.midcast.Inundation = sets.midcast.Sleep

	sets.TreasureHunter = set_combine(user.sets.TreasureHunter, sets.TreasureHunter)

	sets.midcast.Stonega = set_combine(user.sets.midcast.ElemetalMagic, sets.TreasureHunter)
	sets.midcast.Dia = set_combine(sets.midcast.Sleep, sets.TreasureHunter)
	sets.midcast.Diaga = set_combine(sets.midcast.Sleep, sets.TreasureHunter)
	sets.midcast.Bio = set_combine(sets.midcast.Sleep, sets.TreasureHunter)

	sets.midcast.Sleep.Resistant = user.sets.midcast.EnfeeblingMagic.SleepBindBreak.Resistant
	sets.midcast.Bind.Resistant = sets.midcast.Sleep.Resistant
	sets.midcast.Break.Resistant = sets.midcast.Sleep.Resistant

	sets.midcast.Sleep.DW = user.sets.midcast.EnfeeblingMagic.SleepBindBreak.DW
	sets.midcast.Bind.DW = sets.midcast.Sleep.DW
	sets.midcast.Break.DW = sets.midcast.Sleep.DW

	sets.midcast.Dispel = user.sets.midcast.EnfeeblingMagic.Dispel
	sets.midcast.Dispel.DW = user.sets.midcast.EnfeeblingMagic.Dispel.DW

	sets.midcast.Dispelga = user.sets.midcast.EnfeeblingMagic.Dispelga
	sets.midcast.Dispelga.DW = user.sets.midcast.EnfeeblingMagic.Dispelga.DW

	sets.midcast.Frazzle = user.sets.midcast.EnfeeblingMagic.FrazzleDistract
	sets.midcast.Distract = sets.midcast.Frazzle

	sets.midcast.Frazzle.Resistant = user.sets.midcast.EnfeeblingMagic.FrazzleDistract.Resistant

	sets.midcast.Distract.Resistant = sets.midcast.Frazzle.Resistant

	sets.midcast['Frazzle II'] = sets.midcast.Frazzle.Resistant
	sets.midcast.Frazzle.DW = user.sets.midcast.EnfeeblingMagic.FrazzleDistract.DW
	sets.midcast.Distract.DW = sets.midcast.Frazzle.DW

	sets.midcast.Addle = user.sets.midcast.EnfeeblingMagic.AddleParalyzeSlow

	sets.midcast.Paralyze = sets.midcast.Addle
	sets.midcast.Slow = sets.midcast.Addle

	sets.midcast.Addle.Resistant = user.sets.midcast.EnfeeblingMagic.AddleParalyzeSlow.Resistant

	sets.midcast.Paralyze.Resistant = sets.midcast.Addle.Resistant
	sets.midcast.Slow.Resistant = sets.midcast.Addle.Resistant

	sets.midcast.Addle.DW = user.sets.midcast.EnfeeblingMagic.AddleParalyzeSlow.DW
	sets.midcast.Paralyze.DW = sets.midcast.Addle.DW
	sets.midcast.Slow.DW = sets.midcast.Addle.DW

	sets.midcast.Gravity = user.sets.midcast.EnfeeblingMagic.GravityPoisonBlind

	sets.midcast.Gravity.Resistant = user.sets.midcast.EnfeeblingMagic.GravityPoisonBlind.Resistant

	sets.midcast.Gravity.DW = user.sets.midcast.EnfeeblingMagic.GravityPoisonBlind.DW

	sets.midcast.Poison = sets.midcast.Gravity
	sets.midcast.Poison.Resistant = sets.midcast.Gravity.Resistant
	sets.midcast.Poison.DW = sets.midcast.Gravity.DW

	sets.midcast.Blind = sets.midcast.Gravity
	sets.midcast.Blind.Resistant = sets.midcast.Gravity.Resistant
	sets.midcast.Blind.DW = sets.midcast.Gravity.DW

	sets.midcast.Silence = user.sets.midcast.EnfeeblingMagic.Silence

	sets.midcast.Silence.Resistant = user.sets.midcast.EnfeeblingMagic.Silence.Resistant

	sets.midcast.Silence.DW = user.sets.midcast.EnfeeblingMagic.Silence.DW

	sets.midcast['Elemental Magic'] = user.sets.midcast.ElemetalMagic

	sets.midcast['Elemental Magic'].DT = user.sets.midcast.ElemetalMagic.DT

	sets.midcast['Elemental Magic'].Resistant = user.sets.midcast.ElemetalMagic.Resistant

	sets.midcast['Elemental Magic'].Proc = user.sets.midcast.ElemetalMagic.Proc

	sets.midcast['Elemental Magic'].HighTierNuke = user.sets.midcast.ElemetalMagic.HighTierNuke

	sets.midcast['Elemental Magic'].HighTierNuke.Resistant = user.sets.midcast.ElemetalMagic.HighTierNuke.Resistant

	sets.midcast['Elemental Magic'].DW = user.sets.midcast.ElemetalMagic.DW

	-- Gear that Recovers MP when nuking.
	sets.RecoverMP = {} -- {body="Seidr Cotehardie"}

	sets.midcast.Impact = user.sets.midcast.ElemetalMagic.Impact

	sets.midcast['Dark Magic'] = user.sets.midcast.DarkMagic

	sets.midcast.Drain = user.sets.midcast.DarkMagic.DrainAspir

	sets.midcast.Aspir = sets.midcast.Drain

	sets.midcast['Absorb-TP'] = user.sets.midcast.DarkMagic.AbsorbTP

	sets.midcast['Absorb-TP'].Resistant = user.sets.midcast.DarkMagic.AbsorbTP

	sets.midcast.Stun = user.sets.midcast.DarkMagic.Stun

	sets.midcast.Stun.Resistant = user.sets.midcast.DarkMagic.Stun.Resistant

	sets.midcast.Stun.DW = user.sets.midcast.DarkMagic.Stun.DW

	-- Sets for special buff conditions on spells.

	sets.buff.Saboteur = user.sets.buffs.Saboteur

	-- sets.HPDown = {main="Mpaca's Staff",sub="Oneiros Grip",ammo="Homiliary",
	-- 	head="Pixie Hairpin +1",neck="Loricate Torque +1",ear1="Hirudinea Earring",ear2="Ethereal Earring",
	-- 	body="Jhakri Robe +2",hands="Jhakri Cuffs +2",ring1="Mephitas's Ring +1",ring2="Metamor. Ring +1",
	-- 	back="Null Shawl",waist="Luminary Sash",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}

	-- sets.HPCure = {main="Daybreak",sub="Ammurapi Shield",ammo="Regal Gem",
	-- 	head="Nyame Helm",neck="Sanctity Necklace",ear1="Etiolation Earring",ear2="Odnowa Earring +1",
	-- 	body="Bunzi's Robe",hands="Bokwus Gloves",ring1="Sirona's Ring",ring2="Kunaji Ring",
	-- 	back="Engulfer Cape +1",waist="Gishdubar Sash",legs="Nyame Flanchard",feet="Medium's Sabots"}

	-- sets.buff.Doom = set_combine(sets.buff.Doom, {})

	-- Sets to return to when not performing an action.

	-- Resting sets
	sets.resting = user.sets.resting

	-- sets.Ballista = {main="Sakpata's Sword",sub="Sacro Bulwark",range=empty,ammo="Staunch Tathlum +1",
	-- 	head="Bunzi's Hat",neck="Dls. Torque +2",ear1="Etiolation Earring",ear2="Leth. Earring +1",
	-- 	body="Bunzi's Robe",hands="Bunzi's Gloves",ring1="Shneddick Ring",ring2="Shadow Ring",
	-- 	back="Null Shawl",waist="Null Belt",legs="Bunzi's Pants",feet="Leth. Houseaux +3"}

	-- Idle sets
	sets.idle = user.sets.idle
	sets.idle.PDT = user.sets.idle.PDT
	sets.idle.MDT = user.sets.idle.MDT
	sets.idle.MEVA = user.sets.idle.MEVA
	sets.idle.Aminon = user.sets.idle.Aminon
	sets.idle.None = {}

	-- Defense sets
	sets.defense.PDT = user.sets.defense.PDT
	sets.defense.MDT = user.sets.defense.MDT
	sets.defense.MEVA = user.sets.defense.MEVA

	sets.defense.NukeLock = sets.midcast['Elemental Magic']

	sets.Kiting = user.sets.Kiting
	sets.latent_refresh = user.sets.latent_refresh
	sets.latent_refresh_grip = user.sets.latent_refresh_grip
	sets.DayIdle = {}
	sets.NightIdle = {}

	sets.buff.Sublimation = user.sets.buffs.Sublimation
	sets.buff.DTSublimation = user.sets.buffs.Sublimation

	-- Engaged sets

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.Dagger.Accuracy.Evasion

	-- Normal melee group

	sets.engaged = user.sets.engaged

	sets.engaged.Acc = user.sets.engaged.Acc

	sets.engaged.DT = user.sets.engaged.DT

	sets.engaged.Acc.DT = user.sets.engaged.Acc.DT

	sets.engaged.DW = user.sets.engaged.DW

	sets.engaged.DW.Acc = user.sets.engaged.DW.Acc

	sets.engaged.DW.DT = user.sets.engaged.DW.DT

	sets.engaged.DW.Acc.DT = user.sets.engaged.DW.Acc.DT

	sets.engaged.EnspellOnly = user.sets.engaged.EnspellOnly

	sets.engaged.EnspellOnly.Acc = user.sets.engaged.EnspellOnly.Acc

	sets.engaged.DualEnspellOnly = user.sets.engaged.DualEnspellOnly

	sets.engaged.DualEnspellOnly.Acc = user.sets.engaged.DualEnspellOnly.Acc
end

function user_job_buff_change(buff, gain)
	if buff:startswith('Addendum: ') or buff:endswith(' Arts') then
		style_lock = true
	end
end

function user_job_precast(spell, spellMap, eventArgs)
	if state.Weapons.value ~= 'None' and not state.UnlockWeapons.value then
		equip_weaponset()
	end
end

function user_job_post_midcast(spell, spellMap, eventArgs)
	if spell.english:startswith('Refresh') and spell.target.type == 'SELF' and sets.Self_Refresh then
		equip(sets.Self_Refresh)
		if can_dual_wield and sets.Self_Refresh.DW then
			equip(sets.Self_Refresh.DW)
		end
	end
end

buff_spell_lists = {
	Auto = { --Options for When are: Always, Engaged, Idle, OutOfCombat, Combat
		{ Name = 'Refresh III', Buff = 'Refresh', SpellID = 894, When = 'Always' },
		{ Name = 'Haste II',  Buff = 'Haste',     SpellID = 511, When = 'Always' },
		{ Name = 'Aurorastorm', Buff = 'Aurorastorm', SpellID = 119, When = 'Idle' },
		--{Name='Reraise',		Buff='Reraise',		SpellID=135,	When='Always'},
	},

	AutoMelee = {
		--{ Name = 'Phalanx II', Buff = 'Phalanx',    SpellID = 107, When = 'Combat' },
		{ Name = 'Haste II',  Buff = 'Haste',       SpellID = 511, When = 'Combat' },
		{ Name = 'Temper II', Buff = 'Multi Strikes', SpellID = 895, When = 'Combat' },
		{ Name = 'Refresh III', Buff = 'Refresh',   SpellID = 894, When = 'Always' },
		{ Name = 'Gain-STR',  Buff = 'STR Boost',   SpellID = 486, When = 'Combat' },
		{ Name = 'Stoneskin', Buff = 'Stoneskin', SpellID = 54, When = 'Always' },
		{ Name = 'Phalanx',   Buff = 'Phalanx',     SpellID = 107, Reapply = false },
		{ Name = 'Regen II',    Buff = 'Regen',         SpellID = 110, Reapply = false },
	},

	AutoMage = {
		{ Name = 'Phalanx',   Buff = 'Phalanx', SpellID = 107, When = 'Always' },
		{ Name = 'Haste II',  Buff = 'Haste',   SpellID = 511, When = 'Always' },
		{ Name = 'Refresh III', Buff = 'Refresh', SpellID = 894, When = 'Always' },
		{ Name = 'Refresh III', Buff = 'Refresh', SpellID = 894, When = 'Always' },
		{ Name = 'Gain-INT',  Buff = 'INT Boost', SpellID = 490, When = 'Always' },
		{ Name = 'Aquaveil',  Buff = 'Aquaveil', SpellID = 55, When = 'Always' },
		{ Name = 'Blink',     Buff = 'Blink',   SpellID = 53, When = 'Always' },
		{ Name = 'Shell V',   Buff = 'Shell',   SpellID = 52, When = 'Always' },
		{ Name = 'Protect V', Buff = 'Protect', SpellID = 47, When = 'Always' },
		{ Name = 'Stoneskin', Buff = 'Stoneskin', SpellID = 54, When = 'Always' },
	},

	Default = {
		{ Name = 'Haste II',  Buff = 'Haste',   SpellID = 511, Reapply = false },
		{ Name = 'Refresh III', Buff = 'Refresh', SpellID = 894, Reapply = false },
		--{Name='Gain-MND',		Buff='MND Boost',		SpellID=491,	Reapply=false},
		--{Name='Aquaveil',		Buff='Aquaveil',		SpellID=55,		Reapply=false},
		{ Name = 'Phalanx',   Buff = 'Phalanx', SpellID = 107, Reapply = false },
		{ Name = 'Stoneskin', Buff = 'Stoneskin', SpellID = 54, Reapply = false },
		{ Name = 'Blink',     Buff = 'Blink',   SpellID = 53, Reapply = false },
		{ Name = 'Shell V',   Buff = 'Shell',   SpellID = 52, Reapply = false },
		{ Name = 'Protect V', Buff = 'Protect', SpellID = 47, Reapply = false },
	},

	MageBuff = {
		{ Name = 'Haste II',  Buff = 'Haste',   SpellID = 511, Reapply = false },
		{ Name = 'Refresh III', Buff = 'Refresh', SpellID = 894, Reapply = false },
		{ Name = 'Gain-INT',  Buff = 'INT Boost', SpellID = 490, Reapply = false },
		{ Name = 'Aquaveil',  Buff = 'Aquaveil', SpellID = 55, Reapply = false },
		{ Name = 'Phalanx',   Buff = 'Phalanx', SpellID = 107, Reapply = false },
		{ Name = 'Stoneskin', Buff = 'Stoneskin', SpellID = 54, Reapply = false },
		{ Name = 'Blink',     Buff = 'Blink',   SpellID = 53, Reapply = false },
		{ Name = 'Shell V',   Buff = 'Shell',   SpellID = 52, Reapply = false },
		{ Name = 'Protect V', Buff = 'Protect', SpellID = 47, Reapply = false },
	},

	FullMeleeBuff = {
		{ Name = 'Haste II',  Buff = 'Haste',       SpellID = 511, Reapply = false },
		{ Name = 'Refresh III', Buff = 'Refresh',   SpellID = 894, Reapply = false },
		{ Name = 'Phalanx',   Buff = 'Phalanx',     SpellID = 107, Reapply = false },
		{ Name = 'Temper II', Buff = 'Multi Strikes', SpellID = 895, Reapply = false },
		{ Name = 'Gain-STR',  Buff = 'STR Boost',   SpellID = 486, Reapply = false },
		--{Name='Enthunder',		Buff='Enthunder',		SpellID=104,	Reapply=false},
		--{Name='Shock Spikes',	Buff='Shock Spikes',	SpellID=251,	Reapply=false},
		{ Name = 'Shell V',   Buff = 'Shell',       SpellID = 52, Reapply = false },
		{ Name = 'Protect V', Buff = 'Protect',     SpellID = 47, Reapply = false },
		--{Name='Barblizzard',	Buff='Barblizzard',		SpellID=61,		Reapply=false},
		--{Name='Barparalyze',	Buff='Barparalyze',		SpellID=74,		Reapply=false},
		{ Name = 'Aquaveil',  Buff = 'Aquaveil',    SpellID = 55, Reapply = false },
		{ Name = 'Regen II',  Buff = 'Regen',       SpellID = 110, Reapply = false },
		{ Name = 'Stoneskin', Buff = 'Stoneskin',   SpellID = 54, Reapply = false },
		{ Name = 'Blink',     Buff = 'Blink',       SpellID = 53, Reapply = false },
	},

	MeleeBuff = {
		{ Name = 'Haste II',   Buff = 'Haste',       SpellID = 511, Reapply = false },
		{ Name = 'Refresh III', Buff = 'Refresh',    SpellID = 894, Reapply = false },
		{ Name = 'Phalanx',    Buff = 'Phalanx',     SpellID = 107, Reapply = false },
		{ Name = 'Temper II',  Buff = 'Multi Strikes', SpellID = 895, Reapply = false },
		{ Name = 'Gain-STR',   Buff = 'STR Boost',   SpellID = 486, Reapply = false },
		{ Name = 'Enthunder',  Buff = 'Enthunder',   SpellID = 104, Reapply = false },
		{ Name = 'Shock Spikes', Buff = 'Shock Spikes', SpellID = 251, Reapply = false },
	},

	Odin = {
		{ Name = 'Refresh III', Buff = 'Refresh',   SpellID = 894, Reapply = false },
		{ Name = 'Haste II',  Buff = 'Haste',       SpellID = 511, Reapply = false },
		{ Name = 'Phalanx II', Buff = 'Phalanx',    SpellID = 107, Reapply = false },
		{ Name = 'Gain-INT',  Buff = 'INT Boost',   SpellID = 490, Reapply = false },
		{ Name = 'Temper II', Buff = 'Multi Strikes', SpellID = 895, Reapply = false },
		{ Name = 'Regen II',  Buff = 'Regen',       SpellID = 110, Reapply = false },
		{ Name = 'Enaero',    Buff = 'Enaero',      SpellID = 102, Reapply = false },
		{ Name = 'Stoneskin', Buff = 'Stoneskin',   SpellID = 54, Reapply = false },
		{ Name = 'Shell V',   Buff = 'Shell',       SpellID = 52, Reapply = false },
		{ Name = 'Protect V', Buff = 'Protect',     SpellID = 47, Reapply = false },
	},

	HybridCleave = {
		{ Name = 'Refresh III', Buff = 'Refresh',    SpellID = 894, Reapply = false },
		{ Name = 'Haste II',   Buff = 'Haste',       SpellID = 511, Reapply = false },
		{ Name = 'Phalanx',    Buff = 'Phalanx',     SpellID = 107, Reapply = false },
		{ Name = 'Gain-INT',   Buff = 'INT Boost',   SpellID = 490, Reapply = false },
		{ Name = 'Enthunder II', Buff = 'Enthunder II', SpellID = 316, Reapply = false },
		{ Name = 'Temper II',  Buff = 'Multi Strikes', SpellID = 895, Reapply = false },
		{ Name = 'Shell V',    Buff = 'Shell',       SpellID = 52, Reapply = false },
		{ Name = 'Protect V',  Buff = 'Protect',     SpellID = 47, Reapply = false },
	},
}
