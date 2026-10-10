function character_user_job_setup()
    state.OffenseMode:options('Fodder','Normal','Acc','FullAcc')
	state.HybridMode:options('Normal','DT')
    state.WeaponskillMode:options('Match','Normal','Acc','FullAcc','Fodder')
    state.CastingMode:options('Normal','SIRD','Resistant','FullMacc','Fodder','Proc')
    state.IdleMode:options('Normal','Sphere','PDT','DTHippo')
	state.PhysicalDefenseMode:options('PDT')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.Weapons:options('Tizona','Tizona Acc','None','Almace','MeleeClubs','HybridWeapons','Savage Blade','Savage Blade Acc')

    state.ExtraMeleeMode = M{['description']='Extra Melee Mode','None','MP','SuppaBrutal','DWEarrings','DWMax'}

	state.JobMode = M{['description']='Job Mode','AoE','Melee'}
	state.JobMode:set('Melee')

	ws_buff_list = S{'Savage Blade','Expiacion','Chant du Cygne','Vorpal Blade','Black Halo','Requiescat','Realmrazer'}

	--Spells, job abilities and weaponskills that wear sets.TreasureHunter against an untagged monster, plus any ranged attack (User-Globals.lua).
	--In Tag mode nothing else wears it, melee included, and an action off the list doesn't count as tagging. Delete the line to let every action tag.
	TH_Whitelist = S{'Glutinous Dart'}

	gear.da_jse_back = {name="Rosmerta's Cape",augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%',}}
	gear.crit_jse_back = {name="Rosmerta's Cape",augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10',}}
	gear.wsd_jse_back = {name="Rosmerta's Cape",augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}}
	gear.nuke_jse_back = {name="Rosmerta's Cape",augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10',}}
	gear.colada_refresh = {name="Colada",augments={'"Refresh"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12','DMG:+1',}}
	gear.telchine_duration_hands = {name="Telchine Gloves",augments={'Haste+3','Enh. Mag. eff. dur. +10',}}

	send_command('bind ^` input /ja "Chain Affinity" <me>')
	send_command('bind @` input /ja "Efflux" <me>')
	send_command('bind !` input /ja "Burst Affinity" <me>')
	send_command('bind ^@!` gs c cycle SkillchainMode')
	send_command('bind ^backspace input /ja "Unbridled Learning" <me>;wait 1;input /ja "Diffusion" <me>;wait 2;input /ma "Mighty Guard" <me>')
	send_command('bind !backspace input /ja "Unbridled Learning" <me>;wait 1;input /ja "Diffusion" <me>;wait 2;input /ma "Carcharian Verve" <me>')
	send_command('bind @backspace input /ja "Convergence" <me>')
	send_command('bind @f10 gs c toggle LearningMode')
	send_command('bind ^@!` gs c cycle MagicBurstMode')
	send_command('bind @f8 gs c toggle AutoNukeMode')

	select_default_macro_book()
	queue_azure_set(5)
end

function init_gear_sets()

	-- Burst Affinity +21 (WSC multiplier 2.21)
	sets.buff['Burst Affinity'] = {legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}
	-- Chain Affinity +22
	sets.buff['Chain Affinity'] = {feet="Assim. Charuqs +2"}
	-- Convergence +2% per merit level (0 merits: no effect)
	sets.buff.Convergence = {head="Luh. Keffiyeh +1"}
	-- Diffusion duration +25%, +45% with the 5 merits
	sets.buff.Diffusion = {feet="Luhlaza Charuqs +1"}
	sets.buff.Enchainment = {}
	-- Efflux TP bonus +1050, 2250 with the base 1000 and job points
	sets.buff.Efflux = {back=gear.da_jse_back,legs="Hashishin Tayt +3"}
	sets.buff.Doom = {}

	-- HP 94
	sets.HPDown = {head="Wh. Rarab Cap +1",neck="Sibyl Scarf",ear1="Loquac. Earring",ear2="Andoaa Earring",
		body="Telchine Chas.",hands="Jhakri Cuffs +2",ring1="Murky Ring",ring2="Prolix Ring",
		back="Fi Follet Cape +1",waist="Fucho-no-Obi",legs="Enif Cosciales",feet="Chelona Boots"}

	-- HP 616, Cure 53 with Bunzi's Rod (cap 50), 23 without
	sets.HPCure = {main="Bunzi's Rod",
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Mendi. Earring",
		body="Nyame Mail",hands=gear.telchine_duration_hands,ring1="Naji's Loop",ring2="Murky Ring",
		back="Solemnity Cape",waist="Eschan Stone",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	sets.precast.JA['Azure Lore'] = {hands="Luh. Bazubands +1"}	-- Azure Lore +10 s


	-- Waltz potency +10%, DT 52, PDT 13, MDT 3
	sets.precast.Waltz = {
		head="Hashishin Kavuk +3",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Gleti's Cuirass",hands="Hashi. Bazu. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Flume Belt",legs="Hashishin Tayt +3",feet="Nyame Sollerets"}

	sets.Self_Waltz = {}

	sets.precast.Waltz['Healing Waltz'] = {}

	-- Assimilator's set (2 pieces): Acc +15
	sets.precast.Step = {ammo="Honed Tathlum",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Assim. Bazu. +3",ring1="Lehko's Ring",ring2="Jhakri Ring",
		back=gear.da_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.precast.Flourish1 = set_combine(sets.precast.Step, {hands="Hashi. Bazu. +3",ring1="Ayanmo Ring"})

	-- FC 52, 56 with Colada
	sets.precast.FC = {main=gear.colada_refresh,
		head="Amalric Coif +1",ear1="Loquac. Earring",ear2="Etiolation Earring",
		body="Luhlaza Jubbah +1",hands="Pinga Mittens",ring1="Prolix Ring",ring2="Naji's Loop",
		back="Fi Follet Cape +1",waist="Witful Belt",legs="Enif Cosciales",feet="Chelona Boots"}

	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})

	-- FC 45, 49 with Colada; Blue magic casting time -16%
	sets.precast.FC['Blue Magic'] = set_combine(sets.precast.FC, {body="Hashishin Mintan +3"})


	-- WSD 67
	sets.precast.WS = {ammo="Coiste Bodhar",
		head="Hashishin Kavuk +3",neck="Rep. Plat. Medal",ear1="Moonshade Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
		back=gear.wsd_jse_back,waist="Sailfi Belt +1",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	-- Assimilator's set (2 pieces): Acc +15
	sets.precast.WS.Acc = {ammo="Honed Tathlum",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Assim. Bazu. +3",ring1="Lehko's Ring",ring2="Jhakri Ring",
		back=gear.da_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.precast.WS.FullAcc = set_combine(sets.precast.WS.Acc, {})

	-- DT 53, WSD 56
	sets.precast.WS.DT = {ammo="Coiste Bodhar",
		head="Nyame Helm",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Murky Ring",
		back=gear.wsd_jse_back,waist="Sailfi Belt +1",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	-- WSD 67
	sets.precast.WS.Fodder = set_combine(sets.precast.WS, {legs="Nyame Flanchard"})

	-- Fotia Gorget and Fotia Belt fTP +25/256 a hit each
	sets.precast.WS['Requiescat'] = {ammo="Coiste Bodhar",
		head="Hashishin Kavuk +3",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Hashi. Earring +1",
		body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Lehko's Ring",ring2="Rajas Ring",
		back=gear.da_jse_back,waist="Fotia Belt",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}
	sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Requiescat'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	-- DT 55
	sets.precast.WS['Requiescat'].DT = set_combine(sets.precast.WS['Requiescat'], {ear1="Alabaster Earring",ring2="Murky Ring"})
	sets.precast.WS['Requiescat'].Fodder = set_combine(sets.precast.WS['Requiescat'], {})

	sets.precast.WS['Realmrazer'] = set_combine(sets.precast.WS['Requiescat'], {})
	sets.precast.WS['Realmrazer'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Realmrazer'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Realmrazer'].DT = set_combine(sets.precast.WS['Requiescat'].DT, {})
	sets.precast.WS['Realmrazer'].Fodder = set_combine(sets.precast.WS['Realmrazer'], {})

	-- Crit 24, DA 19; Fotia Gorget fTP +25/256 a hit
	sets.precast.WS['Chant du Cygne'] = {ammo="Coiste Bodhar",
		head="Hashishin Kavuk +3",neck="Fotia Gorget",ear1="Brutal Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Nyame Gauntlets",ring1="Lehko's Ring",ring2="Rajas Ring",
		back=gear.crit_jse_back,waist="Sailfi Belt +1",legs="Hashishin Tayt +3",feet="Gleti's Boots"}
	sets.precast.WS['Chant du Cygne'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Chant du Cygne'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	-- DT 55
	sets.precast.WS['Chant du Cygne'].DT = set_combine(sets.precast.WS['Chant du Cygne'], {ear1="Alabaster Earring",
		body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring2="Murky Ring",back=gear.da_jse_back,legs="Hashishin Tayt +3"})
	sets.precast.WS['Chant du Cygne'].Fodder = set_combine(sets.precast.WS['Chant du Cygne'], {})

	-- WSD 65
	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {body="Nyame Mail"})
	sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Savage Blade'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Savage Blade'].DT = set_combine(sets.precast.WS.DT, {})
	sets.precast.WS['Savage Blade'].Fodder = set_combine(sets.precast.WS['Savage Blade'], {})

	sets.precast.WS['Vorpal Blade'] = sets.precast.WS['Chant du Cygne']
	sets.precast.WS['Vorpal Blade'].Acc = sets.precast.WS['Chant du Cygne'].Acc
	sets.precast.WS['Vorpal Blade'].FullAcc = sets.precast.WS['Chant du Cygne'].FullAcc
	sets.precast.WS['Vorpal Blade'].DT = sets.precast.WS['Chant du Cygne'].DT
	sets.precast.WS['Vorpal Blade'].Fodder = sets.precast.WS['Chant du Cygne'].Fodder

	-- WSD 65
	sets.precast.WS['Expiacion'] = set_combine(sets.precast.WS, {body="Nyame Mail"})
	sets.precast.WS['Expiacion'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Expiacion'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Expiacion'].DT = set_combine(sets.precast.WS.DT, {})
	sets.precast.WS['Expiacion'].Fodder = set_combine(sets.precast.WS['Expiacion'], {})

	-- WSD 59, MAB 267
	sets.precast.WS['Sanguine Blade'] = {ammo="Pemphredo Tathlum",
		head="Hashishin Kavuk +3",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Hashi. Earring +1",
		body="Nyame Mail",hands="Jhakri Cuffs +2",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
		back=gear.wsd_jse_back,waist="Eschan Stone",legs="Luh. Shalwar +4",feet="Hashi. Basmak +3"}

	-- DT 53
	sets.precast.WS['Sanguine Blade'].DT = set_combine(sets.precast.WS.DT, {ammo="Pemphredo Tathlum",neck="Sanctity Necklace",waist="Eschan Stone"})

	-- Fotia Belt: fTP +25/256, and its Accuracy 10 counts as Macc
	sets.precast.WS['Flash Nova'] = set_combine(sets.precast.WS['Sanguine Blade'], {waist="Fotia Belt"})

	sets.precast.WS['Sanguine Blade'].DT = set_combine(sets.precast.WS.DT, {ammo="Pemphredo Tathlum",neck="Sanctity Necklace",waist="Eschan Stone"})

	sets.precast.WS['Sanguine Blade'].Acc = set_combine(sets.precast.WS['Sanguine Blade'], {neck="Mirage Stole +2",ear1="Alabaster Earring",
		body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",back=gear.nuke_jse_back,legs="Hashishin Tayt +3"})
	sets.precast.WS['Sanguine Blade'].FullAcc = set_combine(sets.precast.WS['Sanguine Blade'].Acc, {})
	sets.precast.WS['Flash Nova'].Acc = set_combine(sets.precast.WS['Sanguine Blade'].Acc, {waist="Fotia Belt"})
	sets.precast.WS['Flash Nova'].FullAcc = set_combine(sets.precast.WS['Flash Nova'].Acc, {})

	sets.MaxTP = {ear1="Brutal Earring"}	-- DA 5
	sets.AccMaxTP = {ear1="Alabaster Earring"}	-- Acc 2

	-- Haste 32 (cap 26), FC 46, Blue magic recast -16%
	sets.midcast.FastRecast = {ammo="Hasty Pinion",
		head="Amalric Coif +1",ear1="Loquac. Earring",ear2="Etiolation Earring",
		body="Luhlaza Jubbah +1",hands="Hashi. Bazu. +3",ring1="Prolix Ring",ring2="Lehko's Ring",
		back="Fi Follet Cape +1",waist="Witful Belt",legs="Enif Cosciales",feet="Chelona Boots"}

	sets.midcast['Blue Magic'] = {}

	-- Chain Affinity +28, Efflux +800; Hashishin set 5% (WSC x3, x4 under Chain or Burst Affinity)
	sets.midcast['Blue Magic'].Physical = {main="Tizona",sub="Almace",ammo="Coiste Bodhar",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Moonshade Earring",ear2="Hashi. Earring +1",
		body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Jhakri Ring",ring2="Ayanmo Ring",
		back=gear.wsd_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.midcast['Blue Magic'].Physical.Resistant = {main="Tizona",sub="Almace",ammo="Honed Tathlum",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Hashi. Bazu. +3",ring1="Jhakri Ring",ring2="Lehko's Ring",
		back=gear.da_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- Blue magic skill 635
	sets.midcast['Blue Magic'].Physical.Fodder = {main="Tizona",sub="Almace",ammo="Mavi Tathlum",
		head="Luh. Keffiyeh +1",neck="Mirage Stole +2",ear1="Njordr Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back="Cornflower Cape",waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Luhlaza Charuqs +1"}

	sets.midcast['Blue Magic'].PhysicalAcc = set_combine(sets.midcast['Blue Magic'].Physical.Resistant, {})

	sets.midcast['Blue Magic'].PhysicalAcc.Resistant = set_combine(sets.midcast['Blue Magic'].PhysicalAcc, {})
	sets.midcast['Blue Magic'].PhysicalAcc.Fodder = sets.midcast['Blue Magic'].Physical.Fodder

	sets.midcast['Blue Magic'].PhysicalStr = set_combine(sets.midcast['Blue Magic'].Physical, {})
	sets.midcast['Blue Magic'].PhysicalStr.Resistant = set_combine(sets.midcast['Blue Magic'].Physical.Resistant, {})
	sets.midcast['Blue Magic'].PhysicalStr.Fodder = set_combine(sets.midcast['Blue Magic'].Physical.Fodder, {})

	sets.midcast['Blue Magic'].PhysicalDex = set_combine(sets.midcast['Blue Magic'].Physical, {})
	sets.midcast['Blue Magic'].PhysicalDex.Resistant = set_combine(sets.midcast['Blue Magic'].Physical.Resistant, {})
	sets.midcast['Blue Magic'].PhysicalDex.Fodder = set_combine(sets.midcast['Blue Magic'].Physical.Fodder, {})

	sets.midcast['Blue Magic'].PhysicalVit = set_combine(sets.midcast['Blue Magic'].Physical, {})
	sets.midcast['Blue Magic'].PhysicalVit.Resistant = set_combine(sets.midcast['Blue Magic'].Physical.Resistant, {})
	sets.midcast['Blue Magic'].PhysicalVit.Fodder = set_combine(sets.midcast['Blue Magic'].Physical.Fodder, {})

	sets.midcast['Blue Magic'].PhysicalAgi = set_combine(sets.midcast['Blue Magic'].Physical, {})
	sets.midcast['Blue Magic'].PhysicalAgi.Resistant = set_combine(sets.midcast['Blue Magic'].Physical.Resistant, {})
	sets.midcast['Blue Magic'].PhysicalAgi.Fodder = set_combine(sets.midcast['Blue Magic'].Physical.Fodder, {})

	sets.midcast['Blue Magic'].PhysicalInt = set_combine(sets.midcast['Blue Magic'].Physical, {})
	sets.midcast['Blue Magic'].PhysicalInt.Resistant = set_combine(sets.midcast['Blue Magic'].Physical.Resistant, {})
	sets.midcast['Blue Magic'].PhysicalInt.Fodder = set_combine(sets.midcast['Blue Magic'].Physical.Fodder, {})

	sets.midcast['Blue Magic'].PhysicalMnd = set_combine(sets.midcast['Blue Magic'].Physical, {})
	sets.midcast['Blue Magic'].PhysicalMnd.Resistant = set_combine(sets.midcast['Blue Magic'].Physical.Resistant, {})
	sets.midcast['Blue Magic'].PhysicalMnd.Fodder = set_combine(sets.midcast['Blue Magic'].Physical.Fodder, {})

	sets.midcast['Blue Magic'].PhysicalChr = set_combine(sets.midcast['Blue Magic'].Physical, {})
	sets.midcast['Blue Magic'].PhysicalChr.Resistant = set_combine(sets.midcast['Blue Magic'].Physical.Resistant, {})
	sets.midcast['Blue Magic'].PhysicalChr.Fodder = set_combine(sets.midcast['Blue Magic'].Physical.Fodder, {})

	sets.midcast['Blue Magic'].PhysicalHP = set_combine(sets.midcast['Blue Magic'].Physical, {})
	sets.midcast['Blue Magic'].PhysicalHP.Resistant = set_combine(sets.midcast['Blue Magic'].Physical.Resistant, {})
	sets.midcast['Blue Magic'].PhysicalHP.Fodder = set_combine(sets.midcast['Blue Magic'].Physical.Fodder, {})

	-- MAB 311 (367 with the weapons free)
	sets.midcast['Blue Magic'].Magical = {main="Bunzi's Rod",sub="Maxentius",ammo="Pemphredo Tathlum",
		 head="Hashishin Kavuk +3",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Hashi. Earring +1",
		 body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		 back=gear.nuke_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- SIRD 33
	sets.midcast['Blue Magic'].Magical.SIRD = set_combine(sets.midcast['Blue Magic'].Magical, {legs="Assim. Shalwar +1",waist="Rumination Sash",ring1="Murky Ring"})

	sets.midcast['Blue Magic'].Subduction = set_combine(sets.midcast['Blue Magic'].Magical, {})

	sets.midcast['Blue Magic'].Magical.Proc = set_combine(sets.midcast.FastRecast, {})

	sets.midcast['Blue Magic'].Magical.Resistant = set_combine(sets.midcast['Blue Magic'].Magical, {neck="Mirage Stole +2",ear1="Njordr Earring"})

	sets.midcast['Blue Magic'].Magical.Fodder = set_combine(sets.midcast['Blue Magic'].Magical, {legs="Luh. Shalwar +4"})

	sets.midcast['Blue Magic'].MagicalMnd = set_combine(sets.midcast['Blue Magic'].Magical, {})
	sets.midcast['Blue Magic'].MagicalChr = set_combine(sets.midcast['Blue Magic'].Magical, {})
	sets.midcast['Blue Magic'].MagicalVit = set_combine(sets.midcast['Blue Magic'].Magical, {})
	sets.midcast['Blue Magic'].MagicalDex = set_combine(sets.midcast['Blue Magic'].Magical, {})
	sets.midcast['Blue Magic'].MagicalAgi = set_combine(sets.midcast['Blue Magic'].Magical, {})

	-- Blue magic skill 594
	sets.midcast['Blue Magic'].MagicAccuracy = {main="Tizona",sub="Bunzi's Rod",ammo="Pemphredo Tathlum",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Njordr Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.nuke_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.midcast['Blue Magic'].Magical.FullMacc = sets.midcast['Blue Magic'].MagicAccuracy
	sets.midcast['Blue Magic'].Subduction.FullMacc = sets.midcast['Blue Magic'].MagicAccuracy

	sets.midcast['Enfeebling Magic'] = {main="Tizona",sub="Bunzi's Rod",ammo="Pemphredo Tathlum",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
		body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.nuke_jse_back,waist="Rumination Sash",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.midcast['Dark Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {waist="Eschan Stone"})

	-- Enhancing magic duration +30% (augmented)
	sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.FastRecast, {head="Telchine Cap",hands=gear.telchine_duration_hands,legs="Telchine Braconi"})

	-- Enhancing skill +87
	sets.midcast['Phalanx'] = set_combine(sets.midcast['Enhancing Magic'],{main="Pukulatmuj +1",neck="Enhancing Torque",ear1="Mimir Earring",ear2="Andoaa Earring",body="Telchine Chas.",ring1="Stikini Ring",ring2="Stikini Ring",back="Fi Follet Cape +1",waist="Olympus Sash",legs="Carmine Cuisses +1"})

	sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {head="Amalric Coif +1"})	-- Refresh potency +2

	-- Aquaveil +2
	sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {head="Amalric Coif +1"})

	-- Stoneskin +20
	sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {waist="Siegel Sash"})

	sets.midcast.BarElement = set_combine(sets.midcast['Phalanx'], {})

	sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {})
	sets.midcast.Protectra = set_combine(sets.midcast['Enhancing Magic'], {})
	sets.midcast.Shell = set_combine(sets.midcast['Enhancing Magic'], {})
	sets.midcast.Shellra = set_combine(sets.midcast['Enhancing Magic'], {})

	sets.midcast['Divine Magic'] = set_combine(sets.midcast['Dark Magic'], {})

	sets.midcast['Elemental Magic'] = {main="Bunzi's Rod",sub="Maxentius",ammo="Pemphredo Tathlum",
		head="Hashishin Kavuk +3",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Hashi. Earring +1",
		body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.nuke_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {neck="Mirage Stole +2"})	-- Macc 25

	sets.midcast.Helix = sets.midcast['Elemental Magic']
	sets.midcast.Helix.Resistant = sets.midcast['Elemental Magic'].Resistant

	sets.element.Dark = {}
	sets.element.Light = {}

	-- Cure 23, 53 with Bunzi's Rod (cap 50); DT 44, PDT 4
	sets.midcast.Cure = {main="Bunzi's Rod",sub="Maxentius",
		head="Hashishin Kavuk +3",ear1="Alabaster Earring",ear2="Mendi. Earring",
		body="Hashishin Mintan +3",hands=gear.telchine_duration_hands,ring1="Naji's Loop",ring2="Murky Ring",
		back="Solemnity Cape",waist="Flume Belt",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.midcast.UnlockedCure = set_combine(sets.midcast.Cure, {})

	-- Healing magic skill +18
	sets.midcast.Cursna =  set_combine(sets.midcast.FastRecast, {legs="Carmine Cuisses +1"})

	-- Breath damage +25%
	sets.midcast['Blue Magic'].Breath = {ammo="Mavi Tathlum",
		head="Luh. Keffiyeh +1",neck="Mirage Stole +2",ear1="Njordr Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.nuke_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.midcast['Blue Magic'].Stun = {main="Tizona",sub="Bunzi's Rod",ammo="Pemphredo Tathlum",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Njordr Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back="Cornflower Cape",waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.midcast['Blue Magic'].Stun.Resistant = set_combine(sets.midcast['Blue Magic'].Stun, {ammo="Honed Tathlum",ring1="Jhakri Ring",ring2="Ayanmo Ring",back=gear.da_jse_back})

	sets.midcast['Blue Magic'].Stun.Fodder = sets.midcast['Blue Magic'].Stun

	-- HP 666, Cure 48 with Bunzi's Rod
	sets.midcast['Blue Magic'].UnlockedAoEHealing = {main="Bunzi's Rod",
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Nyame Mail",hands=gear.telchine_duration_hands,ring1="Naji's Loop",ring2="Murky Ring",
		back="Solemnity Cape",waist="Eschan Stone",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	-- HP 616, Cure 23 with the weapons locked
	sets.midcast['Blue Magic'].AoEHealing = set_combine(sets.midcast['Blue Magic'].UnlockedAoEHealing, {ear2="Mendi. Earring"})

	-- Cure 23, 53 with Bunzi's Rod (cap 50)
	sets.midcast['Blue Magic'].Healing = {main="Bunzi's Rod",
		head="Hashishin Kavuk +3",ear1="Alabaster Earring",ear2="Mendi. Earring",
		body="Hashishin Mintan +3",hands=gear.telchine_duration_hands,ring1="Naji's Loop",ring2="Stikini Ring",
		back="Solemnity Cape",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.midcast['Blue Magic'].UnlockedHealing = set_combine(sets.midcast['Blue Magic'].Healing, {})

	-- Blue magic skill 635
	sets.midcast['Blue Magic'].SkillBasedBuff = {ammo="Mavi Tathlum",
		head="Luh. Keffiyeh +1",neck="Mirage Stole +2",ear1="Njordr Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back="Cornflower Cape",waist="Witful Belt",legs="Hashishin Tayt +3",feet="Luhlaza Charuqs +1"}

	sets.midcast['Blue Magic'].Buff = set_combine(sets.midcast.FastRecast, {})

	-- Refresh potency +2
	sets.midcast['Blue Magic']['Battery Charge'] = set_combine(sets.midcast['Blue Magic'].Buff, {head="Amalric Coif +1"})

	-- Aquaveil +2
	sets.midcast['Blue Magic']['Carcharian Verve'] = set_combine(sets.midcast['Blue Magic'].Buff, {head="Amalric Coif +1"})

	sets.latent_refresh = {waist="Fucho-no-Obi"}
	sets.latent_refresh_grip = {}
	sets.DayIdle = {}
	sets.NightIdle = {}

	sets.Learning = {hands="Assim. Bazu. +3"}	-- Chance to learn Blue magic +16

	-- Refresh 6 (8 with Colada), Fucho-no-Obi latent Refresh +1, MP recovered while healing +5
	sets.resting = {main=gear.colada_refresh,ammo="Pemphredo Tathlum",
			      head="Rawhide Mask",neck="Sibyl Scarf",ear1="Alabaster Earring", ear2="Etiolation Earring",
			      body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Karieyh Ring",ring2="Murky Ring",
			      back=gear.da_jse_back,waist="Fucho-no-Obi",legs="Hashishin Tayt +3",feet="Chelona Boots"}

	-- Refresh 6 (8 with Colada), Regain 5, DT 55, PDT 4, MDT 3
	sets.idle = {main=gear.colada_refresh,ammo="Pemphredo Tathlum",
			      head="Rawhide Mask",neck="Sibyl Scarf",ear1="Alabaster Earring", ear2="Etiolation Earring",
			      body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Karieyh Ring",ring2="Murky Ring",
			      back=gear.da_jse_back,waist="Flume Belt",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.idle.Sphere = set_combine(sets.idle, {})

	sets.idle.PDT = set_combine(sets.idle, {})

	-- Movement speed 18%, DT 53
	sets.idle.DTHippo = set_combine(sets.idle.PDT, {head="Nyame Helm",ring1="Ayanmo Ring",legs="Carmine Cuisses +1"})

	-- DT 55, PDT 4
	sets.defense.PDT = {ammo="Coiste Bodhar",
				head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
		        body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Lehko's Ring",ring2="Murky Ring",
				back=gear.da_jse_back,waist="Flume Belt",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- DT 58, MDT 3, Magic Def. Bonus 48
	sets.defense.MDT = {ammo="Pemphredo Tathlum",
				head="Hashishin Kavuk +3",neck="Sibyl Scarf",ear1="Alabaster Earring",ear2="Etiolation Earring",
		        body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Ayanmo Ring",ring2="Murky Ring",
				back=gear.da_jse_back,waist="Flume Belt",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- Magic evasion 692, DT 55, MDT 3
    sets.defense.MEVA = set_combine(sets.defense.MDT, {hands="Nyame Gauntlets"})

	sets.defense.NukeLock = sets.midcast['Blue Magic'].Magical

	sets.Kiting = {legs="Carmine Cuisses +1"}	-- Movement speed 18%

    sets.Knockback = {}
	-- Converts 2% of damage taken to MP
    sets.MP = {waist="Flume Belt"}
    sets.MP_Knockback = {}
	sets.SuppaBrutal = {ear1="Brutal Earring"}
	sets.DWEarrings = {}
	sets.DWMax = {legs="Carmine Cuisses +1"}	-- Dual Wield 6
	-- TH 4 (cap 4)
	sets.TreasureHunter = {head="Wh. Rarab Cap +1",body="Volte Jupon",waist="Chaac Belt"}

	sets.weapons['Tizona Acc'] = {main="Tizona",sub="Almace"}
	sets.weapons['Tizona'] = {main="Tizona",sub="Thibron"}
	sets.weapons.MeleeClubs = {main="Maxentius",sub="Bunzi's Rod"}
	sets.weapons.Almace = {main="Almace",sub="Thibron"}
	sets.weapons['Savage Blade'] = {main="Naegling",sub="Thibron"}
	sets.weapons['Savage Blade Acc'] = {main="Naegling",sub="Almace"}
	sets.weapons.MaccWeapons = {main="Tizona",sub="Bunzi's Rod"}
	sets.weapons.HybridWeapons = {main="Naegling",sub="Bunzi's Rod"}

	sets.engaged = {main="Tizona",sub="Almace",ammo="Coiste Bodhar",
			    head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Brutal Earring",ear2="Hashi. Earring +1",
			    body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Lehko's Ring",ring2="Rajas Ring",
			    back=gear.da_jse_back,waist="Sailfi Belt +1",legs="Hashishin Tayt +3",feet="Nyame Sollerets"}

	sets.engaged.AM = set_combine(sets.engaged, {back=gear.crit_jse_back,feet="Hashi. Basmak +3"})


	-- Assimilator's set (2 pieces): Acc +15
	sets.engaged.Acc = {main="Tizona",sub="Almace",ammo="Honed Tathlum",
				head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
				body="Assim. Jubbah +4",hands="Assim. Bazu. +3",ring1="Lehko's Ring",ring2="Jhakri Ring",
				back=gear.da_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.engaged.Acc.AM = set_combine(sets.engaged.Acc, {})

	sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {})

	sets.engaged.FullAcc.AM = set_combine(sets.engaged.Acc, {})

	sets.engaged.Fodder = set_combine(sets.engaged, {})

	sets.engaged.Fodder.AM = set_combine(sets.engaged.AM, {})

	-- DT 57
	sets.engaged.DT = {main="Tizona",sub="Almace",ammo="Coiste Bodhar",
			    head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Brutal Earring",ear2="Hashi. Earring +1",
			    body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Lehko's Ring",ring2="Murky Ring",
			    back=gear.da_jse_back,waist="Kentarch Belt +1",legs="Hashishin Tayt +3",feet="Nyame Sollerets"}

	-- DT 52
	sets.engaged.DT.AM = set_combine(sets.engaged.DT, {back=gear.crit_jse_back})

	-- DT 55
	sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, {body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring2="Murky Ring"})

	sets.engaged.Acc.DT.AM = set_combine(sets.engaged.Acc.DT, {})

	sets.engaged.FullAcc.DT = set_combine(sets.engaged.Acc.DT, {})

	sets.engaged.Fodder.DT = set_combine(sets.engaged.DT, {})

	sets.engaged.Fodder.DT.AM = set_combine(sets.engaged.DT.AM, {})

	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {}
	-- Magic burst damage 17, and 31 to 39 with the weapons free (cap 40)
	sets.MagicBurst = {ring1="Jhakri Ring"}
	-- Resistant nukes add no burst gear: magic burst damage 15, 25 with Bunzi's Rod (cap 40)
	sets.ResistantMagicBurst = {}
	sets.Phalanx_Received = {}
end

function select_default_macro_book()
	if player.sub_job == 'DNC' then
		set_macro_page(4, 2)
	elseif player.sub_job == 'NIN' then
		set_macro_page(5, 2)
	elseif player.sub_job == 'WAR' then
		set_macro_page(7, 2)
	elseif player.sub_job == 'RUN' then
		set_macro_page(3, 2)
	elseif player.sub_job == 'THF' then
		set_macro_page(2, 2)
	elseif player.sub_job == 'RDM' then
		set_macro_page(1, 2)
	else
		set_macro_page(6, 2)
	end
end

AutoWS_List = {
	['Tizona'] = { { 'Expiacion', 1000 }, { 'Expiacion', 1750 }, { 'Expiacion', 'AM2' }, { 'Expiacion', 'AM3' } },
	['Tizona Acc'] = { { 'Expiacion', 1000 }, { 'Expiacion', 1750 }, { 'Expiacion', 2750 }, { 'Expiacion', 'AM2' }, { 'Expiacion', 'AM3' } },
	['Almace'] = { { 'Chant du Cygne', 1000 }, { 'Chant du Cygne', 1750 } },
	['MeleeClubs'] = { { 'Black Halo', 1000 }, { 'Black Halo', 1750 }, { 'Black Halo', 2750 } },
	['HybridWeapons'] = { { 'Sanguine Blade', 1000 } },
	['Savage Blade'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 } },
	['Savage Blade Acc'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 }, { 'Savage Blade', 2750 } },
}

local Unbridled_Spells = S{'Absolute Terror','Bilgestorm','Blistering Roar','Bloodrake','Carcharian Verve',
	'Cesspool','Crashing Thunder','Cruel Joke','Droning Whirlwind','Gates of Hades','Harden Shell',
	'Mighty Guard','Polar Roar','Pyric Bulwark','Tearing Gust','Thunderbolt','Tourbillion','Uproot'}

local Diffusion_Spells = S{'Mighty Guard','Harden Shell'}

--Dropped unless Chain Affinity is up or ready; Efflux goes up first when it is ready.
local Chain_Affinity_Spells = S{'Sinker Drill'}

--The resent spell, which passes untouched, and the os.clock() time until which other blue magic is dropped.
local blu_refire, blu_lock_until = nil, 0
--Last time Unbridled Learning was reported not ready, so AutoBuffMode's retries print it at most every 30 s.
local unbridled_abort_said = nil

--Drops the spell, uses its abilities 1.1 s apart, then resends it. The resend always passes, so this never loops.
function user_job_filter_precast(spell, spellMap, eventArgs)
	if spell.type ~= 'BlueMagic' or spell.test then return end
	--Silenced, the spell would fail after the abilities were spent.
	if buffactive['Silence'] or buffactive['Mute'] or buffactive['Omerta'] then return end
	--Under Amnesia or Impairment the abilities fail: a Chain Affinity spell is dropped, any other goes ahead.
	if buffactive['Amnesia'] or buffactive['Impairment'] then
		if Chain_Affinity_Spells:contains(spell.english) and not buffactive['Chain Affinity'] then
			eventArgs.cancel = true
			add_to_chat(123, "Abort: Chain Affinity can't be used.")
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
		eventArgs.cancel = true
		return
	end

	local recasts = windower.ffxi.get_ability_recasts()
	local unbridled = Unbridled_Spells:contains(spell.english) and not buffactive['Unbridled Learning'] and not buffactive['Unbridled Wisdom']
	local diffusion = Diffusion_Spells:contains(spell.english) and not buffactive['Diffusion'] and recasts[184] == 0
	local chain = Chain_Affinity_Spells:contains(spell.english)
	local chain_affinity = chain and not buffactive['Chain Affinity']
	local efflux = chain and not buffactive['Efflux'] and recasts[185] == 0
	if not (unbridled or diffusion or chain_affinity or efflux) then return end
	if ((windower.ffxi.get_spell_recasts()[spell.recast_id] or 0) / 60) > 1 then return end

	if unbridled and recasts[81] ~= 0 then
		eventArgs.cancel = true
		if not unbridled_abort_said or now - unbridled_abort_said > 30 then
			unbridled_abort_said = now
			add_to_chat(123, 'Abort: Unbridled Learning not active.')
		end
		return
	end
	if chain_affinity and recasts[181] ~= 0 then
		eventArgs.cancel = true
		add_to_chat(123, 'Abort: Chain Affinity not ready.')
		return
	end

	eventArgs.cancel = true
	--Mid-action, the first ability would be refused.
	if midaction() then return end

	local abilities = {}
	if unbridled then abilities[#abilities + 1] = 'Unbridled Learning' end
	if diffusion then abilities[#abilities + 1] = 'Diffusion' end
	if chain_affinity then abilities[#abilities + 1] = 'Chain Affinity' end
	if efflux then abilities[#abilities + 1] = 'Efflux' end

	local delay = 0
	for _, ability in ipairs(abilities) do
		windower.chat.input:schedule(delay, '/ja "'..ability..'" <me>')
		delay = delay + 1.1
	end

	local name, target = spell.english, spell.target.raw or '<me>'
	blu_lock_until = now + delay + 1
	local refire = function()
		blu_refire = name
		windower.chat.input('/ma "'..name..'" '..target)
	end
	refire:schedule(delay)
	add_tick_delay(delay)
end

--With the weapons free, a burst outside Resistant, FullMacc and Proc takes Maxentius in the main hand (magic burst damage +4 a skillchain) and Bunzi's Rod in the sub (+10).
function user_job_post_midcast(spell, spellMap, eventArgs)
	if spell.action_type ~= 'Magic' or state.MagicBurstMode.value == 'Off' or not is_nuke(spell, spellMap) then return end
	local mode = state.CastingMode.value
	if mode:contains('Resistant') or mode == 'FullMacc' or mode == 'Proc' then return end
	if player.status == 'Engaged' or disabled_sets["Weapons"] or not can_dual_wield then return end
	equip({main="Maxentius",sub="Bunzi's Rod"})
end

local azure_settings_path = windower.windower_path..'addons/AzureSets/data/settings.xml'

--Each queued load takes a new number; a scheduled load for an older one does nothing, so a job change sends one //aset.
local azure_request = 0

--Job trait 18 is Dual Wield.
local function has_dual_wield()
	local abilities = windower.ffxi.get_abilities()
	return abilities ~= nil and abilities.job_traits ~= nil and table.contains(abilities.job_traits, 18)
end

local function azure_set_names()
	local file = io.open(azure_settings_path, 'r')
	if not file then return nil end
	local text = file:read('*a'):lower()
	file:close()
	local names = {}
	for name in text:gmatch('<([%w_]+)%s*/?>') do names[name] = true end
	return names
end

--Rechecks Dual Wield each second for a minute while AzureSets sets spells; Sel rereads it only on load or subjob change.
local function watch_dual_wield(request, had, checks)
	if request ~= azure_request or checks > 60 then return end
	local has = has_dual_wield()
	if has ~= had then
		set_dual_wield()
		if not midaction() then send_command('gs c update') end
	end
	watch_dual_wield:schedule(1, request, has, checks + 1)
end

--Loads {sub}_mage (AoE) or {sub}_melee, falling back to war_melee; retries up to ten times while the spell list is missing.
local function load_azure_set(request, tries)
	if request ~= azure_request then return end
	local current = windower.ffxi.get_player()
	if current and current.main_job ~= 'BLU' then return end
	local job_data = current and windower.ffxi.get_mjob_data()
	if not job_data or not job_data.spells then
		tries = (tries or 0) + 1
		if tries < 10 then
			load_azure_set:schedule(1, request, tries)
		else
			add_to_chat(123, 'Blue magic spell list not loaded, AzureSets spell set skipped.')
		end
		return
	end

	local sub = (current.sub_job or 'war'):lower()
	local candidates = {}
	if state.JobMode.value == 'AoE' then candidates[#candidates + 1] = sub..'_mage' end
	candidates[#candidates + 1] = sub..'_melee'
	if sub ~= 'nin' and sub ~= 'war' then candidates[#candidates + 1] = 'war_melee' end

	local names = azure_set_names()
	local chosen
	if not names then
		add_to_chat(123, 'AzureSets settings not found at '..azure_settings_path..', loading '..candidates[1]..' unchecked.')
		chosen = candidates[1]
	else
		for _, name in ipairs(candidates) do
			if names[name] then chosen = name break end
			add_to_chat(123, 'AzureSets spell set '..name..' is missing.')
		end
		if not chosen then return end
	end

	send_command('input //aset spellset '..chosen)
	watch_dual_wield(request, nil, 0)
end

--Global: character_user_job_setup calls it.
function queue_azure_set(delay)
	azure_request = azure_request + 1
	load_azure_set:schedule(delay, azure_request)
end

--Delayed: a main job change also fires this while this file is still loaded.
function user_job_sub_job_change(newSubjob, oldSubjob)
	queue_azure_set(5)
end

function user_job_state_change(stateField, newValue, oldValue)
	if stateField == 'Job Mode' then queue_azure_set(0) end
end

--Retires scheduled loads and watches so none runs after unload.
function user_job_unload()
	azure_request = azure_request + 1
end