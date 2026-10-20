-- Autoy's red mage, for the tests of Sel's automatic actions: its tick, the Auto modes and the lists they work
-- from. The sets are small, since those tests look mostly at what Sel sends rather than at what it wears.

AutoWS_List = {
	Naegling = {{'Savage Blade', 1000}, {'Savage Blade', 1750}, {'Savage Blade', 'AM2'}, {'Savage Blade', 'AM3'}},
	Bow = {{'Flaming Arrow', 1000}},
}

ws_buff_list = S{'Savage Blade'}

function user_job_setup()
	state.OffenseMode:options('Normal')
	state.IdleMode:options('Normal')
	state.Weapons:options('None', 'Naegling', 'Crocea', 'Bow')
end

function init_gear_sets()
	sets.weapons.Naegling = {main = 'Naegling', sub = 'Ammurapi Shield'}
	sets.weapons.Crocea = {main = 'Crocea Mors', sub = 'Ammurapi Shield'}
	sets.weapons.Bow = {main = 'Naegling', sub = 'Ammurapi Shield', range = "Judge's Bow"}
	sets.idle = {head = 'Nyame Helm'}
	sets.engaged = {head = "Bunzi's Hat"}
	sets.defense.PDT = {head = 'Malignance Chapeau'}
end
