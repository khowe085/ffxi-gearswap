function character_user_job_setup()
	-- Options: Override default values
	state.OffenseMode:options('Normal','SomeAcc','Acc','FullAcc','Fodder')
	state.WeaponskillMode:options('Match','Normal','SomeAcc','Acc','FullAcc','Fodder')
	state.HybridMode:options('Normal')
	state.PhysicalDefenseMode:options('PDT', 'PDTReraise')
	state.MagicalDefenseMode:options('MDT', 'MDTReraise')
	state.ResistDefenseMode:options('MEVA')
	state.IdleMode:options('Normal', 'PDT','Refresh','Reraise')
	state.Weapons:options('Foenaria','Montante','Naegling')
	state.ExtraMeleeMode = M{['description']='Extra Melee Mode','None'}
	state.Passive = M{['description'] = 'Passive Mode','None','MP','Twilight'}

	-- Additional local binds
	send_command('bind ^` input /ja "Hasso" <me>')
	send_command('bind !` input /ja "Seigan" <me>')
	send_command('bind @` gs c cycle SkillchainMode')

	gear.stp_jse_back = {name="Ankou's Mantle",augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Damage taken-5%',}}
	gear.fc_jse_back = {name="Ankou's Mantle",augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast "+10',}}
	gear.str_wsd_jse_back = {name="Ankou's Mantle",augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%',}}

	select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
	--------------------------------------
	-- Start defining the sets
	--------------------------------------
	-- Precast Sets
	-- Precast sets to enhance JAs
	sets.precast.JA['Diabolic Eye'] = {}
	sets.precast.JA['Arcane Circle'] = {feet="Ig. Sollerets +3"}
	sets.precast.JA['Souleater'] = {}
	sets.precast.JA['Weapon Bash'] = {hands="Ig. Gauntlets +3"}
	sets.precast.JA['Nether Void'] = {}
	sets.precast.JA['Blood Weapon'] = {}
	sets.precast.JA['Dark Seal'] = {}
	sets.precast.JA['Last Resort'] = {}

	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}

	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}

	sets.precast.Step = {}

	sets.precast.Flourish1 = {}

	-- Fast cast sets for spells

	sets.precast.FC = {
		ear1="Loquac. Earring",ear2="Etiolation Earring",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Prolix Ring",ring2="Murky Ring",
		back=gear.fc_jse_back, waist="Flume Belt",legs="Enif Cosciales"}

	--sets.precast.FC.Impact = set_combine(sets.precast.FC, {head=empty,body="Twilight Cloak"})

	-- Midcast Sets
	sets.midcast.FastRecast = {
		ear1="Loquac. Earring",ear2="Etiolation Earring",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Prolix Ring",ring2="Murky Ring",
		back=gear.fc_jse_back,legs="Enif Cosciales"}

	-- Specific spells

	sets.midcast['Dark Magic'] = {ammo="Pemphredo Tathlum",
		head="Ig. Burgeonet +3",neck="Aesir Torque",
		body="Ignominy Cuirass +3",hands="Ig. Gauntlets +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.fc_jse_back,waist="Casso Sash",legs="Ig. Flanchard +3",feet="Ig. Sollerets +3"}

	sets.midcast['Enfeebling Magic'] = {ammo="Pemphredo Tathlum",
		head="Ig. Burgeonet +3",neck="Sanctity Necklace",
		body="Ignominy Cuirass +3",hands="Ig. Gauntlets +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.fc_jse_back,waist="Eschan Stone",legs="Ig. Flanchard +3",feet="Ig. Sollerets +3"}

	sets.midcast['Dread Spikes'] = set_combine(sets.midcast['Dark Magic'], {})
	sets.midcast.Absorb = set_combine(sets.midcast['Dark Magic'], {})

	sets.midcast.Stun = {ammo="Pemphredo Tathlum",
		head="Ig. Burgeonet +3",neck="Aesir Torque",
		body="Ignominy Cuirass +3",hands="Ig. Gauntlets +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.fc_jse_back,legs="Ig. Flanchard +3",feet="Ig. Sollerets +3"}

	sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {})

	--sets.DrainWeapon = {main="Misanthropy",sub="Alber Strap"}
	--sets.AbsorbWeapon = {main="Liberator",sub="Khonsu",range="Ullr",ammo=empty}
	--sets.DreadWeapon = {main="Crepuscular Scythe",sub="Utu Grip",}

	sets.midcast.Aspir = sets.midcast.Drain

	--sets.midcast.Impact = set_combine(sets.midcast['Dark Magic'], {head=empty,body="Twilight Cloak"})

	sets.midcast.Cure = {}

	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {}

	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {ammo="Coiste Bodhar",
			head="Nyame Helm",neck="Rep. Plat. Medal",ear1="Moonshade Earring",ear2="Alabaster Earring",
			body="Ignominy Cuirass +3",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
			back=gear.str_wsd_jse_back,waist="Sailfi Belt +1",legs="Nyame Flanchard",feet="Nyame Sollerets"}
	
	
	sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {})
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {})
	sets.precast.WS.FullAcc = set_combine(sets.precast.WS, {})
	sets.precast.WS.Fodder = set_combine(sets.precast.WS, {})


	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	sets.precast.WS['Catastrophe'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Catastrophe'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
	sets.precast.WS['Catastrophe'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Catastrophe'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Catastrophe'].Fodder = set_combine(sets.precast.WS.Fodder, {})

	sets.precast.WS['Origin'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Origin'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
	sets.precast.WS['Origin'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Origin'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Origin'].Fodder = set_combine(sets.precast.WS.Fodder, {})

	sets.precast.WS['Torcleaver'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Torcleaver'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
	sets.precast.WS['Torcleaver'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Torcleaver'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Torcleaver'].Fodder = set_combine(sets.precast.WS.Fodder, {})

	sets.precast.WS['Cross Reaper'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Cross Reaper'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
	sets.precast.WS['Cross Reaper'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Cross Reaper'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Cross Reaper'].Fodder = set_combine(sets.precast.WS.Fodder, {})

	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Savage Blade'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
	sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Savage Blade'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Savage Blade'].Fodder = set_combine(sets.precast.WS.Fodder, {})

	sets.precast.WS['Insurgency'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Insurgency'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
	sets.precast.WS['Insurgency'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Insurgency'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Insurgency'].Fodder = set_combine(sets.precast.WS.Fodder, {})

	sets.precast.WS['Entropy'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Entropy'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
	sets.precast.WS['Entropy'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Entropy'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Entropy'].Fodder = set_combine(sets.precast.WS.Fodder, {})

	sets.precast.WS['Resolution'] = set_combine(sets.precast.WS, {})
	sets.precast.WS['Resolution'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
	sets.precast.WS['Resolution'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Resolution'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Resolution'].Fodder = set_combine(sets.precast.WS.Fodder, {})

	-- Sets to return to when not performing an action.

	-- Resting sets
	sets.resting = {}

	-- Swap to these on Moonshade using WS if at 3000 TP
	-- sets.MaxTP = {ear1="Bale Earring",ear2="Grit Earring",}
	-- sets.AccMaxTP = {ear1="Heartseeker Earring",ear2="Steelflash Earring"}
	-- sets.AccDayMaxTPWSEars = {ear1="Heartseeker Earring",ear2="Steelflash Earring"}
	-- sets.DayMaxTPWSEars = {ear1="Bale Earring",ear2="Brutal Earring",}
	-- sets.AccDayWSEars = {ear1="Heartseeker Earring",ear2="Steelflash Earring"}
	-- sets.DayWSEars = {ear1="Brutal Earring",ear2="Moonshade Earring",}


	sets.idle.Weak = set_combine(sets.idle, {head="Crepuscular Helm",body="Crepuscular Mail"})

	sets.idle.Reraise = set_combine(sets.idle, {head="Crepuscular Helm",body="Crepuscular Mail"})

	-- Defense sets
	sets.defense.PDT = {
		head="Nyame Helm",
		body="Volte Haubert",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		waist="Flume Belt",
		left_ear="Alabaster Earring",
		left_ring="Murky Ring",
	}

	sets.defense.PDTReraise = set_combine(sets.defense.PDT, {head="Crepuscular Helm",body="Crepuscular Mail"})

	sets.defense.MDT = {}

	sets.defense.MDTReraise = set_combine(sets.defense.MDT, {head="Crepuscular Helm",body="Crepuscular Mail"})

	sets.defense.MEVA = {}

	-- Idle sets

	sets.idle = {ammo="Coiste Bodhar", neck="Sibyl Scarf",
		head="Crepuscular Helm",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Crepuscular Mail",hands="Sulev. Gauntlets +2",ring1="Karieyh Ring",ring2="Murky Ring",
		back=gear.stp_jse_back,waist="Sailfi Belt +1",feet="Nyame Sollerets"}

	sets.idle.PDT = set_combine(sets.idle, sets.defense.PDT)

	sets.Kiting = {legs="Carmine Cuisses +1"}
	sets.passive.Reraise = {head="Crepuscular Helm",body="Crepuscular Mail"}

	-- Engaged sets
	sets.engaged = {ammo="Coiste Bodhar",
		head="Flam. Zucchetto +2",neck="Asperity Necklace",ear1="Brutal Earring",ear2="Alabaster Earring",
		body="Crepuscular Mail",hands="Sulev. Gauntlets +2",ring1="Lehko's Ring",ring2="Murky Ring",
		back=gear.stp_jse_back,waist="Sailfi Belt +1",legs="Ig. Flanchard +3",feet="Flam. Gambieras +2"}
	sets.engaged.SomeAcc = {}
	sets.engaged.Acc = {}
	sets.engaged.FullAcc = {}
	sets.engaged.Fodder = {}

	--Extra Special Sets

	sets.buff['Dark Seal'] = {} --head="Fallen's Burgeonet +3"
	sets.buff.Souleater = {head="Ig. Burgeonet +3"}
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})

	-- Weapons sets
	sets.weapons.Foenaria = {main="Foenaria",sub="Dilet.'s Grip +1"}
	sets.weapons.Montante = {main="Montante +1",sub="Dilet.'s Grip +1"}
	sets.weapons.Naegling = {main="Naegling"}

	end

-- Select default macro book on initial load or subjob change.

function user_job_lockstyle()
	windower.chat.input('/lockstyleset 003')
end

function select_default_macro_book()
	-- Default macro set/book
	if player.sub_job == 'WAR' then
		set_macro_page(2, 15)
	elseif player.sub_job == 'SAM' then
		set_macro_page(3, 15)
	elseif player.sub_job == 'DNC' then
		set_macro_page(4, 15)
	elseif player.sub_job == 'THF' then
		set_macro_page(1, 15)
	else
		set_macro_page(5, 15)
	end
end
