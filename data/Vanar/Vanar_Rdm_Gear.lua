function character_user_job_setup()
	-- Options: Override default values
    state.OffenseMode:options('Normal','Acc')
    state.HybridMode:options('Normal','DT')
	state.WeaponskillMode:options('Match','Proc')
	state.CastingMode:options('Normal','Resistant','Proc','SIRD')
    state.IdleMode:options('Normal','PDT','MDT','MEVA','Aminon')
    state.PhysicalDefenseMode:options('PDT','NukeLock')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.BuffWeaponsMode = M{'Always','Never'}
	state.AutoBuffMode = M{['description'] = 'Auto Buff Mode','Off','Auto','AutoMelee','AutoMage'}
	state.Weapons:options('None','Naegling','Maxentius','Crocea','Tauret','EnspellOnly','Savage Blade','Savage Blade Acc','Black Halo','DualCrocea','Black Halo Max Acc','DualPrime','DualAeolian','DualEnspellOnly','DualProcSword')

	--Weaponskills that get a buff from Auto WS Buff (User-Globals.lua) first.
	ws_buff_list = S{'Savage Blade','Evisceration','Chant du Cygne','Vorpal Blade','Black Halo','Requiescat','Realmrazer'}
	state.WeaponSets:options('Default','Dual','Proc','Dynamis')

	weapon_sets = {
		['Default'] = {'None','Naegling','Maxentius','Crocea','Tauret','EnspellOnly'},
		['Dual'] = {'Savage Blade','Savage Blade Acc','Black Halo','DualCrocea','Black Halo Max Acc','DualPrime','DualAeolian','DualEnspellOnly'},
		['Dynamis'] = {'DualCroceaSavageBlade','DualCrocea','DualTauretCrocea','DualAeolian'},
		['Proc'] = {'ProcSword','ProcDagger','DualProcSword','DualProcDagger'},
	}

	default_weapons = 'Naegling'
	default_dual_weapons = 'Savage Blade'

	--Auto WS choices for each weapon mode, by its name in the Weapons options and the weapon_sets lists above.
	--Moonshade Earring's TP Bonus +250, which the weapon skill sets wear, turns 1750 into 2000 and 2750 into
	--3000, the cap. With Thibron's TP Bonus +1000 in the offhand, 1750 already reaches the cap, so those modes
	--stop at 1750. A mode that wears the pair of a rahvin branch RDM.lua mode takes its choices: DualCrocea the
	--Sanguine Blade mode's (Naegling and Bunzi's Rod), DualPrime the Evisceration mode's (Tauret and Gleti's Knife),
	--DualCroceaSavageBlade the Savage Blade mode's. DualAeolian and DualTauretCrocea (Tauret and Bunzi's Rod) take the
	--Aeolian Edge mode's, whose off hand was Gleti's Knife. The one-weapon modes (Naegling, Crocea, Maxentius and
	--Tauret, each with Ammurapi Shield) had no rahvin match, so they take the weapon skill Mytha's file named for them.
	--None, the enspell modes and the proc modes have no entry.
	AutoWS_List = {
		['Naegling'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 }, { 'Savage Blade', 2750 } },
		['Crocea'] = { { 'Sanguine Blade', 1000 } },
		['Maxentius'] = { { 'Black Halo', 1000 }, { 'Black Halo', 1750 }, { 'Black Halo', 2750 } },
		['Tauret'] = { { 'Aeolian Edge', 1000 }, { 'Aeolian Edge', 1750 }, { 'Aeolian Edge', 2750 } },
		['Savage Blade'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 } },
		['Savage Blade Acc'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 }, { 'Savage Blade', 2750 } },
		['Black Halo'] = { { 'Black Halo', 1000 }, { 'Black Halo', 1750 } },
		['Black Halo Max Acc'] = { { 'Black Halo', 1000 }, { 'Black Halo', 1750 }, { 'Black Halo', 2750 } },
		['DualCrocea'] = { { 'Sanguine Blade', 1000 } },
		['DualPrime'] = { { 'Evisceration', 1000 }, { 'Evisceration', 1750 }, { 'Evisceration', 2750 } },
		['DualAeolian'] = { { 'Aeolian Edge', 1000 }, { 'Aeolian Edge', 1750 }, { 'Aeolian Edge', 2750 } },
		['DualCroceaSavageBlade'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 } },
		['DualTauretCrocea'] = { { 'Aeolian Edge', 1000 }, { 'Aeolian Edge', 1750 }, { 'Aeolian Edge', 2750 } },
	}
	trust_list = {"Joachim","Ulmia","Qultada","Yoran-Oran (UC)","Selh'teus"}
	
	--Vanar's Sucellos's Capes, named by their augments exactly as //gs export prints them. Vanar has no MND, INT or
	--DEX weapon skill damage cape and no Dual Wield cape, so the sets that wore one take the closest of these four.
	gear.mnd_enfeebling_jse_back = {name="Sucellos's Cape",augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','Haste+10',}}
	gear.int_enfeebling_jse_back = {name="Sucellos's Cape",augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10',}}
	gear.nuke_jse_back = gear.int_enfeebling_jse_back
	gear.str_wsd_jse_back = {name="Sucellos's Cape",augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%',}}
	gear.da_jse_back = {name="Sucellos's Cape",augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%',}}
	--Vanar holds two Colada and two Telchine Gloves, so these name the copy by its augments.
	gear.colada_refresh = {name="Colada",augments={'"Refresh"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12','DMG:+1',}}
	gear.telchine_regen_hands = {name="Telchine Gloves",augments={'"Regen" potency+3',}}
	gear.telchine_duration_hands = {name="Telchine Gloves",augments={'Haste+3','Enh. Mag. eff. dur. +10',}}
	
		-- Additional local binds
	send_command('bind @` gs c cycle ElementalMode')
	send_command('bind ^` gs c scholar dark')
	send_command('bind !` gs c scholar light')
	send_command('bind !backspace input /ja "Composure" <me>')
	send_command('bind ^backspace input /ja "Saboteur" <me>')
	send_command('bind @backspace input /ja "Spontaneity" <t>')
	send_command('bind ^\\\\ input /ma "Protect V" <t>')
	send_command('bind @\\\\ input /ma "Shell V" <t>')
	send_command('bind !\\\\ input /ma "Reraise III" <me>')
	send_command('bind @f8 gs c toggle AutoNukeMode')
	send_command('bind @f10 gs c cycle RecoverMode')
	
	select_default_macro_book()
end

function init_gear_sets()
	--------------------------------------
	-- Start defining the sets
	--------------------------------------

	-- Every piece below is in Vanar's wardrobe or wardrobe 2 in data/export/Vanar 2026-10-08 01-37-10.lua. The sets
	-- were rebuilt from Mytha's, each for the same job, with the totals worked out from the pieces' help text, the
	-- export's augments, docs/gear-notes.md and data/Vanar/Vanar_rank_augments.md. None has been tried in game.
	-- Leth. Earring +1 is always in the right ear, the only ear its Fast Cast, duration and augments work in, so the
	-- Moonshade Earring sets put Moonshade in the left ear and sets.MaxTP swaps the left ear.

	-- Weapons sets. Vanar has no Crocea Mors, Daybreak, Blurred Knife +1, Qutrub Knife, Sacro Bulwark or Ethereal
	-- Dagger, and his Mpu Gandring (Mog Safe 2) and Demers. Degen +1 (Mog Locker) aren't in the wardrobes, so the modes
	-- that named them take the nearest pair he carries, and several modes now wear the same pair.
	sets.weapons.Naegling = {main="Naegling",sub="Ammurapi Shield",range=empty}
	-- Crocea Mors: Naegling is Vanar's best sword for Sanguine and Seraph Blade (Magic Damage 217, MAB 16).
	sets.weapons.Crocea = {main="Naegling",sub="Ammurapi Shield",range=empty}
	sets.weapons.Maxentius = {main="Maxentius",sub="Ammurapi Shield",range=empty}
	sets.weapons.Tauret = {main="Tauret",sub="Ammurapi Shield",range=empty}
	sets.weapons['Savage Blade'] = {main="Naegling",sub="Thibron",range=empty}
	sets.weapons['Savage Blade Acc'] = {main="Naegling",sub="Gleti's Knife",range=empty}
	-- No Mpu Gandring in the wardrobes, so no Ruthless Stroke: the dagger pair for Evisceration instead.
	sets.weapons.DualPrime = {main="Tauret",sub="Gleti's Knife",range=empty}
	sets.weapons.DualEvisceration = {}
	-- Crocea Mors and Daybreak: Naegling with Bunzi's Rod (MAB 35, Macc 40 from the off hand) for the magical sword
	-- weapon skills.
	sets.weapons.DualCrocea = {main="Naegling",sub="Bunzi's Rod",range=empty}
	-- Bunzi's Rod over Maxentius in the off hand: the same Macc 40, INT 15 and MND 15, and MAB 35 against 21 for
	-- Aeolian Edge, which scales with MAB (ffxi-mechanics.md, Magical weapon skill damage).
	sets.weapons.DualAeolian = {main="Tauret",sub="Bunzi's Rod",range=empty}
	-- The proc modes want a weapon of the right type, not damage. Pukulatmuj +1 stands in for Demers. Degen +1 and
	-- Gleti's Knife for Blurred Knife +1.
	sets.weapons.DualProcSword = {main="Pukulatmuj +1",sub="Gleti's Knife",range=empty}
	sets.weapons.ProcSword = {main="Pukulatmuj +1",sub="Ammurapi Shield",range=empty}
	sets.weapons.ProcDagger = {main="Gleti's Knife",sub="Ammurapi Shield",range=empty}
	sets.weapons.DualProcDagger = {main="Gleti's Knife",sub="Pukulatmuj +1",range=empty}
	-- No Qutrub Knife or Ethereal Dagger. Tauret has the most main-hand Magic Accuracy skill of Vanar's daggers (250),
	-- which every Enspell hit rolls with, and Ammurapi Shield (Macc 38) or Gleti's Knife (Macc 40) adds to it. Melee
	-- Enspell damage gear is left out by the player's rule (Vanar_notes.md, Rules for these sets).
	sets.weapons.EnspellOnly = {main="Tauret",sub="Ammurapi Shield"}
	sets.weapons.DualEnspellOnly = {main="Tauret",sub="Gleti's Knife"}
	sets.weapons.DualBow = {}
	sets.weapons.BowMacc = {}
	sets.weapons['Black Halo'] = {main="Maxentius",sub="Thibron",range=empty}
	sets.weapons['Black Halo Max Acc'] = {main="Maxentius",sub="Gleti's Knife",range=empty}

	--Temporary Weapon Sets for Dynamis RP. No Crocea Mors: the Savage Blade and Aeolian Edge pairs above.
	sets.weapons.DualCroceaSavageBlade = {main="Naegling",sub="Thibron"}
	sets.weapons.DualTauretCrocea = {main="Tauret",sub="Bunzi's Rod"}

	-- Precast Sets

	-- Precast sets to enhance JAs
	sets.precast.JA['Chainspell'] = {body="Viti. Tabard +4"}	-- Chainspell +20 s

	-- Steps (Pure Acc). Every slot takes Vanar's most accurate RDM piece; four Atrophy +4 pieces add Acc 45. Lehko's
	-- Ring's DEX 10 (about 7 accuracy) beats Ayanmo Ring's Acc 6 by a point or two. No ammo RDM carries has accuracy.
	sets.precast.Step = {ammo="Coiste Bodhar",
		head="Atro. Chapeau +4",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Atrophy Tabard +4",hands="Atro. Gloves +4",ring1="Lehko's Ring",ring2="Jhakri Ring",
		back=gear.da_jse_back,waist="Eschan Stone",legs="Atro. Tights +4",feet="Leth. Houseaux +3"}

	-- Violent Flourish (Macc & Acc): the Step set, with Snotra Earring (Macc 10) for Alabaster Earring (Acc and Macc 2)
	-- and Ayanmo Ring (Acc and Macc 6) for Lehko's Ring, for Macc 14 more at about 3 less accuracy.
	sets.precast.JA['Violent Flourish'] = set_combine(sets.precast.Step, {ear1="Snotra Earring",ring1="Ayanmo Ring"})

	-- Waltz set (chr and vit). Empty: no armor Vanar's RDM carries has Waltz potency (Gleti's Knife's +10% would cost
	-- the TP of a weapon swap), and a DNC subjob's Waltz gets half the CHR and VIT term (ffxi-mechanics.md, Dancer
	-- abilities from a DNC subjob).
	sets.precast.Waltz = {}

	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}

	-- Fast cast. The Fast Cast trait gives 38%, so 42% from gear reaches the 80% cap (ffxi-mechanics.md, Fast Cast).
	-- Four pieces give 44, and the rest of the set is damage taken. Impatiens, Perimede Cape and the other Quick Magic
	-- pieces are left out by the player's rule.
	sets.precast.FC = {
		head="Atro. Chapeau +4",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Viti. Tabard +4",hands="Leth. Ganth. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Embla Sash",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	sets.precast.FC.DT = set_combine(sets.precast.FC, {})

	-- Every Fast Cast piece Vanar carries, for Impact, which takes the head and body. Jhakri Cuffs +2 with Jhakri Ring
	-- make a two-piece Jhakri set, Fast Cast 3 (gear-notes.md, Jhakri set). Colada's Fast Cast 4 counts only when the
	-- weapons are free.
	sets.precast.FullFC = {main=gear.colada_refresh,
		head="Atro. Chapeau +4",ear1="Loquac. Earring",ear2="Leth. Earring +1",
		body="Viti. Tabard +4",hands="Jhakri Cuffs +2",ring1="Jhakri Ring",ring2="Prolix Ring",
		back="Fi Follet Cape +1",waist="Embla Sash",feet="Chelona Boots"}

	-- Impact needs Twilight Cloak, which is in the Mog Case: the engine puts it on (RDM.lua) once it is in a wardrobe.
	-- Without the head and body this set has Fast Cast 32, or 36 with Colada: 70% or 74% with the trait, short of 80%.
	sets.precast.FC.Impact = set_combine(sets.precast.FullFC, {head=empty})
	-- Dispelga needs Daybreak, which Vanar doesn't own, so this is the plain fast cast set.
	sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {})

	-- Weaponskill sets
	-- Floor: Composure is always up when RDM melees and its +70 accuracy counts (Vanar_notes.md, Rules for these sets),
	-- so the TP-mode weapon skill sets need about 1280 from gear and Oden. The sets below were picked by a search over
	-- Vanar's pieces for the most expected damage at or over that, on the formulas in ffxi-mechanics.md and bg-wiki's test
	-- enemy (1350 evasion, 1500 defense), with Composure's +70 in the hit rate. The estimates anchor to Vanar_notes.md
	-- (Accuracy) and assume Thibron or Ammurapi Shield in the off hand; Gleti's Knife adds 40.

	-- Default set for any weaponskill that isn't any more specifically defined: the Savage Blade set below with Fotia
	-- Gorget, whose +25/256 fTP goes on every hit of a multi-hit weapon skill (ffxi-mechanics.md, Elemental gorgets and
	-- belts). Fotia Belt would take Eschan Stone's Acc 15 and put the set under the floor, since its own Accuracy 10 is
	-- weapon skill accuracy only.
	sets.precast.WS = {range=empty,ammo="Coiste Bodhar",
		head="Viti. Chapeau +4",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Atro. Gloves +4",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
		back=gear.str_wsd_jse_back,waist="Eschan Stone",legs="Nyame Flanchard",feet="Leth. Houseaux +3"}

	-- ACC mode, by the player's ACC rule: the most accuracy each slot can take, ties going to damage. The Step set, with
	-- Fotia Gorget's weapon skill Accuracy 10 for Sanctity Necklace's Accuracy 10, a tie its fTP wins. Every physical
	-- weapon skill's .Acc set below is this one.
	sets.precast.WS.Acc = set_combine(sets.precast.Step, {neck="Fotia Gorget"})

	-- Proc mode: the weapon skill only has to land, so the Step set's accuracy.
	sets.precast.WS.Proc = set_combine(sets.precast.Step, {})

	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	-- Requiescat: five MND hits that can't crit, with fTP 1.0 on each, so both Fotia pieces (+25/256 fTP, about 10% a hit
	-- each) and Moonshade's TP Bonus, which shrinks its attack penalty. With Composure the hit rate is at or near its 95%
	-- cap, so Viti. Chapeau +4 (Att 72, WSD 9) and the Nyame Flanchard (WSD 9, DA 3 at rank 20) take the head and legs,
	-- and Karieyh Ring Lehko's Ring's place: about 5% more than the Lethargy set it replaces, on the search. About 1295
	-- from gear and Oden.
	sets.precast.WS['Requiescat'] = {range=empty,ammo="Coiste Bodhar",
		head="Viti. Chapeau +4",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Karieyh Ring",ring2="Jhakri Ring",
		back=gear.da_jse_back,waist="Fotia Belt",legs="Nyame Flanchard",feet="Leth. Houseaux +3"}
	sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS.Acc, {})

	-- Chant du Cygne and Evisceration: crits that rise with TP, on every hit. The Requiescat set with Lehko's Ring (Crit
	-- 10, DEX 10) for Karieyh Ring. Vanar has no crit cape for RDM; the Double Attack cape gives Acc 30 and DEX 20.
	sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS['Requiescat'], {ring1="Lehko's Ring"})
	sets.precast.WS['Chant du Cygne'].Acc = set_combine(sets.precast.WS.Acc, {})

	sets.precast.WS['Evisceration'] = sets.precast.WS['Chant du Cygne']

	-- Savage Blade (50% STR, 50% MND): Viti. Chapeau +4, the Nyame Flanchard and Atro. Gloves +4 bring back WSD 9 each,
	-- with Leth. Houseaux +3's 12, the cape's 10 and the rings' 8: WSD 57. Lethargy Sayon +3 (Acc 64, Att 64) over Nyame
	-- Mail and Eschan Stone over Sailfi Belt +1 hold the floor: about 1282 from gear and Oden, 1352 with Composure. The
	-- search puts it about 17% above the set without Composure counted, and bg-wiki's simulated set (Nyame Mail, Sailfi
	-- Belt +1) about 7% above it, at about 1306 with Composure, under the floor. Rajas Ring for Karieyh Ring gives 4 more
	-- for about 0.7% less.
	sets.precast.WS['Savage Blade'] = {range=empty,ammo="Coiste Bodhar",
		head="Viti. Chapeau +4",neck="Rep. Plat. Medal",ear1="Moonshade Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Atro. Gloves +4",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
		back=gear.str_wsd_jse_back,waist="Eschan Stone",legs="Nyame Flanchard",feet="Leth. Houseaux +3"}
	sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS.Acc, {})

	-- Black Halo (70% MND, 30% STR): the club hand is about 70 accuracy behind the sword's (Vanar_notes.md, Accuracy), so
	-- the floor keeps more accuracy here: Atro. Chapeau +4 with the gloves (a two-piece Atrophy set, Acc +15), the
	-- Lethargy body and legs, Eschan Stone and Rajas Ring. About 1282 from gear and Oden with Maxentius and Thibron,
	-- 1352 with Composure; the search puts it about 32% above the all-Atrophy set it replaces.
	sets.precast.WS['Black Halo'] = {range=empty,ammo="Coiste Bodhar",
		head="Atro. Chapeau +4",neck="Rep. Plat. Medal",ear1="Moonshade Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Atro. Gloves +4",ring1="Epaminondas's Ring",ring2="Rajas Ring",
		back=gear.str_wsd_jse_back,waist="Eschan Stone",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}
	sets.precast.WS['Black Halo'].Acc = set_combine(sets.precast.WS.Acc, {})

	-- Sanguine Blade: a magical weapon skill (dark, 50% MND and 30% STR, INT x 2 with no cap), so MAB, Magic Damage
	-- and weapon skill damage, which counts on the whole hit. TP doesn't raise its damage, so Friomisi Earring (MAB 10)
	-- for Moonshade. The STR weapon skill damage cape over the INT cape: WSD 10 on the whole hit and STR 30 in the
	-- WSC against INT 20, Magic Damage 20 and MAB 10, about 3% more damage at Vanar's totals (more on the three below,
	-- which have no INT term or a capped one), for 30 less magic accuracy. Karieyh Ring's WSD 3 beats Jhakri Ring's
	-- MAB 3 by about 1.5%. Sanguine Blade has no skillchain property, so no Fotia.
	sets.precast.WS['Sanguine Blade'] = {range=empty,ammo="Pemphredo Tathlum",
		head="Leth. Chappel +3",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Leth. Earring +1",
		body="Nyame Mail",hands="Jhakri Cuffs +2",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
		back=gear.str_wsd_jse_back,waist="Eschan Stone",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	-- Seraph Blade (light, 40% STR, 40% MND, no INT term) gains damage with TP, so Moonshade Earring goes back in, and
	-- it has a skillchain property, so Fotia Belt (+25/256 fTP, and its Accuracy 10 counts as magic accuracy here).
	sets.precast.WS['Seraph Blade'] = set_combine(sets.precast.WS['Sanguine Blade'], {ear1="Moonshade Earring",waist="Fotia Belt"})

	sets.precast.WS['Shining Strike'] = sets.precast.WS['Seraph Blade']
	-- Flash Nova (club, light, 50% STR and 50% MND, fTP 3.0 at any TP): TP doesn't raise it, so the Sanguine Blade
	-- set with Fotia Belt, since it has a skillchain property.
	sets.precast.WS['Flash Nova'] = set_combine(sets.precast.WS['Sanguine Blade'], {waist="Fotia Belt"})

	-- Aeolian Edge (wind, 40% DEX, 40% INT) and Red Lotus Blade (fire, 40% STR, 40% INT): as Seraph Blade.
	sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS['Seraph Blade'], {})

	sets.precast.WS['Red Lotus Blade'] = sets.precast.WS['Aeolian Edge']

	-- ACC mode for the magical weapon skills: the ACC rule's most accuracy is magic accuracy here, since accuracy does
	-- nothing for them (Vanar_notes.md, Rules for these sets). All four Atrophy pieces (Macc 59 to 65, and +45 as a
	-- set), Leth. Houseaux +3 (Macc 60), Dls. Torque +1 (25), Snotra Earring (10), Leth. Earring +1 (15), both Stikini
	-- Rings (8), Obstin. Sash (15, over Fotia Belt's 10 on the skillchain ones) and the INT cape (30, tied with the MND
	-- cape and ahead on MAB and Magic Damage). Shining Strike and Red Lotus Blade share their sets' tables, so they get
	-- these too.
	sets.precast.WS['Sanguine Blade'].Acc = {range=empty,ammo="Pemphredo Tathlum",
		head="Atro. Chapeau +4",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Atrophy Tabard +4",hands="Atro. Gloves +4",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.int_enfeebling_jse_back,waist="Obstin. Sash",legs="Atro. Tights +4",feet="Leth. Houseaux +3"}
	sets.precast.WS['Seraph Blade'].Acc = set_combine(sets.precast.WS['Sanguine Blade'].Acc, {})
	sets.precast.WS['Flash Nova'].Acc = set_combine(sets.precast.WS['Sanguine Blade'].Acc, {})
	sets.precast.WS['Aeolian Edge'].Acc = set_combine(sets.precast.WS['Sanguine Blade'].Acc, {})

	-- Swap to these on Moonshade using WS if at 3000 TP. Moonshade is in the left ear in every set above.
	sets.MaxTP = {ear1="Brutal Earring"}	-- DA 5
	sets.AccMaxTP = {ear1="Alabaster Earring"}	-- Acc 2
	sets.MagicalMaxTP = {ear1="Friomisi Earring"}	-- MAB 10

	-- Midcast Sets

	-- Worn under every spell's midcast set (Sel-Include.lua, filter_midcast), and the set for spells with none of
	-- their own. Recast falls with gear haste, which caps at 26% as listed, and with half of Fast Cast: Haste 26 and
	-- Fast Cast 44 here, 82% with the trait, so recast is at the 40% Fast Cast part's cap. The other slots are damage
	-- taken. It names no weapons, so a spell with none of its own keeps the ones in hand.
	sets.midcast.FastRecast = {ammo="Hasty Pinion",
		head="Atro. Chapeau +4",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Viti. Tabard +4",hands="Leth. Ganth. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Embla Sash",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	-- Cure potency to the 50% cap from armor alone, since with the weapons locked the main and sub never go on. With
	-- them free, Bunzi's Rod adds 30 more, past the cap, and its MND 15. Viti. Tabard +4 adds Healing magic skill 24.
	sets.midcast.Cure = {main="Bunzi's Rod",sub="Ammurapi Shield",range=empty,
		head="Atro. Chapeau +4",neck="Nodens Gorget",ear1="Alabaster Earring",ear2="Mendi. Earring",
		body="Viti. Tabard +4",hands=gear.telchine_duration_hands,ring1="Murky Ring",ring2="Naji's Loop",
		back="Solemnity Cape",waist="Embla Sash",legs="Atro. Tights +4",feet="Vanya Clogs"}

	-- Light weather and Lightsday. Vanar has no Chatoyant Staff, Twilight Cape or Hachirin-no-Obi in the wardrobes,
	-- so these are the Cure set.
	sets.midcast.LightWeatherCure = set_combine(sets.midcast.Cure, {})

		--Cureset for if it's not light weather but is light day.
	sets.midcast.LightDayCure = set_combine(sets.midcast.Cure, {})

	-- Cures in a defense mode, which the engine only reaches with the weapons free (Weapons None): Bunzi's Rod's Cure
	-- 30 lets the armor give up Cure for damage taken. Cure 57 (cap 50), DT 58, PDT 8 and MDT 3.
	sets.midcast.Cure.DT = {main="Bunzi's Rod",sub="Forfend +1",range=empty,
		head="Leth. Chappel +3",neck="Nodens Gorget",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Flume Belt",legs="Atro. Tights +4",feet="Vanya Clogs"}

	-- Cursna from a WHM subjob: its chance rises with Healing magic skill and "Cursna" (Vanya Clogs +5). The fast
	-- recast set, with Viti. Tabard +4 (24), Atro. Tights +4 (18) and Vanya Clogs (20).
	sets.midcast.Cursna = set_combine(sets.midcast.FastRecast, {legs="Atro. Tights +4",feet="Vanya Clogs"})

	sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {})

	-- Enhancing magic, the base every enhancing spell starts from (RDM.lua layers this set, then the Composure set,
	-- then the spell's own). Its 545 enhancing skill (481 without gear, plus Viti. Tabard +4, Leth. Houseaux +3 and
	-- Ghostfyre Cape) is past the 500 where most enhancing spells stop gaining, so it is built for duration, then
	-- recast. Listed duration adds up (103%) and augmented duration adds up (60%), and the two multiply: 3.25 times
	-- base duration (ffxi-mechanics.md, Enhancing duration). Ghostfyre's augmented 20% beats a Sucellos's Cape's
	-- listed 20%. Gear haste 26 (the cap) and Fast Cast 30, 34 with Colada.
	sets.midcast['Enhancing Magic'] = {main=gear.colada_refresh,sub="Ammurapi Shield",ammo="Hasty Pinion",
		head="Telchine Cap",neck="Dls. Torque +1",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Viti. Tabard +4",hands="Atro. Gloves +4",ring1="Murky Ring",ring2="Prolix Ring",
		back="Ghostfyre Cape",waist="Embla Sash",legs="Telchine Braconi",feet="Leth. Houseaux +3"}

	-- Composure on someone else: four Lethargy pieces add 35%. Atro. Gloves +4 stay, since their listed 20% is worth
	-- more than the fifth piece's 15% step (3.55 against 3.53 times base).
	sets.buff.ComposureOther = {head="Leth. Chappel +3",
		body="Lethargy Sayon +3",
		legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	--Red Mage enhancing sets are handled in a different way from most, layered on due to the way Composure works
	--Don't set combine a full set with these spells, they should layer on Enhancing Set > Composure (If Applicable) > Spell
	-- Temper, Temper II and the Enspells keep gaining from enhancing skill past 500, so every skill piece, weapons
	-- included: 654 skill, which gives Temper II 35% Triple Attack (40% at 700). Forfend +1's skill is its rank 15 +10.
	sets.EnhancingSkill = {main="Pukulatmuj +1",sub="Forfend +1",
		neck="Enhancing Torque",ear1="Mimir Earring",ear2="Andoaa Earring",
		body="Viti. Tabard +4",hands="Viti. Gloves +4",ring1="Stikini Ring",ring2="Stikini Ring",
		back="Fi Follet Cape +1",waist="Olympus Sash",legs="Atro. Tights +4",feet="Leth. Houseaux +3"}

	-- Refresh potency, which is what the player puts first when casting Refresh: +8 MP a tick.
	sets.midcast.Refresh = {head="Amalric Coif +1",body="Atrophy Tabard +4",legs="Leth. Fuseau +3"}
	-- 545 skill gives three blocks; Amalric Coif +1 adds two. Vanar has no Regal Cuffs, Emphatikos Rope or Shedir
	-- Seraweels, the other +4.
	sets.midcast.Aquaveil = {head="Amalric Coif +1"}
	-- Barspells cap at 500 skill, which the base set passes. No Shedir Seraweels.
	sets.midcast.BarElement = {}
	-- No Sroda Necklace.
	sets.midcast.BarStatus = {}
	sets.midcast.Temper = sets.EnhancingSkill
	sets.midcast.Enspell = sets.EnhancingSkill
	sets.midcast.BoostStat = {hands="Viti. Gloves +4"}	-- Gain +30
	-- Stoneskin: the base set's skill caps it at 350; Stoneskin+ goes past, to 400.
	sets.midcast.Stoneskin = {neck="Nodens Gorget",waist="Siegel Sash"}
	-- No Sheltered Ring.
	sets.midcast.Protect = {}
	sets.midcast.Shell = {}
	-- Regen potency first, by the player's rule: "Regen" potency +9 from the three Telchine pieces.
	sets.midcast.Regen = {body="Telchine Chas.",hands=gear.telchine_regen_hands,feet="Telchine Pigaches"}

	sets.midcast.Curaga = sets.midcast.Cure
	-- Cure received, Refresh received and Phalanx received gear: Vanar carries none (no Phalaina Locket, Kunaji Ring,
	-- Gishdubar Sash, Taeon or Sakpata's pieces).
	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {}
	sets.Self_Phalanx = {}
	sets.Self_Phalanx.DW = {}

	-- Enfeebling magic. Enfeebling skill adds to its magic accuracy one for one, so the accuracy sets take Viti.
	-- Chapeau +4 (Macc 42, the merit augment's 15 and skill 27) and Leth. Ganth. +3 (Macc 62, skill 29) over the Atrophy
	-- head and gloves: 18 more, though the Atrophy bonus falls to 15. The potency sets add Lethargy Sayon +3's effect +18
	-- and three Lethargy pieces (20% longer with Composure); the duration sets wear all five (50%). Every set keeps Dls.
	-- Torque +1 (Macc 25, effect +7, augmented duration 20%), Obstin. Sash (Macc 15 and skill 2 at rank 17), Snotra
	-- Earring (Macc 10, duration 10%), Leth. Earring +1 (Macc 15) and both Stikini Rings (Macc 8, skill 5). The MND cape
	-- goes on white magic and Frazzle and Distract, and the INT cape on black magic (ffxi-mechanics.md, dSTAT). With the
	-- weapons free, Bunzi's Rod (Macc 40 and Magic Accuracy skill 255) and Ammurapi Shield (Macc 38) go on, and the
	-- accuracy sets add Ullr (Macc 40), which empties the ammo slot. With the weapons locked, user_job_post_midcast
	-- below puts Pemphredo Tathlum in that slot.

	-- Enfeebles with no set of their own, such as Slow II: the MND potency set.
	sets.midcast['Enfeebling Magic'] = {main="Bunzi's Rod",sub="Ammurapi Shield",range=empty,ammo="Pemphredo Tathlum",
		head="Viti. Chapeau +4",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.mnd_enfeebling_jse_back,waist="Obstin. Sash",legs="Leth. Fuseau +3",feet="Viti. Boots +4"}

	sets.midcast['Enfeebling Magic'].Resistant = {main="Bunzi's Rod",sub="Ammurapi Shield",range="Ullr",ammo=empty,
		head="Viti. Chapeau +4",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Atrophy Tabard +4",hands="Leth. Ganth. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.mnd_enfeebling_jse_back,waist="Obstin. Sash",legs="Atro. Tights +4",feet="Viti. Boots +4"}

	-- With Dual Wield, Maxentius in the off hand (Macc 40, INT and MND 15). Gleti's Knife has the same Macc 40 at rank 1
	-- and no INT or MND (Vanar_gear_notes.md, Gleti's Knife).
	sets.midcast['Enfeebling Magic'].DW = {main="Bunzi's Rod",sub="Maxentius"}

	-- Sleep, Bind and Break have no potency: magic accuracy and duration, all five Lethargy pieces, INT cape.
	sets.midcast.Sleep = {main="Bunzi's Rod",sub="Ammurapi Shield",range="Ullr",ammo=empty,
		head="Leth. Chappel +3",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.int_enfeebling_jse_back,waist="Obstin. Sash",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	sets.midcast.Bind = sets.midcast.Sleep
	sets.midcast.Break = sets.midcast.Sleep
	-- Dia III and Inundation: duration only, and only magic immunity resists them.
	sets.midcast['Dia III'] = sets.midcast.Sleep
	-- Bio III is dark magic: neither the Lethargy bonus nor the enfeebling duration pieces lengthen it (Vanar's
	-- rahvin RDM.lua took it off the enfeebling duration tier for this), so it takes the dark magic set below.
	sets.midcast.Inundation = sets.midcast.Sleep

	-- Treasure Hunter 4, the cap off THF: Wh. Rarab Cap +1 (1), Volte Jupon (2) and Chaac Belt (1). It replaces the
	-- Volte Cap and Volte Bracers that Vanar-Items.lua names, which Vanar doesn't own.
	sets.TreasureHunter = {head="Wh. Rarab Cap +1",body="Volte Jupon",waist="Chaac Belt"}
	sets.midcast.Dia = set_combine(sets.midcast.Sleep, sets.TreasureHunter)
	sets.midcast.Diaga = set_combine(sets.midcast.Sleep, sets.TreasureHunter)

	sets.midcast.Sleep.Resistant = {main="Bunzi's Rod",sub="Ammurapi Shield",range="Ullr",ammo=empty,
		head="Viti. Chapeau +4",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Atrophy Tabard +4",hands="Leth. Ganth. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.int_enfeebling_jse_back,waist="Obstin. Sash",legs="Atro. Tights +4",feet="Viti. Boots +4"}

	sets.midcast.Bind.Resistant = sets.midcast.Sleep.Resistant
	sets.midcast.Break.Resistant = sets.midcast.Sleep.Resistant

	sets.midcast.Sleep.DW = {main="Bunzi's Rod",sub="Maxentius"}
	sets.midcast.Bind.DW = sets.midcast.Sleep.DW
	sets.midcast.Break.DW = sets.midcast.Sleep.DW

	-- Dispel: magic accuracy only (+175 of its own), INT cape. Dls. Torque +1's "Dispel"+1 removes a second effect.
	sets.midcast.Dispel = set_combine(sets.midcast.Sleep.Resistant, {})

	sets.midcast.Dispel.DW = {main="Bunzi's Rod",sub="Maxentius"}
	-- Dispelga needs Daybreak in the main hand, which Vanar doesn't own.
	sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, {})
	sets.midcast.Dispelga.DW = {main="Bunzi's Rod",sub="Maxentius"}

	-- Frazzle and Distract: skill potency to 625 and 610 skill, with dMND, then effect+. This set has 586 skill, so
	-- Frazzle III's skill part is 108 of 120 (Vanar_notes.md, Enfeebling skill). MND cape.
	sets.midcast.Frazzle = set_combine(sets.midcast['Enfeebling Magic'], {})

	sets.midcast.Distract = sets.midcast.Frazzle

	sets.midcast.Frazzle.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

	sets.midcast.Distract.Resistant = sets.midcast.Frazzle.Resistant

	sets.midcast['Frazzle II'] = sets.midcast.Frazzle.Resistant
	sets.midcast.Frazzle.DW = {main="Bunzi's Rod",sub="Maxentius"}
	sets.midcast.Distract.DW = sets.midcast.Frazzle.DW

	-- Addle, Paralyze and Slow: MND to the spell's dMND cap, then effect+.
	sets.midcast.Addle = set_combine(sets.midcast['Enfeebling Magic'], {})

	sets.midcast.Paralyze = sets.midcast.Addle
	sets.midcast.Slow = sets.midcast.Addle

	sets.midcast.Addle.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

	sets.midcast.Paralyze.Resistant = sets.midcast.Addle.Resistant
	sets.midcast.Slow.Resistant = sets.midcast.Addle.Resistant

	sets.midcast.Addle.DW = {main="Bunzi's Rod",sub="Maxentius"}
	sets.midcast.Paralyze.DW = sets.midcast.Addle.DW
	sets.midcast.Slow.DW = sets.midcast.Addle.DW

	-- Gravity, Poison and Blind are black magic: the potency set with the INT cape, for INT's magic accuracy and
	-- Blind's dINT potency.
	sets.midcast.Gravity = set_combine(sets.midcast['Enfeebling Magic'], {back=gear.int_enfeebling_jse_back})

	sets.midcast.Gravity.Resistant = set_combine(sets.midcast.Sleep.Resistant, {})

	sets.midcast.Gravity.DW = {main="Bunzi's Rod",sub="Maxentius"}

	sets.midcast.Poison = sets.midcast.Gravity
	sets.midcast.Poison.Resistant = sets.midcast.Gravity.Resistant
	sets.midcast.Poison.DW = sets.midcast.Gravity.DW

	sets.midcast.Blind = sets.midcast.Gravity
	sets.midcast.Blind.Resistant = sets.midcast.Gravity.Resistant
	sets.midcast.Blind.DW = sets.midcast.Gravity.DW

	-- Silence (white magic, no potency): duration and magic accuracy, all five Lethargy pieces, MND cape.
	sets.midcast.Silence = set_combine(sets.midcast.Sleep, {back=gear.mnd_enfeebling_jse_back})

	sets.midcast.Silence.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

	sets.midcast.Silence.DW = {main="Bunzi's Rod",sub="Maxentius"}

	-- Elemental nukes: MAB, Magic Damage and magic accuracy. The player keeps Sanctity Necklace and Eschan Stone on nuke
	-- sets (Vanar_notes.md, Rules), and Snotra Earring and the Stikini Rings over Friomisi and Jhakri while no magic
	-- accuracy margin for nukes is recorded (Vanar_gear_notes.md, Friomisi Earring). Low-tier nukes take this set
	-- (RDM.lua's LowTierNuke) and the higher tiers .HighTierNuke below. With the weapons free, Bunzi's Rod and
	-- Ammurapi Shield (MAB 38, over Maxentius's 21).
	sets.midcast['Elemental Magic'] = {main="Bunzi's Rod",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
		head="Leth. Chappel +3",neck="Sanctity Necklace",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.nuke_jse_back,waist="Eschan Stone",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	-- In a defense mode: the Lethargy head, body and hands already give DT 35, so Alabaster Earring, Murky Ring and
	-- Ayanmo Ring reach the cap, about 53, for Macc 21 and Snotra's Macc 10.
	sets.midcast['Elemental Magic'].DT = set_combine(sets.midcast['Elemental Magic'], {ear1="Alabaster Earring",ring1="Murky Ring",ring2="Ayanmo Ring"})

	-- More magic accuracy for resistant targets: Dls. Torque +1 (Macc 25, INT 12) for Sanctity Necklace, Obstin. Sash
	-- (Macc 15) for Eschan Stone, and Ullr with the weapons free.
	sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {range="Ullr",ammo=empty,neck="Dls. Torque +1",waist="Obstin. Sash"})

	-- Proc mode: the spell has to land but not kill, so magic accuracy with no MAB and fast recast: Gleti's Knife and
	-- Forfend +1 (no MAB, Macc 40 and 31), three Atrophy pieces, Viti. Tabard +4 (Fast Cast 15) and Vanya Clogs.
	sets.midcast['Elemental Magic'].Proc = {main="Gleti's Knife",sub="Forfend +1",range=empty,ammo="Hasty Pinion",
		head="Atro. Chapeau +4",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Viti. Tabard +4",hands="Atro. Gloves +4",ring1="Stikini Ring",ring2="Prolix Ring",
		back=gear.mnd_enfeebling_jse_back,waist="Obstin. Sash",legs="Atro. Tights +4",feet="Vanya Clogs"}

	-- Tier III to V nukes: the same set. Sibyl Scarf's INT would help more there, but the player keeps Sanctity.
	sets.midcast['Elemental Magic'].HighTierNuke = set_combine(sets.midcast['Elemental Magic'], {})

	sets.midcast['Elemental Magic'].HighTierNuke.Resistant = set_combine(sets.midcast['Elemental Magic'].Resistant, {})

	-- Gear that recovers MP when nuking: Vanar has no Seidr Cotehardie.
	sets.RecoverMP = {}

	-- Magic burst, over the nuke set: Ea Houppelande (8, and Magic burst damage II 8 past the cap), Mizu. Kubikazari
	-- (10) and Jhakri Ring (2), with Leth. Fuseau +3's 15: magic burst damage 35 of the 40 cap with the weapons locked,
	-- and 45 (capped at 40) with Bunzi's Rod's 10.
	sets.MagicBurst = {main="Bunzi's Rod",sub="Ammurapi Shield",body="Ea Houppelande",neck="Mizu. Kubikazari",ring1="Jhakri Ring"}
	-- With Dual Wield, Ammurapi Shield still beats Maxentius for nukes.
	sets.midcast['Elemental Magic'].DW = {main="Bunzi's Rod",sub="Ammurapi Shield"}

	-- Impact needs Twilight Cloak (Mog Case), which the engine puts on with the head emptied. Magic accuracy with two
	-- Atrophy pieces (Acc and Macc 15).
	sets.midcast.Impact = {main="Bunzi's Rod",sub="Ammurapi Shield",range=empty,ammo="Pemphredo Tathlum",
		head=empty,neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		hands="Atro. Gloves +4",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.int_enfeebling_jse_back,waist="Obstin. Sash",legs="Atro. Tights +4",feet="Leth. Houseaux +3"}

	-- Dark magic: magic accuracy from dark skill and INT. Four Atrophy pieces (Acc and Macc 45), Leth. Houseaux +3
	-- (Macc 60, over Viti. Boots +4's 48, whose enfeebling skill does nothing here), Obstin. Sash (Macc 15 over Eschan
	-- Stone's 7) and the INT cape.
	sets.midcast['Dark Magic'] = {main="Bunzi's Rod",sub="Ammurapi Shield",range=empty,ammo="Pemphredo Tathlum",
		head="Atro. Chapeau +4",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Atrophy Tabard +4",hands="Atro. Gloves +4",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.int_enfeebling_jse_back,waist="Obstin. Sash",legs="Atro. Tights +4",feet="Leth. Houseaux +3"}

	sets.midcast['Bio III'] = sets.midcast['Dark Magic']
	sets.midcast.Bio = set_combine(sets.midcast['Dark Magic'], sets.TreasureHunter)

	-- Drain and Aspir from a subjob: the dark set with Fucho-no-Obi ("Drain" and "Aspir" potency +8%).
	sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {waist="Fucho-no-Obi"})

	sets.midcast.Aspir = sets.midcast.Drain

	-- Absorb-TP and Stun: the dark set with Ullr, and the MND cape (Haste 10, the same Macc 30) for their recast.
	sets.midcast['Absorb-TP'] = set_combine(sets.midcast['Dark Magic'], {range="Ullr",ammo=empty,back=gear.mnd_enfeebling_jse_back})

	sets.midcast['Absorb-TP'].Resistant = set_combine(sets.midcast['Dark Magic'], {range="Ullr",ammo=empty})

	sets.midcast.Stun = set_combine(sets.midcast['Absorb-TP'], {})

	sets.midcast.Stun.Resistant = set_combine(sets.midcast['Absorb-TP'].Resistant, {})

	sets.midcast.Stun.DW = {main="Bunzi's Rod",sub="Maxentius"}

	-- Sets for special buff conditions on spells.

	sets.buff.Saboteur = {hands="Leth. Ganth. +3"}	-- Saboteur +14

	-- Cure cheat (gs c curecheat): the lowest maximum HP Vanar's wardrobes allow, HP 97 from gear, keeping MP.
	sets.HPDown = {ammo="Pemphredo Tathlum",
		head="Wh. Rarab Cap +1",neck="Sibyl Scarf",ear1="Loquac. Earring",ear2="Andoaa Earring",
		body="Telchine Chas.",hands="Jhakri Cuffs +2",ring1="Murky Ring",ring2="Prolix Ring",
		back="Fi Follet Cape +1",waist="Fucho-no-Obi",legs="Doyen Pants",feet="Chelona Boots"}

	-- ...then the most HP with Cure potency to the cap: Bunzi's Rod (30, with the weapons free), Telchine Gloves (10),
	-- Atro. Tights +4 (12) and Solemnity Cape (7), Nyame elsewhere. HP 658 from gear.
	sets.HPCure = {main="Bunzi's Rod",sub="Ammurapi Shield",
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Nyame Mail",hands=gear.telchine_duration_hands,ring1="Naji's Loop",ring2="Murky Ring",
		back="Solemnity Cape",waist="Eschan Stone",legs="Atro. Tights +4",feet="Nyame Sollerets"}

	-- No Doom gear in the wardrobes. Vanar-Items.lua's Gishdubar Sash isn't Vanar's.
	sets.buff.Doom = {}

	-- Sets to return to when not performing an action.

	-- Resting sets: the idle set, with Chelona Boots (MP recovered while healing +5) and Fucho-no-Obi, whose latent
	-- Refresh works below about half MP.
	sets.resting = {main=gear.colada_refresh,sub="Archduke's Shield",range=empty,
		head="Viti. Chapeau +4",neck="Sibyl Scarf",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Fucho-no-Obi",legs="Leth. Fuseau +3",feet="Chelona Boots"}

	-- Ballista: the PDT idle set, with Carmine Cuisses +1 for 18% movement speed.
	sets.Ballista = {main=gear.colada_refresh,sub="Forfend +1",range=empty,
		head="Leth. Chappel +3",neck="Sibyl Scarf",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Flume Belt",legs="Carmine Cuisses +1",feet="Viti. Boots +4"}

	-- Idle sets. Passive Refresh first, the player's rule for idle: Viti. Chapeau +4 (3), Lethargy Sayon +3 (4), Sibyl
	-- Scarf (1 for a citizen of Windurst), and with the weapons free Colada (2) and Archduke's Shield (1): Refresh 8, or
	-- 11. No other slot has Refresh for RDM, so they carry damage taken (DT 48, PDT 4, MDT 3: about 50 each way) and
	-- magic evasion.
	sets.idle = {main=gear.colada_refresh,sub="Archduke's Shield",range=empty,
		head="Viti. Chapeau +4",neck="Sibyl Scarf",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Flume Belt",legs="Leth. Fuseau +3",feet="Viti. Boots +4"}

	-- Physical: Leth. Chappel +3 (DT 10) for the Viti. Chapeau's Refresh, so DT is clear of the cap (58), and Forfend
	-- +1 (PDT 4, and it blocks, which cuts damage past the cap) with the weapons free.
	sets.idle.PDT = set_combine(sets.idle, {sub="Forfend +1",head="Leth. Chappel +3"})

	-- Magic: the five Lethargy pieces (Magic Def. Bonus 48 between them) with DT 58 and MDT 3, and Archduke's Shield
	-- (Magic Evasion 20).
	sets.idle.MDT = set_combine(sets.idle, {head="Leth. Chappel +3",feet="Leth. Houseaux +3"})

	-- Magic evasion with damage taken capped: Nyame Mail and Gauntlets (Magic Evasion 139 and 112, DT 9 and 7), Leth.
	-- Fuseau +3 (162) and Viti. Boots +4 (167). Magic evasion 705 from armor, DT 49 with MDT 3.
	sets.idle.MEVA = set_combine(sets.idle, {head="Leth. Chappel +3",body="Nyame Mail",hands="Nyame Gauntlets"})

	-- Aminon: no Null Masque, so the magic evasion set.
	sets.idle.Aminon = set_combine(sets.idle.MEVA, {})

	-- Defense sets
	sets.defense.PDT = set_combine(sets.idle.PDT, {})

	sets.defense.NukeLock = sets.midcast['Elemental Magic']

	sets.defense.MDT = set_combine(sets.idle.MDT, {})

	sets.defense.MEVA = set_combine(sets.idle.MEVA, {})

	sets.Kiting = {legs="Carmine Cuisses +1"}	-- Movement speed 18%
	sets.latent_refresh = {waist="Fucho-no-Obi"}
	-- No staff or grip in the wardrobes.
	sets.latent_refresh_grip = {}
	sets.DayIdle = {}
	sets.NightIdle = {}

	sets.buff.Sublimation = {waist="Embla Sash"}	-- Sublimation +3
	sets.buff.DTSublimation = {waist="Embla Sash"}

	-- Engaged sets

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.Dagger.Accuracy.Evasion

	-- Normal melee group. Gear haste is past the 26% cap in every engaged set, so nothing here is picked for haste.

	-- Damage first, as long as main-hand accuracy reaches 1350 from gear, food and Composure's +70, which is always up
	-- when RDM melees (the player's rules). Vanar's rahvin TP set: the Lethargy +3 armor (Acc and Att 60 to 64), Sailfi
	-- Belt +1 (TA 2, DA 5 and STR 14 at rank 14), Asperity Necklace (DA 2, Store TP 3), Brutal Earring, Leth. Earring +1
	-- (Acc 15, DA 5), Lehko's Ring (Store TP 10, Crit 10) and the Double Attack cape. With Naegling it is about 1346 with
	-- Oden, 1416 with Composure, past the 95% hit rate. Maxentius is about 70 lower, about 1347 with Composure, 3 under
	-- the floor (Vanar_notes.md, Accuracy); Sanctity Necklace for the Asperity would clear it, at the Naegling sets'
	-- cost.
	sets.engaged = {ammo="Coiste Bodhar",
		head="Leth. Chappel +3",neck="Asperity Necklace",ear1="Brutal Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Lehko's Ring",ring2="Rajas Ring",
		back=gear.da_jse_back,waist="Sailfi Belt +1",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	-- Accuracy first (the player's rule for ACC mode): every slot takes the most accurate piece, and four Atrophy +4
	-- pieces add Acc 45. Jhakri Ring and Ayanmo Ring tie at Acc 6; Jhakri adds Att 6.
	sets.engaged.Acc = {ammo="Coiste Bodhar",
		head="Atro. Chapeau +4",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Atrophy Tabard +4",hands="Atro. Gloves +4",ring1="Lehko's Ring",ring2="Jhakri Ring",
		back=gear.da_jse_back,waist="Eschan Stone",legs="Atro. Tights +4",feet="Leth. Houseaux +3"}

	-- Damage taken to the cap first. The Lethargy head, body and hands give DT 35; Murky Ring (10), the cape (5) and
	-- Alabaster Earring (5) take it to about 54, so it stays capped whichever way the 1/256 steps round. The rest is the
	-- TP set's: with Composure, Sanctity Necklace and Kentarch Belt +1's 24 more accuracy would go past the hit rate cap.
	sets.engaged.DT = {ammo="Coiste Bodhar",
		head="Leth. Chappel +3",neck="Asperity Necklace",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Lehko's Ring",ring2="Murky Ring",
		back=gear.da_jse_back,waist="Sailfi Belt +1",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	-- Accuracy with damage taken capped: no Atrophy piece has DT, so the Lethargy head, body and hands come back for
	-- DT 35, with Murky Ring, Alabaster Earring and the cape: DT 55. On their own Atro. Tights +4 give no set bonus, so
	-- Leth. Fuseau +3 (Acc 63, Att 63) takes the legs over them (Acc 59). That costs about 56 of the ACC set's accuracy,
	-- counting DEX.
	sets.engaged.Acc.DT = {ammo="Coiste Bodhar",
		head="Leth. Chappel +3",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Lehko's Ring",ring2="Murky Ring",
		back=gear.da_jse_back,waist="Eschan Stone",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	-- Dual Wield. Vanar has no Dual Wield cape, so these are the sets above. Carmine Cuisses +1's Dual Wield 6 would
	-- trade Leth. Fuseau +3's Acc 63 for 55, and the TP set, at about 1352 with Grape Daifuku, has no room for that
	-- under the 1350 floor.
	sets.engaged.DW = set_combine(sets.engaged, {})

	sets.engaged.DW.Acc = set_combine(sets.engaged.Acc, {})

	sets.engaged.DW.DT = set_combine(sets.engaged.DT, {})

	sets.engaged.DW.Acc.DT = set_combine(sets.engaged.Acc.DT, {})

	-- Enspell melee. The player leaves out Enspell damage gear worn while meleeing (Vanar_notes.md, Rules), so these
	-- are the TP and accuracy sets: an Enspell's damage then comes from the skill worn at the cast.
	sets.engaged.EnspellOnly = set_combine(sets.engaged, {})

	sets.engaged.EnspellOnly.Acc = set_combine(sets.engaged.Acc, {})

	sets.engaged.DualEnspellOnly = set_combine(sets.engaged, {})

	sets.engaged.DualEnspellOnly.Acc = set_combine(sets.engaged.Acc, {})
end

-- Select default macro book on initial load or subjob change.
-- Default macro set/book
function select_default_macro_book()
	if player.sub_job == 'SCH' then
		set_macro_page(1, 2)
	elseif player.sub_job == 'DNC' then
		set_macro_page(4, 2)
	elseif player.sub_job == 'NIN' then
		set_macro_page(5, 2)
	elseif player.sub_job == 'BLM' then
		set_macro_page(2, 2)
	elseif player.sub_job == 'DRK' then
		set_macro_page(6, 2)
	else
		set_macro_page(3, 2)
	end
end

function user_job_buff_change(buff, gain)
	if buff:startswith('Addendum: ') or buff:endswith(' Arts') then
		style_lock = true
	end
end

function user_job_lockstyle()
	if player.sub_job == 'SCH' then
		if state.Buff['Light Arts'] or state.Buff['Addendum: White'] then
			windower.chat.input('/lockstyleset 001')
		elseif state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
			windower.chat.input('/lockstyleset 002')
		else
			windower.chat.input('/lockstyleset 004')
		end
	elseif player.sub_job == 'NIN' or player.sub_job == 'DNC' then
		windower.chat.input('/lockstyleset 020')
	end
end

--From the rahvin branch: with Ullr in range, the ammo a weaponskill, Waltz or Step set names would strip the
--bow and reset TP before the action fires, so the ammo slot stays bare.
function user_job_post_precast(spell, spellMap, eventArgs)
	if player.equipment.range == 'Ullr' and spell.action_type ~= 'Ranged Attack' then
		equip({ammo=empty})
	end
end

--With the weapons locked, the weapon set's empty range slot wins over a midcast set's Ullr, and that set leaves the
--ammo slot empty for the bow. RDM.lua's job_post_midcast fills it with Regal Gem then, which Vanar doesn't own, so
--this puts Pemphredo Tathlum there (Macc 8, MAB 4) under the same conditions.
function user_job_post_midcast(spell, spellMap, eventArgs)
	if spell.action_type ~= 'Magic' or state.UnlockWeapons.value or state.Weapons.value == 'None' or not sets.weapons[state.Weapons.value] then return end
	if not (spell.skill == 'Enfeebling Magic' or spell.skill == 'Dark Magic' or (spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble' and spell.english ~= 'Impact')) then return end
	local currentSet = standardize_set(get_midcast_set(spell, spellMap))
	local currentWeapons = standardize_set(sets.weapons[state.Weapons.value])
	if currentSet.range == "Ullr" and currentWeapons.range == 'empty' and not currentWeapons.ammo and not item_equippable("Regal Gem") then
		equip({ammo="Pemphredo Tathlum"})
	end
end

buff_spell_lists = {
	Auto = {--Options for When are: Always, Engaged, Idle, OutOfCombat, Combat
		{Name='Refresh III',	Buff='Refresh',		SpellID=894,	When='Always'},
		{Name='Haste II',		Buff='Haste',		SpellID=511,	When='Always'},
		{Name='Aurorastorm',	Buff='Aurorastorm',	SpellID=119,	When='Idle'},
		{Name='Reraise',		Buff='Reraise',		SpellID=135,	When='Always'},
	},
	
	AutoMelee = {
		{Name='Phalanx II',		Buff='Phalanx',			SpellID=107,	When='Combat'},
		{Name='Haste II',		Buff='Haste',			SpellID=511,	When='Combat'},
		{Name='Temper II',		Buff='Multi Strikes',	SpellID=895,	When='Combat'},
		--{Name='Refresh III',	Buff='Refresh',			SpellID=894,	When='Always'},
		{Name='Gain-STR',		Buff='STR Boost',		SpellID=486,	When='Combat'},
	},
	
	AutoMage = {
		{Name='Phalanx II',		Buff='Phalanx',			SpellID=107,	When='Always'},
		{Name='Haste II',		Buff='Haste',			SpellID=511,	When='Always'},
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	When='Always'},
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	When='Always'},
		{Name='Gain-INT',		Buff='INT Boost',		SpellID=490,	When='Always'},
		{Name='Aquaveil',		Buff='Aquaveil',		SpellID=55,		When='Always'},
		{Name='Blink',			Buff='Blink',			SpellID=53,		When='Always'},
		{Name='Shell V',		Buff='Shell',			SpellID=52,		When='Always'},
		{Name='Protect V',		Buff='Protect',			SpellID=47,		When='Always'},
		{Name='Stoneskin',		Buff='Stoneskin',		SpellID=54,		When='Always'},
	},
	
	Default = {
		{Name='Haste II',		Buff='Haste',			SpellID=511,	Reapply=false},
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	Reapply=false},
		{Name='Gain-MND',		Buff='MND Boost',		SpellID=491,	Reapply=false},
		{Name='Aquaveil',		Buff='Aquaveil',		SpellID=55,		Reapply=false},
		{Name='Phalanx II',		Buff='Phalanx',			SpellID=107,	Reapply=false},
		{Name='Stoneskin',		Buff='Stoneskin',		SpellID=54,		Reapply=false},
		{Name='Blink',			Buff='Blink',			SpellID=53,		Reapply=false},
		{Name='Shell V',		Buff='Shell',			SpellID=52,		Reapply=false},
		{Name='Protect V',		Buff='Protect',			SpellID=47,		Reapply=false},
	},

	MageBuff = {
		{Name='Haste II',		Buff='Haste',			SpellID=511,	Reapply=false},
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	Reapply=false},
		{Name='Gain-INT',		Buff='INT Boost',		SpellID=490,	Reapply=false},
		{Name='Aquaveil',		Buff='Aquaveil',		SpellID=55,		Reapply=false},
		{Name='Phalanx II',		Buff='Phalanx',			SpellID=107,	Reapply=false},
		{Name='Stoneskin',		Buff='Stoneskin',		SpellID=54,		Reapply=false},
		{Name='Blink',			Buff='Blink',			SpellID=53,		Reapply=false},
		{Name='Shell V',		Buff='Shell',			SpellID=52,		Reapply=false},
		{Name='Protect V',		Buff='Protect',			SpellID=47,		Reapply=false},
	},
	
	FullMeleeBuff = {
		{Name='Haste II',		Buff='Haste',			SpellID=511,	Reapply=false},
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	Reapply=false},
		{Name='Phalanx II',		Buff='Phalanx',			SpellID=107,	Reapply=false},
		{Name='Temper II',		Buff='Multi Strikes',	SpellID=895,	Reapply=false},
		{Name='Gain-STR',		Buff='STR Boost',		SpellID=486,	Reapply=false},
		--{Name='Enthunder',		Buff='Enthunder',		SpellID=104,	Reapply=false},
		--{Name='Shock Spikes',	Buff='Shock Spikes',	SpellID=251,	Reapply=false},
		{Name='Shell V',		Buff='Shell',			SpellID=52,		Reapply=false},
		{Name='Protect V',		Buff='Protect',			SpellID=47,		Reapply=false},
		--{Name='Barblizzard',	Buff='Barblizzard',		SpellID=61,		Reapply=false},
		--{Name='Barparalyze',	Buff='Barparalyze',		SpellID=74,		Reapply=false},
		{Name='Aquaveil',		Buff='Aquaveil',		SpellID=55,		Reapply=false},		
		{Name='Regen II',		Buff='Regen',			SpellID=110,	Reapply=false},
		{Name='Stoneskin',		Buff='Stoneskin',		SpellID=54,		Reapply=false},
		{Name='Blink',			Buff='Blink',			SpellID=53,		Reapply=false},
	},
	
	MeleeBuff = {
		{Name='Haste II',		Buff='Haste',			SpellID=511,	Reapply=false},
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	Reapply=false},
		{Name='Phalanx II',		Buff='Phalanx',			SpellID=107,	Reapply=false},
		{Name='Temper II',		Buff='Multi Strikes',	SpellID=895,	Reapply=false},
		{Name='Gain-STR',		Buff='STR Boost',		SpellID=486,	Reapply=false},
		{Name='Enthunder',		Buff='Enthunder',		SpellID=104,	Reapply=false},
		{Name='Shock Spikes',	Buff='Shock Spikes',	SpellID=251,	Reapply=false},
	},

	Odin = {
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	Reapply=false},
		{Name='Haste II',		Buff='Haste',			SpellID=511,	Reapply=false},
		{Name='Phalanx II',		Buff='Phalanx',			SpellID=107,	Reapply=false},
		{Name='Gain-INT',		Buff='INT Boost',		SpellID=490,	Reapply=false},
		{Name='Temper II',		Buff='Multi Strikes',	SpellID=895,	Reapply=false},
		{Name='Regen II',		Buff='Regen',			SpellID=110,	Reapply=false},
		{Name='Enaero',			Buff='Enaero',			SpellID=102,	Reapply=false},
		{Name='Stoneskin',		Buff='Stoneskin',		SpellID=54,		Reapply=false},
		{Name='Shell V',		Buff='Shell',			SpellID=52,		Reapply=false},
		{Name='Protect V',		Buff='Protect',			SpellID=47,		Reapply=false},
	},
	
	HybridCleave = {
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	Reapply=false},
		{Name='Haste II',		Buff='Haste',			SpellID=511,	Reapply=false},
		{Name='Phalanx II',		Buff='Phalanx',			SpellID=107,	Reapply=false},
		{Name='Gain-INT',		Buff='INT Boost',		SpellID=490,	Reapply=false},
		{Name='Enthunder II',	Buff='Enthunder II',	SpellID=316,	Reapply=false},
		{Name='Temper II',		Buff='Multi Strikes',	SpellID=895,	Reapply=false},
		{Name='Shell V',		Buff='Shell',			SpellID=52,		Reapply=false},
		{Name='Protect V',		Buff='Protect',			SpellID=47,		Reapply=false},
	},
}