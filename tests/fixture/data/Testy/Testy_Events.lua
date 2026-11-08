-- A GearSwap user file of the plainest kind, with a hook for each event GearSwap raises besides an action's own,
-- that notes in events what it was handed.

events = {}

local function note(event, fields)
    local entry = {event = event}
    for k, v in pairs(fields or {}) do
        entry[k] = v
    end
    events[#events + 1] = entry
end

function get_sets()
    sets.idle = {main = 'Daybreak', sub = 'Ammurapi Shield', ammo = 'Staunch Tathlum +1', head = 'Nyame Helm',
        body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard', feet = 'Nyame Sollerets',
        neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring',
        ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1', back = "Alaunus's Cape"}
end

function file_unload(...)
    note('file_unload', {args = {...}})
end

function status_change(new, old)
    note('status_change', {new = new, old = old})
end

function buff_change(name, gain, details)
    note('buff_change', {name = name, gain = gain, id = details and details.id})
end

function buff_refresh(name, details)
    note('buff_refresh', {name = name, id = details and details.id})
end

function sub_job_change(new, old)
    note('sub_job_change', {new = new, old = old})
end

function indi_change(indi, gain)
    note('indi_change', {element = indi.element, target = indi.target, size = indi.size, gain = gain})
end

function pet_change(pet, gain)
    note('pet_change', {name = pet.name, gain = gain})
end

function pet_status_change(new, old)
    note('pet_status_change', {new = new, old = old})
end

function party_buff_change(member, name, gain, details)
    note('party_buff_change', {member = member.name, name = name, gain = gain, id = details and details.id})
end

function pet_midcast(spell)
    note('pet_midcast', {name = spell.english, target = spell.target and spell.target.name})
end

function pet_aftercast(spell)
    note('pet_aftercast', {name = spell.english, interrupted = spell.interrupted})
end

function self_command(command)
    note('self_command', {command = command})
end
