function character_user_job_setup()
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
	state.Weapons:options('Naegling','Maxentius','Crocea','Tauret','EnspellOnly','Savage Blade','Savage Blade Acc','Black Halo','DualCrocea','Black Halo Max Acc','DualPrime','DualAeolian','DualEnspellOnly','DualProcSword')
	--Start with the weapons unlocked, so idle and casting sets can change main and sub out of combat. While engaged they stay put.
	state.UnlockWeapons:set(true)

	ws_buff_list = S{'Savage Blade','Evisceration','Chant du Cygne','Vorpal Blade','Black Halo','Requiescat','Realmrazer'}

	--Spells, job abilities and weaponskills that wear sets.TreasureHunter against an untagged monster, plus any ranged attack (User-Globals.lua).
	--In Tag mode nothing else wears it, melee included, and an action off the list doesn't count as tagging. Delete the line to let every action tag.
	TH_Whitelist = S{'Dia','Dia II','Dia III','Stonega'}
	state.WeaponSets:options('Default','Dual','Proc','Dynamis')

	weapon_sets = {
		['Default'] = {'Naegling','Maxentius','Crocea','Tauret','EnspellOnly'},
		['Dual'] = {'Savage Blade','Savage Blade Acc','Black Halo','DualCrocea','Black Halo Max Acc','DualPrime','DualAeolian','DualEnspellOnly'},
		['Dynamis'] = {'DualCroceaSavageBlade','DualCrocea','DualTauretCrocea','DualAeolian'},
		['Proc'] = {'ProcSword','ProcDagger','DualProcSword','DualProcDagger'},
	}

	default_weapons = 'Naegling'
	default_dual_weapons = 'Savage Blade'

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
	
	gear.mnd_enfeebling_jse_back = {name="Sucellos's Cape",augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','Haste+10',}}
	gear.int_enfeebling_jse_back = {name="Sucellos's Cape",augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10',}}
	gear.nuke_jse_back = gear.int_enfeebling_jse_back
	gear.str_wsd_jse_back = {name="Sucellos's Cape",augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%',}}
	gear.da_jse_back = {name="Sucellos's Cape",augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%',}}
	gear.colada_refresh = {name="Colada",augments={'"Refresh"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12','DMG:+1',}}
	gear.telchine_regen_hands = {name="Telchine Gloves",augments={'"Regen" potency+3',}}
	gear.telchine_duration_hands = {name="Telchine Gloves",augments={'Haste+3','Enh. Mag. eff. dur. +10',}}
	
	send_command('bind @` gs c cycle ElementalMode')
	send_command('bind ^` gs c scholar dark')
	send_command('bind !` gs c scholar light')
	send_command('bind !backspace input /ja "Composure" <me>')
	send_command('bind ^backspace input /ja "Saboteur" <me>')
	send_command('bind @backspace input /ja "Spontaneity" <t>')
	send_command('bind ^\\\\ input /ma "Protect V" <t>')
	send_command('bind @\\\\ input /ma "Shell V" <t>')
	send_command('bind !\\\\ input /ma "Reraise III" <me>')
	send_command('bind @f10 gs c cycle RecoverMode')
	
	select_default_macro_book()
end

function init_gear_sets()
	sets.weapons.Naegling = {main="Naegling",sub="Ammurapi Shield",range=empty}
	sets.weapons.Crocea = {main="Naegling",sub="Ammurapi Shield",range=empty}
	sets.weapons.Maxentius = {main="Maxentius",sub="Ammurapi Shield",range=empty}
	sets.weapons.Tauret = {main="Tauret",sub="Ammurapi Shield",range=empty}
	sets.weapons['Savage Blade'] = {main="Naegling",sub="Thibron",range=empty}
	sets.weapons['Savage Blade Acc'] = {main="Naegling",sub="Gleti's Knife",range=empty}
	sets.weapons.DualPrime = {main="Tauret",sub="Gleti's Knife",range=empty}
	sets.weapons.DualEvisceration = {}
	sets.weapons.DualCrocea = {main="Naegling",sub="Bunzi's Rod",range=empty}
	sets.weapons.DualAeolian = {main="Tauret",sub="Bunzi's Rod",range=empty}
	sets.weapons.DualProcSword = {main="Pukulatmuj +1",sub="Gleti's Knife",range=empty}
	sets.weapons.ProcSword = {main="Pukulatmuj +1",sub="Ammurapi Shield",range=empty}
	sets.weapons.ProcDagger = {main="Gleti's Knife",sub="Ammurapi Shield",range=empty}
	sets.weapons.DualProcDagger = {main="Gleti's Knife",sub="Pukulatmuj +1",range=empty}
	sets.weapons.EnspellOnly = {main="Tauret",sub="Ammurapi Shield",range=empty}
	sets.weapons.DualEnspellOnly = {main="Tauret",sub="Gleti's Knife",range=empty}
	sets.weapons.DualBow = {}
	sets.weapons.BowMacc = {}
	sets.weapons['Black Halo'] = {main="Maxentius",sub="Thibron",range=empty}
	sets.weapons['Black Halo Max Acc'] = {main="Maxentius",sub="Gleti's Knife",range=empty}

	sets.weapons.DualCroceaSavageBlade = {main="Naegling",sub="Thibron",range=empty}
	sets.weapons.DualTauretCrocea = {main="Tauret",sub="Bunzi's Rod",range=empty}

	sets.precast.JA['Chainspell'] = {body="Viti. Tabard +4"}	-- Chainspell +20 s

	-- Atrophy set (4 pieces): Acc +45
	sets.precast.Step = {ammo="Coiste Bodhar",
		head="Atro. Chapeau +4",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Atrophy Tabard +4",hands="Atro. Gloves +4",ring1="Lehko's Ring",ring2="Jhakri Ring",
		back=gear.da_jse_back,waist="Eschan Stone",legs="Atro. Tights +4",feet="Leth. Houseaux +3"}

	sets.precast.JA['Violent Flourish'] = set_combine(sets.precast.Step, {ear1="Snotra Earring",ring1="Ayanmo Ring"})

	sets.precast.Waltz = {}

	sets.precast.Waltz['Healing Waltz'] = {}

	-- FC 44 (82% with the trait, cap 80), DT 49
	sets.precast.FC = {
		head="Atro. Chapeau +4",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Viti. Tabard +4",hands="Leth. Ganth. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Embla Sash",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	sets.precast.FC.DT = set_combine(sets.precast.FC, {})

	-- FC 67 with Colada, 63 without, the Jhakri set's 3 included
	sets.precast.FullFC = {main=gear.colada_refresh,
		head="Atro. Chapeau +4",ear1="Loquac. Earring",ear2="Leth. Earring +1",
		body="Viti. Tabard +4",hands="Jhakri Cuffs +2",ring1="Jhakri Ring",ring2="Prolix Ring",
		back="Fi Follet Cape +1",waist="Embla Sash",feet="Chelona Boots"}

	-- FC 36 with Colada, 32 without, once Twilight Cloak takes the head and body
	sets.precast.FC.Impact = set_combine(sets.precast.FullFC, {head=empty})
	sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {})

	-- WSD 57; Fotia Gorget fTP +25/256 a hit
	sets.precast.WS = {range=empty,ammo="Coiste Bodhar",
		head="Viti. Chapeau +4",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Atro. Gloves +4",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
		back=gear.str_wsd_jse_back,waist="Eschan Stone",legs="Nyame Flanchard",feet="Leth. Houseaux +3"}

	sets.precast.WS.Acc = set_combine(sets.precast.Step, {neck="Fotia Gorget"})

	sets.precast.WS.Proc = set_combine(sets.precast.Step, {})

	-- WSD 33, DA 21; Fotia Gorget and Fotia Belt fTP +25/256 a hit each
	sets.precast.WS['Requiescat'] = {range=empty,ammo="Coiste Bodhar",
		head="Viti. Chapeau +4",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Karieyh Ring",ring2="Jhakri Ring",
		back=gear.da_jse_back,waist="Fotia Belt",legs="Nyame Flanchard",feet="Leth. Houseaux +3"}
	sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS.Acc, {})

	-- Crit 10, DA 23; Fotia Gorget and Fotia Belt fTP +25/256 a hit each
	sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS['Requiescat'], {hands="Nyame Gauntlets",ring1="Lehko's Ring",ring2="Rajas Ring"})
	sets.precast.WS['Chant du Cygne'].Acc = set_combine(sets.precast.WS.Acc, {})

	sets.precast.WS['Evisceration'] = sets.precast.WS['Chant du Cygne']

	-- WSD 67
	sets.precast.WS['Savage Blade'] = {range=empty,ammo="Coiste Bodhar",
		head="Viti. Chapeau +4",neck="Rep. Plat. Medal",ear1="Moonshade Earring",ear2="Leth. Earring +1",
		body="Nyame Mail",hands="Atro. Gloves +4",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
		back=gear.str_wsd_jse_back,waist="Eschan Stone",legs="Nyame Flanchard",feet="Leth. Houseaux +3"}
	sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS.Acc, {})

	-- WSD 48; Fotia Gorget fTP +25/256 on the first hit
	sets.precast.WS['Black Halo'] = {range=empty,ammo="Coiste Bodhar",
		head="Viti. Chapeau +4",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Atro. Gloves +4",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
		back=gear.str_wsd_jse_back,waist="Eschan Stone",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}
	sets.precast.WS['Black Halo'].Acc = set_combine(sets.precast.WS.Acc, {})

	-- WSD 47, MAB 265, Magic Damage 94
	sets.precast.WS['Sanguine Blade'] = {range=empty,ammo="Pemphredo Tathlum",
		head="Leth. Chappel +3",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Leth. Earring +1",
		body="Nyame Mail",hands="Jhakri Cuffs +2",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
		back=gear.str_wsd_jse_back,waist="Eschan Stone",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	-- Fotia Belt: fTP +25/256, and its Accuracy 10 counts as Macc
	sets.precast.WS['Seraph Blade'] = set_combine(sets.precast.WS['Sanguine Blade'], {ear1="Moonshade Earring",waist="Fotia Belt"})

	sets.precast.WS['Shining Strike'] = sets.precast.WS['Seraph Blade']
	sets.precast.WS['Flash Nova'] = set_combine(sets.precast.WS['Sanguine Blade'], {waist="Fotia Belt"})

	sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS['Seraph Blade'], {})

	sets.precast.WS['Red Lotus Blade'] = sets.precast.WS['Aeolian Edge']

	-- Atrophy set (4 pieces): Macc +45
	sets.precast.WS['Sanguine Blade'].Acc = {range=empty,ammo="Pemphredo Tathlum",
		head="Atro. Chapeau +4",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Atrophy Tabard +4",hands="Atro. Gloves +4",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.int_enfeebling_jse_back,waist="Obstin. Sash",legs="Atro. Tights +4",feet="Leth. Houseaux +3"}
	sets.precast.WS['Seraph Blade'].Acc = set_combine(sets.precast.WS['Sanguine Blade'].Acc, {})
	sets.precast.WS['Flash Nova'].Acc = set_combine(sets.precast.WS['Sanguine Blade'].Acc, {})
	sets.precast.WS['Aeolian Edge'].Acc = set_combine(sets.precast.WS['Sanguine Blade'].Acc, {})

	sets.MaxTP = {ear1="Brutal Earring"}	-- DA 5
	sets.AccMaxTP = {ear1="Alabaster Earring"}	-- Acc 2
	sets.MagicalMaxTP = {ear1="Friomisi Earring"}	-- MAB 10

	-- Haste 26 (cap 26), FC 44, DT 49
	sets.midcast.FastRecast = {ammo="Hasty Pinion",
		head="Atro. Chapeau +4",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Viti. Tabard +4",hands="Leth. Ganth. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Embla Sash",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	-- Cure 50 (cap 50), 80 with Bunzi's Rod
	sets.midcast.Cure = {main="Bunzi's Rod",sub="Ammurapi Shield",range=empty,
		head="Atro. Chapeau +4",neck="Nodens Gorget",ear1="Alabaster Earring",ear2="Mendi. Earring",
		body="Viti. Tabard +4",hands=gear.telchine_duration_hands,ring1="Murky Ring",ring2="Naji's Loop",
		back="Solemnity Cape",waist="Embla Sash",legs="Atro. Tights +4",feet="Vanya Clogs"}

	sets.midcast.LightWeatherCure = set_combine(sets.midcast.Cure, {})

	sets.midcast.LightDayCure = set_combine(sets.midcast.Cure, {})

	-- Cure 57 (cap 50), DT 58, PDT 8, MDT 3
	sets.midcast.Cure.DT = {main="Bunzi's Rod",sub="Forfend +1",range=empty,
		head="Leth. Chappel +3",neck="Nodens Gorget",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Flume Belt",legs="Atro. Tights +4",feet="Vanya Clogs"}

	-- Healing magic skill +62, Cursna +5
	sets.midcast.Cursna = set_combine(sets.midcast.FastRecast, {legs="Atro. Tights +4",feet="Vanya Clogs"})

	sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {})

	-- Enhancing skill 545, duration x3.25, Haste 26 (cap 26), FC 30 (34 with Colada)
	sets.midcast['Enhancing Magic'] = {main=gear.colada_refresh,sub="Ammurapi Shield",ammo="Hasty Pinion",
		head="Telchine Cap",neck="Dls. Torque +1",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Viti. Tabard +4",hands="Atro. Gloves +4",ring1="Murky Ring",ring2="Prolix Ring",
		back="Ghostfyre Cape",waist="Embla Sash",legs="Telchine Braconi",feet="Leth. Houseaux +3"}

	-- Lethargy set (4 pieces): duration +35% with Composure, x3.55 in all
	sets.buff.ComposureOther = {head="Leth. Chappel +3",
		body="Lethargy Sayon +3",
		legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	-- Enhancing skill 654: Temper II Triple Attack 35%
	sets.EnhancingSkill = {main="Pukulatmuj +1",sub="Forfend +1",
		neck="Enhancing Torque",ear1="Mimir Earring",ear2="Andoaa Earring",
		body="Viti. Tabard +4",hands="Viti. Gloves +4",ring1="Stikini Ring",ring2="Stikini Ring",
		back="Fi Follet Cape +1",waist="Olympus Sash",legs="Atro. Tights +4",feet="Leth. Houseaux +3"}

	-- Refresh potency +8
	sets.midcast.Refresh = {head="Amalric Coif +1",body="Atrophy Tabard +4",legs="Leth. Fuseau +3"}
	-- Aquaveil +2 (5 interruptions blocked)
	sets.midcast.Aquaveil = {head="Amalric Coif +1"}
	sets.midcast.BarElement = {}
	sets.midcast.BarStatus = {}
	sets.midcast.Temper = sets.EnhancingSkill
	sets.midcast.Enspell = sets.EnhancingSkill
	sets.midcast.BoostStat = {hands="Viti. Gloves +4"}	-- Gain +30
	-- Stoneskin +50: 400 HP absorbed
	sets.midcast.Stoneskin = {neck="Nodens Gorget",waist="Siegel Sash"}
	sets.midcast.Protect = {}
	sets.midcast.Shell = {}
	-- Regen potency +9
	sets.midcast.Regen = {body="Telchine Chas.",hands=gear.telchine_regen_hands,feet="Telchine Pigaches"}

	sets.midcast.Curaga = sets.midcast.Cure
	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {}
	sets.Self_Phalanx = {}
	sets.Self_Phalanx.DW = {}

	sets.midcast['Enfeebling Magic'] = {main="Bunzi's Rod",sub="Ammurapi Shield",range="Ullr",ammo=empty,
		head="Viti. Chapeau +4",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.mnd_enfeebling_jse_back,waist="Obstin. Sash",legs="Leth. Fuseau +3",feet="Viti. Boots +4"}

	sets.midcast['Enfeebling Magic'].Resistant = {main="Bunzi's Rod",sub="Ammurapi Shield",range="Ullr",ammo=empty,
		head="Viti. Chapeau +4",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Atrophy Tabard +4",hands="Leth. Ganth. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.mnd_enfeebling_jse_back,waist="Obstin. Sash",legs="Atro. Tights +4",feet="Viti. Boots +4"}

	sets.midcast['Enfeebling Magic'].DW = {main="Bunzi's Rod",sub="Maxentius"}

	-- Lethargy set (5 pieces): duration +50% with Composure
	sets.midcast.Sleep = {main="Bunzi's Rod",sub="Ammurapi Shield",range="Ullr",ammo=empty,
		head="Leth. Chappel +3",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.int_enfeebling_jse_back,waist="Obstin. Sash",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	sets.midcast.Bind = sets.midcast.Sleep
	sets.midcast.Break = sets.midcast.Sleep
	sets.midcast['Dia III'] = sets.midcast.Sleep
	sets.midcast.Inundation = sets.midcast.Sleep

	-- TH 4 (cap 4)
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

	-- Dispel +1: removes two effects
	sets.midcast.Dispel = set_combine(sets.midcast.Sleep.Resistant, {})

	sets.midcast.Dispel.DW = {main="Bunzi's Rod",sub="Maxentius"}
	sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, {})
	sets.midcast.Dispelga.DW = {main="Bunzi's Rod",sub="Maxentius"}

	-- Enfeebling skill 586
	sets.midcast.Frazzle = set_combine(sets.midcast['Enfeebling Magic'], {})

	sets.midcast.Distract = sets.midcast.Frazzle

	sets.midcast.Frazzle.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

	sets.midcast.Distract.Resistant = sets.midcast.Frazzle.Resistant

	sets.midcast['Frazzle II'] = sets.midcast.Frazzle.Resistant
	sets.midcast.Frazzle.DW = {main="Bunzi's Rod",sub="Maxentius"}
	sets.midcast.Distract.DW = sets.midcast.Frazzle.DW

	sets.midcast.Addle = set_combine(sets.midcast['Enfeebling Magic'], {})

	sets.midcast.Paralyze = sets.midcast.Addle
	sets.midcast.Slow = sets.midcast.Addle

	sets.midcast.Addle.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

	sets.midcast.Paralyze.Resistant = sets.midcast.Addle.Resistant
	sets.midcast.Slow.Resistant = sets.midcast.Addle.Resistant

	sets.midcast.Addle.DW = {main="Bunzi's Rod",sub="Maxentius"}
	sets.midcast.Paralyze.DW = sets.midcast.Addle.DW
	sets.midcast.Slow.DW = sets.midcast.Addle.DW

	sets.midcast.Gravity = set_combine(sets.midcast['Enfeebling Magic'], {back=gear.int_enfeebling_jse_back})

	sets.midcast.Gravity.Resistant = set_combine(sets.midcast.Sleep.Resistant, {})

	sets.midcast.Gravity.DW = {main="Bunzi's Rod",sub="Maxentius"}

	sets.midcast.Poison = sets.midcast.Gravity
	sets.midcast.Poison.Resistant = sets.midcast.Gravity.Resistant
	sets.midcast.Poison.DW = sets.midcast.Gravity.DW

	sets.midcast.Blind = sets.midcast.Gravity
	sets.midcast.Blind.Resistant = sets.midcast.Gravity.Resistant
	sets.midcast.Blind.DW = sets.midcast.Gravity.DW

	sets.midcast.Silence = set_combine(sets.midcast.Sleep, {back=gear.mnd_enfeebling_jse_back})

	sets.midcast.Silence.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

	sets.midcast.Silence.DW = {main="Bunzi's Rod",sub="Maxentius"}

	sets.midcast['Elemental Magic'] = {main="Bunzi's Rod",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
		head="Leth. Chappel +3",neck="Sanctity Necklace",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.nuke_jse_back,waist="Eschan Stone",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	-- DT 53 (cap 50)
	sets.midcast['Elemental Magic'].DT = set_combine(sets.midcast['Elemental Magic'], {ear1="Alabaster Earring",ring1="Murky Ring",ring2="Ayanmo Ring"})

	sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {range="Ullr",ammo=empty,neck="Dls. Torque +1",waist="Obstin. Sash"})

	sets.midcast['Elemental Magic'].Proc = {main="Gleti's Knife",sub="Forfend +1",range=empty,ammo="Hasty Pinion",
		head="Atro. Chapeau +4",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Viti. Tabard +4",hands="Atro. Gloves +4",ring1="Stikini Ring",ring2="Prolix Ring",
		back=gear.mnd_enfeebling_jse_back,waist="Obstin. Sash",legs="Atro. Tights +4",feet="Vanya Clogs"}

	sets.midcast['Elemental Magic'].HighTierNuke = set_combine(sets.midcast['Elemental Magic'], {})

	sets.midcast['Elemental Magic'].HighTierNuke.Resistant = set_combine(sets.midcast['Elemental Magic'].Resistant, {})

	sets.RecoverMP = {}

	-- Magic burst damage 25, 35 with Bunzi's Rod (cap 40); MBD II 8
	sets.MagicBurst = {main="Bunzi's Rod",sub="Ammurapi Shield",body="Ea Houppelande",ring1="Jhakri Ring"}
	-- Magic burst damage 25, 35 with Bunzi's Rod (cap 40); Macc +21 with elemental magic skill
	sets.ResistantMagicBurst = {head="Atro. Chapeau +4"}
	sets.midcast['Elemental Magic'].DW = {main="Bunzi's Rod",sub="Ammurapi Shield"}

	-- Atrophy set (2 pieces): Macc +15
	sets.midcast.Impact = {main="Bunzi's Rod",sub="Ammurapi Shield",range="Ullr",ammo=empty,
		head=empty,neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		hands="Atro. Gloves +4",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.int_enfeebling_jse_back,waist="Obstin. Sash",legs="Atro. Tights +4",feet="Leth. Houseaux +3"}

	-- Atrophy set (4 pieces): Macc +45
	sets.midcast['Dark Magic'] = {main="Bunzi's Rod",sub="Ammurapi Shield",range="Ullr",ammo=empty,
		head="Atro. Chapeau +4",neck="Dls. Torque +1",ear1="Snotra Earring",ear2="Leth. Earring +1",
		body="Atrophy Tabard +4",hands="Atro. Gloves +4",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.int_enfeebling_jse_back,waist="Obstin. Sash",legs="Atro. Tights +4",feet="Leth. Houseaux +3"}

	sets.midcast['Bio III'] = sets.midcast['Dark Magic']
	sets.midcast.Bio = set_combine(sets.midcast['Dark Magic'], sets.TreasureHunter)

	-- Drain and Aspir potency +8%
	sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {waist="Fucho-no-Obi"})

	sets.midcast.Aspir = sets.midcast.Drain

	sets.midcast['Absorb-TP'] = set_combine(sets.midcast['Dark Magic'], {range="Ullr",ammo=empty,back=gear.mnd_enfeebling_jse_back})

	sets.midcast['Absorb-TP'].Resistant = set_combine(sets.midcast['Dark Magic'], {range="Ullr",ammo=empty})

	sets.midcast.Stun = set_combine(sets.midcast['Absorb-TP'], {})

	sets.midcast.Stun.Resistant = set_combine(sets.midcast['Absorb-TP'].Resistant, {})

	sets.midcast.Stun.DW = {main="Bunzi's Rod",sub="Maxentius"}

	sets.buff.Saboteur = {hands="Leth. Ganth. +3"}	-- Saboteur +14

	-- HP 97
	sets.HPDown = {ammo="Pemphredo Tathlum",
		head="Wh. Rarab Cap +1",neck="Sibyl Scarf",ear1="Loquac. Earring",ear2="Andoaa Earring",
		body="Telchine Chas.",hands="Jhakri Cuffs +2",ring1="Murky Ring",ring2="Prolix Ring",
		back="Fi Follet Cape +1",waist="Fucho-no-Obi",legs="Doyen Pants",feet="Chelona Boots"}

	-- HP 658, Cure 60 (cap 50) with the weapons free; HP 636, Cure 30 without
	sets.HPCure = {main="Bunzi's Rod",sub="Ammurapi Shield",
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Nyame Mail",hands=gear.telchine_duration_hands,ring1="Naji's Loop",ring2="Murky Ring",
		back="Solemnity Cape",waist="Eschan Stone",legs="Atro. Tights +4",feet="Nyame Sollerets"}

	sets.buff.Doom = {}

	-- Refresh 8 (11 with the weapons free), Fucho-no-Obi latent Refresh +1, MP recovered while healing +5
	sets.resting = {main=gear.colada_refresh,sub="Archduke's Shield",range=empty,
		head="Viti. Chapeau +4",neck="Sibyl Scarf",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Fucho-no-Obi",legs="Leth. Fuseau +3",feet="Chelona Boots"}

	-- Movement speed 18%, DT 58
	sets.Ballista = {main=gear.colada_refresh,sub="Forfend +1",range=empty,
		head="Leth. Chappel +3",neck="Sibyl Scarf",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Flume Belt",legs="Carmine Cuisses +1",feet="Viti. Boots +4"}

	-- Refresh 8 (11 with the weapons free), DT 48, PDT 4, MDT 3
	sets.idle = {main=gear.colada_refresh,sub="Archduke's Shield",range=empty,
		head="Viti. Chapeau +4",neck="Sibyl Scarf",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Flume Belt",legs="Leth. Fuseau +3",feet="Viti. Boots +4"}

	-- DT 58, PDT 8 with Forfend +1
	sets.idle.PDT = set_combine(sets.idle, {sub="Forfend +1",head="Leth. Chappel +3"})

	-- DT 58, MDT 3, Magic Def. Bonus 48
	sets.idle.MDT = set_combine(sets.idle, {head="Leth. Chappel +3",feet="Leth. Houseaux +3"})

	-- Magic evasion 705 (725 with Archduke's Shield), DT 49, MDT 3
	sets.idle.MEVA = set_combine(sets.idle, {head="Leth. Chappel +3",body="Nyame Mail",hands="Nyame Gauntlets"})

	sets.idle.Aminon = set_combine(sets.idle.MEVA, {})

	sets.defense.PDT = set_combine(sets.idle.PDT, {})

	sets.defense.NukeLock = sets.midcast['Elemental Magic']

	sets.defense.MDT = set_combine(sets.idle.MDT, {})

	sets.defense.MEVA = set_combine(sets.idle.MEVA, {})

	sets.Kiting = {legs="Carmine Cuisses +1"}	-- Movement speed 18%
	sets.latent_refresh = {waist="Fucho-no-Obi"}
	sets.latent_refresh_grip = {}
	sets.DayIdle = {}
	sets.NightIdle = {}

	sets.buff.Sublimation = {waist="Embla Sash"}	-- Sublimation +3
	sets.buff.DTSublimation = {waist="Embla Sash"}

	sets.engaged = {ammo="Coiste Bodhar",
		head="Leth. Chappel +3",neck="Asperity Necklace",ear1="Brutal Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Lehko's Ring",ring2="Rajas Ring",
		back=gear.da_jse_back,waist="Sailfi Belt +1",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	-- Atrophy set (4 pieces): Acc +45
	sets.engaged.Acc = {ammo="Coiste Bodhar",
		head="Atro. Chapeau +4",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Atrophy Tabard +4",hands="Atro. Gloves +4",ring1="Lehko's Ring",ring2="Jhakri Ring",
		back=gear.da_jse_back,waist="Eschan Stone",legs="Atro. Tights +4",feet="Leth. Houseaux +3"}

	-- DT 55 (cap 50)
	sets.engaged.DT = {ammo="Coiste Bodhar",
		head="Leth. Chappel +3",neck="Asperity Necklace",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Lehko's Ring",ring2="Murky Ring",
		back=gear.da_jse_back,waist="Sailfi Belt +1",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	-- DT 55 (cap 50)
	sets.engaged.Acc.DT = {ammo="Coiste Bodhar",
		head="Leth. Chappel +3",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Leth. Earring +1",
		body="Lethargy Sayon +3",hands="Leth. Ganth. +3",ring1="Lehko's Ring",ring2="Murky Ring",
		back=gear.da_jse_back,waist="Eschan Stone",legs="Leth. Fuseau +3",feet="Leth. Houseaux +3"}

	sets.engaged.DW = set_combine(sets.engaged, {})

	sets.engaged.DW.Acc = set_combine(sets.engaged.Acc, {})

	sets.engaged.DW.DT = set_combine(sets.engaged.DT, {})

	sets.engaged.DW.Acc.DT = set_combine(sets.engaged.Acc.DT, {})

	sets.engaged.EnspellOnly = set_combine(sets.engaged, {})

	sets.engaged.EnspellOnly.Acc = set_combine(sets.engaged.Acc, {})

	sets.engaged.DualEnspellOnly = set_combine(sets.engaged, {})

	sets.engaged.DualEnspellOnly.Acc = set_combine(sets.engaged.Acc, {})
end

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

--With Ullr in the range slot, a set's ammo would take the bow off and reset TP, so the ammo slot stays empty.
function user_job_post_precast(spell, spellMap, eventArgs)
	if player.equipment.range == 'Ullr' and spell.action_type ~= 'Ranged Attack' then
		equip({ammo=empty})
	end
end

--Engaged, or with the range slot held empty, Pemphredo Tathlum (Macc 8, MAB 4) replaces a midcast set's Ullr, which would cost TP.
function user_job_post_midcast(spell, spellMap, eventArgs)
	if spell.action_type ~= 'Magic' or standardize_set(get_midcast_set(spell, spellMap)).range ~= "Ullr" then return end
	local held = disabled_sets["Weapons"] and standardize_set(disabled_sets["Weapons"])
	if player.status == 'Engaged' or (held and held.range == 'empty') then
		equip({range=empty,ammo=item_equippable("Regal Gem") and "Regal Gem" or "Pemphredo Tathlum"})
	end
end

buff_spell_lists = {
	Auto = {
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