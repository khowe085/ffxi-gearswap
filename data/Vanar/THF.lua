-- Vanar's Thief, built on the Rahvin GearSwap 2.1 sample (data/common/Sample Job Files/THF.lua).
-- Every piece named here comes from Vanar's //gs export, data/export/Vanar 2026-10-03 00-46-48.lua.
-- A basic file: one weapon mode, Gleti's armor engaged, Nyame armor for weapon skills, and the dancer
-- sets for a DNC subjob. It carries nothing BLU.lua and RDM.lua don't already use except Nyame Gauntlets
-- and Skulk. Earring +1. Skulk. Earring +1 is always in the right ear, the only ear its stats work in.
-- data/Vanar/Vanar_gear_list.md lists every piece this file, BLU.lua and RDM.lua use.

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Vanar's settings for every job, such as Windower aliases.
include('Vanar-Globals')

-- The lockstyle set, macro book and macro set that jobsetup applies at load. These are the sample's
-- numbers until Vanar's own Thief ones are set here.
LockStylePallet = "5"
MacroBook = "6"
MacroSet = "1"

-- When true, the engine uses a Remedy on paralysis or silence and a Holy Water on Doom.
AutoItem = false

-- When true, each load picks a lockstyle set from Lockstyle_List in place of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets Random_Lockstyle picks from.
Lockstyle_List = { 1, 2, 6, 12 }

-- The item that "gs c food" uses.
Food = "Grape Daifuku"

-- One offense mode, with its sets.OffenseMode.TP below.
state.OffenseMode:options('TP')
state.OffenseMode:set('TP')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet, MacroBook, MacroSet)

-- One weapon mode, with the sets.Weapons entry of the same name below.
state.WeaponMode:options('Evisceration')
state.WeaponMode:set('Evisceration')
-- Weapon lock at load, as on BLU. 'Locked' always holds the weapon mode's weapons, 'Unlocked' holds them only
-- while engaged. This file has no idle or casting weapons, so Locked costs nothing. Alt+F9 toggles it.
state.WeaponLock:set('Locked')

-- Auto weaponskill choices, keyed by the weapon mode above. gs c AutoWS (F11) cycles OFF and these
-- choices. It starts OFF.
-- Moonshade Earring's TP Bonus +250, which the weapon skill set wears, turns 1750 into 2000 and 2750 into
-- 3000, the cap. Evisceration's critical hit rate rises with TP.
AutoWS_List = {
	['Evisceration'] = { { 'Evisceration', 1000 }, { 'Evisceration', 1750 }, { 'Evisceration', 2750 } },
}
state.AutoWS:set('OFF')

-- Vanar's own copies. Library entries cover everything else.
gear.kentarchPlusOne = hp_gear("Kentarch Belt +1", 0)	-- Acc 14, DA 3
gear.honedTathlum = hp_gear("Honed Tathlum", 0)			-- Acc 15

function get_sets()
	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- The one weapon set. Thief has Dual Wield of its own (tier III, 25%, from level 98), so Gleti's Knife
	-- goes in the off hand on any subjob.
	sets.Weapons = {}

	sets.Weapons['Evisceration'] = {
		main = gear.tauret,		-- Evisceration +50%, from the main hand only
		sub = gear.gleti,		-- Acc 40, Att 30, TA 6, Haste 2, Waltz potency 10, and Crit 5 on its own hits
	}

	-- Worn over the idle set while you are asleep, for gear that wakes you. Empty, and declared so the engine
	-- finds it: a job file that replaces sets.Weapons drops the engine's empty one until the first action.
	sets.Weapons.Sleep = {}

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- The engaged set: Gleti's armor, with Nyame Helm on the head, since no Gleti's Mask is carried. Gear haste
	-- is 32% (Nyame Helm 6, Gleti's 14, Lehko's Ring 10, Gleti's Knife 2), past the 26% cap, so no piece here
	-- is picked for haste.
	sets.OffenseMode = {
		ammo = gear.coiste,							-- DA 3, STP 3
		head = gear.nyameHead,						-- Acc 40, Att 55, DA 2, DT 7 (Path B rank 20)
		body = gear.gletiBody,						-- Acc 40, Att 40, Crit 8, PDT 9, Regain 3
		hands = gear.gletiHands,					-- Acc 40, Att 40, Crit 6, PDT 7, Regain 2
		legs = gear.gletiLegs,						-- Acc 40, Att 40, Crit 7, PDT 8, Regain 3
		feet = gear.gletiFeet,						-- Acc 40, Att 40, Crit 4, PDT 5, Regain 2
		neck = gear.sanctity,						-- Acc 10, Att 10
		waist = gear.kentarchPlusOne,				-- Acc 14, DA 3
		left_ear = gear.brutal,						-- DA 5, STP 1
		right_ear = gear.skulkerEarringPlusOne,		-- Acc 11, TA 4, STP 3, Subtle Blow 6
		left_ring = gear.lehkoHabhokaRing,			-- STP 10, Crit 10, Haste 10
		right_ring = gear.rajas,					-- STP 5, Subtle Blow 5
		back = gear.solemnityCape,					-- DT 4, the only carried cape Thief can wear
	}	-- Acc 235, Att 225, Crit 35, Regain 10. Physical DT 40, magic DT 11.
	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {})

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- No idle set of its own yet: idle wears the engaged set. Every action's precast and midcast also start
	-- from this set, so a slot their sets leave out keeps its engaged piece.
	sets.Idle = set_combine(sets.OffenseMode, {})
	sets.Idle.TP = set_combine(sets.Idle, {})

	-- Worn while resting. Declared so the engine finds it: replacing sets.Idle drops the engine's own until the
	-- first action.
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is worn for every ability. No Thief ability has a set of its own yet.
	sets.JA = set_combine(sets.Idle, {})

	-- Dancer abilities, for a DNC subjob. Each family set is worn for its abilities. None of them swaps
	-- weapons, since new weapons reset TP.

	-- Steps land on melee hit rate, with Accuracy +10 of their own (bg-wiki, Step). This is the engaged set
	-- with the two carried pieces that add accuracy over it. Alabaster Earring and Murky Ring give the wearer
	-- accuracy only from their Path A rank, which isn't recorded, so they stay out.
	sets.Step = set_combine(sets.OffenseMode, {
		ammo = gear.honedTathlum,					-- Acc 15, over Coiste Bodhar's DA 3
		waist = gear.eschan,						-- Acc 15, Macc 7, over Kentarch Belt +1's Acc 14
	})	-- Acc 251, Macc 228

	-- Desperate and Violent Flourish also have to hit, and Violent Flourish's stun is resisted on magic
	-- accuracy (bg-wiki, Violent Flourish), which the Gleti's and Nyame pieces carry as well, Macc 40 each.
	-- No gear changes Animated, Reverse or Building Flourish from a subjob.
	sets.Flourish = set_combine(sets.Step, {})

	-- A Waltz heals (your CHR + the target's VIT) x a slope, halved for a subjob, plus a base, times Waltz
	-- potency (bg-wiki, Waltz). Gleti's Cuirass and Gleti's Knife give Waltz potency +10% each, 20% of the
	-- 50% cap, and the engaged set already wears both. No other carried piece Thief can wear has Waltz
	-- potency, and CHR alone is a secondary stat, so the set is the engaged set.
	sets.Waltz = set_combine(sets.OffenseMode, {})

	-- Jig and Samba effects come from the ability alone. Only Dancer gear changes them (their duration), so
	-- these keep the engaged set.
	sets.Jig = set_combine(sets.OffenseMode, {})
	sets.Samba = set_combine(sets.OffenseMode, {})

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Worn on every weaponskill: Nyame armor, built for Evisceration. Evisceration is five hits at fTP 1.25 with
	-- 50% DEX, plus one from the off hand, and TP raises its critical hit rate, so Moonshade Earring's TP Bonus
	-- helps it. Fotia Gorget and Fotia Belt add +25/256 fTP (about 8%) and Accuracy +10 to every hit. Weapon
	-- skill damage counts on the first hit only (bg-wiki, Weapon Skill Damage). The back keeps the engaged
	-- set's cape.
	sets.WS = {
		ammo = gear.coiste,							-- DA 3
		head = gear.nyameHead,						-- WSD 8, Acc 40, Att 55, DA 2 (Path B rank 20)
		body = gear.nyameBody,						-- WSD 10, Acc 40, Att 55, DA 3
		hands = gear.nyameHands,					-- Acc 40, Att 30, DEX 42 (rank 0)
		legs = gear.nyameLegs,						-- WSD 9, Acc 40, Att 55, DA 3
		feet = gear.nyameFeet,						-- WSD 8, Acc 40, Att 55, DA 2
		neck = gear.fotiaNeck,						-- Acc 10 and +25/256 fTP on every hit (latent)
		waist = gear.fotiaWaist,					-- Acc 10 and +25/256 fTP on every hit (latent)
		left_ear = gear.moonshade,					-- TP Bonus 250
		right_ear = gear.skulkerEarringPlusOne,		-- Acc 11, TA 4
		left_ring = gear.lehkoHabhokaRing,			-- Crit 10, DEX 10
		right_ring = gear.karieyh,					-- WS Acc 5, WSD 3
	}	-- Acc 236, Att 254, WSD 38, DA 13
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
function precast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while each action is in flight. The table it returns is merged over the engine's
-- midcast set, which is empty for abilities, weaponskills and items.
function midcast_custom(spell)
	local equipSet = {}

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
