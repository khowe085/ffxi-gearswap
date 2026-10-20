local plain = require('plain')

local function boot()
    local gs = plain.boot('Testy_Functions.lua')
    gs:chat()
    return gs
end

local function command(gs, text)
    gs:console('gs c ' .. text)
end

local error_of = plain.error_of

describe('equip', function()
    it('puts on the set it is given', function()
        local gs = boot()
        command(gs, 'equip_hat')
        assert.same({{equip = {head = "Bunzi's Hat"}}}, gs:traffic())
    end)

    it('puts on several sets as one', function()
        local gs = boot()
        command(gs, 'equip_two_sets')
        assert.same({{equip = {head = "Bunzi's Hat", left_ring = 'Kishar Ring'}}}, gs:traffic())
    end)

    it('puts on the later set over the earlier where they share a slot', function()
        local gs = boot()
        command(gs, 'equip_hat_then_mitra')
        assert.same({{equip = {head = 'Kaykaus Mitra +1'}}}, gs:traffic())
    end)

    it('with no set changes nothing', function()
        local gs = boot()
        command(gs, 'equip_nothing')
        assert.same({}, gs:traffic())
    end)

    it('with something that is not a set is an error', function()
        local gs = boot()
        assert.matches('Trying to combine non%-gear sets', error_of(gs.console, gs, 'gs c equip_a_name'))
    end)
end)

describe('set_combine', function()
    it('gives the sets as one set, the later over the earlier', function()
        local gs = boot()
        command(gs, 'combine')
        assert.same({head = 'Nyame Helm', body = 'Nyame Mail', neck = 'Loricate Torque +1'}, gs.user.results.combined)
    end)

    it('leaves the sets it combined as they were', function()
        local gs = boot()
        command(gs, 'combine')
        assert.is_nil(gs.user.results.helm_after)
        assert.same({head = 'Nyame Helm'}, gs.user.sets.helm)
    end)

    it('puts on nothing', function()
        local gs = boot()
        command(gs, 'combine')
        assert.same({}, gs:traffic())
    end)

    it('with something that is not a set is an error', function()
        local gs = boot()
        assert.matches('Trying to combine non%-gear sets', error_of(gs.console, gs, 'gs c combine_a_name'))
    end)

    it('gives the slots under their usual names, and leaves out what is no slot', function()
        local gs = boot()
        local combined = gs.user.set_combine({ear1 = 'Etiolation Earring', lring = 'Defending Ring'}, {nonsense = 'x', ring2 = 'Kishar Ring'})
        assert.same({left_ear = 'Etiolation Earring', left_ring = 'Defending Ring', right_ring = 'Kishar Ring'}, combined)
    end)
end)

describe('disable and enable', function()
    it('disable keeps a slot as it is when a set is put on', function()
        local gs = boot()
        command(gs, 'disable head')
        command(gs, 'equip_two_sets')
        assert.same({{equip = {left_ring = 'Kishar Ring'}}}, gs:traffic())
    end)

    it('disable takes the slots in a list, or in a table', function()
        local gs = boot()
        command(gs, 'disable head body')
        assert.same({true, true}, {gs.env.disable_table[4], gs.env.disable_table[5]})
        command(gs, 'enable head body')
        command(gs, 'disable_list head body')
        assert.same({true, true}, {gs.env.disable_table[4], gs.env.disable_table[5]})
    end)

    it('disable takes the names a slot has: ear1 for the left ear', function()
        local gs = boot()
        command(gs, 'disable ear1')
        assert.is_true(gs.env.disable_table[11])
        assert.is_false(gs.env.disable_table[12])
    end)

    it('disable of a name that is no slot is an error', function()
        local gs = boot()
        assert.matches('disable error, passed an unrecognized slot name. %(hat%)', error_of(gs.console, gs, 'gs c disable hat'))
    end)

    it('enable puts on what was held back for the slot while it was disabled, and says what it was', function()
        local gs = boot()
        command(gs, 'disable head')
        command(gs, 'equip_hat')
        assert.same({}, gs:traffic())
        command(gs, 'enable head')
        assert.same({{equip = {head = "Bunzi's Hat"}}}, gs:traffic())
        assert.same({head = "Bunzi's Hat"}, gs.user.results.enabled)
    end)

    it('enable of a slot nothing was held for puts on nothing', function()
        local gs = boot()
        command(gs, 'disable head')
        command(gs, 'enable head')
        assert.same({}, gs:traffic())
        assert.same({}, gs.user.results.enabled)
    end)

    it('enable of a name that is no slot is an error', function()
        local gs = boot()
        assert.matches('enable error, passed an unrecognized slot name. %(hat%)', error_of(gs.console, gs, 'gs c enable hat'))
    end)
end)

describe('print_set', function()
    it('prints a set under its title, each slot on a line, and a line to end it', function()
        local gs = boot()
        command(gs, 'print_set title')
        assert.same({
            {color = 1, text = '------------------------- title -------------------------'},
            {color = 8, text = 'head Nyame Helm'},
            {color = 1, text = '----------------------------------------------------------------'},
        }, gs:chat_lines())
    end)

    it('prints a set with no title between plain dashes', function()
        local gs = boot()
        command(gs, 'print_set')
        assert.same({
            '----------------------------------------------------------------',
            'head Nyame Helm',
            '----------------------------------------------------------------',
        }, gs:chat())
    end)

    it('prints a list in the order it has', function()
        local gs = boot()
        command(gs, 'print_list')
        local lines = gs:chat()
        assert.same({'1 Nyame Helm', '2 Nyame Mail'}, {lines[2], lines[3]})
    end)

    it('prints an empty set as one line that says so', function()
        local gs = boot()
        command(gs, 'print_empty title')
        assert.same({'------------------title -- Empty Table -----------------'}, gs:chat())
    end)

    it('prints an empty set with no title as one line that says so', function()
        local gs = boot()
        command(gs, 'print_empty')
        assert.same({'-------------------------- Empty Table -------------------------'}, gs:chat())
    end)

    it('prints the slots in their order, an advanced piece as its name marked, and the rest after', function()
        local gs = boot()
        command(gs, 'print_with_extras')
        assert.same({
            '------------------------- extras -------------------------',
            'head Nyame Helm',
            'body Nyame Mail (Adv.)',
            'notes a note',
            '----------------------------------------------------------------',
        }, gs:chat())
    end)

    it('of nothing is an error that names the title', function()
        local gs = boot()
        assert.matches('print_set error, nothing set is nil', error_of(gs.console, gs, 'gs c print_nothing'))
    end)

    it('of something that is not a table is an error that names the title', function()
        local gs = boot()
        assert.matches('print_set error, a string set is not a table', error_of(gs.console, gs, 'gs c print_a_string'))
    end)
end)

describe('add_to_chat', function()
    it('puts a line in the chat in the color it is given', function()
        local gs = boot()
        command(gs, 'chat_number 122 hello')
        assert.same({{color = 122, text = 'hello'}}, gs:chat_lines())
    end)

    it('puts a line in the chat in the usual color when it is given only the line', function()
        local gs = boot()
        command(gs, 'chat hello')
        assert.same({{color = 8, text = 'hello'}}, gs:chat_lines())
    end)
end)

describe('send_command', function()
    it('runs the command in the game\'s console', function()
        local gs = boot()
        command(gs, 'echo hello there')
        assert.same({'input /echo hello there'}, {gs.game.commands[#gs.game.commands]})
        assert.same({'/echo hello there'}, gs.game.typed)
    end)

    it('sends it to Windower with an @ in front, which keeps the console from echoing it', function()
        local gs = boot()
        local sent = {}
        local real = gs.game.windower.send_command
        gs.game.windower.send_command = function(text) sent[#sent + 1] = text end
        gs.user.send_command('input /echo hi')
        gs.game.windower.send_command = real
        assert.same({'@input /echo hi'}, sent)
    end)

    pending('sends a command that begins with @ as it is: send_cmd_user tests string.byte(1), the byte of the number 1, '
        .. 'for the first byte of the command, so it adds an @ every time')
end)

describe('include and require', function()
    it('load the file into the user file and give what it returns', function()
        local gs = boot()
        command(gs, 'include Testy_Included.lua')
        assert.same({value = 42}, gs.user.results.included)
        assert.equal('Testy_Included.lua', gs.user.included_marker)
    end)

    it('add .lua to a name that lacks it, and take it in any case', function()
        local gs = boot()
        command(gs, 'include Testy_Included')
        assert.equal('Testy_Included.lua', gs.user.included_marker)
        gs.user.included_marker = nil
        command(gs, 'include TESTY_INCLUDED')
        assert.equal('Testy_Included.lua', gs.user.included_marker)
    end)

    it('are the same function', function()
        local gs = boot()
        command(gs, 'require Testy_Included')
        assert.same({value = 42}, gs.user.results.included)
        assert.equal('Testy_Included.lua', gs.user.included_marker)
    end)

    it('load the file into a table given as the second argument, and not into the user file', function()
        local gs = boot()
        command(gs, 'include_into_table Testy_Included')
        assert.equal('Testy_Included.lua', gs.user.results.into.included_marker)
        assert.is_nil(gs.user.included_marker)
        assert.equal(gs.user.results.into, gs.user.results.included)
    end)

    it('give the globals of the user file to a file loaded into a table', function()
        local gs = boot()
        command(gs, 'include_into_table Testy_Included')
        assert.equal(gs.user.sets, gs.user.results.into.sets)
    end)

    it('of a file that is not there is an error', function()
        local gs = boot()
        assert.matches('Cannot find the include file %(nothing_here.lua%)', error_of(gs.console, gs, 'gs c include nothing_here'))
    end)

    it('of something that is not a name is an error', function()
        local gs = boot()
        assert.matches('include%(%) was passed an invalid value %(5%)', error_of(gs.console, gs, 'gs c include_a_number'))
    end)

    it('of a file Lua can\'t read is an error that says what is wrong with it', function()
        local gs = boot()
        assert.matches('Error loading file %(testy_broken.lua%)', error_of(gs.console, gs, 'gs c include Testy_Broken'))
    end)

    it('of pack gives nothing, for GearSwap has loaded it', function()
        local gs = boot()
        command(gs, 'include pack')
        assert.is_nil(gs.user.results.included)
    end)

    it('of a library GearSwap has loaded gives the library', function()
        local gs = boot()
        command(gs, 'include texts')
        assert.equal(gs.env.package.loaded.texts, gs.user.results.included)
        assert.is_table(gs.user.results.included)
    end)

    it('find a file in the folder include_path names, which the files outside it don\'t have', function()
        local gs = boot()
        command(gs, 'include_path sub')
        command(gs, 'include Testy_Nested')
        assert.same({value = 7}, gs.user.results.included)
        assert.equal('sub/Testy_Nested.lua', gs.user.included_marker)
    end)

    it('find the file outside include_path\'s folder too, when it is not in the folder', function()
        local gs = boot()
        command(gs, 'include_path sub')
        command(gs, 'include Testy_Included')
        assert.equal('Testy_Included.lua', gs.user.included_marker)
    end)

    it('don\'t find a file in a folder include_path was not told of', function()
        local gs = boot()
        assert.matches('Cannot find the include file %(testy_nested.lua%)', error_of(gs.console, gs, 'gs c include Testy_Nested'))
    end)

    it('forget the folder include_path named when it is called with nothing', function()
        local gs = boot()
        command(gs, 'include_path sub')
        command(gs, 'include_path')
        assert.matches('Cannot find the include file', error_of(gs.console, gs, 'gs c include Testy_Nested'))
    end)

    it('forget the folder include_path named once another file is loaded', function()
        local gs = boot()
        command(gs, 'include_path sub')
        plain.load(gs, 'Testy_Functions.lua')
        assert.matches('Cannot find the include file', error_of(gs.console, gs, 'gs c include Testy_Nested'))
    end)
end)

describe('midaction', function()
    it('says there is an action in progress, and which', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        command(gs, 'send_midaction')
        local result = gs.user.results.midaction
        assert.same({true, 'Cure III'}, {result[1], result[2].english})
    end)

    it('called with false ends the action in progress', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        command(gs, 'midaction_false')
        command(gs, 'send_midaction')
        assert.same({false}, gs.user.results.midaction)
    end)
end)

describe('show_swaps and debug_mode', function()
    it('show_swaps with nothing turns showing the swaps on, and with false off', function()
        local gs = boot()
        command(gs, 'show_swaps')
        assert.is_true(gs.env._settings.show_swaps)
        command(gs, 'show_swaps off')
        assert.is_false(gs.env._settings.show_swaps)
        command(gs, 'show_swaps on')
        assert.is_true(gs.env._settings.show_swaps)
    end)

    it('shown swaps are printed in the chat under the event that made them', function()
        local gs = boot()
        command(gs, 'show_swaps on')
        gs:chat()
        command(gs, 'equip_hat')
        assert.same({
            '------------------------- self_command -------------------------',
            'head Bunzi\'s Hat',
            '----------------------------------------------------------------',
        }, gs:chat())
    end)

    it('swaps are not printed when they are not shown', function()
        local gs = boot()
        command(gs, 'equip_hat')
        assert.same({}, gs:chat_lines())
    end)

    it('show_swaps with something that is not a boolean is an error', function()
        local gs = boot()
        assert.matches('show_swaps%(%) was passed an invalid value %(bad%)', error_of(gs.console, gs, 'gs c show_swaps bad'))
    end)

    it('debug_mode with nothing turns debug mode on, and with false off', function()
        local gs = boot()
        command(gs, 'debug_mode')
        assert.is_true(gs.env._settings.debug_mode)
        command(gs, 'debug_mode off')
        assert.is_false(gs.env._settings.debug_mode)
        command(gs, 'debug_mode on')
        assert.is_true(gs.env._settings.debug_mode)
    end)

    it('debug mode says in the chat why an action was left to the game', function()
        local gs = plain.boot('Testy_Functions.lua', {spells = {'Cure IV'}})
        command(gs, 'debug_mode')
        gs:chat()
        gs:type('/ma "Cure III" <me>')
        assert.same({
            'GearSwap (Debug Mode): Unable to execute command. You do not know that spell (Cure III)',
            'GearSwap (Debug Mode): Entering filtered_action',
        }, gs:chat())
    end)

    it('says nothing of that when debug mode is off', function()
        local gs = plain.boot('Testy_Functions.lua', {spells = {'Cure IV'}})
        gs:type('/ma "Cure III" <me>')
        assert.same({}, gs:chat_lines())
    end)

    it('debug_mode with something that is not a boolean is an error', function()
        local gs = boot()
        assert.matches('was passed an invalid value %(bad%)', error_of(gs.console, gs, 'gs c debug_mode bad'))
    end)

    pending('debug_mode with something that is not a boolean names debug_mode() in its error: debug_mode in '
        .. 'user_functions.lua raises the message of show_swaps, which names show_swaps()')
end)

describe('set_language', function()
    it('in get_sets sets the language, and the rest of get_sets goes on', function()
        local gs = plain.boot()
        gs.env.test_language = 'japanese'
        plain.load(gs, 'Testy_Language.lua')
        assert.equal('japanese', gs.env.language)
        assert.is_not_nil(gs.user.sets.after_language)
    end)

    it('is english again when the next file is loaded', function()
        local gs = plain.boot()
        gs.env.test_language = 'japanese'
        plain.load(gs, 'Testy_Language.lua')
        plain.load(gs, 'Testy_WHM.lua')
        assert.equal('english', gs.env.language)
    end)

    it('to english leaves the language english', function()
        local gs = plain.boot()
        gs.env.test_language = 'english'
        plain.load(gs, 'Testy_Language.lua')
        assert.equal('english', gs.env.language)
    end)

    it('to a language GearSwap doesn\'t have is an error', function()
        local gs = plain.boot()
        gs.env.test_language = 'french'
        assert.matches('set_language%(%) was passed an invalid value %(french%)', error_of(gs.console, gs, 'gs load Testy_Language.lua'))
    end)

    it('to nothing is an error', function()
        local gs = plain.boot()
        assert.matches('set_language%(%) was passed an invalid value %(nil%)', error_of(gs.console, gs, 'gs load Testy_Language.lua'))
    end)

    it('after get_sets is an error', function()
        local gs = plain.boot()
        gs.env.test_language = 'english'
        plain.load(gs, 'Testy_Language.lua')
        assert.matches('set_language%(%) is only valid in the get_sets function', error_of(gs.console, gs, 'gs c set_language'))
    end)
end)

describe('register_unhandled_command', function()
    it('gives a gs command GearSwap doesn\'t know to the function, with the words after it', function()
        local gs = boot()
        gs:console('gs mine one two')
        assert.same({'mine', 'one', 'two'}, gs.user.results.unhandled)
    end)

    it('says nothing is wrong when the function took the command', function()
        local gs = boot()
        gs:console('gs mine')
        assert.is_nil(gs:log():find('Command not found', 1, true))
    end)

    it('stops at the first function that took the command', function()
        local gs = boot()
        gs:console('gs mine')
        assert.is_nil(gs.user.results.second_unhandled)
    end)

    it('goes on to the next function when one did not take it', function()
        local gs = boot()
        gs:console('gs also_mine')
        assert.same({'also_mine'}, gs.user.results.unhandled)
        assert.equal('also_mine', gs.user.results.second_unhandled)
        assert.is_nil(gs:log():find('Command not found', 1, true))
    end)

    it('lets GearSwap say it does not know the command when no function took it', function()
        local gs = boot()
        gs:console('gs wibble')
        assert.equal('wibble', gs.user.results.second_unhandled)
        assert.matches('GearSwap: Command not found', gs:log())
    end)

    it('is not asked while the user file is disabled', function()
        local gs = boot()
        gs:console('gs disable')
        gs:console('gs mine')
        assert.is_nil(gs.user.results.unhandled)
        assert.matches('GearSwap: Command not found', gs:log())
    end)

    it('is forgotten once another file is loaded', function()
        local gs = boot()
        local old = gs.user
        plain.load(gs, 'Testy_WHM.lua')
        gs:console('gs mine')
        assert.is_nil(old.results.unhandled)
        assert.matches('GearSwap: Command not found', gs:log())
    end)

    it('with something that is not a function is an error', function()
        local gs = boot()
        assert.matches('unhandled_command was passed an invalid value %(not a function%)', error_of(gs.console, gs, 'gs c unhandled_bad'))
    end)
end)

describe('windower.register_event', function()
    local function zone_change(gs)
        gs.game:fire('zone change', 230, 100)
        gs.game:settle()
    end

    it('runs the function when the event comes, with what the event gives', function()
        local gs = boot()
        zone_change(gs)
        assert.same({{'user', 230, 100}, {'raw', 230, 100}}, gs.user.events_seen)
    end)

    it('lets the function put on gear, as a user file\'s hook does', function()
        local gs = boot()
        zone_change(gs)
        assert.same({{equip = {head = "Bunzi's Hat"}}}, gs:traffic())
    end)

    it('is not run while the user file is disabled', function()
        local gs = boot()
        gs:console('gs disable')
        zone_change(gs)
        assert.same({{'raw', 230, 100}}, gs.user.events_seen)
        assert.same({}, gs:traffic())
    end)

    it('is forgotten once another file is loaded', function()
        local gs = boot()
        local old = gs.user
        plain.load(gs, 'Testy_WHM.lua')
        zone_change(gs)
        assert.same({}, old.events_seen)
    end)

    it('with something that is not a function is an error', function()
        local gs = boot()
        assert.matches('windower.register_event%(%) was passed an invalid value %(not a function%)',
            error_of(gs.console, gs, 'gs c register_bad_function'))
    end)

    it('with something that is not an event\'s name is an error', function()
        local gs = boot()
        assert.matches('windower.register_event%(%) was passed an invalid value %(5%)', error_of(gs.console, gs, 'gs c register_bad_name'))
    end)

    it('gives a number to unregister it by', function()
        local gs = boot()
        assert.is_number(gs.user.results.user_event)
        assert.not_equal(gs.user.results.user_event, gs.user.results.raw_event)
    end)

    describe('unregistered', function()
        it('stops the function from being run', function()
            local gs = boot()
            command(gs, 'unregister')
            zone_change(gs)
            assert.same({{'raw', 230, 100}}, gs.user.events_seen)
        end)

        it('with something that is not a number is an error', function()
            local gs = boot()
            assert.matches('windower.unregister_event%(%) was passed an invalid value %(nothing%)',
                error_of(gs.console, gs, 'gs c unregister_nothing'))
        end)
    end)
end)

describe('windower.raw_register_event', function()
    it('runs the function with what the event gives, as the user file, without letting it put on gear', function()
        local gs = boot()
        gs.game:fire('zone change', 230, 100)
        gs.game:settle()
        assert.same({'raw', 230, 100}, gs.user.events_seen[2])
        assert.equal("Bunzi's Hat", gs:worn().head)
        assert.is_nil(gs:traffic()[2])
    end)

    it('is run while the user file is disabled', function()
        local gs = boot()
        gs:console('gs disable')
        gs.game:fire('zone change', 230, 100)
        assert.same({{'raw', 230, 100}}, gs.user.events_seen)
    end)

    it('with something that is not a function is an error', function()
        local gs = boot()
        assert.matches('windower.register_event%(%) was passed an invalid value %(not a function%)',
            error_of(gs.console, gs, 'gs c raw_register_bad_function'))
    end)
end)

describe('text boxes and primitives a user file makes', function()
    for _, kind in ipairs({'text', 'prim'}) do
        it('a ' .. kind .. ' is made once by name, and a second of that name is refused with a message', function()
            local gs = boot()
            gs.user.windower[kind].create('box')
            assert.is_true(gs.env.__raw[kind].registry.box)
            assert.same({}, gs:chat_lines())
            gs.user.windower[kind].create('box')
            assert.same({'GearSwap: ' .. (kind == 'text' and 'Text object' or 'Primitive')
                .. ' cannot be created because it already exists.'}, gs:chat())
        end)

        it('a ' .. kind .. ' can be made again once it is deleted', function()
            local gs = boot()
            gs.user.windower[kind].create('box')
            gs.user.windower[kind].delete('box')
            assert.is_nil(gs.env.__raw[kind].registry.box)
            gs.user.windower[kind].create('box')
            assert.same({}, gs:chat_lines())
        end)

        it('a ' .. kind .. ' GearSwap has no record of is deleted all the same', function()
            local gs = boot()
            assert.has_no.errors(function()
                gs.user.windower[kind].delete('never made')
            end)
        end)

        it('a ' .. kind .. ' is gone once another file is loaded', function()
            local gs = boot()
            gs.user.windower[kind].create('box')
            plain.load(gs, 'Testy_WHM.lua')
            assert.is_nil(gs.env.__raw[kind].registry.box)
        end)
    end
end)

describe('the user file\'s windower', function()
    it('is Windower\'s, with the functions GearSwap replaced', function()
        local gs = boot()
        assert.equal('Testy', gs.user.windower.ffxi.get_player().name)
        assert.is_not_equal(gs.env.windower.register_event, gs.user.windower.register_event)
    end)
end)

describe('a user function', function()
    it('that raises an error stops what GearSwap was doing, naming the function', function()
        local gs = boot()
        assert.matches('GearSwap has detected an error in the user function self_command', error_of(gs.console, gs, 'gs c nonsense'))
    end)

    it('that is not a function is said not to be one', function()
        local gs = boot()
        gs.user.precast = 5
        gs:type('/ma "Cure III" <me>')
        assert.matches('precast%(%) exists but is not a function', gs:log())
    end)
end)

describe('coroutine.schedule', function()
    it('runs a function in a user file after the seconds it is given', function()
        local gs = boot()
        command(gs, 'wait_then_echo 2')
        gs:advance(1.9)
        assert.is_nil(gs:log():find('command: input /echo woke', 1, true))
        gs:advance(0.2)
        assert.matches('command: input /echo woke', gs:log())
    end)
end)

describe('coroutine.sleep', function()
    pending('waits the seconds in a user file\'s coroutine and goes on: user_coroutine is the coroutine library itself, '
        .. 'so replacing its yield with user_yield makes user_sleep, which yields, call user_yield, which calls itself, '
        .. 'and the stack overflows')
end)
