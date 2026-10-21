-- A GearSwap user file for Testy as a paladin, which the tests never load: they read it with gs stash and gs pull, in
-- a sandbox where nothing it does may reach the game, GearSwap or the loaded file. get_sets tries each way the tests
-- check: commands, chat input and chat, an event, a timer, text boxes, a message to other addons, equip, disable,
-- enable and midaction, GearSwap's settings, globals and language, and include and include_path. It names the head
-- piece by the main job it sees, so the tests can tell it is read as the paladin file.

function get_sets()
    send_command('input /echo from the paladin file')
    windower.send_command('input /echo from windower')
    windower.chat.input('/echo chat from the paladin file')
    add_to_chat(122, 'chat from the paladin file')
    windower.add_to_chat(122, 'chat from windower')
    windower.register_event('zone change', function()
        error('the paladin file\'s zone change event ran')
    end)
    coroutine.schedule(function()
        send_command('input /echo scheduled by the paladin file')
    end, 0)
    texts.new('a text box of the paladin file')
    windower.text.create('the paladin file\'s box')
    windower.send_ipc_message('from the paladin file')
    equip({head = 'Kaykaus Mitra +1'})
    disable('head')
    enable('body')
    midaction(false)
    gearswap.paladin_file_was_here = true
    _settings.paladin_file_was_here = true
    debug_mode(true)
    show_swaps(true)
    set_language('japanese')
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
