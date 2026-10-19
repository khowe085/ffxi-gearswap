-- Commy's thief gear file, loaded by the real data/THF.lua, for the tests of Sel's Treasure Hunter modes. Each set
-- wears a piece that tells it apart from the others.

function user_job_setup()
	state.OffenseMode:options('Normal')
	state.IdleMode:options('Normal')
	state.Weapons:options('None')
	state.AmbushMode = M(false, 'Ambush Mode')
end

function init_gear_sets()
	sets.precast.JA['Sneak Attack'] = {ring2 = "Medada's Ring"}
	sets.precast.WS = {neck = 'Sanctity Necklace'}

	sets.idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', waist = 'Plat. Mog. Belt'}
	sets.engaged = {head = 'Nyame Helm', body = 'Malignance Tabard', legs = 'Nyame Flanchard', waist = 'Plat. Mog. Belt'}

	sets.buff['Sneak Attack'] = {back = 'Moonlight Cape'}
	sets.TreasureHunter = {head = 'Volte Cap', legs = 'Volte Hose', waist = 'Chaac Belt'}
end
