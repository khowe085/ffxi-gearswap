-- Testy's Blue Mage: a small job file for the tools' tests.
-- Every piece named here comes from Testy's //gs export, data/export/Testy 2026-01-02 08-00-00.lua.
include('RahvinGS/GearSets-Include')
include('Testy-Globals')

-- This file's own copy of one of the engine's lists. The others stay the engine's.
BlueBuff = S { 'Cocoon' }

function get_sets()
	sets.Idle = {
		head = gear.nyameHead,
		hands = gear.hashishinHandsPlusThree,
		waist = gear.ruminationSash,
	}
	sets.Midcast = set_combine(sets.Idle, {})
end
