-- Testy's Blue Mage with nothing in it for the data checks to report.
function user_job_setup()
	blue_magic_maps.Physical = S{'Foot Kick','Power Attack'}
	blue_magic_maps.Breath = S{'Frost Breath'}
	blue_magic_maps.Magical = S{'Blastbomb'}
	blue_magic_maps.SkillBasedBuff = S{'Occultation'}
	blue_magic_maps.Buff = S{'Cocoon'}
	blue_magic_maps.Healing = S{'Magic Fruit'}
	blue_magic_maps.MagicAccuracy = S{'Sheep Song','Blank Gaze'}
end

function init_gear_sets()
	sets.idle = {head="Nyame Helm",hands="Hashi. Bazu. +3",waist="Rumination Sash"}
	sets.midcast['Blue Magic'] = set_combine(sets.idle, {})
end
