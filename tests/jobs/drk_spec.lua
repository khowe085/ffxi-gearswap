local jobby = require('jobby')

local gear = {'Ragnarok', 'Naegling', 'Apocalypse', 'Volte Cap', 'Null Masque', 'Volte Jupon', 'Adamantite Armor',
    'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Fotia Gorget', "Combatant's Torque", 'Null Belt',
    'Moonshade Earring', 'Brutal Earring', 'Lugra Earring', 'Cessance Earring', 'Odnowa Earring +1', 'Karieyh Ring',
    'Chirich Ring +1', "Cornelia's Ring"}

local function boot(options)
    options = options or {}
    options.items = gear
    options.sub_job = options.sub_job or 'WHM'
    return jobby.boot('DRK', options)
end

local function boot_ticking(options)
    options = options or {}
    options.items = gear
    options.sub_job = options.sub_job or 'WHM'
    return jobby.boot_ticking('DRK', options)
end

-- What the idle set of Jobby's dark knight gear file wears, as the game shows it worn, with his scythe in hand.
local idle = jobby.worn_by(jobby.full_idle, jobby.weapons.DRK)

-- Worn at the boot for a great sword's weapon skill.
local great_sword = {main = 'Ragnarok'}

local function weaponskill(gs, line)
    gs:type(line)
    local traffic = gs:traffic()
    assert.is_truthy(traffic[#traffic] and traffic[#traffic].action, 'the weapon skill didn\'t go out')
    return gs:worn()
end

-- What is worn with the idle set on and the engaged set over it.
local function engaged_with(changes)
    local set = {head = 'Volte Cap', body = 'Volte Jupon'}
    for slot, item in pairs(changes or {}) do
        set[slot] = item
    end
    return jobby.worn_by(idle, set)
end

describe('DRK\'s weapon skill under Auto Buff Mode', function()
    local function buffing(wearing)
        local booted = boot({tp = 1000, wearing = wearing})
        booted:console('gs c set AutoBuffMode Auto')
        return booted
    end

    local gs
    before_each(function()
        gs = buffing()
    end)

    it('is held for Consume Mana for Entropy when Consume Mana is ready', function()
        gs:type('/ws "Entropy" <t>')
        assert.same({'Consume Mana'}, gs:actions())
    end)

    it('goes out 1.1 seconds after Consume Mana, once that is on recast', function()
        gs:type('/ws "Entropy" <t>')
        gs:traffic()
        gs:finish_action()
        gs.game:start_ability_recast('Consume Mana', 60)
        gs:advance(1.05)
        assert.same({}, gs:actions())
        gs:advance(0.1)
        assert.same({'Entropy'}, gs:actions())
    end)

    it('goes out at once while Consume Mana is on recast', function()
        gs.game:start_ability_recast('Consume Mana', 60)
        gs:type('/ws "Entropy" <t>')
        assert.same({'Entropy'}, gs:actions())
    end)

    it('goes out at once with Sekkanoki up', function()
        gs:gain_buff('Sekkanoki')
        gs:type('/ws "Entropy" <t>')
        assert.same({'Entropy'}, gs:actions())
    end)

    it('goes out at once with Auto Buff Mode off', function()
        gs:console('gs c set AutoBuffMode Off')
        gs:type('/ws "Entropy" <t>')
        assert.same({'Entropy'}, gs:actions())
    end)

    it('is not held for Consume Mana for another weapon skill', function()
        gs = buffing(great_sword)
        gs:type('/ws "Torcleaver" <t>')
        assert.same({'Torcleaver'}, gs:actions())
    end)
end)

describe('DRK\'s weapon skill under Auto Buff Mode with Samurai as the sub job', function()
    local function buffing(wearing)
        local booted = boot({tp = 2500, sub_job = 'SAM', wearing = wearing})
        booted:console('gs c set AutoBuffMode Auto')
        return booted
    end

    local gs
    before_each(function()
        gs = buffing(great_sword)
    end)

    it('is held for Sekkanoki with over 1850 TP', function()
        gs:type('/ws "Torcleaver" <t>')
        assert.same({'Sekkanoki'}, gs:actions())
    end)

    it('is held for Sekkanoki at 1851 TP', function()
        gs.game.player.vitals.tp = 1851
        gs:type('/ws "Torcleaver" <t>')
        assert.same({'Sekkanoki'}, gs:actions())
    end)

    it('is held for Meditate when Sekkanoki is on recast', function()
        gs.game:start_ability_recast('Sekkanoki', 60)
        gs:type('/ws "Torcleaver" <t>')
        assert.same({'Meditate'}, gs:actions())
    end)

    it('is held for Meditate with 1850 TP or less', function()
        gs.game.player.vitals.tp = 1850
        gs:type('/ws "Torcleaver" <t>')
        assert.same({'Meditate'}, gs:actions())
    end)

    it('is held for Meditate, not Sekkanoki, with Consume Mana up', function()
        gs:gain_buff('Consume Mana')
        gs:type('/ws "Torcleaver" <t>')
        assert.same({'Meditate'}, gs:actions())
    end)

    it('goes out when Sekkanoki and Meditate are both on recast', function()
        gs.game:start_ability_recast('Sekkanoki', 60)
        gs.game:start_ability_recast('Meditate', 60)
        gs:type('/ws "Torcleaver" <t>')
        assert.same({'Torcleaver'}, gs:actions())
    end)

    it('goes out when the sub job\'s abilities are restricted', function()
        gs:gain_buff('SJ Restriction')
        gs:type('/ws "Torcleaver" <t>')
        assert.same({'Torcleaver'}, gs:actions())
    end)

    it('is held for Consume Mana first for Entropy, ahead of the sub job\'s abilities', function()
        gs = buffing()
        gs:type('/ws "Entropy" <t>')
        assert.same({'Consume Mana'}, gs:actions())
    end)
end)

describe('DRK\'s weapon skill in the gear file\'s Auto WS Buff list', function()
    it('is held for Last Resort', function()
        local gs = boot({tp = 1000, wearing = great_sword})
        gs:type('/ws "Resolution" <t>')
        assert.same({'Last Resort'}, gs:actions())
    end)

    it('goes out 1.1 seconds after Last Resort', function()
        local gs = boot({tp = 1000, wearing = great_sword})
        gs:type('/ws "Resolution" <t>')
        gs:traffic()
        gs:finish_action()
        gs.game:start_ability_recast('Last Resort', 60)
        gs:gain_buff('Last Resort')
        gs:advance(1.05)
        assert.same({}, gs:actions())
        gs:advance(0.1)
        assert.same({'Resolution'}, gs:actions())
    end)

    it('goes out at once with Last Resort up', function()
        local gs = boot({tp = 1000, wearing = great_sword})
        gs:gain_buff('Last Resort')
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, gs:actions())
    end)

    it('goes out at once with Auto WS Buff off', function()
        local gs = boot({tp = 1000, wearing = great_sword})
        gs:console('gs c toggle AutoWSBuff')
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, gs:actions())
    end)
end)

describe('DRK\'s drain, absorb and dread spikes with the weapons locked', function()
    local function main_after(line, tp, mode)
        local gs = boot({tp = tp})
        gs:console('gs c set Weapons Ragnarok')
        if mode then
            gs:console('gs c set DrainSwapWeaponMode ' .. mode)
        end
        gs:type(line)
        return gs:worn().main
    end

    it('stay locked in Drain Swap Weapon Mode Never, the first mode', function()
        assert.equal('Ragnarok', main_after('/ma "Drain II" <t>', 0))
    end)

    it('let Drain II\'s weapon set through in Drain Swap Weapon Mode Always', function()
        assert.equal('Apocalypse', main_after('/ma "Drain II" <t>', 3000, 'Always'))
    end)

    it('let Drain III\'s weapon set through too', function()
        assert.equal('Apocalypse', main_after('/ma "Drain III" <t>', 3000, 'Always'))
    end)

    it('let Absorb-STR\'s weapon set through', function()
        assert.equal('Apocalypse', main_after('/ma "Absorb-STR" <t>', 3000, 'Always'))
    end)

    it('let Dread Spikes\' weapon set through', function()
        assert.equal('Apocalypse', main_after('/ma "Dread Spikes" <me>', 3000, 'Always'))
    end)

    it('let the weapon set through in Drain Swap Weapon Mode 300 with TP under 300', function()
        assert.equal('Apocalypse', main_after('/ma "Drain II" <t>', 299, '300'))
    end)

    it('stay locked in Drain Swap Weapon Mode 300 with 300 TP', function()
        assert.equal('Ragnarok', main_after('/ma "Drain II" <t>', 300, '300'))
    end)

    it('stay locked for Drain, which isn\'t one of the spells that want Dark Seal', function()
        assert.equal('Ragnarok', main_after('/ma "Drain" <t>', 0, 'Always'))
    end)

    it('stay locked for Aspir', function()
        assert.equal('Ragnarok', main_after('/ma "Aspir" <t>', 0, 'Always'))
    end)

    it('go back to the weapon set\'s once the spell is done', function()
        local gs = boot()
        gs:console('gs c set Weapons Ragnarok')
        gs:console('gs c set DrainSwapWeaponMode Always')
        gs:type('/ma "Drain II" <t>')
        gs:finish_action()
        assert.equal('Ragnarok', gs:worn().main)
    end)
end)

describe('DRK\'s drain, absorb and dread spikes weapon sets', function()
    local function ring_after(line)
        local gs = boot()
        gs:type(line)
        return gs:worn().left_ring
    end

    it('is sets.DrainWeapon for a drain', function()
        assert.equal('Karieyh Ring', ring_after('/ma "Drain" <t>'))
        assert.equal('Karieyh Ring', ring_after('/ma "Drain II" <t>'))
    end)

    it('is sets.AbsorbWeapon for an absorb', function()
        assert.equal('Chirich Ring +1', ring_after('/ma "Absorb-STR" <t>'))
    end)

    it('is sets.DreadWeapon for Dread Spikes', function()
        assert.equal("Cornelia's Ring", ring_after('/ma "Dread Spikes" <me>'))
    end)

    it('is none for another dark spell', function()
        assert.equal('Defending Ring', ring_after('/ma "Aspir" <t>'))
    end)
end)

describe('DRK\'s Dark Seal and Nether Void gear', function()
    local function hands_after(line, setup)
        local gs = boot()
        if setup then
            setup(gs)
        end
        gs:type(line)
        return gs:worn()
    end

    it('has sets.buff[\'Dark Seal\'] over the midcast set of Drain II under Dark Seal', function()
        local worn = hands_after('/ma "Drain II" <t>', function(gs) gs:gain_buff('Dark Seal') end)
        assert.equal('Volte Bracers', worn.hands)
        assert.equal('Volte Cap', worn.head)
    end)

    it('has it over Absorb-STR and Dread Spikes too', function()
        assert.equal('Volte Bracers', hands_after('/ma "Absorb-STR" <t>', function(gs) gs:gain_buff('Dark Seal') end).hands)
        assert.equal('Volte Bracers', hands_after('/ma "Dread Spikes" <me>', function(gs) gs:gain_buff('Dark Seal') end).hands)
    end)

    it('has it over no other dark spell', function()
        assert.equal('Nyame Gauntlets', hands_after('/ma "Aspir" <t>', function(gs) gs:gain_buff('Dark Seal') end).hands)
        assert.equal('Nyame Gauntlets', hands_after('/ma "Drain" <t>', function(gs) gs:gain_buff('Dark Seal') end).hands)
    end)

    it('has it over no spell without Dark Seal', function()
        assert.equal('Nyame Gauntlets', hands_after('/ma "Drain II" <t>').hands)
    end)

    pending('has sets.buff[\'Nether Void\'] over Drain II and Absorb-STR under Nether Void: job_post_midcast in '
        .. 'data/DRK.lua tests (not spell.english == \'Dread Spikes\' and ...), which reads "(not x) == y" and is never '
        .. 'true, so the set is never worn')
end)

describe('DRK\'s weapon skill set', function()
    local function ws(tp, line, setup, wearing)
        local gs = boot({tp = tp, wearing = wearing})
        if setup then
            setup(gs)
        end
        return weaponskill(gs, line)
    end

    local function acc(gs)
        gs:console('gs c set OffenseMode Acc')
    end

    local function at_night(gs)
        gs:set_time(22 * 60)
    end

    it('is sets.precast.WS[name] with no cap TP, Moonshade Earring in it', function()
        local worn = ws(1000, '/ws "Entropy" <t>')
        assert.equal('Moonshade Earring', worn.left_ear)
        assert.equal('Volte Boots', worn.feet)
    end)

    it('swaps Moonshade Earring for sets.DayMaxTPWSEars by day when TP, with Moonshade\'s 250, is over 3200', function()
        assert.equal('Cessance Earring', ws(2951, '/ws "Entropy" <t>').left_ear)
    end)

    it('keeps Moonshade Earring on at 2950 TP', function()
        assert.equal('Moonshade Earring', ws(2950, '/ws "Entropy" <t>').left_ear)
    end)

    it('swaps Moonshade Earring for sets.MaxTP at night', function()
        assert.equal('Lugra Earring', ws(3000, '/ws "Entropy" <t>', at_night).left_ear)
    end)

    it('swaps in sets.AccDayMaxTPWSEars by day in an accuracy offense mode', function()
        local worn = ws(3000, '/ws "Entropy" <t>', acc)
        assert.equal('Odnowa Earring +1', worn.left_ear)
        assert.equal('Adamantite Armor', worn.body)
    end)

    it('swaps in sets.AccMaxTP at night in an accuracy offense mode', function()
        local worn = ws(3000, '/ws "Entropy" <t>', function(gs) at_night(gs) acc(gs) end)
        assert.equal('Lugra Earring', worn.left_ear)
        assert.equal('Adamantite Armor', worn.body)
    end)

    it('has Lugra Earring in the set swapped for sets.DayWSEars by day', function()
        assert.equal('Cessance Earring', ws(1000, '/ws "Torcleaver" <t>', nil, great_sword).left_ear)
    end)

    it('keeps Lugra Earring on at night', function()
        assert.equal('Lugra Earring', ws(1000, '/ws "Torcleaver" <t>', at_night, great_sword).left_ear)
    end)

    it('swaps in sets.AccDayWSEars with Lugra Earring by day in an accuracy offense mode', function()
        assert.equal('Odnowa Earring +1', ws(1000, '/ws "Torcleaver" <t>', acc, great_sword).left_ear)
    end)

    it('swaps in sets.DayWSEars by day below the cap when the set has Moonshade Earring and Lugra Earring', function()
        local worn = ws(1000, '/ws "Cross Reaper" <t>')
        assert.equal('Cessance Earring', worn.left_ear)
        assert.equal('Lugra Earring', worn.right_ear)
    end)

    it('keeps Moonshade Earring on below the cap at night, with Lugra Earring in the set', function()
        assert.equal('Moonshade Earring', ws(1000, '/ws "Cross Reaper" <t>', at_night).left_ear)
    end)

    it('swaps in sets.AccDayWSEars by day below the cap in an accuracy offense mode, with both earrings in the set', function()
        assert.equal('Odnowa Earring +1', ws(1000, '/ws "Cross Reaper" <t>', acc).left_ear)
    end)

    it('swaps in sets.DayWSEars, not sets.AccDayWSEars, under Sneak Attack in an accuracy offense mode', function()
        local worn = ws(1000, '/ws "Cross Reaper" <t>', function(gs)
            acc(gs)
            gs:gain_buff('Sneak Attack')
        end)
        assert.equal('Cessance Earring', worn.left_ear)
    end)

    it('has sets.buff.Souleater laid over it under Souleater', function()
        local worn = ws(1000, '/ws "Entropy" <t>', function(gs) gs:gain_buff('Souleater') end)
        assert.equal("Combatant's Torque", worn.neck)
    end)

    it('has no Souleater set laid over it without Souleater', function()
        assert.equal('Fotia Gorget', ws(1000, '/ws "Entropy" <t>').neck)
    end)
end)

describe('DRK\'s melee set', function()
    local gs
    before_each(function()
        gs = boot()
        gs:engage()
    end)

    it('is sets.engaged', function()
        assert.same(engaged_with({neck = 'Loricate Torque +1'}), gs:worn())
    end)

    it('has sets.buff.Souleater laid over it while Souleater is up', function()
        gs:gain_buff('Souleater')
        assert.same(engaged_with({neck = "Combatant's Torque"}), gs:worn())
        gs:lose_buff('Souleater')
        assert.same(engaged_with({neck = 'Loricate Torque +1'}), gs:worn())
    end)

    it('has no Souleater set laid over it while a defense mode is on', function()
        gs:gain_buff('Souleater')
        gs:console('gs c set DefenseMode Physical')
        assert.same(engaged_with({head = 'Null Masque', waist = 'Null Belt', neck = 'Loricate Torque +1'}), gs:worn())
    end)

    it('has sets.buff.Souleater over the hybrid set too', function()
        gs:console('gs c set HybridMode DT')
        gs:gain_buff('Souleater')
        assert.same(engaged_with({head = 'Null Masque', neck = "Combatant's Torque"}), gs:worn())
    end)
end)

describe('DRK\'s idle set', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('has sets.latent_refresh over it under 51% MP', function()
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 400, 40
        gs:console('gs c update')
        assert.same(jobby.worn_by(idle, {waist = 'Null Belt'}), gs:worn())
    end)

    it('has no latent refresh set over it at 51% MP', function()
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 510, 51
        gs:console('gs c update')
        assert.same(jobby.worn_by(idle), gs:worn())
    end)

    it('has no latent refresh set over it in the DT idle mode', function()
        gs:console('gs c set IdleMode DT')
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 400, 40
        gs:console('gs c update')
        assert.same(jobby.worn_by(idle), gs:worn())
    end)
end)

describe('DRK\'s Sleep timers', function()
    local function timers(spell, options)
        local gs = boot({sub_job = 'BLM'})
        if options and options.timers_off then
            gs:console('gs c toggle UseCustomTimers')
        end
        gs:commands()
        gs:type('/ma "' .. spell .. '" <t>')
        gs:finish_action()
        return gs:commands()
    end

    it('starts a 60 second timer on the target when Sleep lands', function()
        assert.same({'timers c "Sleep [Apex Toad]" 60 down spells/00220.png'}, timers('Sleep'))
    end)

    it('starts a 60 second timer when Sleepga lands', function()
        assert.same({'timers c "Sleepga [Apex Toad]" 60 down spells/00220.png'}, timers('Sleepga'))
    end)

    it('starts no timer with Use Custom Timers off', function()
        assert.same({}, timers('Sleep', {timers_off = true}))
        assert.same({}, timers('Sleepga', {timers_off = true}))
    end)

    it('starts no timer when Sleep is interrupted', function()
        local gs = boot({sub_job = 'BLM'})
        gs:type('/ma "Sleep" <t>')
        gs:interrupt_action()
        assert.same({}, gs:commands())
    end)
end)

describe('DRK\'s tick with Samurai as the sub job', function()
    local function boot_hasso(options)
        options = options or {}
        options.sub_job = 'SAM'
        local gs = boot_ticking(options)
        gs:console('gs c set Weapons Ragnarok')
        gs:engage()
        gs:traffic()
        return gs
    end

    it('uses Hasso engaged with a two-handed weapon', function()
        local gs = boot_hasso()
        gs:play_until_action()
        assert.same({'Hasso'}, gs:actions())
    end)

    it('uses Seigan when the Stance is Seigan', function()
        local gs = boot_hasso()
        gs:console('gs c set Stance Seigan')
        gs:play_until_action()
        assert.same({'Seigan'}, gs:actions())
    end)

    it('uses nothing when the Stance is None', function()
        local gs = boot_hasso()
        gs:console('gs c set Stance None')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses nothing with Hasso up', function()
        local gs = boot_hasso()
        gs:gain_buff('Hasso')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses nothing with Seigan up', function()
        local gs = boot_hasso()
        gs:gain_buff('Seigan')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses nothing while Hasso is on recast', function()
        local gs = boot_hasso()
        gs.game:start_ability_recast('Hasso', 30)
        gs:chat()
        gs:play(3)
        assert.same({}, gs:actions())
        assert.same({}, gs:chat())
    end)

    it('uses nothing with a one-handed weapon', function()
        local gs = boot_hasso()
        gs:console('gs c set Weapons Naegling')
        gs:traffic()
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses nothing while the sub job\'s abilities are restricted', function()
        local gs = boot_hasso()
        gs:gain_buff('SJ Restriction')
        gs:play(3)
        assert.same({}, gs:actions())
    end)
end)

describe('DRK\'s stance', function()
    it('is set to None on an update without Samurai as the sub job', function()
        local gs = boot({sub_job = 'WHM'})
        gs:console('gs c set Stance Seigan')
        assert.equal('Seigan', gs.user.state.Stance.value)
        gs:console('gs c update')
        assert.equal('None', gs.user.state.Stance.value)
    end)

    it('is left alone on an update with Samurai as the sub job', function()
        local gs = boot({sub_job = 'SAM'})
        gs:console('gs c set Stance Seigan')
        gs:console('gs c update')
        assert.equal('Seigan', gs.user.state.Stance.value)
    end)
end)

describe('DRK\'s Auto Buff Mode in a fight', function()
    local function buffing(options, keep_ws_buff_list)
        local gs = boot_ticking(options)
        if not keep_ws_buff_list then
            gs.user.ws_buff_list = nil
        end
        gs:console('gs c set AutoBuffMode Auto')
        gs:monster_hits()
        return gs
    end

    -- Dread Spikes, a spell the Auto buff list casts in a fight, is up.
    local buffed = {'Dread Spikes'}

    it('starts with Last Resort', function()
        local gs = buffing({buffs = buffed})
        gs:play_until_action()
        assert.same({'Last Resort'}, gs:actions())
    end)

    it('goes on to Scarlet Delirium with Last Resort up', function()
        local gs = buffing({buffs = buffed})
        gs:gain_buff('Last Resort')
        gs:play_until_action()
        assert.same({'Scarlet Delirium'}, gs:actions())
    end)

    it('uses nothing with both up and no War sub job', function()
        local gs = buffing({buffs = buffed})
        gs:gain_buff('Last Resort')
        gs:gain_buff('Scarlet Delirium')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('goes on to Berserk with a War sub job', function()
        local gs = buffing({sub_job = 'WAR', buffs = buffed})
        gs:gain_buff('Last Resort')
        gs:gain_buff('Scarlet Delirium')
        gs:play_until_action()
        assert.same({'Berserk'}, gs:actions())
    end)

    it('goes on to Aggressor with a War sub job and Berserk up', function()
        local gs = buffing({sub_job = 'WAR', buffs = buffed})
        gs:gain_buff('Last Resort')
        gs:gain_buff('Scarlet Delirium')
        gs:gain_buff('Berserk')
        gs:play_until_action()
        assert.same({'Aggressor'}, gs:actions())
    end)

    it('passes over Last Resort while it is on recast', function()
        local gs = buffing({buffs = buffed})
        gs.game:start_ability_recast('Last Resort', 60)
        gs:play_until_action()
        assert.same({'Scarlet Delirium'}, gs:actions())
    end)

    it('leaves Last Resort to the weapon skills when the gear file has an Auto WS Buff list', function()
        local gs = buffing({buffs = buffed}, true)
        gs:play_until_action()
        assert.same({'Scarlet Delirium'}, gs:actions())
    end)

    it('leaves Berserk and Aggressor, a War sub job\'s, to the weapon skills too when the gear file has an Auto WS '
        .. 'Buff list', function()
        local gs = buffing({sub_job = 'WAR', buffs = buffed}, true)
        gs:gain_buff('Scarlet Delirium')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses Last Resort again with Auto WS Buff off', function()
        local gs = buffing({buffs = buffed}, true)
        gs:console('gs c toggle AutoWSBuff')
        gs:play_until_action()
        assert.same({'Last Resort'}, gs:actions())
    end)

    it('uses nothing out of a fight', function()
        local gs = boot_ticking({buffs = buffed})
        gs.user.ws_buff_list = nil
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses nothing with Auto Buff Mode off', function()
        local gs = buffing({buffs = buffed})
        gs:console('gs c set AutoBuffMode Off')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    pending('uses no Berserk or Aggressor while the sub job\'s abilities are restricted: job_check_buff in '
        .. 'data/DRK.lua checks only that the sub job is Warrior, so it tries Berserk under SJ Restriction')
end)

describe('DRK\'s buff spells', function()
    it('Auto Buff Mode casts Dread Spikes in a fight', function()
        local gs = boot_ticking({buffs = {'Last Resort', 'Scarlet Delirium'}})
        gs:console('gs c set AutoBuffMode Auto')
        gs:monster_hits()
        gs:play_until_action()
        assert.same({'Dread Spikes'}, gs:actions())
    end)

    it('Auto Buff Mode casts no Dread Spikes out of a fight', function()
        local gs = boot_ticking()
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('buff up casts Dread Spikes from the Default list', function()
        local gs = boot_ticking()
        gs:console('gs c buffup')
        gs:play_until_action()
        assert.same({'Dread Spikes'}, gs:actions())
    end)
end)

describe('DRK\'s buff states', function()
    it('follow the buffs as they come and go', function()
        local gs = boot()
        gs:gain_buff('Dark Seal')
        assert.is_true(gs.user.state.Buff['Dark Seal'])
        gs:lose_buff('Dark Seal')
        assert.is_false(gs.user.state.Buff['Dark Seal'])
    end)

    it('start with Drain Swap Weapon Mode Never', function()
        assert.equal('Never', boot().user.state.DrainSwapWeaponMode.value)
    end)
end)
