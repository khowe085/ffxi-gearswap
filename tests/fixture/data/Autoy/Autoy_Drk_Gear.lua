-- Autoy's dark knight, for the tests of Sel's automatic actions: data/DRK.lua's own buffing under AutoBuffMode, and
-- how User-Globals.lua keeps it off the abilities its Auto WS Buff uses.

ws_buff_list = S{'Savage Blade'}

function user_job_setup()
	state.OffenseMode:options('Normal')
	state.IdleMode:options('Normal')
	state.Weapons:options('None', 'Naegling')
end

function init_gear_sets()
	sets.weapons.Naegling = {main = 'Naegling'}
	sets.idle = {head = 'Nyame Helm'}
	sets.engaged = {head = 'Nyame Helm'}
end
