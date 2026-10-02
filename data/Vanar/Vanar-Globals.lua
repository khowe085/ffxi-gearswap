-- Vanar's settings for every job. BLU.lua and RDM.lua include this file right after the engine, so
-- anything here runs each time either job file loads. GearSwap finds it in data/Vanar/.

-- Windower aliases. Type //mappy, or mappy in the console, to launch Mappy. -runonce skips the launch
-- when Mappy is already running.
send_command('alias mappy run -runonce "G:/SquareEnix/Windower/mappy.exe"')

-- Short words after //gs. Each runs the longer command, with the rest of the line passed along:
--   gs e <set>      gs equip <set>
--   gs x <options>  gs export <options>
--   gs d <slots>    gs c disable <slots>
--   gs t <action>   gs c test <action>
-- except gs e naked, which runs gs c naked on and gs c enable all, as gs equip naked now does too.
local short_words = { e = 'gs equip', x = 'gs export', d = 'gs c disable', t = 'gs c test' }

-- The longer command for a short word, or nil for any other word. An argument with a space in it
-- and no quotes of its own is quoted again, so it stays one argument when the command is resent.
local function short_word_command(word, ...)
	local command = type(word) == 'string' and short_words[word:lower()]
	if not command then return nil end
	for _, arg in ipairs({ ... }) do
		arg = tostring(arg)
		command = command .. ' ' .. ((arg:find(' ') and not arg:find('"')) and ('"' .. arg .. '"') or arg)
	end
	return command
end

-- gs equip naked and gs e naked, in any case, turn on the engine's naked hold, which strips every slot
-- and keeps it bare, and release every slot gs c disable holds, in place of an equip. Returns whether
-- the command was one of them.
local function naked_command(word, ...)
	local args = { ... }
	if type(word) ~= 'string' or #args ~= 1 or tostring(args[1]):lower() ~= 'naked' then return false end
	word = word:lower()
	if word ~= 'e' and word ~= 'equip' then return false end
	windower.send_command('gs c naked on; gs c enable all')
	return true
end

-- GearSwap passes this function each //gs word it does not know, and returning true keeps its
-- "Command not found" line out of chat.
register_unhandled_command(function(word, ...)
	if naked_command(word, ...) then return true end
	local command = short_word_command(word, ...)
	if not command then return false end
	send_command(command)
	return true
end)

-- GearSwap answers gs equip itself, so gs equip naked only reaches this raw handler. GearSwap's own
-- equip of its naked set still runs first, and the engine's naked hold then takes over the slots.
-- While a gs c test hold has the job file off, GearSwap passes nothing to the function above, so this
-- handler also sends a short word typed during the hold on as its longer command, and a second gs t
-- ends the hold and runs the new test, as gs c test does. GearSwap still prints "Command not found"
-- for the short word itself.
windower.raw_register_event('addon command', function(word, ...)
	if type(word) == 'string' and word:lower() == 'equip' then
		naked_command(word, ...)
		return
	end
	if not gearswap.gearswap_disabled then return end
	if naked_command(word, ...) then return end
	local command = short_word_command(word, ...)
	if command then send_command(command) end
end)
