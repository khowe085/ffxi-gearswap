-- Testy's Red Mage: a small job file for the tools' tests, in the shape of a real one.
-- Every piece named here comes from Testy's //gs export, data/export/Testy 2026-01-02 08-00-00.lua.
include('RahvinGS/GearSets-Include')
include('Testy-Globals')

-- A line in a comment is not an entry: gear.commented = hp_gear("Regal Gem", 0)
gear.sucellosMND = hp_gear("Sucellos's Cape", 0, {
	augments = { 'MND+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Haste+10', } })				-- Macc 20, MND 20
gear.sucellosINT = hp_gear("Sucellos's Cape", 0, {
	augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', '"Mag.Atk.Bns."+10', } })	-- Macc 20, MAB 10
gear.coladaRefresh = rank_gear("Colada", 100, {
	augments = { '"Refresh"+2', 'Mag. Acc.+11', 'DMG:+1', } })						-- Refresh 2
gear.stikini1 = hp_gear("Stikini Ring", 0)
gear.stikini2 = hp_gear("Stikini Ring", 0)

function get_sets()
	sets.Weapons = {}
	sets.Weapons['Savage Blade'] = {
		main = gear.naegling,
		sub = gear.ammurapi,
	}
	sets.Weapons.Idle = {
		main = gear.coladaRefresh,	-- Refresh 2
	}

	sets.Idle = {
		head = gear.nyameHead,				-- DT 7
		body = gear.lethargyBodyPlusThree,
		left_ring = gear.stikini1,
		right_ring = gear.stikini2,
		back = gear.sucellosMND,
	}

	--[[ A set kept for later is not read:
	sets.Old = { head = gear.atrophyHeadPlusFour, neck = gear.regalGem }
	]]
	sets.Midcast = set_combine(sets.Idle, {})
	sets.Midcast.Enfeebling = set_combine(sets.Midcast, {
		head = gear.atrophyHeadPlusFour,
		waist = gear.obstinateSash,		-- Macc 15 (Path A rank 20)
		left_ear = gear.loquacious,
	})
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast, { left_ring = gear.prolix })

	sets.WS = { ammo = gear.coiste }
	for _, ws in ipairs({ 'Sanguine Blade', 'Seraph Blade' }) do
		sets.WS[ws] = set_combine(sets.WS, {})
		sets.WS[ws].ACC = set_combine(sets.WS[ws], { waist = gear.eschan })
	end
end

function midcast_custom(spell)
	local equipSet = {}
	local cape = gear.sucellosINT
	if spell.skill == 'Dark Magic' then
		equipSet = set_combine(equipSet, { back = gear.sucellosINT })
	end
	return equipSet
end
