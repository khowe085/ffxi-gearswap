-- A GearSwap user file of the plainest kind whose hooks do what the tests set in knobs: change the target, delay, cancel
-- or aim the action. Each hook notes in calls what GearSwap handed it. The precast hook wears a head piece for any
-- action, the midcast hook another, and the aftercast hook the idle set.

calls = {}
knobs = {}

local function note(event, spell)
    calls[#calls + 1] = {
        event = event,
        name = spell and spell.english,
        target = spell and spell.target and spell.target.name,
        raw = spell and spell.target and spell.target.raw,
        target_id = spell and spell.target and spell.target.id,
        target_type = spell and spell.target and spell.target.type,
        party = spell and spell.target and spell.target.ispartymember,
        type = spell and spell.type,
        action_type = spell and spell.action_type,
        prefix = spell and spell.prefix,
        interrupted = spell and spell.interrupted or nil,
        value = spell and spell.value,
        test = spell and spell.test,
        skill = spell and spell.skill,
        element = spell and spell.element,
        mp_cost = spell and spell.mp_cost,
        tp_cost = spell and spell.tp_cost,
        mpaftercast = spell and spell.mpaftercast,
        tpaftercast = spell and spell.tpaftercast,
        cast_time = spell and spell.cast_time,
        spell_id = spell and spell.id,
    }
end

function get_sets()
    sets.idle = {head = 'Nyame Helm', neck = 'Loricate Torque +1'}
    sets.precast = {head = "Bunzi's Hat"}
    sets.midcast = {head = 'Kaykaus Mitra +1'}
end

function filtered_action(spell)
    note('filtered_action', spell)
    if knobs.cancel_filtered then
        cancel_spell()
    end
end

function pretarget(spell)
    note('pretarget', spell)
    if knobs.change_target then
        change_target(knobs.change_target)
    end
    if knobs.pretarget_delay then
        cast_delay(knobs.pretarget_delay)
    end
    if knobs.cancel_in_pretarget then
        cancel_spell()
    end
end

function precast(spell)
    note('precast', spell)
    equip(sets.precast)
    if knobs.echo_in_precast then
        send_command('input /echo precast ran')
        windower.chat.input('/echo precast chat')
    end
    if knobs.precast_delay then
        cast_delay(knobs.precast_delay)
    end
    if knobs.move_target then
        move_spell_target(knobs.move_target)
    end
    if knobs.cancel_in_precast then
        cancel_spell()
    end
    if knobs.cancel_with ~= nil then
        cancel_spell(knobs.cancel_with)
    end
    if knobs.check_target then
        target_checked = gearswap.target_type_check(spell)
    end
end

function midcast(spell)
    note('midcast', spell)
    equip(sets.midcast)
end

function aftercast(spell)
    note('aftercast', spell)
    equip(sets.idle)
end

function pet_midcast(spell)
    note('pet_midcast', spell)
end

function pet_aftercast(spell)
    note('pet_aftercast', spell)
end
