function job_filter_precast(spell, spellMap, eventArgs)
	-- Auto Unbridled / Diffusion
	if spell.skill == 'Blue Magic' and unbridled_spells:contains(spell.english) and not (state.Buff['Unbridled Learning'] or state.Buff['Unbridled Wisdom']) then
		if (state.AutoUnbridled.value or buffup ~= '' or state.AutoBuffMode.value ~= 'Off') and (windower.ffxi.get_ability_recasts()[81] < latency and (windower.ffxi.get_spell_recasts()[spell.recast_id] / 60) < spell_latency) then
			eventArgs.cancel = true

			windower.chat.input('/ja "Unbridled Learning" <me>')

			if diffusion_spells:contains(spell.english) and not state.Buff.Diffusion and windower.ffxi.get_ability_recasts()[184] < latency then
				windower.chat.input:schedule(latency, '/ja "Diffusion" <me>')
			end

			windower.chat.input:schedule(1, '/ma "' .. spell.english .. '" ' .. spell.target.raw .. '')
			return
		else
			eventArgs.cancel = true
			add_to_chat(123, 'Abort: Unbridled Learning not active.')
			return
		end
	end

	-- Auto Diffusion
	if spell.skill == 'Blue Magic' and diffusion_spells:contains(spell.english) and not state.Buff.Diffusion and windower.ffxi.get_ability_recasts()[184] < latency then
		eventArgs.cancel = true
		windower.chat.input('/ja "Diffusion" <me>')
		windower.chat.input:schedule(1, '/ma "' .. spell.english .. '" ' .. spell.target.raw .. '')
		return
	end

	-- Auto Chain Affinity
	if spell.skill == 'Blue Magic' and chain_affinity_spells:contains(spell.english) then
		local ability_recasts = windower.ffxi.get_ability_recasts()

		if not state.Buff['Chain Affinity'] and not (ability_recasts[181] < latency) then
			eventArgs.cancel = true
			add_to_chat(123, 'Abort: Chain Affinity not ready.')
			return
		end

		local need_chain_affinity = not state.Buff['Chain Affinity'] and ability_recasts[181] < latency
		local need_efflux = not state.Buff.Efflux and ability_recasts[185] < latency

		if need_chain_affinity or need_efflux then
			eventArgs.cancel = true
			local delay = 0

			if need_chain_affinity then
				windower.chat.input('/ja "Chain Affinity" <me>')
				delay = delay + latency
			end

			if need_efflux then
				windower.chat.input:schedule(delay, '/ja "Efflux" <me>')
				delay = delay + latency
			end

			windower.chat.input:schedule(delay + 0.5, '/ma "' .. spell.english .. '" ' .. spell.target.raw .. '')
			return
		end
	end
end

-- Override the library's auto-buff check (Sel-Utility.lua) to also confirm we
-- have enough MP for the spell before attempting to cast it.
function check_buff()
	if state.AutoBuffMode.value ~= 'Off' and not data.areas.cities:contains(world.area) then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		local buff_list = buff_spell_lists[state.AutoBuffMode.value]

		for i in pairs(buff_list) do
			local buff_spell = buff_list[i]

			if not buffactive[buff_spell.Buff]
				and (buff_spell.When == 'Always'
					or (buff_spell.When == 'Combat' and in_combat)
					or (buff_spell.When == 'Engaged' and player.status == 'Engaged')
					or (buff_spell.When == 'Idle' and player.status == 'Idle')
					or (buff_spell.When == 'OutOfCombat' and not in_combat))
				and spell_recasts[buff_spell.SpellID] < spell_latency
				and silent_can_cast(buff_spell.Name)
				and actual_cost(buff_spell.SpellID) <= player.mp
				and (not unbridled_spells:contains(buff_spell.Name) or unbridled_ready()) then
				windower.chat.input('/ma "'..buff_spell.Name..'" <me>')
				add_tick_delay()
				return true
			end
		end
	else
		return false
	end
end

function character_user_job_setup()
	-- Options: Override default values
	state.OffenseMode:options('Fodder', 'Normal', 'Acc', 'FullAcc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc', 'FullAcc', 'Fodder')
	state.CastingMode:options('Normal', 'SIRD', 'Resistant', 'FullMacc', 'Fodder', 'Proc')
	state.IdleMode:options('Normal', 'Sphere', 'PDT', 'DTHippo')
	state.PhysicalDefenseMode:options('PDT')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.Weapons:options('Naegbron', 'Naegmace', 'MeleeClubs')

	state.ExtraMeleeMode = M { ['description'] = 'Extra Melee Mode', 'None', 'MP', 'SuppaBrutal', 'DWEarrings', 'DWMax' }

	-- Spells that should pop Diffusion before casting, if it's ready and not already up.
	diffusion_spells = S{'Mighty Guard'}

	-- Spells that should pop Chain Affinity and Efflux before casting, if they're ready and not already up.
	chain_affinity_spells = S{"Sinker Drill"}

	-- Abmbuscade capes
	gear.wsd_jse_back = { name = "Rosmerta's Cape", augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', } }
	gear.nuke_jse_back = { name = "Rosmerta's Cape", augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', '"Mag.Atk.Bns."+10', } }
	gear.da_jse_back = { name = "Rosmerta's Cape", augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Phys. dmg. taken-10%', } }
	--gear.stp_jse_back = { name = "Rosmerta's Cape", augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', } }
	--gear.crit_jse_back = { name = "Rosmerta's Cape", augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Crit.hit rate+10', } }

	-- AF
	gear.af_hands = "Assim. Bazu. +1"
	gear.af_body = "Assim. Jubbah +2"
	gear.af_legs = "Assim. Shalwar +1"
	gear.af_feet = "Assim. Charuqs +2"
	
	-- Relic
	gear.relic_head = "Luh. Keffiyeh +1"
	gear.relic_hands = "Luh. Bazubands +1"
	gear.relic_body = "Luhlaza Jubbah +1"
	gear.relic_legs = "Luhlaza Shalwar +2"
	gear.relic_feet = "Luhlaza Charuqs +1"

	-- Empyean
	gear.empy_Head = "Hashishin Kavuk"
	gear.empy_hands = "Hashi. Bazubands"
	gear.empy_body = "Hashishin Mintan"
	gear.empy_legs = "Hashishin Tayt +1"
	gear.empy_feet = "Hashishin Basmak"
	
	-- Other
	gear.AdhemarHands = { name = "Adhemar Wristbands", augments = { 'STR+10', 'DEX+10', 'Attack+15', } }
	gear.AdhemarHead = { name = "Adhemar Bonnet", augments = { 'STR+10', 'DEX+10', 'Attack+15', } }
	gear.AdhemarBody = { name = "Adhemar Jacket", augments = { 'STR+10', 'DEX+10', 'Attack+15', } }
	gear.DarkRing1 = { name = "Dark Ring", augments = { 'Phys. dmg. taken -3%', 'Spell interruption rate down -3%' } }
	gear.RecastGloves = { name = "Telchine Gloves", augments = { 'Haste +3' } }
	gear.CarmineCuisses = { name = "Carmine Cuisses +1", augments = { 'Accuracy+20', 'Attack+12', '"Dual Wield"+6' } }
	gear.herculean_ta_feet = { name = "Herculean Boots", augments = { 'Accuracy+21 Attack+21', '"Triple Atk."+2', 'Attack+10', } }
	gear.herculean_wsd_feet = { name = "Herculean Boots", augments = { 'Weapon skill damage +4%', 'Pet: Haste+3', 'Accuracy+5 Attack+5', } }
	gear.herculean_crit_feet = { name = "Herculean Boots", augments = { 'Accuracy+23 Attack+23', 'Crit. hit damage +1%', 'DEX+3', 'Accuracy+9', 'Attack+12', } }

	gear.BlueMagicSkill = {
		ammo = "Mavi Tathlum",
		head = "Luh. Keffiyeh +1",
		body = "Assim. Jubbah +2",
		feet = "Luhlaza Charuqs +1",
		legs = gear.empy_legs,
		left_ring = "Stikini Ring",
		right_ring = "Stikini Ring",
		back = { name = "Cornflower Cape", augments = { 'MP+29', 'DEX+1', 'Accuracy+3', 'Blue Magic skill +10', } },
	}


	autows = 'Savage Blade'
	trust_list = { "Joachim", "Qultada", "Yoran-Oran (UC)" }
	autows_list = {
		['Naegbron'] = 'Savage Blade',
		['Naegmace'] = {'Savage Blade', 2000},
		['MeleeClubs'] = 'Black Halo',
	}

	-- Additional local binds
	-- send_command('bind ^` input /ja "Chain Affinity" <me>')
	-- send_command('bind @` input /ja "Efflux" <me>')
	-- send_command('bind !` input /ja "Burst Affinity" <me>')
	-- send_command('bind ^@!` gs c cycle SkillchainMode')
	-- send_command(
	-- 'bind ^backspace input /ja "Unbridled Learning" <me>;wait 1;input /ja "Diffusion" <me>;wait 2;input /ma "Mighty Guard" <me>')
	-- send_command(
	-- 'bind !backspace input /ja "Unbridled Learning" <me>;wait 1;input /ja "Diffusion" <me>;wait 2;input /ma "Carcharian Verve" <me>')
	-- send_command('bind @backspace input /ja "Convergence" <me>')
	-- send_command('bind @f10 gs c toggle LearningMode')
	-- send_command('bind ^@!` gs c cycle MagicBurstMode')
	-- send_command('bind @f8 gs c toggle AutoNukeMode')

	select_default_macro_book()
end

function init_gear_sets()
	--------------------------------------
	-- Start defining the sets
	--------------------------------------

	sets.buff['Burst Affinity'] = { legs = gear.af_legs, feet = gear.empy_feet }
	sets.buff['Chain Affinity'] = { head=gear.empy_Head, feet = gear.af_feet }
	sets.buff.Convergence = { head = gear.relic_head }
	sets.buff.Diffusion = { feet = gear.relic_feet }
	sets.buff.Enchainment = { body = gear.relic_body }
	sets.buff.Efflux = { back = gear.da_jse_back, legs = gear.empy_legs }
	sets.buff.Doom = set_combine(sets.buff.Doom, {})

	sets.HPDown = {
		ear1 = "Mendicant's Earring",
		body = "Jhakri Robe +2",
		hands = "Jhakri Cuffs +2",
		back = "Swith Cape",
		waist = "Flume Belt",
		legs = "Jhakri Slops +2",
		feet = "Jhakri Pigaches +2"
	}

	sets.HPCure = {
		ammo = "Pemphredo Tathlum",
		ear1 = "Etiolation Earring",
		ear2 = "Mendi. Earring",
		hands = "Telchine Gloves",
		legs = gear.CarmineCuisses,
	}

	-- Precast Sets

	-- Precast sets to enhance JAs
	sets.precast.JA['Azure Lore'] = { hands = gear.relic_hands }

	-- Waltz set (chr and vit)
	sets.precast.Waltz = {
		waist = "Chaac Belt",
	}

	sets.Self_Waltz = { 
	}

	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}

	sets.precast.Step = {
		body = gear.af_body,
		hands = gear.af_hands,
		back = gear.da_jse_back,
		legs = gear.CarmineCuisses,
	}

	sets.precast.Flourish1 = {
	}

	-- Fast cast sets for spells

	sets.precast.FC = {
		ammo = "Impatiens",
		head = "Haruspex Hat",
		body = gear.relic_body,
		feet = "Chelona Boots",
		hands = "Thaumas Gloves",
		waist = "Witful Belt",
		right_ear = "Loquac. Earring",
		left_ring = "Weather. Ring",
		right_ring = "Prolix Ring",
		back = "Perimede Cape",
	}
	
	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, { 
	})

	sets.precast.FC['Blue Magic'] = set_combine(sets.precast.FC, { 
		body = gear.empy_body
	})

	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {
		ammo = "Oshasha's Treatise",
		head = "Jhakri Coronal +2",
		body = gear.af_body,
		hands = "Jhakri Cuffs +2",
		legs = gear.relic_legs,
		feet = gear.herculean_wsd_feet,
		neck = "Fotia Gorget",
		waist = "Fotia Belt",
		left_ear = "Steelflash Earring",
		right_ear = "Bladeborn Earring",
		left_ring = "Apate Ring",
		right_ring = "Rajas Ring",
		back = gear.wsd_jse_back,
	}

	sets.precast.WS.Acc = set_combine(sets.precast.WS, {

	})

	sets.precast.WS.FullAcc = set_combine(sets.precast.WS, {

	})

	sets.precast.WS.DT = set_combine(sets.precast.WS, {

	})

	sets.precast.WS.Fodder = set_combine(sets.precast.WS, {

	})

	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, { 

	})

	sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS.Acc, {
		
	})

	sets.precast.WS['Requiescat'].FullAcc = set_combine(sets.precast.WS.FullAcc, {

	})

	sets.precast.WS['Requiescat'].DT = set_combine(sets.precast.WS.DT, {

	})

	sets.precast.WS['Requiescat'].Fodder = set_combine(sets.precast.WS['Requiescat'], {

	})

	sets.precast.WS['Realmrazer'] = set_combine(sets.precast.WS, { 
		
	})

	sets.precast.WS['Realmrazer'].Acc = set_combine(sets.precast.WS.Acc, { 
		
	})

	sets.precast.WS['Realmrazer'].FullAcc = set_combine(sets.precast.WS.FullAcc, {

	})

	sets.precast.WS['Realmrazer'].DT = set_combine(sets.precast.WS.DT, {

	})

	sets.precast.WS['Realmrazer'].Fodder = set_combine(sets.precast.WS['Realmrazer'], {

	})

	sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, { 
		
	})

	sets.precast.WS['Chant du Cygne'].Acc = set_combine(sets.precast.WS.Acc, { 
		
	})
	
	sets.precast.WS['Chant du Cygne'].FullAcc = set_combine(sets.precast.WS.FullAcc, {

	})
	
	sets.precast.WS['Chant du Cygne'].DT = set_combine(sets.precast.WS.DT, { 
		
	})

	sets.precast.WS['Chant du Cygne'].Fodder = set_combine(sets.precast.WS['Chant du Cygne'], {

	})

	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, { 

	})

	sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS.Acc,{ 
		
	})

	sets.precast.WS['Savage Blade'].FullAcc = set_combine(sets.precast.WS.FullAcc, {

	})

	sets.precast.WS['Savage Blade'].DT = set_combine(sets.precast.WS.DT, { 
		
	})

	sets.precast.WS['Savage Blade'].Fodder = set_combine(sets.precast.WS['Savage Blade'], {

	})

	sets.precast.WS['Vorpal Blade'] = sets.precast.WS['Chant du Cygne']
	sets.precast.WS['Vorpal Blade'].Acc = sets.precast.WS['Chant du Cygne'].Acc
	sets.precast.WS['Vorpal Blade'].FullAcc = sets.precast.WS['Chant du Cygne'].FullAcc
	sets.precast.WS['Vorpal Blade'].DT = sets.precast.WS['Chant du Cygne'].DT
	sets.precast.WS['Vorpal Blade'].Fodder = sets.precast.WS['Chant du Cygne'].Fodder

	sets.precast.WS['Expiacion'] = set_combine(sets.precast.WS,	{ 
		
	})
	
	sets.precast.WS['Expiacion'].Acc = set_combine(sets.precast.WS.Acc,{

	})

	sets.precast.WS['Expiacion'].FullAcc = set_combine(sets.precast.WS.FullAcc,{

	})
	
	sets.precast.WS['Expiacion'].DT = set_combine(sets.precast.WS.DT, { 
		
	})
	
	sets.precast.WS['Expiacion'].Fodder = set_combine(sets.precast.WS['Expiacion'], {

	})

	sets.precast.WS['Sanguine Blade'] = {
		ammo = "Pemphredo Tathlum",
		head = "Jhakri Coronal +2",
		body = "Jhakri Robe +2",
		hands = "Jhakri Cuffs +2",
		legs = "Jhakri Slops +2",
		feet = "Jhakri Pigaches +2",
		neck = "Sanctity Necklace",
		waist = "Eschan Stone",
		left_ear = "Choleric Earring",
		right_ear = "Friomisi Earring",
		left_ring = "Stikini Ring",
		right_ring = "Stikini Ring",
		back = gear.nuke_jse_back
	}

	sets.precast.WS['Sanguine Blade'].DT = set_combine(sets.precast.WS.DT, { 
		back = gear.nuke_jse_back 
	})

	sets.precast.WS['Flash Nova'] = set_combine(sets.precast.WS['Sanguine Blade'], {
	})

	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = { 

	}
	sets.AccMaxTP = { 
	}

	-- Midcast Sets
	sets.midcast.FastRecast = set_combine(sets.precast.FC, {
		ammo = "Hasty Pinion",
		head = gear.relic_head,
		hands = gear.empy_hands,
		legs = "Aya. Cosciales +2",
	})

	sets.midcast['Blue Magic'] = {}

	-- Physical Spells --

	sets.midcast['Blue Magic'].Physical = set_combine(set_combine(sets.precast.WS, gear.BlueMagicSkill), {
		neck = "Sanctity Necklace",
		waist = "Eschan Stone"
	})

	sets.midcast['Blue Magic'].Physical.Resistant = set_combine(sets.midcast['Blue Magic'].Physical, {
		
	})

	sets.midcast['Blue Magic'].Physical.Fodder = set_combine(sets.midcast['Blue Magic'].Physical, {

	})

	sets.midcast['Blue Magic'].PhysicalAcc = set_combine(sets.midcast['Blue Magic'].Physical, {

	})

	sets.midcast['Blue Magic'].PhysicalAcc.Resistant = set_combine(sets.midcast['Blue Magic'].PhysicalAcc, {})
	sets.midcast['Blue Magic'].PhysicalAcc.Fodder = sets.midcast['Blue Magic'].Fodder

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

	-- Magical Spells --

	sets.midcast['Blue Magic'].Magical = {
		ammo = "Pemphredo Tathlum",
		head = "Jhakri Coronal +2",
		neck = "Sanctity Necklace",
		ear1 = "Choleric Earring",
		ear2 = "Friomisi Earring",
		body = "Jhakri Robe +2",
		hands = "Jhakri Cuffs +2",
		legs = "Jhakri Slops +2",
		ring1 = "Stikini Ring",
		ring2 = "Stikini Ring",
		back = gear.nuke_jse_back,
		waist = "Eschan Stone",
		feet = "Jhakri Pigaches +2"
	}

	sets.midcast['Blue Magic'].Magical.SIRD = set_combine(sets.midcast['Blue Magic'].Magical, {

	})

	sets.midcast['Blue Magic'].Subduction = set_combine(sets.midcast['Blue Magic'].Magical, {
		
	})

	sets.midcast['Blue Magic'].Magical.Proc = set_combine(sets.midcast['Blue Magic'].Magical, {
		
	})

	sets.midcast['Blue Magic'].Magical.Resistant = set_combine(sets.midcast['Blue Magic'].Magical, {
		
	})

	sets.midcast['Blue Magic'].Magical.Fodder = set_combine(sets.midcast['Blue Magic'].Magical, {
		
	})

	sets.midcast['Blue Magic'].MagicalMnd = set_combine(sets.midcast['Blue Magic'].Magical,  {

	})

	sets.midcast['Blue Magic'].MagicalChr = set_combine(sets.midcast['Blue Magic'].Magical, {

	})

	sets.midcast['Blue Magic'].MagicalVit = set_combine(sets.midcast['Blue Magic'].Magical, {

	})

	sets.midcast['Blue Magic'].MagicalDex = set_combine(sets.midcast['Blue Magic'].Magical, {
		
	})

	sets.midcast['Blue Magic'].MagicAccuracy = set_combine(sets.midcast['Blue Magic'].Magical, {

	})

	sets.midcast['Blue Magic'].Magical.FullMacc = sets.midcast['Blue Magic'].MagicAccuracy
	sets.midcast['Blue Magic'].Subduction.FullMacc = sets.midcast['Blue Magic'].MagicAccuracy


	sets.midcast.Cure = {
		ear2 = "Mendi. Earring",
		hands = "Telchine Gloves",
	}

	sets.midcast.UnlockedCure = set_combine(sets.midcast.Cure, {

	})

	sets.midcast.Cursna = set_combine(sets.midcast.Cure, {
	})

	-- Breath Spells --

	sets.midcast['Blue Magic'].Breath = set_combine(sets.midcast['Blue Magic'].Magical, gear.BlueMagicSkill)

	-- Physical Added Effect Spells most notably "Stun" spells --

	sets.midcast['Blue Magic'].Stun = set_combine(sets.midcast['Blue Magic'].Magical, gear.BlueMagicSkill)

	sets.midcast['Blue Magic'].Stun.Resistant = set_combine(sets.midcast['Blue Magic'].Stun, {

	})

	sets.midcast['Blue Magic'].Stun.Fodder = sets.midcast['Blue Magic'].Stun

	-- Other Specific Spells --

	sets.midcast['Blue Magic'].UnlockedAoEHealing = set_combine(sets.midcast.Cure, {

	})

	sets.midcast['Blue Magic'].AoEHealing = set_combine(sets.midcast.Cure, {

	})

	sets.midcast['Blue Magic'].Healing = set_combine(sets.midcast.Cure, {

	})

	sets.midcast['Blue Magic'].UnlockedHealing = set_combine(sets.midcast.Cure, {

	})

	sets.midcast['Blue Magic'].Buff = {
		hands = gear.empy_hands
	}

	sets.midcast['Blue Magic'].SkillBasedBuff = set_combine(sets.midcast['Blue Magic'].Buff, gear.BlueMagicSkill)

	sets.midcast['Blue Magic']['Battery Charge'] = set_combine(sets.midcast['Blue Magic'].Buff,	{ 
	})

	sets.midcast['Blue Magic']['Carcharian Verve'] = set_combine(sets.midcast['Blue Magic'].Buff, {
	})

	-- Sets to return to when not performing an action.

	sets.latent_refresh = { waist = "Fucho-no-obi" }
	sets.latent_refresh_grip = {}
	sets.DayIdle = {}
	sets.NightIdle = {}

	-- Gear for learning spells: +skill and AF hands.
	sets.Learning = { hands = gear.af_hands }

	-- Idle sets
	sets.idle = {
		main = "Naegling",
		sub = "Almace",
		ammo = "Mavi Tathlum",
		head = "Rawhide Mask",
		body = "Jhakri Robe +2",
		hands = "Serpentes Cuffs",
		legs = gear.relic_legs,
		feet = "Serpentes Sabots",
		neck = "Sibyl Scarf",
		waist = "Eschan Stone",
		left_ear = "Moonshade Earring",
		right_ear = "Etiolation Earring",
		left_ring = "Warden's Ring",
		right_ring = gear.DarkRing1,
		back = "Cornflower Cape",
	}

	sets.idle.Sphere = set_combine(sets.idle, {

	 })

	sets.idle.PDT = set_combine(sets.idle, {

	})

	sets.idle.DTHippo = set_combine(sets.idle.PDT, {

	})

	-- Resting sets
	sets.resting = set_combine(sets.idle, {
		main = "Chatoyant Staff",
		feet = "Chelona Boots"
	})

	-- Defense sets
	sets.defense.PDT = {
		
	}

	sets.defense.MDT = {
		
	}

	sets.defense.MEVA = {
		
	}

	sets.defense.NukeLock = sets.midcast['Blue Magic'].Magical

	sets.Kiting = { legs = "Carmine Cuisses +1" }

	-- Extra Melee sets.  Apply these on top of melee sets.
	sets.Knockback = {}
	sets.MP = {}
	sets.MP_Knockback = {}
	sets.SuppaBrutal = {} --{ ear1 = "Suppanomimi", ear2 = "Brutal Earring" }
	sets.DWEarrings = {} -- { ear1 = "Dudgeon Earring", ear2 = "Heartseeker Earring" }
	sets.DWMax = { 
		-- ear1 = "Dudgeon Earring", 
		-- ear2 = "Heartseeker Earring", 
		-- body = "Adhemar Jacket +1", 
		-- waist =	"Reiki Yotai", 
		-- legs = "Carmine Cuisses +1" 
	}
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})

	-- Weapons sets
	sets.weapons.Naegbron = {main = 'Naegling', sub = 'Machaera +2' }
	sets.weapons.Naegmace = { main = "Naegling", sub = "Almace" }
	sets.weapons.MeleeClubs = { main = "Kaja Rod", sub = "Nibiru Cudgel" }

	-- Engaged sets
	
	sets.engaged = {
		main = "Naegling",
		sub = "Almace",
		ammo = "Ginsen",
		head = gear.AdhemarHead,
		body = gear.AdhemarBody,
		hands = gear.AdhemarHands,
		legs = gear.CarmineCuisses,
		feet = gear.herculean_ta_feet,
		neck = "Asperity Necklace",
		waist = "Kentarch Belt +1",
		left_ear = "Bladeborn Earring",
		right_ear = "Steelflash Earring",
		left_ring = "Apate Ring",
		right_ring = "Rajas Ring",
		back = gear.da_jse_back
	}

	sets.engaged.AM = set_combine(sets.engaged, {

	})


	sets.engaged.Acc = set_combine(sets.engaged, {
		
	})

	sets.engaged.Acc.AM = set_combine(sets.engaged, {
		
	})

	sets.engaged.FullAcc =set_combine(sets.engaged, {
		
	})

	sets.engaged.FullAcc.AM = set_combine(sets.engaged, {
		
	})

	sets.engaged.Fodder = set_combine(sets.engaged, {
		
	})

	sets.engaged.Fodder.AM = set_combine(sets.engaged, {
		
	})

	sets.engaged.DT = set_combine(sets.engaged, {
		
	})

	sets.engaged.DT.AM = set_combine(sets.engaged, {
		
	})

	sets.engaged.Acc.DT = set_combine(sets.engaged, {
		
	})

	sets.engaged.Acc.DT.AM = set_combine(sets.engaged, {
		
	})

	sets.engaged.FullAcc.DT = set_combine(sets.engaged, {
		
	})

	sets.engaged.Fodder.DT = set_combine(sets.engaged, {
		
	})

	sets.engaged.Fodder.DT.AM = set_combine(sets.engaged, {
		
	})

	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {}
	sets.MagicBurst = {}
	sets.Phalanx_Received = {}
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	-- Default macro set/book
	local macro_pages = {
		WAR = 2,
		NIN = 3,
		DNC = 4,
		RDM = 3,
	}

	local page = macro_pages[player.sub_job] or 1
	set_macro_page(page, 2)

	windower.send_command('lua r xivcrossbar')
end

function user_job_lockstyle()
	local cmd = '/lockstyleset 025'

	if cmd then
		windower.send_command('du blinking self always off')
		windower.chat.input(cmd)
		windower.send_command('wait 5;du blinking self always on')
	end
end
