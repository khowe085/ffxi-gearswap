-- Vanar's Blue Mage, built on the Rahvin GearSwap 2.1 sample (data/common/Sample Job Files/BLU.lua).
-- Every piece named here comes from Vanar's //gs export, data/export/Vanar_2026-09-27_18-24-29.lua.
-- Sets favor, in order: accuracy, magic accuracy, weapon skill damage, attack, magic attack and
-- damage taken. Hashi. Earring +1 is always in the right ear, the only ear its sword and blue magic
-- skill bonuses work in. At Master Level 25 sword skill is past 600, where each point adds 0.9 accuracy
-- and 1 attack, so Hashishin Kavuk +3's Sword skill 30 is worth about Acc 27 and Att 30, and Hashi.
-- Earring +1's Sword skill 11 about Acc 10 and Att 11.
-- data/Vanar/Vanar_gear_list.md lists every piece this file and RDM.lua use.

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Vanar's own copies. Library entries cover everything else. Augments are written exactly as
-- //gs export printed them, so each entry matches only that copy.
gear.rosmertaDA = hp_gear("Rosmerta's Cape", 0, {
	augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Damage taken-5%', } })   -- Acc 30, Att 20, DA 10, DT 5
gear.rosmertaWSD = hp_gear("Rosmerta's Cape", 0, {
	augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', } })               -- Acc 20, Att 20, WSD 10
gear.rosmertaCrit = hp_gear("Rosmerta's Cape", 0, {
	augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Crit.hit rate+9', } })                                 -- Acc 20, Att 20, Crit 9
gear.rosmertaMAB = hp_gear("Rosmerta's Cape", 0, {
	augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', '"Mag.Atk.Bns."+10', } })           -- Macc 30, MAB 10, MDmg 20
gear.telchineGlovesDuration = hp_gear("Telchine Gloves", 52, {
	augments = { 'Haste+3', 'Enh. Mag. eff. dur. +10', } })                                                 -- Enhancing duration 10, Cure 10
gear.cornflower = mp_gear("Cornflower Cape", 29)  -- Macc 15, MAB 15, Blue magic skill 15
gear.iris = rank_gear("Iris", 100)                -- Blue magic skill 30, Macc 15, MAB 29, Blue magic casting time -7%
gear.kentarchPlusOne = hp_gear("Kentarch Belt +1", 0) -- Acc 14, DA 3
gear.njordr = hp_gear("Njordr Earring", 0)        -- Blue magic skill 10
gear.honedTathlum = hp_gear("Honed Tathlum", 0)   -- Acc 15
gear.strendu = hp_gear("Strendu Ring", 0)         -- Macc 2, MAB 4
gear.whiteRarabCap = hp_gear("Wh. Rarab Cap +1", 0) -- Treasure Hunter 1
-- Two copies of one ring. They are only ever worn as a pair, which keeps GearSwap from pulling
-- the same copy into both slots. If one ever fails to equip, pin each to the bag it lives in,
-- for example hp_gear("Stikini Ring", 0, { bag = "wardrobe" }) and { bag = "wardrobe2" }.
gear.stikini1 = hp_gear("Stikini Ring", 0)        -- Macc 8, all magic skills 5
gear.stikini2 = hp_gear("Stikini Ring", 0)
gear.telchineBodyRegen = hp_gear("Telchine Chas.", 54, {
	augments = { '"Regen" potency+3', } })                                                                  -- Regen potency 3, Regen duration +12s, Enhancing skill 12
gear.telchineHandsRegen = hp_gear("Telchine Gloves", 52, {
	augments = { '"Regen" potency+3', } })                                                                  -- Regen potency 3
gear.telchineFeetRegen = hp_gear("Telchine Pigaches", 13, {
	augments = { '"Regen" potency+3', } })                                                                  -- Regen potency 3
gear.pukulatmujPlusOne = rank_gear("Pukulatmuj +1", 100) -- Enhancing skill 11, Stoneskin casting time -11%
gear.enhancingTorque = hp_gear("Enhancing Torque", 0)     -- Enhancing skill 7
gear.fiFolletPlusOne = mp_gear("Fi Follet Cape +1", 45, {
	augments = { 'Path: A', } })                                                                            -- Enhancing skill 9
gear.chelonaBoots = mp_gear("Chelona Boots", 35)         -- Fast Cast 4
gear.swithCape = hp_gear("Swith Cape", -20)              -- Fast Cast 3

-- The in-game lockstyle set, macro book and macro set this file applies on load.
LockStylePallet = "11"
MacroBook = "8"
MacroSet = "1"

-- The food "gs c food" uses.
Food = "Grape Daifuku"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List on each load, in place of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = {1,2,6,12}

-- Offense modes. Each one offered needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below.
state.OffenseMode:options('TP','ACC','DT')

-- The offense mode the file starts in.
state.OffenseMode:set('DT')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- Blue magic lists. Each blue spell takes the midcast set of the list that names it. The lists follow what a spell's damage or
-- effect scales with, since those do not share gear. The engine declares the same lists, and these copies replace them, so edit a list here to move a spell.
BluePhysical = S { 'Amorphic Spikes', 'Asuran Claws', 'Barbed Crescent', 'Battle Dance',
    'Benthic Typhoon', 'Bilgestorm', 'Bloodrake', 'Bludgeon', 'Body Slam', 'Cannonball',
    'Claw Cyclone', 'Death Scissors', 'Delta Thrust', 'Dimensional Death', 'Disseverment',
    'Empty Thrash', 'Feather Storm', 'Final Sting', 'Foot Kick', 'Frenetic Rip', 'Frypan',
    'Glutinous Dart', 'Goblin Rush', 'Grand Slam', 'Head Butt', 'Heavy Strike', 'Helldive',
    'Hydro Shot', 'Hysteric Barrage', 'Jet Stream', 'Mandibular Bite', 'Paralyzing Triad',
    'Pinecone Bomb', 'Power Attack', 'Quad. Continuum', 'Quadrastrike', 'Queasyshroom',
    'Ram Charge', 'Saurian Slide', 'Screwdriver', 'Seedspray', 'Sickle Slash', 'Sinker Drill',
    'Smite of Rage', 'Spinal Cleave', 'Spiral Spin', 'Sprout Smack', 'Sub-zero Smash',
    'Sudden Lunge', 'Sweeping Gouge', 'Tail Slap', 'Terror Touch', 'Thrashing Assault',
    'Tourbillion', 'Uppercut', 'Vanity Dive', 'Vertical Cleave', 'Whirl of Rage', 'Wild Oats' }
BlueBreath = S { 'Bad Breath', 'Flying Hip Press', 'Frost Breath', 'Heat Breath',
    'Hecatomb Wave', 'Magnetite Cloud', 'Poison Breath', 'Radiant Breath', 'Self-Destruct',
    'Thunder Breath', 'Vapor Spray', 'Wind Breath' }
BlueNuke = S { 'Acrid Stream', 'Anvil Lightning', 'Blastbomb', 'Blazing Bound',
    'Blinding Fulgor', 'Blitzstrahl', 'Bomb Toss', 'Cesspool', 'Charged Whisker',
    'Crashing Thunder', 'Cursed Sphere', 'Dark Orb', 'Death Ray', 'Diffusion Ray',
    'Droning Whirlwind', 'Embalming Earth', 'Entomb', 'Evryone. Grudge', 'Eyes On Me',
    'Firespit', 'Foul Waters', 'Gates of Hades', 'Ice Break', 'Leafstorm', 'Maelstrom',
    'Magic Hammer', 'Mind Blast', 'Molting Plumage', 'Mysterious Light', 'Nectarous Deluge',
    'Palling Salvo', 'Polar Roar', 'Rail Cannon', 'Regurgitation', 'Rending Deluge',
    'Retinal Glare', 'Scouring Spate', 'Searing Tempest', 'Silent Storm', 'Spectral Floe',
    'Subduction', 'Tearing Gust', 'Tem. Upheaval', 'Temporal Shift', 'Tenebral Crush',
    'Thermal Pulse', 'Thunderbolt', 'Uproot', 'Water Bomb' }
BlueSkill = S { 'Atra. Libations', 'Barrier Tusk', 'Diamondhide', 'Magic Barrier',
    'Metallic Body', 'Occultation', 'Plasma Charge', 'Pyric Bulwark', 'Reactor Cool' }
BlueBuff = S { 'Amplification', 'Animating Wail', 'Battery Charge', 'Carcharian Verve',
    'Cocoon', 'Erratic Flutter', 'Exuviation', 'Fantod', 'Feather Barrier', 'Harden Shell',
    'Memento Mori', 'Mighty Guard', 'Nat. Meditation', 'O. Counterstance', 'Refueling',
    'Regeneration', 'Saline Coat', 'Triumphant Roar', 'Warm-Up', 'Winds of Promy.',
    'Zephyr Mantle' }
BlueHealing = S { 'Healing Breeze', 'Magic Fruit', 'Plenilune Embrace', 'Pollen', 'Restoral',
    'Wild Carrot' }
BlueTank = S { 'Actinic Burst', 'Blank Gaze', 'Demoralizing Roar', 'Frightful Roar',
    'Geist Wall', 'Jettatura', 'Sheep Song', 'Soporific', 'Stinking Gas' }
BlueACC = S { '1000 Needles', 'Absolute Terror', 'Auroral Drape', 'Awful Eye',
    'Blistering Roar', 'Blood Drain', 'Blood Saber', 'Chaotic Eye', 'Cimicine Discharge',
    'Cold Wave', 'Corrosive Ooze', 'Cruel Joke', 'Digest', 'Dream Flower', 'Enervation',
    'Feather Tickle', 'Filamented Hold', 'Infrasonics', 'Light of Penance', 'Lowing',
    'MP Drainkiss', 'Mortal Ray', 'Osmosis', 'Reaving Wind', 'Sandspin', 'Sandspray',
    'Sound Blast', 'Venom Shell', 'Voracious Trunk', 'Yawn' }

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Naegling','Naegling Acc','Tizona','Tizona Acc','Almace','Black Halo','Magic')
state.WeaponMode:set('Naegling')

-- Auto weaponskill choices, keyed by the weapon modes above. gs c AutoWS (Alt+F9) cycles OFF and the
-- current weapon mode's choices. It starts OFF and goes back to OFF when the weapon mode changes.
-- 'AM2' and 'AM3' build that Aftermath level first, then fire at 1000 while it lasts.
AutoWS_List = {
	['Naegling'] = { { 'Savage Blade', 1000 } },
	['Naegling Acc'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 } },
	['Tizona'] = { { 'Expiacion', 1000 }, { 'Expiacion', 'AM2' }, { 'Expiacion', 'AM3' } },
	['Tizona Acc'] = { { 'Expiacion', 1000 }, { 'Expiacion', 'AM2' }, { 'Expiacion', 'AM3' } },
	['Almace'] = { { 'Chant du Cygne', 1000 } },
}

-- Naming JobMode shows it in chat and on the status box.
UI_Name = 'Mode'

-- Job mode. self_command_custom below loads the matching blue magic spell set and macro set when you cycle it.
state.JobMode:options('AoE','Melee')
state.JobMode:set('Melee')

function get_sets()

	-- Weapon sets, one per weapon mode. Thibron's TP Bonus +1000 backs every weapon skill mode, and the Acc
	-- modes trade it for Almace in the offhand, for more accuracy.
	sets.Weapons = {}

	sets.Weapons['Naegling'] = {	-- Savage Blade
		main = gear.naegling,
		sub = gear.thibron,
	}

	sets.Weapons['Naegling Acc'] = {	-- Savage Blade
		main = gear.naegling,
		sub = gear.almace,
	}

	sets.Weapons['Tizona'] = {		-- Expiacion
		main = gear.tizona,
		sub = gear.thibron,
	}

	sets.Weapons['Tizona Acc'] = {	-- Expiacion
		main = gear.tizona,
		sub = gear.almace,
	}

	sets.Weapons['Almace'] = {		-- Chant du Cygne
		main = gear.almace,
		sub = gear.thibron,
	}

	sets.Weapons['Black Halo'] = {	-- Black Halo
		main = gear.maxentius,
		sub = gear.thibron,
	}

	sets.Weapons['Magic'] = {		-- Nukes and AoE: Macc 55, MAB 64, Blue magic skill 30
		main = gear.bunzi,
		sub = gear.iris,
	}

	-- Worn whenever you are not engaged. It is also the floor under every action, so a slot an action's sets leave unnamed keeps its idle piece.
	sets.Idle = {
		ammo = gear.pemphredoTathlum,			-- Macc 8, MAB 4, Conserve MP 4
		head = gear.hashishinHeadPlusThree,		-- Magic evasion 125
		body = gear.hashishinBodyPlusThree,		-- DT 13, Refresh 4
		hands = gear.hashishinHandsPlusThree,	-- DT 10
		legs = gear.hashishinLegsPlusThree,		-- DT 12
		feet = gear.hashishinFeetPlusThree,		-- Magic evasion 157
		neck = gear.sanctity,					-- Regen 2
		waist = gear.platinumMoogleBelt,		-- DT 3, HP 10%
		left_ear = gear.alabaster,				-- DT 5, HP 100
		right_ear = gear.etiolation,			-- HP 50, MP 50
		left_ring = gear.karieyh,				-- Regain 5
		right_ring = gear.ayanmoRing,			-- DT 3
		back = gear.rosmertaDA,					-- DT 5
	}	-- DT 51. Damage taken caps at 50%, so the slots past the cap carry Regen, Regain, Refresh and HP instead.
	-- Idle sets for each offense mode, merged over the idle set.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})

	-- Worn over the idle set while a Phantom Roll on you stands at 11, for a ring such as Roller's Ring.
	sets.Idle.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathD,	-- Movement speed 18%
	}

	-- The ring slot Zodiac Ring goes in when an elemental spell matches the day: "right_ring" or "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set merges over it.
	-- Gear haste is 33% in every mode, past the 26% cap, so no piece here is picked for haste.
	sets.OffenseMode = {
		ammo = gear.coiste,							-- DA 3, STP 3
		head = gear.hashishinHeadPlusThree,			-- Acc 61, Att 61, Sword skill 30
		body = gear.hashishinBodyPlusThree,			-- Acc 64, Att 64, DT 13
		hands = gear.hashishinHandsPlusThree,		-- Acc 62, Att 62, DT 10
		legs = gear.hashishinLegsPlusThree,			-- Acc 63, Att 63, DT 12
		feet = gear.hashishinFeetPlusThree,			-- Acc 60, Att 60
		neck = gear.mirageStolePlusTwo,				-- Acc 25
		waist = gear.kentarchPlusOne,				-- Acc 14, DA 3
		left_ear = gear.brutal,						-- DA 5
		right_ear = gear.hashishinEarringPlusOne,	-- Acc 12, DA 4, Sword skill 11
		left_ring = gear.lehkoHabhokaRing,			-- STP 10, Crit 10
		right_ring = gear.eponas,					-- DA 3, TA 3
		back = gear.rosmertaDA,						-- Acc 30, Att 20, DA 10, DT 5
	}	-- Acc 391, Att 330, DT 40

	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {
		ammo = gear.honedTathlum,					-- Acc 15
		right_ring = gear.ayanmoRing,				-- Acc 6, DT 3
	})	-- Acc 412, DT 43

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		right_ring = gear.murky,					-- DT 10
	})	-- DT 50

	-- Fast cast, worn at the start of every spell. A Quick Magic proc finishes the spell before the midcast
	-- swap, so the spell lands in this set. Witful Belt is the only Quick Magic piece left, kept because it
	-- is the only waist with Fast Cast that BLU can wear.
	sets.Precast = {}
	sets.Precast.FastCast = {
		head = gear.amalricCoifPlusOne,		-- FC 11
		body = gear.luhlazaBodyPlusOne,		-- FC 7
		hands = gear.pingaHands,			-- FC 5
		legs = gear.ayanmoLegsPlusTwo,		-- FC 6
		waist = gear.witful,				-- FC 3, Quick Magic 3
		left_ear = gear.loquacious,			-- FC 2
		right_ear = gear.etiolation,		-- FC 1
		left_ring = gear.prolix,			-- FC 2
		back = gear.swithCape,				-- FC 3
		feet = gear.chelonaBoots,			-- FC 4
	}	-- FC 44. Ammo and neck keep the idle set's pieces.

	-- Merged over the fast-cast set for blue magic.
	sets.Precast.BlueMagic = set_combine(sets.Precast.FastCast, {
		body = gear.hashishinBodyPlusThree,	-- Blue magic casting time -16
	})

	-- Merged over the fast-cast set for every enhancing spell. Fast cast, casting time cuts and the Fast
	-- Cast trait add up to an 80% cap. The trait is 5 to 25% from set blue magic such as Erratic Flutter,
	-- or 15% from a RDM subjob, whichever is higher.
	sets.Precast.Enhancing = {
		waist = gear.siegel,				-- Enhancing magic casting time -8
	}	-- 49% from gear

	-- Stoneskin from a WHM or RDM subjob, over sets.Precast.Enhancing.
	sets.Precast["Stoneskin"] = {
		main = gear.pukulatmujPlusOne,		-- Stoneskin casting time -11
		legs = gear.doyenLegs,				-- Stoneskin casting time -10
	}	-- 64% from gear, so any Fast Cast trait of 16% or more reaches the cap

	-- Job abilities. sets.JA is worn for every job ability, and the set named for the ability merges over it.
	sets.JA = set_combine(sets.Idle, {})
	sets.JA["Azure Lore"] = {
		hands = gear.luhlazaHandsPlusOne,	-- Enhances Azure Lore
	}

	-- Dancer abilities from the subjob. Each family set is worn for its abilities, and a child named for the ability merges over it.
	sets.Flourish = set_combine(sets.Idle.DT, {})
	sets.Jig = set_combine(sets.Idle.DT, {})
	sets.Step = set_combine(sets.OffenseMode.ACC, {})
	sets.Samba = set_combine(sets.Idle.DT, {})
	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		body = gear.gletiBody,				-- Waltz potency 10
	})

	--The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Utsusemi from a NIN subjob keeps the idle set's DT.
	sets.Midcast.Utsusemi = set_combine(sets.Idle, {})

	-- Cure spells from a WHM or RDM subjob.
	sets.Midcast.Cure = set_combine(sets.Midcast, {
		hands = gear.telchineGlovesDuration,	-- Cure 10
		back = gear.solemnityCape,				-- Cure 7, DT 4
	})
	sets.Midcast.Curaga = set_combine(sets.Midcast.Cure, {})

	-- Enhancing magic from a subjob, built for duration first and recast second. Raise, Reraise and the
	-- -na spells take it too.
	sets.Midcast.Enhancing = set_combine(sets.Midcast, {
		head = gear.telchineCapBEnhDur,			-- Enhancing duration 10
		hands = gear.telchineGlovesDuration,	-- Enhancing duration 10
		legs = gear.telchineBraconiBEnhDur,		-- Enhancing duration 10
		left_ring = gear.prolix,				-- Fast Cast 2
	})
	sets.Midcast.Enhancing.Others = set_combine(sets.Midcast.Enhancing, {})

	-- A subjob's enhancing skill is far below the 500 where most enhancing spells stop gaining, so
	-- skill still raises potency here. The first-tier en-spells from a RDM subjob set their damage by
	-- the skill worn at the cast, and Phalanx's damage cut rises with skill too.
	sets.Midcast.Enhancing.Skill = set_combine(sets.Midcast.Enhancing, {
		main = gear.pukulatmujPlusOne,			-- Enhancing skill 11
		body = gear.telchineBodyRegen,			-- Enhancing skill 12
		legs = gear.carmineLegsPlusOnePathD,	-- Enhancing skill 18
		neck = gear.enhancingTorque,			-- Enhancing skill 7
		waist = gear.olympus,					-- Enhancing skill 5
		left_ear = gear.mimir,					-- Enhancing skill 10
		right_ear = gear.andoaaEarring,			-- Enhancing skill 5
		left_ring = gear.stikini1,				-- Enhancing skill 5
		right_ring = gear.stikini2,				-- Enhancing skill 5
		back = gear.fiFolletPlusOne,			-- Enhancing skill 9
	})	-- Enhancing skill +87
	sets.Midcast.Enhancing.Elemental = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.Enhancing.Status = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.Phalanx = set_combine(sets.Midcast.Enhancing.Skill, {})

	-- Regen and Refresh put potency first, then duration, then recast.
	sets.Midcast.Regen = {
		body = gear.telchineBodyRegen,			-- Regen potency 3, Regen duration +12s
		hands = gear.telchineHandsRegen,		-- Regen potency 3
		feet = gear.telchineFeetRegen,			-- Regen potency 3
	}
	sets.Midcast.Refresh = {
		head = gear.amalricCoifPlusOne,			-- Refresh potency +2
	}

	-- Blue magic. Each spell takes the one subfamily set its list above names, unless it has a set of its own. The engine never wears sets.Midcast.BlueMagic itself.
	sets.Midcast.BlueMagic = {}

	-- Physical spells: accuracy and attack. Kavuk +3 adds Chain Affinity and Tayt +3 adds Efflux TP Bonus,
	-- and all five Hashishin +3 pieces together occasionally augment blue magic.
	sets.Midcast.BlueMagic.Physical = {
		ammo = gear.coiste,							-- Att 15, STR 10, DEX 10 (Path A)
		head = gear.hashishinHeadPlusThree,			-- Acc 61, Att 61
		body = gear.hashishinBodyPlusThree,			-- Acc 64, Att 64
		hands = gear.hashishinHandsPlusThree,		-- Acc 62, Att 62
		legs = gear.hashishinLegsPlusThree,			-- Acc 63, Att 63
		feet = gear.hashishinFeetPlusThree,			-- Acc 60, Att 60
		neck = gear.mirageStolePlusTwo,				-- Acc 25
		waist = gear.eschan,						-- Acc 15, Att 15
		left_ear = gear.moonshade,					-- Att 4, TP Bonus 250 for Efflux
		right_ear = gear.hashishinEarringPlusOne,	-- Acc 12
		left_ring = gear.jhakriRing,				-- Acc 6, Att 6
		right_ring = gear.ayanmoRing,				-- Acc 6
		back = gear.rosmertaWSD,					-- Acc 20, Att 20, STR 30
	}

	-- Magical spells: magic accuracy, magic attack and blue magic skill. Basmak +3 adds Burst Affinity.
	sets.Midcast.BlueMagic.Nuke = {
		ammo = gear.pemphredoTathlum,				-- Macc 8, MAB 4
		head = gear.hashishinHeadPlusThree,			-- Macc 61, MAB 51
		body = gear.hashishinBodyPlusThree,			-- Macc 64, MAB 54
		hands = gear.hashishinHandsPlusThree,		-- Macc 62, MAB 57
		legs = gear.hashishinLegsPlusThree,			-- Macc 63, MAB 53, Blue magic skill 33
		feet = gear.hashishinFeetPlusThree,			-- Macc 60, MAB 55, Magic burst damage 15
		neck = gear.mirageStolePlusTwo,				-- Macc 25, Blue magic skill 20
		waist = gear.eschan,						-- Macc 7, MAB 7
		left_ear = gear.friomisi,					-- MAB 10
		right_ear = gear.hashishinEarringPlusOne,	-- Macc 12, Blue magic skill 11
		left_ring = gear.jhakriRing,				-- Macc 6, MAB 3
		right_ring = gear.strendu,					-- Macc 2, MAB 4
		back = gear.rosmertaMAB,					-- Macc 30, MAB 10, MDmg 20
	}

	-- Debuffs that only need to land: magic accuracy and blue magic skill.
	sets.Midcast.BlueMagic.ACC = {
		ammo = gear.pemphredoTathlum,				-- Macc 8
		head = gear.hashishinHeadPlusThree,			-- Macc 61
		body = gear.assimilatorBodyPlusFour,		-- Macc 60, Blue magic skill 25
		hands = gear.hashishinHandsPlusThree,		-- Macc 62
		legs = gear.hashishinLegsPlusThree,			-- Macc 63, Blue magic skill 33
		feet = gear.hashishinFeetPlusThree,			-- Macc 60
		neck = gear.mirageStolePlusTwo,				-- Macc 25, Blue magic skill 20
		waist = gear.eschan,						-- Macc 7
		left_ear = gear.njordr,						-- Blue magic skill 10
		right_ear = gear.hashishinEarringPlusOne,	-- Macc 12, Blue magic skill 11
		left_ring = gear.stikini1,					-- Macc 8, skill 5
		right_ring = gear.stikini2,					-- Macc 8, skill 5
		back = gear.rosmertaMAB,					-- Macc 30
	}

	-- Spells whose potency scales with blue magic skill, such as Occultation, Magic Barrier and Barrier Tusk.
	sets.Midcast.BlueMagic.Skill = set_combine(sets.Midcast, {
		body = gear.assimilatorBodyPlusFour,		-- Blue magic skill 25
		legs = gear.hashishinLegsPlusThree,			-- Blue magic skill 33
		feet = gear.luhlazaFeetPlusOne,				-- Blue magic skill 8
		neck = gear.mirageStolePlusTwo,				-- Blue magic skill 20
		left_ear = gear.njordr,						-- Blue magic skill 10
		right_ear = gear.hashishinEarringPlusOne,	-- Blue magic skill 11
		left_ring = gear.stikini1,					-- Blue magic skill 5
		right_ring = gear.stikini2,					-- Blue magic skill 5
		back = gear.cornflower,						-- Blue magic skill 15
	})

	-- Breath spells scale with your HP, and Bad Breath and Magnetite Cloud still need to land.
	sets.Midcast.BlueMagic.Breath = set_combine(sets.Midcast.BlueMagic.ACC, {
		head = gear.nyameHead,						-- HP 91, Macc 40
		body = gear.nyameBody,						-- HP 136, Macc 40
		legs = gear.nyameLegs,						-- HP 114, Macc 40
		feet = gear.nyameFeet,						-- HP 68, Macc 40
		left_ear = gear.alabaster,					-- HP 100
	})

	-- Fixed-potency buffs keep the idle set's DT. Enmity spells such as Jettatura and Geist Wall need to land.
	sets.Midcast.BlueMagic.Buff = set_combine(sets.Midcast, {})
	sets.Midcast.BlueMagic.Enmity = set_combine(sets.Midcast.BlueMagic.ACC, {})
	sets.Midcast.BlueMagic.Healing = set_combine(sets.Midcast.BlueMagic.Skill, {
		hands = gear.telchineGlovesDuration,		-- Cure 10
		back = gear.solemnityCape,					-- Cure 7
	})

	-- Magic from a subjob: nukes take the blue nuke set, and enfeebles, dark and divine magic the accuracy set.
	sets.Midcast.Nuke = set_combine(sets.Midcast.BlueMagic.Nuke, {})
	sets.Midcast.Burst = set_combine(sets.Midcast.BlueMagic.Nuke, {})
	sets.Midcast.Enfeebling = set_combine(sets.Midcast.BlueMagic.ACC, {})
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Duration = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Aspir = set_combine(sets.Midcast.BlueMagic.ACC, {})
	sets.Midcast.Drain = set_combine(sets.Midcast.BlueMagic.ACC, {})
	sets.Midcast.Divine = set_combine(sets.Midcast.BlueMagic.ACC, {})

	-- Sets named for one spell. Each replaces the family set for that spell.

	-- White Wind heals floor(MaxHP/7)*2, raised by cure potency, so this is max HP plus cure potency.
	sets.Midcast["White Wind"] = {
		head = gear.nyameHead,					-- HP 91
		body = gear.nyameBody,					-- HP 136
		hands = gear.telchineGlovesDuration,	-- Cure 10
		legs = gear.nyameLegs,					-- HP 114
		feet = gear.nyameFeet,					-- HP 68
		neck = gear.sanctity,					-- HP 35
		waist = gear.platinumMoogleBelt,		-- HP 10%
		left_ear = gear.alabaster,				-- HP 100
		right_ear = gear.etiolation,			-- HP 50
		back = gear.solemnityCape,				-- Cure 7
	}

	-- Stoneskin absorbs enhancing skill + 3 x MND - 190, up to 350, which Blue Mage's MND reaches even at
	-- a subjob's skill. Stoneskin+ gear goes past that cap.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		waist = gear.siegel,					-- Stoneskin +20
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		head = gear.amalricCoifPlusOne,			-- Aquaveil +2
	})

	-- Weaponskill base, the weapon skill damage set. Savage Blade, Expiacion and Black Halo wear it as it is.
	-- It follows bg-wiki's simulated Savage Blade and Expiacion sets (All Jobs Gear Sets/Blue Mage). Jhakri
	-- Cuffs +2 stand in for its Path B Nyame Gauntlets (WSD 11, DA 5), since Vanar's have no path, Hashi.
	-- Earring +1 for Hoxne Earring and Karieyh Ring for Beithir Ring. Nyame values are Path B at rank 20.
	sets.WS = {
		ammo = gear.coiste,							-- Att 15, STR 10, DEX 10, DA 3 (Path A)
		head = gear.hashishinHeadPlusThree,			-- WSD 12, Acc 61, Att 61, Sword skill 30
		body = gear.nyameBody,						-- WSD 13, DA 7, Acc 40, Att 65
		hands = gear.jhakriHandsPlusTwo,			-- WSD 7, Acc 43, Att 43
		legs = gear.nyameLegs,						-- WSD 12, DA 6, Acc 40, Att 65
		feet = gear.nyameFeet,						-- WSD 11, DA 5, Acc 53, Att 65
		neck = gear.mirageStolePlusTwo,				-- STR 25, DEX 25 (Path A), Acc 25
		waist = gear.sailfi,
		left_ear = gear.moonshade,					-- TP Bonus 250
		right_ear = gear.hashishinEarringPlusOne,	-- Acc 12, Sword skill 11
		left_ring = gear.epimanondas,				-- WSD 5
		right_ring = gear.karieyh,					-- WSD 3, WS Acc 5
		back = gear.rosmertaWSD,					-- WSD 10, Acc 20, Att 20
	}

	-- Merged in ACC mode after the set named for the weaponskill, so its slots win. A weaponskill with an ACC set of its own skips it.
	-- The feet stay: Nyame Sollerets (Path B) already have Acc 53, and Hashishin Basmak +3 would trade WSD 11 for 7 more.
	sets.WS.ACC = {
		hands = gear.hashishinHandsPlusThree,		-- Acc 62
		waist = gear.kentarchPlusOne,				-- Acc 14
	}

	-- MAB is not an offense mode. It is the shared table for the magical weaponskills below.
	sets.WS.MAB = {
		ammo = gear.pemphredoTathlum,				-- Macc 8, MAB 4
		head = gear.hashishinHeadPlusThree,			-- WSD 12, MAB 51
		body = gear.nyameBody,						-- WSD 13 (Path B), MAB 30
		hands = gear.jhakriHandsPlusTwo,			-- WSD 7, MAB 40
		legs = gear.luhlazaLegsPlusFour,			-- WSD 12, MAB 60
		feet = gear.hashishinFeetPlusThree,			-- MAB 55
		neck = gear.sanctity,						-- Macc 10, MAB 10
		waist = gear.eschan,						-- Macc 7, MAB 7
		left_ear = gear.friomisi,					-- MAB 10
		right_ear = gear.hashishinEarringPlusOne,	-- Macc 12
		left_ring = gear.epimanondas,				-- WSD 5
		right_ring = gear.jhakriRing,				-- Macc 6, MAB 3
		back = gear.rosmertaMAB,					-- Macc 30, MAB 10, MDmg 20
	}

	sets.WS['Sanguine Blade'] = set_combine(sets.WS.MAB, {})

	-- These magical weaponskills gain damage with TP, so the TP Bonus earring goes back in.
	sets.WS['Seraph Blade'] = set_combine(sets.WS.MAB, { left_ear = gear.moonshade })
	sets.WS['Red Lotus Blade'] = set_combine(sets.WS.MAB, { left_ear = gear.moonshade })
	sets.WS['Flash Nova'] = set_combine(sets.WS.MAB, { left_ear = gear.moonshade })

	-- In ACC mode these magical weaponskills raise magic accuracy instead of taking sets.WS.ACC, whose
	-- Kentarch Belt +1 would replace Eschan Stone's Macc and MAB. Hashishin Bazubands +3 trade Jhakri
	-- Cuffs +2's WSD 7 for Macc 19 and MAB 17 more.
	for _, ws in ipairs({ 'Sanguine Blade', 'Seraph Blade', 'Red Lotus Blade', 'Flash Nova' }) do
		sets.WS[ws].ACC = set_combine(sets.WS[ws], { hands = gear.hashishinHandsPlusThree })
	end

	-- Chant du Cygne: DEX and critical hit rate, which rises with TP. It follows bg-wiki's set, with Lehko's
	-- Ring for Begrudging Ring and Hashi. Earring +1 for Hoxne Earring. The head is Hashishin Kavuk +3, not
	-- Adhemar Bonnet: with its sword skill it adds about Acc 88, Att 91 and WSD 12 (first hit), where the
	-- Bonnet adds Att 41, TA 3 and Crit damage 5.
	sets.WS['Chant du Cygne'] = {
		ammo = gear.coiste,
		head = gear.hashishinHeadPlusThree,			-- WSD 12, Acc 61, Att 61, Sword skill 30
		body = gear.gletiBody,						-- Crit 8, Acc 40, Att 40
		hands = gear.gletiHands,					-- Crit 6, Acc 40, Att 40
		legs = gear.gletiLegs,						-- Crit 7, Acc 40, Att 40
		feet = gear.gletiFeet,						-- Crit 4, Acc 40, Att 40
		neck = gear.mirageStolePlusTwo,				-- DEX 25, Crit 5 (Path A), Acc 25
		waist = gear.fotiaWaist,
		left_ear = gear.moonshade,					-- TP Bonus 250
		right_ear = gear.hashishinEarringPlusOne,	-- Acc 12, Sword skill 11
		left_ring = gear.lehkoHabhokaRing,			-- Crit 10
		right_ring = gear.eponas,					-- DA 3, TA 3
		back = gear.rosmertaCrit,					-- Crit 9, Acc 20, Att 20
	}

	-- Requiescat: five MND hits, so accuracy and multi-attack over weapon skill damage.
	sets.WS['Requiescat'] = {
		ammo = gear.coiste,
		head = gear.hashishinHeadPlusThree,			-- Acc 61, Sword skill 30
		body = gear.hashishinBodyPlusThree,			-- Acc 64
		hands = gear.hashishinHandsPlusThree,		-- Acc 62
		legs = gear.hashishinLegsPlusThree,			-- Acc 63
		feet = gear.hashishinFeetPlusThree,			-- Acc 60
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ear = gear.moonshade,
		right_ear = gear.hashishinEarringPlusOne,	-- Acc 12, Sword skill 11
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.eponas,
		back = gear.rosmertaDA,						-- Acc 30, DA 10
	}

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and throughout a fight in Full Time mode. It is never worn in None mode, where every job but Thief starts.
	sets.TreasureHunter = {
		ammo = gear.perfectEgg,		-- TH 1
		head = gear.whiteRarabCap,	-- TH 1
		body = gear.volteJupon,		-- TH 2
		waist = gear.chaac,			-- TH 1
	}

	-- Merged over the blue magic set while Diffusion is up. A spell with a set of its own above does not take it.
	sets.Diffusion = {
		feet = gear.luhlazaFeetPlusOne,	-- Enhances Diffusion
	}

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's subjob changes.
function sub_job_change_custom(new, old)
	-- A common use is switching the macro book or set.
end

-- Called before each action, after the engine's own checks. Cancel the action here with cancel_spell(). Nothing it returns is used.
function pretarget_custom(spell,action)

end
-- Gear returned here merges over the engine's precast set for the action.
function precast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Gear returned here merges over the engine's midcast set for the action.
function midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Gear returned here merges over the idle or engaged set worn when an action ends.
function aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Called when a buff is gained or lost, except while an action is in flight. Gear returned here merges over the idle or engaged set.
function buff_change_custom(name,gain)
	local equipSet = {}

	return equipSet
end
-- Gear returned here merges over every idle and engaged build: after each action, on a buff, status or mode change, and when you start or stop moving.
function choose_set_custom()
	local equipSet = {}

	return equipSet
end
-- Called when your status changes, such as engaging, disengaging or resting. Gear returned here merges over the idle or engaged set that follows.
function status_change_custom(new,old)
	local equipSet = {}

	return equipSet
end
-- Called for a "gs c" command the engine does not handle itself, and for the weapon mode, job mode and job mode 2 commands, which call it before the gear rebuild. The command arrives in lowercase.
-- Here, a job mode change, by key, by gs c jobmode or by gs c jobmode AoE, loads the matching AzureSets spell set, magic for AoE and tp for Melee, and switches the macro set to match.
-- Testing the first word keeps jobmode2 and other commands that merely contain jobmode from triggering it.
function self_command_custom(command)
	if command:match('^(%S+)') == 'jobmode' then
		if state.JobMode.value == 'AoE' then
			send_command('input //aset spellset magic;input /macro book '..MacroBook..';wait .1; input /macro set 2')
		else
			send_command('input //aset spellset tp;input /macro book '..MacroBook..';wait .1; input /macro set 1')
		end
	end
end

-- Called when the job file unloads, after the engine has released its keys and held slots.
function user_file_unload()

end

-- Called when a pet is summoned or lost. Gear returned here merges over the idle or engaged set.
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called when a pet's action ends. Gear returned here merges over the idle or engaged set.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while a pet's action is in flight. Gear returned here merges over sets.Pet_Midcast and the set named for the action.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
