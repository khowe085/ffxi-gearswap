-- A GearSwap user file of the plainest kind whose self commands call the functions GearSwap gives a user file, one
-- command for each, so the tests can use them as a user does: gs c <command> <words>. What a command works out is
-- left in results.

results = {}
events_seen = {}

function get_sets()
    sets.idle = {head = 'Nyame Helm', neck = 'Loricate Torque +1'}
    sets.helm = {head = 'Nyame Helm'}
    sets.hat = {head = "Bunzi's Hat"}
    sets.mitra = {head = 'Kaykaus Mitra +1'}
    sets.body = {body = 'Nyame Mail'}
    sets.ring = {ring1 = 'Kishar Ring'}

    register_unhandled_command(function(command, ...)
        results.unhandled = {command, ...}
        return command == 'mine'
    end)
    register_unhandled_command(function(command)
        results.second_unhandled = command
        return command == 'also_mine'
    end)

    results.user_event = windower.register_event('zone change', function(new, old)
        events_seen[#events_seen + 1] = {'user', new, old}
        equip(sets.hat)
    end)
    results.raw_event = windower.raw_register_event('zone change', function(new, old)
        events_seen[#events_seen + 1] = {'raw', new, old}
        equip(sets.mitra)
    end)
end

local commands = {}

function commands.equip_hat()
    equip(sets.hat)
end

function commands.equip_two_sets()
    equip(sets.hat, sets.ring)
end

function commands.equip_hat_then_mitra()
    equip(sets.hat, sets.mitra)
end

function commands.equip_nothing()
    equip()
end

function commands.equip_a_name()
    equip('Nyame Helm')
end

function commands.combine()
    results.combined = set_combine(sets.helm, sets.body, {neck = 'Loricate Torque +1'})
    results.helm_after = sets.helm.body
end

function commands.combine_a_name()
    set_combine(sets.helm, 'Nyame Mail')
end

function commands.disable(...)
    disable(...)
end

function commands.disable_list(...)
    disable({...})
end

function commands.enable(...)
    results.enabled = enable(...)
end

function commands.print_set(title)
    print_set(sets.helm, title)
end

function commands.print_list()
    print_set({'Nyame Helm', 'Nyame Mail'}, 'a list')
end

function commands.print_empty(title)
    print_set({}, title)
end

function commands.print_nothing()
    print_set(nil, 'nothing')
end

function commands.print_a_string()
    print_set('head', 'a string')
end

function commands.print_with_extras()
    print_set({head = 'Nyame Helm', body = {name = 'Nyame Mail', augments = {'DEX+1'}}, notes = 'a note'}, 'extras')
end

function commands.chat(...)
    add_to_chat(...)
end

function commands.chat_number(color, text)
    add_to_chat(tonumber(color), text)
end

function commands.echo(...)
    send_command('input /echo ' .. table.concat({...}, ' '))
end

function commands.wait_then_echo(seconds)
    coroutine.schedule(function()
        send_command('input /echo woke')
    end, tonumber(seconds))
end

function commands.unregister()
    windower.unregister_event(results.user_event)
end

function commands.unregister_nothing()
    windower.unregister_event('nothing')
end

function commands.register_bad_function()
    windower.register_event('zone change', 'not a function')
end

function commands.register_bad_name()
    windower.register_event(5, function() end)
end

function commands.raw_register_bad_function()
    windower.raw_register_event('zone change', 'not a function')
end

function commands.unhandled_bad()
    register_unhandled_command('not a function')
end

function commands.include(name)
    results.included = include(name)
end

function commands.require(name)
    results.included = require(name)
end

function commands.include_into_table(name)
    results.into = {}
    results.included = include(name, results.into)
end

function commands.include_a_number()
    include(5)
end

function commands.include_path(path)
    include_path(path)
end

function commands.show_swaps(value)
    if value == 'on' then
        show_swaps(true)
    elseif value == 'off' then
        show_swaps(false)
    elseif value == 'bad' then
        show_swaps('bad')
    else
        show_swaps()
    end
end

function commands.debug_mode(value)
    if value == 'on' then
        debug_mode(true)
    elseif value == 'off' then
        debug_mode(false)
    elseif value == 'bad' then
        debug_mode('bad')
    else
        debug_mode()
    end
end

function commands.midaction_false()
    midaction(false)
end

function commands.send_midaction()
    results.midaction = {midaction()}
end

function self_command(command)
    local words = {}
    for word in command:gmatch('%S+') do
        words[#words + 1] = word
    end
    local name = table.remove(words, 1)
    commands[name](unpack(words))
end
