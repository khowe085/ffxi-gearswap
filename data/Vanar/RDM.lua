-- Vanar's Red Mage, built on the Rahvin GearSwap 2.1 sample (data/common/Sample Job Files/RDM.lua).
-- Every piece named here comes from Vanar's //gs export, data/export/Vanar 2026-10-01 20-15-33.lua.
-- Sets favor, in order: accuracy, magic accuracy, weapon skill damage, attack, magic attack and
-- damage taken. Leth. Earring +1 is always in the right ear, the only ear its Fast Cast and
-- enhancing duration work in.
-- data/Vanar/Vanar_gear_list.md lists every piece this file and BLU.lua use.

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

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

-- The spells that wear sets.TreasureHunter against an untagged monster. A spell off this list keeps its own
-- midcast set and does not count as tagging. Delete the line to let every spell tag.
TH_Spells = S { 'Dia', 'Dia II', 'Dia III', 'Stonega' }

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet, MacroBook, MacroSet)

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Savage Blade', 'Savage Blade Acc', 'Sanguine Blade', 'Black Halo', 'Black Halo Acc', 'Chant du Cygne', 'Evisceration', 'Aeolian Edge')
state.WeaponMode:set('Savage Blade')

-- Auto weaponskill choices, keyed by the weapon modes above. gs c AutoWS (F11) cycles OFF and the
-- current weapon mode's choices. It starts OFF and goes back to OFF when the weapon mode changes.
AutoWS_List = {
	['Savage Blade'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 } },
	['Savage Blade Acc'] = { { 'Savage Blade', 1000 } },
	['Black Halo'] = { { 'Black Halo', 1000 } },
	['Black Halo Acc'] = { { 'Black Halo', 1000 } },
	['Aeolian Edge'] = { { 'Aeolian Edge', 1000 } },
}
state.AutoWS:set('OFF')

-- The magic skills that have to land. midcast_custom casts them in sets.Weapons.Casting when you are
-- not engaged.
Casting_Skills = S { 'Enfeebling Magic', 'Elemental Magic', 'Dark Magic', 'Divine Magic' }

-- The spells named like a family set below: sets.Midcast.Phalanx, sets.Midcast.Refresh and
-- sets.Midcast.Regen. midcast_custom puts the enhancing set back under them.
Family_Set_Spells = S { 'Phalanx', 'Refresh', 'Regen' }

-- Auto buff lists, as on BLU. gs c AutoBuff (F12) cycles OFF and Auto, and starts OFF.
-- While Auto is on, the engine casts the first buff below that you are missing, on yourself. Temper II
-- and Gain-STR only help in melee, so they wait until you engage. Each cast wears its midcast set, and
-- those swap weapons, which costs TP while engaged unless the weapon lock (Alt+F9) is on.
AutoBuff_List = {
	Auto = {
		{ Name = 'Temper II', Buff = 'Multi Strikes', When = 'Engaged' },
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
gear.strendu = hp_gear("Strendu Ring", 0)                                                                      -- Macc 2, MAB 4
gear.whiteRarabCap = hp_gear("Wh. Rarab Cap +1", 0)                                                            -- Treasure Hunter 1
-- Two copies of one ring. They are only ever worn as a pair, which keeps GearSwap from pulling
-- the same copy into both slots. If one ever fails to equip, pin each to the bag it lives in,
-- for example hp_gear("Stikini Ring", 0, { bag = "wardrobe" }) and { bag = "wardrobe2" }.
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
	augments = { 'Path: A', } })                                                 -- Enhancing skill 9
gear.chelonaBoots = mp_gear("Chelona Boots", 35)                                 -- Fast Cast 4
gear.swithCape = hp_gear("Swith Cape", -20)                                      -- Fast Cast 3
gear.coladaRefresh = rank_gear("Colada", 100, {
	augments = { '"Refresh"+2', 'Mag. Acc.+11', '"Mag.Atk.Bns."+12', 'DMG:+1', } }) -- Refresh 2
gear.archdukesShield = hp_gear("Archduke's Shield", 0)                           -- Refresh 1, INT 20, MND 20, Magic evasion 20
gear.pahtliCape = mp_gear("Pahtli Cape", 50)                                     -- Cure spellcasting time -8

function get_sets()
	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode above, each named for the weaponskill it is built for. They are worn
	-- only while engaged. Out of combat choose_set_custom swaps in sets.Weapons.Idle for its refresh, which
	-- costs whatever TP is left when you disengage. Savage Blade and Black Halo dual wield Thibron for its TP
	-- Bonus +1000. Sanguine Blade takes Bunzi's Rod for its magic attack, and Black Halo Acc for its accuracy.
	-- Chant du Cygne and the two dagger modes take Gleti's Knife, and Savage Blade Acc takes Almace. Every
	-- mode clears the range slot. Ullr only goes on for the casts midcast_custom names.
	sets.Weapons = {}

	sets.Weapons['Savage Blade'] = {	-- also Seraph Blade and Red Lotus Blade
		main = gear.naegling,
		sub = gear.thibron,			-- TP Bonus +1000
		range = empty,
	}

	sets.Weapons['Savage Blade Acc'] = {
		main = gear.naegling,
		sub = gear.almace,
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
		sub = gear.bunzi,			-- Acc 40
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

	-- Worn whenever you are not engaged, in every weapon mode. choose_set_custom puts it on.
	sets.Weapons.Idle = {
		main = gear.coladaRefresh,		-- Refresh 2
		sub = gear.archdukesShield,		-- Refresh 1
	}

	-- Worn for the casts that have to land while you are not engaged. midcast_custom puts it on.
	sets.Weapons.Casting = {
		main = gear.bunzi,				-- Macc 40, MAB 35
		sub = gear.ammurapi,			-- Macc 38, MAB 38
		range = gear.ullr,				-- Macc 40
		ammo = empty,					-- any ammo that is not an arrow strips the bow
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {
		sub = gear.ammurapi,
	}

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
		neck = gear.sanctity,					-- Regen 2
		waist = gear.platinumMoogleBelt,		-- DT 3, HP 10%
		left_ear = gear.alabaster,				-- DT 5, HP 100
		right_ear = gear.etiolation,			-- HP 50, MP 50
		left_ring = gear.murky,					-- DT 10
		right_ring = gear.ayanmoRing,			-- DT 3
		back = gear.sucellosDA,					-- DT 5
	}	-- DT 51, Refresh 7, and 10 with sets.Weapons.Idle. Damage taken caps at 50%, so the slots past the cap carry Refresh, Regen and magic evasion instead.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})

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

	-- The ring slot Zodiac Ring goes in when a spell's element matches the day: "right_ring" or
	-- "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- The engaged base, merged first in every offense mode. The mode's own set goes over it.
	-- Gear haste is 30% in every mode (32% with Gleti's Knife), past the 26% cap, so no piece here is
	-- picked for haste.
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
		right_ear = gear.lethargyEarringPlusOne,	-- Acc 11, DA 3
		left_ring = gear.lehkoHabhokaRing,			-- STP 10, Crit 10
		right_ring = gear.rajas,					-- STP 5, Subtle Blow 5
		back = gear.sucellosDA,						-- Acc 30, Att 20, DA 10, DT 5
	}	-- Acc 375, Att 340, DT 40

	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {})

	-- Four Atrophy +4 pieces add the set's Acc +45.
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {
		head = gear.atrophyHeadPlusFour,			-- Acc 64
		body = gear.atrophyBodyPlusFour,			-- Acc 65
		hands = gear.atrophyHandsPlusFour,			-- Acc 63, Att 35
		legs = gear.atrophyLegsPlusFour,			-- Acc 59
	})	-- Acc 421, DT 5

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		right_ring = gear.murky,					-- DT 10
	})	-- DT 50

	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Spells only wear it when TH_Spells lists them. TH Mode
	-- starts in Tag, Alt+F11 cycles it, and None turns it off.
	sets.TreasureHunter = {
		head = gear.whiteRarabCap,	-- TH 1
		body = gear.volteJupon,		-- TH 2
		waist = gear.chaac,			-- TH 1
	}

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
	-- place, and the free slots add 11 fast cast, so fast cast is 88% with the Stoneskin cuts on top. bg-wiki counts those cuts inside the same 80% cap, so
	-- under that reading the set changes nothing, and if they go past it the cast is faster. Recast
	-- is set by the midcast set, so nothing here costs any.
	sets.Precast["Stoneskin"] = {
		main = gear.pukulatmujPlusOne,			-- Stoneskin casting time -11
		legs = gear.doyenLegs,					-- Stoneskin casting time -10
		waist = gear.siegel,					-- Enhancing magic casting time -8
		feet = gear.chelonaBoots,				-- FC 4
		back = gear.swithCape,					-- FC 3
		left_ear = gear.loquacious,				-- FC 2
		left_ring = gear.prolix,				-- FC 2
	}	-- FC 88%, and Stoneskin casting time -29%

	-- Cure spells, over the fast-cast set. The Cure casting time pieces take the slots the fast-cast set
	-- leaves open, Doyen Pants among them, so fast cast stays at 82% with the Cure cuts on top. As with
	-- Stoneskin, bg-wiki counts those cuts inside the 80% cap, so under that reading the set changes
	-- nothing, and if they go past it the cast is faster. Recast is set by the midcast set, so nothing here
	-- costs any. Serenity (Cure casting time -8) is left out: it is a two-handed staff, so it would take
	-- the shield off, and the TP too while engaged without the weapon lock.
	sets.Precast.Cure = {
		hands = gear.vanyaHandsPathB,			-- Cure spellcasting time -7
		legs = gear.doyenLegs,					-- Cure spellcasting time -15
		feet = gear.vanyaFeetPathD,				-- Cure spellcasting time -15
		left_ear = gear.mendicantEarring,		-- Cure spellcasting time -5
		back = gear.pahtliCape,					-- Cure spellcasting time -8
	}	-- FC 82%, and Cure spellcasting time -50%

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
		body = gear.bunziBody,					-- Cure 15
		hands = gear.telchineHandsRegen,		-- Cure 10
		legs = gear.atrophyLegsPlusFour,		-- Cure 12
		feet = gear.vanyaFeetPathD,				-- Cure 10
		back = gear.solemnityCape,				-- Cure 7, DT 4
	})	-- Cure 54 (cap 50)
	sets.Midcast.Curaga = set_combine(sets.Midcast.Cure, {})

	-- Enhancing magic. Most enhancing spells stop gaining from skill at 500 (bg-wiki, Category:Enhancing
	-- Magic), and this set already gives 544: 480 without gear at RDM 99 and Master Level 24, plus
	-- Vitiation Tabard +4, Lethargy Houseaux +3 and Ghostfyre Cape. So it is built for duration first and
	-- recast second. Durations an item lists natively add together, augmented durations (Telchine, Dls.
	-- Torque +1 Path A, Ghostfyre Cape) add together, and the two totals multiply, so Ghostfyre's augmented
	-- 20% beats a Sucellos's Cape's native 20%. Recast falls with gear haste, which caps at 26%, and with
	-- half of fast cast, so 2 fast cast count as 1 haste. Every enhancing spell starts from this set.
	sets.Midcast.Enhancing = set_combine(sets.Midcast, {
		sub = gear.ammurapi,					-- 10%
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
	})	-- native 103% x augments 60%, 3.25 times base duration. Gear haste 25%, gear fast cast 30%.

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
	})	-- Enhancing skill 653. Temper II's triple attack is (skill - 300) / 10, 35% here, up to 40% at 700.

	-- Gain spells. Their potency from skill caps at 500, and Vitiation Gloves +4 add to it.
	sets.Midcast.Enhancing.Gain = set_combine(sets.Midcast.Enhancing, {
		hands = gear.vitiationHandsPlusFour,	-- Gain effect +30
	})

	-- Bar-spells. Their potency caps at 500 skill, which the duration set already gives.
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

	-- Phalanx stops gaining at 500 skill. The enhancing set gives 544, and 520 on someone else, where the
	-- Others set's Lethargy Sayon +3 takes the Vitiation Tabard's 24 skill away, so Phalanx needs nothing
	-- of its own. The engine warns on every cast when the set it reaches for is empty, so this names the
	-- ring the enhancing set already wears.
	sets.Midcast.Phalanx = {
		right_ring = gear.prolix,				-- Fast Cast 2
	}

	-- Sets named for one spell. Such a set takes the place of the spell's family set, which is why
	-- these start from the family set with set_combine.
	-- Stoneskin absorbs enhancing skill + 3 x MND - 190, up to 350, so this set's 544 skill caps it on its
	-- own. Stoneskin+ gear goes past that cap, up to 475. Siegel Sash only has to be worn during the cast.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		neck = gear.nodens,		-- Stoneskin +30
		waist = gear.siegel,	-- Stoneskin +20
	})	-- 400

	-- At 501 skill or more Aquaveil blocks three interruptions.
	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		head = gear.amalricCoifPlusOne,	-- Aquaveil +2
	})

	-- Enfeebling magic. The engine adds .MACC, .Potency or .Duration from its own spell lists.
	-- Four Atrophy +4 pieces add the set's Macc +45. Cast while not engaged, sets.Weapons.Casting adds Macc 118.
	sets.Midcast.Enfeebling = set_combine(sets.Midcast, {
		head = gear.atrophyHeadPlusFour,			-- Macc 64
		body = gear.atrophyBodyPlusFour,			-- Macc 65, Enfeebling skill 22
		hands = gear.atrophyHandsPlusFour,			-- Macc 63
		legs = gear.atrophyLegsPlusFour,			-- Macc 59
		feet = gear.vitiationFeetPlusFour,			-- Macc 48, Enfeebling skill 17, effect +10
		neck = gear.duelistTorquePlusOne,			-- Macc 25, effect +7
		waist = gear.eschan,						-- Macc 7
		left_ear = gear.snotra,						-- Macc 10, duration 10%
		right_ear = gear.lethargyEarringPlusOne,	-- Macc 11
		left_ring = gear.stikini1,					-- Macc 8, Enfeebling skill 5
		right_ring = gear.stikini2,					-- Macc 8, Enfeebling skill 5
		back = gear.sucellosMND,					-- Macc 30, MND 20, effect +10
	})	-- Macc 443 with the set bonus

	-- Enfeebles that only need to land, such as Dispel, Frazzle and Poison.
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})

	-- Potency-based enfeebles, such as Paralyze, Slow, Addle, Distract, Blind and Gravity. This is bg-wiki's
	-- MND potency set (Community Red Mage Guide) from what Vanar owns. Three Lethargy pieces also lengthen
	-- these spells by 20% while Composure is up.
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, {
		head = gear.vitiationChapeauPlusFour,		-- Macc 42, Enfeebling skill 27, merit Macc +15
		body = gear.lethargyBodyPlusThree,			-- Enfeebling effect +18, Macc 64
		hands = gear.lethargyHandsPlusThree,		-- Enfeebling skill 29, Saboteur +14, Macc 62
		legs = gear.lethargyLegsPlusThree,			-- Macc 63
	})

	-- Duration-based enfeebles, such as Sleep, Dia, Bio, Silence, Bind, Break and Inundation. bg-wiki's
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

	-- Dark magic. Bio and the Aspir and Drain spells take the enfeebling accuracy set.
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Aspir = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Drain = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Divine = set_combine(sets.Midcast.Enfeebling, {})

	-- Elemental nukes. A magic burst uses sets.Midcast.Burst instead.
	sets.Midcast.Nuke = set_combine(sets.Midcast, {
		head = gear.lethargyHeadPlusThree,			-- MAB 56, Macc 61, MDmg 31
		body = gear.lethargyBodyPlusThree,			-- MAB 54, Macc 64, MDmg 34
		hands = gear.lethargyHandsPlusThree,		-- MAB 52, Macc 62, MDmg 32
		legs = gear.lethargyLegsPlusThree,			-- MAB 58, Macc 63, MDmg 33
		feet = gear.lethargyFeetPlusThree,			-- MAB 50, Macc 60, MDmg 30
		neck = gear.sanctity,						-- MAB 10, Macc 10
		waist = gear.eschan,						-- MAB 7, Macc 7
		left_ear = gear.friomisi,					-- MAB 10
		right_ear = gear.lethargyEarringPlusOne,	-- Macc 11
		left_ring = gear.jhakriRing,				-- MAB 3, Macc 6
		right_ring = gear.strendu,					-- MAB 4, Macc 2
		back = gear.sucellosINT,					-- MAB 10, Macc 30, MDmg 20
	})

	-- Magic bursts, in place of sets.Midcast.Nuke. A nuke bursts when it lands on the skillchain's
	-- target within 8 seconds and its element matches the skillchain.
	sets.Midcast.Burst = set_combine(sets.Midcast.Nuke, {
		body = gear.bunziBody,						-- Magic burst damage 10
		neck = gear.mizukageNoKubikazari,			-- Magic burst damage 10
	})	-- Magic burst damage 37 with the Fuseau and the Jhakri Ring (cap 40)

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is worn for every ability, and a set named for the ability goes over it.
	sets.JA = set_combine(sets.Idle, {})
	sets.JA["Chainspell"] = { body = gear.vitiationBodyPlusFour }

	-- Dancer abilities, for a DNC subjob. Each family set is worn for its abilities, with a set
	-- named for one ability over it.
	sets.Flourish = set_combine(sets.Idle.DT, {})
	sets.Jig = set_combine(sets.Idle.DT, {})
	sets.Step = set_combine(sets.OffenseMode.ACC, {})
	sets.Samba = set_combine(sets.Idle.DT, {})
	sets.Waltz = set_combine(sets.OffenseMode.DT, {})

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Worn on every weaponskill: the weapon skill damage set. Savage Blade, Black Halo and Death
	-- Blossom wear it as it is. It is bg-wiki's Savage Blade set (All Jobs Gear Sets/Red Mage) with Leth.
	-- Earring +1 for Hoxne Earring and Karieyh Ring for Sroda Ring. Nyame values are Path B at rank 20.
	sets.WS = {
		ammo = gear.coiste,							-- Att 15, STR 10, DEX 10, DA 3 (Path A)
		head = gear.vitiationChapeauPlusFour,		-- WSD 9, Acc 42, Att 72
		body = gear.nyameBody,						-- WSD 13, DA 7, Acc 40, Att 65, DT 9
		hands = gear.atrophyHandsPlusFour,			-- WSD 9, Acc 63, Att 35
		legs = gear.nyameLegs,						-- WSD 12, DA 6, Acc 40, Att 65, DT 8
		feet = gear.lethargyFeetPlusThree,			-- WSD 12, Acc 60, Att 60
		neck = gear.republicanPlatinumMedal,		-- Att 30
		waist = gear.sailfi,
		left_ear = gear.moonshade,					-- TP Bonus 250
		right_ear = gear.lethargyEarringPlusOne,	-- Acc 11
		left_ring = gear.epimanondas,				-- WSD 5
		right_ring = gear.karieyh,					-- WSD 3, WS Acc 5
		back = gear.sucellosWSD,					-- WSD 10, Acc 20, Att 20, DT 5
	}

	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set.
	sets.WS.ACC = {
		neck = gear.sanctity,						-- Acc 10
		waist = gear.kentarchPlusOne,				-- Acc 14
	}

	-- MAB and Crit are not offense modes here. They are shared sets for the weaponskills below.
	sets.WS.MAB = {
		ammo = gear.pemphredoTathlum,				-- Macc 8, MAB 4
		head = gear.lethargyHeadPlusThree,			-- MAB 56, MDmg 31
		body = gear.nyameBody,						-- WSD 13 (Path B), MAB 30
		hands = gear.jhakriHandsPlusTwo,			-- WSD 7, MAB 40
		legs = gear.lethargyLegsPlusThree,			-- MAB 58, MDmg 33
		feet = gear.lethargyFeetPlusThree,			-- WSD 12, MAB 50, MDmg 30
		neck = gear.sanctity,						-- Macc 10, MAB 10
		waist = gear.eschan,						-- Macc 7, MAB 7
		left_ear = gear.friomisi,					-- MAB 10
		right_ear = gear.lethargyEarringPlusOne,	-- Macc 11
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
		right_ear = gear.lethargyEarringPlusOne,	-- Acc 11
		left_ring = gear.lehkoHabhokaRing,			-- Crit 10
		right_ring = gear.ayanmoRing,				-- Acc 6
		back = gear.sucellosDA,						-- Acc 30, Att 20
	}

	-- Sets named for each weaponskill.
	sets.WS["Sanguine Blade"] = set_combine(sets.WS.MAB, {})

	-- These magical weaponskills gain damage with TP, so the TP Bonus earring goes back in.
	sets.WS["Seraph Blade"] = set_combine(sets.WS.MAB, { left_ear = gear.moonshade })
	sets.WS["Red Lotus Blade"] = set_combine(sets.WS.MAB, { left_ear = gear.moonshade })
	sets.WS["Aeolian Edge"] = set_combine(sets.WS.MAB, { left_ear = gear.moonshade })

	-- In ACC mode these magical weaponskills raise magic accuracy instead of taking sets.WS.ACC, whose
	-- Kentarch Belt +1 would replace Eschan Stone's Macc and MAB. Lethargy Gantherots +3 trade Jhakri
	-- Cuffs +2's WSD 7 for Macc 19 and MAB 12 more.
	for _, ws in ipairs({ "Sanguine Blade", "Seraph Blade", "Red Lotus Blade", "Aeolian Edge" }) do
		sets.WS[ws].ACC = set_combine(sets.WS[ws], { hands = gear.lethargyHandsPlusThree })
	end

	sets.WS["Chant du Cygne"] = set_combine(sets.WS.Crit, {})
	sets.WS["Evisceration"] = set_combine(sets.WS.Crit, {})
	sets.WS["Vorpal Blade"] = set_combine(sets.WS.Crit, {})

	-- Requiescat: five MND hits, so accuracy over critical hit rate.
	sets.WS["Requiescat"] = set_combine(sets.WS.Crit, {
		feet = gear.lethargyFeetPlusThree,			-- Acc 60, Att 60
	})
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
	end
	-- The casting weapons for magic that has to land, cast while not engaged. Engaged casts keep the
	-- weapon mode's weapons, since new weapons reset TP. After the cast, the weapon mode takes the range
	-- slot back off and choose_set_custom puts the idle weapons back on.
	if player.status ~= 'Engaged' and Casting_Skills:contains(spell.skill) then
		equipSet = sets.Weapons.Casting
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
	-- The refresh weapons whenever you are not engaged. The engine builds the idle set on the same test.
	if player.status ~= 'Engaged' then
		equipSet = sets.Weapons.Idle
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
