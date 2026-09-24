function character_user_job_setup()
	-- Options: Override default values
    state.OffenseMode:options('Normal','Acc')
    state.HybridMode:options('Normal','DT')
	state.WeaponskillMode:options('Match','Proc')
	state.CastingMode:options('Normal','Resistant','Proc','SIRD')
    state.IdleMode:options('Normal','DT','Aminon')
    state.PhysicalDefenseMode:options('PDT','NukeLock')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.BuffWeaponsMode = M{'Always','Never'}
	state.AutoBuffMode = M{['description'] = 'Auto Buff Mode','Off','Auto','AutoMelee','AutoMage'}
	--state.Weapons:options('None','Naegling','Maxentius','Crocea','Tauret','EnspellOnly','DualWeapons','DualWeaponsAcc','DualMaxentius','DualCrocea','DualMaxentiusAcc','DualPrime','DualAeolian','DualEnspellOnly','DualProcSword')
	state.Weapons:options('None','Naegling','Maxentius','Tauret','EnspellOnly','DualWeapons','DualWeaponsAcc','DualMaxentius','DualMaxentiusAcc','DualAeolian','DualEnspellOnly','DualProcSword')
	state.WeaponSets:options('Default','Dual','Proc','Dynamis')

	weapon_sets = {
		['Default'] = {'None','Naegling','Maxentius','Crocea','Tauret','EnspellOnly'},
		['Dual'] = {'None','DualWeapons','DualMaxentius'},
		['Dynamis'] = {'DualCroceaSavageBlade','DualCrocea','DualTauretCrocea','DualAeolian'},
		['Proc'] = {'ProcSword','ProcDagger','DualProcSword','DualProcDagger'},
	}

	default_weapons = 'None'
	default_dual_weapons = 'DualWeapons'
	trust_list = { "Joachim", "Qultada", "Yoran-Oran (UC)" }
	autows_list =  {['Naegling']={'Savage Blade',1750},['Maxentius']='Black Halo',['Crocea']='Sanguine Blade',['Tauret']='Aeolian Edge',['DualWeapons']='Savage Blade',['DualWeaponsAcc']='Savage Blade',
					['DualMaxentius']='Black Halo',['DualMaxentiusAcc']='Black Halo',['DualEvisceration']='Evisceration',['DualCrocea']='Sanguine Blade',['DualClubs']='Black Halo',
					['DualAeolian']='Aeolian Edge',['DualPrime']='Exenterator',['DualCroceaSavageBlade']="Savage Blade",['CroceaDaybreak']="Seraph Blade",["DualTauretCrocea"]="Aeolian Edge"}
	
	-- gear.int_enfeebling_jse_back = {name="Sucellos's Cape",augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','Haste+10',}}
	gear.mnd_enfeebling_jse_back = {name="Sucellos's Cape",augments={'MND+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', 'Haste+10'}}
	gear.str_wsd_jse_back = {name="Sucellos's Cape",augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}}
	gear.nuke_jse_back = { name="Sucellos's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10',}}
	gear.da_jse_back = {name="Sucellos's Cape",augments =  {'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Phys. dmg. taken-10%',}}
	gear.skill_jse_back = {name="Ghostfyre Cape", augments={'Enfb.mag. skill +8','Enha.mag. skill +5','Mag. Acc.+8','Enh. Mag. eff. dur. +20'}}
	gear.CarmineCuisses = {name="Carmine Cuisses +1", augments={'Accuracy+20','Attack+12','"Dual Wield"+6',}}
	gear.recast_hands = { name = "Telchine Gloves", augments = { 'Haste +3' } }
	gear.merlinic_nuke_legs = { name = "Merlinic Shalwar", augments = { 'Mag. Acc.+25 "Mag.Atk.Bns."+25', 'Magic burst dmg.+1%', 'INT+7', 'Mag. Acc.+11', '"Mag.Atk.Bns."+13' } }
	gear.chironic_macc_legs = { name = "Chironic Hose", augments = { 'Mag. Acc.+28', 'MND+12' } }

	-- AF
	gear.af_head = 'Atrophy Chapeau +4'
	gear.af_hands = "Atrophy Gloves +4"
	gear.af_body = "Atrophy Tabard +4"
	gear.af_legs = "Atrophy Tights +4"

	-- Relic
	gear.relic_neck = "Dls. Torque +1"
	gear.relic_head = "Viti. Chapeau +4"
	gear.relic_hands = "Viti. Gloves +4"
	gear.relic_body = "Viti. Tabard +4"
	gear.relic_feet = "Vitiation Boots +4"

	-- Empyean
	gear.empy_head = "Leth. Chappel +3"
	gear.empy_hands = "Leth. Ganth. +3"
	gear.empy_body = "Lethargy Sayon +3"
	gear.empy_legs = "Leth. Fuseau +3"
	gear.empy_feet = "Leth. Houseaux +3"
	gear.empy_ear = "Leth. Earring +1"

	-- Skill sets
	gear.enhancing_skill = {
		main = "Pukulatmuj +1",
		sub = "Forfend +1",
		neck = "Enhancing Torque",
		ear1 = "Andoaa Earring",
		ear2 = "Mimir Earring",
		hands = gear.relic_hands,
		body = gear.relic_body,
		ring1 = "Stikini Ring",
		ring2 = "Stikini Ring",
		back = "Fi Follet Cape +1",
		waist = "Olympus Sash",
		legs = gear.af_legs,
		feet = gear.empy_feet
	}

	gear.enhancing_duration = {
		sub="Ammurapi Shield",
		neck=gear.relic_neck,
		head="Telchine Cap",
		hands=gear.af_hands,
		body=gear.relic_body,
		feet = gear.empy_feet,
		ear2=gear.empy_ear,
		waist="Embla Sash",
		back=gear.mnd_enfeebling_jse_back
	}

	gear.enfeebling_skill = {
		head = gear.relic_head,
		body = gear.af_body,
		hands = gear.empy_hands,
		legs = gear.chironic_macc_legs,
		feet = gear.relic_feet,
		waist = "Rumination Sash",
		left_ring = "Stikini Ring",
		right_ring = "Stikini Ring",
		back = gear.skill_jse_back,
	}

	gear.enfeebling_base = set_combine(gear.enfeebling_skill, {
		main = "Maxentius",
		sub = "Ammurapi Shield",
		range = "Ullr",
		neck = gear.relic_neck,
		left_ear = "Snotra Earring",
		right_ear = gear.empy_ear,
		head=gear.empy_Head,
		body = gear.empy_body,
		back = gear.mnd_enfeebling_jse_back
	})

	gear.enfeebling_duration = {
		head=gear.empy_head,
		legs=gear.empy_legs,
		feet=gear.empy_feet,
		body = gear.empy_body,
		hands = gear.empy_hands,
		neck = gear.relic_neck,
	}

	gear.enfeebling_resist = {
		head=gear.relic_head,
		body=gear.af_body,
		hands=gear.empy_hands,
		legs=gear.chironic_macc_legs,
		feet=gear.relic_feet
		--neck="Null Loop",
		--back="Null Shawl",
		--waist="Null Belt"
	}

	-- Additional local binds
	-- send_command('bind @` gs c cycle ElementalMode')
	-- send_command('bind ^` gs c scholar dark')
	-- send_command('bind !` gs c scholar light')
	-- send_command('bind !backspace input /ja "Composure" <me>')
	-- send_command('bind ^backspace input /ja "Saboteur" <me>')
	-- send_command('bind @backspace input /ja "Spontaneity" <t>')
	-- send_command('bind ^\\\\ input /ma "Protect V" <t>')
	-- send_command('bind @\\\\ input /ma "Shell V" <t>')
	-- send_command('bind !\\\\ input /ma "Reraise III" <me>')
	-- send_command('bind @f8 gs c toggle AutoNukeMode')
	-- send_command('bind @f10 gs c cycle RecoverMode')
	
	select_default_macro_book()
end

function init_gear_sets()
	--------------------------------------
	-- Start defining the sets
	--------------------------------------

	-- Weapons sets
	sets.weapons.Naegling = {main="Naegling",sub="Ammurapi Shield",range=empty}
	sets.weapons.Crocea = {main="Naegling",sub="Ammurapi Shield",range=empty}
	sets.weapons.Maxentius = {main="Maxentius",sub="Ammurapi Shield",range=empty}
	sets.weapons.Tauret = {main="Tauret",sub="Ammurapi Shield",range=empty}
	sets.weapons.DualWeapons = {main="Naegling",sub="Thibron",range=empty}
	sets.weapons.DualWeaponsAcc = sets.weapons.DualWeapons --{main="Naegling",sub="Gleti's Knife",range=empty}
	sets.weapons.DualPrime = {}--{main="Mpu Gandring",sub="Gleti's Knife",range=empty}
	sets.weapons.DualEvisceration = {}
	sets.weapons.DualCrocea = {}--{main="Crocea Mors",sub="Daybreak",range=empty}
	sets.weapons.DualAeolian = {main="Tauret",sub="Maxentius",range=empty}
	sets.weapons.DualProcSword = {main="Demers. Degen +1",sub="Tauret",range=empty}
	sets.weapons.ProcSword = {main="Demers. Degen +1",sub="Ammurapi Shield",range=empty}
	sets.weapons.ProcDagger = {main="Tauret",sub="Ammurapi Shield",range=empty}
	sets.weapons.DualProcDagger = {main="Tauret",sub="Demers. Degen +1",range=empty}
	sets.weapons.EnspellOnly = {main="Demersal Degen +1", sub="Ammurapi Shield"}--{main="Qutrub Knife",sub="Sacro Bulwark"}
	sets.weapons.DualEnspellOnly = {}--{main="Qutrub Knife",sub="Ethereal Dagger"}
	sets.weapons.DualBow = {}
	sets.weapons.BowMacc = {}
	sets.weapons.DualMaxentius = {main="Maxentius",sub="Thibron",range=empty}
	sets.weapons.DualMaxentiusAcc = {main="Maxentius",sub="Thibron",range=empty}
	
	--Temporary Weapon Sets for Dynamis RP
	--sets.weapons.DualCroceaSavageBlade = {main="Crocea Mors",sub="Thibron"}
	--sets.weapons.DualTauretCrocea = {main="Tauret",sub="Crocea Mors"}
	
	-- Precast Sets
	
	-- Precast sets to enhance JAs
	sets.precast.JA['Chainspell'] = {body=gear.relic_body}
	
	-- Steps (Pure Acc)
	
    sets.precast.Step = {
		--ammo="Hasty Pinion +1",
		--head="Malignance Chapeau",neck="Null Loop",ear1="Zennaroi Earring",ear2="Crepuscular Earring",
		--body="Malignance Tabard",hands="Malignance Gloves",ring1="Cacoethic Ring +1",ring2="Chirich Ring +1",
		--back="Null Shawl",waist="Null Belt",legs="Malignance Tights",feet="Malignance Boots"
	}

	-- Violent Flourish (Macc & Acc)
    sets.precast.JA['Violent Flourish'] = {
		head=gear.empy_head,
		hands = gear.empy_hands,
		ring1 = "Stikini Ring",
		ring2 = "Stikini Ring",
		legs=gear.empy_legs,
		feet=gear.empy_feet
	}

	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}
		
	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}

	-- Fast cast sets for spells
	sets.precast.FC = {
		head=gear.af_head,
		left_ear="Loquac. Earring",
		right_ear=gear.empy_ear,
		body = gear.relic_body,
		legs = "Aya. Cosciales +2",
		waist="Embla Sash",
		feet = "Chelona Boots",
		back="Fi Follet Cape +1",
	}

	sets.precast.FC['Enfeebling Magic'] = set_combine(sets.precast.FC, {
		head = gear.empy_head
	})

	sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, {
		feet="Vanya Clogs"
	})

	sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
		waist="Siegel Sash"
	})

	sets.precast.FC.DT = sets.precast.FC
	sets.precast.FullFC = sets.precast.FC

	-- sets.precast.FC.Impact = set_combine(sets.precast.FC, {head=empty,body="Crepuscular Cloak"})
	-- sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Sacro Bulwark"})

	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {
		ammo="Oshasha's Treatise",
		head=gear.relic_head,
		body=gear.empy_body,
		hands=gear.af_hands,
		legs=gear.empy_legs,
		feet=gear.empy_feet,
		neck="Fotia Gorget",
		waist="Fotia Belt",
		left_ear="Moonshade Earring",
		right_ear=gear.empy_ear,
		left_ring="Karieyh Ring",
		right_ring="Epaminondas's Ring",
		back=gear.str_wsd_jse_back,
	}
	sets.precast.WS.Proc = sets.precast.WS

	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {
		hands = gear.empy_hands,
		ring1 = "Stikini Ring",
		ring2 = "Stikini Ring",
		back=gear.mnd_enfeebling_jse_back
	})

	sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {
		
	})
		
	sets.precast.WS['Evisceration'] = sets.precast.WS['Chant du Cygne']

	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {

	})
		
	sets.precast.WS['Black Halo'] = set_combine(sets.precast.WS, {

	})
		
	sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS, {
		ammo="Pemphredo Tathlum",
		ear1="Friomisi Earring",
		ear2="Choleric Earring",
		neck="Sanctity Necklace",
		waist="Eschan Stone"
	})
		
	sets.precast.WS['Seraph Blade'] = sets.precast.WS['Sanguine Blade']

	sets.precast.WS['Shining Strike'] = sets.precast.WS['Seraph Blade']
	sets.precast.WS['Flash Nova'] = sets.precast.WS['Seraph Blade']
		
	sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS, {

	})
		
	sets.precast.WS['Red Lotus Blade'] = sets.precast.WS['Aeolian Edge']

	-- Swap to these on Moonshade using WS if at 3000 TP
	 sets.MaxTP = {ear2="Brutal Earring"}
	-- sets.AccMaxTP = {ear2="Telos Earring"}
	-- sets.MagicalMaxTP = {ear2="Friomisi Earring"}
	
	-- Midcast Sets

	-- Gear that converts elemental damage done to recover MP.	
	sets.midcast.FastRecast = set_combine(sets.precast.FC, {
		left_ring="Lehko's Ring"
	})

	sets.midcast.Cure = set_combine(sets.midcast.FastRecast, {
		main = "Nibiru Cudgel",
		sub = "Archduke's Shield",
		left_ear = "Mendicant's Earring",
		neck = "Nodens Gorget",
		ring2 = "Naji's loop",
		legs = gear.af_legs,
		hands = gear.recast_hands,
		feet = "Vanya Clogs",
		back = gear.skill_jse_back
	})
		
	sets.midcast.Cure.LightWeatherCure = set_combine(sets.midcast.Cure, {})
	sets.midcast.Cure.LightDayCure = set_combine(sets.midcast.Cure, {})
	sets.midcast.Cure.DT = set_combine(sets.midcast.Cure, {})
	sets.midcast.Cure.Cursna = set_combine(sets.midcast.Cure, {
		feet="Vanya Clogs"
	})
	sets.midcast.Cure.StatusRemoval = set_combine(sets.midcast.FastRecast, {})
	
	-- Add Duration
	sets.midcast['Enhancing Magic'] = set_combine(gear.enhancing_skill, gear.enhancing_duration)

	--Atrophy Gloves are better than Lethargy for me despite the set bonus for duration on others.
	sets.buff.ComposureOther = {head=gear.empy_head,
		body=gear.empy_body, legs=gear.empy_legs,
		feet=gear.empy_feet
	}
		
	--Red Mage enhancing sets are handled in a different way from most, layered on due to the way Composure works
	--Don't set combine a full set with these spells, they should layer on Enhancing Set > Composure (If Applicable) > Spell
		
	sets.midcast.Refresh = {
		head="Amalric Coif +1",
		body=gear.af_body,
		legs=gear.empy_legs
	}
	sets.midcast.Aquaveil = {head="Amalric Coif +1"} --{,waist="Emphatikos Rope",legs="Shedir Seraweels"} --hands="Regal Cuffs"
	sets.midcast.BarElement = {} --{legs="Shedir Seraweels"}
	sets.midcast.BarStatus = {}--{neck="Sroda Necklace"}
	sets.midcast.Temper = set_combine(gear.enhancing_duration, gear.enhancing_skill)
	sets.midcast.Enspell = set_combine(gear.enhancing_duration, gear.enhancing_skill)
	sets.midcast.BoostStat = {hands=gear.relic_hands}
	sets.midcast.Stoneskin = {main="Pukulatmuj +1", neck="Nodens Gorget",waist="Siegel Sash",legs="Doyen Pants"}--ring2="Earthcry Earring"
	sets.midcast.Protect = {}--{ring2="Sheltered Ring"}
	sets.midcast.Shell = {}--{ring2="Sheltered Ring"}
	sets.midcast.Regen = {}--{main="Bolelabunga",sub="Ammurapi Shield"}
	
	sets.midcast.Curaga = sets.midcast.Cure
	sets.Self_Healing = {}--{neck="Phalaina Locket",ear1="Etiolation Earring",ring2="Kunaji Ring",waist="Gishdubar Sash"}
	sets.Cure_Received = {}--{neck="Phalaina Locket",ring2="Kunaji Ring",waist="Gishdubar Sash"}
	sets.Self_Refresh = {}--{waist="Gishdubar Sash"}
	sets.Self_Phalanx = {
		-- main="Sakpata's Sword",
		-- head="Taeon Chapeau",
		-- body="Taeon Tabard",
		-- hands="Taeon Gloves",
		-- back=gear.mnd_enfeebling_jse_back,
		-- legs="Taeon Tights",
		-- feet="Taeon Boots",
		-- ammo="Staunch Tathlum +1"
	}
	sets.Self_Phalanx.DW = {}-- {main="Sakpata's Sword",sub="Egeking"}

	sets.midcast['Enfeebling Magic'] = gear.enfeebling_base
		
	sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], gear.enfeebling_resist)
	sets.midcast['Enfeebling Magic'].DW = {
		--main="Bunzi's Rod",
		--sub="Maxentius"
	}
	
	-- Duration / Accuracy / INT
	sets.midcast.Sleep = set_combine(set_combine(sets.midcast['Enfeebling Magic'], gear.enfeebling_duration), {
		back = gear.nuke_jse_back
	})

	sets.midcast.Sleep.Resistant = set_combine(sets.midcast.Sleep, gear.enfeebling_resist)
	sets.midcast.Sleep.DW = {
		--main="Bunzi's Rod",
		--sub="Maxentius"
	}
		
	sets.midcast.Bind = sets.midcast.Sleep
	sets.midcast.Bind.Resistant = sets.midcast.Sleep.Resistant
	sets.midcast.Bind.DW = sets.midcast.Sleep.DW
	
	sets.midcast.Break = sets.midcast.Sleep
	sets.midcast.Break.Resistant = sets.midcast.Sleep.Resistant
	sets.midcast.Break.DW = sets.midcast.Sleep.DW

	sets.midcast['Dia III'] = sets.midcast.Sleep
	sets.midcast['Bio III'] = sets.midcast.Sleep
	sets.midcast.Inundation = sets.midcast.Sleep

	-- Accuracy
	sets.midcast.Dispel = set_combine(set_combine(sets.midcast['Enfeebling Magic'], gear.enfeebling_resist), {
		back = gear.nuke_jse_back
	})

	sets.midcast.Dispel.DW = {
		--main="Bunzi's Rod",
		--sub="Maxentius"
	}
	sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, {
		-- main="Daybreak",
		-- sub="Ammurapi Shield"
	})
	sets.midcast.Dispelga.DW = {
		--main="Daybreak",sub="Bunzi's Rod"
	}
	
	-- Duration / Effect
	sets.midcast.Frazzle = sets.midcast['Enfeebling Magic']
				
	sets.midcast.Frazzle.Resistant = set_combine(sets.midcast.Frazzle, gear.enfeebling_resist)
		
	sets.midcast.Frazzle.DW = {
		--main="Bunzi's Rod",sub="Daybreak"
	}
	
	sets.midcast.Distract = sets.midcast.Frazzle
	sets.midcast.Distract.Resistant = sets.midcast.Frazzle.Resistant
	sets.midcast.Distract.DW = sets.midcast.Frazzle.DW
	
	sets.midcast.Addle = sets.midcast['Enfeebling Magic']
		
	sets.midcast.Paralyze = sets.midcast.Addle
	sets.midcast.Slow = sets.midcast.Addle
	
	sets.midcast.Addle.Resistant = set_combine(sets.midcast.Frazzle, {
		body = gear.af_body,
		--neck="Null Loop",
		--back="Null Shawl",
		--waist="Null Belt"
	})
		
	sets.midcast.Paralyze.Resistant = sets.midcast.Addle.Resistant
	sets.midcast.Slow.Resistant = sets.midcast.Addle.Resistant
	
	sets.midcast.Addle.DW = {
		--main="Bunzi's Rod",sub="Daybreak"
	}
	sets.midcast.Paralyze.DW = sets.midcast.Addle.DW
	sets.midcast.Slow.DW = sets.midcast.Addle.DW
	
	sets.midcast.Gravity = set_combine(set_combine(sets.midcast['Enfeebling Magic'], gear.enfeebling_duration), {
		back = gear.nuke_jse_back
	})
		
	sets.midcast.Gravity.Resistant = set_combine(sets.midcast.Gravity, gear.enfeebling_resist)
		
	sets.midcast.Gravity.DW = {
		--main="Bunzi's Rod",sub="Maxentius"
	}
	
	sets.midcast.Poison = sets.midcast.Gravity
	sets.midcast.Poison.Resistant = sets.midcast.Gravity.Resistant
	sets.midcast.Poison.DW = sets.midcast.Gravity.DW
	
	sets.midcast.Blind = sets.midcast.Gravity
	sets.midcast.Blind.Resistant = sets.midcast.Gravity.Resistant
	sets.midcast.Blind.DW = sets.midcast.Gravity.DW
	
	sets.midcast.Silence = set_combine(sets.midcast['Enfeebling Magic'], gear.enfeebling_duration)
		
	sets.midcast.Silence.Resistant = set_combine(sets.midcast.Silence, gear.enfeebling_resist)
		
	sets.midcast.Silence.DW = {
		--main="Bunzi's Rod",sub="Daybreak"
	}
	
	--After Bunzi's is augmented it will probably win on low-tier nukes.
	sets.midcast['Elemental Magic'] = {
		main="Maxentius",
		sub="Ammurapi Shield",
		ammo="Pemphredo Tathlum",
		head=gear.empy_head,
		body=gear.empy_body,
		hands=gear.empy_hands,
		legs=gear.empy_legs,
		feet=gear.empy_feet,
		neck="Sanctity Necklace",
		waist="Eschan Stone",
		left_ear="Friomisi Earring",
		right_ear="Novio Earring",
		left_ring="Jhakri Ring",
		right_ring="Acumen Ring",
		back=gear.nuke_jse_back
	}
		
	sets.midcast['Elemental Magic'].DT = set_combine(sets.midcast['Elemental Magic'], {

	})
		
	sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {

	})
		
	sets.midcast['Elemental Magic'].Proc = set_combine(sets.midcast['Elemental Magic'], {

	})
		
	sets.midcast['Elemental Magic'].HighTierNuke = set_combine(sets.midcast['Elemental Magic'], {

	})
		
	sets.midcast['Elemental Magic'].HighTierNuke.Resistant = set_combine(sets.midcast['Elemental Magic'], {

	})
		
	-- Gear that Recovers MP when nuking.
	sets.RecoverMP = {} --{body="Seidr Cotehardie"}
	
	-- Gear for Magic Burst mode.
    sets.MagicBurst = {
		--main="Bunzi's Rod",sub="Ammurapi Shield",neck="Mizu. Kubikazari",hands="Bunzi's Gloves",ring1="Mujin Band"
	}
	sets.midcast['Elemental Magic'].DW = {
		--main="Bunzi's Rod",sub="Daybreak"
	}
		
	sets.midcast.Impact = {}

	sets.midcast['Dark Magic'] = {
		main = "Maxentius",
		sub = "Ammurapi Shield",
		ammo = "Pemphredo Tathlum",
		head = gear.empy_head,
		body = gear.empy_body,
		hands = gear.empy_hands,
		legs = gear.empy_legs,
		feet = gear.empy_feet,
		neck = gear.relic_neck,
		waist = "Eschan Stone",
		left_ear = "Snotra Earring",
		right_ear = gear.empy_ear,
		left_ring = "Stikini Ring",
		right_ring = "Stikini Ring",
		back = gear.nuke_jse_back
	}

	sets.midcast.Drain = sets.midcast['Dark Magic']

	sets.midcast.Aspir = sets.midcast.Drain
	
	sets.midcast['Absorb-TP'] = sets.midcast['Dark Magic']
		
	sets.midcast['Absorb-TP'].Resistant = sets.midcast['Dark Magic']
		
	sets.midcast.Stun = sets.midcast['Dark Magic']

	sets.midcast.Stun.Resistant = sets.midcast['Dark Magic']
		
	sets.midcast.Stun.DW = {
		--main="Bunzi's Rod",sub="Maxentius"
	}

	-- Sets for special buff conditions on spells.
		
	sets.buff.Saboteur = {hands=gear.empy_hands}
	
	sets.HPDown = {}
		
    sets.HPCure = {}
	
	sets.buff.Doom = set_combine(sets.buff.Doom, {})

	-- Sets to return to when not performing an action.

	-- Idle sets
	sets.idle = {
		main="Colada",
		sub="Archduke's Shield",
		ammo="Pemphredo Tathlum",
		head=gear.relic_head,
		body=gear.empy_body,
		hands=gear.empy_hands,
		legs=gear.CarmineCuisses,
		feet="Nyame Sollerets",
		neck="Sibyl Scarf",
		waist="Flume Belt",
		left_ear="Alabaster Earring",
		right_ear=gear.empy_ear,
		left_ring="Murky Ring",
		right_ring="Stikini Ring",
		back=gear.da_jse_back
	}
	
		
	sets.idle.DT = set_combine(sets.idle, {})
		
	sets.idle.Aminon = {}
	
	-- Resting sets
	sets.resting = set_combine(sets.idle, {
		main = "Chatoyant Staff",
		feet = "Chelona Boots"
	})

	-- Defense sets
	sets.defense.NukeLock = sets.midcast['Elemental Magic']
	
	sets.Kiting = {legs=gear.CarmineCuisses}
	sets.latent_refresh = {waist="Fucho-no-obi"}
	--sets.latent_refresh_grip = {sub="Oneiros Grip"}
	sets.DayIdle = {}
	sets.NightIdle = {}
	
    --sets.buff.Sublimation = {waist="Embla Sash"}
    --sets.buff.DTSublimation = {waist="Embla Sash"}

	-- Treasure Hunter

	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
	sets.midcast.Dia = set_combine(sets.midcast.Sleep, sets.TreasureHunter)
	sets.midcast.Diaga = set_combine(sets.midcast.Sleep, sets.TreasureHunter)
	sets.midcast.Bio = set_combine(sets.midcast.Sleep, sets.TreasureHunter)

	-- Engaged sets

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.Dagger.Accuracy.Evasion
	
	-- Normal melee group

	sets.engaged = {
		ammo = "Ginsen",
		head = gear.empy_head,
		body = gear.empy_body,
		hands = gear.empy_hands,
		legs = gear.CarmineCuisses,
		feet = "Nyame Sollerets",
		neck = "Asperity Necklace",
		waist = "Sailfi Belt +1",
		left_ear = "Brutal Earring",
		right_ear = gear.empy_ear,
		left_ring = "Lehko's Ring",
		right_ring = "Rajas Ring",
		back = gear.da_jse_back
	}
	
	-- {
	-- 	ammo = "Ginsen",
	-- 	head = "Aya. Zucchetto +2",
	-- 	body = "Ayanmo Corazza +2",
	-- 	hands = "Nyame Gauntlets",
	-- 	legs = gear.CarmineCuisses,
	-- 	feet = "Aya. Gambieras +2",
	-- 	neck = "Asperity Necklace",
	-- 	waist = "Sailfi Belt +1",
	-- 	left_ear = "Steelflash Earring",
	-- 	right_ear = "Bladeborn Earring",
	-- 	left_ring = "Rajas Ring",
	-- 	right_ring = "Lehko's Ring",
	-- 	back = gear.da_jse_back,
	-- }
		
	sets.engaged.Acc = set_combine(sets.engaged, {
	})

	sets.engaged.DT = set_combine(sets.engaged, {
	})
		
	sets.engaged.Acc.DT = set_combine(sets.engaged, {
	})
		
	sets.engaged.DW = set_combine(sets.engaged, {
	})
		
	sets.engaged.DW.Acc = set_combine(sets.engaged, {
	})
		
	sets.engaged.DW.DT = set_combine(sets.engaged, {
	})
		
	sets.engaged.DW.Acc.DT = set_combine(sets.engaged, {
	})

	sets.engaged.EnspellOnly = set_combine(sets.engaged, {
	})
		
	sets.engaged.EnspellOnly.Acc = set_combine(sets.engaged, {
	})

	sets.engaged.DualEnspellOnly = set_combine(sets.engaged, {
	})
		
	sets.engaged.DualEnspellOnly.Acc = set_combine(sets.engaged, {
	})

end

-- Select default macro book on initial load or subjob change.
-- Default macro set/book
function select_default_macro_book()
	local macro_pages = {
		SCH = 2,
		BLM = 3,
		DRK = 4,
		DNC = 5,
		NIN = 6,
	}

	local page = macro_pages[player.sub_job] or 1
	set_macro_page(page, 1)

	windower.send_command('gs validate')
	--windower.send_command('lua r xivcrossbar')
end

function user_job_lockstyle()
	local cmd

	if player.sub_job == 'SCH' then
		if state.Buff['Light Arts'] or state.Buff['Addendum: White'] then
			cmd = '/lockstyleset 022'
		elseif state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
			cmd = '/lockstyleset 0023'
		else
			cmd = '/lockstyleset 021'
		end
	elseif player.sub_job == 'NIN' or player.sub_job == 'DNC' then
		cmd = '/lockstyleset 024'
	end

	if cmd then
		windower.chat.input(cmd)
	end
end

function user_job_buff_change(buff, gain)
	if buff:startswith('Addendum: ') or buff:endswith(' Arts') then
		style_lock = true
	end
end

function user_job_precast(spell, spellMap, eventArgs)
	if state.Weapons.value ~= 'None' and not state.UnlockWeapons.value then
		equip_weaponset()
	end
end

function user_job_post_midcast(spell, spellMap, eventArgs)	
	if spell.english:startswith('Refresh') and spell.target.type == 'SELF' and sets.Self_Refresh then
		equip(sets.Self_Refresh)
		if can_dual_wield and sets.Self_Refresh.DW then
			equip(sets.Self_Refresh.DW)
		end
	end
end

-- Sel-Include's get_idle_set() sends any IdleMode whose name contains DT/Tank/EVA to
-- state.NonCombatIdleMode while out of combat. That mode is never defined anywhere in
-- the library, so the lookup fails, the elseif is skipped, and idle silently falls back
-- to plain sets.idle. Reapply the selected mode's set so PDT/MDT/MEVA hold out of
-- combat as well as in it.
function user_job_customize_idle_set(idleSet)
	if in_combat then return idleSet end

	local mode = state.IdleMode.value
	if not (mode:contains('DT') or mode:contains('Tank') or mode:contains('EVA')) then
		return idleSet
	end

	local modeSet = sets.idle[mode]
	if not modeSet then return idleSet end

	-- Mirror the pet and custom-group descent get_idle_set would have done.
	if (pet.isvalid or state.Buff.Pet) and modeSet.Pet then
		modeSet = modeSet.Pet
		if pet.status == 'Engaged' and modeSet.Engaged then
			modeSet = modeSet.Engaged
		end
	end

	for _,group in ipairs(classes.CustomIdleGroups) do
		if modeSet[group] then modeSet = modeSet[group] end
	end

	return set_combine(idleSet, modeSet)
end

buff_spell_lists = {
	Auto = {--Options for When are: Always, Engaged, Idle, OutOfCombat, Combat
		{Name='Refresh III',	Buff='Refresh',		SpellID=894,	When='Always'},
		{Name='Haste II',		Buff='Haste',		SpellID=511,	When='Always'},
		--{Name='Aurorastorm',	Buff='Aurorastorm',	SpellID=119,	When='Idle'},
		--{Name='Reraise',		Buff='Reraise',		SpellID=135,	When='Always'},
	},
	
	AutoMelee = {
		{Name='Phalanx',		Buff='Phalanx',			SpellID=107,	When='Combat'},
		{Name='Haste II',		Buff='Haste',			SpellID=511,	When='Combat'},
		{Name='Temper II',		Buff='Multi Strikes',	SpellID=895,	When='Combat'},
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	When='Always'},
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