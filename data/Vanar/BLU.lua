-- Vanar's Blue Mage, built on the Rahvin GearSwap 2.1 sample (data/common/Sample Job Files/BLU.lua).
-- Every piece named here comes from Vanar's //gs export, data/export/Vanar 2026-10-03 00-46-48.lua.
-- Sets favor, in order: accuracy, magic accuracy, weapon skill damage, attack, magic attack and
-- damage taken. Hashi. Earring +1 is always in the right ear, the only ear its sword and blue magic
-- skill bonuses work in. At Master Level 25 sword skill is past 600, where each point adds 0.9 accuracy
-- and 1 attack, so Hashishin Kavuk +3's Sword skill 30 is worth about Acc 27 and Att 30, and Hashi.
-- Earring +1's Sword skill 11 about Acc 10 and Att 11.
-- data/Vanar/Vanar_gear_list.md lists every piece this file, RDM.lua and THF.lua use.

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Vanar's settings for every job, such as Windower aliases.
include('Vanar-Globals')

-- The in-game lockstyle set, macro book and macro set this file applies on load.
LockStylePallet = "2"
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
state.OffenseMode:set('TP')

-- The spells, job abilities and weaponskills that wear sets.TreasureHunter against an untagged monster, along with
-- every ranged attack. In Tag mode nothing else wears it, melee included, and an action off the list does not count
-- as tagging. Delete the line to let every action tag.
TH_Whitelist = S { 'Glutinous Dart' }

-- Naming JobMode shows it in chat and on the status box. It and the job mode come before jobsetup, whose key list
-- reads UI_Name as it prints.
UI_Name = 'Mode'

-- Job mode. self_command_custom below loads the matching blue magic spell set and macro set when you cycle it.
-- AoE loads {sub}_mage and Melee loads {sub}_melee. Save these in AzureSets with //aset save <name>.
state.JobMode:options('AoE','Melee')
state.JobMode:set('Melee')

-- The engine sends /echo Change Complete with the lockstyle, about five seconds after a load or a subjob change,
-- which can be before the blue magic spell set starts loading. This file holds the echo back until the spell set
-- load has sent its //aset command (release_echo, below), so AzureSets' line that it is setting the spells comes
-- first. The engine runs in this file's environment, so replacing windower here with a copy whose send_command
-- takes the echo out reaches the engine's sends too. GearSwap's own windower table is untouched, and the next job
-- file gets a fresh environment.
local echo_held = false
local release_echo
do
	local send = windower.send_command
	windower = setmetatable({
		send_command = function(command)
			local rest, cut = command:gsub('input /echo Change Complete;?', '')
			send(rest)
			if cut > 0 then
				echo_held = true
				if release_echo then release_echo() end
			end
		end,
	}, { __index = windower })
end

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet, MacroBook, MacroSet)

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
    'Subduction', 'Tearing Gust', 'Tem. Upheaval', 'Tenebral Crush',
    'Thermal Pulse', 'Thunderbolt', 'Uproot', 'Water Bomb' }
BlueSkill = S { 'Atra. Libations', 'Diamondhide', 'Magic Barrier',
    'Metallic Body', 'Occultation', 'Plasma Charge', 'Pyric Bulwark', 'Reactor Cool' }
BlueBuff = S { 'Amplification', 'Animating Wail', 'Barrier Tusk', 'Battery Charge', 'Carcharian Verve',
    'Cocoon', 'Erratic Flutter', 'Fantod', 'Feather Barrier', 'Harden Shell',
    'Memento Mori', 'Mighty Guard', 'Nat. Meditation', 'O. Counterstance', 'Refueling',
    'Regeneration', 'Saline Coat', 'Triumphant Roar', 'Warm-Up', 'Winds of Promy.',
    'Zephyr Mantle' }
BlueHealing = S { 'Exuviation', 'Healing Breeze', 'Magic Fruit', 'Plenilune Embrace', 'Pollen', 'Restoral',
    'White Wind', 'Wild Carrot' }
BlueTank = S { 'Actinic Burst', 'Blank Gaze', 'Demoralizing Roar', 'Frightful Roar',
    'Geist Wall', 'Jettatura', 'Sheep Song', 'Soporific', 'Stinking Gas' }
BlueACC = S { '1000 Needles', 'Absolute Terror', 'Auroral Drape', 'Awful Eye',
    'Blistering Roar', 'Blood Drain', 'Blood Saber', 'Chaotic Eye', 'Cimicine Discharge',
    'Cold Wave', 'Corrosive Ooze', 'Cruel Joke', 'Digest', 'Dream Flower', 'Enervation',
    'Feather Tickle', 'Filamented Hold', 'Infrasonics', 'Light of Penance', 'Lowing',
    'MP Drainkiss', 'Mortal Ray', 'Osmosis', 'Reaving Wind', 'Sandspin', 'Sandspray',
    'Sound Blast', 'Temporal Shift', 'Venom Shell', 'Voracious Trunk', 'Yawn' }

-- The magic skills from a subjob that midcast_custom casts in sets.Weapons.Casting when you are not
-- engaged and the weapon lock is Unlocked. It does the same for the blue magic in BlueNuke, BlueACC,
-- BlueTank, BlueBreath and BlueHealing.
Casting_Skills = S { 'Enfeebling Magic', 'Elemental Magic', 'Dark Magic', 'Divine Magic', 'Healing Magic' }

-- The subjob spells named like a family set that holds only the slots it changes: sets.Midcast.Refresh
-- and sets.Midcast.Regen. midcast_custom puts the enhancing set back under them.
Family_Set_Spells = S { 'Refresh', 'Regen' }

-- Bio, Bio II and Bio III from a subjob leave the engine's enfeebling duration tier (interface.lua), which only
-- adds enfeebling-magic pieces, and stay on sets.Midcast.Dark. The list is changed in place so later engine
-- edits still apply.
for _, spell in ipairs({ 'Bio', 'Bio II', 'Bio III' }) do
	Enfeeble_Duration:remove(spell)
end

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Tizona','Tizona Acc','Black Halo','Black Halo Acc','Savage Blade','Savage Blade Acc','Chant du Cygne','Chant du Cygne Acc')
state.WeaponMode:set('Tizona')
-- Weapon lock at load. 'Locked' always holds the weapon mode's weapons, 'Unlocked' holds them only while engaged.
-- While Locked, sets.Weapons.Idle and sets.Weapons.Casting never go on. Alt+F9 toggles it.
state.WeaponLock:set('Locked')

-- Auto weaponskill choices, keyed by the weapon modes above. gs c AutoWS (F11) cycles OFF and the
-- current weapon mode's choices. It starts OFF and goes back to OFF when the weapon mode changes.
-- Moonshade Earring's TP Bonus +250, which the weapon skill sets wear, turns 1750 into 2000 and 2750 into
-- 3000, the cap. With Thibron's TP Bonus +1000 in the offhand, 1750 already reaches the cap, so those modes
-- stop at 1750. 'AM2' and 'AM3' build that Aftermath level first, then fire at 1000 while it lasts.
AutoWS_List = {
	['Tizona'] = { { 'Expiacion', 1000 }, { 'Expiacion', 1750 }, { 'Expiacion', 'AM2' }, { 'Expiacion', 'AM3' } },
	['Tizona Acc'] = { { 'Expiacion', 1000 }, { 'Expiacion', 1750 }, { 'Expiacion', 2750 }, { 'Expiacion', 'AM2' }, { 'Expiacion', 'AM3' } },
	['Black Halo'] = { { 'Black Halo', 1000 }, { 'Black Halo', 1750 } },
	['Black Halo Acc'] = { { 'Black Halo', 1000 }, { 'Black Halo', 1750 }, { 'Black Halo', 2750 } },
	['Savage Blade'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 } },
	['Savage Blade Acc'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 }, { 'Savage Blade', 2750 } },
	['Chant du Cygne'] = { { 'Chant du Cygne', 1000 }, { 'Chant du Cygne', 1750 } },
	['Chant du Cygne Acc'] = { { 'Chant du Cygne', 1000 }, { 'Chant du Cygne', 1750 }, { 'Chant du Cygne', 2750 } },
}
state.AutoWS:set('OFF')

-- Auto buff lists. gs c AutoBuff (F12) cycles OFF and Auto, and starts OFF. While Auto is
-- on, the engine casts the first buff below that you are missing, on yourself. When is Always, Engaged,
-- Idle, Combat or OutOfCombat. Engaged means weapons drawn; Combat means in battle (battle music on),
-- engaged or not. The engine checks that a spell is learned, not that a blue magic spell is set, so
-- Erratic Flutter, Nat. Meditation and Cocoon must be in the spell set. Mighty Guard goes through the
-- Unbridled Learning and Diffusion handling in pretarget_custom.
AutoBuff_List = {
	Auto = {
		{ Name = 'Erratic Flutter', Buff = 'Haste', When = 'Always' },
		--{ Name = 'Battery Charge', Buff = 'Refresh', When = 'Idle' },
		--{ Name = 'Refresh', Buff = 'Refresh', When = 'Idle' },
		{ Name = 'Nat. Meditation', Buff = 'Attack Boost', When = 'Engaged' },
		{ Name = 'Cocoon', Buff = 'Defense Boost', When = 'Engaged' },
		-- Last: while Unbridled Learning is on recast, pretarget_custom aborts it, and an entry below it would
		-- never be reached.
		{ Name = 'Mighty Guard', Buff = 'Mighty Guard', When = 'Combat' },
	},
}

-- Blue magic that needs Unbridled Learning or Unbridled Wisdom up before it can be cast: the 18 spells
-- that take no set points.
Unbridled_Spells = S { 'Absolute Terror', 'Bilgestorm', 'Blistering Roar', 'Bloodrake', 'Carcharian Verve',
	'Cesspool', 'Crashing Thunder', 'Cruel Joke', 'Droning Whirlwind', 'Gates of Hades', 'Harden Shell',
	'Mighty Guard', 'Polar Roar', 'Pyric Bulwark', 'Tearing Gust', 'Thunderbolt', 'Tourbillion', 'Uproot' }

-- Blue magic that uses Diffusion first, when it is ready and not already up, so the buff reaches the party.
Diffusion_Spells = S { 'Mighty Guard', 'Harden Shell' }

-- Physical blue magic that needs Chain Affinity up or ready (the spell is dropped otherwise), and that also uses
-- Efflux first when it is ready and not already up.
Chain_Affinity_Spells = S { 'Sinker Drill' }

-- The last time pretarget_custom said Unbridled Learning was not ready, so a cast AutoBuff retries every
-- 3 seconds prints it once every 30 seconds at most.
local unbridled_abort_said = nil
-- The spell pretarget_custom sends again after its abilities, set as that send goes out, so that send
-- alone passes untouched, and the os.clock() time until which other blue magic presses are dropped while
-- the abilities go up.
local blu_refire, blu_lock_until = nil, 0

-- Vanar's own copies. Library entries cover everything else. Augments are written exactly as
-- //gs export printed them, so each entry matches only that copy.
gear.rosmertaDA = hp_gear("Rosmerta's Cape", 0, {
	augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Damage taken-5%', } }) -- Acc 30, Att 20, DA 10, DT 5
gear.rosmertaWSD = hp_gear("Rosmerta's Cape", 0, {
	augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', } })           -- Acc 20, Att 20, WSD 10
gear.rosmertaCrit = hp_gear("Rosmerta's Cape", 0, {
	augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Crit.hit rate+10', } })                   -- Acc 20, Att 20, DEX 30, Crit 10
gear.rosmertaMAB = hp_gear("Rosmerta's Cape", 0, {
	augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', '"Mag.Atk.Bns."+10', } })        -- Macc 30, MAB 10, MDmg 20
gear.telchineGlovesDuration = hp_gear("Telchine Gloves", 52, {
	augments = { 'Haste+3', 'Enh. Mag. eff. dur. +10', } })                                              -- Enhancing duration 10, Cure 10
gear.cornflower = mp_gear("Cornflower Cape", 29)                                                         -- Macc 15, MAB 15, Blue magic skill 15
gear.kentarchPlusOne = hp_gear("Kentarch Belt +1", 0)                                                    -- Acc 14, DA 3
gear.njordr = hp_gear("Njordr Earring", 0)                                                               -- Blue magic skill 10
gear.honedTathlum = hp_gear("Honed Tathlum", 0)                                                          -- Acc 15
gear.whiteRarabCap = hp_gear("Wh. Rarab Cap +1", 0)                                                      -- Treasure Hunter 1
-- Two copies of one ring, worn as a pair or one at a time. A set wearing both should not directly follow
-- a set wearing one: GearSwap's copy matching (equip_processing.lua, unpack_equip_list) can then pick the
-- copy already worn for the other slot. If one ever fails to equip, pin each to the bag it lives in, for
-- example hp_gear("Stikini Ring", 0, { bag = "wardrobe" }) and { bag = "wardrobe2" }.
gear.stikini1 = hp_gear("Stikini Ring", 0) -- Macc 8, all magic skills 5
gear.stikini2 = hp_gear("Stikini Ring", 0)
gear.telchineBodyRegen = hp_gear("Telchine Chas.", 54, {
	augments = { '"Regen" potency+3', } })                                       -- Regen potency 3, Regen duration +12s, Enhancing skill 12
gear.telchineHandsRegen = hp_gear("Telchine Gloves", 52, {
	augments = { '"Regen" potency+3', } })                                       -- Regen potency 3
gear.telchineFeetRegen = hp_gear("Telchine Pigaches", 13, {
	augments = { '"Regen" potency+3', } })                                       -- Regen potency 3
gear.pukulatmujPlusOne = rank_gear("Pukulatmuj +1", 100)                         -- Enhancing skill 11, Stoneskin casting time -11%
gear.enhancingTorque = hp_gear("Enhancing Torque", 0)                            -- Enhancing skill 7
gear.fiFolletPlusOne = mp_gear("Fi Follet Cape +1", 45, {
	augments = { 'Path: A', } })                                                 -- Enhancing skill 9; rank 11: Fast Cast 8, SIRD -3
gear.chelonaBoots = mp_gear("Chelona Boots", 35)                                 -- Fast Cast 4
gear.maviTathlum = hp_gear("Mavi Tathlum", 0)                                    -- Blue magic skill 5, breath damage +5%
gear.coladaRefresh = rank_gear("Colada", 100, {
	augments = { '"Refresh"+2', 'Mag. Acc.+11', '"Mag.Atk.Bns."+12', 'DMG:+1', } }) -- Refresh 2
gear.fucho = mp_gear("Fucho-no-Obi", 30)                                         -- Refresh 1 while MP is below half of max MP without ear, ring and back MP (latent)

function get_sets()

	-- Weapon sets, one per weapon mode. Thibron's TP Bonus +1000 backs every weapon skill mode, and the Acc
	-- modes trade it for a more accurate offhand: Almace, Naegling when Almace is the main, or Bunzi's Rod for
	-- Black Halo. With the weapon lock
	-- Locked, as this file loads, they are worn at all times. Unlocked, they are worn while engaged, and while not
	-- engaged choose_set_custom swaps in sets.Weapons.Idle, which costs whatever TP is left when you disengage.
	sets.Weapons = {}

	sets.Weapons['Tizona'] = {		-- Expiacion
		main = gear.tizona,
		sub = gear.thibron,
	}

	sets.Weapons['Tizona Acc'] = {	-- Expiacion
		main = gear.tizona,
		sub = gear.almace,
	}

	sets.Weapons['Black Halo'] = {	-- Black Halo
		main = gear.maxentius,
		sub = gear.thibron,
	}

	-- The offhand needs Dual Wield from set blue magic, as every offhand weapon here does.
	sets.Weapons['Black Halo Acc'] = {	-- Black Halo
		main = gear.maxentius,
		sub = gear.bunzi,			-- Acc 40
	}

	sets.Weapons['Savage Blade'] = {
		main = gear.naegling,
		sub = gear.thibron,
	}

	sets.Weapons['Savage Blade Acc'] = {
		main = gear.naegling,
		sub = gear.almace,
	}

	sets.Weapons['Chant du Cygne'] = {
		main = gear.almace,
		sub = gear.thibron,
	}

	sets.Weapons['Chant du Cygne Acc'] = {
		main = gear.almace,
		sub = gear.naegling,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active, as right after a job
	-- or subjob change, before the blue magic that gives Dual Wield is set. The game refuses a weapon in sub
	-- without the trait, with an error in chat, and no shield is in this file's gear, so the offhand is emptied.
	-- The engine reads the trait on a load, on a subjob change and every 30 seconds. While a spell set loads,
	-- watch_dual_wield also rereads it, so the swords go on as soon as the trait is back. The engine reads this set
	-- on every idle and engaged build, and without it says "sets.Weapons.Shield not found".
	sets.Weapons.Shield = { sub = empty }

	-- Worn over the idle set while you are asleep, for gear that wakes you. Empty, and declared so the engine finds
	-- it, as above.
	sets.Weapons.Sleep = {}

	-- Worn whenever you are not engaged, in every weapon mode, while the weapon lock is Unlocked. choose_set_custom
	-- puts it on. Archduke's Shield is not a BLU item, so the offhand stays the weapon mode's.
	sets.Weapons.Idle = {
		main = gear.coladaRefresh, -- Refresh 2
	}

	-- Worn for the casts midcast_custom names while you are not engaged and the weapon lock is Unlocked.
	sets.Weapons.Casting = {
		main = gear.bunzi,				-- Macc 40, MAB 35, Cure 30, Magic Accuracy skill 255
		sub = gear.maxentius,			-- Macc 40, MAB 21. Its Magic Accuracy skill and its magic burst bonus (+4% per skillchain step) only count in the main hand.
	}

	-- Worn whenever you are not engaged. It is also the floor under every action, so a slot an action's sets leave unnamed keeps its idle piece.
	sets.Idle = {
		ammo = gear.pemphredoTathlum,			-- Macc 8, MAB 4, Conserve MP 4
		head = gear.rawhideHeadPathB,			-- Refresh 1, HP 86
		body = gear.hashishinBodyPlusThree,		-- DT 13, Refresh 4
		hands = gear.hashishinHandsPlusThree,	-- DT 10
		legs = gear.hashishinLegsPlusThree,		-- DT 12
		feet = gear.hashishinFeetPlusThree,		-- Magic evasion 157
		neck = gear.sibylScarf,					-- Refresh 1 for a citizen of Windurst
		waist = gear.flumeBelt,					-- PDT 4, and 2% of damage taken comes back as MP
		left_ear = gear.alabaster,				-- DT 5, HP 100
		right_ear = gear.etiolation,			-- HP 50, MP 50, MDT 3
		left_ring = gear.karieyh,				-- Regain 5
		right_ring = gear.murky,				-- DT 10
		back = gear.rosmertaDA,					-- DT 5
	}	-- DT 55, PDT 4 and MDT 3: physical 59 and magic 58, each capped at 50. Refresh 6, and 8 with sets.Weapons.Idle.
	-- Idle sets for each offense mode, merged over the idle set.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})

	-- Worn while resting. Declared so the engine finds it: replacing sets.Idle drops the engine's own until the
	-- first action.
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- Worn over the idle set while a Phantom Roll on you stands at 11, for a ring such as Roller's Ring.
	sets.Idle.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathD,	-- Movement speed 18%
	}

	-- Merged over the idle set while Fucho-no-Obi's latent Refresh +1 works, a little below 50% MP; choose_set_custom puts it on. It takes Flume Belt's PDT 4, so idle physical DT is 55 meanwhile.
	sets.LowMP = {
		waist = gear.fucho,					-- Refresh 1 (latent)
	}

	-- The ring slot Zodiac Ring goes in when an elemental spell matches the day: "right_ring" or "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set merges over it.
	-- Gear haste is 33% in ACC and DT and 42% in TP (Sailfi Belt +1 adds 9), past the 26% cap either way, so no
	-- piece here is picked for haste.
	sets.OffenseMode = {
		ammo = gear.coiste,							-- DA 3, STP 3
		head = gear.hashishinHeadPlusThree,			-- Acc 61, Att 61, Sword skill 30
		body = gear.hashishinBodyPlusThree,			-- Acc 64, Att 64, DT 13
		hands = gear.hashishinHandsPlusThree,		-- Acc 62, Att 62, DT 10
		legs = gear.hashishinLegsPlusThree,			-- Acc 63, Att 63, DT 12
		feet = gear.nyameFeet,						-- Acc 40, Att 55, DA 2, DT 7 (Path B)
		neck = gear.mirageStolePlusTwo,				-- Acc 25
		waist = gear.kentarchPlusOne,				-- Acc 14, DA 3
		left_ear = gear.brutal,						-- DA 5
		right_ear = gear.hashishinEarringPlusOne,	-- Acc 12, DA 4, Sword skill 11
		left_ring = gear.lehkoHabhokaRing,			-- STP 10, Crit 10
		right_ring = gear.rajas,					-- STP 5, Subtle Blow 5
		back = gear.rosmertaDA,						-- Acc 30, Att 20, DA 10, DT 5
	}	-- Acc 371, Att 325, DT 47

	-- Sailfi Belt +1 trades Kentarch Belt +1's Acc 14 for multi-attack and Attack. ACC and DT keep Kentarch.
	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {
		waist = gear.sailfi,						-- TA 2, DA 5, STR 15 (Path A), Att 10-15 (Unity)
	})	-- Acc 357, Att 335-340, DT 47

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {
		ammo = gear.honedTathlum,					-- Acc 15
		feet = gear.hashishinFeetPlusThree,			-- Acc 60, Att 60
		right_ring = gear.ayanmoRing,				-- Acc 6, DT 3
	})	-- Acc 412, DT 43

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		right_ring = gear.murky,					-- DT 10
	})	-- DT 57 (cap 50)

	-- Fast cast, worn at the start of every spell. A Quick Magic proc finishes the spell before the midcast
	-- swap, so the spell lands in this set. Witful Belt is the only Quick Magic piece left, kept because it
	-- is the only waist with Fast Cast that BLU can wear.
	sets.Precast = {}
	sets.Precast.FastCast = {
		head = gear.amalricCoifPlusOne,		-- FC 11
		body = gear.luhlazaBodyPlusOne,		-- FC 7
		hands = gear.pingaHands,			-- FC 5
		legs = gear.enifLegs,				-- FC 8
		waist = gear.witful,				-- FC 3, Quick Magic 3
		left_ear = gear.loquacious,			-- FC 2
		right_ear = gear.etiolation,		-- FC 1
		left_ring = gear.prolix,			-- FC 2
		right_ring = gear.najiLoop,			-- FC 1
		back = gear.fiFolletPlusOne,		-- FC 8 (rank 11)
		feet = gear.chelonaBoots,			-- FC 4
	}	-- FC 52. Ammo and neck keep the idle set's pieces.

	-- Merged over the fast-cast set for blue magic.
	sets.Precast.BlueMagic = set_combine(sets.Precast.FastCast, {
		body = gear.hashishinBodyPlusThree,	-- Blue magic casting time -16
	})

	-- Merged over the fast-cast set for every enhancing spell. Fast cast, casting time cuts and the Fast
	-- Cast trait add up to an 80% cap. The trait is 5 to 25% from set blue magic such as Erratic Flutter,
	-- or 15% from a RDM subjob, whichever is higher.
	sets.Precast.Enhancing = {
		waist = gear.siegel,				-- Enhancing magic casting time -8
	}	-- 57% from gear

	-- Stoneskin from a WHM or RDM subjob, over sets.Precast.Enhancing.
	sets.Precast["Stoneskin"] = {
		main = gear.pukulatmujPlusOne,		-- Stoneskin casting time -11
		legs = gear.doyenLegs,				-- Stoneskin casting time -10
	}	-- 70% from gear, so any Fast Cast trait of 10% or more reaches the cap

	-- Cure spells from a WHM or RDM subjob, over the fast-cast set. Each Cure casting time piece cuts more
	-- than the fast cast it replaces: Doyen Pants for Enif Cosciales and Mendi. Earring for Etiolation
	-- Earring. Recast is set by the midcast set, so nothing here costs any.
	sets.Precast.Cure = {
		legs = gear.doyenLegs,				-- Cure spellcasting time -15
		right_ear = gear.mendicantEarring,	-- Cure spellcasting time -5
	}	-- 63% from gear (fast cast 43, Cure spellcasting time -20), so any Fast Cast trait of 17% or more reaches the cap

	-- Job abilities. sets.JA is worn for every job ability, and the set named for the ability merges over it.
	sets.JA = set_combine(sets.Idle, {})
	sets.JA["Azure Lore"] = {
		hands = gear.luhlazaHandsPlusOne,	-- Enhances Azure Lore
	}
	-- Chain Affinity's TP Bonus gains +50 per Enchainment merit from this body, +250 at Vanar's 5. bg-wiki
	-- doesn't say whether that is read when the ability is used or when the spell goes off. Sinker Drill
	-- keeps Hashishin Mintan +3's accuracy and attack, so only the ability wears it.
	sets.JA["Chain Affinity"] = {
		body = gear.luhlazaBodyPlusOne,		-- Enhances Enchainment
	}
	-- When Luhlaza Charuqs +1's Diffusion augment is read is disputed, so the ability wears them as well as the
	-- diffused spell (sets.Diffusion).
	sets.JA["Diffusion"] = {
		feet = gear.luhlazaFeetPlusOne,		-- Enhances Diffusion
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

	-- Fast Recast, for spells no potency gear helps: the fixed-potency blue buffs and Utsusemi. Battery Charge
	-- takes it too, with Refresh potency from Amalric Coif +1, which the set already wears for its haste and FC.
	-- Recast is base x (1 - haste) x (1 - floor(Fast Cast / 2) / 100), so the set reaches the gear haste cap
	-- (256/1024) and then takes all the Fast Cast it can. It drops idle DT for the cast.
	sets.Midcast.FastRecast = set_combine(sets.Midcast, {
		head = gear.amalricCoifPlusOne,			-- Haste 6, FC 11
		body = gear.luhlazaBodyPlusOne,			-- Haste 4, FC 7
		hands = gear.hashishinHandsPlusThree,	-- Haste 3, Blue magic recast -16%
		legs = gear.enifLegs,					-- Haste 5, FC 8
		feet = gear.chelonaBoots,				-- FC 4
		waist = gear.witful,					-- Haste 3, FC 3
		left_ear = gear.loquacious,				-- FC 2
		right_ear = gear.etiolation,			-- FC 1
		left_ring = gear.prolix,				-- FC 2
		right_ring = gear.lehkoHabhokaRing,		-- Haste 10
		back = gear.fiFolletPlusOne,			-- FC 8 (rank 11)
	})	-- Haste 31, past the cap, FC 46 and Blue magic recast -16%: with a Fast Cast trait of 15 to 25 the recast is
	-- 44 to 41% of base, against 58 to 55% in the idle set. Ammo and neck keep the idle set's pieces.

	-- Utsusemi from a NIN subjob. Blue magic recast does nothing for ninjutsu, so Pinga Mittens' FC 5 takes the hands.
	sets.Midcast.Utsusemi = set_combine(sets.Midcast.FastRecast, {
		hands = gear.pingaHands,				-- FC 5
	})

	-- Cure spells from a WHM or RDM subjob. Cast while not engaged, sets.Weapons.Casting adds Cure 30.
	sets.Midcast.Cure = set_combine(sets.Midcast, {
		hands = gear.telchineGlovesDuration,	-- Cure 10
		right_ear = gear.mendicantEarring,		-- Cure 5
		right_ring = gear.najiLoop,				-- Cure potency II 1, Cure 1
		back = gear.solemnityCape,				-- Cure 7, DT 4
	})	-- Cure 23, and 53 with sets.Weapons.Casting (cap 50), plus Cure potency II 1
	sets.Midcast.Curaga = set_combine(sets.Midcast.Cure, {})

	-- Cursna from a WHM subjob, worn over sets.Midcast.Enhancing. "Cursna"+ and Healing magic skill raise its chance
	-- to remove Doom. Empty for now.
	sets.Midcast.Cursna = {}

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
	-- Elemental barspells rise with enhancing skill up to 500, far above a subjob's, so they take the skill set.
	sets.Midcast.Enhancing.Elemental = set_combine(sets.Midcast.Enhancing.Skill, {})
	sets.Midcast.Enhancing.Status = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.Phalanx = set_combine(sets.Midcast.Enhancing.Skill, {})

	-- Regen and Refresh put potency first, then duration, then recast. These sets name only the slots they
	-- change, for the engine to merge over the enhancing set. The spells called Regen and Refresh would
	-- wear them alone, so midcast_custom puts the enhancing set back under them.
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
		left_ear = gear.moonshade,					-- Att 4. TP Bonus 250 only under Chain Affinity, where bg-wiki's pages disagree; Efflux uses no TP
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
		left_ring = gear.stikini1,					-- Macc 8, all magic skills 5
		right_ring = gear.stikini2,					-- Macc 8, all magic skills 5
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

	-- Spells whose potency scales with blue magic skill, such as Occultation, Magic Barrier, Diamondhide and
	-- Metallic Body.
	sets.Midcast.BlueMagic.Skill = set_combine(sets.Midcast, {
		ammo = gear.maviTathlum,					-- Blue magic skill 5
		head = gear.luhlazaHeadPlusOne,				-- Blue magic skill 13
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

	-- Breath spells scale with current HP, which HP gear put on at midcast raises only as a maximum, not as HP
	-- you have (inferred from bg-wiki's breath formulas). So they keep the accuracy set, which Bad Breath and
	-- Magnetite Cloud need to land, and trade Kavuk +3's Macc 61 for breath damage.
	sets.Midcast.BlueMagic.Breath = set_combine(sets.Midcast.BlueMagic.ACC, {
		ammo = gear.maviTathlum,					-- Breath damage +5%, Blue magic skill 5
		head = gear.luhlazaHeadPlusOne,				-- Breath damage dealt +20%, Blue magic skill 13
	})

	-- Fixed-potency buffs gain nothing from potency gear, so they take the Fast Recast set. Enmity spells such as
	-- Jettatura and Geist Wall need to land.
	sets.Midcast.BlueMagic.Buff = set_combine(sets.Midcast.FastRecast, {})
	sets.Midcast.BlueMagic.Enmity = set_combine(sets.Midcast.BlueMagic.ACC, {})
	-- Healing blue magic heals by the multi-target cure formula, 3 x MND + VIT with Cure potency on top, and blue
	-- magic skill does nothing for it. Restoral is the exception and has its own set below.
	sets.Midcast.BlueMagic.Healing = set_combine(sets.Midcast, {
		head = gear.hashishinHeadPlusThree,			-- MND 35, VIT 28
		body = gear.hashishinBodyPlusThree,			-- MND 45, VIT 30
		hands = gear.telchineGlovesDuration,		-- Cure 10, MND 33, VIT 23
		legs = gear.hashishinLegsPlusThree,			-- MND 43, VIT 20
		feet = gear.hashishinFeetPlusThree,			-- MND 32, VIT 22
		right_ear = gear.mendicantEarring,			-- Cure 5
		left_ring = gear.najiLoop,					-- Cure 1, Cure potency II 1
		right_ring = gear.stikini1,					-- MND 5
		back = gear.solemnityCape,					-- Cure 7
	})	-- Cure 23, and 53 with sets.Weapons.Casting (cap 50), plus Cure potency II 1

	-- Magic from a subjob: nukes take the blue nuke set, and enfeebles, dark and divine magic the accuracy set.
	-- Blue magic skill does nothing for those, so Njordr Earring gives way to Alabaster Earring and Assim. Jubbah +4
	-- to Hashishin Mintan +3. Enfeebles also take Rumination Sash's enfeebling skill; dark and divine magic keep
	-- Eschan Stone.
	sets.Midcast.Nuke = set_combine(sets.Midcast.BlueMagic.Nuke, {})
	sets.Midcast.Burst = set_combine(sets.Midcast.BlueMagic.Nuke, {})
	sets.Midcast.Enfeebling = set_combine(sets.Midcast.BlueMagic.ACC, {
		body = gear.hashishinBodyPlusThree,			-- Macc 64, INT 45, MND 45
		waist = gear.ruminationSash,				-- Macc 3, Enfeebling skill 7, MND 4
		left_ear = gear.alabaster,					-- Macc up to 15 (Path A, by rank), DT 5
	})
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Duration = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {
		waist = gear.eschan,						-- Macc 7
	})
	sets.Midcast.Aspir = set_combine(sets.Midcast.Dark, {})
	sets.Midcast.Drain = set_combine(sets.Midcast.Dark, {})
	sets.Midcast.Divine = set_combine(sets.Midcast.Dark, {})

	-- Sets named for one spell. Each replaces the family set for that spell.

	-- Battery Charge is a refresh spell you cast, so Refresh potency gear raises it (bg-wiki, Amalric Coif +1).
	sets.Midcast["Battery Charge"] = set_combine(sets.Midcast.BlueMagic.Buff, {
		head = gear.amalricCoifPlusOne,			-- Refresh potency +2
	})

	-- Restoral heals more with Blue Magic skill (2 skill for 1 HP), unlike the other blue heals, so it takes the
	-- skill set with Cure pieces in four of its slots. It stays on BlueHealing for the casting weapons.
	sets.Midcast["Restoral"] = set_combine(sets.Midcast.BlueMagic.Skill, {
		hands = gear.telchineGlovesDuration,	-- Cure 10
		left_ear = gear.mendicantEarring,		-- Cure 5
		left_ring = gear.najiLoop,				-- Cure 1, Cure potency II 1
		back = gear.solemnityCape,				-- Cure 7
	})	-- Cure 23, and 53 with sets.Weapons.Casting (cap 50), plus Cure potency II 1

	-- White Wind heals floor(MaxHP/7)*2, raised by cure potency, so this is max HP plus cure potency.
	sets.Midcast["White Wind"] = {
		head = gear.nyameHead,					-- HP 91
		body = gear.nyameBody,					-- HP 136
		hands = gear.telchineGlovesDuration,	-- Cure 10
		legs = gear.nyameLegs,					-- HP 114
		feet = gear.nyameFeet,					-- HP 68
		neck = gear.sanctity,					-- HP 35
		waist = gear.flumeBelt,					-- No HP. Plat. Mog. Belt's HP+10% here was worth about 10% more healing
		left_ear = gear.alabaster,				-- HP 100
		right_ear = gear.mendicantEarring,		-- Cure 5: about 2% more healing than Etiolation Earring's HP 50, but
												-- about 0.5% less with the casting weapons on, past the Cure cap
		left_ring = gear.najiLoop,				-- Cure 1, Cure potency II 1
		back = gear.solemnityCape,				-- Cure 7
	}	-- Cure 23, and 53 with sets.Weapons.Casting (cap 50), plus Cure potency II 1. White Wind is on BlueHealing so
	-- midcast_custom gives it the casting weapons.

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
	-- Cuffs +2 stand in for its Path B Nyame Gauntlets, since Vanar's have no path, Hashi. Earring +1 for
	-- Hoxne Earring and Karieyh Ring for Beithir Ring. Nyame values are Path B at rank 20.
	-- The legs are Luhlaza Shalwar +4 in place of its Nyame Flanchard, for 3 more WSD and 10 more accuracy
	-- at the cost of Att 55 and DA 3, and the body Assimilator's Jubbah +4 in place of its Nyame Mail, for
	-- 2 more WSD, 20 more accuracy and 25 more DEX at the cost of Att 55 and DA 3.
	sets.WS = {
		ammo = gear.coiste,							-- Att 15, STR 10, DEX 10, DA 3 (Path A)
		head = gear.hashishinHeadPlusThree,			-- WSD 12, Acc 61, Att 61, Sword skill 30
		body = gear.assimilatorBodyPlusFour,		-- WSD 12, Acc 60, DEX 49, STR 39
		hands = gear.jhakriHandsPlusTwo,			-- WSD 7, Acc 43, Att 43
		legs = gear.luhlazaLegsPlusFour,			-- WSD 12, Acc 50, STR 46
		feet = gear.nyameFeet,						-- WSD 8, DA 2, Acc 40, Att 55
		neck = gear.mirageStolePlusTwo,				-- STR 25, DEX 25 (Path A), Acc 25
		waist = gear.sailfi,
		left_ear = gear.moonshade,					-- TP Bonus 250
		right_ear = gear.hashishinEarringPlusOne,	-- Acc 12, Sword skill 11
		left_ring = gear.epimanondas,				-- WSD 5
		right_ring = gear.karieyh,					-- WSD 3, WS Acc 5
		back = gear.rosmertaWSD,					-- WSD 10, Acc 20, Att 20
	}

	-- Merged in ACC mode after the set named for the weaponskill, so its slots win. A weaponskill with an ACC set of its own skips it.
	-- The feet stay Nyame Sollerets (WSD 8, Acc 40). Hashishin Basmak +3 would trade their WSD 8 for 20 more accuracy.
	sets.WS.ACC = {
		hands = gear.hashishinHandsPlusThree,		-- Acc 62
		waist = gear.kentarchPlusOne,				-- Acc 14
	}

	-- MAB is not an offense mode. It is the shared table for the magical weaponskills below.
	sets.WS.MAB = {
		ammo = gear.pemphredoTathlum,				-- Macc 8, MAB 4
		head = gear.hashishinHeadPlusThree,			-- WSD 12, MAB 51
		body = gear.nyameBody,						-- WSD 10 (Path B), MAB 30
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

	-- Seraph Blade and Red Lotus Blade gain damage with TP, so the TP Bonus earring goes back in. Flash Nova's
	-- damage doesn't change with TP. All three have skillchain properties, so Fotia Belt's latent works on them:
	-- +25/256 fTP and Macc 10, over Eschan Stone's Macc 7 and MAB 7. Sanguine Blade has no property.
	sets.WS['Seraph Blade'] = set_combine(sets.WS.MAB, { left_ear = gear.moonshade, waist = gear.fotiaWaist })
	sets.WS['Red Lotus Blade'] = set_combine(sets.WS.MAB, { left_ear = gear.moonshade, waist = gear.fotiaWaist })
	sets.WS['Flash Nova'] = set_combine(sets.WS.MAB, { waist = gear.fotiaWaist })

	-- In ACC mode these magical weaponskills raise magic accuracy instead of taking sets.WS.ACC, whose
	-- Kentarch Belt +1 would replace their waist. Hashishin Bazubands +3 trade Jhakri
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
		right_ring = gear.rajas,					-- STP 5, Subtle Blow 5
		back = gear.rosmertaCrit,					-- Crit 10, DEX 30, Acc 20, Att 20
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
		right_ring = gear.rajas,
		back = gear.rosmertaDA,						-- Acc 30, DA 10
	}

	-- In ACC mode these keep their own set instead of taking sets.WS.ACC, whose Kentarch Belt +1 would replace
	-- Fotia Belt. Its latent already gives every hit of these weapon skills Accuracy +10 and +25/256 fTP. Chant du
	-- Cygne still takes sets.WS.ACC's Hashishin Bazubands +3; Requiescat already wears them.
	sets.WS['Chant du Cygne'].ACC = set_combine(sets.WS['Chant du Cygne'], {
		hands = gear.hashishinHandsPlusThree,		-- Acc 62
	})
	sets.WS['Requiescat'].ACC = set_combine(sets.WS['Requiescat'], {})

	-- Treasure Hunter gear. In Tag mode it is worn only for an action TH_Whitelist lists, aimed at a monster not yet tagged, never just for being engaged. Full Time also wears it whenever engaged. TH Mode starts in Tag, Alt+F11 cycles it, and None turns it off.
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

	-- Merged over the blue magic set while Diffusion is up. A spell with a set of its own above does not take it,
	-- so a blue buff with its own set names it as that set's Diffusion child, which the engine merges while the
	-- buff is up.
	sets.Diffusion = {
		feet = gear.luhlazaFeetPlusOne,	-- Enhances Diffusion
	}
	sets.Midcast["Battery Charge"].Diffusion = sets.Diffusion

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Whether the job traits include Dual Wield (trait 18) now, from the subjob or from set blue magic. It reads the
-- game, not the engine's copy, which the engine refreshes only on a load, a subjob change and every 30 seconds.
local function has_dual_wield()
	local abilities = windower.ffxi.get_abilities()
	return abilities ~= nil and abilities.job_traits ~= nil and table.contains(abilities.job_traits, 18)
end

-- Called when the player's subjob changes.
-- Here, it reloads the AzureSets spell set for the new subjob and the current job mode.
-- It waits for the game to finish the change, because a main job change also fires this while this file is still loaded.
function sub_job_change_custom(new, old)
	queue_azure_set(5)
end

-- Called before each action, after the engine's own checks. Cancel the action here with cancel_spell(). Nothing it returns is used.
function pretarget_custom(spell,action)
	-- Automatic Unbridled Learning, Diffusion, Chain Affinity and Efflux, as in the old file. A spell from the
	-- lists above that needs one of them is dropped, the abilities go up 1.1 seconds apart, and the spell
	-- is sent again 1.1 seconds after them. That second send always passes, whether or not the abilities
	-- landed, so the hook never loops, and other blue magic pressed meanwhile is dropped. Nothing starts
	-- while the engine is busy, since its busy gate would refuse the first ability, or while the spell
	-- itself is recasting. An unbridled spell is dropped with a message when Unbridled Learning (ability
	-- recast 81) is not ready, and a Chain Affinity spell when Chain Affinity (181) is not. Diffusion (184)
	-- and Efflux (185) are used only when ready. Every check reads the live buffs and recasts, never a
	-- cached flag, so nothing can stick until a reload.
	if spell.type ~= 'BlueMagic' then return end
	-- Silenced, the spell would fail after its abilities went up and onto their recasts, so none is used.
	if buffactive['Silence'] or buffactive['Mute'] or buffactive['Omerta'] then return end
	-- Under Amnesia or Impairment the abilities themselves fail. A Chain Affinity spell without Chain Affinity up
	-- is still dropped, as it is when Chain Affinity isn't ready; anything else goes ahead without its abilities.
	if buffactive['Amnesia'] or buffactive['Impairment'] then
		if Chain_Affinity_Spells:contains(spell.english) and not buffactive['Chain Affinity'] then
			cancel_spell()
			add_to_chat(123, 'Abort: Chain Affinity can\'t be used.')
		end
		return
	end
	local now = os.clock()
	if now >= blu_lock_until then blu_refire = nil end
	if blu_refire == spell.english then
		blu_refire, blu_lock_until = nil, 0
		return
	end
	if now < blu_lock_until then
		cancel_spell()
		return
	end
	local recasts = windower.ffxi.get_ability_recasts()
	local unbridled = Unbridled_Spells:contains(spell.english)
		and not buffactive['Unbridled Learning'] and not buffactive['Unbridled Wisdom']
	local diffusion = Diffusion_Spells:contains(spell.english) and not buffactive['Diffusion']
		and recasts[184] == 0
	local chain = Chain_Affinity_Spells:contains(spell.english)
	local chain_affinity = chain and not buffactive['Chain Affinity']
	local efflux = chain and not buffactive['Efflux'] and recasts[185] == 0
	if not (unbridled or diffusion or chain_affinity or efflux) then return end
	if ((windower.ffxi.get_spell_recasts()[spell.recast_id] or 0) / 60) > 1 then return end
	if unbridled and recasts[81] ~= 0 then
		cancel_spell()
		if not unbridled_abort_said or now - unbridled_abort_said > 30 then
			unbridled_abort_said = now
			add_to_chat(123, 'Abort: Unbridled Learning not active.')
		end
		return
	end
	if chain_affinity and recasts[181] ~= 0 then
		cancel_spell()
		add_to_chat(123, 'Abort: Chain Affinity not ready.')
		return
	end
	cancel_spell()
	if is_Busy then return end
	local abilities = {}
	if unbridled then abilities[#abilities + 1] = 'Unbridled Learning' end
	if diffusion then abilities[#abilities + 1] = 'Diffusion' end
	if chain_affinity then abilities[#abilities + 1] = 'Chain Affinity' end
	if efflux then abilities[#abilities + 1] = 'Efflux' end
	local delay = 0
	for _, ability in ipairs(abilities) do
		coroutine.schedule(function() windower.send_command('input /ja "' .. ability .. '" <me>') end, delay)
		delay = delay + 1.1
	end
	local name, target = spell.english, spell.target.raw or '<me>'
	blu_lock_until = now + delay + 1
	coroutine.schedule(function()
		blu_refire = name
		windower.send_command('input /ma "' .. name .. '" ' .. target)
	end, delay)
end
-- Gear returned here merges over the engine's precast set for the action.
function precast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Gear returned here merges over the engine's midcast set for the action.
function midcast_custom(spell)
	local equipSet = {}
	-- sets.Midcast.Refresh and .Regen hold only the slots they change, for the engine to merge over the
	-- enhancing set, and over the Others set for a cast on someone else. But the engine wears a set named
	-- for the exact spell in place of the whole enhancing set, so the spells called Refresh and Regen
	-- would get those few slots over idle gear and lose every duration piece. This puts the enhancing set,
	-- and the Others set for a cast on someone else, back under them, as the engine does for the rest of
	-- each family.
	if Family_Set_Spells:contains(spell.english) then
		local others = spell.target.type ~= 'SELF' or buffactive['Accession']
		equipSet = set_combine(sets.Midcast.Enhancing, others and sets.Midcast.Enhancing.Others or {}, sets.Midcast[spell.english])
	end
	-- The casting weapons for magic that has to land or heals, cast while not engaged with the weapon lock
	-- Unlocked. Engaged casts keep the weapon mode's weapons, since new weapons reset TP, and Locked holds the
	-- main, where a new sub alone would make a mixed pair. After the cast, choose_set_custom puts the idle
	-- weapons back on. Without Dual Wield the game refuses Maxentius in sub, so the offhand stays empty.
	if player.status ~= 'Engaged' and state.WeaponLock.value == 'Unlocked' then
		local name = spell.english
		if Casting_Skills:contains(spell.skill) or BlueNuke:contains(name) or BlueACC:contains(name)
			or BlueTank:contains(name) or BlueBreath:contains(name) or BlueHealing:contains(name) then
			equipSet = sets.Weapons.Casting
			if not has_dual_wield() then
				equipSet = set_combine(equipSet, { sub = empty })
			end
		end
	end
	-- Elemental debuffs from a subjob (Burn, Frost and the rest) take the enfeebling accuracy set, but enfeebling
	-- skill does nothing for elemental magic, so Eschan Stone goes back on over Rumination Sash.
	if Elemental_Enfeeble:contains(spell.english) then
		equipSet = set_combine(equipSet, { waist = gear.eschan })
	end
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
	-- The refresh weapon whenever you are not engaged. The engine builds the idle set on the same test.
	-- Fucho-no-Obi joins it once its latent is on, checked on every rebuild. The latent needs MP below half
	-- of a maximum that leaves out ear, ring and back MP (bg-wiki, Fucho-no-Obi). The idle set's Etiolation
	-- Earring and Murky Ring carry 80 of it, so the test starts a few points below 50%.
	if player.status ~= 'Engaged' then
		equipSet = sets.Weapons.Idle
		if player.mp < (player.max_mp - 80) / 2 then
			equipSet = set_combine(equipSet, sets.LowMP)
		end
	end
	return equipSet
end
-- Called when your status changes, such as engaging, disengaging or resting. Gear returned here merges over the idle or engaged set that follows.
function status_change_custom(new,old)
	local equipSet = {}

	return equipSet
end
-- Called for a "gs c" command the engine does not handle itself, and for the weapon mode, job mode and job mode 2 commands, which call it before the gear rebuild. The command arrives in lowercase.
-- Here, a job mode change, by key, by gs c jobmode or by gs c jobmode AoE, switches the macro set to match: 2 for AoE, 1 for Melee.
-- It then loads the matching AzureSets spell set. The macro set changes even when no spell set is found.
-- Testing the first word keeps jobmode2 and other commands that merely contain jobmode from triggering it.
function self_command_custom(command)
	if command:match('^(%S+)') == 'jobmode' then
		local macro_set = state.JobMode.value == 'AoE' and 2 or 1
		send_command('input /macro book ' .. MacroBook .. ';wait .1; input /macro set ' .. macro_set)
		queue_azure_set(0)
	end
end

-- The AzureSets save file, read to learn which spell sets exist.
local azure_settings_path = windower.windower_path .. 'addons/AzureSets/data/settings.xml'

-- Each queued load takes a new request number, and a scheduled load or retry for an older number does nothing.
-- Changing main job to BLU loads this file and may also change the subjob, and this keeps that to one //aset command.
local azure_request = 0

-- True from a load being queued until it sends its //aset command or gives up. The engine's Change Complete echo
-- waits for it.
local azure_pending = false

-- Schedules load_azure_set after delay seconds, replacing any load still waiting.
function queue_azure_set(delay)
	azure_request = azure_request + 1
	azure_pending = true
	local request = azure_request
	coroutine.schedule(function() load_azure_set(request) end, delay)
end

-- Returns a lookup of the spell set names saved in AzureSets, or nil when the file cannot be read.
local function azure_set_names()
	local file = io.open(azure_settings_path, 'r')
	if not file then return nil end
	local text = file:read('*a'):lower()
	file:close()
	local names = {}
	for name in text:gmatch('<([%w_]+)%s*/?>') do names[name] = true end
	return names
end

-- Sends the engine's held Change Complete echo once no spell set load is waiting. The wait lets AzureSets' own line,
-- that it is setting the spell set or that the set is already set, come first. Declared at the top of the file, where
-- the copy of windower that holds the echo calls it.
function release_echo()
	if not echo_held or azure_pending then return end
	echo_held = false
	send_command('wait 1;input /echo Change Complete')
end

-- Ends the queued load, sent or given up, and lets the echo go.
local function azure_done()
	azure_pending = false
	release_echo()
end

-- Watches Dual Wield each second for a minute after //aset spellset, while AzureSets sets the spells one at a time.
-- Set blue magic grants or removes the trait, and the engine would otherwise not reread it for up to 30 seconds, nor
-- change gear when it did. Each change seen here updates the engine's copy and rebuilds the gear, which puts the
-- swords on or empties the offhand. The first check does the same, since the trait may have changed since the
-- engine last read it. During an action the rebuild is left to the one the action ends with.
local function watch_dual_wield(request, had, checks)
	if request ~= azure_request or checks > 60 then return end
	local has = has_dual_wield()
	if has ~= had then
		dual_wield_check()
		if not is_Busy then equip_set_command() end
	end
	coroutine.schedule(function() watch_dual_wield(request, has, checks + 1) end, 1)
end

-- Loads the AzureSets spell set for the subjob and job mode: {sub}_mage in AoE mode, {sub}_melee in Melee mode.
-- A missing {sub}_mage falls back to {sub}_melee. For a subjob other than NIN, a missing {sub}_melee falls back to war_melee,
-- whose blue magic gives Dual Wield from traits. nin_melee has no Dual Wield spells, since NIN brings the trait itself. With
-- no subjob it loads war_melee. Each miss is warned in chat.
-- It reads the job from the game, not GearSwap's player table, and does nothing unless the main job is BLU.
-- After a job change the game sends the blue magic spell list late, and AzureSets errors without it, so it retries each second for up to ten tries.
-- It retries the same way while the game has no player to read.
-- After a load's //aset command, or its last warning when it loads nothing, it lets the engine's Change Complete echo go.
-- After the command it also starts watch_dual_wield.
function load_azure_set(request, tries)
	if request ~= azure_request then return end
	local current = windower.ffxi.get_player()
	if current and current.main_job ~= 'BLU' then return end
	local job_data = current and windower.ffxi.get_mjob_data()
	if not job_data or not job_data.spells then
		tries = (tries or 0) + 1
		if tries < 10 then
			coroutine.schedule(function() load_azure_set(request, tries) end, 1)
		else
			warn('Blue magic spell list not loaded, AzureSets spell set skipped')
			azure_done()
		end
		return
	end
	local sub = (current.sub_job or 'war'):lower()
	local candidates = {}
	if state.JobMode.value == 'AoE' then candidates[#candidates+1] = sub .. '_mage' end
	candidates[#candidates+1] = sub .. '_melee'
	if sub ~= 'nin' and sub ~= 'war' then candidates[#candidates+1] = 'war_melee' end

	local names = azure_set_names()
	local chosen
	if not names then
		warn('AzureSets settings not found at ' .. azure_settings_path .. ', loading ' .. candidates[1] .. ' unchecked')
		chosen = candidates[1]
	else
		for _, name in ipairs(candidates) do
			if names[name] then chosen = name break end
			warn('AzureSets spell set ' .. name .. ' is missing')
		end
		if not chosen then
			azure_done()
			return
		end
	end

	send_command('input //aset spellset ' .. chosen)
	azure_done()
	watch_dual_wield(request, nil, 0)
end

-- Called when the job file unloads, after the engine has released its keys and held slots.
-- Here, it retires any spell set load or Dual Wield watch still scheduled, so none runs after this file is gone.
function user_file_unload()
	azure_request = azure_request + 1
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

-- Loads the spell set when this file loads, which covers changing main job to BLU. It waits as a subjob change does.
queue_azure_set(5)
