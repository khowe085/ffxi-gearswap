-- A small Sel gear file for the tests of data/RUN.lua. The sets for the moments the job file lays over the idle, engaged
-- and defense sets (a ward up, an effusion, Embolden) wear pieces that tell them apart.

function user_job_setup()
	state.OffenseMode:options('Normal', 'Acc')
	state.HybridMode:options('Normal', 'DT')
	state.WeaponskillMode:options('Match', 'Normal', 'Acc')
	state.CastingMode:options('Normal', 'Resistant')
	state.IdleMode:options('Normal', 'DT')
	state.PhysicalDefenseMode:options('PDT')
	state.MagicalDefenseMode:options('MDT')
	state.ResistDefenseMode:options('MEVA')
	state.ExtraDefenseMode:options('None', 'MP')
	state.Weapons:options('None', 'Epeolatry')
end

function init_gear_sets()
	sets.weapons.Epeolatry = {main = 'Epeolatry'}

	sets.idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
		feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring',
		ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1'}
	sets.idle.DT = set_combine(sets.idle, {body = 'Volte Jupon'})
	sets.latent_refresh = {waist = 'Wanion Belt'}
	sets.latent_refresh_grip = {ring2 = 'Lunette Ring'}

	sets.engaged = set_combine(sets.idle, {head = 'Volte Cap', body = 'Volte Jupon'})
	sets.engaged.MP = set_combine(sets.engaged, {hands = 'Volte Bracers'})
	sets.defense.PDT = {neck = 'Weike Torque'}
	sets.defense.MDT = {neck = 'Weike Torque'}
	sets.defense.MEVA = {neck = 'Weike Torque'}
	sets.MP = {ear2 = 'Pensee Earring'}

	sets.buff.Battuta = {legs = 'Volte Hose'}
	sets.buff.Embolden = {neck = 'Orunmila\'s Torque'}

	sets.precast.FC = {head = 'Volte Cap', neck = 'Weike Torque'}
	sets.precast.FC.Inspiration = {feet = 'Volte Boots'}
	sets.precast.JA['Vivacious Pulse'] = {}
	sets.precast.JA['Vivacious Pulse'].Ignis = {head = 'Null Masque'}
	sets.precast.JA['Vivacious Pulse'].Lux = {head = 'Volte Cap'}
	sets.precast.JA['Vivacious Pulse'].Tenebrae = {legs = 'Volte Hose'}
	sets.precast.JA.Vallation = {hands = 'Volte Bracers'}
	sets.precast.JA.Valiance = {hands = 'Volte Bracers', back = 'Prodigious Mantle'}
	sets.precast.JA.Ignis = {back = 'Prodigious Mantle'}
	sets.precast.Effusion = {legs = 'Volte Hose'}
	sets.element.Light = {ring1 = 'Lunette Ring'}

	sets.precast.WS.Resolution = {head = 'Null Masque', ear1 = 'Moonshade Earring'}
	sets.MaxTP = {ear1 = 'Sortiarius Earring', ear2 = 'Pensee Earring'}
	sets.AccMaxTP = {ear1 = 'Beatific Earring', ear2 = 'Pensee Earring'}
end
