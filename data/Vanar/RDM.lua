-- Vanar's Red Mage, built on the Rahvin GearSwap 2.1 sample (data/common/Sample Job Files/RDM.lua).
-- Every piece named here comes from Vanar's //gs export, data/export/Vanar 2026-10-03 00-46-48.lua.
-- Sets favor, in order: accuracy, magic accuracy, weapon skill damage, attack, magic attack and
-- damage taken. Leth. Earring +1 is always in the right ear, the only ear its Fast Cast and
-- enhancing duration work in.
-- data/Vanar/Vanar_gear_list.md lists every piece this file and BLU.lua use.

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Vanar's settings for every job, such as Windower aliases.
include('Vanar-Globals')

-- The lockstyle set, macro book and macro set that jobsetup applies at load.
LockStylePallet = "1"
MacroBook = "3"
MacroSet = "1"

-- When true, the engine uses a Remedy on paralysis or silence and a Holy Water on Doom.
AutoItem = false

-- When true, each load picks a lockstyle set from Lockstyle_List in place of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets Random_Lockstyle picks from.
Lockstyle_List = { 1, 2, 6, 12 }

-- The item that "gs c food" uses.
Food = "Crepe B. Helene"

-- The offense modes this job cycles through. Each mode needs a sets.OffenseMode.<Mode> and a
-- sets.Idle.<Mode> below. state.OffenseMode:set picks the mode selected at load.
state.OffenseMode:options('TP', 'ACC', 'DT')
state.OffenseMode:set('TP')

-- The spells, job abilities and weaponskills that wear sets.TreasureHunter against an untagged monster, along with
-- every ranged attack. In Tag mode nothing else wears it, melee included, and an action off the list does not count
-- as tagging. Delete the line to let every action tag.
TH_Whitelist = S { 'Dia', 'Dia II', 'Dia III', 'Stonega' }

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet, MacroBook, MacroSet)

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Savage Blade', 'Savage Blade Acc', 'Sanguine Blade', 'Black Halo', 'Black Halo Acc', 'Chant du Cygne', 'Evisceration', 'Aeolian Edge')
state.WeaponMode:set('Savage Blade')
-- Weapon lock at load. 'Unlocked' holds the weapon mode's weapons only while engaged, so out of combat the idle,
-- casting and skill sets can change the main and sub. 'Locked' would hold them everywhere, and is the engine's
-- default when a file sets nothing.
state.WeaponLock:set('Unlocked')

-- Auto weaponskill choices, keyed by the weapon modes above. gs c AutoWS (F11) cycles OFF and the
-- current weapon mode's choices. It starts OFF and goes back to OFF when the weapon mode changes.
-- Moonshade Earring's TP Bonus +250, which the weapon skill sets wear, turns 1750 into 2000 and 2750 into
-- 3000, the cap. With Thibron's TP Bonus +1000 in the offhand, 1750 already reaches the cap, so those modes
-- stop at 1750.
AutoWS_List = {
	['Savage Blade'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 } },
	['Savage Blade Acc'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 }, { 'Savage Blade', 2750 } },
	['Sanguine Blade'] = { { 'Sanguine Blade', 1000 } },
	['Black Halo'] = { { 'Black Halo', 1000 }, { 'Black Halo', 1750 } },
	['Black Halo Acc'] = { { 'Black Halo', 1000 }, { 'Black Halo', 1750 }, { 'Black Halo', 2750 } },
	['Chant du Cygne'] = { { 'Chant du Cygne', 1000 }, { 'Chant du Cygne', 1750 }, { 'Chant du Cygne', 2750 } },
	['Evisceration'] = { { 'Evisceration', 1000 }, { 'Evisceration', 1750 }, { 'Evisceration', 2750 } },
	['Aeolian Edge'] = { { 'Aeolian Edge', 1000 }, { 'Aeolian Edge', 1750 }, { 'Aeolian Edge', 2750 } },
}
state.AutoWS:set('OFF')

-- The magic skills that have to land. midcast_custom casts them in sets.Weapons.Casting when you are
-- not engaged and the weapon lock is Unlocked.
Casting_Skills = S { 'Enfeebling Magic', 'Elemental Magic', 'Dark Magic', 'Divine Magic' }

-- The spells named like a family set below: sets.Midcast.Phalanx, sets.Midcast.Refresh and
-- sets.Midcast.Regen. midcast_custom puts the enhancing set back under them.
Family_Set_Spells = S { 'Phalanx', 'Refresh', 'Regen' }

-- Enfeebles whose magic accuracy comes from INT (bg-wiki, Magic Accuracy). The enfeebling tier sets put the
-- MND cape back on, so midcast_custom swaps the INT cape in last, for these and for the engine's
-- Elemental_Enfeeble list (Burn, Frost and the rest). Frazzle and Distract are black magic but take MND, so
-- they stay off the list. Dark magic wears the INT cape in sets.Midcast.Dark.
INT_Cape_Spells = S { 'Blind', 'Blind II', 'Sleep', 'Sleep II', 'Sleepga', 'Bind', 'Break', 'Gravity', 'Gravity II',
	'Dispel', 'Poison', 'Poison II', 'Poisonga' }

-- Bio, Bio II and Bio III leave the engine's enfeebling duration tier (interface.lua), which only adds
-- enfeebling-magic pieces, and stay on sets.Midcast.Dark. The list is changed in place so later engine edits
-- still apply.
for _, spell in ipairs({ 'Bio', 'Bio II', 'Bio III' }) do
	Enfeeble_Duration:remove(spell)
end

-- Auto buff lists, as on BLU. gs c AutoBuff (F12) cycles OFF and Auto, and starts OFF.
-- While Auto is on, the engine casts the first buff below that you are missing, on yourself. Gain-STR only
-- helps in melee, so it waits until you engage. Temper II is cast while not engaged, so its set's skill
-- weapons go on; it isn't recast mid-fight while engaged. Each cast wears its midcast set. While engaged the
-- weapon lock holds main and sub whatever its value, so those casts don't swap weapons or cost TP.
AutoBuff_List = {
	Auto = {
		{ Name = 'Temper II', Buff = 'Multi Strikes', When = 'Idle' },
		{ Name = 'Gain-STR', Buff = 'STR Boost', When = 'Engaged' },
		{ Name = 'Refresh III', Buff = 'Refresh', When = 'Always' },
		{ Name = 'Haste II', Buff = 'Haste', When = 'Always' },
		{ Name = 'Phalanx', Buff = 'Phalanx', When = 'Always' },
	},
}

-- Vanar's own copies. Library entries cover everything else. Augments are written exactly as
-- //gs export printed them, so each entry matches only that copy.
gear.sucellosDA = hp_gear("Sucellos's Cape", 0, {
	augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Damage taken-5%', } })    -- Acc 30, Att 20, DA 10, DT 5
gear.sucellosWSD = hp_gear("Sucellos's Cape", 0, {
	augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%', } }) -- Acc 20, Att 20, WSD 10, DT 5
gear.sucellosMND = hp_gear("Sucellos's Cape", 0, {
	augments = { 'MND+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', 'Haste+10', } })                       -- Macc 30, MND 20
gear.sucellosINT = hp_gear("Sucellos's Cape", 0, {
	augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', '"Mag.Atk.Bns."+10', } })              -- Macc 30, MAB 10, MDmg 20
gear.ghostfyre = hp_gear("Ghostfyre Cape", 0)                                                                  -- Enhancing duration 20, Enhancing skill 5, Enfeebling skill 8, Macc 8
gear.kentarchPlusOne = hp_gear("Kentarch Belt +1", 0)                                                          -- Acc 14, DA 3
gear.whiteRarabCap = hp_gear("Wh. Rarab Cap +1", 0)                                                            -- Treasure Hunter 1
-- Two copies of one ring, worn as a pair or one at a time. A set wearing both should not directly follow
-- a set wearing one: GearSwap's copy matching (equip_processing.lua, unpack_equip_list) can then pick the
-- copy already worn for the other slot. If one ever fails to equip, pin each to the bag it lives in, for
-- example hp_gear("Stikini Ring", 0, { bag = "wardrobe" }) and { bag = "wardrobe2" }.
gear.stikini1 = hp_gear("Stikini Ring", 0) -- Macc 8, all magic skills 5
gear.stikini2 = hp_gear("Stikini Ring", 0)
gear.telchineBodyRegen = hp_gear("Telchine Chas.", 54, {
	augments = { '"Regen" potency+3', } })                                       -- Regen potency 3, Regen duration +12s, Enhancing skill 12
gear.telchineHandsRegen = hp_gear("Telchine Gloves", 52, {
	augments = { '"Regen" potency+3', } })                                       -- Regen potency 3, Cure 10
gear.telchineFeetRegen = hp_gear("Telchine Pigaches", 13, {
	augments = { '"Regen" potency+3', } })                                       -- Regen potency 3
gear.pukulatmujPlusOne = rank_gear("Pukulatmuj +1", 100)                         -- Enhancing skill 11, Stoneskin casting time -11%
gear.forfendPlusOne = hp_gear("Forfend +1", 22, {
	augments = { 'Path: A', } })                                                 -- Enhancing skill 10, Acc 15, Macc 15 (Path A at max rank)
gear.enhancingTorque = hp_gear("Enhancing Torque", 0)                            -- Enhancing skill 7
gear.fiFolletPlusOne = mp_gear("Fi Follet Cape +1", 45, {
	augments = { 'Path: A', } })                                                 -- Enhancing skill 9; rank 11: Fast Cast 8, SIRD -3
gear.coladaRefresh = rank_gear("Colada", 100, {
	augments = { '"Refresh"+2', 'Mag. Acc.+11', '"Mag.Atk.Bns."+12', 'DMG:+1', } }) -- Refresh 2
gear.archdukesShield = hp_gear("Archduke's Shield", 0)                           -- Refresh 1, INT 20, MND 20, Magic evasion 20
gear.asperity = hp_gear("Asperity Necklace", 0)                                  -- Att 8, STP 3, DA 2
gear.hastyPinion = hp_gear("Hasty Pinion", 0)                                    -- Haste 1, Store TP -5
gear.fucho = mp_gear("Fucho-no-Obi", 30)                                         -- Refresh 1 while MP is below half of max MP without ear, ring and back MP (latent)

function get_sets()
	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode above, each named for the weaponskill it is built for. They are worn
	-- only while engaged, under the Unlocked weapon lock this file loads with. Out of combat
	-- choose_set_custom swaps in sets.Weapons.Idle for its refresh, which costs whatever TP is left when you
	-- disengage. Savage Blade and Black Halo dual wield Thibron for its TP Bonus +1000. Sanguine Blade takes
	-- Bunzi's Rod for its magic attack. Black Halo Acc, Chant du Cygne and the two dagger modes take Gleti's
	-- Knife, and Savage Blade Acc takes Almace. Every mode clears the range slot.
	-- Ullr only goes on for the casts midcast_custom names.
	sets.Weapons = {}

	sets.Weapons['Savage Blade'] = {	-- also Seraph Blade and Red Lotus Blade
		main = gear.naegling,
		sub = gear.thibron,			-- TP Bonus +1000
		range = empty,
	}

	sets.Weapons['Savage Blade Acc'] = {
		main = gear.naegling,
		sub = gear.gleti,			-- Acc 40, Att 30, TA 6
		range = empty,
	}

	sets.Weapons['Sanguine Blade'] = {
		main = gear.naegling,
		sub = gear.bunzi,			-- MAB 35, Macc 40
		range = empty,
	}

	sets.Weapons['Black Halo'] = {
		main = gear.maxentius,
		sub = gear.thibron,			-- TP Bonus +1000
		range = empty,
	}

	sets.Weapons['Black Halo Acc'] = {
		main = gear.maxentius,
		sub = gear.gleti,			-- Acc 40, DEX 15, and a more accurate offhand than Bunzi's Rod
		range = empty,
	}

	sets.Weapons['Chant du Cygne'] = {
		main = gear.almace,
		sub = gear.gleti,			-- Acc 40, Att 30, TA 6, Crit 5
		range = empty,
	}

	sets.Weapons['Evisceration'] = {
		main = gear.tauret,
		sub = gear.gleti,			-- Acc 40, Att 30, TA 6, Crit 5
		range = empty,
	}

	sets.Weapons['Aeolian Edge'] = {
		main = gear.tauret,
		sub = gear.gleti,			-- DEX 15, Macc 40
		range = empty,
	}

	-- Worn whenever you are not engaged and the weapon lock is Unlocked, in every weapon mode.
	-- choose_set_custom puts it on.
	sets.Weapons.Idle = {
		main = gear.coladaRefresh,		-- Refresh 2
		sub = gear.archdukesShield,		-- Refresh 1
	}

	-- Worn for the casts that have to land while you are not engaged and the weapon lock is Unlocked.
	-- midcast_custom puts it on.
	sets.Weapons.Casting = {
		main = gear.bunzi,				-- Macc 40, MAB 35, Magic Accuracy skill 255
		sub = gear.ammurapi,			-- Macc 38, MAB 38
		range = gear.ullr,				-- Macc 40
		ammo = empty,					-- any ammo that is not an arrow strips the bow
	}

	-- The same, with Maxentius in the offhand when a subjob gives Dual Wield, for magic that has to land.
	-- Nukes keep Ammurapi Shield for its magic attack. midcast_custom picks between the two.
	sets.Weapons.CastingDualWield = set_combine(sets.Weapons.Casting, {
		sub = gear.maxentius,			-- Macc 40, MAB 21, INT 15, MND 15. Its Magic Accuracy skill only counts in the main hand.
	})

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {
		sub = gear.ammurapi,
	}

	-- Worn over the idle set while you are asleep, for gear that wakes you. Empty, and declared so the engine
	-- finds it: a job file that replaces sets.Weapons drops the engine's empty one until the first action.
	sets.Weapons.Sleep = {}

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn while idle. Every action's precast and midcast also start from this set, so a slot
	-- their sets leave out keeps its idle piece.
	sets.Idle = {
		head = gear.vitiationChapeauPlusFour,	-- Refresh 3
		body = gear.lethargyBodyPlusThree,		-- Refresh 4, DT 14
		hands = gear.lethargyHandsPlusThree,	-- DT 11
		legs = gear.lethargyLegsPlusThree,		-- Magic evasion 162
		feet = gear.vitiationFeetPlusFour,		-- Magic evasion 167
		neck = gear.sibylScarf,					-- Refresh 1 for a citizen of Windurst
		waist = gear.flumeBelt,					-- PDT 4, and 2% of damage taken comes back as MP
		left_ear = gear.alabaster,				-- DT 5, HP 100
		right_ear = gear.etiolation,			-- HP 50, MP 50, MDT 3
		left_ring = gear.murky,					-- DT 10
		right_ring = gear.ayanmoRing,			-- DT 3
		back = gear.sucellosDA,					-- DT 5
	}	-- DT 48, PDT 4 and MDT 3: physical 52 and magic 51, each capped at 50. Refresh 8, and 11 with sets.Weapons.Idle. Damage taken caps at 50%, so the slots past the cap carry Refresh and magic evasion instead.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})

	-- Worn while resting. Declared so the engine finds it: replacing sets.Idle drops the engine's own until the
	-- first action.
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- Worn over the idle set while a Phantom Roll on you stands at 11, for a ring such as Roller's Ring.
	sets.Idle.XIRoll = {}

	-- Worn over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = set_combine(sets.Idle, {
		waist = gear.embla,	-- Sublimation +3
	})

	-- Worn over the idle set while moving and not engaged.
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathD,	-- Movement speed 18%
	}

	-- Worn over the idle set while Fucho-no-Obi's latent Refresh +1 works, a little below 50% MP; see
	-- choose_set_custom, which puts it on. It takes Flume Belt's PDT 4, so idle physical DT is 48 meanwhile.
	sets.LowMP = {
		waist = gear.fucho,						-- Refresh 1 (latent)
	}

	-- The ring slot Zodiac Ring goes in when a spell's element matches the day: "right_ring" or
	-- "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- The engaged base, merged first in every offense mode. The mode's own set goes over it.
	-- Gear haste is 30% in ACC and DT and 39% in TP (Sailfi Belt +1 adds 9), 2% more with Gleti's Knife, all
	-- past the 26% cap, so no piece here is picked for haste.
	sets.OffenseMode = {
		ammo = gear.coiste,							-- DA 3, STP 3
		head = gear.lethargyHeadPlusThree,			-- Acc 61, Att 61, DT 10
		body = gear.lethargyBodyPlusThree,			-- Acc 64, Att 64, DT 14
		hands = gear.lethargyHandsPlusThree,		-- Acc 62, Att 62, DT 11
		legs = gear.lethargyLegsPlusThree,			-- Acc 63, Att 63
		feet = gear.lethargyFeetPlusThree,			-- Acc 60, Att 60
		neck = gear.sanctity,						-- Acc 10, Att 10
		waist = gear.kentarchPlusOne,				-- Acc 14, DA 3
		left_ear = gear.brutal,						-- DA 5
		right_ear = gear.lethargyEarringPlusOne,	-- Acc 15, DA 5
		left_ring = gear.lehkoHabhokaRing,			-- STP 10, Crit 10
		right_ring = gear.rajas,					-- STP 5, Subtle Blow 5
		back = gear.sucellosDA,						-- Acc 30, Att 20, DA 10, DT 5
	}	-- Acc 379, Att 340, DT 40

	-- Sailfi Belt +1 trades Kentarch Belt +1's Acc 14 for multi-attack and Attack. ACC and DT keep Kentarch.
	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {
		neck = gear.asperity,						-- Att 8, STP 3, DA 2
		waist = gear.sailfi,						-- TA 2, DA 5, STR 15 (Path A), Att 10-15 (Unity)
	})	-- Acc 355, Att 348-353, DT 40

	-- Four Atrophy +4 pieces add the set's Acc +45.
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {
		head = gear.atrophyHeadPlusFour,			-- Acc 64
		body = gear.atrophyBodyPlusFour,			-- Acc 65
		hands = gear.atrophyHandsPlusFour,			-- Acc 63, Att 35
		legs = gear.atrophyLegsPlusFour,			-- Acc 59
	})	-- Acc 425, DT 5

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		right_ring = gear.murky,					-- DT 10
	})	-- DT 50

	-- Treasure Hunter gear. In Tag mode it is worn only for an action TH_Whitelist lists, aimed at an
	-- untagged monster, never just for being engaged. Full Time also wears it whenever engaged. TH Mode
	-- starts in Tag, Alt+F11 cycles it, and None turns it off.
	sets.TreasureHunter = {
		head = gear.whiteRarabCap,	-- TH 1
		body = gear.volteJupon,		-- TH 2
		waist = gear.chaac,			-- TH 1
	}

	-- Worn when you use a Holy Water or Hallowed Water. "Holy Water" potency gear raises its chance to remove Doom,
	-- such as Nicander's Necklace, Purity Ring and Blenmot's Ring. Empty for now.
	sets.Holy_Water = {}

	-- Put on when Doom lands and held until it wears off. With SpellReceived ON, it is worn instead when another of
	-- your characters casts Cursna on you. Potency of "Cursna" received raises the chance that Cursna removes Doom,
	-- such as Nicander's Necklace, Gishdubar Sash, Purity Ring, Eshmun's Ring and Saida Ring. Its slots stay held
	-- while Doom lasts, so sets.Holy_Water can only change the others. Empty for now.
	sets.Cursna_Received = {}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Precast sets, worn as an action starts.
	sets.Precast = {}

	-- Fast cast gear, worn at the start of every spell. The Fast Cast trait covers 38%, so 42%
	-- from gear reaches the 80% cap.
	sets.Precast.FastCast = {
		head = gear.atrophyHeadPlusFour,		-- FC 16
		body = gear.vitiationBodyPlusFour,		-- FC 15
		waist = gear.embla,						-- FC 5
		right_ear = gear.lethargyEarringPlusOne,	-- FC 8
	}	-- FC 44, 82% with the trait. The other slots keep the idle set's DT pieces.

	-- Stoneskin, over the fast-cast set. Doyen Pants fill the legs and Siegel Sash takes Embla Sash's
	-- place, and the free slots add 12 fast cast, so fast cast is 89% with the Stoneskin cuts on top.
	-- bg-wiki counts those cuts inside the same 80% cap, so under that reading the set changes nothing, and
	-- if they go past it the cast is faster. Recast is set by the midcast set, so nothing here costs any.
	sets.Precast["Stoneskin"] = {
		main = gear.pukulatmujPlusOne,			-- Stoneskin casting time -11
		legs = gear.doyenLegs,					-- Stoneskin casting time -10
		waist = gear.siegel,					-- Enhancing magic casting time -8
		back = gear.fiFolletPlusOne,			-- FC 8 (rank 11)
		left_ear = gear.loquacious,				-- FC 2
		left_ring = gear.prolix,				-- FC 2
	}	-- FC 89% (cap 80), and Stoneskin casting time -29%

	-- Cure spells, over the fast-cast set. The Cure casting time pieces take the slots the fast-cast set
	-- leaves open, Doyen Pants among them, so fast cast stays at 82% with the Cure cuts on top. As with
	-- Stoneskin, bg-wiki counts those cuts inside the 80% cap, so under that reading the set changes
	-- nothing, and if they go past it the cast is faster. Recast is set by the midcast set, so nothing here
	-- costs any. Serenity (Cure casting time -8) is left out: it is a two-handed staff, so out of combat it
	-- would take the shield off. While engaged the weapon lock keeps the weapons.
	sets.Precast.Cure = {
		legs = gear.doyenLegs,					-- Cure spellcasting time -15
		feet = gear.vanyaFeetPathD,				-- Cure spellcasting time -15
		left_ear = gear.mendicantEarring,		-- Cure spellcasting time -5
	}	-- FC 82%, and Cure spellcasting time -35%

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this
	-- set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Utsusemi from a NIN subjob keeps the idle set's DT.
	sets.Midcast.Utsusemi = set_combine(sets.Idle, {})

	-- Cure spells.
	sets.Midcast.Cure = set_combine(sets.Midcast, {
		body = gear.vitiationBodyPlusFour,		-- Healing magic skill 24
		hands = gear.telchineHandsRegen,		-- Cure 10
		legs = gear.atrophyLegsPlusFour,		-- Cure 12
		feet = gear.vanyaFeetPathD,				-- Cure 10
		right_ring = gear.najiLoop,				-- Cure potency II 1, Cure 1
		neck = gear.nodens,						-- Cure 5
		right_ear = gear.mendicantEarring,		-- Cure 5
		back = gear.solemnityCape,				-- Cure 7, DT 4
	})	-- Cure 50 (the cap), Cure potency II 1, which counts past that cap, and Healing magic skill 24
	sets.Midcast.Curaga = set_combine(sets.Midcast.Cure, {})

	-- Cursna from a WHM subjob, worn over sets.Midcast.Enhancing. "Cursna"+ and Healing magic skill raise its chance
	-- to remove Doom. Empty for now.
	sets.Midcast.Cursna = {}

	-- Enhancing magic. Most enhancing spells stop gaining from skill at 500 (bg-wiki, Category:Enhancing
	-- Magic), and this set already gives 545: 481 without gear at RDM 99 and Master Level 25, plus
	-- Vitiation Tabard +4, Lethargy Houseaux +3 and Ghostfyre Cape. So it is built for duration first and
	-- recast second. Durations an item lists natively add together, augmented durations (Telchine, Dls.
	-- Torque +1 Path A, Ghostfyre Cape) add together, and the two totals multiply, so Ghostfyre's augmented
	-- 20% beats a Sucellos's Cape's native 20%. Recast falls with gear haste, which caps at 26%, and with
	-- half of fast cast, so 2 fast cast count as 1 haste. Every enhancing spell starts from this set.
	sets.Midcast.Enhancing = set_combine(sets.Midcast, {
		sub = gear.ammurapi,					-- 10%
		ammo = gear.hastyPinion,				-- Haste 1
		head = gear.telchineCapBEnhDur,			-- augment 10%, Haste 6
		body = gear.vitiationBodyPlusFour,		-- 15%, Fast Cast 15, Haste 3
		hands = gear.atrophyHandsPlusFour,		-- 20%, Haste 3
		legs = gear.telchineBraconiBEnhDur,		-- augment 10%, Haste 5
		feet = gear.lethargyFeetPlusThree,		-- 40%, Haste 3
		neck = gear.duelistTorquePlusOne,		-- augment 20% (Path A)
		waist = gear.embla,						-- 10%, Fast Cast 5
		left_ear = gear.alabaster,				-- Haste 5
		right_ear = gear.lethargyEarringPlusOne,	-- 8%, Fast Cast 8
		right_ring = gear.prolix,				-- Fast Cast 2
		back = gear.ghostfyre,					-- augment 20%
	})	-- native 103% x augments 60%, 3.25 times base duration. Gear haste 26% (the cap), gear fast cast 30%.

	-- Enhancing spells cast on someone else, and self-casts under Accession. The Lethargy set bonus
	-- lengthens them while Composure is up, 35% for four pieces and 50% for five, and it multiplies apart
	-- from the native and augmented totals. Four pieces with Atrophy Gloves +4 (3.55 times base) edge out
	-- five (3.53 times), since the fifth would replace the gloves' native 20%.
	sets.Midcast.Enhancing.Others = set_combine(sets.Midcast.Enhancing, {
		head = gear.lethargyHeadPlusThree,
		body = gear.lethargyBodyPlusThree,
		legs = gear.lethargyLegsPlusThree,
	})

	-- Temper, Temper II and the first-tier en-spells keep gaining from enhancing skill past 500, so they
	-- wear every skill piece, weapons included. A first-tier en-spell's damage is set by the skill worn
	-- at the cast. A second-tier en-spell reads the skill worn on each attack round (bg-wiki,
	-- Category:Enspell), so the engine leaves the second tier on the duration set. Forfend +1 is a shield,
	-- so the set needs no Dual Wield.
	sets.Midcast.Enhancing.Skill = set_combine(sets.Midcast.Enhancing, {
		main = gear.pukulatmujPlusOne,			-- Enhancing skill 11
		sub = gear.forfendPlusOne,				-- Enhancing skill 10 (Path A)
		body = gear.vitiationBodyPlusFour,		-- Enhancing skill 24
		hands = gear.vitiationHandsPlusFour,	-- Enhancing skill 25
		legs = gear.atrophyLegsPlusFour,		-- Enhancing skill 22
		feet = gear.lethargyFeetPlusThree,		-- Enhancing skill 35
		neck = gear.enhancingTorque,			-- Enhancing skill 7
		waist = gear.olympus,					-- Enhancing skill 5
		left_ear = gear.mimir,					-- Enhancing skill 10
		right_ear = gear.andoaaEarring,			-- Enhancing skill 5
		left_ring = gear.stikini1,				-- Enhancing skill 5
		right_ring = gear.stikini2,				-- Enhancing skill 5
		back = gear.fiFolletPlusOne,			-- Enhancing skill 9
	})	-- Enhancing skill 654. Temper II's triple attack is (skill - 300) / 10, 35% here, up to 40% at 700.

	-- Gain spells. Their potency from skill caps at 500, and Vitiation Gloves +4 add to it.
	sets.Midcast.Enhancing.Gain = set_combine(sets.Midcast.Enhancing, {
		hands = gear.vitiationHandsPlusFour,	-- Gain effect +30
	})

	-- Elemental bar-spells cap at 500 skill, which the duration set already gives. Bar-status spells ignore
	-- skill. Both take the duration set.
	sets.Midcast.Enhancing.Elemental = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.Enhancing.Status = set_combine(sets.Midcast.Enhancing, {})

	-- Regen and Refresh put potency first, then duration, then recast. These sets and the Phalanx set
	-- name only the slots they change, so a cast on someone else keeps the Others set's Lethargy pieces
	-- in the rest. The spells called Phalanx, Refresh and Regen would wear these sets alone, so
	-- midcast_custom puts the enhancing set back under them.
	sets.Midcast.Regen = {
		body = gear.telchineBodyRegen,			-- Regen potency 3, Regen duration +12s
		hands = gear.telchineHandsRegen,		-- Regen potency 3
		feet = gear.telchineFeetRegen,			-- Regen potency 3
	}

	sets.Midcast.Refresh = {
		head = gear.amalricCoifPlusOne,			-- Refresh potency +2
		body = gear.atrophyBodyPlusFour,		-- Refresh potency +2
		legs = gear.lethargyLegsPlusThree,		-- Refresh potency +4
	}

	-- Phalanx stops gaining at 500 skill. The enhancing set gives 545, and 521 on someone else, where the
	-- Others set's Lethargy Sayon +3 takes the Vitiation Tabard's 24 skill away, so Phalanx needs nothing
	-- of its own. The engine warns (at most once a minute) when the set it reaches for is empty, so this names the
	-- ring the enhancing set already wears.
	sets.Midcast.Phalanx = {
		right_ring = gear.prolix,				-- Fast Cast 2
	}

	-- Sets named for one spell. Such a set takes the place of the spell's family set, which is why
	-- these start from the family set with set_combine.
	-- Stoneskin absorbs enhancing skill + 3 x MND - 190, up to 350, so this set's 545 skill caps it on its
	-- own. Stoneskin+ gear goes past that cap, up to 475. Siegel Sash only has to be worn during the cast.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		neck = gear.nodens,		-- Stoneskin +30
		waist = gear.siegel,	-- Stoneskin +20
	})	-- 400

	-- At 501 skill or more Aquaveil blocks three interruptions.
	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		head = gear.amalricCoifPlusOne,	-- Aquaveil +2
	})

	-- Enfeebling magic. The engine adds .MACC, .Potency or .Duration from its enfeebling lists, one of which
	-- (Enfeeble_Duration) is changed at the top of this file. INT_Cape_Spells swap this set's MND cape for the INT cape in
	-- midcast_custom.
	-- Four Atrophy +4 pieces add the set's Macc +45. Cast while the weapons are free, sets.Weapons.Casting adds Macc 118
	-- but empties the ammo for Ullr, which drops Pemphredo Tathlum's 8: net +110.
	sets.Midcast.Enfeebling = set_combine(sets.Midcast, {
		ammo = gear.pemphredoTathlum,				-- Macc 8, on casts that keep the ammo slot (engaged or Locked)
		head = gear.atrophyHeadPlusFour,			-- Macc 64
		body = gear.atrophyBodyPlusFour,			-- Macc 65, Enfeebling skill 22
		hands = gear.atrophyHandsPlusFour,			-- Macc 63
		legs = gear.atrophyLegsPlusFour,			-- Macc 59
		feet = gear.vitiationFeetPlusFour,			-- Macc 48, Enfeebling skill 17, effect +10
		neck = gear.duelistTorquePlusOne,			-- Macc 25, effect +7
		waist = gear.ruminationSash,				-- Macc 3, Enfeebling skill 7, MND 4
		left_ear = gear.snotra,						-- Macc 10, duration 10%
		right_ear = gear.lethargyEarringPlusOne,	-- Macc 15
		left_ring = gear.stikini1,					-- Macc 8, Enfeebling skill 5
		right_ring = gear.stikini2,					-- Macc 8, Enfeebling skill 5
		back = gear.sucellosMND,					-- Macc 30, MND 20, effect +10
	})	-- Macc 451 with the set bonus, plus Enfeebling skill 56, which adds to magic accuracy one for one.

	-- Enfeebles that only need to land, such as Dispel, Frazzle and Poison. Enfeebling skill counts one for one as magic
	-- accuracy here, so Vitiation Chapeau +4 and Lethargy Gantherots +3 beat the Atrophy head and hands even
	-- though the Atrophy bonus drops from +45 to +15: 18 more in all.
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {
		head = gear.vitiationChapeauPlusFour,		-- Macc 42, Enfeebling skill 27, merit Macc +15 (5 merits)
		hands = gear.lethargyHandsPlusThree,		-- Macc 62, Enfeebling skill 29
	})

	-- Potency-based enfeebles, such as Paralyze, Slow, Addle, Distract, Blind and Gravity. It is
	-- adapted from bg-wiki's MND potency set (Community Red Mage Guide): Leth. Fuseau +3 in place of Chironic
	-- Hose for a third Lethargy piece, which lengthens these spells by 20% while Composure is up, and Rumination
	-- Sash in place of Obstin. Sash for its enfeebling skill.
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, {
		head = gear.vitiationChapeauPlusFour,		-- Macc 42, Enfeebling skill 27, merit Macc +15 (5 merits)
		body = gear.lethargyBodyPlusThree,			-- Enfeebling effect +18, Macc 64
		hands = gear.lethargyHandsPlusThree,		-- Enfeebling skill 29, Saboteur +14, Macc 62
		legs = gear.lethargyLegsPlusThree,			-- Macc 63
	})

	-- Duration-based enfeebles, such as Sleep, Dia, Silence, Bind, Break and Inundation. bg-wiki's
	-- duration set (Finans Gearset Guides/Red Mage) is built on Lethargy, which lengthens enfeebling magic
	-- while Composure is up: 35% for four pieces, 50% for five. Its hands are Regal Cuffs, which Vanar does
	-- not own, so the Lethargy Gantherots make the fifth piece.
	sets.Midcast.Enfeebling.Duration = set_combine(sets.Midcast.Enfeebling, {
		head = gear.lethargyHeadPlusThree,			-- Macc 61
		body = gear.lethargyBodyPlusThree,			-- Macc 64
		hands = gear.lethargyHandsPlusThree,		-- Macc 62, Enfeebling skill 29
		legs = gear.lethargyLegsPlusThree,			-- Macc 63
		feet = gear.lethargyFeetPlusThree,			-- Macc 60
		waist = gear.obstinateSash,					-- Enfeebling duration 5%
	})

	-- Worn while Saboteur is up on every spell that merges sets.Midcast.Enfeebling. The Lethargy
	-- Gantherots raise Saboteur's bonus and must be worn during the cast.
	sets.Midcast.Enfeebling.Saboteur = {
		hands = gear.lethargyHandsPlusThree,		-- Saboteur +14
	}

	-- Dark magic. Bio and the Aspir and Drain spells take the enfeebling accuracy set, with the INT cape,
	-- since dark magic takes magic accuracy from INT. Rumination Sash's enfeebling skill does nothing for
	-- dark or divine magic, so Eschan Stone's Macc 7 beats its Macc 3 there. Bio is off the enfeebling
	-- duration tier (top of this file), so it wears this set as it is.
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {
		waist = gear.eschan,						-- Macc 7
		back = gear.sucellosINT,					-- Macc 30, INT 20
	})
	sets.Midcast.Aspir = set_combine(sets.Midcast.Dark, {})
	sets.Midcast.Drain = set_combine(sets.Midcast.Dark, {})
	sets.Midcast.Divine = set_combine(sets.Midcast.Enfeebling, {
		waist = gear.eschan,						-- Macc 7
	})

	-- Elemental nukes. A magic burst uses sets.Midcast.Burst instead.
	sets.Midcast.Nuke = set_combine(sets.Midcast, {
		ammo = gear.pemphredoTathlum,				-- Macc 8, MAB 4, on casts that keep the ammo slot (engaged or Locked)
		head = gear.lethargyHeadPlusThree,			-- MAB 56, Macc 61, MDmg 31
		body = gear.lethargyBodyPlusThree,			-- MAB 54, Macc 64, MDmg 34
		hands = gear.lethargyHandsPlusThree,		-- MAB 52, Macc 62, MDmg 32
		legs = gear.lethargyLegsPlusThree,			-- MAB 58, Macc 63, MDmg 33
		feet = gear.lethargyFeetPlusThree,			-- MAB 50, Macc 60, MDmg 30
		neck = gear.sanctity,						-- MAB 10, Macc 10
		waist = gear.eschan,						-- MAB 7, Macc 7
		left_ear = gear.snotra,						-- Macc 10
		right_ear = gear.lethargyEarringPlusOne,	-- Macc 15
		left_ring = gear.stikini1,					-- Macc 8, all magic skills 5
		right_ring = gear.stikini2,					-- Macc 8, all magic skills 5
		back = gear.sucellosINT,					-- MAB 10, Macc 30, MDmg 20
	})

	-- Magic bursts, in place of sets.Midcast.Nuke. The engine wears this set when the cast starts within 8
	-- seconds of a skillchain on the same target whose elements include the spell's. The game's own burst
	-- window is 10 seconds from the closing weapon skill, measured when the spell lands.
	sets.Midcast.Burst = set_combine(sets.Midcast.Nuke, {
		body = gear.eaBody,							-- Magic burst damage 8, Magic burst damage II 8
		neck = gear.mizukageNoKubikazari,			-- Magic burst damage 10
		left_ring = gear.jhakriRing,				-- Magic burst damage 2
	})	-- Magic burst damage 35 with the Fuseau (cap 40), plus Magic burst damage II 8 past the cap. Bunzi's Rod
	-- adds 10 when worn (45, capped at 40).

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is worn for every ability, and a set named for the ability goes over it.
	sets.JA = set_combine(sets.Idle, {})
	sets.JA["Chainspell"] = { body = gear.vitiationBodyPlusFour }

	-- Dancer abilities, for a DNC subjob. Each family set is worn for its abilities, with a set
	-- named for one ability over it. None of them swaps weapons, since new weapons reset TP.

	-- Steps land on melee hit rate, with Accuracy +10 of their own (bg-wiki, Step). This is the ACC engaged
	-- set with the three carried pieces that add accuracy over it.
	sets.Step = set_combine(sets.OffenseMode.ACC, {
		waist = gear.eschan,						-- Acc 15, Macc 7, over Kentarch Belt +1's Acc 14
		left_ring = gear.ayanmoRing,				-- Acc 6, Macc 6
		right_ring = gear.jhakriRing,				-- Acc 6, Macc 6
	})	-- Acc 438, Macc 400

	-- Desperate and Violent Flourish also have to hit, and Violent Flourish's stun is resisted on magic
	-- accuracy (bg-wiki, Violent Flourish), which the Atrophy +4 pieces and their set bonus carry as well.
	-- No gear changes Animated, Reverse or Building Flourish from a subjob.
	sets.Flourish = set_combine(sets.Step, {})

	-- A Waltz heals (your CHR + the target's VIT) x a slope, halved for a subjob, plus a base, times Waltz
	-- potency (bg-wiki, Waltz). No armor RDM can wear has Waltz potency; Gleti's Knife has +10%, but weapons
	-- stay. The carried armor with the most CHR and VIT adds 28 over this set, about 10 HP on Curing Waltz III,
	-- so the set keeps its DT.
	sets.Waltz = set_combine(sets.OffenseMode.DT, {})

	-- Jig and Samba effects come from the ability alone. Only Dancer gear changes them (their duration), so
	-- these keep the idle DT set.
	sets.Jig = set_combine(sets.Idle.DT, {})
	sets.Samba = set_combine(sets.Idle.DT, {})

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Worn on every weaponskill: the weapon skill damage set. Savage Blade, Black Halo and Death
	-- Blossom wear it as it is. It is bg-wiki's Savage Blade set (All Jobs Gear Sets/Red Mage) with Leth.
	-- Earring +1 for Hoxne Earring and Karieyh Ring for Sroda Ring. Nyame values are Path B at rank 20.
	sets.WS = {
		ammo = gear.coiste,							-- Att 15, STR 10, DEX 10, DA 3 (Path A)
		head = gear.vitiationChapeauPlusFour,		-- WSD 9, Acc 42, Att 72
		body = gear.nyameBody,						-- WSD 10, DA 3, Acc 40, Att 55, DT 9
		hands = gear.atrophyHandsPlusFour,			-- WSD 9, Acc 63, Att 35
		legs = gear.nyameLegs,						-- WSD 9, DA 3, Acc 40, Att 55, DT 8
		feet = gear.lethargyFeetPlusThree,			-- WSD 12, Acc 60, Att 60
		neck = gear.republicanPlatinumMedal,		-- Att 30
		waist = gear.sailfi,
		left_ear = gear.moonshade,					-- TP Bonus 250
		right_ear = gear.lethargyEarringPlusOne,	-- Acc 15
		left_ring = gear.epimanondas,				-- WSD 5
		right_ring = gear.karieyh,					-- WSD 3, WS Acc 5
		back = gear.sucellosWSD,					-- WSD 10, Acc 20, Att 20, DT 5
	}

	-- Worn over sets.WS in ACC mode on weaponskills with no set of their own: Savage Blade, Black Halo and
	-- Death Blossom. Every named set below carries its own ACC set instead. List only the pieces the mode
	-- changes, since every slot named here overrides sets.WS.
	sets.WS.ACC = {
		neck = gear.sanctity,						-- Acc 10
		waist = gear.eschan,						-- Acc 15, Att 15
	}

	-- MAB and Crit are not offense modes here. They are shared sets for the weaponskills below.
	sets.WS.MAB = {
		ammo = gear.pemphredoTathlum,				-- Macc 8, MAB 4
		head = gear.lethargyHeadPlusThree,			-- MAB 56, MDmg 31
		body = gear.nyameBody,						-- WSD 10 (Path B), MAB 30
		hands = gear.jhakriHandsPlusTwo,			-- WSD 7, MAB 40
		legs = gear.lethargyLegsPlusThree,			-- MAB 58, MDmg 33
		feet = gear.lethargyFeetPlusThree,			-- WSD 12, MAB 50, MDmg 30
		neck = gear.sanctity,						-- Macc 10, MAB 10
		waist = gear.eschan,						-- Macc 7, MAB 7
		left_ear = gear.friomisi,					-- MAB 10
		right_ear = gear.lethargyEarringPlusOne,	-- Macc 15
		left_ring = gear.epimanondas,				-- WSD 5
		right_ring = gear.jhakriRing,				-- Macc 6, MAB 3
		back = gear.sucellosINT,					-- Macc 30, MAB 10, MDmg 20
	}

	sets.WS.Crit = {
		ammo = gear.coiste,							-- Att 15, DEX 10, DA 3 (Path A)
		head = gear.lethargyHeadPlusThree,			-- Acc 61, Att 61
		body = gear.lethargyBodyPlusThree,			-- Acc 64, Att 64
		hands = gear.lethargyHandsPlusThree,		-- Acc 62, Att 62
		legs = gear.lethargyLegsPlusThree,			-- Acc 63, Att 63
		feet = gear.lethargyFeetPlusThree,			-- Acc 60, Att 60, DEX 30, WSD 12
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ear = gear.moonshade,					-- TP Bonus 250
		right_ear = gear.lethargyEarringPlusOne,	-- Acc 15
		left_ring = gear.lehkoHabhokaRing,			-- Crit 10
		right_ring = gear.jhakriRing,				-- Acc 6, Att 6
		back = gear.sucellosDA,						-- Acc 30, Att 20
	}

	-- Sets named for each weaponskill.
	sets.WS["Sanguine Blade"] = set_combine(sets.WS.MAB, {})

	-- These magical weaponskills gain damage with TP, so the TP Bonus earring goes back in. They have
	-- skillchain properties, so Fotia Belt's latent works on them: +25/256 fTP and Macc 10, over Eschan Stone's
	-- Macc 7 and MAB 7. Sanguine Blade has no property.
	sets.WS["Seraph Blade"] = set_combine(sets.WS.MAB, { left_ear = gear.moonshade, waist = gear.fotiaWaist })
	sets.WS["Red Lotus Blade"] = set_combine(sets.WS.MAB, { left_ear = gear.moonshade, waist = gear.fotiaWaist })
	sets.WS["Aeolian Edge"] = set_combine(sets.WS.MAB, { left_ear = gear.moonshade, waist = gear.fotiaWaist })

	-- In ACC mode these magical weaponskills raise magic accuracy instead of taking sets.WS.ACC, whose
	-- waist would replace theirs. Lethargy Gantherots +3 trade Jhakri
	-- Cuffs +2's WSD 7 for Macc 19 and MAB 12 more.
	for _, ws in ipairs({ "Sanguine Blade", "Seraph Blade", "Red Lotus Blade", "Aeolian Edge" }) do
		sets.WS[ws].ACC = set_combine(sets.WS[ws], { hands = gear.lethargyHandsPlusThree })
	end

	sets.WS["Chant du Cygne"] = set_combine(sets.WS.Crit, {})
	sets.WS["Evisceration"] = set_combine(sets.WS.Crit, {})
	sets.WS["Vorpal Blade"] = set_combine(sets.WS.Crit, {})

	-- Requiescat: five MND hits that can't crit. Every WS.Crit piece but Lehko's Ring is there for accuracy and
	-- attack, and the ring's DEX 10 (about Acc 7) and Store TP 10 still beat the Acc 6 of Vanar's other rings, so it
	-- wears that set as it is.
	sets.WS["Requiescat"] = set_combine(sets.WS.Crit, {})

	-- In ACC mode these keep their own set instead of taking sets.WS.ACC. Its Sanctity Necklace and Eschan
	-- Stone would replace Fotia Gorget and Fotia Belt, whose latents already give every hit of these weapon
	-- skills Accuracy +10 each and +25/256 fTP. The swap would trade that fTP for 5 more accuracy and Att 15.
	for _, ws in ipairs({ "Chant du Cygne", "Evisceration", "Vorpal Blade", "Requiescat" }) do
		sets.WS[ws].ACC = set_combine(sets.WS[ws], {})
	end
end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the subjob changes.
function sub_job_change_custom(new, old)
	-- Typically used to change the macro book or set.
end

-- Called before each action, after the engine's own checks. Call cancel_spell() here to stop
-- the action.
function pretarget_custom(spell, action)

end

-- Called as each action starts. The table it returns is merged over the engine's precast set.
-- With Ullr in range, the ammo a weaponskill, Waltz or Step set names would strip the bow and
-- reset TP before the action fires, so the ammo slot stays bare.
function precast_custom(spell)
	local equipSet = {}
	if player.equipment.range == 'Ullr' and spell.action_type ~= 'Ranged Attack' then
		equipSet = { ammo = empty }
	end
	return equipSet
end

-- Whether you have Dual Wield, job trait 18, which RDM only gets from a subjob such as NIN or DNC.
-- The engine reads it the same way.
local function can_dual_wield()
	local abilities = windower.ffxi.get_abilities()
	return abilities ~= nil and abilities.job_traits ~= nil and table.contains(abilities.job_traits, 18)
end

-- Whether this file may change main and sub: only while not engaged with the weapon lock Unlocked. Engaged,
-- new weapons reset TP, and Locked holds the main, where a new sub alone would make a mixed pair.
local function weapons_free()
	return player.status ~= 'Engaged' and state.WeaponLock.value == 'Unlocked'
end

-- Called while each action is in flight. The table it returns is merged over the engine's
-- midcast set, which is empty for abilities, weaponskills and items.
function midcast_custom(spell)
	local equipSet = {}
	-- sets.Midcast.Phalanx, .Refresh and .Regen hold only the slots they change, for the engine to merge
	-- over the enhancing set, and over the Others set for a cast on someone else. But the engine wears a
	-- set named for the exact spell in place of the whole enhancing set, so the spells called Phalanx,
	-- Refresh and Regen would get those few slots over idle gear and lose every duration piece. This puts
	-- the enhancing set, and the Others set for a cast on someone else, back under them, as the engine
	-- does for the rest of each family.
	if Family_Set_Spells:contains(spell.english) then
		local others = spell.target.type ~= 'SELF' or buffactive['Accession']
		equipSet = set_combine(sets.Midcast.Enhancing, others and sets.Midcast.Enhancing.Others or {}, sets.Midcast[spell.english])
		-- The enhancing set names Ammurapi Shield, which would reach the sub slot past the weapon lock.
		if not weapons_free() then
			equipSet.main, equipSet.sub, equipSet.range = nil, nil, nil
		end
	end
	-- The casting weapons for magic that has to land, cast while not engaged. The offhand is Maxentius
	-- with Dual Wield, and Ammurapi Shield without it and for nukes, which want its magic attack. The
	-- engine's Elemental_Enfeeble list keeps Burn, Frost and the other elemental debuffs off the nukes.
	-- Engaged or Locked casts keep the weapon mode's weapons (weapons_free). After the cast, the weapon
	-- mode takes the range slot back off and choose_set_custom puts the idle weapons back on.
	if weapons_free() and Casting_Skills:contains(spell.skill) then
		local nuke = spell.skill == 'Elemental Magic' and not Elemental_Enfeeble:contains(spell.english)
		equipSet = (can_dual_wield() and not nuke) and sets.Weapons.CastingDualWield or sets.Weapons.Casting
	end
	if INT_Cape_Spells:contains(spell.english) then
		equipSet = set_combine(equipSet, { back = gear.sucellosINT })
	elseif Elemental_Enfeeble:contains(spell.english) then
		-- Elemental magic: enfeebling skill does nothing for it, so the MACC tier's Rumination Sash, Vitiation
		-- head and Lethargy hands give way to Eschan Stone and the Atrophy head and hands (four-piece bonus).
		equipSet = set_combine(equipSet, { head = gear.atrophyHeadPlusFour, hands = gear.atrophyHandsPlusFour,
			waist = gear.eschan, back = gear.sucellosINT })
	end
	return equipSet
end

-- Called when each action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds.
function aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when a buff is gained or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. A change during one of your own actions is dressed when the action ends instead.
function buff_change_custom(name, gain)
	local equipSet = {}
	return equipSet
end

-- Called whenever the engine rebuilds the idle or engaged set, which it does after each action,
-- on a buff or status change, and when movement starts or stops. The table it returns is merged
-- over that set.
function choose_set_custom()
	local equipSet = {}
	-- The refresh weapons whenever the weapons are free (weapons_free). The engine builds the idle set when
	-- you are not engaged. Fucho-no-Obi joins them once its latent is on, unless Sublimation is charging (buff 187), when the
	-- Sublimation set's Embla Sash is worth more. Both are checked on every rebuild: after each action, on a
	-- buff or status change, and when you start or stop moving. The latent needs MP below half of a maximum
	-- that leaves out ear, ring and back MP (bg-wiki, Fucho-no-Obi). The idle set's Etiolation Earring and
	-- Murky Ring carry 80 of it, so the test starts a few points below 50%.
	if player.status ~= 'Engaged' then
		if weapons_free() then
			equipSet = sets.Weapons.Idle
		end
		if player.mp < (player.max_mp - 80) / 2 and not buffactive[187] then
			equipSet = set_combine(equipSet, sets.LowMP)
		end
	end
	return equipSet
end

-- Called when the player's status changes, such as engaging, disengaging or resting. The table
-- it returns is merged over the rebuilt idle or engaged set.
function status_change_custom(new, old)
	local equipSet = {}

	return equipSet
end

-- Called with each "gs c" command, in lowercase, that the engine's own commands leave unclaimed.
-- Use it to add commands of your own. The Weapon Mode, Job Mode and Job Mode 2 commands also call
-- it, before their gear rebuild.
function self_command_custom(command)

end

-- Called when the job file unloads, after the engine releases its keybinds and slot holds.
function user_file_unload()

end

-- Called when a pet is summoned or lost. The table it returns is merged over the rebuilt idle or
-- engaged set.
function pet_change_custom(pet, gain)
	local equipSet = {}

	return equipSet
end

-- Called when a pet's action ends. The table it returns is merged over the idle or engaged set
-- the engine rebuilds.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while a pet's action is in flight. The table it returns is merged over sets.Pet_Midcast
-- and the set named for the action.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
