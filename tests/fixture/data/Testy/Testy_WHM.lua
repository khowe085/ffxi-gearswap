-- A GearSwap user file of the plainest kind, with no framework under it, for the tests of GearSwap itself. Each
-- hook notes in calls what GearSwap handed it, and wears a set.

calls = {}

local function note(event, spell, extra)
    calls[#calls + 1] = {
        event = event,
        name = spell and spell.english,
        target = spell and spell.target and spell.target.name,
        type = spell and spell.type,
        action_type = spell and spell.action_type,
        interrupted = spell and spell.interrupted or nil,
        extra = extra,
    }
end

function get_sets()
    sets.idle = {main = 'Daybreak', sub = 'Ammurapi Shield', ammo = 'Staunch Tathlum +1', head = 'Nyame Helm',
        body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard', feet = 'Nyame Sollerets',
        neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring',
        ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1', back = "Alaunus's Cape"}
    sets.engaged = set_combine(sets.idle, {main = "Bunzi's Rod"})
    sets.precast = {}
    sets.precast.FastCast = {head = "Bunzi's Hat", neck = 'Loricate Torque +1', ring1 = 'Kishar Ring'}
    sets.precast.WS = {neck = 'Loricate Torque +1', ring1 = 'Stikini Ring +1', ring2 = 'Defending Ring'}
    sets.precast.JA = {head = "Bunzi's Hat"}
    sets.midcast = {}
    sets.midcast.Cure = {head = 'Kaykaus Mitra +1'}
end

function filtered_action(spell)
    note('filtered_action', spell)
end

function pretarget(spell)
    note('pretarget', spell)
end

function precast(spell)
    note('precast', spell)
    if spell.action_type == 'Magic' then
        equip(sets.precast.FastCast)
    elseif spell.type == 'WeaponSkill' then
        equip(sets.precast.WS)
    elseif spell.type == 'JobAbility' then
        equip(sets.precast.JA)
    end
    if cancel_next then
        cancel_next = nil
        cancel_spell()
    end
end

function midcast(spell)
    note('midcast', spell)
    if spell.english:startswith('Cure') then
        equip(sets.midcast.Cure)
    end
end

function aftercast(spell)
    note('aftercast', spell)
    equip(player.status == 'Engaged' and sets.engaged or sets.idle)
end

function status_change(new, old)
    note('status_change', nil, {new = new, old = old})
    equip(new == 'Engaged' and sets.engaged or sets.idle)
end

function buff_change(name, gain)
    note('buff_change', nil, {name = name, gain = gain})
end

function self_command(command)
    note('self_command', nil, command)
    if command == 'idle' then
        equip(sets.idle)
    end
end
