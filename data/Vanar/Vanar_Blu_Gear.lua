function character_user_job_setup()
	-- Options: Override default values
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

	--Picks the AzureSets spell set: AoE loads {sub}_mage and Melee loads {sub}_melee. Save these in AzureSets with //aset save <name>.
	--Cycle with: gs c cycle JobMode
	state.JobMode = M{['description']='Job Mode','AoE','Melee'}
	state.JobMode:set('Melee')

	--Weaponskills that get a buff from Auto WS Buff (User-Globals.lua) first.
	ws_buff_list = S{'Savage Blade','Expiacion','Chant du Cygne','Vorpal Blade','Black Halo','Requiescat','Realmrazer'}

	--Vanar's Rosmerta's Capes, named by their augments exactly as //gs export prints them. Vanar has no Store TP cape,
	--so the sets that wore one take the Double Attack or crit cape.
	gear.da_jse_back = {name="Rosmerta's Cape",augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%',}}
	gear.crit_jse_back = {name="Rosmerta's Cape",augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10',}}
	gear.wsd_jse_back = {name="Rosmerta's Cape",augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}}
	gear.nuke_jse_back = {name="Rosmerta's Cape",augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10',}}
	--Vanar holds two Colada and two Telchine Gloves, so these name the copy by its augments.
	gear.colada_refresh = {name="Colada",augments={'"Refresh"+2','Mag. Acc.+11','"Mag.Atk.Bns."+12','DMG:+1',}}
	gear.telchine_duration_hands = {name="Telchine Gloves",augments={'Haste+3','Enh. Mag. eff. dur. +10',}}

	-- Additional local binds
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

	--------------------------------------
	-- Start defining the sets
	--------------------------------------

	-- Every piece below is in Vanar's wardrobe or wardrobe 2 in data/export/Vanar 2026-10-08 01-37-10.lua. The sets
	-- were rebuilt from Mytha's, each for the same job, with the totals worked out from the pieces' help text, the
	-- export's augments, docs/gear-notes.md and data/Vanar/Vanar_rank_augments.md. None has been tried in game.
	-- Hashi. Earring +1 is always in the right ear, the only ear its skill bonuses and augments work in, so the Moonshade
	-- Earring sets put Moonshade in the left ear and sets.MaxTP swaps the left ear. At Master Level 25 a hand holding an
	-- item-level sword is past 600 sword skill, so Hashishin Kavuk +3's Sword skill 30 is about Acc 27 and Hashi. Earring
	-- +1's 11 about Acc 10, for that hand only.

	-- Chain Affinity, Burst Affinity, Diffusion and Efflux gear changes the next spell, so the engine adds these over the
	-- blue magic midcast set while the buff is up (BLU.lua, job_post_midcast).
	-- Burst Affinity: Hashi. Basmak +3 (+21). Mytha's set also wore the Shalwar, but Vanar's Assim. Shalwar +1 (+12, a
	-- WSC multiplier of 2.33 against 2.21) would take Hashishin Tayt +3's MAB 53, Macc 63 and skill 33, about 10% of the
	-- damage on that cast, and the fifth Hashishin piece, so the Tayt stays.
	sets.buff['Burst Affinity'] = {feet="Hashi. Basmak +3"}
	-- Chain Affinity: Hashishin Kavuk +3 (+28) and, as in Mytha's set, Assim. Charuqs +2 (+22), each adding to the
	-- spell's base damage on every hit, past its damage cap (gear-notes.md, Assim. Charuqs +2). The Charuqs take Hashi.
	-- Basmak +3's place, 15 less Acc and 32 less Att, and leave four Hashishin pieces: a 1% smaller chance of the
	-- quadrupled WSC, about 0.02 of the WSC a hit against the Charuqs' 22 (gear-notes.md, Hashishin set).
	sets.buff['Chain Affinity'] = {head="Hashishin Kavuk +3",feet="Assim. Charuqs +2"}
	-- Vanar has no Convergence merits, so this is never worn (Vanar_notes.md, Merits).
	sets.buff.Convergence = {head="Luh. Keffiyeh +1"}
	sets.buff.Diffusion = {feet="Luhlaza Charuqs +1"}	-- Diffusion duration +25% at Vanar's 5 merits, +45% with the merits' own 20%
	sets.buff.Enchainment = {}
	-- Efflux TP bonus: Hashishin Tayt +3 (+800). Every Rosmerta's Cape adds +250, and every physical set wears one but
	-- the Fodder set's Cornflower Cape.
	sets.buff.Efflux = {legs="Hashishin Tayt +3"}
	-- No Doom gear in the wardrobes. Vanar-Items.lua's Gishdubar Sash isn't Vanar's.
	sets.buff.Doom = {}

	-- Cure cheat (gs c curecheat, then Magic Fruit): the lowest maximum HP Vanar's wardrobes allow, HP 94 from gear.
	-- Magic Fruit then wears the Healing set below.
	sets.HPDown = {head="Wh. Rarab Cap +1",neck="Sibyl Scarf",ear1="Loquac. Earring",ear2="Andoaa Earring",
		body="Telchine Chas.",hands="Jhakri Cuffs +2",ring1="Murky Ring",ring2="Prolix Ring",
		back="Fi Follet Cape +1",waist="Fucho-no-Obi",legs="Enif Cosciales",feet="Chelona Boots"}

	-- Sel-Include.lua wears this only for a self-cast spell mapped to Cure after curecheat, and BLU.lua's own curecheat
	-- casts Magic Fruit (mapped to Healing), so on BLU it is never worn. Kept as the most HP with Cure potency to the
	-- cap: Bunzi's Rod (30, with the weapons free), Telchine Gloves (10), Solemnity Cape (7), Mendi. Earring (5) and
	-- Naji's Loop (1, and Cure potency II 1), Nyame elsewhere.
	sets.HPCure = {main="Bunzi's Rod",
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Mendi. Earring",
		body="Nyame Mail",hands=gear.telchine_duration_hands,ring1="Naji's Loop",ring2="Murky Ring",
		back="Solemnity Cape",waist="Eschan Stone",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	-- Precast Sets

	-- Precast sets to enhance JAs
	sets.precast.JA['Azure Lore'] = {hands="Luh. Bazubands +1"}	-- Azure Lore +10 s


	-- Waltz set (chr and vit). Gleti's Cuirass has Waltz potency +10%, the only piece Vanar carries with it. A DNC
	-- subjob's Waltz gets half the CHR and VIT term (ffxi-mechanics.md, Dancer abilities from a DNC subjob), so the
	-- rest is damage taken, as in the rahvin branch's BLU.lua: DT 52, PDT 13 and MDT 3.
	sets.precast.Waltz = {
		head="Hashishin Kavuk +3",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Gleti's Cuirass",hands="Hashi. Bazu. +3",ring1="Murky Ring",ring2="Ayanmo Ring",
		back=gear.da_jse_back,waist="Flume Belt",legs="Hashishin Tayt +3",feet="Nyame Sollerets"}

	-- No Passion Jacket or Asklepian Ring.
	sets.Self_Waltz = {}

	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}

	-- Steps land on melee hit rate: the most accurate set BLU carries, as the ACC engaged set below. Assim. Bazu. +3, as
	-- in Mytha's set, makes a two-piece Assimilator's set with the Jubbah, Acc +15 (gear-notes.md, Assimilator's set):
	-- Acc 48 + 15 and DEX 45 against Hashi. Bazu. +3's Acc 62 and DEX 43, about 2 more. The player's test in game showed
	-- the +4 Jubbah and the +3 Bazubands sharing the bonus (Vanar_gear_notes.md, Assimilator's set). Assim. Charuqs +2
	-- as a third piece comes out about even with Hashi. Basmak +3 (Acc 60, DEX 30), so the Basmak and its Att 60 stay.
	sets.precast.Step = {ammo="Honed Tathlum",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Assim. Bazu. +3",ring1="Lehko's Ring",ring2="Jhakri Ring",
		back=gear.da_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- Desperate and Violent Flourish have to hit, and Violent Flourish's stun lands on magic accuracy: the Step set with
	-- Ayanmo Ring (Acc and Macc 6) for Lehko's Ring, and Hashi. Bazu. +3 (Macc 62) back for the Assimilator's hands,
	-- whose set bonus gives only Macc 15.
	sets.precast.Flourish1 = set_combine(sets.precast.Step, {hands="Hashi. Bazu. +3",ring1="Ayanmo Ring"})

	-- Fast cast sets for spells
	-- Fast Cast 52 from armor, 56 with Colada while the weapons are free. BLU's own Fast Cast comes from set blue magic
	-- (5 to 25%) or /RDM (15%), so the set stays short of the 80% cap unless the spells give 25% and Colada is on.
	-- Witful Belt is the one Quick Magic piece the player keeps (Vanar_notes.md, Rules).
	sets.precast.FC = {main=gear.colada_refresh,
		head="Amalric Coif +1",ear1="Loquac. Earring",ear2="Etiolation Earring",
		body="Luhlaza Jubbah +1",hands="Pinga Mittens",ring1="Prolix Ring",ring2="Naji's Loop",
		back="Fi Follet Cape +1",waist="Witful Belt",legs="Enif Cosciales",feet="Chelona Boots"}

	-- No Passion Jacket.
	sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})

	-- Blue magic: Hashishin Mintan +3's Blue magic spellcasting time -16% for Luhlaza Jubbah +1's Fast Cast 7.
	sets.precast.FC['Blue Magic'] = set_combine(sets.precast.FC, {body="Hashishin Mintan +3"})


	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined, Black Halo among them: weapon skill
	-- damage on the first hit, after bg-wiki's simulated Savage Blade and Expiacion sets (All Jobs Gear Sets/Blue Mage)
	-- with Hashi. Earring +1 for Hoxne Earring and Karieyh Ring for Beithir Ring. Assim. Jubbah +4 over Nyame Mail: 2 more
	-- WSD, 20 more Acc and 25 more DEX for Att 55 and DA 3. With the spells' Accuracy Bonus IV, an estimate puts Black
	-- Halo with MeleeClubs (Maxentius, with Bunzi's Rod's Accuracy 40) at about 1365 with Grape Daifuku and 1359 with
	-- Oden in this set (Vanar_notes.md, Accuracy). That leaves room over the player's 1350 floor for the Nyame Gauntlets
	-- (WSD 8, Att 55 at rank 20) over Jhakri Cuffs +2, for 2 to 3 accuracy, but not for the Nyame Flanchard as well:
	-- its 10 less accuracy would put Oden at about 1349, so Luh. Shalwar +4 (Acc 50) stays.
	sets.precast.WS = {ammo="Coiste Bodhar",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Moonshade Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
		back=gear.wsd_jse_back,waist="Sailfi Belt +1",legs="Luh. Shalwar +4",feet="Nyame Sollerets"}

	-- Acc and FullAcc: the player's ACC-mode rule, the most accuracy each slot can take, ties going to damage. Vanar
	-- carries nothing more accurate, so both modes wear it. Jhakri Ring and Ayanmo Ring tie at Acc 6; Jhakri adds Att 6.
	-- Assim. Bazu. +3, as in Mytha's sets, for the Step set's reason: about 2 more accuracy with the Jubbah's set bonus.
	sets.precast.WS.Acc = {ammo="Honed Tathlum",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Assim. Bazu. +3",ring1="Lehko's Ring",ring2="Jhakri Ring",
		back=gear.da_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.precast.WS.FullAcc = set_combine(sets.precast.WS.Acc, {})

	-- A defense mode's weapon skill (the engine wears it only in a defense mode, in combat): all five Nyame pieces, DT 38
	-- and WSD 41 at Vanar's ranks, with Murky Ring and Alabaster Earring: DT 53.
	sets.precast.WS.DT = {ammo="Coiste Bodhar",
		head="Nyame Helm",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
		body="Nyame Mail",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Murky Ring",
		back=gear.wsd_jse_back,waist="Sailfi Belt +1",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	-- Fodder, the first offense mode and so the one in use by default (the weapon skill mode follows it). The player's
	-- 1350 floor doesn't hold in it (Vanar_notes.md, Rules for these sets), so the Nyame Flanchard goes in for Luh.
	-- Shalwar +4: about 1.2 to 1.4% more Black Halo at rank 17, on the calculation in Vanar_gear_notes.md (Nyame
	-- Flanchard), and more at rank 20 (WSD 9, Att 55, DA 3), for 10 accuracy. The other weapon skills' Fodder sets are their TP-mode sets, since nothing in those
	-- is there for the floor.
	sets.precast.WS.Fodder = set_combine(sets.precast.WS, {legs="Nyame Flanchard"})

	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
	-- Requiescat: five MND hits with fTP 1.0 each, so accuracy and attack on every hit and both Fotia pieces (+25/256 fTP,
	-- about 10% a hit each). Moonshade Earring's TP Bonus shrinks its attack penalty.
	sets.precast.WS['Requiescat'] = {ammo="Coiste Bodhar",
		head="Hashishin Kavuk +3",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Hashi. Earring +1",
		body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Lehko's Ring",ring2="Rajas Ring",
		back=gear.da_jse_back,waist="Fotia Belt",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}
	sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Requiescat'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	-- Murky Ring and Alabaster Earring with the Hashishin body, hands and legs: DT 55.
	sets.precast.WS['Requiescat'].DT = set_combine(sets.precast.WS['Requiescat'], {ear1="Alabaster Earring",ring2="Murky Ring"})
	sets.precast.WS['Requiescat'].Fodder = set_combine(sets.precast.WS['Requiescat'], {})

	-- Realmrazer (club, seven MND hits at fTP 0.9): the Requiescat sets. The sword skill on the Kavuk and the earring does
	-- nothing for a club hand, and Vanar has no better head or right ear for it.
	sets.precast.WS['Realmrazer'] = set_combine(sets.precast.WS['Requiescat'], {})
	sets.precast.WS['Realmrazer'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Realmrazer'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Realmrazer'].DT = set_combine(sets.precast.WS['Requiescat'].DT, {})
	sets.precast.WS['Realmrazer'].Fodder = set_combine(sets.precast.WS['Realmrazer'], {})

	-- Chant du Cygne: DEX and critical hit rate, which rises with TP, on three hits that replicate fTP. It follows
	-- bg-wiki's set, with Lehko's Ring for Begrudging Ring and Hashi. Earring +1 for Hoxne Earring. Hashishin Kavuk +3
	-- over Adhemar Bonnet: with its sword skill about Acc 88, Att 91 and WSD 12 on the first hit, against Att 41, TA 3
	-- and crit damage 5. The rank 0 Gleti's pieces keep their crit rate and PDL (Crit 25 and PDL 29 for the four).
	sets.precast.WS['Chant du Cygne'] = {ammo="Coiste Bodhar",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Moonshade Earring",ear2="Hashi. Earring +1",
		body="Gleti's Cuirass",hands="Gleti's Gauntlets",ring1="Lehko's Ring",ring2="Rajas Ring",
		back=gear.crit_jse_back,waist="Fotia Belt",legs="Gleti's Breeches",feet="Gleti's Boots"}
	sets.precast.WS['Chant du Cygne'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Chant du Cygne'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	-- The Hashishin body, hands and legs (DT 35) with Murky Ring, Alabaster Earring and the Double Attack cape: DT 55,
	-- keeping Gleti's Boots (Crit 4, PDT 5).
	sets.precast.WS['Chant du Cygne'].DT = set_combine(sets.precast.WS['Chant du Cygne'], {ear1="Alabaster Earring",
		body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring2="Murky Ring",back=gear.da_jse_back,legs="Hashishin Tayt +3"})
	sets.precast.WS['Chant du Cygne'].Fodder = set_combine(sets.precast.WS['Chant du Cygne'], {})

	-- Savage Blade (50% STR, 50% MND): the default set with the Nyame Gauntlets and Flanchard, both rank 20: WSD 8 and 9,
	-- Att 55 each and Double Attack 2 and 3, for 13 less accuracy than Jhakri Cuffs +2 and Luh. Shalwar +4. An estimate
	-- leaves it at about 1395 with Grape Daifuku and 1389 with Oden (Vanar_notes.md, Accuracy).
	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {hands="Nyame Gauntlets",legs="Nyame Flanchard"})
	sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Savage Blade'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Savage Blade'].DT = set_combine(sets.precast.WS.DT, {})
	sets.precast.WS['Savage Blade'].Fodder = set_combine(sets.precast.WS['Savage Blade'], {})

	sets.precast.WS['Vorpal Blade'] = sets.precast.WS['Chant du Cygne']
	sets.precast.WS['Vorpal Blade'].Acc = sets.precast.WS['Chant du Cygne'].Acc
	sets.precast.WS['Vorpal Blade'].FullAcc = sets.precast.WS['Chant du Cygne'].FullAcc
	sets.precast.WS['Vorpal Blade'].DT = sets.precast.WS['Chant du Cygne'].DT
	sets.precast.WS['Vorpal Blade'].Fodder = sets.precast.WS['Chant du Cygne'].Fodder

	-- Expiacion: as Savage Blade. At rank 20 the Nyame Gauntlets beat Jhakri Cuffs +2 here too, by about 0.6 to 0.7%,
	-- for 2 less accuracy (Vanar_gear_notes.md, Nyame Gauntlets): about 1391 with Grape Daifuku and 1385 with Oden.
	sets.precast.WS['Expiacion'] = set_combine(sets.precast.WS, {hands="Nyame Gauntlets",legs="Nyame Flanchard"})
	sets.precast.WS['Expiacion'].Acc = set_combine(sets.precast.WS.Acc, {})
	sets.precast.WS['Expiacion'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
	sets.precast.WS['Expiacion'].DT = set_combine(sets.precast.WS.DT, {})
	sets.precast.WS['Expiacion'].Fodder = set_combine(sets.precast.WS['Expiacion'], {})

	-- Sanguine Blade: magical (dark, 50% MND and 30% STR, INT x 2 with no cap), so MAB, Magic Damage and weapon skill
	-- damage, which counts on the whole hit. TP doesn't raise its damage, so Friomisi Earring (MAB 10) for Moonshade.
	-- The STR weapon skill damage cape over the INT one, WSD 10 and STR 30 against INT 20, Magic Damage 20 and MAB 10:
	-- about 2% more damage by an estimate (wsdist's base stats, a target with INT 290), for 30 less magic accuracy.
	-- Karieyh Ring's WSD 3 beats Jhakri Ring's MAB 3 by about 1%.
	sets.precast.WS['Sanguine Blade'] = {ammo="Pemphredo Tathlum",
		head="Hashishin Kavuk +3",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Hashi. Earring +1",
		body="Nyame Mail",hands="Jhakri Cuffs +2",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
		back=gear.wsd_jse_back,waist="Eschan Stone",legs="Luh. Shalwar +4",feet="Hashi. Basmak +3"}

	-- A defense mode's Sanguine Blade: the five Nyame pieces (DT 38, MAB 30 each), Murky Ring and Alabaster Earring: DT 53.
	sets.precast.WS['Sanguine Blade'].DT = set_combine(sets.precast.WS.DT, {ammo="Pemphredo Tathlum",neck="Sanctity Necklace",waist="Eschan Stone"})

	-- Flash Nova (club, light, 50% STR and 50% MND, fTP 3.0 at any TP): the Sanguine Blade set with Fotia Belt, since it
	-- has a skillchain property (+25/256 fTP, and its Accuracy 10 counts as magic accuracy here).
	sets.precast.WS['Flash Nova'] = set_combine(sets.precast.WS['Sanguine Blade'], {waist="Fotia Belt"})

	-- (Repeats the line above Flash Nova.)
	sets.precast.WS['Sanguine Blade'].DT = set_combine(sets.precast.WS.DT, {ammo="Pemphredo Tathlum",neck="Sanctity Necklace",waist="Eschan Stone"})

	-- Acc and FullAcc for the two magical weapon skills: the ACC rule's most accuracy is magic accuracy here, since
	-- accuracy does nothing for them (Vanar_notes.md, Rules for these sets). The Hashishin +3 body, hands and legs (Macc
	-- 62 to 64), Mirage Stole +2 (25), Alabaster Earring (2), both Stikini Rings (8) and the INT cape (30) join the
	-- Kavuk, Basmak, Hashi. Earring +1 and Pemphredo Tathlum. Sanguine Blade keeps Eschan Stone (7); Flash Nova keeps
	-- Fotia Belt, whose Accuracy 10 counts as magic accuracy on a weapon skill with a skillchain property. Blue magic
	-- skill does nothing for weapon skills. The Assimilator's pieces' set bonus (Macc 15 or 30) is less than the
	-- Hashishin pieces' own.
	sets.precast.WS['Sanguine Blade'].Acc = set_combine(sets.precast.WS['Sanguine Blade'], {neck="Mirage Stole +2",ear1="Alabaster Earring",
		body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",back=gear.nuke_jse_back,legs="Hashishin Tayt +3"})
	sets.precast.WS['Sanguine Blade'].FullAcc = set_combine(sets.precast.WS['Sanguine Blade'].Acc, {})
	sets.precast.WS['Flash Nova'].Acc = set_combine(sets.precast.WS['Sanguine Blade'].Acc, {waist="Fotia Belt"})
	sets.precast.WS['Flash Nova'].FullAcc = set_combine(sets.precast.WS['Flash Nova'].Acc, {})

	-- Swap to these on Moonshade using WS if at 3000 TP. BLU.lua swaps them in once the TP, Moonshade's 250 counted,
	-- passes 3200. Moonshade is in the left ear in every set above.
	sets.MaxTP = {ear1="Brutal Earring"}	-- DA 5
	sets.AccMaxTP = {ear1="Alabaster Earring"}	-- Acc 2

	-- Midcast Sets
	-- Worn under every spell's midcast set (Sel-Include.lua, filter_midcast), and the set for fixed-potency buffs. Recast
	-- falls with gear haste, which caps at 26% as listed, half of Fast Cast, and Blue magic recast. Haste 32 (cap 26),
	-- Fast Cast 46 and Hashi. Bazu. +3's Blue magic recast -16%. It names no weapons, so a spell with none of its own keeps
	-- the ones in hand.
	sets.midcast.FastRecast = {ammo="Hasty Pinion",
		head="Amalric Coif +1",ear1="Loquac. Earring",ear2="Etiolation Earring",
		body="Luhlaza Jubbah +1",hands="Hashi. Bazu. +3",ring1="Prolix Ring",ring2="Lehko's Ring",
		back="Fi Follet Cape +1",waist="Witful Belt",legs="Enif Cosciales",feet="Chelona Boots"}

	sets.midcast['Blue Magic'] = {}

	-- Physical Spells --

	-- Physical spells: accuracy and attack, and the STR cape. Physical damage also rises with an item-level main hand,
	-- so with the weapons free Tizona and Almace go on. Hashishin Kavuk +3 adds Chain Affinity +28 and Hashishin Tayt +3
	-- Efflux +800, and five Hashishin pieces occasionally augment the spell (gear-notes.md, Hashishin set). bg-wiki
	-- doesn't say weapon skill damage, Double Attack or the gorgets apply to blue magic, so no piece is here for them.
	sets.midcast['Blue Magic'].Physical = {main="Tizona",sub="Almace",ammo="Coiste Bodhar",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Moonshade Earring",ear2="Hashi. Earring +1",
		body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Jhakri Ring",ring2="Ayanmo Ring",
		back=gear.wsd_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- Hit chance first: the ACC engaged set's pieces, with the weapons above. Hashi. Bazu. +3 stays here (Mytha's set
	-- had other hands): Att 62 and a fourth Hashishin piece against the Assimilator's hands' 2 or so more accuracy.
	sets.midcast['Blue Magic'].Physical.Resistant = {main="Tizona",sub="Almace",ammo="Honed Tathlum",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Hashi. Bazu. +3",ring1="Jhakri Ring",ring2="Lehko's Ring",
		back=gear.da_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- Fodder: Blue magic skill, which raises a physical spell's base damage up to its cap: 635 skill from 485, against
	-- 549 in the Physical set.
	sets.midcast['Blue Magic'].Physical.Fodder = {main="Tizona",sub="Almace",ammo="Mavi Tathlum",
		head="Luh. Keffiyeh +1",neck="Mirage Stole +2",ear1="Njordr Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back="Cornflower Cape",waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Luhlaza Charuqs +1"}

	-- Heavy Strike's accuracy penalty: the accuracy set.
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

	-- Magical Spells --

	-- Magical spells: MAB and magic accuracy, with Blue magic skill adding to magic accuracy one for one. MAB raises their
	-- damage, so the player's nuke rule holds here too: Sanctity Necklace (Macc 10, MAB 10) and Eschan Stone (Macc 7, MAB
	-- 7) keep the neck and waist (Vanar_notes.md, Rules for these sets). The Hashishin +3 armor (Macc 60 to 64, MAB 51
	-- to 57), Hashi. Earring +1 (Macc 12, skill 11) and the Stikini Rings fill the rest. Hashishin Tayt +3 over Luh.
	-- Shalwar +4 (MAB 60): 7 less MAB, but 13 more Macc, skill 33 and the fifth Hashishin piece, and damage within a few
	-- percent either way depending on the spell's stat. The Stikini Rings over Jhakri Ring: its MAB 3 is about 0.6%
	-- against 7 more magic accuracy a ring. With the weapons free, Bunzi's Rod (Macc 40 and Magic Accuracy skill 255, MAB
	-- 35) and Maxentius (Macc 40, MAB 21); Maxentius's burst bonus only works in the main hand. Vanar has no elemental obi.
	sets.midcast['Blue Magic'].Magical = {main="Bunzi's Rod",sub="Maxentius",ammo="Pemphredo Tathlum",
		 head="Hashishin Kavuk +3",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Hashi. Earring +1",
		 body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		 back=gear.nuke_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- Spell interruption: Assim. Shalwar +1 (20), Rumination Sash (10) and Murky Ring (3) make 33%, far from the 102%
	-- that stops interruption. Vanar has no SIRD merits recorded. The Shalwar matches Carmine Cuisses +1's 20 with 4 more
	-- INT and Burst Affinity +12; neither has MAB or magic accuracy. The sash takes Eschan Stone's place, the one break
	-- from the nuke rule, since this mode is for not being interrupted.
	sets.midcast['Blue Magic'].Magical.SIRD = set_combine(sets.midcast['Blue Magic'].Magical, {legs="Assim. Shalwar +1",waist="Rumination Sash",ring1="Murky Ring"})

	sets.midcast['Blue Magic'].Subduction = set_combine(sets.midcast['Blue Magic'].Magical, {})

	-- Proc mode: the spell has to land but not kill, so the fast recast set, which has no MAB.
	sets.midcast['Blue Magic'].Magical.Proc = set_combine(sets.midcast.FastRecast, {})

	-- Resistant, the magic accuracy mode: Mirage Stole +2 (Macc 25, skill 20) for Sanctity Necklace and Njordr Earring
	-- (skill 10) for Friomisi Earring (MAB 10), as RDM's resistant nuke set gives up its nuke neck and waist.
	sets.midcast['Blue Magic'].Magical.Resistant = set_combine(sets.midcast['Blue Magic'].Magical, {neck="Mirage Stole +2",ear1="Njordr Earring"})

	-- Fodder: damage over magic accuracy: Luh. Shalwar +4 (MAB 60, against the Tayt's 53 and skill 33). The neck stays
	-- Sanctity Necklace by the nuke rule.
	sets.midcast['Blue Magic'].Magical.Fodder = set_combine(sets.midcast['Blue Magic'].Magical, {legs="Luh. Shalwar +4"})

	-- The Stikini Rings' MND is already in the set.
	sets.midcast['Blue Magic'].MagicalMnd = set_combine(sets.midcast['Blue Magic'].Magical, {})
	sets.midcast['Blue Magic'].MagicalChr = set_combine(sets.midcast['Blue Magic'].Magical, {})
	sets.midcast['Blue Magic'].MagicalVit = set_combine(sets.midcast['Blue Magic'].Magical, {})
	sets.midcast['Blue Magic'].MagicalDex = set_combine(sets.midcast['Blue Magic'].Magical, {})
	-- Crashing Thunder, BLU.lua's one MagicalAgi spell. Without this set it got only the fast recast set.
	sets.midcast['Blue Magic'].MagicalAgi = set_combine(sets.midcast['Blue Magic'].Magical, {})

	-- Debuffs that only have to land: the most magic accuracy and Blue magic skill. Tizona in the main hand has Macc 70
	-- at rank 15 and Magic Accuracy skill 255, 30 more than Bunzi's Rod. Assim. Jubbah +4 (Macc 60, skill 25) and Njordr
	-- Earring (skill 10) go in.
	sets.midcast['Blue Magic'].MagicAccuracy = {main="Tizona",sub="Bunzi's Rod",ammo="Pemphredo Tathlum",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Njordr Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.nuke_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.midcast['Blue Magic'].Magical.FullMacc = sets.midcast['Blue Magic'].MagicAccuracy
	sets.midcast['Blue Magic'].Subduction.FullMacc = sets.midcast['Blue Magic'].MagicAccuracy

	-- Enfeebles from a subjob: the magic accuracy set, where Blue magic skill does nothing, so Hashishin Mintan +3 (Macc
	-- 64), Alabaster Earring (Macc 2) and Rumination Sash (Macc 3, Enfeebling skill 7) take its place.
	sets.midcast['Enfeebling Magic'] = {main="Tizona",sub="Bunzi's Rod",ammo="Pemphredo Tathlum",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
		body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.nuke_jse_back,waist="Rumination Sash",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- Dark magic from a subjob: Eschan Stone (Macc 7) for the sash, whose skill is enfeebling only.
	sets.midcast['Dark Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {waist="Eschan Stone"})

	-- Enhancing magic from a subjob: duration from the three Telchine pieces (augmented 10% each), over the fast recast
	-- set. BLU can't wear Vanar's other duration pieces, Embla Sash and Ghostfyre Cape.
	sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.FastRecast, {head="Telchine Cap",hands=gear.telchine_duration_hands,legs="Telchine Braconi"})

	-- A subjob's enhancing skill is far below the 500 where Phalanx stops gaining, so every skill piece: +87. Vanar has no
	-- Phalanx+ gear (Taeon, Herculean or Sakpata's).
	sets.midcast['Phalanx'] = set_combine(sets.midcast['Enhancing Magic'],{main="Pukulatmuj +1",neck="Enhancing Torque",ear1="Mimir Earring",ear2="Andoaa Earring",body="Telchine Chas.",ring1="Stikini Ring",ring2="Stikini Ring",back="Fi Follet Cape +1",waist="Olympus Sash",legs="Carmine Cuisses +1"})

	sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {head="Amalric Coif +1"})	-- Refresh potency +2

	-- Amalric Coif +1's Aquaveil +2. No Regal Cuffs, Emphatikos Rope or Shedir Seraweels.
	sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {head="Amalric Coif +1"})

	-- Stoneskin from a subjob: Siegel Sash's Stoneskin +20. No Earthcry Earring or Shedir Seraweels.
	sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {waist="Siegel Sash"})

	-- Barspells rise with skill up to 500, far past a subjob's, so the skill set. No Shedir Seraweels.
	sets.midcast.BarElement = set_combine(sets.midcast['Phalanx'], {})

	-- No Sheltered Ring.
	sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {})
	sets.midcast.Protectra = set_combine(sets.midcast['Enhancing Magic'], {})
	sets.midcast.Shell = set_combine(sets.midcast['Enhancing Magic'], {})
	sets.midcast.Shellra = set_combine(sets.midcast['Enhancing Magic'], {})

	-- Divine magic from a subjob: the dark magic set's magic accuracy.
	sets.midcast['Divine Magic'] = set_combine(sets.midcast['Dark Magic'], {})

	-- Elemental magic from a subjob: the blue magic nuke set's pieces, Sanctity Necklace and Eschan Stone included.
	-- Hashishin Tayt +3's Blue magic skill does nothing here; it stays for Macc 63 and INT 48 against Luh. Shalwar +4's
	-- Macc 50, INT 43 and MAB 60 (53 on the Tayt).
	sets.midcast['Elemental Magic'] = {main="Bunzi's Rod",sub="Maxentius",ammo="Pemphredo Tathlum",
		head="Hashishin Kavuk +3",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Hashi. Earring +1",
		body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.nuke_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {neck="Mirage Stole +2"})	-- Macc 25

	sets.midcast.Helix = sets.midcast['Elemental Magic']
	sets.midcast.Helix.Resistant = sets.midcast['Elemental Magic'].Resistant

	-- No Pixie Hairpin +1 or Archon Ring.
	sets.element.Dark = {}
	sets.element.Light = {} --ring2="Weatherspoon Ring"

	-- Cures from a subjob. Cure 23 from armor, and 53 with Bunzi's Rod while the weapons are free (cap 50): Telchine Gloves
	-- (10), Solemnity Cape (7), Mendi. Earring (5) and Naji's Loop (1, and Cure potency II 1). The Hashishin pieces add MND,
	-- and with Alabaster Earring, Murky Ring and the cape the set has DT 44, and PDT 4 more from Flume Belt.
	sets.midcast.Cure = {main="Bunzi's Rod",sub="Maxentius",
		head="Hashishin Kavuk +3",ear1="Alabaster Earring",ear2="Mendi. Earring",
		body="Hashishin Mintan +3",hands=gear.telchine_duration_hands,ring1="Naji's Loop",ring2="Murky Ring",
		back="Solemnity Cape",waist="Flume Belt",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- Not read by the engine (BLU.lua names UnlockedHealing and UnlockedAoEHealing only); kept as the Cure set.
	sets.midcast.UnlockedCure = set_combine(sets.midcast.Cure, {})

	-- Cursna from a WHM subjob: its chance rises with Healing magic skill, so the fast recast set with Carmine Cuisses +1
	-- (Healing 18). Vanar has no Cursna gear BLU can wear.
	sets.midcast.Cursna =  set_combine(sets.midcast.FastRecast, {legs="Carmine Cuisses +1"})

	-- Breath Spells --

	-- Breath damage comes from current HP, which midcast HP gear doesn't raise (ffxi-mechanics.md, Breath blue magic), so
	-- the magic accuracy set for landing, with Mavi Tathlum (breath +5%) and Luh. Keffiyeh +1 (breath +20%, skill 13).
	sets.midcast['Blue Magic'].Breath = {ammo="Mavi Tathlum",
		head="Luh. Keffiyeh +1",neck="Mirage Stole +2",ear1="Njordr Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back=gear.nuke_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- Physical Added Effect Spells most notably "Stun" spells --

	-- The hit needs accuracy and the stun magic accuracy and skill: the Hashishin +3 armor carries both, Assim. Jubbah +4
	-- adds skill 25 and DEX 49, and Cornflower Cape (Macc 15, skill 15) matches the INT cape's Macc 30 with Acc 3.
	sets.midcast['Blue Magic'].Stun = {main="Tizona",sub="Bunzi's Rod",ammo="Pemphredo Tathlum",
		head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Njordr Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back="Cornflower Cape",waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- More accuracy for the hit: Honed Tathlum (Acc 15), Jhakri and Ayanmo Rings (Acc and Macc 6 each) and the Double
	-- Attack cape (Acc 30).
	sets.midcast['Blue Magic'].Stun.Resistant = set_combine(sets.midcast['Blue Magic'].Stun, {ammo="Honed Tathlum",ring1="Jhakri Ring",ring2="Ayanmo Ring",back=gear.da_jse_back})

	sets.midcast['Blue Magic'].Stun.Fodder = sets.midcast['Blue Magic'].Stun

	-- Other Specific Spells --

	-- White Wind heals from maximum HP, raised by Cure potency (ffxi-mechanics.md, Blue magic healing), so four Nyame
	-- pieces (HP 409), Sanctity Necklace (35), Alabaster Earring (100) and Eschan Stone (20). With the weapons free,
	-- Bunzi's Rod's Cure 30 takes the Cure part to 48, and Etiolation Earring's HP 50 beats Mendi. Earring past that,
	-- by about 0.5% (the rahvin branch's BLU.lua). BLU.lua also wears these for Healing Breeze on yourself, which heals
	-- by MND and VIT and Cure potency, not HP.
	sets.midcast['Blue Magic'].UnlockedAoEHealing = {main="Bunzi's Rod",
		head="Nyame Helm",neck="Sanctity Necklace",ear1="Alabaster Earring",ear2="Etiolation Earring",
		body="Nyame Mail",hands=gear.telchine_duration_hands,ring1="Naji's Loop",ring2="Murky Ring",
		back="Solemnity Cape",waist="Eschan Stone",legs="Nyame Flanchard",feet="Nyame Sollerets"}

	-- With the weapons locked the Cure part is only 18, so Mendi. Earring's Cure 5 is worth more than HP 50 (about 2%).
	sets.midcast['Blue Magic'].AoEHealing = set_combine(sets.midcast['Blue Magic'].UnlockedAoEHealing, {ear2="Mendi. Earring"})

	-- Magic Fruit and the other cure-formula heals: 3 x MND + VIT, with Cure potency on top; Blue magic skill does
	-- nothing for them (ffxi-mechanics.md, Blue magic healing). Cure 23, and 53 with Bunzi's Rod (cap 50). Restoral is
	-- on the same list in BLU.lua, so it wears this set too, though its heal also rises with Blue magic skill.
	sets.midcast['Blue Magic'].Healing = {main="Bunzi's Rod",
		head="Hashishin Kavuk +3",ear1="Alabaster Earring",ear2="Mendi. Earring",
		body="Hashishin Mintan +3",hands=gear.telchine_duration_hands,ring1="Naji's Loop",ring2="Stikini Ring",
		back="Solemnity Cape",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.midcast['Blue Magic'].UnlockedHealing = set_combine(sets.midcast['Blue Magic'].Healing, {})

	-- BLU.lua's skill-based buffs (Diamondhide, Magic Barrier, Occultation, Plasma Charge, Reactor Cool): Blue magic
	-- skill 635 from 485. Vanar's Iris isn't in the wardrobes. Metallic Body, which also rises with skill to 500, is on
	-- BLU.lua's Buff list, so it wears the fast recast set.
	sets.midcast['Blue Magic'].SkillBasedBuff = {ammo="Mavi Tathlum",
		head="Luh. Keffiyeh +1",neck="Mirage Stole +2",ear1="Njordr Earring",ear2="Hashi. Earring +1",
		body="Assim. Jubbah +4",hands="Hashi. Bazu. +3",ring1="Stikini Ring",ring2="Stikini Ring",
		back="Cornflower Cape",waist="Witful Belt",legs="Hashishin Tayt +3",feet="Luhlaza Charuqs +1"}

	-- Fixed-potency buffs gain nothing from potency gear: the fast recast set.
	sets.midcast['Blue Magic'].Buff = set_combine(sets.midcast.FastRecast, {})

	-- Battery Charge is a Refresh you cast, so Amalric Coif +1's Refresh potency +2 raises it. No Grapevine Cape or
	-- Gishdubar Sash.
	sets.midcast['Blue Magic']['Battery Charge'] = set_combine(sets.midcast['Blue Magic'].Buff, {head="Amalric Coif +1"})

	-- Carcharian Verve's Aquaveil: Amalric Coif +1's Aquaveil +2.
	sets.midcast['Blue Magic']['Carcharian Verve'] = set_combine(sets.midcast['Blue Magic'].Buff, {head="Amalric Coif +1"})

	-- Sets to return to when not performing an action.

	sets.latent_refresh = {waist="Fucho-no-Obi"}
	-- No staff or grip in the wardrobes.
	sets.latent_refresh_grip = {}
	sets.DayIdle = {}
	sets.NightIdle = {}

	-- Gear for learning spells: +skill and AF hands.
	sets.Learning = {hands="Assim. Bazu. +3"}	-- Chance to learn Blue magic +16

	-- Resting sets: the idle set with Chelona Boots (MP recovered while healing +5) and Fucho-no-Obi, whose latent
	-- Refresh works below about half MP.
	sets.resting = {main=gear.colada_refresh,ammo="Pemphredo Tathlum",
			      head="Rawhide Mask",neck="Sibyl Scarf",ear1="Alabaster Earring", ear2="Etiolation Earring",
			      body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Karieyh Ring",ring2="Murky Ring",
			      back=gear.da_jse_back,waist="Fucho-no-Obi",legs="Hashishin Tayt +3",feet="Chelona Boots"}

	-- Idle sets. Passive Refresh first (the player's rule): Rawhide Mask (1), Hashishin Mintan +3 (4), Sibyl Scarf (1 for
	-- a citizen of Windurst), and Colada (2) with the weapons free: Refresh 6, or 8. Karieyh Ring's Regain 5 builds TP
	-- while idle. The other slots carry damage taken: DT 55, PDT 4 and MDT 3, each way past the cap.
	sets.idle = {main=gear.colada_refresh,ammo="Pemphredo Tathlum",
			      head="Rawhide Mask",neck="Sibyl Scarf",ear1="Alabaster Earring", ear2="Etiolation Earring",
			      body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Karieyh Ring",ring2="Murky Ring",
			      back=gear.da_jse_back,waist="Flume Belt",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- No Mekosuchinae Harness.
	sets.idle.Sphere = set_combine(sets.idle, {})

	-- The idle set already caps physical and magic damage taken, and BLU can't block, so PDT idle is the same set.
	sets.idle.PDT = set_combine(sets.idle, {})

	-- Moving: Carmine Cuisses +1 (18%) takes the Tayt's DT 12, so Nyame Helm (7) and Ayanmo Ring (3) put it back: DT 53.
	-- No Hippomenes Socks.
	sets.idle.DTHippo = set_combine(sets.idle.PDT, {head="Nyame Helm",ring1="Ayanmo Ring",legs="Carmine Cuisses +1"})

	-- Defense sets
	-- These go over the engaged set too, so PDT keeps the TP set's accuracy pieces: DT 55, PDT 4.
	sets.defense.PDT = {ammo="Coiste Bodhar",
				head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
		        body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Lehko's Ring",ring2="Murky Ring",
				back=gear.da_jse_back,waist="Flume Belt",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- Magic: DT 58 with MDT 3, and the five Hashishin pieces' Magic Def. Bonus 48.
	sets.defense.MDT = {ammo="Pemphredo Tathlum",
				head="Hashishin Kavuk +3",neck="Sibyl Scarf",ear1="Alabaster Earring",ear2="Etiolation Earring",
		        body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Ayanmo Ring",ring2="Murky Ring",
				back=gear.da_jse_back,waist="Flume Belt",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	-- Magic evasion with DT capped: Nyame Gauntlets (Magic Evasion 112, DT 7) for the Bazubands (87, DT 10). Magic evasion
	-- 692 from armor, DT 55 with MDT 3.
    sets.defense.MEVA = set_combine(sets.defense.MDT, {hands="Nyame Gauntlets"})

	sets.defense.NukeLock = sets.midcast['Blue Magic'].Magical

	sets.Kiting = {legs="Carmine Cuisses +1"}	-- Movement speed 18%

    -- Extra Melee sets.  Apply these on top of melee sets.
    sets.Knockback = {}
	-- Flume Belt converts 2% of damage taken to MP. No Suppanomimi or Ethereal Earring.
    sets.MP = {waist="Flume Belt"}
    sets.MP_Knockback = {}
	-- No Suppanomimi, Dudgeon or Heartseeker Earring, Adhemar Jacket +1 or Reiki Yotai in the wardrobes. Brutal Earring
	-- stays in the left ear, since Hashi. Earring +1 works only in the right.
	sets.SuppaBrutal = {ear1="Brutal Earring"}
	sets.DWEarrings = {}
	sets.DWMax = {legs="Carmine Cuisses +1"}	-- Dual Wield 6
	-- Treasure Hunter 4, the cap off THF: Wh. Rarab Cap +1 (1), Volte Jupon (2) and Chaac Belt (1). It replaces the Volte
	-- Cap and Volte Bracers that Vanar-Items.lua names, which Vanar doesn't own.
	sets.TreasureHunter = {head="Wh. Rarab Cap +1",body="Volte Jupon",waist="Chaac Belt"}

	-- Weapons sets. Vanar's Nehushtan and Iris are in the Mog Locker, not the wardrobes, and he has no Sequence or
	-- Vampirism, so the modes that named them take the nearest pair he carries.
	sets.weapons['Tizona Acc'] = {main="Tizona",sub="Almace"}
	sets.weapons['Tizona'] = {main="Tizona",sub="Thibron"}
	-- Two clubs for Black Halo and Realmrazer: Bunzi's Rod (Acc 40) for Nehushtan.
	sets.weapons.MeleeClubs = {main="Maxentius",sub="Bunzi's Rod"}
	-- Chant du Cygne: Thibron's TP Bonus +1000 for Sequence.
	sets.weapons.Almace = {main="Almace",sub="Thibron"}
	sets.weapons['Savage Blade'] = {main="Naegling",sub="Thibron"}
	sets.weapons['Savage Blade Acc'] = {main="Naegling",sub="Almace"}
	sets.weapons.MaccWeapons = {main="Tizona",sub="Bunzi's Rod"}
	-- Sanguine Blade: Naegling (Magic Damage 217, MAB 16) with Bunzi's Rod (MAB 35, Macc 40) for the Vampirism pair.
	sets.weapons.HybridWeapons = {main="Naegling",sub="Bunzi's Rod"}

	-- Engaged sets

	-- Damage first, as long as main-hand accuracy reaches 1350 from gear and food (the player's rule). Vanar's rahvin TP
	-- set: the Hashishin +3 armor (Acc and Att 61 to 64), Nyame Sollerets (DA 2 at rank 20), Mirage Stole +2, Sailfi Belt
	-- +1, Brutal Earring, Hashi. Earring +1, Lehko's Ring (Store TP 10, Crit 10), Rajas Ring and the Double Attack cape.
	-- With the spells' Accuracy Bonus IV, an estimate puts it at 1481 to 1485 with Tizona or Naegling and Thibron on
	-- Grape Daifuku, 6 less on Oden, and about 1445 with MeleeClubs (Vanar_notes.md, Accuracy). With a weapon mode on,
	-- the weapons are locked and the Tizona and Almace named here do nothing; they go on only with Weapons at None, as
	-- in Mytha's sets.
	sets.engaged = {main="Tizona",sub="Almace",ammo="Coiste Bodhar",
			    head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Brutal Earring",ear2="Hashi. Earring +1",
			    body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Lehko's Ring",ring2="Rajas Ring",
			    back=gear.da_jse_back,waist="Sailfi Belt +1",legs="Hashishin Tayt +3",feet="Nyame Sollerets"}

	-- Under Tizona's Aftermath level 3 (the engine's AM group): its "attacks twice or thrice" is checked after Double
	-- Attack, so a Double Attack proc takes its place and DA is worth about a fifth of its usual value (ffxi-mechanics.md,
	-- Multi-attack). The crit cape (Crit 10, DEX 30) for the DA cape and Hashi. Basmak +3 (Acc and Att 60) for Nyame
	-- Sollerets.
	sets.engaged.AM = set_combine(sets.engaged, {back=gear.crit_jse_back,feet="Hashi. Basmak +3"})


	-- Acc and FullAcc: the player's ACC-mode rule, the most accuracy each slot can take, ties going to damage. Vanar
	-- carries nothing more accurate, so both modes wear it, Aftermath or not. Assim. Jubbah +4 has 4 less accuracy than
	-- Hashishin Mintan +3 but 15 more DEX, about 7 more in all. Assim. Bazu. +3, as in Mytha's FullAcc set, for the Step
	-- set's reason: about 2 more accuracy with the Jubbah's set bonus.
	sets.engaged.Acc = {main="Tizona",sub="Almace",ammo="Honed Tathlum",
				head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Alabaster Earring",ear2="Hashi. Earring +1",
				body="Assim. Jubbah +4",hands="Assim. Bazu. +3",ring1="Lehko's Ring",ring2="Jhakri Ring",
				back=gear.da_jse_back,waist="Eschan Stone",legs="Hashishin Tayt +3",feet="Hashi. Basmak +3"}

	sets.engaged.Acc.AM = set_combine(sets.engaged.Acc, {})

	sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {})

	sets.engaged.FullAcc.AM = set_combine(sets.engaged.Acc, {})

	-- Fodder: the 1350 floor doesn't hold here, but the TP set leaves nothing out for it, so these are the TP sets.
	sets.engaged.Fodder = set_combine(sets.engaged, {})

	sets.engaged.Fodder.AM = set_combine(sets.engaged.AM, {})

	-- Damage taken to the cap first: the Hashishin body, hands and legs, Nyame Sollerets, the cape and Murky Ring for Rajas
	-- Ring give DT 57. Kentarch Belt +1 keeps 14 more accuracy than the TP set's Sailfi Belt +1.
	sets.engaged.DT = {main="Tizona",sub="Almace",ammo="Coiste Bodhar",
			    head="Hashishin Kavuk +3",neck="Mirage Stole +2",ear1="Brutal Earring",ear2="Hashi. Earring +1",
			    body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring1="Lehko's Ring",ring2="Murky Ring",
			    back=gear.da_jse_back,waist="Kentarch Belt +1",legs="Hashishin Tayt +3",feet="Nyame Sollerets"}

	-- Aftermath: the crit cape for the DA cape still leaves DT 52.
	sets.engaged.DT.AM = set_combine(sets.engaged.DT, {back=gear.crit_jse_back})

	-- The ACC set with Hashishin Mintan +3 (DT 13) for the Jubbah, Hashi. Bazu. +3 (DT 10) for the Assimilator's hands,
	-- which lose their set bonus without the Jubbah, and Murky Ring for Jhakri Ring: DT 55, for about 16 of the ACC
	-- set's accuracy.
	sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, {body="Hashishin Mintan +3",hands="Hashi. Bazu. +3",ring2="Murky Ring"})

	sets.engaged.Acc.DT.AM = set_combine(sets.engaged.Acc.DT, {})

	sets.engaged.FullAcc.DT = set_combine(sets.engaged.Acc.DT, {})

	sets.engaged.Fodder.DT = set_combine(sets.engaged.DT, {})

	sets.engaged.Fodder.DT.AM = set_combine(sets.engaged.DT.AM, {})

	-- Cure received, Refresh received and Phalanx received gear: Vanar carries none (no Phalaina Locket, Buremte Gloves,
	-- Kunaji Ring, Gishdubar Sash, Grapevine Cape or Herculean Phalanx pieces).
	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {}
	-- Magic burst, over the magical set: Jhakri Ring (Magic burst damage 2, MAB 3) for a Stikini Ring, with Hashi. Basmak
	-- +3's 15 and, with the weapons free, Bunzi's Rod's 10: 17, or 27 (cap 40). BLU can't wear Vanar's Ea Houppelande
	-- or Mizu. Kubikazari, and a Nyame piece's burst damage 5 to 7 costs 21 to 27 MAB and 20 or more magic accuracy
	-- against the Hashishin piece it would replace.
	sets.MagicBurst = {ring1="Jhakri Ring"}
	sets.Phalanx_Received = {}
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	-- Default macro set/book
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

--Auto WS choices for each weapon mode in state.Weapons, by its name there. Moonshade Earring's TP Bonus +250,
--which the weapon skill sets wear, turns 1750 into 2000 and 2750 into 3000, the cap. With Thibron's TP Bonus +1000
--in the offhand, 1750 already reaches the cap, so those modes stop at 1750. 'AM2' and 'AM3' build that Aftermath
--level first, then fire at 1000 while it lasts. Each mode takes the choices of the rahvin branch's BLU.lua mode with
--the same pair: Almace its Chant du Cygne mode (Almace and Thibron), MeleeClubs its Black Halo Acc mode (Maxentius
--and Bunzi's Rod). That file had no Naegling and Bunzi's Rod mode, so HybridWeapons takes the rahvin RDM.lua choice
--for that pair: Sanguine Blade, whose damage TP doesn't raise. None has no entry.
AutoWS_List = {
	['Tizona'] = { { 'Expiacion', 1000 }, { 'Expiacion', 1750 }, { 'Expiacion', 'AM2' }, { 'Expiacion', 'AM3' } },
	['Tizona Acc'] = { { 'Expiacion', 1000 }, { 'Expiacion', 1750 }, { 'Expiacion', 2750 }, { 'Expiacion', 'AM2' }, { 'Expiacion', 'AM3' } },
	['Almace'] = { { 'Chant du Cygne', 1000 }, { 'Chant du Cygne', 1750 } },
	['MeleeClubs'] = { { 'Black Halo', 1000 }, { 'Black Halo', 1750 }, { 'Black Halo', 2750 } },
	['HybridWeapons'] = { { 'Sanguine Blade', 1000 } },
	['Savage Blade'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 } },
	['Savage Blade Acc'] = { { 'Savage Blade', 1000 }, { 'Savage Blade', 1750 }, { 'Savage Blade', 2750 } },
}

--Auto Unbridled Learning, Diffusion, Chain Affinity and Efflux, ported from the rahvin branch's BLU.lua.
--Blue magic that needs Unbridled Learning or Unbridled Wisdom up before it can be cast: the 18 spells that take no set points.
local Unbridled_Spells = S{'Absolute Terror','Bilgestorm','Blistering Roar','Bloodrake','Carcharian Verve',
	'Cesspool','Crashing Thunder','Cruel Joke','Droning Whirlwind','Gates of Hades','Harden Shell',
	'Mighty Guard','Polar Roar','Pyric Bulwark','Tearing Gust','Thunderbolt','Tourbillion','Uproot'}

--Blue magic that uses Diffusion first, when it is ready and not already up, so the buff reaches the party.
local Diffusion_Spells = S{'Mighty Guard','Harden Shell'}

--Physical blue magic that needs Chain Affinity up or ready (the spell is dropped otherwise), and that also
--uses Efflux first when it is ready and not already up.
local Chain_Affinity_Spells = S{'Sinker Drill'}

--The spell sent again after its abilities, set as that send goes out so it alone passes untouched, and the
--os.clock() time until which other blue magic presses are dropped while the abilities go up.
local blu_refire, blu_lock_until = nil, 0
--The last time Unbridled Learning was reported not ready, so a cast AutoBuffMode retries prints it once every 30 seconds at most.
local unbridled_abort_said = nil

--A spell from the lists above that needs one of the abilities is dropped, the abilities go up 1.1 seconds
--apart, and the spell is sent again 1.1 seconds after them. That second send always passes, whether or not
--the abilities landed, so this never loops. Runs ahead of BLU.lua's own Unbridled check in job_filter_precast.
function user_job_filter_precast(spell, spellMap, eventArgs)
	if spell.type ~= 'BlueMagic' then return end
	--Silenced, the spell would fail after its abilities went up and onto their recasts, so none is used.
	if buffactive['Silence'] or buffactive['Mute'] or buffactive['Omerta'] then return end
	--Under Amnesia or Impairment the abilities themselves fail. A Chain Affinity spell without Chain Affinity up
	--is still dropped, as it is when Chain Affinity isn't ready; anything else goes ahead without its abilities.
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
	--rahvin's busy gate: mid-action, the first ability would be refused.
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

--AzureSets auto-load and the Dual Wield re-check, ported from the rahvin branch's BLU.lua.

--The AzureSets save file, read to learn which spell sets exist.
local azure_settings_path = windower.windower_path..'addons/AzureSets/data/settings.xml'

--Each queued load takes a new request number, and a scheduled load or retry for an older number does nothing.
--Changing main job to BLU loads this file and may also change the subjob, and this keeps that to one //aset command.
local azure_request = 0

--Whether the job traits include Dual Wield (trait 18) now, from the subjob or from set blue magic.
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

--Watches Dual Wield each second for a minute after //aset spellset, while AzureSets sets the spells one at a time.
--Set blue magic grants or removes the trait, and Sel only rereads it on a load or subjob change. Each change seen
--here updates Sel's can_dual_wield and its weapons, then the gear. The first check does the same, since the trait
--may have changed since Sel last read it. During an action the rebuild is left to the one the action ends with.
local function watch_dual_wield(request, had, checks)
	if request ~= azure_request or checks > 60 then return end
	local has = has_dual_wield()
	if has ~= had then
		set_dual_wield()
		if not midaction() then send_command('gs c update') end
	end
	watch_dual_wield:schedule(1, request, has, checks + 1)
end

--Loads the AzureSets spell set for the subjob and job mode: {sub}_mage in AoE mode, {sub}_melee in Melee mode.
--A missing {sub}_mage falls back to {sub}_melee. For a subjob other than NIN, a missing {sub}_melee falls back to
--war_melee, whose blue magic gives Dual Wield from traits; NIN brings the trait itself. With no subjob it loads
--war_melee. Each miss is warned in chat. After a job change the game sends the blue magic spell list late, and
--AzureSets errors without it, so it retries each second for up to ten tries.
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

--Global, since character_user_job_setup above calls it.
function queue_azure_set(delay)
	azure_request = azure_request + 1
	load_azure_set:schedule(delay, azure_request)
end

--Waits for the game to finish the change, because a main job change also fires this while this file is still loaded.
function user_job_sub_job_change(newSubjob, oldSubjob)
	queue_azure_set(5)
end

function user_job_state_change(stateField, newValue, oldValue)
	if stateField == 'Job Mode' then queue_azure_set(0) end
end

--Retires any spell set load or Dual Wield watch still scheduled, so none runs after this file is gone.
function user_job_unload()
	azure_request = azure_request + 1
end