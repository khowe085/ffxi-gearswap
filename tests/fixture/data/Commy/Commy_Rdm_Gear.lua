-- Commy's red mage gear file, loaded by the real data/RDM.lua, for the tests of Sel's commands, modes, status
-- display, Treasure Hunter, spell maps and buff handling. No two sets are alike, so what is worn tells which set went
-- on.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.CastingMode:options('Normal', 'Resistant')
	state.IdleMode:options('Normal', 'DT', 'Refresh')
	state.PhysicalDefenseMode:options('PDT')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.Weapons:options('None', 'DualWeapons', 'Naegling', 'Swords', 'Crocea', 'Club')
	state.Passive:options('None', 'Emp')
end

function init_gear_sets()
	sets.weapons.Naegling = {main = 'Naegling', sub = 'Ammurapi Shield'}
	sets.weapons.Crocea = {main = 'Crocea Mors', sub = 'Ammurapi Shield'}
	-- Sets passed over while a red mage with a white mage sub job can't dual wield: DualWeapons by Sel, by its name
	-- alone, since its sub is a shield; Swords by User-Globals.lua, by the weapon in its sub. There is no
	-- sets.weapons.Club.
	sets.weapons.DualWeapons = {main = 'Aern Sword', sub = 'Ammurapi Shield'}
	sets.weapons.Swords = {main = 'Murgleis', sub = 'Crocea Mors'}

	sets.precast.FC = {head = "Bunzi's Hat", ring1 = 'Kishar Ring'}
	sets.precast.WS = {head = 'Kaykaus Mitra +1', body = 'Atrophy Tabard +3'}

	sets.midcast.FastRecast = {head = 'Malignance Chapeau'}
	sets.midcast.Cure = {main = "Bunzi's Rod", head = 'Kaykaus Mitra +1'}
	sets.midcast['Enhancing Magic'] = {body = 'Lethargy Sayon +3'}
	sets.midcast['Enfeebling Magic'] = {body = 'Malignance Tabard'}

	-- A set for each spell map, on a slot the sets above leave alone.
	sets.midcast.CureNuke = {legs = 'Merlinic Shalwar'}
	sets.midcast.BarElement = {legs = 'Telchine Braconi'}
	sets.midcast.Enspell = {legs = 'Chironic Hose'}
	sets.midcast.StatusRemoval = {legs = 'Malignance Tights'}
	sets.midcast.Dia = {legs = 'Volte Brais'}
	sets.midcast.Bio = {hands = 'Regal Cuffs'}
	sets.midcast.Protect = {legs = "Bunzi's Pants"}
	sets.midcast.Shell = {legs = 'Lengo Pants'}
	sets.midcast.Regen = {legs = 'Psycloth Lappas'}
	sets.midcast.Spikes = {legs = 'Querkening Brais'}
	sets.midcast.Raise = {hands = 'Telchine Gloves'}
	sets.midcast.Temper = {hands = 'Chironic Gloves'}
	sets.midcast.BoostStat = {hands = 'Amalric Gages'}

	sets.idle = {main = 'Daybreak', sub = 'Ammurapi Shield', ammo = 'Staunch Tathlum +1', head = 'Nyame Helm',
		body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard', feet = 'Nyame Sollerets',
		neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring',
		ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1', back = "Sucellos's Cape"}
	sets.idle.DT = set_combine(sets.idle, {head = 'Malignance Chapeau', body = 'Malignance Tabard'})
	sets.idle.Refresh = set_combine(sets.idle, {head = 'Kaykaus Mitra +1'})
	sets.Kiting = {feet = 'Volte Boots'}
	sets.passive.Emp = {waist = "Orpheus's Sash"}

	sets.defense.PDT = {head = 'Kaykaus Mitra +1', body = 'Malignance Tabard'}
	sets.defense.MDT = {body = 'Volte Jupon'}
	sets.defense.MEVA = {back = 'Null Shawl'}

	sets.engaged = {head = "Bunzi's Hat", body = 'Lethargy Sayon +3', legs = 'Nyame Flanchard'}
	sets.engaged.Acc = set_combine(sets.engaged, {body = 'Malignance Tabard'})
	sets.engaged.DT = set_combine(sets.engaged, {head = 'Malignance Chapeau'})

	sets.TreasureHunter = {head = 'Volte Cap', legs = 'Volte Hose'}
	sets.HPDown = {ring2 = "Medada's Ring"}
	sets.HPCure = {legs = 'Kaykaus Tights'}
	sets.buff.Doom = {neck = "Nicander's Necklace"}
	sets.buff.Saboteur = {feet = 'Malignance Boots'}
	sets.Refresh_Received = {waist = 'Chaac Belt'}
	sets.crafting = {neck = 'Sanctity Necklace'}
end

-- gs c test hands its words here.
function user_test(cmdParams)
	tested_with = cmdParams
end

-- gs c commy is the gear file's own command, which notes its words and goes no further.
function user_job_self_command(commandArgs, eventArgs)
	if commandArgs[1] == 'commy' then
		own_command = table.concat(commandArgs, ' ', 2)
		eventArgs.handled = true
	end
end
