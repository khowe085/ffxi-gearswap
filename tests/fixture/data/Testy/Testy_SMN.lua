-- A GearSwap user file of the plainest kind, with no framework under it, for the tests of the stand-in game's pet.
-- Each hook notes in calls what GearSwap handed it.

calls = {}

local function note(event, spell, extra)
    calls[#calls + 1] = {
        event = event,
        name = spell and spell.english,
        target = spell and spell.target and spell.target.name,
        type = spell and spell.type,
        action_type = spell and spell.action_type,
        pet_name = pet.isvalid and pet.name or nil,
        pet_status = pet.isvalid and pet.status or nil,
        extra = extra,
    }
end

function get_sets()
    sets.idle = {}
end

function pet_change(changed, gain)
    note('pet_change', nil, {name = changed.name, gain = gain, element = changed.element, valid = changed.isvalid})
end

function pet_status_change(new, old)
    note('pet_status_change', nil, {new = new, old = old})
end

function pet_midcast(spell)
    note('pet_midcast', spell)
end

function pet_aftercast(spell)
    note('pet_aftercast', spell)
end
