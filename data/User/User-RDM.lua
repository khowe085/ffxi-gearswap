latency = .25
conserveshadows = false

--Options for automation.
send_command('gs c set MiniQueue false') -- Queues spells to be recast if it was casted too quickly after another spell  or was on cooldown
send_command('gs c set SkipProcWeapons false')
send_command('gs c set AutoArts false')
send_command('gs c set AutoWSMode false')
send_command('gs c set AutoShadowMode false')
send_command('gs c set AutoSubMode false')


-- Define Aliases
send_command('alias mappy run -runonce "G:/SquareEnix/Windower/mappy.exe"')

-- Other
send_command('console_displayactivity 0')
