-- Copy to data/<Character>/<JOB>.lua (e.g. data/Vanar/RDM.lua); GearSwap loads that file for the
-- matching character and job. Core.lua then picks the set for each action from the tables below.
-- Actions that can't happen right now (another action still resolving, a WS under 1000 TP, a
-- running recast, Silence, Amnesia, Sleep...) are cancelled silently before any gear changes.
-- Core.lua defines precast, midcast, aftercast, pet_midcast, pet_aftercast, status_change,
-- self_command and file_unload; don't define those here, since yours would replace Core's. Use the
-- job hooks at the bottom instead.
include("Core.lua")

-- Named pieces the sets below refer to as gear.*. Uncomment each piece you own and fill in its
-- name. A piece left commented out is nil, so sets using it skip that slot and whatever is layered
-- beneath (e.g. FastRecast) stays on.
local function init_gear()
	-- Artifact
	-- gear.af_head = ""
	-- gear.af_body = ""
	-- gear.af_hands = ""
	-- gear.af_legs = ""
	-- gear.af_feet = ""

	-- Relic
	-- gear.relic_head = ""
	-- gear.relic_body = ""
	-- gear.relic_hands = ""
	-- gear.relic_legs = ""
	-- gear.relic_feet = ""

	-- Empyrean
	-- gear.empy_head = ""
	-- gear.empy_body = ""
	-- gear.empy_hands = ""
	-- gear.empy_legs = ""
	-- gear.empy_feet = ""
	-- gear.empy_ear = ""

	-- Your best pieces for the job's magic skill, layered into sets with set_combine, e.g.
	-- sets.midcast["Blue Magic"] = set_combine(sets.midcast.FastRecast, gear.skill)
	gear.skill = {}
end

function get_sets()
	init_gear()

	-- Modes pick sub-sets such as sets.midcast.Frazzle.Resistant or sets.engaged.Acc.DT.
	-- Change them in game with: gs c cycle <Mode>   or   gs c set <Mode> <Value>
	-- or gs c toggle <Mode> for on/off modes. Mode names and values ignore case; the commands don't.
	-- gs c update puts your idle/engaged gear back on. The mode line along the bottom of the screen
	-- can be dragged anywhere (it starts back there on each load); gs c hud hides or shows it.
	-- Weapon skills follow OffenseMode: sets.precast.WS["Savage Blade"].Acc
	-- state.CastingMode:options("Normal", "Resistant")
	-- state.OffenseMode:options("Normal", "Acc")
	-- state.HybridMode:options("Normal", "DT")
	-- state.IdleMode:options("Normal", "DT")

	-- Weapons picks a sets.weapons entry, worn over your idle and engaged sets. While you're engaged
	-- with anything but 'None', main/sub/range are locked so casts can't zero your TP; otherwise any
	-- set may swap them (Temper or Enspell weapons, a MACC bow). The lock also holds back instrument
	-- swaps, and GearSwap refuses spells that need gear in those slots (Dispelga without Daybreak
	-- already in hand, Honor March). Change it with gs c: a state.Weapons:set() from your own code
	-- while engaged won't swap until you disengage.
	-- state.Weapons:options("None", "Naegling")
	-- sets.weapons.Naegling = { main = "Naegling", sub = "Ammurapi Shield" }

	-- AutoWS: { WS, TP } pairs per Weapons option. gs c cycle AutoWSMode steps through Off and the
	-- chosen weapon's pairs; changing Weapons turns it back to Off. While you're engaged, each TP
	-- change at or above the number uses the WS. "AM2"/"AM3" build that Aftermath level at 2000/3000
	-- TP, then use the WS at 1000 while it (or a higher level) lasts. A weapon with no entry does nothing.
	-- autows_list = {
	-- 	Naegling = { { "Savage Blade", 1000 } },
	-- 	Almace = { { "Savage Blade", 1000 }, { "Chant du Cygne", 1000 }, { "Chant du Cygne", "AM3" } },
	-- }

	-- AutoWSBuff (on by default; gs c cycle AutoWSBuff): before a weapon skill, uses one ready buff
	-- (Last Resort as DRK or /DRK, then Berserk, Warcry, Aggressor as WAR or /WAR) and re-fires the
	-- weapon skill 1.1s later. Presses in between are dropped.

	-- Auto buffs (Off by default; gs c cycle AutoBuffMode picks a list): like Sel, about twice a
	-- second it casts the first buff in the chosen list that isn't up. It waits while you're moving,
	-- just after an action, in town, invisible or unable to cast, and skips spells on recast or ones
	-- your jobs can't cast. Each entry has:
	--   Name    - the spell to cast on yourself
	--   Buff    - the buff it gives, as named on your buff bar (Temper II gives Multi Strikes)
	--   SpellID - the spell's id, for its recast
	--   When    - Always, Engaged, Idle, Combat (from your first action on a live monster until 6s
	--             after your battle target is gone) or OutOfCombat
	-- buff_spell_lists = {
	-- 	Melee = {
	-- 		{ Name = "Haste II", Buff = "Haste", SpellID = 511, When = "Always" },
	-- 		{ Name = "Temper II", Buff = "Multi Strikes", SpellID = 895, When = "Combat" },
	-- 	},
	-- 	Mage = {
	-- 		{ Name = "Refresh III", Buff = "Refresh", SpellID = 894, When = "Idle" },
	-- 	},
	-- }

	-- Auto TH (on by default; gs c cycle AutoTHMode picks the action, then Off): the selected spell or
	-- ability gets sets.TreasureHunter on top, at precast for abilities and midcast for spells.
	-- autoth_list = { "Provoke", "Dia II" }
	-- sets.TreasureHunter = { waist = "Chaac Belt" }

	-- Precast: magic uses sets.precast.FC, weapon skills .WS, job abilities .JA, ranged attacks .RA
	-- and items .Item. Other ability types (Waltz, Step, BloodPactRage...) use a table named for the
	-- type when you define one, e.g. sets.precast.Waltz, and .JA otherwise. Within each, the most
	-- specific set wins: spell name, spell map (Frazzle covers Frazzle I-III), skill, then type, e.g.
	-- sets.precast.FC["Enhancing Magic"].
	-- Core also maps spells the way Sel's job files did, so these work as set names too:
	-- LowTierNuke/HighTierNuke, Blue Magic categories (PhysicalStr, Magical, Buff...),
	-- NinjutsuBuff/NinjutsuDebuff, Physical/MagicalBloodPactRage, DebuffBloodPactWard, Indi, and Cure
	-- variants like LightWeatherCure, LightDayCuraga, CureSolace and MeleeCure (while your weapons
	-- are locked). A Cure or Curaga variant with no set uses your Cure or Curaga set;
	-- job_get_spell_map can override any map.
	sets.precast.FC = {}
	sets.precast.WS = {}

	-- Midcast: FastRecast goes on first for all magic, then the most specific set on top, e.g.
	-- sets.midcast["Frazzle II"], sets.midcast.Frazzle, sets.midcast["Enfeebling Magic"].
	-- Ranged attacks use sets.midcast.RA, or sets.midcast.RangedAttack if your precast set is named
	-- sets.precast.RangedAttack. Weapon skills and job abilities have no midcast: they go off in
	-- their precast gear, and job_post_midcast doesn't run for them.
	sets.midcast.FastRecast = {}

	-- Pet moves (Blood Pacts, BST Ready) use sets.midcast.Pet with the same lookup, e.g.
	-- sets.midcast.Pet["Flaming Crush"] or sets.midcast.Pet.BloodPactRage. It goes on as soon as your
	-- pet command resolves (or the pet readies a move itself), and idle/engaged gear comes back once
	-- the pet's move is done.

	-- Worn after every action and whenever your status changes.
	sets.idle = {}
	sets.engaged = {}
	sets.resting = {}
end

-- Job hooks. Core.lua calls each one if it exists; gear equipped in a post hook goes on top of the
-- set Core.lua chose.

-- Return a spell map name to use instead of defaultMap, or nil to keep it.
function job_get_spell_map(spell, defaultMap) end

function job_post_precast(spell, spellMap) end

-- Not called for weapon skills or job abilities, which have no midcast.
function job_post_midcast(spell, spellMap) end

function job_post_aftercast(spell, spellMap) end

-- Return the set to wear whenever idle or engaged gear goes on (after actions, status and mode
-- changes). Build it with set_combine, e.g. set_combine(idleSet, sets.Kiting), so that sets.idle
-- itself isn't changed.
function job_customize_idle_set(idleSet)
	return idleSet
end

function job_customize_melee_set(meleeSet)
	return meleeSet
end

-- Gets any gs c command Core doesn't handle itself (cycle, set, toggle, update, hud); return true
-- for the ones you handle.
function job_self_command(command) end

-- Runs when this file unloads (job change, //gs reload), e.g. to unbind keys bound in get_sets().
function job_file_unload() end
