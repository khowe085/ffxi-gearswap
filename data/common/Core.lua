-- Picks precast, midcast and idle/engaged sets automatically, following the lookup order of
-- Selindrile's Sel-Include.lua. Job files include it before defining their sets: see data/Template.lua.

include("Modes.lua")

state = {
	CastingMode = M({ ["description"] = "Casting Mode", "Normal" }),
	OffenseMode = M({ ["description"] = "Offense Mode", "Normal" }),
	HybridMode = M({ ["description"] = "Hybrid Mode", "Normal" }),
	IdleMode = M({ ["description"] = "Idle Mode", "Normal" }),
	Weapons = M({ ["description"] = "Weapons", "None" }),
	AutoWSMode = M({ ["description"] = "Auto WS", "Off" }),
	AutoWSBuff = M(true, "Auto WS Buff"),
	AutoTHMode = M({ ["description"] = "Auto TH", "Off" }),
	AutoBuffMode = M({ ["description"] = "Auto Buff", "Off" }),
}

gear = {}

sets.precast = {}
sets.precast.FC = {}
sets.precast.JA = {}
sets.precast.WS = {}
sets.precast.Item = {}
sets.midcast = {}
sets.midcast.Pet = {}
sets.idle = {}
sets.engaged = {}
sets.resting = {}
sets.weapons = {}
sets.TreasureHunter = {}

local spell_maps = {
	["Cure"] = "Cure",
	["Cure II"] = "Cure",
	["Cure III"] = "Cure",
	["Cure IV"] = "Cure",
	["Cure V"] = "Cure",
	["Cure VI"] = "Cure",
	["Full Cure"] = "Cure",
	["Cura"] = "Curaga",
	["Cura II"] = "Curaga",
	["Cura III"] = "Curaga",
	["Curaga"] = "Curaga",
	["Curaga II"] = "Curaga",
	["Curaga III"] = "Curaga",
	["Curaga IV"] = "Curaga",
	["Curaga V"] = "Curaga",
	-- Status Removal doesn't include Esuna or Sacrifice, since they work differently than the rest
	["Poisona"] = "StatusRemoval",
	["Paralyna"] = "StatusRemoval",
	["Silena"] = "StatusRemoval",
	["Blindna"] = "StatusRemoval",
	["Cursna"] = "StatusRemoval",
	["Stona"] = "StatusRemoval",
	["Viruna"] = "StatusRemoval",
	["Erase"] = "StatusRemoval",
	["Barfire"] = "BarElement",
	["Barstone"] = "BarElement",
	["Barwater"] = "BarElement",
	["Baraero"] = "BarElement",
	["Barblizzard"] = "BarElement",
	["Barthunder"] = "BarElement",
	["Barfira"] = "BarElement",
	["Barstonra"] = "BarElement",
	["Barwatera"] = "BarElement",
	["Baraera"] = "BarElement",
	["Barblizzara"] = "BarElement",
	["Barthundra"] = "BarElement",
	["Baramnesia"] = "BarStatus",
	["Baramnesra"] = "BarStatus",
	["Barvirus"] = "BarStatus",
	["Barvira"] = "BarStatus",
	["Barparalyze"] = "BarStatus",
	["Barparalyzra"] = "BarStatus",
	["Barsilence"] = "BarStatus",
	["Barsilencera"] = "BarStatus",
	["Barpetrify"] = "BarStatus",
	["Barpetra"] = "BarStatus",
	["Barpoison"] = "BarStatus",
	["Barpoisonra"] = "BarStatus",
	["Barblind"] = "BarStatus",
	["Barblindra"] = "BarStatus",
	["Barsleep"] = "BarStatus",
	["Barsleepra"] = "BarStatus",
	["Boost-AGI"] = "BoostStat",
	["Boost-CHR"] = "BoostStat",
	["Boost-DEX"] = "BoostStat",
	["Boost-INT"] = "BoostStat",
	["Boost-MND"] = "BoostStat",
	["Boost-STR"] = "BoostStat",
	["Boost-VIT"] = "BoostStat",
	["Gain-AGI"] = "BoostStat",
	["Gain-CHR"] = "BoostStat",
	["Gain-DEX"] = "BoostStat",
	["Gain-INT"] = "BoostStat",
	["Gain-MND"] = "BoostStat",
	["Gain-STR"] = "BoostStat",
	["Gain-VIT"] = "BoostStat",
	["Raise"] = "Raise",
	["Raise II"] = "Raise",
	["Raise III"] = "Raise",
	["Arise"] = "Raise",
	["Reraise"] = "Reraise",
	["Reraise II"] = "Reraise",
	["Reraise III"] = "Reraise",
	["Reraise IV"] = "Reraise",
	["Dia"] = "Dia",
	["Dia II"] = "Dia",
	["Dia III"] = "Dia",
	["Diaga"] = "Dia",
	["Diaga II"] = "Dia",
	["Bio"] = "Bio",
	["Bio II"] = "Bio",
	["Bio III"] = "Bio",
	["Dispel"] = "Dispel",
	["Dispelga"] = "Dispel",
	["Protect"] = "Protect",
	["Protect II"] = "Protect",
	["Protect III"] = "Protect",
	["Protect IV"] = "Protect",
	["Protect V"] = "Protect",
	["Shell"] = "Shell",
	["Shell II"] = "Shell",
	["Shell III"] = "Shell",
	["Shell IV"] = "Shell",
	["Shell V"] = "Shell",
	["Protectra"] = "Protectra",
	["Protectra II"] = "Protectra",
	["Protectra III"] = "Protectra",
	["Protectra IV"] = "Protectra",
	["Protectra V"] = "Protectra",
	["Shellra"] = "Shellra",
	["Shellra II"] = "Shellra",
	["Shellra III"] = "Shellra",
	["Shellra IV"] = "Shellra",
	["Shellra V"] = "Shellra",
	["Regen"] = "Regen",
	["Regen II"] = "Regen",
	["Regen III"] = "Regen",
	["Regen IV"] = "Regen",
	["Regen V"] = "Regen",
	["Refresh"] = "Refresh",
	["Refresh II"] = "Refresh",
	["Refresh III"] = "Refresh",
	["Teleport-Holla"] = "Teleport",
	["Teleport-Dem"] = "Teleport",
	["Teleport-Mea"] = "Teleport",
	["Teleport-Altep"] = "Teleport",
	["Teleport-Yhoat"] = "Teleport",
	["Teleport-Vahzl"] = "Teleport",
	["Recall-Pashh"] = "Teleport",
	["Recall-Meriph"] = "Teleport",
	["Recall-Jugner"] = "Teleport",
	["Warp"] = "Teleport",
	["Escape"] = "Teleport",
	["Retrace"] = "TeleportOther",
	["Tractor"] = "TeleportOther",
	["Warp II"] = "TeleportOther",
	["Temper"] = "Temper",
	["Temper II"] = "Temper",
	["Valor Minuet"] = "Minuet",
	["Valor Minuet II"] = "Minuet",
	["Valor Minuet III"] = "Minuet",
	["Valor Minuet IV"] = "Minuet",
	["Valor Minuet V"] = "Minuet",
	["Knight's Minne"] = "Minne",
	["Knight's Minne II"] = "Minne",
	["Knight's Minne III"] = "Minne",
	["Knight's Minne IV"] = "Minne",
	["Knight's Minne V"] = "Minne",
	["Advancing March"] = "March",
	["Victory March"] = "March",
	["Honor March"] = "March",
	["Sword Madrigal"] = "Madrigal",
	["Blade Madrigal"] = "Madrigal",
	["Hunter's Prelude"] = "Prelude",
	["Archer's Prelude"] = "Prelude",
	["Sheepfoe Mambo"] = "Mambo",
	["Dragonfoe Mambo"] = "Mambo",
	["Raptor Mazurka"] = "Mazurka",
	["Chocobo Mazurka"] = "Mazurka",
	["Shock Spikes"] = "Spikes",
	["Ice Spikes"] = "Spikes",
	["Blaze Spikes"] = "Spikes",
	["Dread Spikes"] = "Spikes",
	["Enfire"] = "Enspell",
	["Enfire II"] = "Enspell",
	["Enblizzard"] = "Enspell",
	["Enblizzard II"] = "Enspell",
	["Enaero"] = "Enspell",
	["Enaero II"] = "Enspell",
	["Enstone"] = "Enspell",
	["Enstone II"] = "Enspell",
	["Enthunder"] = "Enspell",
	["Enthunder II"] = "Enspell",
	["Enwater"] = "Enspell",
	["Enwater II"] = "Enspell",
	["Enlight"] = "Enspell",
	["Enlight II"] = "Enspell",
	["Endark"] = "Enspell",
	["Endark II"] = "Enspell",
	["Sinewy Etude"] = "Etude",
	["Dextrous Etude"] = "Etude",
	["Vivacious Etude"] = "Etude",
	["Quick Etude"] = "Etude",
	["Learned Etude"] = "Etude",
	["Spirited Etude"] = "Etude",
	["Enchanting Etude"] = "Etude",
	["Herculean Etude"] = "Etude",
	["Uncanny Etude"] = "Etude",
	["Vital Etude"] = "Etude",
	["Swift Etude"] = "Etude",
	["Sage Etude"] = "Etude",
	["Logical Etude"] = "Etude",
	["Bewitching Etude"] = "Etude",
	["Mage's Ballad"] = "Ballad",
	["Mage's Ballad II"] = "Ballad",
	["Mage's Ballad III"] = "Ballad",
	["Army's Paeon"] = "Paeon",
	["Army's Paeon II"] = "Paeon",
	["Army's Paeon III"] = "Paeon",
	["Army's Paeon IV"] = "Paeon",
	["Army's Paeon V"] = "Paeon",
	["Army's Paeon VI"] = "Paeon",
	["Fire Carol"] = "Carol",
	["Ice Carol"] = "Carol",
	["Wind Carol"] = "Carol",
	["Earth Carol"] = "Carol",
	["Lightning Carol"] = "Carol",
	["Water Carol"] = "Carol",
	["Light Carol"] = "Carol",
	["Dark Carol"] = "Carol",
	["Fire Carol II"] = "Carol",
	["Ice Carol II"] = "Carol",
	["Wind Carol II"] = "Carol",
	["Earth Carol II"] = "Carol",
	["Lightning Carol II"] = "Carol",
	["Water Carol II"] = "Carol",
	["Light Carol II"] = "Carol",
	["Dark Carol II"] = "Carol",
	["Foe Lullaby"] = "Lullaby",
	["Foe Lullaby II"] = "Lullaby",
	["Horde Lullaby"] = "Lullaby",
	["Horde Lullaby II"] = "Lullaby",
	["Fire Threnody"] = "Threnody",
	["Ice Threnody"] = "Threnody",
	["Wind Threnody"] = "Threnody",
	["Earth Threnody"] = "Threnody",
	["Ltng. Threnody"] = "Threnody",
	["Water Threnody"] = "Threnody",
	["Light Threnody"] = "Threnody",
	["Dark Threnody"] = "Threnody",
	["Fire Threnody II"] = "Threnody",
	["Ice Threnody II"] = "Threnody",
	["Wind Threnody II"] = "Threnody",
	["Earth Threnody II"] = "Threnody",
	["Ltng. Threnody II"] = "Threnody",
	["Water Threnody II"] = "Threnody",
	["Light Threnody II"] = "Threnody",
	["Dark Threnody II"] = "Threnody",
	["Battlefield Elegy"] = "Elegy",
	["Carnage Elegy"] = "Elegy",
	["Foe Requiem"] = "Requiem",
	["Foe Requiem II"] = "Requiem",
	["Foe Requiem III"] = "Requiem",
	["Foe Requiem IV"] = "Requiem",
	["Foe Requiem V"] = "Requiem",
	["Foe Requiem VI"] = "Requiem",
	["Foe Requiem VII"] = "Requiem",
	["Utsusemi: Ichi"] = "Utsusemi",
	["Utsusemi: Ni"] = "Utsusemi",
	["Utsusemi: San"] = "Utsusemi",
	["Katon: Ichi"] = "ElementalNinjutsu",
	["Suiton: Ichi"] = "ElementalNinjutsu",
	["Raiton: Ichi"] = "ElementalNinjutsu",
	["Doton: Ichi"] = "ElementalNinjutsu",
	["Huton: Ichi"] = "ElementalNinjutsu",
	["Hyoton: Ichi"] = "ElementalNinjutsu",
	["Katon: Ni"] = "ElementalNinjutsu",
	["Suiton: Ni"] = "ElementalNinjutsu",
	["Raiton: Ni"] = "ElementalNinjutsu",
	["Doton: Ni"] = "ElementalNinjutsu",
	["Huton: Ni"] = "ElementalNinjutsu",
	["Hyoton: Ni"] = "ElementalNinjutsu",
	["Katon: San"] = "ElementalNinjutsu",
	["Suiton: San"] = "ElementalNinjutsu",
	["Raiton: San"] = "ElementalNinjutsu",
	["Doton: San"] = "ElementalNinjutsu",
	["Huton: San"] = "ElementalNinjutsu",
	["Hyoton: San"] = "ElementalNinjutsu",
	["Banish"] = "Banish",
	["Banish II"] = "Banish",
	["Banish III"] = "Banish",
	["Banishga"] = "Banish",
	["Banishga II"] = "Banish",
	["Holy"] = "Holy",
	["Holy II"] = "Holy",
	["Drain"] = "Drain",
	["Drain II"] = "Drain",
	["Drain III"] = "Drain",
	["Aspir"] = "Aspir",
	["Aspir II"] = "Aspir",
	["Aspir III"] = "Aspir",
	["Absorb-STR"] = "Absorb",
	["Absorb-DEX"] = "Absorb",
	["Absorb-VIT"] = "Absorb",
	["Absorb-AGI"] = "Absorb",
	["Absorb-INT"] = "Absorb",
	["Absorb-MND"] = "Absorb",
	["Absorb-CHR"] = "Absorb",
	["Absorb-ACC"] = "Absorb",
	["Absorb-TP"] = "Absorb",
	["Absorb-Attri"] = "Absorb",
	["Burn"] = "ElementalEnfeeble",
	["Frost"] = "ElementalEnfeeble",
	["Choke"] = "ElementalEnfeeble",
	["Rasp"] = "ElementalEnfeeble",
	["Shock"] = "ElementalEnfeeble",
	["Drown"] = "ElementalEnfeeble",
	["Pyrohelix"] = "Helix",
	["Cryohelix"] = "Helix",
	["Anemohelix"] = "Helix",
	["Geohelix"] = "Helix",
	["Ionohelix"] = "Helix",
	["Hydrohelix"] = "Helix",
	["Luminohelix"] = "Helix",
	["Noctohelix"] = "Helix",
	["Pyrohelix II"] = "Helix",
	["Cryohelix II"] = "Helix",
	["Anemohelix II"] = "Helix",
	["Geohelix II"] = "Helix",
	["Ionohelix II"] = "Helix",
	["Hydrohelix II"] = "Helix",
	["Luminohelix II"] = "Helix",
	["Noctohelix II"] = "Helix",
	["Firestorm"] = "Storm",
	["Hailstorm"] = "Storm",
	["Windstorm"] = "Storm",
	["Sandstorm"] = "Storm",
	["Thunderstorm"] = "Storm",
	["Rainstorm"] = "Storm",
	["Aurorastorm"] = "Storm",
	["Voidstorm"] = "Storm",
	["Firestorm II"] = "Storm",
	["Hailstorm II"] = "Storm",
	["Windstorm II"] = "Storm",
	["Sandstorm II"] = "Storm",
	["Thunderstorm II"] = "Storm",
	["Rainstorm II"] = "Storm",
	["Aurorastorm II"] = "Storm",
	["Voidstorm II"] = "Storm",
	["Fire Maneuver"] = "Maneuver",
	["Ice Maneuver"] = "Maneuver",
	["Wind Maneuver"] = "Maneuver",
	["Earth Maneuver"] = "Maneuver",
	["Thunder Maneuver"] = "Maneuver",
	["Water Maneuver"] = "Maneuver",
	["Light Maneuver"] = "Maneuver",
	["Dark Maneuver"] = "Maneuver",
	["Haste"] = "Haste",
	["Haste II"] = "Haste",
	["Paralyze"] = "Paralyze",
	["Paralyze II"] = "Paralyze",
	["Addle"] = "Addle",
	["Addle II"] = "Addle",
	["Gravity"] = "Gravity",
	["Gravity II"] = "Gravity",
	["Frazzle"] = "Frazzle",
	["Frazzle II"] = "Frazzle",
	["Frazzle III"] = "Frazzle",
	["Distract"] = "Distract",
	["Distract II"] = "Distract",
	["Distract III"] = "Distract",
	["Sleep"] = "Sleep",
	["Sleep II"] = "Sleep",
	["Sleepga"] = "Sleep",
	["Sleepga II"] = "Sleep",
	["Break"] = "Break",
	["Breakga"] = "Break",
	["Blind"] = "Blind",
	["Blind II"] = "Blind",
	["Poison"] = "Poison",
	["Poison II"] = "Poison",
	["Poisonga"] = "Poison",
}

-- Sel's list of spells the skill set does nothing for (raises, warps, teleports), so midcast skips
-- it and falls through to the spell type set.
local no_skill_spells = {
	["Raise"] = true,
	["Raise II"] = true,
	["Raise III"] = true,
	["Arise"] = true,
	["Reraise"] = true,
	["Reraise II"] = true,
	["Reraise III"] = true,
	["Reraise IV"] = true,
	["Warp"] = true,
	["Warp II"] = true,
	["Escape"] = true,
	["Retrace"] = true,
	["Tractor"] = true,
	["Teleport-Holla"] = true,
	["Teleport-Dem"] = true,
	["Teleport-Mea"] = true,
	["Teleport-Altep"] = true,
	["Teleport-Yhoat"] = true,
	["Teleport-Vahzl"] = true,
	["Recall-Pashh"] = true,
	["Recall-Meriph"] = true,
	["Recall-Jugner"] = true,
}

local function set_of(names)
	local set = {}
	for _, name in ipairs(names) do
		set[name] = true
	end
	return set
end

-- Sel's LowTierNukes, the same list in its BLM, GEO, RDM and SCH files.
local low_tier_nukes = set_of({
	"Stone",
	"Water",
	"Aero",
	"Fire",
	"Blizzard",
	"Thunder",
	"Stone II",
	"Water II",
	"Aero II",
	"Fire II",
	"Blizzard II",
	"Thunder II",
	"Stonega",
	"Waterga",
	"Aeroga",
	"Firaga",
	"Blizzaga",
	"Thundaga",
})

-- Sel's BLU spell categories, in its order. Four spells are listed twice (Bilgestorm, Mind Blast,
-- Hecatomb Wave, Sub-zero Smash); Sel picked between them at random, here the first listing wins.
local blue_magic_categories = {
	{ "Physical", { "Bilgestorm" } },
	{ "PhysicalAcc", { "Heavy Strike" } },
	{
		"PhysicalStr",
		{
			"Bloodrake",
			"Death Scissors",
			"Dimensional Death",
			"Empty Thrash",
			"Quadrastrike",
			"Sinker Drill",
			"Spinal Cleave",
			"Uppercut",
			"Vertical Cleave",
		},
	},
	{
		"PhysicalDex",
		{
			"Amorphic Spikes",
			"Asuran Claws",
			"Claw Cyclone",
			"Disseverment",
			"Foot Kick",
			"Frenetic Rip",
			"Goblin Rush",
			"Hysteric Barrage",
			"Paralyzing Triad",
			"Sickle Slash",
			"Smite of Rage",
			"Thrashing Assault",
			"Vanity Dive",
		},
	},
	{
		"PhysicalVit",
		{
			"Body Slam",
			"Cannonball",
			"Delta Thrust",
			"Glutinous Dart",
			"Grand Slam",
			"Power Attack",
			"Quad. Continuum",
		},
	},
	{ "PhysicalAgi", { "Helldive", "Jet Stream" } },
	{ "PhysicalInt", { "Mandibular Bite" } },
	{ "PhysicalMnd", { "Ram Charge", "Screwdriver", "Tourbillion" } },
	{ "PhysicalChr", { "Bludgeon" } },
	{ "PhysicalHP", { "Final Sting" } },
	{
		"Magical",
		{
			"Blastbomb",
			"Blazing Bound",
			"Bomb Toss",
			"Cursed Sphere",
			"Dark Orb",
			"Death Ray",
			"Diffusion Ray",
			"Droning Whirlwind",
			"Embalming Earth",
			"Firespit",
			"Foul Waters",
			"Ice Break",
			"Leafstorm",
			"Maelstrom",
			"Rail Cannon",
			"Regurgitation",
			"Rending Deluge",
			"Retinal Glare",
			"Subduction",
			"Tearing Gust",
			"Tem. Upheaval",
			"Water Bomb",
			"Molting Plumage",
			"Nectarous Deluge",
			"Searing Tempest",
			"Blinding Fulgor",
			"Spectral Floe",
			"Scouring Spate",
			"Anvil Lightning",
			"Silent Storm",
			"Entomb",
			"Tenebral Crush",
			"Palling Salvo",
		},
	},
	{ "MagicalMnd", { "Acrid Stream", "Evryone. Grudge", "Magic Hammer", "Mind Blast" } },
	{ "MagicalChr", { "Eyes On Me", "Mysterious Light" } },
	{ "MagicalVit", { "Thermal Pulse" } },
	{ "MagicalDex", { "Charged Whisker", "Gates of Hades" } },
	{ "MagicalAgi", { "Crashing Thunder" } },
	{
		"MagicAccuracy",
		{
			"1000 Needles",
			"Absolute Terror",
			"Actinic Burst",
			"Auroral Drape",
			"Awful Eye",
			"Bad Breath",
			"Blank Gaze",
			"Blistering Roar",
			"Blitzstrahl",
			"Blood Drain",
			"Blood Saber",
			"Cesspool",
			"Chaotic Eye",
			"Cimicine Discharge",
			"Cold Wave",
			"Corrosive Ooze",
			"Cruel Joke",
			"Demoralizing Roar",
			"Digest",
			"Dream Flower",
			"Enervation",
			"Feather Tickle",
			"Filamented Hold",
			"Frightful Roar",
			"Frost Breath",
			"Geist Wall",
			"Hecatomb Wave",
			"Infrasonics",
			"Jettatura",
			"Light of Penance",
			"Lowing",
			"Mind Blast",
			"Mortal Ray",
			"MP Drainkiss",
			"Osmosis",
			"Radiant Breath",
			"Reaving Wind",
			"Sandspin",
			"Sandspray",
			"Sheep Song",
			"Soporific",
			"Sound Blast",
			"Stinking Gas",
			"Sub-zero Smash",
			"Temporal Shift",
			"Thunderbolt",
			"Venom Shell",
			"Voracious Trunk",
			"Yawn",
			"Atra. Libations",
		},
	},
	{
		"Breath",
		{
			"Flying Hip Press",
			"Heat Breath",
			"Hecatomb Wave",
			"Magnetite Cloud",
			"Poison Breath",
			"Self-Destruct",
			"Thunder Breath",
			"Vapor Spray",
			"Wind Breath",
		},
	},
	{
		"Stun",
		{
			"Barbed Crescent",
			"Battle Dance",
			"Benthic Typhoon",
			"Bilgestorm",
			"Feather Storm",
			"Frypan",
			"Head Butt",
			"Hydro Shot",
			"Pinecone Bomb",
			"Queasyshroom",
			"Saurian Slide",
			"Seedspray",
			"Spiral Spin",
			"Sprout Smack",
			"Sub-zero Smash",
			"Sudden Lunge",
			"Sweeping Gouge",
			"Tail Slap",
			"Terror Touch",
			"Wild Oats",
			"Whirl of Rage",
		},
	},
	{
		"Healing",
		{
			"Exuviation",
			"Healing Breeze",
			"Magic Fruit",
			"Plenilune Embrace",
			"Pollen",
			"Restoral",
			"White Wind",
			"Wild Carrot",
		},
	},
	{ "SkillBasedBuff", { "Diamondhide", "Magic Barrier", "Occultation", "Plasma Charge", "Reactor Cool" } },
	{
		"Buff",
		{
			"Amplification",
			"Animating Wail",
			"Barrier Tusk",
			"Battery Charge",
			"Carcharian Verve",
			"Cocoon",
			"Erratic Flutter",
			"Fantod",
			"Feather Barrier",
			"Harden Shell",
			"Memento Mori",
			"Metallic Body",
			"Mighty Guard",
			"Nat. Meditation",
			"Orcish Counterstance",
			"Pyric Bulwark",
			"Refueling",
			"Regeneration",
			"Saline Coat",
			"Triumphant Roar",
			"Warm-Up",
			"Winds of Promy.",
			"Zephyr Mantle",
		},
	},
}

local blue_magic_maps = {}
for _, category in ipairs(blue_magic_categories) do
	for _, spell in ipairs(category[2]) do
		blue_magic_maps[spell] = blue_magic_maps[spell] or category[1]
	end
end

-- Sel's magicalRagePacts from its SMN file.
local magical_rage_pacts = set_of({
	"Inferno",
	"Earthen Fury",
	"Tidal Wave",
	"Aerial Blast",
	"Diamond Dust",
	"Judgment Bolt",
	"Searing Light",
	"Howling Moon",
	"Ruinous Omen",
	"Clarsach Call",
	"Impact",
	"Fire II",
	"Stone II",
	"Water II",
	"Aero II",
	"Blizzard II",
	"Thunder II",
	"Fire IV",
	"Stone IV",
	"Water IV",
	"Aero IV",
	"Blizzard IV",
	"Thunder IV",
	"Thunderspark",
	"Burning Strike",
	"Meteorite",
	"Nether Blast",
	"Flaming Crush",
	"Meteor Strike",
	"Conflag Strike",
	"Heavenly Strike",
	"Wind Blade",
	"Geocrush",
	"Grand Fall",
	"Thunderstorm",
	"Holy Mist",
	"Lunar Bay",
	"Night Terror",
	"Level ? Holy",
	"Tornado II",
	"Sonic Buffet",
})

-- As in Sel, a Cure-family map with no set of its own (LightWeatherCure, MeleeCureSolace...) uses
-- the Cure set; a Curaga one tries the Curaga set first.
local function cure_fallback(equipSet, spellMap)
	if not spellMap then
		return nil
	elseif spellMap:find("Curaga", 1, true) then
		return equipSet.Curaga or equipSet.Cure
	elseif spellMap:find("Cure", 1, true) then
		return equipSet.Cure
	end
end

local function get_named_set(equipSet, spell, spellMap)
	return equipSet[spell.english] or equipSet[spellMap] or cure_fallback(equipSet, spellMap) or equipSet
end

-- Lookup order: spell name, spell map, then skill or type -- and within a skill or type set,
-- a sub-set named for the spell or its map.
local function select_specific_set(equipSet, spell, spellMap, skipSkill)
	local namedSet = get_named_set(equipSet, spell, spellMap)
	if namedSet ~= equipSet then
		return namedSet
	end

	local categorySet = (not skipSkill and equipSet[spell.skill]) or equipSet[spell.type]
	if not categorySet then
		return equipSet
	end
	return get_named_set(categorySet, spell, spellMap)
end

local function apply_mode(equipSet, mode)
	return equipSet[mode.current] or equipSet
end

-- As in Sel and Mote, the precast table's name decides the midcast one too.
local function ranged_category()
	return sets.precast.RangedAttack and "RangedAttack" or "RA"
end

local function precast_category(spell)
	if spell.action_type == "Magic" then
		return "FC"
	elseif spell.type == "WeaponSkill" then
		return "WS"
	elseif spell.action_type == "Ability" then
		return sets.precast[spell.type] and spell.type or "JA"
	elseif spell.action_type == "Ranged Attack" then
		return ranged_category()
	elseif spell.action_type == "Item" then
		return "Item"
	end
end

local function get_precast_set(spell, spellMap)
	local categorySet = sets.precast[precast_category(spell)]
	if not categorySet then
		return {}
	end

	local equipSet = select_specific_set(categorySet, spell, spellMap)
	if spell.action_type == "Magic" then
		return apply_mode(equipSet, state.CastingMode)
	elseif spell.type == "WeaponSkill" then
		return apply_mode(equipSet, state.OffenseMode)
	end
	return equipSet
end

local weapon_slots = { "main", "sub", "range" }
local weapons_changed = false
-- The weapon slots Core disabled itself. A slot already disabled (//gs disable) is left to you, but
-- one you disable while Core holds it can't be told apart and is released with Core's lock.
local core_locked_slots = {}

local function lock_weapons()
	for _, slot in ipairs(weapon_slots) do
		if not gearswap.disable_table[gearswap.slot_map[slot]] then
			disable(slot)
			core_locked_slots[slot] = true
		end
	end
end

-- GearSwap's own enable() rather than the user-facing one, which re-sends whatever the lock held
-- back (say a MACC bow from a cast mid-fight) into any slot the sets equipped right after leave empty.
local function unlock_weapons()
	for slot in pairs(core_locked_slots) do
		gearswap.enable(slot)
	end
	core_locked_slots = {}
end

-- Swapping main, sub or range zeroes TP, so they only lock while swinging with a chosen weapon.
local function should_lock_weapons(status)
	return status == "Engaged" and state.Weapons.value ~= "None"
end

local function light_prefix()
	if world.weather_element == "Light" then
		return "LightWeather"
	elseif world.day_element == "Light" then
		return "LightDay"
	end
	return ""
end

-- Sel's Cure maps: Melee… while the weapon lock keeps the Cure set from swapping weapons, …Solace
-- under Afflatus Solace. A variant with no set falls back to the Cure set.
local function cure_map()
	local melee = should_lock_weapons(player.status) and "Melee" or ""
	local solace = buffactive["afflatus solace"] and "Solace" or ""
	return melee .. light_prefix() .. "Cure" .. solace
end

local function nuke_map(spell, defaultMap)
	if defaultMap == "ElementalEnfeeble" or defaultMap == "Helix" or state.CastingMode.value:find("^Occult") then
		return defaultMap
	end
	return low_tier_nukes[spell.english] and "LowTierNuke" or "HighTierNuke"
end

-- Sel's per-job spell maps, applied to every job since each keys off the spell itself.
local function core_spell_map(spell, defaultMap)
	if defaultMap == "Cure" then
		return cure_map()
	elseif defaultMap == "Curaga" then
		return light_prefix() .. "Curaga"
	elseif spell.skill == "Elemental Magic" then
		return nuke_map(spell, defaultMap)
	elseif spell.skill == "Blue Magic" then
		return blue_magic_maps[spell.english] or defaultMap
	elseif spell.skill == "Ninjutsu" and not defaultMap then
		return spell.target.type == "SELF" and "NinjutsuBuff" or "NinjutsuDebuff"
	elseif spell.type == "BloodPactRage" then
		return magical_rage_pacts[spell.english] and "MagicalBloodPactRage" or "PhysicalBloodPactRage"
	elseif spell.type == "BloodPactWard" then
		return spell.target.type == "MONSTER" and "DebuffBloodPactWard" or "BloodPactWard"
	elseif spell.skill == "Geomancy" and spell.english:find("^Indi") then
		return "Indi"
	end
	return defaultMap
end

local function get_spell_map(spell)
	local coreMap = core_spell_map(spell, spell_maps[spell.english])
	return job_get_spell_map and job_get_spell_map(spell, coreMap) or coreMap
end

-- Sel's lists (disable_list, check_amnesia, check_silence).
local incapacitating_buffs = { "terror", "sleep", "lullaby", "stun", "animated", "charm", "petrification" }
local ability_blocking_buffs = { "amnesia", "impairment" }
local magic_blocking_buffs = { "silence", "mute", "omerta" }

local function has_any_buff(buffs)
	for _, buff in ipairs(buffs) do
		if buffactive[buff] then
			return true
		end
	end
	return false
end

-- Sel's exemptions: abilities spent from charges (e.g. Stratagems, Quick Draw) stay usable while
-- their recast timer runs.
local charged_recast_ids = { [102] = true, [195] = true, [231] = true, [255] = true }

-- Only a known cooldown blocks. Sel also blocks abilities missing from the recast table, but that
-- would lock out every ready ability if the table ever omits them. Sel lets an action through in
-- its last 0.5s (abilities) or 0.8s (spells) of recast; any time left blocks here, so gear never
-- swaps for an action the server may still refuse.
local function recast_running(recasts, recastId)
	local remaining = recastId and recasts[recastId]
	return remaining ~= nil and remaining > 0
end

local function cannot_act(spell)
	if
		midaction()
		or player.hp == 0
		or (player.status ~= "Idle" and player.status ~= "Engaged")
		or has_any_buff(incapacitating_buffs)
	then
		return true
	end

	if spell.action_type == "Magic" then
		return has_any_buff(magic_blocking_buffs) or recast_running(windower.ffxi.get_spell_recasts(), spell.recast_id)
	elseif spell.type == "WeaponSkill" then
		return player.tp < 1000 or has_any_buff(ability_blocking_buffs)
	elseif spell.action_type == "Ability" then
		return has_any_buff(ability_blocking_buffs)
			or (
				not charged_recast_ids[spell.recast_id]
				and recast_running(windower.ffxi.get_ability_recasts(), spell.recast_id)
			)
	end
	return false
end

-- Used before a weapon skill, one per weapon skill, in this order. Berserk and Defender cancel
-- each other, so Berserk waits while Defender is up.
local ws_buffs = {
	{ name = "Last Resort", job = "DRK", level = 15, recast = 87 },
	{ name = "Berserk", job = "WAR", level = 15, recast = 1, unless = "defender" },
	{ name = "Warcry", job = "WAR", level = 35, recast = 2 },
	{ name = "Aggressor", job = "WAR", level = 45, recast = 4 },
}

local function has_job_ability(job, level)
	if player.main_job == job and player.main_job_level >= level then
		return true
	end
	return player.sub_job == job and player.sub_job_level >= level and not buffactive["sj restriction"]
end

local function ready_ws_buff()
	local recasts = windower.ffxi.get_ability_recasts()
	for _, ability in ipairs(ws_buffs) do
		if
			has_job_ability(ability.job, ability.level)
			and not buffactive[ability.name:lower()]
			and not (ability.unless and buffactive[ability.unless])
			and recasts[ability.recast] == 0
		then
			return ability.name
		end
	end
end

-- The weapon skill Core is re-firing. Set as the re-fire goes out, so only that re-fire, not a
-- spammed press before it, is let through untouched.
local ws_buff_refire
-- os.clock() time until which other presses of a weapon skill are dropped while its buff and
-- re-fire are pending, so spam can't stack more of them onto Windower's command queue.
local ws_buff_lock = 0

-- Uses a ready buff in the weapon skill's place and re-fires the weapon skill once the buff is up.
local function buff_before_ws(spell)
	-- A lapsed lock means the re-fire never made it back here; its token must not wave a much
	-- later press through.
	if os.clock() >= ws_buff_lock then
		ws_buff_refire = nil
	end
	if ws_buff_refire == spell.english then
		ws_buff_refire = nil
		return false
	end
	if os.clock() < ws_buff_lock then
		cancel_spell()
		return true
	end
	if not state.AutoWSBuff.value then
		return false
	end

	local ability = ready_ws_buff()
	if not ability then
		return false
	end

	cancel_spell()
	ws_buff_lock = os.clock() + 5
	send_command('input /ja "' .. ability .. '" <me>')
	local wsName, target = spell.english, spell.target.raw
	local fire_ws = function()
		ws_buff_refire = wsName
		send_command('input /ws "' .. wsName .. '" ' .. target)
	end
	fire_ws:schedule(1.1)
	return true
end

local autoth_list_built

-- AutoTHMode offers autoth_list's actions, then Off, starting on the first action.
local function sync_autoth()
	if autoth_list_built == autoth_list then
		return
	end
	autoth_list_built = autoth_list
	local options = {}
	for _, action in ipairs(autoth_list or {}) do
		options[#options + 1] = action
	end
	options[#options + 1] = "Off"
	state.AutoTHMode:options(unpack(options))
end

local function equip_auto_th(spell)
	sync_autoth()
	if spell.english == state.AutoTHMode.value then
		equip(sets.TreasureHunter)
	end
end

function precast(spell)
	if cannot_act(spell) then
		cancel_spell()
		return
	end

	local spellMap = get_spell_map(spell)
	if job_filter_precast and job_filter_precast(spell, spellMap) then
		cancel_spell()
		return
	end

	if spell.type == "WeaponSkill" and buff_before_ws(spell) then
		return
	end

	-- The lock can be stale here: nothing has locked yet if this file was (re)loaded mid-fight, and
	-- GearSwap sends no status_change on a KO or raise.
	if should_lock_weapons(player.status) then
		lock_weapons()
	else
		unlock_weapons()
	end

	equip(get_precast_set(spell, spellMap))
	-- Abilities resolve as they're used, so their TH gear goes on here; spells get it at midcast.
	if spell.action_type ~= "Magic" and spell.action_type ~= "Ranged Attack" then
		equip_auto_th(spell)
	end

	if job_post_precast then
		job_post_precast(spell, spellMap)
	end
end

local function get_midcast_set(spell, spellMap)
	local baseSet = sets.midcast
	if spell.action_type == "Ranged Attack" then
		baseSet = sets.midcast[ranged_category()]
		if not baseSet then
			return {}
		end
	end

	local equipSet = select_specific_set(baseSet, spell, spellMap, no_skill_spells[spell.english])
	-- Unlike the precast categories, sets.midcast itself is only a container, and GearSwap would read
	-- a sub-set key such as Ranged as a slot name.
	if equipSet == sets.midcast then
		return {}
	end
	if spell.action_type == "Magic" then
		return apply_mode(equipSet, state.CastingMode)
	end
	return equipSet
end

function midcast(spell)
	-- As in Sel, weapon skills and job abilities skip midcast: they resolve with the gear worn when
	-- the action packet goes out, which GearSwap sends just ahead of midcast gear (equip_sets in
	-- flow.lua), so a midcast swap would only race it.
	if spell.type == "WeaponSkill" or spell.type == "JobAbility" then
		return
	end

	if spell.action_type == "Magic" and sets.midcast.FastRecast then
		equip(sets.midcast.FastRecast)
	end

	local spellMap = get_spell_map(spell)
	equip(get_midcast_set(spell, spellMap))
	if spell.action_type == "Magic" or spell.action_type == "Ranged Attack" then
		equip_auto_th(spell)
	end

	if job_post_midcast then
		job_post_midcast(spell, spellMap)
	end
end

local function equip_weapon_set()
	local weaponSet = sets.weapons[state.Weapons.value]
	if weaponSet then
		equip(weaponSet)
	end
end

local function equip_status_gear(status)
	if player.hp == 0 then
		return
	end

	-- A Weapons change releases the lock once so the new weapon set can go on; that TP loss was
	-- asked for.
	local lockWeapons = should_lock_weapons(status)
	if not lockWeapons or weapons_changed then
		unlock_weapons()
		weapons_changed = false
	end

	if status == "Engaged" then
		local meleeSet = apply_mode(apply_mode(sets.engaged, state.OffenseMode), state.HybridMode)
		if job_customize_melee_set then
			meleeSet = job_customize_melee_set(meleeSet)
		end
		equip(meleeSet)
		equip_weapon_set()
	elseif status == "Resting" then
		equip(sets.resting)
	elseif status == "Idle" or status == "" then
		local idleSet = apply_mode(sets.idle, state.IdleMode)
		if job_customize_idle_set then
			idleSet = job_customize_idle_set(idleSet)
		end
		equip(idleSet)
		equip_weapon_set()
	end

	if lockWeapons then
		lock_weapons()
	end
end

-- Your own commands that make the pet act (Blood Pacts, BST Ready moves).
local pet_move_types = { BloodPactRage = true, BloodPactWard = true, Monster = true }

local function get_pet_set(spell, spellMap)
	if not sets.midcast.Pet then
		return {}
	end
	return select_specific_set(sets.midcast.Pet, spell, spellMap)
end

-- Sel's combat flag, for auto buffs' Combat and OutOfCombat: set when one of your actions lands on
-- a live monster.
local in_combat = false
local last_in_combat = 0

-- Sel's pauses after an action before auto buffs act again, so a buff isn't refused for coming too
-- soon ("Unable to cast spells at this time"). Sel trims each by its 0.5s latency allowance.
local latency = 0.5
local auto_action_time = 0

local function post_action_delay(spell)
	if spell.interrupted then
		return spell.prefix == "/magic" and 1.75 - latency or 0
	elseif spell.action_type == "Magic" then
		return 2.9 - latency
	elseif spell.type == "WeaponSkill" then
		return 2.7 - latency
	elseif spell.action_type == "Ability" then
		return 0.8 - latency
	elseif spell.action_type == "Item" then
		return 1.5 - latency
	elseif spell.action_type == "Ranged Attack" then
		return 0.85 - latency
	end
	return 0
end

function aftercast(spell)
	if spell.type == "WeaponSkill" then
		ws_buff_lock = 0
		ws_buff_refire = nil
	end
	if not spell.interrupted and spell.target.type == "MONSTER" and spell.target.hpp > 0 then
		in_combat = true
		last_in_combat = os.clock()
	end
	auto_action_time = os.clock() + post_action_delay(spell)

	-- The pet acts a moment after your command resolves, so its gear goes on now instead of idle.
	local petPending, petMove = pet_midaction()
	if pet_move_types[spell.type] and not spell.interrupted then
		equip(get_pet_set(spell, get_spell_map(spell)))
	elseif petPending then
		-- The pet readied its move before or during your action, whose gear went on over the pet's.
		equip(get_pet_set(petMove, get_spell_map(petMove)))
	else
		equip_status_gear(player.status)
	end

	if job_post_aftercast then
		job_post_aftercast(spell, get_spell_map(spell))
	end
end

-- Goes on even over an action of yours in flight: the pet's move comes first.
function pet_midcast(spell)
	equip(get_pet_set(spell, get_spell_map(spell)))
end

function pet_aftercast()
	if not midaction() then
		equip_status_gear(player.status)
	end
end

function status_change(newStatus)
	if not midaction() and not pet_midaction() then
		equip_status_gear(newStatus)
	end
end

local autows_weapon
local autows_list_built
local autows_choices = {}

-- AutoWSMode offers Off plus the chosen weapon's autows_list entries, rebuilt (back to Off) whenever
-- Weapons or autows_list changes.
local function sync_autows()
	if autows_weapon == state.Weapons.value and autows_list_built == autows_list then
		return
	end
	autows_weapon = state.Weapons.value
	autows_list_built = autows_list
	autows_choices = {}
	local labels = { "Off" }
	for _, choice in ipairs(autows_list and autows_list[autows_weapon] or {}) do
		if choice[1] and choice[2] then
			local label = choice[1] .. " " .. choice[2]
			labels[#labels + 1] = label
			autows_choices[label] = choice
		end
	end
	state.AutoWSMode:options(unpack(labels))
end

-- An AM2/AM3 option builds that Aftermath level at 2000/3000 TP, then uses the WS at 1000 while
-- it, or a higher level, lasts.
local function autows_threshold(tp)
	local level = tonumber(tostring(tp):match("^AM([23])$"))
	if not level then
		return tonumber(tp)
	end
	for held = level, 3 do
		if buffactive["aftermath: lv." .. held] then
			return 1000
		end
	end
	return level * 1000
end

-- Enough of a spell for cannot_act, so nothing is sent for a weapon skill that can't happen.
local any_weapon_skill = { type = "WeaponSkill", action_type = "Ability" }

local function auto_ws(tp)
	sync_autows()
	local choice = autows_choices[state.AutoWSMode.value]
	if not choice or player.status ~= "Engaged" or os.clock() < auto_action_time or cannot_act(any_weapon_skill) then
		return
	end

	local threshold = autows_threshold(choice[2])
	if threshold and tp >= threshold then
		send_command('input /ws "' .. choice[1] .. '" <t>')
	end
end

windower.register_event("tp change", auto_ws)

local autobuff_lists_built

-- AutoBuffMode offers Off plus buff_spell_lists' names, alphabetically.
local function sync_autobuff()
	if autobuff_lists_built == buff_spell_lists then
		return
	end
	autobuff_lists_built = buff_spell_lists
	local names = {}
	for name in pairs(buff_spell_lists or {}) do
		names[#names + 1] = name
	end
	table.sort(names)
	state.AutoBuffMode:options("Off", unpack(names))
end

local function buff_wanted(buff)
	local when = buff.When or "Always"
	return when == "Always"
		or (when == "Engaged" and player.status == "Engaged")
		or (when == "Idle" and player.status == "Idle")
		or (when == "Combat" and in_combat)
		or (when == "OutOfCombat" and not in_combat)
end

-- A spell GearSwap would let you cast, off recast and affordable, while nothing stops you acting.
-- Without the MP check a short cast would be refused, and gear swapped, twice a second.
local function can_cast_buff(buff)
	local spell = gearswap.res.spells[buff.SpellID]
	return spell ~= nil
		and player.mp >= (spell.mp_cost or 0)
		and not cannot_act({ action_type = "Magic", recast_id = spell.recast_id })
		and gearswap.check_spell(windower.ffxi.get_spells(), spell)
end

-- Blue magic the game refuses without Unbridled Learning (or Wisdom) up, from Sel's BLU file.
local unbridled_spells = set_of({
	"Absolute Terror",
	"Blistering Roar",
	"Bloodrake",
	"Carcharian Verve",
	"Cesspool",
	"Crashing Thunder",
	"Cruel Joke",
	"Droning Whirlwind",
	"Gates of Hades",
	"Harden Shell",
	"Mighty Guard",
	"Polar Roar",
	"Pyric Bulwark",
	"Tearing Gust",
	"Thunderbolt",
	"Tourbillion",
	"Uproot",
})
local unbridled_learning_recast = 81

local function unbridled_up()
	return buffactive["unbridled learning"] or buffactive["unbridled wisdom"]
end

-- Sel's check_buff: casts the first buff in the selected list that isn't up, one per tick. A buff
-- that needs Unbridled Learning gets the ability first, once it's ready; the spell follows next tick.
local function check_buff()
	sync_autobuff()
	local list = buff_spell_lists and buff_spell_lists[state.AutoBuffMode.value]
	if not list then
		return
	end
	for _, buff in ipairs(list) do
		local complete = buff.Name and buff.Buff and buff.SpellID
		if complete and not buffactive[buff.Buff:lower()] and buff_wanted(buff) and can_cast_buff(buff) then
			if not unbridled_spells[buff.Name] or unbridled_up() then
				send_command('input /ma "' .. buff.Name .. '" <me>')
				return
			elseif not recast_running(windower.ffxi.get_ability_recasts(), unbridled_learning_recast) then
				send_command('input /ja "Unbridled Learning" <me>')
				return
			end
		end
	end
end

-- As in Sel, combat ends 6s after your last action on a monster, once your battle target is gone.
local function update_combat()
	if in_combat and os.clock() >= last_in_combat + 6 then
		local battleTarget = windower.ffxi.get_mob_by_target("bt")
		if not battleTarget or battleTarget.hpp == 0 then
			in_combat = false
		end
	end
end

-- Sel's list of cities, where auto buffs stay off.
local cities = set_of({
	"Ru'Lude Gardens",
	"Upper Jeuno",
	"Lower Jeuno",
	"Port Jeuno",
	"Port Windurst",
	"Windurst Waters",
	"Windurst Woods",
	"Windurst Walls",
	"Heavens Tower",
	"Port San d'Oria",
	"Northern San d'Oria",
	"Southern San d'Oria",
	"Chateau d'Oraguille",
	"Port Bastok",
	"Bastok Markets",
	"Bastok Mines",
	"Metalworks",
	"Aht Urhgan Whitegate",
	"The Colosseum",
	"Tavnazian Safehold",
	"Nashmau",
	"Selbina",
	"Mhaura",
	"Rabao",
	"Norg",
	"Kazham",
	"Eastern Adoulin",
	"Western Adoulin",
	"Celennia Memorial Library",
	"Mog Garden",
	"Leafallia",
})

local moving = false
local last_position
local move_check_time = 0

-- Sel samples your position every 0.1s; a spell cast while moving would be interrupted. Sel
-- compares only x and z; all three here, so no direction of travel is missed.
local function track_movement()
	if os.clock() < move_check_time then
		return
	end
	move_check_time = os.clock() + 0.1
	local me = windower.ffxi.get_mob_by_target("me")
	if me then
		moving = last_position ~= nil
			and (me.x ~= last_position.x or me.y ~= last_position.y or me.z ~= last_position.z)
		last_position = { x = me.x, y = me.y, z = me.z }
	end
end

-- Sel's display: one line of modes along the bottom of the screen, a value in yellow once it's
-- off its first option.
local hud_colors = {
	white = "\\cs(255,255,255)",
	yellow = "\\cs(255,192,0)",
	gray = "\\cs(192,192,192)",
}

local function default_hud_position()
	local screen = windower.get_windower_settings()
	if screen.ui_x_res == 1920 and screen.ui_y_res == 1080 then
		return screen.ui_x_res - 1917, screen.ui_y_res - 18
	end
	return 2, screen.ui_y_res - 20
end

local hud_x, hud_y = default_hud_position()
local hud = texts.new({
	pos = { x = hud_x, y = hud_y },
	text = { font = "Arial", size = 12, stroke = { width = 2, alpha = 192 } },
	bg = { alpha = 0 },
	flags = { bold = true, draggable = true },
})
-- Windower text boxes start hidden.
hud:show()

local function hud_value(mode)
	local color = mode.current == mode[1] and hud_colors.white or hud_colors.yellow
	return color .. mode.current .. hud_colors.white
end

local function update_hud()
	sync_autows()
	sync_autobuff()
	sync_autoth()
	local items = {}
	local choice = autows_choices[state.AutoWSMode.value]
	if choice then
		items[#items + 1] = hud_colors.yellow .. "Auto WS: " .. choice[1] .. ": " .. choice[2] .. hud_colors.white
	end
	if state.AutoWSBuff.value then
		items[#items + 1] = hud_colors.yellow .. "Auto WS Buff" .. hud_colors.white
	end
	if state.AutoBuffMode.value ~= "Off" then
		items[#items + 1] = "Auto Buff: " .. hud_value(state.AutoBuffMode)
	end
	items[#items + 1] = "Weapons: " .. hud_value(state.Weapons)
	items[#items + 1] = "Offense: "
		.. hud_value(state.OffenseMode)
		.. hud_colors.gray
		.. " / "
		.. hud_value(state.HybridMode)
	if state.IdleMode.current ~= state.IdleMode[1] then
		items[#items + 1] = "Idle: " .. hud_value(state.IdleMode)
	end
	items[#items + 1] = "Casting: " .. hud_value(state.CastingMode)
	if state.AutoTHMode.value ~= "Off" then
		items[#items + 1] = "Auto TH: " .. hud_colors.yellow .. state.AutoTHMode.value .. hud_colors.white
	end
	hud:text("   " .. hud_colors.white .. table.concat(items, "    "))
end

update_hud()

-- GearSwap reloads the job file on a main job change and calls sub_job_change on a sub job change;
-- the hook runs after both. For the load, the first tick comes once the whole file has run.
local function job_changed()
	if job_post_job_change then
		job_post_job_change()
	end
end

function sub_job_change()
	job_changed()
end

local tick_time = 0
local load_reported = false

-- Sel's tick: a prerender check twice a second. Raw events don't refresh GearSwap's globals.
local function tick()
	track_movement()
	if os.clock() < tick_time then
		return
	end
	tick_time = os.clock() + 0.5
	gearswap.refresh_globals(false)
	if not load_reported then
		load_reported = true
		job_changed()
	end
	update_combat()
	update_hud()
	if moving or os.clock() < auto_action_time or buffactive.invisible or cities[world.area] then
		return
	end
	-- A buff cast now would still be in flight when the weapon skill re-fires, cancelling it.
	if os.clock() < ws_buff_lock then
		return
	end
	check_buff()
end

windower.raw_register_event("prerender", tick)

-- Nothing is locked yet after a reload mid-fight, so lock before re-equipping swaps weapons.
local function keep_weapons_in_hand()
	if should_lock_weapons(player.status) then
		lock_weapons()
	end
end

local function find_mode(name)
	local lowered = name:lower()
	for key, entry in pairs(state) do
		if type(key) == "string" and key:lower() == lowered then
			return entry, key
		end
	end
end

local command_usage = {
	cycle = "Usage: gs c cycle <Mode>",
	set = "Usage: gs c set <Mode> <Value>",
	toggle = "Usage: gs c toggle <Mode>",
}

function self_command(command)
	local action, modeName, value = command:match("^(%S*)%s*(%S*)%s*(.-)%s*$")
	if action == "update" then
		keep_weapons_in_hand()
		if not midaction() and not pet_midaction() then
			equip_status_gear(player.status)
		end
		return
	elseif action == "hud" then
		if hud:visible() then
			hud:hide()
		else
			hud:show()
		end
		return
	end
	if not command_usage[action] then
		if not (job_self_command and job_self_command(command)) then
			add_to_chat(123, "Unknown command: " .. command)
		end
		return
	end
	if modeName == "" then
		add_to_chat(123, command_usage[action])
		return
	end
	if value == "" then
		value = nil
	end

	local mode, modeKey = find_mode(modeName)
	if type(mode) ~= "table" or mode._class ~= "mode" then
		add_to_chat(123, "Unknown mode: " .. modeName)
		return
	end

	if mode == state.AutoWSMode then
		sync_autows()
	elseif mode == state.AutoTHMode then
		sync_autoth()
	elseif mode == state.AutoBuffMode then
		sync_autobuff()
	end

	local description = mode.description or modeKey
	if action == "toggle" then
		if mode._type ~= "boolean" then
			add_to_chat(123, description .. " isn't on/off: use gs c cycle " .. modeKey)
			return
		end
		mode:toggle()
	elseif action == "cycle" then
		mode:cycle()
	elseif not pcall(mode.set, mode, value) then
		add_to_chat(123, "Unknown " .. description .. " value: " .. (value or ""))
		return
	end

	add_to_chat(122, description .. ": " .. mode.current)
	if mode == state.Weapons then
		weapons_changed = true
		sync_autows()
	else
		keep_weapons_in_hand()
	end
	if not midaction() and not pet_midaction() then
		equip_status_gear(player.status)
	end
	update_hud()
end

-- GearSwap keeps disabled slots across job file loads.
function file_unload()
	unlock_weapons()

	if job_file_unload then
		job_file_unload()
	end
end
