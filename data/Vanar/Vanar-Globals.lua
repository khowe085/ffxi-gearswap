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

-- GearSwap passes this function each //gs word it does not know, and returning true keeps its
-- "Command not found" line out of chat.
register_unhandled_command(function(word, ...)
	local command = short_word_command(word, ...)
	if not command then return false end
	send_command(command)
	return true
end)

-- While a gs c test hold has the job file off, GearSwap passes nothing to the function above. This
-- raw handler sends a short word typed during the hold on as its longer command, so a second gs t
-- ends the hold and runs the new test, as gs c test does. GearSwap still prints "Command not found"
-- for the short word itself.
windower.raw_register_event('addon command', function(word, ...)
	if not gearswap.gearswap_disabled then return end
	local command = short_word_command(word, ...)
	if command then send_command(command) end
end)
