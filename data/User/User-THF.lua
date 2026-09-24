latency = .25
conserveshadows = false

--Options for automation.
send_command('gs c set MiniQueue false') -- Queues spells to be recast if it was casted too quickly after another spell  or was on cooldown
send_command('gs c set SkipProcWeapons false')
send_command('gs c set AutoWSMode false')
send_command('gs c set AutoShadowMode false')

-- Unbind Defaults
send_command('unbind !@^f7')
send_command('unbind !^f7')
send_command('unbind f7 gs')
send_command('unbind @f8')
send_command('unbind ^f8')
send_command('unbind !f8')
send_command('unbind ^@!f8')
send_command('unbind @pause')
send_command('unbind @scrolllock')
send_command('unbind f9')
send_command('unbind ^f9')
send_command('unbind @f9')
send_command('unbind !f9')
send_command('unbind f10')
send_command('unbind ^f10')
send_command('unbind !f10')
send_command('unbind f11')
send_command('unbind ^f11')
send_command('unbind @f11')
send_command('unbind !f11')
send_command('unbind ^f12')
send_command('unbind f12')
send_command('unbind @f12')
send_command('unbind !f12')
send_command('unbind ^@!f12')
send_command('unbind ^@!pause')
send_command('unbind ^@!backspace')

-- Define Aliases
send_command('alias mappy run -runonce "G:/SquareEnix/Windower/mappy.exe"')

-- Other
send_command('console_displayactivity 0')



