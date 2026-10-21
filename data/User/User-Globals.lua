--Place for your settings and custom functions that are meant to affect all of your jobs and characters.
latency = .5
--If this is set to true it will prevent you from casting shadows when you have more up than that spell would generate.
conserveshadows = true
--Display related settings.

--Options for automation.
state.ReEquip 		  		= M(true, 'ReEquip Mode')		 --Set this to false if you don't want to equip your current Weapon set when you aren't wearing any weapons.
state.AutoArts 		  		= M(false, 'AutoArts') 		 --Set this to true to keep up Composure, Arts, Solace and the like automatically.
state.AutoLockstyle	 	    = M(true, 'AutoLockstyle Mode') --Set this to false if you don't want gearswap to automatically lockstyle on load and weapon change.
state.CancelStoneskin 		= M(true, 'Cancel Stone Skin') --Set this to false if you don't want to automatically cancel stoneskin when you're slept.
state.SkipProcWeapons 		= M(false, 'Skip Proc Weapons') --Set this to true to skip Proc weapon sets when cycling Weapons, outside a Proc WeaponSets group.
state.NotifyBuffs	  		= M(false, 'Notify Buffs') 	 --Set this to true if you want to notify your party when you recieve a specific buff/debuff. (List Below)
state.TreasureMode:set('Tag') --Sel-TreasureHunter only defaults THF to Tag; this makes every job start in Tag.
state.AutoWSBuff			= M(true, 'Auto WS Buff') --Set this to false if you don't want a ready WAR/DRK buff used before each weaponskill. Toggle: gs c toggle AutoWSBuff
state.AutoWS				= M{['description']='Auto WS', 'OFF'} --Options are rebuilt from AutoWS_List for the current weapon set; don't call :options() on it.
state.AutoXP				= M(false, 'Auto XP') --Pulls and fights nearby monsters by itself, from the gear file's AutoXP_Settings. Toggle: gs c toggle AutoXP

--[[Binds you may want to change.
	Bind special characters.
	@ = Windows Key
	% = Works only when text bar not up.
	$ = Works only when text bar is up.
	^ = Control Key
	! = Alt Key
	~ = Shift Key
	# = Apps Key
]]
food_lists = {
	Attack = 'Grape Daifuku',
	Oden = 'Oden',
}
state.AutoFoodMode = M{['description'] = 'Auto Food Mode','Off','Attack','Oden'}
trust_lists = {
	Default = {'Yoran-Oran (UC)','Koru-Moru','Qultada','Ulmia','Joachim'},
	Limbus = {'Yoran-Oran (UC)','Qultada','Ulmia'},
}
state.AutoTrustMode = M{['description'] = 'Auto Trust Mode','Off','Default','Limbus'}
send_command('bind f6 gs c cycle AutoTrustMode') --Cycles through Off and the trust_lists entries, summoning that list's trusts automatically.
send_command('bind f7 gs c set DefenseMode Physical') --Turns your physical defense set on.
send_command('bind ^f7 gs c cycle PhysicalDefenseMode') --Changes your physical defense set.
send_command('bind !f7 gs c set DefenseMode Resist') --Turns your resist defense set on.
send_command('bind ^!f7 gs c cycle ResistDefenseMode') --Changes your resist defense set.
send_command('bind f9 gs c cycle AutoWS') --Cycles auto-ws through OFF and the current weapon's AutoWS_List choices.
send_command('bind ^f9 gs c cycle Weapons') --Cycle through weapons sets.
send_command('bind !f9 gs c toggle UnlockWeapons') --Lets sets change main and sub out of combat; while engaged they stay put.
send_command('bind @f9 gs c cycle RangedMode') --Changes ranged offense settings such as accuracy.
send_command('bind f10 gs c cycle AutoBuffMode') --Automatically keeps certain buffs up, job-dependant.
send_command('bind ^f10 gs c cycle AutoFoodMode') --Turns auto-food mode on and off.
send_command('bind !f10 gs c toggle AutoStunMode') --Turns auto-stun mode off and on.
send_command('bind ^!f10 gs c toggle AutoNukeMode') --Turns auto-nuke mode on and off.
send_command('bind f11 gs c cycle OffenseMode') --Changes offense settings such as accuracy.
send_command('bind ^f11 gs c cycle HybridMode') --Changes defense settings for melee such as PDT.
send_command('bind !f11 gs c cycle ExtraMeleeMode') --Adds another set layered on top of your engaged set.
send_command('bind ^!f11 gs c cycle CastingMode') --Changes your castingmode options such as magic accuracy.
send_command('bind @f11 gs c cycle IdleMode') --Changes your idle mode options such as refresh.
send_command('bind ^@!f11 gs reload') --Reloads gearswap.
send_command('bind f12 gs c toggle Kiting') --Keeps your kiting gear on..
send_command('bind ^f12 gs c set DefenseMode Magical') --Turns your magical defense set on.
send_command('bind !f12 gs c cycle MagicalDefenseMode') --Changes your magical defense set.
send_command('bind ^!f12 gs c reset DefenseMode') --Turns your defensive mode off.
send_command('bind @scrolllock gs c cycle Passive') --Changes offense settings such as accuracy.
send_command('bind pause gs c update user') --Runs a quick check to make sure you have the right gear on and checks variables.
send_command('bind ^@!pause gs org') --Runs organizer.
send_command('bind ^@!backspace gs c buffup') --Buffup macro because buffs are love.

NotifyBuffs = S{'doom','petrification'}

--Auto WS Buff: before a weaponskill in the job file's ws_buff_list, the first ready buff below is used in its
--place and the weaponskill is sent again 1.1 seconds later. One buff per weaponskill, in this order. A job file
--with no ws_buff_list gets no buffs; it sets one as, e.g., ws_buff_list = S{'Savage Blade','Expiacion'}
--recast is the ability's recast id. Berserk and Defender cancel each other, so Berserk waits while Defender is up.
ws_buffs = {
	{name='Last Resort', job='DRK', level=15, recast=87},
	{name='Berserk',     job='WAR', level=15, recast=1, unless='Defender'},
	{name='Warcry',      job='WAR', level=35, recast=2},
	{name='Aggressor',   job='WAR', level=45, recast=4},
}

--The weaponskill being sent again. Set as that send goes out, so only it, and not a press
--spammed before it, is let through untouched; cleared once it gets past Sel's filters.
local ws_buff_refire
--os.clock() time until which other presses of a weaponskill are dropped while its buff and its
--second send are pending. Ability recasts don't update until the server resolves the JA, so
--without this every press in that window would queue another buff and weaponskill.
local ws_buff_lock = 0

local function has_job_ability(job, level)
	if player.main_job == job and (player.main_job_level or 0) >= level then return true end
	return player.sub_job == job and (player.sub_job_level or 0) >= level and not buffactive['SJ Restriction']
end

local function ready_ws_buff()
	local recasts = windower.ffxi.get_ability_recasts()
	for _, ability in ipairs(ws_buffs) do
		if has_job_ability(ability.job, ability.level)
			and not buffactive[ability.name]
			and not (ability.unless and buffactive[ability.unless])
			and recasts[ability.recast] < latency then
			return ability.name
		end
	end
end

--Runs ahead of every other precast filter, so a dropped press never swaps into the weaponskill set.
function user_filter_precast(spell, spellMap, eventArgs)
	--gs test flags spell.test: it only wants the gear, and the TP check would leave nothing but the weapons on.
	if spell.type ~= 'WeaponSkill' or spell.test then return end

	--A lapsed lock means the second send never made it back here, and its token must not wave a much later press through.
	if os.clock() >= ws_buff_lock then ws_buff_refire = nil end
	--Kept until user_precast: Sel's own filters can still hold the second send in MiniQueue and send it once more,
	--and that send needs the token too.
	if ws_buff_refire == spell.english then
		eventArgs.ws_buff_refiring = true
	end

	--Sel doesn't check TP, so a weaponskill macro spammed under 1000 TP would swap into the WS set
	--and cost TP gain until it swapped back.
	if player.tp < 1000 then
		eventArgs.cancel = true
		return
	end

	if not eventArgs.ws_buff_refiring and os.clock() < ws_buff_lock then
		eventArgs.cancel = true
	end
end

--Runs after Sel's own precast filters, so the buff is never used for a weaponskill they would refuse.
function user_precast(spell, spellMap, eventArgs)
	if eventArgs.ws_buff_refiring then
		ws_buff_refire = nil
		return
	end
	if spell.type ~= 'WeaponSkill' or spell.test or not state.AutoWSBuff.value then return end
	if silent_check_amnesia() then return end
	--WAR.lua pops Warcry and re-sends the weaponskill itself under AutoBuffMode; the lock below would drop that re-send.
	if player.main_job == 'WAR' and state.AutoBuffMode.value ~= 'Off' then return end
	if not (ws_buff_list and ws_buff_list:contains(spell.english)) then return end
	--The second send names the original target as typed; one with no raw target (from the game menu) goes off unbuffed.
	if not spell.target.raw then return end

	local ability = ready_ws_buff()
	if not ability then return end

	eventArgs.cancel = true
	ws_buff_lock = os.clock() + 5
	windower.chat.input('/ja "'..ability..'" <me>')

	local ws_name, ws_target = spell.english, spell.target.raw
	local fire_ws = function()
		ws_buff_refire = ws_name
		windower.chat.input('/ws "'..ws_name..'" '..ws_target)
	end
	fire_ws:schedule(1.1)
	add_tick_delay(1.1)
end

function user_aftercast(spell, spellMap, eventArgs)
	if spell.type == 'WeaponSkill' then
		ws_buff_lock = 0
		ws_buff_refire = nil
	end
end

--Engaged weapon hold: with UnlockWeapons on or Weapons set to None, sets may still swap main and
--sub out of combat, but while engaged the weapons stay put so a mid-fight cast doesn't cost TP.
--It uses Sel's own "Weapons" disable slot, so AspisMode's swap still gets through: Sel frees that
--slot for the ability and calls equip_weaponset() in aftercast, which puts the hold back.
local function sel_locks_weapons()
	return state.Weapons.value ~= 'None' and sets.weapons[state.Weapons.value] and not state.UnlockWeapons.value
end

local function hold_engaged_weapons(status)
	if sel_locks_weapons() then return end

	if (status or player.status) == 'Engaged' then
		local held
		if state.Weapons.value ~= 'None' and sets.weapons[state.Weapons.value] then
			held = sets.weapons[state.Weapons.value]
		else
			--Weapons None names no pair, so hold what's in hand. An empty slot isn't held, or nothing could fill it.
			held = {}
			for _, slot in ipairs({'main', 'sub'}) do
				if player.equipment[slot] and player.equipment[slot] ~= 'empty' then held[slot] = player.equipment[slot] end
			end
		end
		internal_disable_set(held, "Weapons")
	elseif disabled_sets["Weapons"] then
		--Not internal_enable_set(), which would flag Sel to call equip_weaponset() again after every action.
		disabled_sets["Weapons"] = nil
		build_internal_disable()
	end
end

local sel_equip_weaponset = equip_weaponset
function equip_weaponset()
	sel_equip_weaponset()
	hold_engaged_weapons()
end
--The job files' check_arts (Composure, Light Arts and the like) also fires under AutoBuffMode and gs c buffup,
--so AutoArts alone doesn't stop it. Off means never.
if check_arts then
	local job_check_arts = check_arts
	function check_arts()
		if not state.AutoArts.value then return false end
		return job_check_arts()
	end
end

function user_status_change(newStatus, oldStatus, eventArgs)
	hold_engaged_weapons(newStatus)
end

--Auto XP: gs c toggle AutoXP pulls and fights nearby monsters by itself, from the gear file's AutoXP_Settings:
--	AutoXP_Settings = {
--		Trusts = 'Default',            --The trust_lists entry AutoTrustMode is set to.
--		Healer = 'Yoran-Oran (UC)',    --One of those trusts. Between pulls, under HealerMPP % MP, it's dismissed and called again.
--		HealerMPP = 10,
--		Buffs = 'Tizona',              --The AutoBuffMode option to set.
--		WS = 'Expiacion 1000',         --The AutoWS choice to set, set again after a change to a weapon set that has it.
--		Pull = 'Glutinous Dart',       --A spell or job ability used on the monster, or 'Ranged'.
--		PullRange = 20,                --Yalms.
--		Heal = 'Plenilune Embrace',    --A spell or job ability used on yourself. At or under HealHPP % HP for more
--		HealHPP = 50,                  --than HealSeconds, it goes ahead of buffs and weaponskills whenever it's
--		HealSeconds = 5,               --ready, and at or under HealHPP no pull goes out.
--	}
--Trusts, Healer, Buffs, WS and Heal can be left out. Turning it off puts AutoTrustMode, AutoBuffMode and AutoWS back.
--Idle and out of town, it calls the AutoTrustMode list's missing trusts, going on without one on recast or one it
--can't call, presses F8 for the nearest monster, uses Pull on it when it's unclaimed and within PullRange, and engages
--it once it's claimed. A monster already fighting the party is engaged first. It turns itself off on zoning and on death.
local autoxp = {}

local function autoxp_action(name)
	if name == 'Ranged' then return {command = '/ra'} end
	local spell_id = get_spell_id_by_name(name)
	if spell_id then return {command = '/ma "'..name..'"', spell = name, id = spell_id} end
	local ability_id = get_ability_id_by_name(name)
	if ability_id then
		local ability = res.job_abilities[ability_id]
		return {command = '/ja "'..name..'"', ability = name, recast = ability.recast_id, tp = ability.tp_cost or 0}
	end
end

--What each kind of ranged weapon fires, by the range_type and ammo_type of Windower's item resources.
local autoxp_ammo_types = {Bow = 'Arrow', Crossbow = 'Bolt', Gun = 'Bullet', Cannon = 'Shell'}

local function autoxp_throwing(item)
	return item ~= nil and res.skills[item.skill] ~= nil and res.skills[item.skill].en == 'Throwing'
end

--A thrown weapon in the range slot (a boomerang) or the ammo slot (shuriken) fires by itself; a bow, crossbow or
--gun needs its own kind of ammo.
local function autoxp_can_shoot()
	local range = res.items:with('en', player.equipment.range)
	local ammo = res.items:with('en', player.equipment.ammo)
	if not range then return autoxp_throwing(ammo) end
	if autoxp_throwing(range) then return true end
	local wanted = autoxp_ammo_types[range.range_type]
	return wanted ~= nil and ammo ~= nil and ammo.ammo_type == wanted
end

local function autoxp_blue_set(job_data, id)
	return job_data ~= nil and job_data.spells ~= nil and table.contains(job_data.spells, id)
end

--Blue magic can only be cast while it's set.
local function autoxp_usable(action)
	if action.ability then return silent_can_ability(action.ability) end
	if not action.spell then return autoxp_can_shoot() end
	if res.spells[action.id].type ~= 'BlueMagic' then return silent_can_cast(action.spell) end
	return (player.main_job_id == 16 and autoxp_blue_set(windower.ffxi.get_mjob_data(), action.id))
		or (player.sub_job_id == 16 and autoxp_blue_set(windower.ffxi.get_sjob_data(), action.id))
end

--Why the action has to wait ('recast' when that's all it waits on), or nil when it can go now.
local function autoxp_wait_reason(action)
	if not autoxp_usable(action) then return "can't be used" end
	if action.spell then
		if buffactive.silence or buffactive.mute or buffactive.Omerta then return 'silenced' end
		if actual_cost(action.id) > player.mp then return 'not enough MP' end
		if windower.ffxi.get_spell_recasts()[action.id] >= spell_latency then return 'recast' end
	elseif action.ability then
		if silent_check_amnesia() then return 'abilities are blocked' end
		if action.tp > player.tp then return 'not enough TP' end
		--Sel caches an ability as usable until the next zone, but level sync can take it away before then.
		local recast = windower.ffxi.get_ability_recasts()[action.recast]
		if not recast then return "can't be used" end
		if recast >= latency then return 'recast' end
	end
end

local function autoxp_problem(s)
	if type(s) ~= 'table' then return 'the gear file has no AutoXP_Settings table.' end
	local pull = type(s.Pull) == 'string' and autoxp_action(s.Pull)
	if not pull then return 'Pull must name a spell, a job ability or Ranged.' end
	if not autoxp_usable(pull) then return "you can't use "..s.Pull..' now.' end
	if type(s.PullRange) ~= 'number' then return 'PullRange must be a number of yalms.' end
	if s.Heal ~= nil then
		local heal = type(s.Heal) == 'string' and s.Heal ~= 'Ranged' and autoxp_action(s.Heal)
		if not heal then return 'Heal must name a spell or a job ability.' end
		if not autoxp_usable(heal) then return "you can't use "..s.Heal..' now.' end
		if type(s.HealHPP) ~= 'number' or type(s.HealSeconds) ~= 'number' then return 'Heal needs HealHPP and HealSeconds.' end
	end
	if s.Trusts ~= nil and not (type(s.Trusts) == 'string' and trust_lists[s.Trusts] and state.AutoTrustMode:contains(s.Trusts)) then
		return 'Trusts must name a trust_lists entry.'
	end
	if s.Healer ~= nil and not (s.Trusts and table.contains(trust_lists[s.Trusts], s.Healer) and get_spell_id_by_name(s.Healer) and type(s.HealerMPP) == 'number') then
		return 'Healer must be one of the Trusts list, with HealerMPP.'
	end
	if s.Buffs ~= nil and not (type(s.Buffs) == 'string' and state.AutoBuffMode:contains(s.Buffs)) then
		return 'Buffs must name an AutoBuffMode option.'
	end
	if s.WS ~= nil and type(s.WS) ~= 'string' then return "WS must name an AutoWS choice, as 'Savage Blade 1000'." end
end

local function autoxp_set_ws()
	local ws = AutoXP_Settings.WS
	if ws == nil then return end
	if state.AutoWS:contains(ws) then
		state.AutoWS:set(ws)
	else
		add_to_chat(123, 'Auto XP: AutoWS_List has no '..ws..' for '..state.Weapons.value..'.')
	end
end

local function autoxp_start()
	local s = AutoXP_Settings
	local problem = autoxp_problem(s)
	if problem then
		state.AutoXP:set(false)
		add_to_chat(123, 'Auto XP: '..problem)
		return
	end

	local saved = {}
	for key, mode in pairs({Trusts = 'AutoTrustMode', Buffs = 'AutoBuffMode', WS = 'AutoWS'}) do
		if s[key] ~= nil then saved[mode] = state[mode].value end
	end
	autoxp = {
		saved = saved,
		pull = autoxp_action(s.Pull),
		heal = s.Heal and autoxp_action(s.Heal),
		healer_id = s.Healer and get_spell_id_by_name(s.Healer),
		retry_at = 0, pull_until = 0, dismiss_at = 0, check_at = 0, heal_at = 0, trust_calls = {},
	}
	autoxp.healer_name = autoxp.healer_id and res.spells[autoxp.healer_id].party_name
	if s.Trusts then state.AutoTrustMode:set(s.Trusts) end
	if s.Buffs then state.AutoBuffMode:set(s.Buffs) end
	autoxp_set_ws()
end

--A mode's options can change while Auto XP is on (AutoWS's with the weapon set); one no longer offered goes back to its first, Off.
local function autoxp_stop()
	local saved = autoxp.saved
	autoxp = {}
	for name, value in pairs(saved or {}) do
		if state[name]:contains(value) then state[name]:set(value) else state[name]:reset() end
	end
end

--Only autoxp_start, which toggling the mode runs, fills autoxp, so state.AutoXP set any other way does nothing.
local function autoxp_running()
	return state.AutoXP.value and autoxp.pull ~= nil
end

--While Auto XP runs it calls the trusts itself (user_tick below): Sel's own call goes again on every tick for a trust
--that can't be called, and nothing after it in the tick would run.
local sel_check_trust = check_trust
function check_trust()
	if autoxp_running() then return false end
	return sel_check_trust()
end

local function autoxp_turn_off(reason)
	state.AutoXP:set(false)
	autoxp_stop()
	add_to_chat(122, 'Auto XP is now off: '..reason)
	if state.DisplayMode.value then update_job_states() end
end

--Shown once until the next pull, so a wait that lasts doesn't fill the chat log.
local function autoxp_note(text)
	if text == autoxp.last_note then return end
	autoxp.last_note = text
	add_to_chat(122, 'Auto XP: '..text)
end

--heal_at spaces out the sends: a Heal that Sel's precast refuses starts no recast and no cast delay.
local function autoxp_heal_first()
	return autoxp_running() and autoxp.heal and autoxp.low_since and os.clock() >= autoxp.heal_at
		and os.clock() - autoxp.low_since > AutoXP_Settings.HealSeconds and not autoxp_wait_reason(autoxp.heal)
end

--The first trust of the AutoTrustMode list that's missing and can be called: known, its recast ready and room in
--the party. One on recast waits for a later break between fights. A call that brings no trust in (it can't be called
--here, or no more trusts are allowed) starts no recast, so after two the trust is given up on until it's seen in the
--party again.
local function autoxp_callable_trust()
	local list = trust_lists[state.AutoTrustMode.value]
	if not list then return end
	local room = not windower.ffxi.get_party().p5
	local known, recasts = windower.ffxi.get_spells(), windower.ffxi.get_spell_recasts()
	local callable
	for _, name in ipairs(list) do
		local id = get_spell_id_by_name(name)
		if id and known[id] then
			local calls = autoxp.trust_calls[name] or 0
			if have_trust(res.spells[id].party_name) then
				autoxp.trust_calls[name] = nil
			elseif room and recasts[id] < spell_latency then
				if calls == 2 then
					autoxp.trust_calls[name] = 3
					add_to_chat(122, "Auto XP: can't call "..name..', going on without it.')
				elseif calls < 2 and not callable then
					callable = name
				end
			end
		end
	end
	return callable
end

--Only while the AutoTrustMode list still holds the healer, so it's called again once dismissed.
local function autoxp_low_healer()
	if not autoxp.healer_name or not table.contains(trust_lists[state.AutoTrustMode.value] or {}, AutoXP_Settings.Healer) then return end
	local party = windower.ffxi.get_party()
	for slot = 1, 5 do
		local member = party['p'..slot]
		if member and member.name:lower() == autoxp.healer_name:lower() and member.mpp < AutoXP_Settings.HealerMPP then
			return member
		end
	end
end

--Windower's mob distance is squared.
local function autoxp_in_range(mob)
	return math.sqrt(mob.distance) <= AutoXP_Settings.PullRange
end

local function autoxp_pullable(mob)
	return mob ~= nil and mob.spawn_type == 16 and mob.hpp > 0 and mob.claim_id == 0 and autoxp_in_range(mob)
end

local function autoxp_claimed_by_party(mob)
	if not (mob and mob.spawn_type == 16 and mob.hpp > 0 and mob.claim_id ~= 0 and autoxp_in_range(mob)) then return false end
	local party = windower.ffxi.get_party()
	for slot = 0, 5 do
		local member = party['p'..slot]
		if member and member.mob and member.mob.id == mob.claim_id then return true end
	end
	return false
end

--The monster pulled, once claimed, or one already fighting the party.
local function autoxp_fight_target()
	local pulled = autoxp.pull_id and windower.ffxi.get_mob_by_id(autoxp.pull_id)
	if autoxp_claimed_by_party(pulled) then return pulled end
	local bt = windower.ffxi.get_mob_by_target('bt')
	if autoxp_claimed_by_party(bt) then return bt end
end

--The engage packet and the guard Sel's AutoEngageMode use, so the two never engage over each other.
local function autoxp_engage(mob)
	engaging = os.clock() + 2
	autoxp.pull_id, autoxp.pull_until, autoxp.targeted_at = nil, 0, nil
	packets.inject(packets.new('outgoing', 0x1a, {
		['Target'] = mob.id,
		['Target Index'] = mob.index,
		['Category'] = 0x02,
	}))
end

--Sel's tick runs user_tick ahead of the job's tick (its AutoBuffMode buffs) and extra_user_tick after it, so the
--buffs go up between pulls before the next pull.
function user_tick()
	if not autoxp_running() or in_town then return false end

	if autoxp_heal_first() then
		windower.chat.input(autoxp.heal.command..' <me>')
		autoxp.heal_at = os.clock() + 3
		add_tick_delay()
		return true
	end

	if player.status ~= 'Idle' then return false end

	if os.clock() >= engaging then
		local mob = autoxp_fight_target()
		if mob then
			autoxp_engage(mob)
			add_tick_delay()
			return true
		end
	end

	--As in Sel's check_trust: no trust can be called with a monster on the party, outside Reives and Domain Invasion.
	if buffactive['Reive Mark'] or buffactive['Elvorseal'] or not in_combat then
		local trust = autoxp_callable_trust()
		if trust then
			autoxp.trust_calls[trust] = (autoxp.trust_calls[trust] or 0) + 1
			windower.chat.input('/ma "'..trust..'" <me>')
			add_tick_delay(1.5)
			return true
		end
	end
	return false
end

function extra_user_tick()
	if not autoxp_running() or in_town or player.status ~= 'Idle' then return false end
	local now = os.clock()
	if now < engaging then return false end
	if autoxp.low_since then
		autoxp_note('waiting for HP.')
		return false
	end

	--F8's target is read on a later tick. The job's tick may have cast in between, so Pull is checked again,
	--and a press from before a fight or a long wait is made again.
	local targeted_at = autoxp.targeted_at
	autoxp.targeted_at = nil
	if targeted_at and now - targeted_at < 5 and not autoxp_wait_reason(autoxp.pull) then
		local mob = windower.ffxi.get_mob_by_target('t')
		if not autoxp_pullable(mob) then
			autoxp_note('F8 picked no unclaimed monster within '..AutoXP_Settings.PullRange..' yalms.')
			autoxp.retry_at = now + 3
			return false
		end
		windower.chat.input(autoxp.pull.command..' <t>')
		autoxp.pull_id, autoxp.pull_until, autoxp.last_note = mob.id, now + 10, nil
		add_tick_delay()
		return true
	end
	if now < autoxp.retry_at or now < autoxp.pull_until then return false end

	--Dismissed only once it can be called again straight away: trusts can't be called with a monster on the party.
	local healer = autoxp_low_healer()
	if healer then
		if in_combat or now < autoxp.dismiss_at or windower.ffxi.get_spell_recasts()[autoxp.healer_id] >= spell_latency then
			autoxp_note('waiting to dismiss '..healer.name..'.')
			return false
		end
		autoxp_note('dismissing '..healer.name..' at '..healer.mpp..'% MP.')
		--Only the trust's name works here: /refa 2 and /refa p2 do nothing.
		windower.chat.input('/refa '..healer.name)
		autoxp.dismiss_at = now + 10
		add_tick_delay(1)
		return true
	end
	if autoxp_callable_trust() then
		autoxp_note('waiting for trusts.')
		return false
	end
	local reason = autoxp_wait_reason(autoxp.pull)
	if reason then
		if reason ~= 'recast' then autoxp_note(AutoXP_Settings.Pull..': '..reason..'.') end
		return false
	end

	send_command('setkey f8 down;wait .1;setkey f8 up')
	autoxp.targeted_at = now
	add_tick_delay(.5)
	return true
end

--Polled, since Sel's tick, which the Heal timer would otherwise run on, stands still through every action.
windower.raw_register_event('prerender', function()
	if not autoxp_running() or os.clock() < autoxp.check_at then return end
	autoxp.check_at = os.clock() + .25
	local me = windower.ffxi.get_player()
	if not me then return end

	local status = res.statuses[me.status] and res.statuses[me.status].english
	if status == 'Dead' or status == 'Engaged dead' then
		autoxp_turn_off('you died.')
	elseif not autoxp.heal or me.vitals.hpp > AutoXP_Settings.HealHPP then
		autoxp.low_since = nil
	elseif not autoxp.low_since then
		autoxp.low_since = os.clock()
	end
end)

function user_zone_change(new_id, old_id)
	if state.AutoXP.value then autoxp_turn_off('zoned.') end
end

--Auto WS, as on the rahvin branch: the mode offers OFF plus one option per AutoWS_List entry for the
--current weapon set, labeled with the weaponskill and its TP, as 'Savage Blade 1000'. A gear file sets:
--	AutoWS_List = {
--		Naegling = {{'Savage Blade', 1000}, {'Savage Blade', 1750}},
--		Almace   = {{'Chant du Cygne', 'AM3'}},
--	}
--'AM2' or 'AM3' in place of the TP builds that Aftermath level at 2000 or 3000 TP, then uses the
--weaponskill at 1000 while that level, or a higher one, is up. It fires on TP change, only while engaged,
--at <t>, and waits two seconds after a send before sending another. Changing weapon set sets it back to OFF,
--or, with Auto XP on, to Auto XP's WS choice when the new set has it.
--Kept from Sel's own auto-ws: the melee range check and AutoWSRestore.
local autows_weapon, autows_list_built
local autows_choices = {}
local autows_next = 0

--Returns true when it rebuilt, which also sets the mode back to OFF.
local function autows_sync()
	local list = type(AutoWS_List) == 'table' and AutoWS_List or nil
	if autows_weapon == state.Weapons.value and autows_list_built == list then return false end

	autows_weapon = state.Weapons.value
	autows_list_built = list
	autows_choices = {}
	local labels = {'OFF'}
	for _, choice in ipairs(list and list[autows_weapon] or {}) do
		if type(choice) == 'table' and choice[1] and choice[2] then
			local label = tostring(choice[1])..' '..tostring(choice[2])
			if not autows_choices[label] then
				labels[#labels + 1] = label
				autows_choices[label] = choice
			end
		end
	end
	state.AutoWS:options(unpack(labels))
	state.AutoWS:set('OFF')
	return true
end

local function autows_resync()
	if not autows_sync() then return false end
	if autoxp_running() then autoxp_set_ws() end
	return true
end

local function autows_threshold(tp)
	local level = tonumber(tostring(tp):upper():match('^AM([23])$'))
	if not level then return tonumber(tp) end
	for held = level, 3 do
		if buffactive['Aftermath: Lv.'..held] then return 1000 end
	end
	return level * 1000
end

--Sel's restore weaponskills, by ability id, tried ahead of the chosen one when HP or MP runs low.
local autows_restore = {
	{id=47,  name='Sanguine Blade', hpp=41},
	{id=105, name='Catastrophe',    hpp=41},
	{id=109, name='Entropy',        mpp=31},
	{id=171, name='Mystic Boon',    mpp=31},
}

local function autows_pick(choice, tp, in_melee_range)
	if state.AutoWSRestore.value and in_melee_range then
		local available_ws = S(windower.ffxi.get_abilities().weapon_skills)
		for _, ws in ipairs(autows_restore) do
			if available_ws:contains(ws.id) and ((ws.hpp and player.hpp < ws.hpp) or (ws.mpp and player.mpp < ws.mpp)) then
				return ws.name
			end
		end
	end

	local ws_name = tostring(choice[1])
	if not (in_melee_range or data.weaponskills.ranged:contains(ws_name)) then return end

	local threshold = autows_threshold(choice[2])
	if threshold and tp >= threshold then return ws_name end
end

windower.raw_register_event('tp change', function(new_tp)
	if state.AutoWS.value == 'OFF' and not autoxp_running() then return end
	gearswap.refresh_globals()
	--Weapons can change without a state change (gs c abyred, WeaponSets).
	autows_resync()
	local choice = autows_choices[state.AutoWS.value]
	if not choice then return end

	local now = os.clock()
	if now < autows_next or midaction() then return end
	if autoxp_heal_first() then return end
	if player.status ~= 'Engaged' or (new_tp or player.tp) < 1000 then return end
	if buffactive['Amnesia'] or buffactive['Sleep'] or buffactive['Stun'] or buffactive['Petrification'] or buffactive['Terror'] or buffactive['Charm'] then return end

	local target = windower.ffxi.get_mob_by_target('t')
	if not target or target.hpp == 0 or target.spawn_type ~= 16 then return end
	--Windower's mob distance is squared.
	local distance = math.sqrt(target.distance)
	if distance > (19.7 + target.model_size) then return end

	local ws_name = autows_pick(choice, new_tp or player.tp, distance < (3.2 + target.model_size))
	if not ws_name then return end

	autows_next = now + 2
	windower.chat.input('/ws "'..ws_name..'" <t>')
end)

--Sel's tick-driven auto-ws is replaced by the above.
function check_ws()
	return false
end

--While Auto WS Buff handles them, a job's tick buffing (job_check_buff under AutoBuffMode) must not use the
--same abilities on its own, since in_combat lingers after a fight and they'd go off nowhere near a weaponskill.
--The job's tick reads ability recasts to decide, so for the length of its call those four read as on recast
--and it moves on to its other buffs. Left alone where Auto WS Buff wouldn't act: no ws_buff_list, or main WAR under AutoBuffMode.
local ws_buff_recast_ids = {}
for _, ability in ipairs(ws_buffs) do ws_buff_recast_ids[ability.recast] = true end
local job_check_buff_wrapped

local function wrap_job_check_buff()
	if not job_check_buff or job_check_buff_wrapped == job_check_buff then return end
	local sel_job_check_buff = job_check_buff
	job_check_buff = function(...)
		if not state.AutoWSBuff.value or not ws_buff_list or (player.main_job == 'WAR' and state.AutoBuffMode.value ~= 'Off') then
			return sel_job_check_buff(...)
		end
		local get_ability_recasts = windower.ffxi.get_ability_recasts
		windower.ffxi.get_ability_recasts = function()
			local recasts = get_ability_recasts()
			for id in pairs(ws_buff_recast_ids) do recasts[id] = 9999 end
			return recasts
		end
		local ok, result = pcall(sel_job_check_buff, ...)
		windower.ffxi.get_ability_recasts = get_ability_recasts
		if not ok then error(result, 0) end
		return result
	end
	job_check_buff_wrapped = job_check_buff
end

--Sel's AutoBuffMode buffing with two more checks: enough MP for the spell, and, for a BLU spell that needs
--Unbridled Learning, that it's ready, so a cast isn't tried that can only fail.
function check_buff()
	if state.AutoBuffMode.value ~= 'Off' and not in_town then
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
				and not (unbridled_spells and unbridled_ready and unbridled_spells:contains(buff_spell.Name) and not unbridled_ready()) then
				windower.chat.input('/ma "'..buff_spell.Name..'" <me>')
				add_tick_delay()
				return true
			end
		end
	else
		return false
	end
end

--Sel's get_idle_set sends an IdleMode with DT, Tank or EVA in its name to state.NonCombatIdleMode while out of
--combat, but nothing defines that mode, so idle silently falls back to plain sets.idle. This puts the selected
--mode's set back, with the pet and custom-group descent get_idle_set would have done.
local function idle_mode_set()
	if in_combat then return end
	local mode = state.IdleMode.value
	if not (mode:contains('DT') or mode:contains('Tank') or mode:contains('EVA')) then return end

	local mode_set = sets.idle[mode]
	if not mode_set then return end
	if (pet.isvalid or state.Buff.Pet) and mode_set.Pet then
		mode_set = mode_set.Pet
		if pet.status == 'Engaged' and mode_set.Engaged then mode_set = mode_set.Engaged end
	end
	for _, group in ipairs(classes.CustomIdleGroups) do
		if mode_set[group] then mode_set = mode_set[group] end
	end
	return mode_set
end

--The job files add sets.latent_refresh (Fucho-no-Obi and the like) under 51% MP. While Sublimation is charging
--it's left off, as on the rahvin branch: the sets are set aside before the job's idle customization and put
--back after the last one.
local stashed_latent

local function restore_latent()
	if not stashed_latent then return end
	sets.latent_refresh, sets.latent_refresh_grip = stashed_latent[1], stashed_latent[2]
	stashed_latent = nil
end

function user_customize_idle_set(idleSet)
	restore_latent()
	if buffactive['Sublimation: Activated'] then
		stashed_latent = {sets.latent_refresh, sets.latent_refresh_grip}
		sets.latent_refresh, sets.latent_refresh_grip = nil, nil
	end

	local mode_set = idle_mode_set()
	if mode_set then idleSet = set_combine(idleSet, mode_set) end
	return idleSet
end

--With UnlockWeapons on, Sel lays the selected weapon set over the idle set just before this runs.
--sets.weapons.Idle (or its child for the idle mode) goes on over that.
function extra_user_customize_idle_set(idleSet)
	restore_latent()
	if state.UnlockWeapons.value and sets.weapons[state.Weapons.value] and sets.weapons.Idle then
		idleSet = set_combine(idleSet, sets.weapons.Idle[state.IdleMode.value] or sets.weapons.Idle)
	end
	return idleSet
end

--Lockstyle and gs validate 5 seconds after a job change (a file load) or a subjob change, on a timer of its own rather
--than Sel's tick, which other tick work can hold off. Each change restarts the timer, so a subjob change straight after
--a job change runs them once, for the final pair. Sel's own later locks (weapon change, RDM's arts) still go through its tick.
local job_change_token = 0

local function apply_lockstyle()
	if not state.AutoLockstyle.value then return end
	if user_job_lockstyle then
		user_job_lockstyle()
	elseif user_lockstyle then
		user_lockstyle()
	else
		windower.chat.input('/lockstyle on')
	end
	--Sel's load-time lock is still pending in its tick; this stands in for it.
	style_lock = false
	style_delay = os.clock() + 15
end

local function after_job_change(token)
	if token ~= job_change_token then return end
	apply_lockstyle()
	send_command('gs validate')
end

local function queue_after_job_change()
	job_change_token = job_change_token + 1
	after_job_change:schedule(5, job_change_token)
end

--A timer still scheduled when the file unloads (on a job change) would run with the old job's settings.
function user_unload()
	job_change_token = job_change_token + 1
end

--Sel's status box has no label for a new mode, so Auto WS is appended after it draws. Sel-Display loads
--after this file and defines update_job_states over any wrapper made at load, so it's wrapped from extra_user_setup.
local function wrap_update_job_states()
	if update_job_states_wrapped == update_job_states then return end
	local sel_update_job_states = update_job_states
	update_job_states = function()
		sel_update_job_states()
		if stateBox and state.DisplayMode.value and state.CraftingMode.value == 'None' then
			local color = state.AutoWS.value == 'OFF' and display.colors.White or display.colors.Yellow
			stateBox:append(string.format("%sAuto WS: %s%s", color, state.AutoWS.value, display.colors.OffWhite))
			if state.AutoXP.value then
				stateBox:append(string.format("    %sAuto XP%s", display.colors.Yellow, display.colors.OffWhite))
			end
		end
	end
	update_job_states_wrapped = update_job_states
end

--Runs at load and on every subjob change.
function extra_user_setup()
	autows_resync()
	wrap_job_check_buff()
	wrap_update_job_states()
	queue_after_job_change()
end

--Sel only skips a weapon set it can't dual wield when the set's name has 'Dual' or 'DW' in it, and the
--rahvin-named sets don't. This goes by the sub instead: a weapon there (not a shield or a grip) means dual wield.
local function is_dual_set(name)
	local set = sets.weapons[name]
	local sub = set and set.sub
	if type(sub) == 'table' then sub = sub.name end
	local id = get_item_id_by_name(sub)
	local item = id and res.items[id]
	return item ~= nil and item.category == 'Weapon' and not item.shield_size and (item.skill or 0) > 0
end

local function skip_dual_sets()
	if can_dual_wield or not is_dual_set(state.Weapons.value) then return end

	local startindex = state.Weapons.index
	repeat
		if cycle_direction == 'backward' then state.Weapons:cycleback() else state.Weapons:cycle() end
	until not is_dual_set(state.Weapons.value) or state.Weapons.index == startindex

	equip_weaponset()
	set_autows(state.Weapons.value)
end

--Sel frees the weapons outright when UnlockWeapons turns on; this runs after it.
function user_state_change(stateField, newValue, oldValue)
	if stateField == 'Unlock Weapons' then
		hold_engaged_weapons()
	elseif stateField == 'Weapons' then
		skip_dual_sets()
		local was = state.AutoWS.value
		if autows_resync() and was ~= 'OFF' and state.AutoWS.value == 'OFF' then add_to_chat(122, 'Auto WS is now OFF.') end
	elseif stateField == 'Auto Weaponskill Mode' and newValue and not state.RngHelper.value then
		state.AutoWSMode:set(false)
		add_to_chat(122, 'Auto Weaponskill Mode only drives RngHelper ranged auto-ws now; melee auto-ws is gs c cycle AutoWS.')
	elseif stateField == 'RngHelper' and not newValue and state.AutoWSMode.value then
		state.AutoWSMode:set(false)
	elseif stateField == 'Auto XP' and newValue ~= oldValue then
		if newValue then autoxp_start() else autoxp_stop() end
	end
end

--Sel's own melee auto-ws is gone in favor of AutoWS above; what's left of it is RngHelper's ranged
--auto-ws, which still runs off AutoWSMode, rangedautows and gs c autows while RngHelper is on.
--AutoWSMode is held off without RngHelper (above), which also keeps Sel's status box from showing its melee auto-ws.
local sel_handle_autows = handle_autows
function handle_autows(cmdParams)
	if state.RngHelper.value then return sel_handle_autows(cmdParams) end
	add_to_chat(122, 'Melee auto-ws is set per weapon in AutoWS_List; cycle it with gs c cycle AutoWS.')
end

--gs c smartws uses the current weapon set's first AutoWS_List weaponskill, in place of Sel's autows_list.
local sel_handle_smartws = handle_smartws
function handle_smartws(cmdParams)
	local choices = type(AutoWS_List) == 'table' and AutoWS_List[state.Weapons.value]
	if choices and choices[1] then autows = choices[1][1] end
	return sel_handle_smartws(cmdParams)
end

--TH_Whitelist, as on the rahvin branch. A job file that sets TH_Whitelist = S{'Dia','Dia II','Stonega'} limits
--Treasure Hunter gear to the listed spells, job abilities and weaponskills, plus any ranged attack, against an
--untagged monster. Engaging no longer locks the TH set on in Tag mode (that lock is what kept precast fast cast
--gear off before the first hit), and an action off the list doesn't count as tagging, since it landed without TH
--gear; neither does a melee swing in Tag mode. Fulltime and SATA still lock it on while engaged. A job file with no
--TH_Whitelist keeps Sel's behavior. A spell wears the set at midcast, so its precast keeps the fast cast gear.
local function th_gated()
	return TH_Whitelist ~= nil and state.TreasureMode.value ~= 'None'
end

local function th_listed(spell)
	return spell.action_type == 'Ranged Attack' or TH_Whitelist:contains(spell.english)
end

local sel_TH_for_first_hit = TH_for_first_hit
function TH_for_first_hit()
	if TH_Whitelist and state.TreasureMode.value == 'Tag' then
		if state.th_gear_is_locked then unlock_TH() end
		return
	end
	return sel_TH_for_first_hit()
end

--The raw action event tags every target of a listed action, including an area spell's.
local sel_th_action_check = th_action_check
function th_action_check(category, param)
	if not TH_Whitelist then return sel_th_action_check(category, param) end
	if category == 2 then return true end

	local resource = (category == 4 and res.spells) or (category == 3 and res.weapon_skills) or ((category == 6 or category == 14) and res.job_abilities)
	local entry = resource and resource[param]
	return entry and TH_Whitelist:contains(entry.en) or false
end

--Sel's TH equips in default_post_precast (weaponskills, abilities) and general_post_midcast (spells) are
--written inline against sets.TreasureHunter, so for an unlisted action it's set empty for the length of the call.
local function without_th_unless_listed(sel_function)
	return function(spell, spellMap, eventArgs)
		if not th_gated() or th_listed(spell) then return sel_function(spell, spellMap, eventArgs) end

		local th_set = sets.TreasureHunter
		sets.TreasureHunter = {}
		local ok, err = pcall(sel_function, spell, spellMap, eventArgs)
		sets.TreasureHunter = th_set
		if not ok then error(err, 0) end
	end
end
default_post_precast = without_th_unless_listed(default_post_precast)
general_post_midcast = without_th_unless_listed(general_post_midcast)

--Sel's aftercast marks the target tagged after any action, so an unlisted one is taken back out.
local sel_default_aftercast = default_aftercast
function default_aftercast(spell, spellMap, eventArgs)
	local target_id = spell.target and spell.target.id
	local was_tagged = target_id and info.tagged_mobs[target_id]
	sel_default_aftercast(spell, spellMap, eventArgs)
	if target_id and th_gated() and not was_tagged and not th_listed(spell) then
		info.tagged_mobs[target_id] = nil
	end
end

--A ranged attack against an untagged monster wears the TH set at precast.
function user_post_precast(spell, spellMap, eventArgs)
	if th_gated() and spell.action_type == 'Ranged Attack' and spell.target.type == 'MONSTER' and not info.tagged_mobs[spell.target.id] then
		equip(sets.TreasureHunter)
	end
end

--gs test (spell.test) wants only the gear. Sel's precast checks can cancel a test and queue the action to cast once
--a recast or a move ends, which the test's silenced input can't stop, so they're skipped for it.
local sel_filter_precast = filter_precast
function filter_precast(spell, spellMap, eventArgs)
	if spell.test then return end
	return sel_filter_precast(spell, spellMap, eventArgs)
end

--Magic burst detection, ported from the rahvin branch. A skillchain on a monster within 21 yalms, closed by anyone,
--opens an eight-second window on that monster for the elements the chain made. A nuke (Sel's is_nuke: elemental
--magic, BLU magical spells, elemental ninjutsu and the like) cast at it inside the window, of one of those elements,
--wears Sel's burst sets (MagicBurst, HelixBurst, the Resistant and RecoverBurst variants) as if MagicBurstMode were
--Single for that one cast. A weaponskill landing on that monster closes the window. MagicBurstMode still works by hand.
local skillchain_elements = {
	Light = {'Light', 'Lightning', 'Wind', 'Fire'}, Darkness = {'Dark', 'Ice', 'Water', 'Earth'},
	Gravitation = {'Dark', 'Earth'}, Fragmentation = {'Lightning', 'Wind'}, Distortion = {'Ice', 'Water'},
	Fusion = {'Light', 'Fire'}, Compression = {'Dark'}, Liquefaction = {'Fire'}, Induration = {'Ice'},
	Reverberation = {'Water'}, Transfixion = {'Light'}, Scission = {'Earth'}, Detonation = {'Wind'},
	Impaction = {'Lightning'},
}
--Add-effect message ids that report a skillchain: 288-301 chain damage and 385-398 chain healing, both in this
--order, then 767-770 Radiance and Umbra.
local skillchain_order = {'Light', 'Darkness', 'Gravitation', 'Fragmentation', 'Distortion', 'Fusion', 'Compression',
	'Liquefaction', 'Induration', 'Reverberation', 'Transfixion', 'Scission', 'Detonation', 'Impaction'}
local skillchain_by_message = {[767] = 'Light', [768] = 'Darkness', [769] = 'Light', [770] = 'Darkness'}
for i, name in ipairs(skillchain_order) do
	skillchain_by_message[287 + i] = name
	skillchain_by_message[384 + i] = name
end

local burst_target_id, burst_time, burst_elements = 0, 0, {}

windower.raw_register_event('action', function(act)
	if not act or (act.category ~= 3 and act.category ~= 4) then return end
	local target = act.targets and act.targets[1]
	local action = target and target.actions and target.actions[1]
	if not action then return end

	local chain = skillchain_by_message[action.add_effect_message]
	if chain then
		local mob = windower.ffxi.get_mob_by_id(target.id)
		if mob and mob.spawn_type == 16 and math.sqrt(mob.distance) < 21 then
			burst_target_id, burst_time, burst_elements = mob.id, os.clock(), {}
			for _, element in ipairs(skillchain_elements[chain]) do burst_elements[element] = true end
		end
	elseif act.category == 3 and act.param ~= 0 and target.id == burst_target_id then
		burst_target_id, burst_time, burst_elements = 0, 0, {}
	end
end)

local function is_burst(spell, spellMap)
	--Blue magic can only magic burst under Burst Affinity.
	if spell.skill == 'Blue Magic' and not buffactive['Burst Affinity'] then return false end
	return spell.target and spell.target.id == burst_target_id and os.clock() - burst_time < 8
		and burst_elements[spell.element] and is_nuke(spell, spellMap)
end

--Set at the first midcast hook and put back at the last, so every midcast stage, the job file's included, sees it.
local burst_forced = false

function user_midcast(spell, spellMap, eventArgs)
	--A midcast cancelled after this hook never reaches extra_user_post_midcast, so a forced Single is undone here.
	if burst_forced and state.MagicBurstMode.value == 'Single' then state.MagicBurstMode:set('Off') end
	burst_forced = false
	if spell.action_type == 'Magic' and state.MagicBurstMode.value == 'Off' and is_burst(spell, spellMap) then
		state.MagicBurstMode:set('Single')
		burst_forced = true
		add_to_chat(122, '['..spell.english..'] Burst Detected!')
	end
end

function extra_user_post_midcast(spell, spellMap, eventArgs)
	if burst_forced then
		state.MagicBurstMode:set('Off')
		burst_forced = false
	end
end