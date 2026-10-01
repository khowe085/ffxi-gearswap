-- Vanar's RDM, from Mytha_Rdm_Gear.lua on the old branch. Where Mytha's piece isn't owned, the
-- best owned piece for that set's job (per bg-wiki) stands in, with Mytha's piece noted beside it.
-- Murky Ring and Alabaster Earring are placed for their fully augmented Accuracy+15 / Magic Accuracy+15.
-- init_gear() defines every set on the gear table; get_sets() sets the modes and hands them to
-- Core.lua, which defines precast, midcast, aftercast, pet_midcast, pet_aftercast, status_change,
-- sub_job_change, self_command and file_unload. The job hooks at the bottom add RDM's own behavior.
-- Casting sets keep their weapons (Bunzi's Rod, Pukulatmuj +1, Ullr...): Core only locks main/sub/
-- range while you're engaged with a Weapons option other than None, so they swap while idle or with
-- None. Idle, engaged and weapon skill sets carry no weapons.
include("Core.lua")

local function init_gear()
	-- Artifact (no Atrophy Boots owned)
	gear.af_head = "Atro. Chapeau +4"
	gear.af_body = "Atrophy Tabard +4"
	gear.af_hands = "Atro. Gloves +4"
	gear.af_legs = "Atro. Tights +4"

	-- Relic (no Vitiation Tights owned)
	gear.relic_head = "Viti. Chapeau +4"
	gear.relic_body = "Viti. Tabard +4"
	gear.relic_hands = "Viti. Gloves +4"
	gear.relic_feet = "Viti. Boots +4"
	gear.relic_neck = "Dls. Torque +1"

	-- Empyrean
	gear.empy_head = "Leth. Chappel +3"
	gear.empy_body = "Lethargy Sayon +3"
	gear.empy_hands = "Leth. Ganth. +3"
	gear.empy_legs = "Leth. Fuseau +3"
	gear.empy_feet = "Leth. Houseaux +3"
	gear.empy_ear = "Leth. Earring +1"

	-- Ambuscade capes
	gear.da_cape = { name = "Sucellos's Cape", augments = { "DEX+20", "Accuracy+20 Attack+20", "Accuracy+10", '"Dbl.Atk."+10', "Damage taken-5%" } }
	gear.wsd_cape = { name = "Sucellos's Cape", augments = { "STR+20", "Accuracy+20 Attack+20", "STR+10", "Weapon skill damage +10%", "Damage taken-5%" } }
	gear.nuke_cape = { name = "Sucellos's Cape", augments = { "INT+20", "Mag. Acc+20 /Mag. Dmg.+20", "Mag. Acc.+10", '"Mag.Atk.Bns."+10' } }
	gear.mnd_cape = { name = "Sucellos's Cape", augments = { "MND+20", "Mag. Acc+20 /Mag. Dmg.+20", "Mag. Acc.+10", "Haste+10" } }
	gear.skill_cape = { name = "Ghostfyre Cape", augments = { "Enfb.mag. skill +8", "Enha.mag. skill +5", "Mag. Acc.+8", "Enh. Mag. eff. dur. +20" } }

	-- Augmented pieces
	gear.amalric_head = { name = "Amalric Coif +1", augments = { "INT+11", "Elem. magic skill +17", "Dark magic skill +17" } }
	gear.chironic_macc_legs = { name = "Chironic Hose", augments = { "Mag. Acc.+28", "MND+12" } }
	gear.telchine_duration_head = { name = "Telchine Cap", augments = { "Enh. Mag. eff. dur. +10" } }
	gear.telchine_duration_legs = { name = "Telchine Braconi", augments = { "Enh. Mag. eff. dur. +10" } }
	gear.telchine_regen_body = { name = "Telchine Chas.", augments = { '"Regen" potency+3' } }
	gear.telchine_regen_hands = { name = "Telchine Gloves", augments = { '"Regen" potency+3' } }
	gear.telchine_regen_feet = { name = "Telchine Pigaches", augments = { '"Regen" potency+3' } }
	gear.vanya_hands = { name = "Vanya Cuffs", augments = { "Healing magic skill +20", '"Cure" spellcasting time -7%', "Magic dmg. taken -3" } }
	gear.vanya_feet = { name = "Vanya Clogs", augments = { '"Cure" potency +5%', '"Cure" spellcasting time -15%', '"Conserve MP"+6' } }
	gear.carmine_legs = { name = "Carmine Cuisses +1", augments = { "Accuracy+20", "Attack+12", '"Dual Wield"+6' } }
	gear.colada_refresh = { name = "Colada", augments = { '"Refresh"+2', "Mag. Acc.+11", '"Mag.Atk.Bns."+12', "DMG:+1" } }

	-- Your skill pieces for each school, layered under the sets that lean on skill.

	gear.enhancing_skill = {
		main = "Pukulatmuj +1",
		sub = "Forfend +1",
		-- ammo: Mytha's Staunch Tathlum +1; nothing owned fits
		-- head: Mytha's Befouled Crown; nothing owned has Enhancing skill
		neck = "Enhancing Torque", -- Mytha: Incanter's Torque
		ear1 = "Andoaa Earring",
		ear2 = "Mimir Earring",
		body = gear.relic_body,
		hands = gear.relic_hands,
		ring1 = "Stikini Ring", -- Mytha: Stikini Ring +1
		ring2 = "Stikini Ring", -- Mytha: Stikini Ring +1
		back = "Fi Follet Cape +1",
		waist = "Olympus Sash",
		legs = gear.af_legs,
		feet = gear.empy_feet,
	}

	-- The duration-augmented Telchine Gloves lose to Atro. Gloves +4 here.
	gear.enhancing_duration = {
		sub = "Ammurapi Shield",
		head = gear.telchine_duration_head,
		neck = gear.relic_neck, -- Mytha: Dls. Torque +2
		ear2 = gear.empy_ear,
		body = gear.relic_body,
		hands = gear.af_hands,
		back = gear.skill_cape,
		waist = "Embla Sash",
		legs = gear.telchine_duration_legs,
		feet = gear.empy_feet,
	}

	gear.enfeebling_skill = {
		head = gear.relic_head,
		body = gear.af_body,
		hands = gear.empy_hands,
		ring1 = "Stikini Ring", -- Mytha: Stikini Ring +1
		ring2 = "Stikini Ring", -- Mytha: Stikini Ring +1
		back = gear.skill_cape,
		waist = "Obstin. Sash",
		legs = gear.chironic_macc_legs,
		feet = gear.relic_feet,
	}

	gear.elemental_skill = {
		head = gear.af_head,
		neck = "Aesir Torque",
		ring1 = "Stikini Ring",
		ring2 = "Stikini Ring",
	}

	gear.healing_skill = {
		body = gear.relic_body,
		hands = gear.vanya_hands,
		ring1 = "Stikini Ring",
		ring2 = "Stikini Ring",
		legs = gear.af_legs,
		feet = gear.vanya_feet,
	}

	gear.dark_skill = {
		head = gear.amalric_head,
		neck = "Aesir Torque",
		ring1 = "Stikini Ring",
		ring2 = "Stikini Ring",
	}

	-- Sets

	-- Single weapons pair with Ammurapi Shield; range = empty takes Ullr back off after a Resistant cast.
	gear.weapons = {}
	gear.weapons.Naegling = { main = "Naegling", sub = "Ammurapi Shield", range = empty }
	gear.weapons.Maxentius = { main = "Maxentius", sub = "Ammurapi Shield", range = empty }
	gear.weapons.Tauret = { main = "Tauret", sub = "Ammurapi Shield", range = empty }
	gear.weapons.EnspellOnly = { main = "Demers. Degen +1", sub = "Ammurapi Shield", range = empty }
	gear.weapons.DualWeapons = { main = "Naegling", sub = "Thibron", range = empty }
	gear.weapons.DualWeaponsAcc = { main = "Naegling", sub = "Almace", range = empty }
	gear.weapons.DualMaxentius = { main = "Maxentius", sub = "Thibron", range = empty }
	gear.weapons.DualMaxentiusAcc = { main = "Maxentius", sub = "Almace", range = empty }
	gear.weapons.DualAeolian = { main = "Tauret", sub = "Maxentius", range = empty }
	gear.weapons.DualProcSword = { main = "Demers. Degen +1", sub = "Tauret", range = empty }

	gear.treasure_hunter = {
		ammo = "Per. Lucky Egg",
		head = "Wh. Rarab Cap +1",
		body = "Volte Jupon",
		waist = "Chaac Belt",
	}

	-- Worn over an Enfeebling Magic midcast while Saboteur is up (job_post_midcast).
	gear.buff = {}
	gear.buff.Saboteur = { hands = gear.empy_hands }

	-- Worn over an Enhancing Magic midcast on someone else while Composure is up (job_post_midcast).
	-- Atrophy Gloves +4 beat Lethargy for duration even without the set bonus, as in Mytha's file.
	gear.buff.ComposureOther = {
		head = gear.empy_head,
		body = gear.empy_body,
		legs = gear.empy_legs,
		feet = gear.empy_feet,
	}

	-- Precast Sets

	gear.ja = {}
	gear.ja["Chainspell"] = { body = gear.relic_body }

	-- Steps (pure accuracy)
	gear.step = {
		ammo = "Ginsen", -- Mytha: Hasty Pinion +1
		head = gear.empy_head, -- Mytha: Malignance Chapeau
		neck = "Subtlety Spec.", -- Mytha: Null Loop
		ear1 = "Alabaster Earring", -- Mytha: Zennaroi Earring
		ear2 = gear.empy_ear, -- Mytha: Crepuscular Earring
		body = gear.empy_body, -- Mytha: Malignance Tabard
		hands = gear.empy_hands, -- Mytha: Malignance Gloves
		ring1 = "Murky Ring", -- Mytha: Cacoethic Ring +1
		ring2 = "Lehko's Ring", -- Mytha: Chirich Ring +1
		back = gear.da_cape, -- Mytha: Null Shawl
		waist = "Eschan Stone", -- Mytha: Null Belt
		legs = gear.empy_legs, -- Mytha: Malignance Tights
		feet = gear.empy_feet, -- Mytha: Malignance Boots
	}

	-- Violent Flourish (magic accuracy and accuracy)
	gear.flourish = {
		ammo = "Pemphredo Tathlum", -- Mytha: Regal Gem
		head = gear.empy_head,
		neck = gear.relic_neck, -- Mytha: Null Loop
		ear1 = "Alabaster Earring", -- Mytha: Malignance Earring
		ear2 = gear.empy_ear, -- Mytha: Crepuscular Earring
		body = gear.empy_body, -- Mytha: Malignance Tabard
		hands = gear.empy_hands,
		ring1 = "Stikini Ring", -- Mytha: Stikini Ring +1
		ring2 = "Stikini Ring", -- Mytha: Metamorph Ring +1
		back = gear.mnd_cape, -- Mytha: Null Shawl
		waist = "Eschan Stone", -- Mytha: Null Belt
		legs = gear.empy_legs,
		feet = gear.empy_feet,
	}

	-- Waltz set (chr and vit)
	gear.waltz = {}

	-- Don't need any special gear for Healing Waltz.
	gear.waltz["Healing Waltz"] = {}

	-- Fast cast sets for spells. Mytha's FC.DT was the same set, and FullFC / FC.Impact / FC.Dispelga
	-- need Grioavolr, Crepuscular Cloak and Daybreak, none owned (Impact and Dispelga can't be cast
	-- without the last two). Like Mytha's, this set fills the slots Fast Cast doesn't need with DT.
	gear.fc = {
		main = gear.colada_refresh, -- Mytha: Sakpata's Sword
		sub = "Ammurapi Shield", -- Mytha: Sacro Bulwark
		-- ammo: Mytha's Impatiens; quick magic unwanted
		head = gear.af_head, -- Mytha: Atrophy Chapeau +3
		-- neck: Mytha's Loricate Torque +1, dropped as filler
		ear1 = "Estq. Earring", -- Mytha: Malignance Earring
		ear2 = gear.empy_ear,
		body = gear.relic_body, -- Mytha: Viti. Tabard +3
		hands = gear.empy_hands, -- Mytha: Nyame Gauntlets; Ganth. +3 have more DT
		ring1 = "Murky Ring", -- Mytha: Defending Ring
		ring2 = "Prolix Ring", -- Mytha: Lebeche Ring
		back = "Swith Cape", -- Mytha: Perimede Cape
		waist = "Witful Belt",
		legs = "Nyame Flanchard",
		feet = "Chelona Boots", -- Mytha: Nyame Sollerets; keeps Fast Cast capped without the FC hands
	}

	-- Your old file's school-specific casting time pieces.
	gear.fc["Enfeebling Magic"] = set_combine(gear.fc, { head = gear.empy_head })
	gear.fc["Enhancing Magic"] = set_combine(gear.fc, { waist = "Siegel Sash" })
	gear.fc["Healing Magic"] = set_combine(gear.fc, { feet = gear.vanya_feet })

	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	gear.ws = {
		range = empty,
		ammo = "Oshasha's Treatise",
		head = gear.relic_head, -- Mytha: Viti. Chapeau +3
		neck = "Fotia Gorget",
		ear1 = "Moonshade Earring",
		ear2 = gear.empy_ear, -- Mytha: Sherida Earring
		body = "Nyame Mail",
		hands = gear.af_hands, -- Mytha: Jhakri Cuffs +2; +4 gloves have more WSD and MND
		ring1 = "Karieyh Ring", -- Mytha: Sroda Ring
		ring2 = "Epaminondas's Ring", -- Mytha: Cornelia's Ring
		back = gear.wsd_cape,
		waist = "Fotia Belt",
		legs = "Nyame Flanchard",
		feet = gear.empy_feet,
	}

	-- OffenseMode Proc: accuracy for Dynamis procs.
	gear.ws.Proc = gear.step

	-- Specific weaponskill sets. Uses the base set if an appropriate OffenseMode version isn't found.
	gear.ws["Requiescat"] = set_combine(gear.ws, {
		ammo = "Hydrocera", -- Mytha: Regal Gem
		body = gear.empy_body,
		hands = gear.empy_hands,
		ring1 = "Stikini Ring", -- Mytha: Stikini Ring +1
		ring2 = "Epaminondas's Ring", -- Mytha: Metamor. Ring +1
		back = gear.wsd_cape, -- Mytha: MND/WSD Sucellos's Cape
		legs = gear.empy_legs,
	})

	gear.ws["Chant du Cygne"] = set_combine(gear.ws, {
		ammo = "Coiste Bodhar",
		head = "Nyame Helm",
		ear1 = "Brutal Earring",
		ear2 = gear.empy_ear, -- Mytha: Sherida Earring
		-- body: Mytha's Malignance Tabard; Nyame Mail from the base set
		-- hands: Mytha's Malignance Gloves; Atro. Gloves +4 from the base set
		ring1 = "Epaminondas's Ring",
		ring2 = "Lehko's Ring", -- Mytha: Cornelia's Ring
	})

	gear.ws["Evisceration"] = gear.ws["Chant du Cygne"]

	gear.ws["Savage Blade"] = set_combine(gear.ws, {
		-- neck: Mytha's Rep. Plat. Medal; Fotia Gorget from the base set
		waist = "Sailfi Belt +1",
	})

	gear.ws["Black Halo"] = gear.ws["Savage Blade"] -- Mytha: MND/WSD Sucellos's Cape

	gear.ws["Sanguine Blade"] = set_combine(gear.ws, {
		ammo = "Pemphredo Tathlum", -- Mytha: Sroda Tathlum
		head = gear.empy_head,
		neck = "Sanctity Necklace", -- Mytha: Baetyl Pendant
		ear1 = "Friomisi Earring", -- Mytha: Malignance Earring
		ear2 = "Moonshade Earring",
		hands = gear.empy_hands,
		ring1 = "Epaminondas's Ring",
		ring2 = "Acumen Ring", -- Mytha: Cornelia's Ring
		back = gear.wsd_cape, -- Mytha: MND/WSD Sucellos's Cape
		waist = "Eschan Stone", -- Mytha: Orpheus's Sash
	})

	gear.ws["Seraph Blade"] = gear.ws["Sanguine Blade"]
	gear.ws["Shining Strike"] = gear.ws["Seraph Blade"]
	gear.ws["Flash Nova"] = gear.ws["Seraph Blade"]

	gear.ws["Aeolian Edge"] = set_combine(gear.ws, {
		ammo = "Pemphredo Tathlum", -- Mytha: Sroda Tathlum
		head = gear.empy_head,
		ear1 = "Friomisi Earring", -- Mytha: Malignance Earring
		ear2 = "Moonshade Earring",
		hands = "Jhakri Cuffs +2",
		ring1 = "Acumen Ring", -- Mytha: Freke Ring
		ring2 = "Epaminondas's Ring", -- Mytha: Cornelia's Ring
		back = gear.nuke_cape, -- Mytha: INT/WSD Sucellos's Cape
		waist = "Eschan Stone", -- Mytha: Orpheus's Sash
	})

	gear.ws["Red Lotus Blade"] = gear.ws["Aeolian Edge"]

	-- Swap these in for Moonshade Earring when TP is already capped (job_post_precast).
	gear.max_tp = { ear1 = "Brutal Earring", ear2 = gear.empy_ear }
	gear.acc_max_tp = { ear1 = "Alabaster Earring", ear2 = gear.empy_ear } -- Mytha: Telos Earring
	gear.magical_max_tp = { ear1 = "Friomisi Earring", ear2 = "Novio Earring" }

	-- Midcast Sets

	gear.fastrecast = {
		main = gear.colada_refresh, -- Mytha: Sakpata's Sword
		sub = "Ammurapi Shield", -- Mytha: Sacro Bulwark
		-- ammo: Mytha's Staunch Tathlum +1; nothing owned fits
		head = gear.af_head, -- Mytha: Atrophy Chapeau +3
		-- neck: Mytha's Loricate Torque +1, dropped as filler
		ear1 = "Alabaster Earring", -- Mytha: Malignance Earring
		ear2 = gear.empy_ear,
		body = gear.relic_body, -- Mytha: Viti. Tabard +3
		hands = "Bunzi's Gloves",
		ring1 = "Murky Ring", -- Mytha: Defending Ring
		ring2 = "Stikini Ring", -- Mytha: Freke Ring
		back = gear.mnd_cape,
		waist = "Rumination Sash", -- Mytha: Emphatikos Rope
		legs = "Bunzi's Pants",
		feet = "Nyame Sollerets", -- Mytha: Bunzi's Sabots
	}

	-- Healing Magic --
	-- Bunzi's Rod alone brings Cure potency near its cap, so the other slots are Mytha's picks or MND.

	gear.cure = set_combine(gear.healing_skill, {
		main = "Bunzi's Rod", -- Mytha: Daybreak
		sub = "Ammurapi Shield",
		range = empty,
		ammo = "Hydrocera", -- Mytha: Regal Gem
		head = gear.empy_head, -- Mytha: Vanya Hood
		neck = "Nodens Gorget", -- Mytha: Incanter's Torque
		ear1 = "Mendi. Earring", -- Mytha: Meili Earring
		ear2 = gear.empy_ear, -- Mytha: Mendi. Earring
		body = gear.empy_body, -- Mytha: Bunzi's Robe
		hands = "Telchine Gloves", -- Mytha: Gende. Gages +1
		ring1 = "Stikini Ring", -- Mytha: Sirona's Ring
		ring2 = "Naji's Loop", -- Mytha: Menelaus's Ring
		back = "Solemnity Cape", -- Mytha: MND Sucellos's Cape
		waist = "Rumination Sash", -- Mytha: Luminary Sash
		legs = gear.af_legs, -- Mytha: Atrophy Tights +3
		feet = gear.vanya_feet,
	})

	gear.cure.DT = set_combine(gear.cure, {
		-- ammo: Mytha's Staunch Tathlum +1; nothing owned fits
		head = gear.empy_head,
		-- neck: Mytha's Loricate Torque +1; Nodens Gorget from the Cure set
		ear1 = "Alabaster Earring", -- Mytha: Halasz Earring
		ear2 = "Mendi. Earring",
		hands = "Bunzi's Gloves", -- Mytha: Chironic Gloves with an Aspir augment
		ring1 = "Murky Ring", -- Mytha: Defending Ring
		ring2 = "Stikini Ring", -- Mytha: Freke Ring
		waist = "Rumination Sash", -- Mytha: Emphatikos Rope
		legs = "Bunzi's Pants",
		feet = "Nyame Sollerets", -- Mytha: Bunzi's Sabots
	})

	-- Mytha's Light-weather and Light-day cures swapped to Chatoyant Staff, Twilight Cape and
	-- Hachirin-no-Obi; Cure potency is capped without them.

	gear.cursna = set_combine(gear.healing_skill, {
		-- ammo: Mytha's Hasty Pinion +1; you're at the haste cap
		-- head: Mytha's Vanya Hood; nothing owned adds to Cursna
		-- neck: Mytha's Debilis Medallion; nothing owned fits
		ear1 = "Mendi. Earring", -- Mytha: Meili Earring
		ear2 = gear.empy_ear,
		-- hands: Mytha's Hieros Mittens; Vanya Cuffs from the skill set
		-- ring1: Mytha's Haoma's Ring; Stikini Ring from the skill set
		ring2 = "Naji's Loop", -- Mytha: Menelaus's Ring
		-- back: Mytha's Oretan. Cape +1; nothing owned fits
		waist = "Rumination Sash", -- Mytha: Bishop's Sash
	})

	-- Mytha's StatusRemoval set was FastRecast plus Grioavolr and Clemency Grip, neither owned, so
	-- the -na spells and Erase just use FastRecast.

	-- Enhancing Magic --
	-- Core wears FastRecast, then the spell's own set. job_post_midcast then layers the Enhancing set,
	-- Composure gear when the target is someone else, and the spell's set again on top, as Sel's RDM
	-- did, so a Refresh or Temper keeps its own pieces over the Composure ones.

	-- Mytha: Colada with an Enhancing duration augment in main, Kishar and Lebeche Rings.
	gear.enhancing = set_combine(gear.enhancing_skill, gear.enhancing_duration)

	gear.enhancing.Refresh = { head = gear.amalric_head, body = gear.af_body, legs = gear.empy_legs }
	gear.enhancing.Aquaveil = { head = gear.amalric_head } -- Mytha: Emphatikos Rope, Shedir Seraweels
	-- BarElement (Shedir Seraweels) and BarStatus (Sroda Necklace): nothing owned fits
	gear.enhancing.Temper = gear.enhancing_skill
	gear.enhancing.Enspell = gear.enhancing_skill
	-- Phalanx caps at 500 skill, so it keeps the duration-led base set (Mytha's Self_Phalanx was a Taeon
	-- set with Phalanx augments, not owned).
	gear.enhancing.BoostStat = { hands = gear.relic_hands }
	gear.enhancing.Stoneskin = { neck = "Nodens Gorget", waist = "Siegel Sash" }
	gear.enhancing.Regen = { body = gear.telchine_regen_body, hands = gear.telchine_regen_hands, feet = gear.telchine_regen_feet } -- Mytha: Bolelabunga
	-- Protect and Shell (Sheltered Ring): nothing owned fits

	-- Enfeebling Magic --

	gear.enfeebling = set_combine(gear.enfeebling_skill, {
		main = "Bunzi's Rod",
		sub = "Ammurapi Shield",
		range = empty,
		ammo = "Pemphredo Tathlum", -- Mytha: Regal Gem
		head = gear.empy_head,
		neck = gear.relic_neck, -- Mytha: Dls. Torque +2
		ear1 = "Snotra Earring", -- Mytha: Malignance Earring
		ear2 = gear.empy_ear, -- Mytha: Snotra Earring
		body = gear.empy_body,
		hands = gear.empy_hands,
		ring1 = "Stikini Ring", -- Mytha: Stikini Ring +1
		ring2 = "Stikini Ring", -- Mytha: Metamor. Ring +1
		back = gear.mnd_cape,
		waist = "Obstin. Sash",
		legs = gear.chironic_macc_legs,
		feet = gear.relic_feet, -- Mytha: Vitiation Boots +3
	})

	gear.enfeebling.Resistant = set_combine(gear.enfeebling, {
		range = "Ullr",
		ammo = empty,
		neck = gear.relic_neck, -- Mytha: Null Loop
		body = gear.af_body, -- Mytha: Atrophy Tabard +3
		back = gear.mnd_cape, -- Mytha: Null Shawl
		waist = "Obstin. Sash", -- Mytha: Null Belt
		feet = gear.empy_feet,
	})

	gear.enfeebling.Sleep = set_combine(gear.enfeebling, {
		range = "Ullr",
		ammo = empty,
		ring1 = "Stikini Ring", -- Mytha: Kishar Ring
		back = gear.nuke_cape, -- Mytha: Null Shawl; INT for Sleep's accuracy
		legs = gear.empy_legs,
		feet = gear.empy_feet,
	})

	gear.enfeebling.Sleep.Resistant = set_combine(gear.enfeebling.Resistant, {
		head = gear.af_head, -- Mytha: Atrophy Chapeau +3
	})

	gear.enfeebling.Bind = gear.enfeebling.Sleep
	gear.enfeebling.Break = gear.enfeebling.Sleep
	gear.enfeebling.Inundation = gear.enfeebling.Sleep
	-- Mytha's Dia and Bio wore Treasure Hunter gear; here AutoTHMode adds it (autoth_list).
	gear.enfeebling.Dia = gear.enfeebling.Sleep
	gear.enfeebling.Bio = gear.enfeebling.Sleep

	-- Mytha's Dispel set differed from the Resistant Sleep set only by the neck, and Null Loop's
	-- stand-in is already Dls. Torque +1.
	gear.enfeebling.Dispel = gear.enfeebling.Sleep.Resistant

	gear.enfeebling.Frazzle = set_combine(gear.enfeebling, {
		main = "Bunzi's Rod", -- Mytha: Daybreak
		legs = gear.empy_legs,
	})

	gear.enfeebling.Frazzle.Resistant = gear.enfeebling.Sleep.Resistant
	gear.enfeebling.Distract = gear.enfeebling.Frazzle
	gear.enfeebling["Frazzle II"] = gear.enfeebling.Frazzle.Resistant

	gear.enfeebling.Addle = set_combine(gear.enfeebling, {
		main = "Bunzi's Rod", -- Mytha: Daybreak
		head = gear.relic_head, -- Mytha: Viti. Chapeau +3
	})

	gear.enfeebling.Addle.Resistant = set_combine(gear.enfeebling.Resistant, {
		head = gear.relic_head, -- Mytha: Viti. Chapeau +3
		body = gear.empy_body,
	})

	gear.enfeebling.Paralyze = gear.enfeebling.Addle
	gear.enfeebling.Slow = gear.enfeebling.Addle

	gear.enfeebling.Gravity = set_combine(gear.enfeebling, {
		ring1 = "Stikini Ring", -- Mytha: Kishar Ring
		back = gear.nuke_cape, -- Mytha: INT Sucellos's Cape
		legs = gear.empy_legs,
		feet = gear.empy_feet,
	})

	gear.enfeebling.Gravity.Resistant = set_combine(gear.enfeebling.Resistant, {
		body = gear.empy_body,
		back = gear.nuke_cape, -- Mytha: INT Sucellos's Cape
	})

	gear.enfeebling.Poison = gear.enfeebling.Gravity
	gear.enfeebling.Blind = gear.enfeebling.Gravity

	gear.enfeebling.Silence = set_combine(gear.enfeebling, {
		main = "Bunzi's Rod", -- Mytha: Daybreak
		range = "Ullr",
		ammo = empty,
		ring1 = "Stikini Ring", -- Mytha: Kishar Ring
		back = gear.mnd_cape, -- Mytha: Null Shawl
		legs = gear.empy_legs,
		feet = gear.empy_feet,
	})

	gear.enfeebling.Silence.Resistant = gear.enfeebling.Sleep.Resistant

	-- Elemental Magic --

	gear.elemental = set_combine(gear.elemental_skill, {
		main = "Bunzi's Rod",
		sub = "Ammurapi Shield", -- Mytha: Culminus
		ammo = "Pemphredo Tathlum", -- Mytha: Ghastly Tathlum +1
		head = gear.empy_head,
		neck = "Sibyl Scarf", -- Mytha: Baetyl Pendant
		ear1 = "Friomisi Earring",
		ear2 = "Novio Earring", -- Mytha: Malignance Earring
		body = gear.empy_body,
		hands = gear.empy_hands,
		ring1 = "Acumen Ring", -- Mytha: Freke Ring
		ring2 = "Jhakri Ring", -- Mytha: Metamor. Ring +1
		back = gear.nuke_cape,
		waist = "Eschan Stone", -- Mytha: Sacro Cord
		legs = gear.empy_legs,
		feet = gear.empy_feet,
	})

	gear.elemental.DT = set_combine(gear.elemental, {
		-- ammo: Mytha's Staunch Tathlum +1; nothing owned fits
		-- neck: Mytha's Loricate Torque +1; Sibyl Scarf from the Elemental set
		waist = "Rumination Sash", -- Mytha: Emphatikos Rope
		legs = "Bunzi's Pants",
	})

	-- Atrophy Chapeau +4 and Aesir Torque out-accuracy the Lethargy head and Sibyl Scarf here once
	-- their Elemental skill counts.
	gear.elemental.Resistant = set_combine(gear.elemental, {
		range = "Ullr",
		ammo = empty,
		head = gear.af_head, -- Mytha: Leth. Chappel +3
		neck = "Aesir Torque", -- Mytha: Sibyl Scarf
		ear1 = "Alabaster Earring", -- Mytha: Malignance Earring
		ear2 = gear.empy_ear, -- Mytha: Friomisi Earring
		waist = "Obstin. Sash", -- Mytha: Acuity Belt +1
	})

	gear.elemental.Proc = set_combine(gear.enfeebling.Resistant, {
		main = "Gleti's Knife",
		sub = "Forfend +1",
		range = empty,
		ammo = "Pemphredo Tathlum", -- Mytha: Regal Gem
		ring1 = "Stikini Ring", -- Mytha: Kishar Ring
		ring2 = "Prolix Ring",
	})

	gear.elemental.HighTierNuke = set_combine(gear.elemental, {
		waist = "Obstin. Sash", -- Mytha: Acuity Belt +1
	})

	gear.elemental.HighTierNuke.Resistant = gear.elemental.Resistant

	-- Mytha's MagicBurst and RecoverMP sets need Sel's modes, and Impact needs Crepuscular Cloak.

	-- Dark Magic --

	gear.dark = set_combine(gear.dark_skill, {
		main = "Bunzi's Rod", -- Mytha: Daybreak
		sub = "Ammurapi Shield",
		range = empty,
		ammo = "Pemphredo Tathlum", -- Mytha: Regal Gem
		head = gear.empy_head,
		neck = gear.relic_neck, -- Mytha: Null Loop
		ear1 = "Alabaster Earring", -- Mytha: Malignance Earring
		ear2 = gear.empy_ear, -- Mytha: Snotra Earring
		body = gear.empy_body,
		hands = gear.empy_hands,
		ring1 = "Stikini Ring", -- Mytha: Stikini Ring +1
		ring2 = "Stikini Ring", -- Mytha: Metamor. Ring +1
		back = gear.mnd_cape, -- Mytha: Null Shawl
		waist = "Obstin. Sash", -- Mytha: Null Belt
		legs = gear.empy_legs,
		feet = gear.empy_feet,
	})

	-- Mytha's Pixie Hairpin +1, Chironic Aspir pieces and Evanescence Ring aren't owned; the Lethargy
	-- pieces carry the magic accuracy.
	gear.dark.Drain = set_combine(gear.dark, {
		back = gear.nuke_cape,
		waist = "Fucho-no-Obi",
	})

	gear.dark.Aspir = gear.dark.Drain

	gear.dark.Absorb = set_combine(gear.dark, {
		range = "Ullr",
		ammo = empty,
		head = gear.af_head, -- Mytha: Atrophy Chapeau +3
		body = gear.relic_body, -- Mytha: Viti. Tabard +3
	})

	gear.dark.Absorb.Resistant = set_combine(gear.dark.Absorb, { body = gear.empy_body })

	gear.dark.Stun = gear.dark.Absorb
	gear.dark.Stun.Resistant = gear.dark.Absorb.Resistant

	-- Sets to return to when not performing an action.

	gear.resting = {
		-- main and sub: Mytha's Chatoyant Staff and Oneiros Grip; weapons only through the Weapons option
		range = empty,
		-- ammo: Mytha's Impatiens; quick magic unwanted
		head = gear.relic_head, -- Mytha: Viti. Chapeau +3
		neck = "Sibyl Scarf", -- Mytha: Loricate Torque +1
		ear1 = "Alabaster Earring", -- Mytha: Etiolation Earring
		ear2 = gear.empy_ear, -- Mytha: Ethereal Earring
		body = gear.empy_body,
		hands = gear.empy_hands, -- Mytha: Merlinic Dastanas with a Refresh augment
		ring1 = "Murky Ring", -- Mytha: Defending Ring
		ring2 = "Stikini Ring", -- Mytha: Sheltered Ring
		back = gear.da_cape, -- Mytha: Null Shawl
		waist = "Fucho-no-Obi", -- Mytha: Null Belt
		legs = "Bunzi's Pants", -- Mytha: Merlinic Shalwar with a Refresh augment
		feet = "Chelona Boots", -- Mytha: Merlinic Crackows with a Refresh augment
	}

	gear.idle = {
		-- main and sub: Mytha's Mpaca's Staff and Oneiros Grip; weapons only through the Weapons option
		range = empty,
		-- ammo: Mytha's Homiliary; nothing owned fits
		head = gear.relic_head, -- Mytha: Viti. Chapeau +3
		neck = "Sibyl Scarf",
		ear1 = "Alabaster Earring", -- Mytha: Etiolation Earring
		ear2 = gear.empy_ear, -- Mytha: Ethereal Earring
		body = gear.empy_body,
		hands = gear.empy_hands, -- Mytha: Chironic Gloves with a Refresh augment
		ring1 = "Stikini Ring", -- Mytha: Stikini Ring +1
		ring2 = "Stikini Ring", -- Mytha: Stikini Ring +1
		back = gear.da_cape, -- Mytha: Null Shawl
		waist = "Fucho-no-Obi", -- Mytha: Null Belt
		legs = gear.carmine_legs, -- Mytha: Merlinic Shalwar with a Refresh augment
		feet = "Nyame Sollerets", -- Mytha: Merlinic Crackows with a Refresh augment
	}

	-- Chappel, Sayon and Ganth. +3 have more DT than the Nyame pieces Mytha wore; Mytha's Daybreak and
	-- Sacro Bulwark stay out with the other weapons.
	gear.idle.PDT = set_combine(gear.idle, {
		-- ammo: Mytha's Staunch Tathlum +1; nothing owned fits
		head = gear.empy_head, -- Mytha: Nyame Helm
		-- neck: Mytha's Loricate Torque +1; Sibyl Scarf from the idle set
		body = gear.empy_body, -- Mytha: Nyame Mail
		hands = gear.empy_hands, -- Mytha: Nyame Gauntlets
		ring1 = "Murky Ring", -- Mytha: Defending Ring
		-- ring2: Mytha's Shadow Ring; Stikini Ring from the idle set
		back = gear.da_cape, -- Mytha: Shadow Mantle
		waist = "Flume Belt", -- Mytha: Plat. Mog. Belt
		legs = "Nyame Flanchard",
		feet = "Nyame Sollerets",
	})

	-- Mytha's MEVA and Aminon sets differed from this one only by Null Shawl and Null Masque, neither
	-- owned.
	gear.idle.MDT = set_combine(gear.idle, {
		-- ammo: Mytha's Staunch Tathlum +1; nothing owned fits
		head = gear.empy_head, -- Mytha: Bunzi's Hat
		-- neck: Mytha's Warder's Charm +1; Sibyl Scarf from the idle set
		ear2 = gear.empy_ear, -- Mytha: Sanare Earring
		body = gear.empy_body, -- Mytha: Bunzi's Robe
		hands = "Bunzi's Gloves",
		ring1 = "Murky Ring", -- Mytha: Defending Ring
		-- ring2: Mytha's Shadow Ring; Stikini Ring from the idle set
		back = "Solemnity Cape", -- Mytha: Engulfer Cape +1
		waist = "Flume Belt", -- Mytha: Null Belt
		legs = "Bunzi's Pants",
		feet = "Nyame Sollerets", -- Mytha: Bunzi's Sabots
	})

	-- Engaged sets

	gear.engaged = {
		ammo = "Coiste Bodhar",
		head = "Nyame Helm", -- Mytha: Malignance Chapeau
		neck = "Sanctity Necklace", -- Mytha: Anu Torque
		ear1 = "Brutal Earring", -- Mytha: Sherida Earring
		ear2 = gear.empy_ear, -- Mytha: Dedition Earring
		body = "Nyame Mail", -- Mytha: Malignance Tabard
		hands = "Bunzi's Gloves", -- Mytha: Malignance Gloves
		ring1 = "Rajas Ring", -- Mytha: Chirich Ring +1
		ring2 = "Lehko's Ring", -- Mytha: Chirich Ring +1
		back = gear.da_cape, -- Mytha: Null Shawl
		waist = "Sailfi Belt +1", -- Mytha: Windbuffet Belt +1
		legs = "Nyame Flanchard", -- Mytha: Malignance Tights
		feet = "Nyame Sollerets", -- Mytha: Malignance Boots
	}

	gear.engaged.Acc = set_combine(gear.engaged, {
		head = gear.empy_head, -- Mytha: Malignance Chapeau
		neck = "Subtlety Spec.", -- Mytha: Null Loop
		ear1 = "Alabaster Earring", -- Mytha: Crep. Earring
		ear2 = gear.empy_ear, -- Mytha: Telos Earring
		body = gear.empy_body, -- Mytha: Malignance Tabard
		hands = gear.empy_hands, -- Mytha: Malignance Gloves
		ring1 = "Murky Ring", -- Mytha: Chirich Ring +1
		waist = "Kentarch Belt +1", -- Mytha: Null Belt
		legs = gear.empy_legs, -- Mytha: Malignance Tights
		feet = gear.empy_feet, -- Mytha: Malignance Boots
	})

	gear.engaged.DT = set_combine(gear.engaged, {
		-- neck: Mytha's Null Loop; Sanctity Necklace from the engaged set
		body = gear.empy_body, -- Mytha: Malignance Tabard
		hands = gear.empy_hands, -- Mytha: Malignance Gloves
		ring1 = "Murky Ring", -- Mytha: Defending Ring
	})

	gear.engaged.Acc.DT = set_combine(gear.engaged.DT, {
		neck = "Subtlety Spec.", -- Mytha: Null Loop
		ear1 = "Alabaster Earring", -- Mytha: Crep. Earring
		ear2 = gear.empy_ear, -- Mytha: Telos Earring
		waist = "Kentarch Belt +1", -- Mytha: Null Belt
	})

	-- Worn instead of the engaged set while the Weapons option is EnspellOnly (job_customize_melee_set).
	-- Mytha's Umuthi Hat, Sroda Tathlum and Orpheus's Sash aren't owned, and nothing owned adds enspell
	-- damage in the hands, so they come from the engaged sets.
	gear.engaged.EnspellOnly = set_combine(gear.engaged, {
		back = gear.skill_cape,
	})

	gear.engaged.EnspellOnly.Acc = set_combine(gear.engaged.Acc, {
		back = gear.skill_cape,
	})
end

function get_sets()
	init_gear()

	-- OffenseMode Proc only changes weapon skills (sets.precast.WS.Proc); melee falls back to Normal.
	state.OffenseMode:options("Normal", "Acc", "Proc")
	state.HybridMode:options("Normal", "DT")
	state.CastingMode:options("Normal", "Resistant", "Proc", "DT")
	state.IdleMode:options("Normal", "PDT", "MDT")
	state.Weapons:options(
		"None",
		"Naegling",
		"Maxentius",
		"Tauret",
		"EnspellOnly",
		"DualWeapons",
		"DualWeaponsAcc",
		"DualMaxentius",
		"DualMaxentiusAcc",
		"DualAeolian",
		"DualProcSword"
	)

	autows_list = {
		Naegling = { { "Savage Blade", 1750 } },
		Maxentius = { { "Black Halo", 1000 } },
		Tauret = { { "Aeolian Edge", 1000 } },
		DualWeapons = { { "Savage Blade", 1000 } },
		DualWeaponsAcc = { { "Savage Blade", 1000 } },
		DualMaxentius = { { "Black Halo", 1000 } },
		DualMaxentiusAcc = { { "Black Halo", 1000 } },
		DualAeolian = { { "Aeolian Edge", 1000 } },
	}

	autoth_list = { "Dia II", "Diaga II", "Bio II" }

	-- The sets Core reads, defined in init_gear().
	sets.precast.JA = gear.ja
	sets.precast.Waltz = gear.waltz
	sets.precast.Step = gear.step
	sets.precast.Flourish1 = gear.flourish
	sets.precast.FC = gear.fc
	sets.precast.WS = gear.ws
	sets.MaxTP = gear.max_tp
	sets.AccMaxTP = gear.acc_max_tp
	sets.MagicalMaxTP = gear.magical_max_tp
	sets.midcast.FastRecast = gear.fastrecast
	sets.midcast.Cure = gear.cure
	sets.midcast.Cursna = gear.cursna
	sets.midcast["Enhancing Magic"] = gear.enhancing
	sets.midcast["Enfeebling Magic"] = gear.enfeebling
	sets.midcast["Elemental Magic"] = gear.elemental
	sets.midcast["Dark Magic"] = gear.dark
	sets.resting = gear.resting
	sets.idle = gear.idle
	sets.engaged = gear.engaged
	sets.weapons = gear.weapons
	sets.TreasureHunter = gear.treasure_hunter
	sets.buff = gear.buff
end

-- Job hooks

-- Macro book 1, page by sub job; lockstyle by sub job.
function job_post_job_change()
	local macroPages = { SCH = 2, BLM = 3, DRK = 4, DNC = 5, NIN = 6 }
	send_command("@input /macro book 1;wait 1.1;input /macro set " .. (macroPages[player.sub_job] or 1))
	local lockstyles = { SCH = 21, NIN = 24, DNC = 24 }
	if lockstyles[player.sub_job] then
		send_command("wait 5;input /lockstyleset " .. lockstyles[player.sub_job])
	end
end

-- Convert fails with no MP to swap; Phalanx on someone else is always Phalanx II.
function job_filter_precast(spell)
	if spell.english == "Convert" and player.mp == 0 then
		add_to_chat(123, "Convert would fail with 0 MP")
		return true
	elseif spell.english == "Phalanx" and spell.target.type == "PLAYER" then
		send_command('input /ma "Phalanx II" ' .. spell.target.raw)
		return true
	end
	return false
end

local magical_weapon_skills = {
	["Red Lotus Blade"] = true,
	["Burning Blade"] = true,
	["Shining Blade"] = true,
	["Seraph Blade"] = true,
	["Sanguine Blade"] = true,
	["Frostbite"] = true,
	["Freezebite"] = true,
	["Cyclone"] = true,
	["Gust Slash"] = true,
	["Energy Drain"] = true,
	["Energy Steal"] = true,
	["Aeolian Edge"] = true,
	["Shining Strike"] = true,
	["Seraph Strike"] = true,
	["Starlight"] = true,
	["Moonlight"] = true,
	["Sunburst"] = true,
	["Flash Nova"] = true,
}

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
		if magical_weapon_skills[spell.english] then
			equip(sets.MagicalMaxTP)
		elseif state.OffenseMode.value:find("Acc") then
			equip(sets.AccMaxTP)
		else
			equip(sets.MaxTP)
		end
	end
end

function job_post_midcast(spell, spellMap)
	if spell.skill == "Enfeebling Magic" then
		if buffactive.saboteur then
			equip(sets.buff.Saboteur)
		end
	elseif spell.skill == "Enhancing Magic" then
		local enhancing = sets.midcast["Enhancing Magic"]
		equip(enhancing)
		if buffactive.composure and spell.target.type == "PLAYER" then
			equip(sets.buff.ComposureOther)
		end
		local spellSet = enhancing[spell.english] or enhancing[spellMap]
		if spellSet then
			equip(spellSet)
		end
	end
end

function job_customize_melee_set(meleeSet)
	if state.Weapons.value == "EnspellOnly" then
		local enspellSet = sets.engaged.EnspellOnly
		return enspellSet[state.OffenseMode.value] or enspellSet
	end
	return meleeSet
end
