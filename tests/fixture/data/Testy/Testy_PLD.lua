-- A GearSwap user file for Testy as a paladin, which the tests never load: they read it with gs stash and gs pull, in
-- a sandbox where nothing it does may reach the game. get_sets tries to reach it every way a user file can, and
-- names the head piece by the main job it sees, so the tests can tell it is read as the paladin file.

function get_sets()
    send_command('input /echo from the paladin file')
    windower.send_command('input /echo from windower')
    windower.chat.input('/echo chat from the paladin file')
    add_to_chat(122, 'chat from the paladin file')
    windower.add_to_chat(122, 'chat from windower')
    windower.register_event('zone change', function()
        sandbox_event_ran = true
    end)
    coroutine.schedule(function()
        send_command('input /echo scheduled by the paladin file')
    end, 0)
    equip({head = 'Kaykaus Mitra +1'})
    disable('head')
    enable('head')
    midaction(false)
    included = include('Testy_Included.lua')
    include_path('sub')
    nested = include('Testy_Nested.lua')

    sets.idle = {
        main = 'Naegling',
        head = player.main_job == 'PLD' and 'Nyame Helm' or "Bunzi's Hat",
        ring1 = 'Stikini Ring +1',
        ring2 = 'Stikini Ring +1',
        back = {name = "Alaunus's Cape", augments = {'MND+20', 'Enmity+10'}},
    }
    sets.engaged = set_combine(sets.idle, {neck = 'Loricate Torque +1'})
    sets.nothing = {head = empty}
end
