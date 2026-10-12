-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function character_user_job_setup()
	-- Options: Override default values
	state.OffenseMode:options('Normal','Acc')
	state.HybridMode:options('Normal','DT')
	state.RangedMode:options('Normal', 'Acc')
	state.WeaponskillMode:options('Match','Acc')
	state.IdleMode:options('Normal','Refresh')
	state.PhysicalDefenseMode:options('PDT')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.Weapons:options('Naegling','Tauret')

	--Weaponskills that get a buff from Auto WS Buff (User-Globals.lua) first.
	ws_buff_list = S{'Evisceration'}

	state.ExtraMeleeMode = M{['description']='Extra Melee Mode','None','Suppa','DWMax','Parry'}
	state.AmbushMode = M(false, 'Ambush Mode')

	-- Additional local binds
	send_command('bind ^` input /ja "Flee" <me>')
	send_command('bind !` input /ra <t>')
	send_command('bind @` gs c cycle SkillchainMode')
	send_command('bind ^backspace input /item "Thief\'s Tools" <t>')
	send_command('bind !backspace input /ja "Hide" <me>')
	send_command('bind ^\\\\ input /ja "Despoil" <t>')
	send_command('bind !\\\\ input /ja "Mug" <t>')

	select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
	--------------------------------------
	-- Special sets (required by rules)
	--------------------------------------

	sets.TreasureHunter = {head="Wh. Rarab Cap +1",body="Volte Jupon",waist="Chaac Belt"}
	sets.Kiting = {}

	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {}
	
	sets.buff['Sneak Attack'] = {}
	sets.buff['Trick Attack'] = {}

	-- Extra Melee sets.  Apply these on top of melee sets.
	sets.Knockback = {}
	sets.Suppa = {}
	sets.DWEarrings = {}
	sets.DWMax = {}
	sets.Ambush = {}
	
	-- Weapons sets
	sets.weapons.Naegling = {main="Naegling",sub="Gleti's Knife"}
	sets.weapons.Tauret = {main="Tauret",sub="Gleti's Knife"}

	sets.precast.Step = {ammo="Honed Tathlum",
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Skulk. Earring +1",
		body="Gleti's Cuirass",hands="Nyame Gauntlets",ring1="Lehko's Ring",ring2="Rajas Ring",
		back={name="Toutatis's Cape",augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','Crit.hit rate+10'}},waist="Eschan Stone",legs="Nyame Flanchard",feet="Gleti's Boots"}

	sets.precast.JA['Violent Flourish'] = {ammo="Honed Tathlum",
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Skulk. Earring +1",
		body="Gleti's Cuirass",hands="Nyame Gauntlets",ring1="Lehko's Ring",ring2="Rajas Ring",
		back={name="Toutatis's Cape",augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','Crit.hit rate+10'}},waist="Eschan Stone",legs="Nyame Flanchard",feet="Gleti's Boots"}
		
	sets.precast.JA['Animated Flourish'] = sets.TreasureHunter
	sets.precast.JA.Provoke = sets.TreasureHunter

	--------------------------------------
	-- Precast sets
	--------------------------------------

	-- Precast sets to enhance JAs
	sets.precast.JA['Collaborator'] = {}
	sets.precast.JA['Accomplice'] = {}
	sets.precast.JA['Flee'] = {} 
	sets.precast.JA['Hide'] = {}
	sets.precast.JA['Conspirator'] = {} 
	sets.precast.JA['Steal'] = {}
	sets.precast.JA['Mug'] = {}
	sets.precast.JA['Despoil'] = {}
	sets.precast.JA['Perfect Dodge'] = {}
	sets.precast.JA['Feint'] = {} 

	sets.precast.JA['Sneak Attack'] = sets.buff['Sneak Attack']
	sets.precast.JA['Trick Attack'] = sets.buff['Trick Attack']

	-- Waltz set (chr and vit)
	sets.precast.Waltz = {
		head="Nyame Helm",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Gleti's Cuirass",hands="Nyame Gauntlets",ring2="Murky Ring",
		back="Solemnity Cape",waist="Flume Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	sets.Self_Waltz = {}
		
	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}


	-- Fast cast sets for spells
	sets.precast.FC = {ear1="Etiolation Earring",ear2="Loquac. Earring",
		ring1="Prolix Ring",ring2="Naji's Loop",legs="Enif Cosciales"}

	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})


	-- Ranged snapshot gear
	sets.precast.RA = {}


	-- Weaponskill sets

	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {ammo="Honed Tathlum",
		head="Nyame Helm",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Skulk. Earring +1",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Lehko's Ring",ring2="Epaminondas's Ring",
		back={name="Toutatis's Cape",augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','Crit.hit rate+10'}},waist="Eschan Stone",legs="Nyame Flanchard",feet="Nyame Sollerets"}
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {ear1="Alabaster Earring",body="Gleti's Cuirass",ring2="Karieyh Ring",feet="Gleti's Boots"})

	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	sets.precast.WS["Rudra's Storm"] = set_combine(sets.precast.WS, {})
	sets.precast.WS["Rudra's Storm"].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS["Rudra's Storm"].SA = set_combine(sets.precast.WS["Rudra's Storm"], {})
	sets.precast.WS["Rudra's Storm"].TA = sets.precast.WS["Rudra's Storm"].SA
	sets.precast.WS["Rudra's Storm"].SATA = sets.precast.WS["Rudra's Storm"].SA
	
	sets.precast.WS["Evisceration"] = set_combine(sets.precast.WS, {body="Gleti's Cuirass",hands="Gleti's Gauntlets",ring2="Karieyh Ring",waist="Fotia Belt",legs="Gleti's Breeches",feet="Gleti's Boots"})
	sets.precast.WS["Evisceration"].Acc = set_combine(sets.precast.WS.Acc, {hands="Gleti's Gauntlets",legs="Gleti's Breeches"})
	sets.precast.WS["Evisceration"].SA = set_combine(sets.precast.WS["Rudra's Storm"], {})
	sets.precast.WS["Evisceration"].TA = sets.precast.WS["Rudra's Storm"].SA
	sets.precast.WS["Evisceration"].SATA = sets.precast.WS["Rudra's Storm"].SA

	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {ear1="Alabaster Earring",body="Gleti's Cuirass",ring2="Karieyh Ring",feet="Gleti's Boots"})

	sets.precast.WS['Last Stand'] = sets.precast.WS
	sets.precast.WS['Empyreal Arrow'] = sets.precast.WS['Last Stand']
		
	sets.precast.WS['Aeolian Edge'] = sets.precast.WS
	sets.precast.WS['Aeolian Edge'].TH = set_combine(sets.precast.WS['Aeolian Edge'], sets.TreasureHunter)

	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {ear1="Alabaster Earring"}
	sets.AccMaxTP = {ear1="Alabaster Earring"}

	--------------------------------------
	-- Midcast sets
	--------------------------------------

	sets.midcast.FastRecast = {
		head="Nyame Helm",ear1="Alabaster Earring",ear2="Loquac. Earring",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Prolix Ring",ring2="Murky Ring",
		back="Solemnity Cape",waist="Sailfi Belt +1",legs="Enif Cosciales",feet="Nyame Sollerets"}

	-- Specific spells
	sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {})

	sets.midcast.Dia = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
	sets.midcast.Diaga = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
	sets.midcast['Dia II'] = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
	sets.midcast.Bio = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)
	sets.midcast['Bio II'] = set_combine(sets.midcast.FastRecast, sets.TreasureHunter)

	-- Ranged gear

	sets.midcast.RA = {
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Lehko's Ring",ring2="Murky Ring",
		back="Solemnity Cape",waist="Eschan Stone",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	sets.midcast.RA.Acc = {
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Lehko's Ring",ring2="Murky Ring",
		back="Solemnity Cape",waist="Eschan Stone",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	--------------------------------------
	-- Idle/resting/defense sets
	--------------------------------------

	-- Resting sets
	sets.resting = {head="Rawhide Mask",neck="Sibyl Scarf"}

	sets.HPDown = {ammo="Pemphredo Tathlum",
		head="Wh. Rarab Cap +1",neck="Sibyl Scarf",ear1="Loquac. Earring",ear2="Andoaa Earring",
		body=empty,hands=empty,ring1="Prolix Ring",ring2="Murky Ring",
		back="Solemnity Cape",waist="Flume Belt",legs=empty,feet=empty}
	
	sets.HPMax = {
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Nyame Mail",hands="Nyame Gauntlets",
		waist="Eschan Stone",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	-- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)

	sets.idle = {
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Karieyh Ring",ring2="Murky Ring",
		back="Solemnity Cape",waist="Flume Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	sets.idle.Refresh = {
		head="Rawhide Mask",neck="Sibyl Scarf",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Karieyh Ring",ring2="Murky Ring",
		back="Solemnity Cape",waist="Flume Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}
		
	sets.idle.Sphere = set_combine(sets.idle, {})

	sets.idle.Weak = set_combine(sets.idle, {})

	-- Defense sets

	sets.defense.PDT = {
		head="Nyame Helm",ear1="Alabaster Earring",
		body="Nyame Mail",hands="Nyame Gauntlets",ring2="Murky Ring",
		back="Solemnity Cape",waist="Flume Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	sets.defense.MDT = {
		head="Nyame Helm",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Nyame Mail",hands="Gleti's Gauntlets",ring2="Murky Ring",
		back="Solemnity Cape",legs="Nyame Flanchard",feet="Nyame Sollerets"}
		
	sets.defense.MEVA = {
		head="Nyame Helm",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Nyame Mail",hands="Nyame Gauntlets",ring2="Murky Ring",
		back="Solemnity Cape",legs="Nyame Flanchard",feet="Nyame Sollerets"}


	--------------------------------------
	-- Melee sets  
	--------------------------------------

	-- Normal melee group
	sets.engaged = {ammo="Honed Tathlum",
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Skulk. Earring +1",
		body="Gleti's Cuirass",hands="Nyame Gauntlets",ring1="Lehko's Ring",ring2="Murky Ring",
		back={name="Toutatis's Cape",augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','Crit.hit rate+10'}},waist="Eschan Stone",legs="Nyame Flanchard",feet="Gleti's Boots"}
		
	sets.engaged.Acc = {ammo="Honed Tathlum",
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Skulk. Earring +1",
		body="Gleti's Cuirass",hands="Gleti's Gauntlets",ring1="Lehko's Ring",ring2="Rajas Ring",
		back={name="Toutatis's Cape",augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','Crit.hit rate+10'}},waist="Eschan Stone",legs="Gleti's Breeches",feet="Gleti's Boots"}

	sets.engaged.DT = {ammo="Honed Tathlum",
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Skulk. Earring +1",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Lehko's Ring",ring2="Murky Ring",
		back={name="Toutatis's Cape",augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','Crit.hit rate+10'}},waist="Eschan Stone",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	sets.engaged.Acc.DT = {ammo="Honed Tathlum",
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Skulk. Earring +1",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Lehko's Ring",ring2="Murky Ring",
		back={name="Toutatis's Cape",augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','Crit.hit rate+10'}},waist="Eschan Stone",legs="Nyame Flanchard",feet="Nyame Sollerets"}
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	-- Default macro set/book
	if player.sub_job == 'DNC' then
		set_macro_page(1, 5)
	elseif player.sub_job == 'WHM' then
		set_macro_page(5, 5)
	end
end

function user_job_lockstyle()
	if player.equipment.main == nil or player.equipment.main == 'empty' then
		windower.chat.input('/lockstyleset 001')
	elseif res.items[get_item_id_by_name(player.equipment.main)].skill == 3 then --Sword in main hand.
		if player.equipment.sub == nil or player.equipment.sub == 'empty' then --Sword/Nothing.
				windower.chat.input('/lockstyleset 007')
		elseif res.items[get_item_id_by_name(player.equipment.sub)].skill == 2 then --Sword/Dagger.
			windower.chat.input('/lockstyleset 007')
		else
			windower.chat.input('/lockstyleset 007') --Catchall just in case something's weird.
		end
	elseif res.items[get_item_id_by_name(player.equipment.main)].skill == 2 then --Dagger in main hand.
		if player.equipment.sub == nil or player.equipment.sub == 'empty' then --Dagger/Nothing.
			windower.chat.input('/lockstyleset 008')
		elseif res.items[get_item_id_by_name(player.equipment.sub)].skill == 2 then --Dagger/Dagger.
			windower.chat.input('/lockstyleset 008')
		else
			windower.chat.input('/lockstyleset 008') --Catchall just in case something's weird.
		end
	end
end

--Moonshade Earring's TP Bonus +250, which the weapon skill set wears, turns 1750 into 2000 and 2750 into
--3000, the cap. Evisceration's critical hit rate rises with TP.
AutoWS_List = {
	['Naegling'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 }, { 'Savage Blade', 2750 } },
	['Tauret'] = { { 'Evisceration', 1000 }, { 'Evisceration', 1750 }, { 'Evisceration', 2750 } },
}