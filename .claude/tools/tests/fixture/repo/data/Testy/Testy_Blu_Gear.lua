-- Testy's Blue Mage, as a Selindrile gear file: a small one for the tools' tests.
function user_job_setup()
	state.CastingMode:options('Normal','Resistant')

	blue_magic_maps.Buff = S{'Cocoon'}
	-- blue_magic_maps.Healing = S{'Not Read'}

	gear.hashi_hands = {name="Hashishin Bazubands +3"}
	gear.nyame_head = {name="Nyame Helm",augments={'Path: B',}}
	gear.stikini_w8 = {name="Stikini Ring",bag="wardrobe8"}
end

function init_gear_sets()
	sets.idle = {head=gear.nyame_head,hands=gear.hashi_hands,waist="Rumination Sash"}
	sets.idle.DT = set_combine(sets.idle, {ammo=empty})

	sets.precast.FC = {ear1="Loquac. Earring",ring2="Prolix Ring",
		ring1=gear.stikini_w8}

	sets.midcast['Blue Magic'] = set_combine(sets.idle, {})
	sets.midcast['Blue Magic'].Buff = sets.midcast['Blue Magic']
	sets.midcast["Testy's Own"] = {back={name="Sucellos's Cape",augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Haste+10',}}}

	--[[ A set kept for later is not read:
	sets.Old = {head="Regal Gem"}
	]]
	sets.engaged = set_combine(sets.idle, sets.precast.FC, {body="Ayanmo Corazza +2"})

	-- Sel's own files define sets.buff.Doom, so this file can't see its base.
	sets.buff.Doom = set_combine(sets.buff.Doom, {waist="Eschan Stone"})
	sets.Kiting = {feet=gear.no_such_piece}
end

function user_job_post_midcast(spell, spellMap, eventArgs)
	if spell.skill == 'Blue Magic' then
		equip(sets.midcast['Blue Magic'])
	end
end
