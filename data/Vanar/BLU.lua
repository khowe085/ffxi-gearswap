-- Vanar's BLU, from Mytha_Blu_Gear.lua on the old branch. Where Mytha's piece isn't owned, the
-- best owned piece for that set's job (per bg-wiki) stands in, with Mytha's piece noted beside it.
-- Murky Ring and Alabaster Earring are placed for their fully augmented Accuracy+15 / Magic Accuracy+15.
-- init_gear() defines every set on the gear table; get_sets() sets the modes and hands them to
-- Core.lua, which defines precast, midcast, aftercast, pet_midcast, pet_aftercast, status_change,
-- sub_job_change, self_command and file_unload. The job hooks at the bottom add BLU's own behavior.
include("Core.lua")

local function init_gear()
	-- Artifact
	gear.af_head = "Assim. Keffiyeh +1"
	gear.af_body = "Assim. Jubbah +4"
	gear.af_hands = "Assim. Bazu. +3"
	gear.af_legs = "Assim. Shalwar +1"
	gear.af_feet = "Assim. Charuqs +2"

	-- Relic
	gear.relic_head = "Luh. Keffiyeh +1"
	gear.relic_body = "Luhlaza Jubbah +1"
	gear.relic_hands = "Luh. Bazubands +1"
	gear.relic_legs = "Luh. Shalwar +4"
	gear.relic_feet = "Luhlaza Charuqs +1"

	-- Empyrean
	gear.empy_head = "Hashishin Kavuk +3"
	gear.empy_body = "Hashishin Mintan +3"
	gear.empy_hands = "Hashi. Bazu. +3"
	gear.empy_legs = "Hashishin Tayt +3"
	gear.empy_feet = "Hashi. Basmak +3"
	gear.empy_ear = "Hashi. Earring +1"

	-- Ambuscade capes
	gear.da_cape = {name = "Rosmerta's Cape", augments = { "DEX+20", "Accuracy+20 Attack+20", "Accuracy+10", '"Dbl.Atk."+10', "Damage taken-5%" } }
	gear.crit_cape = { name = "Rosmerta's Cape", augments = { "DEX+20", "Accuracy+20 Attack+20", 'DEX+5', "Crit.hit rate+10" } }
	gear.wsd_cape = {name = "Rosmerta's Cape", augments = { "STR+20", "Accuracy+20 Attack+20", "STR+10", "Weapon skill damage +10%" } }
	gear.nuke_cape = {name = "Rosmerta's Cape",	augments = { "INT+20", "Mag. Acc+20 /Mag. Dmg.+20", "Mag. Acc.+10", '"Mag.Atk.Bns."+10' } }
	gear.skill_cape = { name = "Cornflower Cape", augments = { "MP+29", "DEX+1", "Accuracy+3", "Blue Magic skill +10" } }

	-- Augmented pieces
	gear.adhemar_head = { name = "Adhemar Bonnet", augments = { "STR+10", "DEX+10", "Attack+15" } }
	gear.adhemar_body = { name = "Adhemar Jacket", augments = { "STR+10", "DEX+10", "Attack+15" } }
	gear.adhemar_hands = { name = "Adhemar Wristbands", augments = { "STR+10", "DEX+10", "Attack+15" } }
	gear.carmine_legs = { name = "Carmine Cuisses +1", augments = { "Accuracy+20", "Attack+12", '"Dual Wield"+6' } }
	gear.amalric_head =	{ name = "Amalric Coif +1", augments = { "INT+11", "Elem. magic skill +17", "Dark magic skill +17" } }

	-- Your Blue Magic skill pieces, layered under the sets that lean on skill.
	gear.blue_magic_skill = {
		ammo = "Mavi Tathlum",
		head = gear.relic_head,
		neck = "Mirage Stole +2",
		ear1 = "Njordr Earring",
		ear2 = gear.empy_ear,
		body = gear.af_body,
		ring1 = "Stikini Ring",
		back = gear.skill_cape,
		legs = gear.empy_legs,
		feet = gear.relic_feet,
	}

	-- Sets

	gear.weapons = {}
	gear.weapons.Tizbron = { main = "Tizona", sub = "Thibron" }
	gear.weapons.Tizalmace = { main = "Tizona", sub = "Almace" }
	gear.weapons.Almace = { main = "Almace", sub = "Thibron" }
	gear.weapons.Maxbron = { main = "Maxentius", sub = "Thibron" }
	gear.weapons.Naegbron = { main = "Naegling", sub = "Thibron" }
	gear.weapons.Naegmace = { main = "Naegling", sub = "Almace" }
	gear.treasure_hunter =	{ 
		ammo = "Per. Lucky Egg", 
		head = "Wh. Rarab Cap +1", 
		body = "Volte Jupon", 
		waist = "Chaac Belt" 
	}

	-- Worn over a Blue Magic midcast while the matching JA buff is up (job_post_midcast).
	gear.buff = {}
	gear.buff["Burst Affinity"] = { legs = gear.af_legs, feet = gear.empy_feet }
	gear.buff["Chain Affinity"] = { feet = gear.af_feet }
	gear.buff.Convergence = { head = gear.relic_head }
	gear.buff.Diffusion = { feet = gear.relic_feet }
	gear.buff.Efflux = { back = gear.da_cape, legs = gear.empy_legs }

	-- Gear for learning spells.
	gear.learning = { hands = gear.af_hands }

	-- Precast Sets

	gear.ja = {}
	gear.ja["Azure Lore"] = { hands = gear.relic_hands }

	gear.waltz = {
		-- ammo: Mytha's Staunch Tathlum +1; nothing owned fits
		head = gear.empy_head, -- Mytha: Carmine Mask +1
		neck = "Loricate Torque", -- Mytha: Unmoving Collar +1
		ear1 = "Etiolation Earring", -- Mytha: Enchntr. Earring +1
		-- ear2: Mytha's Handler's Earring +1; nothing owned fits
		body = "Gleti's Cuirass", -- Mytha: Herculean Vest with a Waltz augment; Gleti's has Waltz potency +10%
		-- hands: Mytha's Herculean Gloves with a Waltz augment; nothing owned fits
		ring1 = "Murky Ring", -- Mytha: Defending Ring
		-- ring2: Mytha's Valseur's Ring; nothing owned fits
		back = gear.da_cape, -- Mytha: Moonlight Cape
		waist = "Chaac Belt",
		legs = gear.empy_legs, -- Mytha: Dashing Subligar
		-- feet: Mytha's Herculean Boots with a Waltz augment; nothing owned fits
	}

	-- Don't need any special gear for Healing Waltz.
	gear.waltz["Healing Waltz"] = {}

	gear.step = {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		head = gear.empy_head, -- Mytha: Carmine Mask +1
		neck = "Mirage Stole +2",
		ear1 = "Alabaster Earring", -- Mytha: Telos Earring
		ear2 = gear.empy_ear, -- Mytha: Regal Earring
		body = gear.af_body,
		hands = gear.af_hands,
		ring1 = "Murky Ring", -- Mytha: Ramuh Ring +1
		ring2 = "Lehko's Ring", -- Mytha: Ramuh Ring +1
		back = gear.da_cape,
		waist = "Eschan Stone", -- Mytha: Olseni Belt
		legs = gear.carmine_legs,
		feet = gear.empy_feet, -- Mytha: Malignance Boots
	}

	gear.flourish = {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		head = gear.empy_head, -- Mytha: Malignance Chapeau
		neck = "Mirage Stole +2",
		ear1 = "Alabaster Earring", -- Mytha: Digni. Earring
		ear2 = gear.empy_ear, -- Mytha: Regal Earring
		body = gear.empy_body, -- Mytha: Malignance Tabard
		hands = gear.empy_hands, -- Mytha: Malignance Gloves
		ring1 = "Stikini Ring", -- Mytha: Stikini Ring +1
		ring2 = "Stikini Ring", -- Mytha: Stikini Ring +1
		back = gear.skill_cape,
		waist = "Eschan Stone", -- Mytha: Olseni Belt
		legs = gear.empy_legs, -- Mytha: Malignance Tights
		feet = gear.empy_feet, -- Mytha: Malignance Boots
	}

	-- Fast cast sets for spells

	gear.fc = {
		-- ammo: Mytha's Impatiens; quick magic unwanted
		head = gear.amalric_head, -- Mytha: Carmine Mask +1
		-- neck: Mytha's Voltsurge Torque; nothing owned fits
		ear1 = "Etiolation Earring", -- Mytha: Enchntr. Earring +1
		ear2 = "Loquac. Earring",
		body = gear.relic_body,
		hands = "Pinga Mittens", -- Mytha: Leyline Gloves
		ring1 = "Naji's Loop", -- Mytha: Kishar Ring
		ring2 = "Prolix Ring", -- Mytha: Lebeche Ring
		back = "Swith Cape", -- Mytha: Perimede Cape
		waist = "Witful Belt",
		legs = "Aya. Cosciales +2", -- Mytha: Psycloth Lappas
		feet = "Chelona Boots", -- Mytha: Carmine Greaves +1
	}

	gear.fc["Blue Magic"] = set_combine(gear.fc, { body = gear.empy_body })

	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined

	gear.ws = {
		ammo = "Coiste Bodhar", -- Mytha: Aurgelmir Orb +1
		head = gear.empy_head, -- Mytha: Lilitu Headpiece
		neck = "Fotia Gorget",
		ear1 = "Brutal Earring",
		ear2 = gear.empy_ear, -- Mytha: Cessance Earring
		body = gear.adhemar_body,
		hands = "Jhakri Cuffs +2",
		ring1 = "Karieyh Ring", -- Mytha: Epona's Ring
		ring2 = "Epaminondas's Ring", -- Mytha: Apate Ring
		back = gear.da_cape,
		waist = "Fotia Belt",
		legs = gear.relic_legs,
		feet = "Nyame Sollerets", -- Mytha: Herculean Boots with a Triple Attack augment
	}

	gear.ws.Acc = {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		head = gear.empy_head, -- Mytha: Carmine Mask +1
		neck = "Fotia Gorget",
		ear1 = "Alabaster Earring", -- Mytha: Telos Earring
		ear2 = gear.empy_ear, -- Mytha: Mache Earring +1
		body = gear.af_body,
		hands = gear.af_hands,
		ring1 = "Karieyh Ring", -- Mytha: Epona's Ring
		ring2 = "Lehko's Ring", -- Mytha: Ilabrat Ring
		back = gear.da_cape,
		waist = "Fotia Belt",
		legs = gear.carmine_legs,
		feet = "Nyame Sollerets", -- Mytha: Herculean Boots with a Triple Attack augment
	}

	gear.ws.FullAcc = {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		head = gear.empy_head, -- Mytha: Carmine Mask +1
		neck = "Mirage Stole +2",
		ear1 = "Alabaster Earring", -- Mytha: Odr Earring
		ear2 = gear.empy_ear, -- Mytha: Mache Earring +1
		body = gear.af_body,
		hands = gear.af_hands,
		ring1 = "Murky Ring", -- Mytha: Ramuh Ring +1
		ring2 = "Lehko's Ring", -- Mytha: Ramuh Ring +1
		back = gear.da_cape,
		waist = "Eschan Stone", -- Mytha: Olseni Belt
		legs = gear.carmine_legs,
		feet = gear.empy_feet, -- Mytha: Malignance Boots
	}

	gear.ws.Fodder = gear.ws

	-- Specific weaponskill sets. Uses the base set if an appropriate OffenseMode version isn't found.
	gear.ws["Requiescat"] = set_combine(gear.ws, {
		head = "Jhakri Coronal +2",
		ear2 = gear.empy_ear, -- Mytha: Regal Earring
		body = "Jhakri Robe +2",
		ring2 = "Lehko's Ring", -- Mytha: Rufescent Ring
		legs = "Jhakri Slops +2",
		feet = "Jhakri Pigaches +2",
	})
	gear.ws["Requiescat"].Acc = set_combine(gear.ws.Acc, {
		head = "Jhakri Coronal +2",
		ear1 = "Alabaster Earring", -- Mytha: Telos Earring
		ear2 = gear.empy_ear, -- Mytha: Regal Earring
		ring1 = "Karieyh Ring", -- Mytha: Rufescent Ring
		legs = "Jhakri Slops +2",
		feet = "Jhakri Pigaches +2",
	})
	gear.ws["Requiescat"].FullAcc = gear.ws.FullAcc
	gear.ws["Requiescat"].Fodder = gear.ws["Requiescat"]

	gear.ws["Realmrazer"] = gear.ws["Requiescat"]

	gear.ws["Chant du Cygne"] = set_combine(gear.ws, {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		head = gear.adhemar_head,
		neck = "Mirage Stole +2",
		ear1 = "Moonshade Earring",
		ear2 = gear.empy_ear, -- Mytha: Odr Earring
		body = "Gleti's Cuirass", -- Mytha: Abnoba Kaftan
		hands = gear.adhemar_hands,
		ring2 = "Lehko's Ring", -- Mytha: Begrudging Ring
		back = gear.crit_cape,
		feet = "Nyame Sollerets", -- Mytha: Thereoid Greaves
	})
	gear.ws["Chant du Cygne"].Acc = set_combine(gear.ws.Acc, {
		ear1 = "Moonshade Earring",
		ear2 = gear.empy_ear, -- Mytha: Odr Earring
		ring2 = "Lehko's Ring", -- Mytha: Begrudging Ring
		body = gear.af_body, -- Mytha: Sayadio's Kaftan
		back = gear.crit_cape,
		legs = gear.carmine_legs,
	})
	gear.ws["Chant du Cygne"].FullAcc = gear.ws.FullAcc
	gear.ws["Chant du Cygne"].Fodder = gear.ws["Chant du Cygne"]

	gear.ws["Vorpal Blade"] = gear.ws["Chant du Cygne"]

	gear.ws["Savage Blade"] = set_combine(gear.ws, {
		head = gear.empy_head, -- Mytha: Lilitu Headpiece
		neck = "Mirage Stole +2",
		ear1 = "Moonshade Earring",
		ear2 = gear.empy_ear, -- Mytha: Ishvara Earring
		body = gear.af_body,
		hands = "Jhakri Cuffs +2",
		ring1 = "Epaminondas's Ring", -- Mytha: Ifrit Ring +1
		ring2 = "Lehko's Ring", -- Mytha: Rufescent Ring
		back = gear.wsd_cape,
		waist = "Sailfi Belt +1",
		legs = gear.relic_legs,
		feet = "Nyame Sollerets", -- Mytha: Herculean Boots with a WS damage augment
	})
	gear.ws["Savage Blade"].Acc = set_combine(gear.ws.Acc, {
		neck = "Mirage Stole +2",
		ear1 = "Moonshade Earring",
		hands = "Jhakri Cuffs +2",
		back = gear.wsd_cape,
		waist = "Eschan Stone", -- Mytha: Grunfeld Rope
		legs = gear.relic_legs,
		feet = "Nyame Sollerets", -- Mytha: Herculean Boots with a WS damage augment
	})
	gear.ws["Savage Blade"].FullAcc = gear.ws.FullAcc
	gear.ws["Savage Blade"].Fodder = gear.ws["Savage Blade"]

	-- Black Halo (Maxbron) has Savage Blade's mods, so it shares the set.
	gear.ws["Black Halo"] = gear.ws["Savage Blade"]

	gear.ws["Expiacion"] = set_combine(gear.ws, {
		head = gear.empy_head, -- Mytha: Lilitu Headpiece
		neck = "Mirage Stole +2",
		ear1 = "Moonshade Earring",
		ear2 = gear.empy_ear, -- Mytha: Ishvara Earring
		body = gear.af_body,
		hands = "Jhakri Cuffs +2",
		ring1 = "Epaminondas's Ring", -- Mytha: Ifrit Ring +1
		ring2 = "Lehko's Ring", -- Mytha: Rufescent Ring
		back = gear.wsd_cape,
		waist = "Sailfi Belt +1",
		legs = gear.relic_legs,
		feet = "Nyame Sollerets", -- Mytha: Herculean Boots with a WS damage augment
	})
	gear.ws["Expiacion"].Acc = set_combine(gear.ws.Acc, {
		neck = "Mirage Stole +2",
		ear1 = "Moonshade Earring",
		body = gear.af_body,
		hands = "Jhakri Cuffs +2",
		back = gear.wsd_cape,
		legs = gear.relic_legs,
		feet = "Nyame Sollerets", -- Mytha: Herculean Boots with a WS damage augment
	})
	gear.ws["Expiacion"].FullAcc = set_combine(gear.ws.FullAcc, { body = gear.af_body, hands = "Jhakri Cuffs +2" })
	gear.ws["Expiacion"].Fodder = gear.ws["Expiacion"]

	gear.ws["Sanguine Blade"] = {
		ammo = "Pemphredo Tathlum", -- Mytha: Ghastly Tathlum +1
		head = gear.empy_head, -- Mytha: Pixie Hairpin +1
		neck = "Sibyl Scarf", -- Mytha: Baetyl Pendant
		ear1 = "Novio Earring", -- Mytha: Regal Earring
		ear2 = "Friomisi Earring",
		body = gear.empy_body, -- Mytha: Amalric Doublet +1
		hands = "Jhakri Cuffs +2",
		ring1 = "Acumen Ring", -- Mytha: Metamor. Ring +1
		ring2 = "Jhakri Ring", -- Mytha: Archon Ring
		back = gear.nuke_cape,
		waist = "Eschan Stone", -- Mytha: Yamabuki-no-Obi
		legs = gear.relic_legs,
		feet = gear.empy_feet, -- Mytha: Amalric Nails +1
	}

	gear.ws["Flash Nova"] = {
		ammo = "Pemphredo Tathlum", -- Mytha: Ghastly Tathlum +1
		head = "Jhakri Coronal +2",
		neck = "Sibyl Scarf", -- Mytha: Baetyl Pendant
		ear1 = "Novio Earring", -- Mytha: Regal Earring
		ear2 = "Friomisi Earring",
		body = gear.empy_body, -- Mytha: Amalric Doublet +1
		hands = "Jhakri Cuffs +2",
		ring1 = "Acumen Ring", -- Mytha: Metamor. Ring +1
		ring2 = "Jhakri Ring", -- Mytha: Shiva Ring +1
		back = gear.nuke_cape,
		waist = "Eschan Stone", -- Mytha: Yamabuki-no-Obi
		legs = gear.relic_legs,
		feet = gear.empy_feet, -- Mytha: Amalric Nails +1
	}

	-- Swap these in for Moonshade Earring when TP is already capped (job_post_precast).
	gear.max_tp = { ear1 = "Brutal Earring", ear2 = gear.empy_ear } -- Mytha: Cessance Earring
	gear.acc_max_tp = { ear1 = "Alabaster Earring", ear2 = gear.empy_ear } -- Mytha: Regal Earring, Telos Earring

	-- Midcast Sets

	gear.fastrecast = {
		-- ammo: Mytha's Hasty Pinion +1; you're at the haste cap
		head = gear.empy_head, -- Mytha: Carmine Mask +1
		ear1 = "Etiolation Earring", -- Mytha: Enchntr. Earring +1
		ear2 = "Loquac. Earring",
		body = gear.relic_body,
		hands = "Pinga Mittens", -- Mytha: Leyline Gloves
		ring1 = "Naji's Loop", -- Mytha: Kishar Ring
		ring2 = "Prolix Ring",
		back = "Swith Cape",
		waist = "Witful Belt",
		legs = "Aya. Cosciales +2", -- Mytha: Psycloth Lappas
		feet = "Chelona Boots", -- Mytha: Carmine Greaves +1
	}

	gear.blue = {}

	-- Physical Spells --

	gear.blue.Physical = {
		ammo = "Mavi Tathlum",
		head = gear.empy_head, -- Mytha: Lilitu Headpiece
		neck = "Mirage Stole +2",
		ear1 = "Suppanomimi",
		ear2 = "Alabaster Earring", -- Mytha: Telos Earring
		body = "Jhakri Robe +2",
		hands = "Jhakri Cuffs +2",
		ring1 = "Murky Ring", -- Mytha: Ifrit Ring +1
		ring2 = "Lehko's Ring", -- Mytha: Ilabrat Ring
		back = gear.wsd_cape,
		waist = "Sailfi Belt +1", -- Mytha: Grunfeld Rope
		legs = "Jhakri Slops +2",
		feet = "Jhakri Pigaches +2",
	}

	gear.blue.Physical.Resistant = {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		head = "Jhakri Coronal +2",
		neck = "Mirage Stole +2",
		ear1 = "Alabaster Earring", -- Mytha: Telos Earring
		ear2 = gear.empy_ear, -- Mytha: Regal Earring
		body = gear.af_body,
		hands = gear.empy_hands, -- Mytha: Malignance Gloves
		ring1 = "Murky Ring", -- Mytha: Ramuh Ring +1
		ring2 = "Lehko's Ring", -- Mytha: Ramuh Ring +1
		back = gear.da_cape,
		waist = "Eschan Stone", -- Mytha: Grunfeld Rope
		legs = "Jhakri Slops +2",
		feet = "Jhakri Pigaches +2",
	}

	gear.blue.Physical.Fodder = set_combine(gear.blue_magic_skill, {
		ear1 = "Suppanomimi",
		ear2 = "Alabaster Earring", -- Mytha: Telos Earring
		hands = "Jhakri Cuffs +2",
		ring1 = "Murky Ring", -- Mytha: Ifrit Ring +1
		ring2 = "Lehko's Ring", -- Mytha: Ilabrat Ring
		waist = "Sailfi Belt +1", -- Mytha: Grunfeld Rope
	})

	gear.blue.PhysicalAcc = {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		head = "Jhakri Coronal +2",
		neck = "Mirage Stole +2",
		ear1 = "Alabaster Earring", -- Mytha: Telos Earring
		ear2 = gear.empy_ear, -- Mytha: Regal Earring
		body = gear.af_body,
		hands = "Jhakri Cuffs +2",
		ring1 = "Murky Ring", -- Mytha: Ramuh Ring +1
		ring2 = "Lehko's Ring", -- Mytha: Ilabrat Ring
		back = gear.da_cape,
		waist = "Eschan Stone", -- Mytha: Grunfeld Rope
		legs = "Jhakri Slops +2",
		feet = gear.empy_feet, -- Mytha: Malignance Boots
	}

	gear.blue.PhysicalAcc.Fodder = gear.blue.Physical.Fodder

	-- The stat-specific physical maps all use the Physical sets, as in Mytha's file.
	for _, map in ipairs({
		"PhysicalStr",
		"PhysicalDex",
		"PhysicalVit",
		"PhysicalAgi",
		"PhysicalInt",
		"PhysicalMnd",
		"PhysicalChr",
		"PhysicalHP",
	}) do
		gear.blue[map] = gear.blue.Physical
	end

	-- Magical Spells --

	gear.blue.Magical = {
		ammo = "Pemphredo Tathlum", -- Mytha: Ghastly Tathlum +1
		head = "Jhakri Coronal +2",
		neck = "Sibyl Scarf", -- Mytha: Baetyl Pendant
		ear1 = "Novio Earring", -- Mytha: Regal Earring
		ear2 = "Friomisi Earring",
		body = gear.empy_body, -- Mytha: Amalric Doublet +1
		hands = gear.empy_hands, -- Mytha: Amalric Gages +1
		ring1 = "Acumen Ring", -- Mytha: Metamor. Ring +1
		ring2 = "Jhakri Ring", -- Mytha: Shiva Ring +1
		back = gear.nuke_cape,
		waist = "Eschan Stone", -- Mytha: Hachirin-no-Obi (gear.ElementalObi), on matching weather or day
		legs = gear.relic_legs,
		feet = gear.empy_feet, -- Mytha: Amalric Nails +1
	}

	gear.blue.Magical.SIRD = {
		-- ammo: Mytha's Staunch Tathlum +1; nothing owned fits
		head = "Jhakri Coronal +2",
		neck = "Loricate Torque",
		ear1 = "Novio Earring", -- Mytha: Regal Earring
		ear2 = "Friomisi Earring",
		body = gear.empy_body, -- Mytha: Amalric Doublet +1
		hands = gear.empy_hands, -- Mytha: Rawhide Gloves
		ring1 = "Murky Ring", -- Mytha: Defending Ring
		ring2 = "Jhakri Ring", -- Mytha: Metamor. Ring +1
		back = gear.nuke_cape,
		waist = "Rumination Sash", -- Mytha: Emphatikos Rope
		legs = gear.carmine_legs,
		feet = gear.empy_feet, -- Mytha: Amalric Nails +1
	}

	gear.blue.Magical.Proc = {
		-- ammo: Mytha's Hasty Pinion +1; you're at the haste cap
		head = gear.amalric_head, -- Mytha: Carmine Mask +1
		ear1 = "Etiolation Earring", -- Mytha: Enchntr. Earring +1
		ear2 = "Loquac. Earring",
		body = gear.relic_body,
		hands = "Pinga Mittens", -- Mytha: Leyline Gloves
		ring1 = "Naji's Loop", -- Mytha: Kishar Ring
		ring2 = "Prolix Ring",
		back = "Swith Cape",
		waist = "Witful Belt",
		legs = "Aya. Cosciales +2", -- Mytha: Psycloth Lappas
		feet = "Chelona Boots", -- Mytha: Carmine Greaves +1
	}

	gear.blue.Magical.Resistant = set_combine(gear.blue.Magical, {
		neck = "Mirage Stole +2",
		hands = "Jhakri Cuffs +2",
		ring1 = "Stikini Ring", -- Mytha: Stikini Ring +1
		ring2 = "Stikini Ring", -- Mytha: Stikini Ring +1
		waist = "Eschan Stone", -- Mytha: Yamabuki-no-Obi
		feet = "Jhakri Pigaches +2",
	})

	-- Mytha's Fodder nuke set also swapped in Twilight Cape (gear.ElementalCape) on matching weather or
	-- day; Core doesn't check weather, so the nuke cape stays.
	gear.blue.Magical.Fodder = set_combine(gear.blue.Magical, { ammo = "Pemphredo Tathlum" })

	gear.blue.MagicalMnd = set_combine(gear.blue.Magical, { ring2 = "Stikini Ring" }) -- Mytha: Stikini Ring +1
	gear.blue.MagicalChr = gear.blue.Magical
	gear.blue.MagicalVit = gear.blue.Magical
	gear.blue.MagicalDex = gear.blue.Magical
	gear.blue.MagicalAgi = gear.blue.Magical

	gear.blue.Subduction = gear.blue.Magical

	gear.blue.MagicAccuracy = set_combine(gear.blue_magic_skill, {
		ammo = "Pemphredo Tathlum",
		head = gear.af_head,
		body = gear.empy_body, -- Mytha: Amalric Doublet +1
		hands = gear.empy_hands, -- Mytha: Malignance Gloves
		ring2 = "Stikini Ring", -- Mytha: Stikini Ring +1
		waist = "Eschan Stone", -- Mytha: Acuity Belt +1
		legs = gear.af_legs,
		feet = gear.empy_feet, -- Mytha: Malignance Boots
	})

	gear.blue.Magical.FullMacc = gear.blue.MagicAccuracy

	gear.cure = {
		-- ammo: Mytha's Staunch Tathlum +1; nothing owned fits
		head = "Nyame Helm",
		neck = "Loricate Torque",
		ear1 = "Alabaster Earring", -- Mytha: Regal Earring
		ear2 = "Mendi. Earring",
		body = gear.empy_body, -- Mytha: Vrikodara Jupon
		hands = "Telchine Gloves",
		ring1 = "Naji's Loop", -- Mytha: Janniston Ring
		ring2 = "Stikini Ring", -- Mytha: Menelaus's Ring
		back = "Solemnity Cape", -- Mytha: Moonlight Cape
		waist = "Rumination Sash", -- Mytha: Luminary Sash
		legs = gear.empy_legs, -- Mytha: Nyame Flanchard; Tayt +3 has more DT
		-- feet: Mytha's Medium's Sabots; nothing owned fits
	}

	gear.cursna = set_combine(gear.cure, {
		-- neck: Mytha's Debilis Medallion; nothing owned fits
		-- hands: Mytha's Hieros Mittens; nothing owned fits
		-- back: Mytha's Oretan. Cape +1; nothing owned fits
		-- ring1: Mytha's Haoma's Ring; nothing owned fits
		ring2 = "Stikini Ring", -- Mytha: Menelaus's Ring
		waist = "Witful Belt",
	})

	-- Breath Spells --

	gear.blue.Breath = set_combine(gear.blue_magic_skill, {
		hands = gear.relic_hands,
		-- ring1: Mytha's Kunaji Ring; Stikini Ring from the skill set
		ring2 = "Murky Ring", -- Mytha: Meridian Ring
	})

	-- Physical Added Effect Spells most notably "Stun" spells --

	gear.blue.Stun = {
		ammo = "Pemphredo Tathlum",
		head = gear.empy_head, -- Mytha: Malignance Chapeau
		neck = "Mirage Stole +2",
		ear1 = "Alabaster Earring", -- Mytha: Digni. Earring
		ear2 = gear.empy_ear, -- Mytha: Regal Earring
		body = gear.empy_body, -- Mytha: Malignance Tabard
		hands = gear.empy_hands, -- Mytha: Malignance Gloves
		ring1 = "Murky Ring", -- Mytha: Metamor. Ring +1
		ring2 = "Stikini Ring", -- Mytha: Stikini Ring +1
		back = gear.skill_cape,
		waist = "Eschan Stone", -- Mytha: Luminary Sash
		legs = gear.empy_legs, -- Mytha: Malignance Tights
		feet = gear.empy_feet, -- Mytha: Malignance Boots
	}

	gear.blue.Stun.Resistant = set_combine(gear.blue.Stun, {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		waist = "Eschan Stone", -- Mytha: Olseni Belt
	})

	-- Other Specific Spells --

	gear.blue.Healing = {
		-- ammo: Mytha's Staunch Tathlum +1; nothing owned fits
		head = "Nyame Helm",
		neck = "Loricate Torque",
		ear1 = "Mendi. Earring", -- Mytha: Tuisto Earring
		ear2 = "Alabaster Earring", -- Mytha: Odnowa Earring +1
		body = gear.empy_body, -- Mytha: Vrikodara Jupon
		hands = "Telchine Gloves",
		ring1 = "Naji's Loop", -- Mytha: Janniston Ring
		ring2 = "Stikini Ring", -- Mytha: Gelatinous Ring +1
		back = "Solemnity Cape", -- Mytha: Moonlight Cape
		waist = "Eschan Stone",
		-- legs: Mytha's Gyve Trousers; nothing owned fits
		-- feet: Mytha's Medium's Sabots; nothing owned fits
	}

	gear.blue.SkillBasedBuff = set_combine(gear.blue_magic_skill, {
		-- hands: Mytha's Rawhide Gloves; nothing owned fits
		ring2 = "Stikini Ring", -- Mytha: Stikini Ring +1
		waist = "Witful Belt",
	})

	gear.blue.Buff = {
		ammo = "Mavi Tathlum",
		head = gear.relic_head,
		neck = "Mirage Stole +2", -- Mytha: Incanter's Torque
		ear1 = "Etiolation Earring", -- Mytha: Gifted Earring
		ear2 = "Loquac. Earring",
		body = gear.af_body,
		hands = gear.empy_hands,
		ring1 = "Naji's Loop", -- Mytha: Kishar Ring
		ring2 = "Murky Ring", -- Mytha: Dark Ring
		back = "Solemnity Cape", -- Mytha: Aurist's Cape +1
		waist = "Witful Belt",
		legs = "Aya. Cosciales +2", -- Mytha: Lengo Pants
		feet = "Chelona Boots", -- Mytha: Carmine Greaves +1
	}

	gear.blue["Battery Charge"] = set_combine(gear.blue.Buff, {
		head = gear.amalric_head,
		-- back: Mytha's Grapevine Cape; nothing owned fits
		-- waist: Mytha's Gishdubar Sash; nothing owned fits
	})

	gear.blue["Carcharian Verve"] = set_combine(gear.blue.Buff, {
		head = gear.amalric_head,
		-- hands: Mytha's Regal Cuffs; nothing owned fits
		-- waist: Mytha's Emphatikos Rope; nothing owned fits
		-- legs: Mytha's Shedir Seraweels; nothing owned fits
	})

	-- Sets to return to when not performing an action.

	gear.resting = {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		head = "Rawhide Mask",
		neck = "Loricate Torque",
		ear1 = "Etiolation Earring",
		ear2 = "Alabaster Earring", -- Mytha: Ethereal Earring
		body = gear.empy_body, -- Mytha: Jhakri Robe +2; Mintan +3 has more refresh and DT
		hands = gear.empy_hands, -- Mytha: Herculean Gloves with a Refresh augment
		feet = "Nyame Sollerets", -- Mytha: Herculean Boots with a Refresh augment
		ring1 = "Murky Ring", -- Mytha: Defending Ring
		-- ring2: Mytha's Sheltered Ring; nothing owned fits
		back = gear.da_cape, -- Mytha: Bleating Mantle
		waist = "Flume Belt",
		legs = gear.empy_legs, -- Mytha: Lengo Pants
	}

	-- Your own idle set from Vanar_Blu_Gear.lua on the old branch.
	gear.idle = {
		ammo = "Pemphredo Tathlum",
		head = "Rawhide Mask",
		neck = "Sibyl Scarf",
		ear1 = "Alabaster Earring",
		ear2 = gear.empy_ear,
		body = gear.empy_body,
		hands = gear.empy_hands,
		ring1 = "Murky Ring",
		ring2 = "Lehko's Ring",
		back = gear.da_cape,
		waist = "Flume Belt",
		legs = gear.carmine_legs,
		feet = "Nyame Sollerets",
	}

	-- The idle set with DT in the three slots where it has none.
	gear.idle.PDT = set_combine(gear.idle, {
		head = "Nyame Helm",
		neck = "Loricate Torque",
		legs = gear.empy_legs,
	})

	-- Mytha's DTHippo added Hippo. Socks +1 to the PDT set; Carmine Cuisses +1 keep the movement speed.
	gear.idle.DTHippo = set_combine(gear.idle.PDT, { legs = gear.carmine_legs })

	-- Engaged sets

	gear.engaged = {
		ammo = "Coiste Bodhar", -- Mytha: Aurgelmir Orb +1
		head = gear.adhemar_head, -- Mytha: Dampening Tam
		neck = "Mirage Stole +2",
		ear1 = "Brutal Earring",
		ear2 = gear.empy_ear, -- Mytha: Cessance Earring
		body = gear.adhemar_body,
		hands = gear.adhemar_hands, -- Mytha: Adhemar Wrist. +1
		ring1 = "Rajas Ring", -- Mytha: Epona's Ring
		ring2 = "Lehko's Ring", -- Mytha: Petrov Ring
		back = gear.da_cape,
		waist = "Sailfi Belt +1", -- Mytha: Windbuffet Belt +1
		legs = gear.empy_legs,
		feet = "Nyame Sollerets", -- Mytha: Herculean Boots with a Triple Attack augment
	}

	gear.engaged.Acc = {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		head = gear.empy_head, -- Mytha: Dampening Tam
		neck = "Mirage Stole +2",
		ear1 = "Alabaster Earring", -- Mytha: Telos Earring
		ear2 = gear.empy_ear, -- Mytha: Cessance Earring
		body = gear.empy_body, -- Mytha: Malignance Tabard
		hands = gear.empy_hands, -- Mytha: Adhemar Wrist. +1
		ring1 = "Rajas Ring", -- Mytha: Epona's Ring
		ring2 = "Lehko's Ring", -- Mytha: Petrov Ring
		back = gear.da_cape,
		waist = "Sailfi Belt +1", -- Mytha: Windbuffet Belt +1
		legs = gear.carmine_legs,
		feet = gear.empy_feet, -- Mytha: Malignance Boots
	}

	gear.engaged.FullAcc = {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		head = gear.empy_head, -- Mytha: Carmine Mask +1
		neck = "Mirage Stole +2",
		ear1 = "Alabaster Earring", -- Mytha: Telos Earring
		ear2 = gear.empy_ear, -- Mytha: Mache Earring +1
		body = gear.af_body,
		hands = gear.af_hands,
		ring1 = "Murky Ring", -- Mytha: Ramuh Ring +1
		ring2 = "Lehko's Ring", -- Mytha: Ramuh Ring +1
		back = gear.da_cape,
		waist = "Eschan Stone", -- Mytha: Olseni Belt
		legs = gear.carmine_legs,
		feet = gear.empy_feet, -- Mytha: Malignance Boots
	}

	gear.engaged.Fodder = set_combine(gear.engaged, { ear1 = "Alabaster Earring" }) -- Mytha: Dedition Earring

	gear.engaged.DT = {
		ammo = "Coiste Bodhar", -- Mytha: Aurgelmir Orb +1
		head = "Nyame Helm", -- Mytha: Malignance Chapeau
		neck = "Loricate Torque",
		ear1 = "Suppanomimi",
		ear2 = "Brutal Earring",
		body = gear.empy_body, -- Mytha: Malignance Tabard
		hands = gear.empy_hands, -- Mytha: Malignance Gloves
		ring1 = "Murky Ring", -- Mytha: Defending Ring
		ring2 = "Lehko's Ring", -- Mytha: Petrov Ring
		back = gear.da_cape,
		waist = "Sailfi Belt +1", -- Mytha: Windbuffet Belt +1
		legs = gear.empy_legs, -- Mytha: Malignance Tights
		feet = "Nyame Sollerets", -- Mytha: Malignance Boots
	}

	gear.engaged.Acc.DT = set_combine(gear.engaged.DT, {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		ear1 = "Alabaster Earring", -- Mytha: Telos Earring
		ear2 = gear.empy_ear, -- Mytha: Cessance Earring
		ring2 = "Lehko's Ring", -- Mytha: Ilabrat Ring
		waist = "Eschan Stone", -- Mytha: Reiki Yotai
	})

	gear.engaged.FullAcc.DT = set_combine(gear.engaged.DT, {
		ammo = "Honed Tathlum", -- Mytha: Falcon Eye
		ear1 = "Alabaster Earring", -- Mytha: Odr Earring
		ear2 = gear.empy_ear, -- Mytha: Mache Earring +1
		ring2 = "Lehko's Ring", -- Mytha: Ramuh Ring +1
		waist = "Eschan Stone", -- Mytha: Reiki Yotai
	})

	gear.engaged.Fodder.DT =
		set_combine(gear.engaged.DT, { ear1 = "Brutal Earring", ear2 = gear.empy_ear, waist = "Sailfi Belt +1" }) -- Mytha: Cessance Earring, Reiki Yotai
end

function get_sets()
	init_gear()

	state.OffenseMode:options("Fodder", "Normal", "Acc", "FullAcc")
	state.HybridMode:options("Normal", "DT")
	state.CastingMode:options("Normal", "SIRD", "Resistant", "FullMacc", "Fodder", "Proc")
	state.IdleMode:options("Normal", "PDT", "DTHippo")
	state.Weapons:options("Tizbron", "Tizalmace", "Almace", "Maxbron", "Naegbron", "Naegmace", "None")
	-- gs c toggle LearningMode keeps sets.Learning on over everything.
	state.LearningMode = M(false, "Learning Mode")

	autows_list = {
		Tizbron = { { "Expiacion", 1000 }, { "Expiacion", "AM2" }, { "Expiacion", "AM3" } },
		Tizalmace = { { "Expiacion", 1000 }, { "Expiacion", "AM2" }, { "Expiacion", "AM3" } },
		Almace = { { "Chant du Cygne", 1000 } },
		Naegbron = { { "Savage Blade", 1000 } },
		Naegmace = { { "Savage Blade", 1000 }, { "Savage Blade", 1750 } },
	}

	autoth_list = { "Glutinous Dart" }

	-- The sets Core reads, defined in init_gear().
	sets.precast.JA = gear.ja
	sets.precast.Waltz = gear.waltz
	sets.precast.Step = gear.step
	sets.precast.Flourish1 = gear.flourish
	sets.precast.FC = gear.fc
	sets.precast.WS = gear.ws
	sets.MaxTP = gear.max_tp
	sets.AccMaxTP = gear.acc_max_tp
	sets.midcast.FastRecast = gear.fastrecast
	sets.midcast["Blue Magic"] = gear.blue
	sets.midcast.Cure = gear.cure
	sets.midcast.Cursna = gear.cursna
	sets.resting = gear.resting
	sets.idle = gear.idle
	sets.engaged = gear.engaged
	sets.weapons = gear.weapons
	sets.TreasureHunter = gear.treasure_hunter
	sets.buff = gear.buff
	sets.Learning = gear.learning
end

-- Job hooks

-- Macro book 2, page by sub job; lockstyle 25.
function job_post_job_change()
	local macroPages = { WAR = 2, NIN = 3, DNC = 4, RDM = 3 }
	send_command("@input /macro book 2;wait 1.1;input /macro set " .. (macroPages[player.sub_job] or 1))
	send_command("wait 5;input /lockstyleset 25")
end

-- Spells the game refuses without Unbridled Learning (Sel's list), and the ones worth a Diffusion.
local unbridled_spells = {
	["Absolute Terror"] = true,
	["Blistering Roar"] = true,
	["Bloodrake"] = true,
	["Carcharian Verve"] = true,
	["Cesspool"] = true,
	["Crashing Thunder"] = true,
	["Cruel Joke"] = true,
	["Droning Whirlwind"] = true,
	["Gates of Hades"] = true,
	["Harden Shell"] = true,
	["Mighty Guard"] = true,
	["Polar Roar"] = true,
	["Pyric Bulwark"] = true,
	["Tearing Gust"] = true,
	["Thunderbolt"] = true,
	["Tourbillion"] = true,
	["Uproot"] = true,
}
local diffusion_spells = { ["Mighty Guard"] = true }
local unbridled_learning_recast, diffusion_recast = 81, 184

local function ability_ready(recastId)
	return windower.ffxi.get_ability_recasts()[recastId] == 0
end

local function send_after(delay, command)
	send_command(delay > 0 and ("wait " .. delay .. ";" .. command) or command)
end

-- Uses Unbridled Learning, then Diffusion, ahead of a spell that wants them and re-casts the spell
-- after. Each step waits 1.1s for the last to resolve, as Core's weapon skill buffs do. Reads the
-- live buff and recast tables, so nothing goes stale across a job change.
function job_filter_precast(spell)
	if spell.skill ~= "Blue Magic" then
		return false
	end
	local needsUnbridled = unbridled_spells[spell.english]
		and not (buffactive["unbridled learning"] or buffactive["unbridled wisdom"])
	if needsUnbridled and not ability_ready(unbridled_learning_recast) then
		add_to_chat(123, spell.english .. " needs Unbridled Learning, which isn't ready")
		return true
	end
	local wantsDiffusion = diffusion_spells[spell.english]
		and not buffactive.diffusion
		and ability_ready(diffusion_recast)
	if not needsUnbridled and not wantsDiffusion then
		return false
	end

	local delay = 0
	if needsUnbridled then
		send_command('input /ja "Unbridled Learning" <me>')
		delay = 1.1
	end
	if wantsDiffusion then
		send_after(delay, 'input /ja "Diffusion" <me>')
		delay = delay + 1.1
	end
	send_after(delay, 'input /ma "' .. spell.english .. '" ' .. spell.target.raw)
	return true
end

local affinity_buffs = { "Burst Affinity", "Chain Affinity", "Convergence", "Diffusion", "Efflux" }

-- Moonshade Earring's TP Bonus is wasted once TP is capped; Thibron's own bonus counts toward that.
local function tp_capped()
	local weaponSet = sets.weapons[state.Weapons.value] or {}
	local bonus = (weaponSet.main == "Thibron" or weaponSet.sub == "Thibron") and 1000 or 0
	return player.tp + bonus >= 3000
end

local function ws_set_wears_moonshade(spell)
	local wsSet = sets.precast.WS[spell.english]
	if not wsSet then
		return false
	end
	wsSet = wsSet[state.OffenseMode.value] or wsSet
	return wsSet.ear1 == "Moonshade Earring" or wsSet.ear2 == "Moonshade Earring"
end

function job_post_precast(spell, spellMap)
	if spell.type == "WeaponSkill" and ws_set_wears_moonshade(spell) and tp_capped() then
		equip(state.OffenseMode.value:find("Acc") and sets.AccMaxTP or sets.MaxTP)
	end
	if state.LearningMode.value then
		equip(sets.Learning)
	end
end

function job_post_midcast(spell, spellMap)
	if spell.skill == "Blue Magic" then
		for _, buff in ipairs(affinity_buffs) do
			if buffactive[buff:lower()] then
				equip(sets.buff[buff])
			end
		end
	end
	if state.LearningMode.value then
		equip(sets.Learning)
	end
end

function job_customize_idle_set(idleSet)
	if state.LearningMode.value then
		return set_combine(idleSet, sets.Learning)
	end
	return idleSet
end

function job_customize_melee_set(meleeSet)
	if state.LearningMode.value then
		return set_combine(meleeSet, sets.Learning)
	end
	return meleeSet
end
