local jobby = require('jobby')

local gear = {'Naegling', 'Conqueror', 'Volte Cap', 'Null Masque', 'Volte Jupon', 'Adamantite Armor',
    'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Fotia Gorget', "Combatant's Torque", 'Null Belt',
    'Moonshade Earring', 'Brutal Earring', 'Lugra Earring', 'Cessance Earring', 'Odnowa Earring +1', 'Karieyh Ring',
    'Chirich Ring +1'}

local great_sword = {'Hard Slash', 'Resolution', 'Ground Strike'}

-- What the idle set of Jobby's warrior gear file wears, as the game shows it worn, with his great sword in hand.
local idle = jobby.worn_by(jobby.full_idle, jobby.weapons.WAR)

local function boot(options)
    options = options or {}
    options.items = gear
    return jobby.boot('WAR', options)
end

local function boot_ticking(options)
    options = options or {}
    options.items = gear
    return jobby.boot_ticking('WAR', options)
end

-- Jobby in a fight with Auto Buff Mode on.
local function boot_buffing(options)
    local gs = boot_ticking(options)
    gs:console('gs c set AutoBuffMode Auto')
    gs:monster_hits()
    return gs
end

-- What is worn once the weapon skill typed has gone out: its precast set over what was on before.
local function weaponskill(gs, line)
    gs:type(line)
    assert.same({line:match('^/ws "(.-)"')}, gs:actions(), 'the weapon skill typed didn\'t go out')
    return gs:worn()
end

local function with_ws(changes)
    return jobby.worn_by(idle, changes)
end

describe('WAR\'s weapon skill filter', function()
    it('sends Resolution in place of Upheaval when Jobby has the great sword weapon skills', function()
        local gs = boot({tp = 1000, abilities = great_sword})
        assert.is_true(gs:type('/ws "Upheaval" <t>'))
        assert.same({
            {equip = {head = 'Volte Cap', neck = 'Fotia Gorget', left_ear = 'Moonshade Earring',
                right_ear = 'Brutal Earring', hands = 'Volte Bracers'}},
            {action = 'Resolution', target = 'Apex Toad'},
        }, gs:traffic())
    end)

    it('sends Ground Strike in place of Ukko\'s Fury', function()
        local gs = boot({tp = 1000, abilities = great_sword})
        gs:type('/ws "Ukko\'s Fury" <t>')
        assert.same({'Ground Strike'}, gs:actions())
    end)

    it('sends nothing in place of Upheaval when Jobby hasn\'t Hard Slash, which the job file takes for a great '
        .. 'sword', function()
        local gs = boot({tp = 1000, abilities = {'Resolution'}})
        gs:type('/ws "Upheaval" <t>')
        assert.same({}, gs:traffic())
        assert.same({}, gs:typed())
    end)

    it('lets a weapon skill Jobby has go out as it is', function()
        local gs = boot({tp = 1000, abilities = great_sword})
        gs:type('/ws "Ground Strike" <t>')
        assert.same({'Ground Strike'}, gs:actions())
    end)
end)

describe('WAR\'s Berserk', function()
    local function berserk(tp, conqueror_mode)
        local gs = boot({tp = tp})
        gs:console('gs c set Weapons Naegling')
        if conqueror_mode then
            gs:console('gs c set ConquerorMode ' .. conqueror_mode)
        end
        gs:type('/ja "Berserk" <me>')
        return gs
    end

    it('puts Conqueror on through the weapon lock while TP is under 250, the first Conqueror Mode', function()
        local gs = berserk(0)
        assert.same(with_ws({main = 'Conqueror', body = 'Volte Jupon'}), gs:worn())
    end)

    it('leaves the weapon set\'s main on with TP of 250 or more', function()
        local gs = berserk(250)
        assert.same(with_ws({main = 'Naegling', body = 'Volte Jupon'}), gs:worn())
    end)

    it('puts Conqueror on in Conqueror Mode 1000 with TP under 1000', function()
        local gs = berserk(999, '1000')
        assert.equal('Conqueror', gs:worn().main)
    end)

    it('puts Conqueror on in Conqueror Mode Always at any TP', function()
        local gs = berserk(3000, 'Always')
        assert.equal('Conqueror', gs:worn().main)
    end)

    it('never puts Conqueror on in Conqueror Mode Never', function()
        local gs = berserk(0, 'Never')
        assert.equal('Naegling', gs:worn().main)
    end)

    it('puts the weapon set\'s main back once Berserk is done', function()
        local gs = berserk(0)
        gs:finish_action()
        assert.same(jobby.worn_by(idle, {main = 'Naegling'}), gs:worn())
    end)

    pending('goes out in Conqueror Mode Always without Conqueror: job_precast in data/WAR.lua then compares the TP '
        .. 'with tonumber(\'Always\'), which is nil, and raises a Lua error')
end)

describe('WAR\'s weapon skill under Auto Buff Mode', function()
    local gs
    before_each(function()
        gs = boot({tp = 1500})
        gs:console('gs c set AutoBuffMode Auto')
    end)

    it('is held for Warcry when TP is under 2250 and Warcry is ready', function()
        gs:type('/ws "Resolution" <t>')
        assert.same({
            {equip = {head = 'Null Masque'}},
            {action = 'Warcry', target = 'Jobby'},
        }, gs:traffic())
    end)

    it('goes out 1.1 seconds after Warcry, which Sel counts as up once it is used', function()
        gs:type('/ws "Resolution" <t>')
        gs:traffic()
        gs:finish_action()
        gs:advance(1.05)
        assert.same({}, gs:actions())
        gs:advance(0.1)
        assert.same({'Resolution'}, gs:actions())
    end)

    it('goes out at once with Warcry up', function()
        gs:gain_buff('Warcry')
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, gs:actions())
    end)

    it('goes out at once with Blood Rage up', function()
        gs:gain_buff('Blood Rage')
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, gs:actions())
    end)

    it('goes out at once while Warcry is on recast', function()
        gs.game:start_ability_recast('Warcry', 60)
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, gs:actions())
    end)

    it('is held for Warcry at 2249 TP', function()
        gs.game.player.vitals.tp = 2249
        gs:type('/ws "Resolution" <t>')
        assert.same({'Warcry'}, gs:actions())
    end)

    it('goes out at once with 2250 TP', function()
        gs.game.player.vitals.tp = 2250
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, gs:actions())
    end)

    it('goes out at once with Auto Buff Mode off', function()
        gs:console('gs c set AutoBuffMode Off')
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, gs:actions())
    end)
end)

describe('WAR\'s weapon skill under Auto Buff Mode with Samurai as the sub job', function()
    local gs
    before_each(function()
        gs = boot({tp = 2500, sub_job = 'SAM'})
        gs:console('gs c set AutoBuffMode Auto')
    end)

    it('is held for Sekkanoki with over 1850 TP', function()
        gs:type('/ws "Resolution" <t>')
        assert.same({'Sekkanoki'}, gs:actions())
    end)

    it('is held for Meditate when Sekkanoki is on recast', function()
        gs.game:start_ability_recast('Sekkanoki', 60)
        gs:type('/ws "Resolution" <t>')
        assert.same({'Meditate'}, gs:actions())
    end)

    it('is held for Meditate with 1850 TP or less', function()
        gs.game.player.vitals.tp = 1850
        gs:gain_buff('Warcry')
        gs:type('/ws "Resolution" <t>')
        assert.same({'Meditate'}, gs:actions())
    end)

    it('goes out when Sekkanoki and Meditate are both on recast', function()
        gs.game:start_ability_recast('Sekkanoki', 60)
        gs.game:start_ability_recast('Meditate', 60)
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, gs:actions())
    end)

    it('goes out when the sub job\'s abilities are restricted', function()
        gs:gain_buff('SJ Restriction')
        gs:type('/ws "Resolution" <t>')
        assert.same({'Resolution'}, gs:actions())
    end)

    it('is held for Sekkanoki, then Meditate, then goes out', function()
        gs:type('/ws "Resolution" <t>')
        assert.same({'Sekkanoki'}, gs:actions())
        gs:finish_action()
        gs.game:start_ability_recast('Sekkanoki', 60)
        gs:advance(1.2)
        assert.same({'Meditate'}, gs:actions())
        gs:finish_action()
        gs.game:start_ability_recast('Meditate', 60)
        gs:advance(1.2)
        assert.same({'Resolution'}, gs:actions())
    end)
end)

describe('WAR\'s melee set', function()
    local gs
    before_each(function()
        gs = boot()
        gs:engage()
    end)

    it('is sets.engaged', function()
        assert.same(jobby.worn_by(idle, {head = 'Volte Cap', body = 'Volte Jupon'}), gs:worn())
    end)

    it('has sets.buff.Retaliation laid over it while Retaliation is up', function()
        gs:gain_buff('Retaliation')
        assert.same(jobby.worn_by(idle,
            {head = 'Volte Cap', body = 'Volte Jupon', waist = 'Null Belt'}), gs:worn())
        gs:lose_buff('Retaliation')
        assert.same(jobby.worn_by(idle, {head = 'Volte Cap', body = 'Volte Jupon'}), gs:worn())
    end)

    it('has sets.buff.Restraint laid over it while Restraint is up', function()
        gs:gain_buff('Restraint')
        assert.same(jobby.worn_by(idle,
            {head = 'Volte Cap', body = 'Volte Jupon', ring1 = 'Karieyh Ring'}), gs:worn())
    end)

    it('has both laid over it with both buffs up', function()
        gs:gain_buff('Retaliation')
        gs:gain_buff('Restraint')
        assert.same(jobby.worn_by(idle, {head = 'Volte Cap', body = 'Volte Jupon', waist = 'Null Belt',
            ring1 = 'Karieyh Ring'}), gs:worn())
    end)

    it('leaves the buff sets off in an accuracy offense mode', function()
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Retaliation')
        gs:gain_buff('Restraint')
        assert.same(jobby.worn_by(idle, {head = 'Volte Cap', body = 'Adamantite Armor'}), gs:worn())
    end)

    it('leaves the buff sets off in a hybrid mode', function()
        gs:console('gs c set HybridMode DT')
        gs:gain_buff('Retaliation')
        gs:gain_buff('Restraint')
        assert.same(jobby.worn_by(idle, {head = 'Null Masque', body = 'Volte Jupon'}), gs:worn())
    end)

    it('is sets.engaged.Charge with Brazen Rush up', function()
        gs:gain_buff('Brazen Rush')
        assert.same(jobby.worn_by(idle,
            {head = 'Volte Cap', body = 'Volte Jupon', hands = 'Volte Bracers'}), gs:worn())
    end)

    it('is sets.engaged.Charge with Warrior\'s Charge up', function()
        gs:gain_buff('Warrior\'s Charge')
        assert.same(jobby.worn_by(idle,
            {head = 'Volte Cap', body = 'Volte Jupon', hands = 'Volte Bracers'}), gs:worn())
    end)

    it('is sets.engaged.Mighty with Mighty Strikes up', function()
        gs:gain_buff('Mighty Strikes')
        assert.same(jobby.worn_by(idle,
            {head = 'Volte Cap', body = 'Volte Jupon', legs = 'Volte Hose'}), gs:worn())
    end)

    it('is sets.engaged.Charge.Mighty with both up', function()
        gs:gain_buff('Brazen Rush')
        gs:gain_buff('Mighty Strikes')
        assert.same(jobby.worn_by(idle, {head = 'Volte Cap', body = 'Volte Jupon', hands = 'Volte Bracers',
            feet = 'Volte Boots'}), gs:worn())
    end)

    it('goes back to sets.engaged when the buffs end', function()
        gs:gain_buff('Brazen Rush')
        gs:gain_buff('Mighty Strikes')
        gs:lose_buff('Brazen Rush')
        gs:lose_buff('Mighty Strikes')
        assert.same(jobby.worn_by(idle, {head = 'Volte Cap', body = 'Volte Jupon'}), gs:worn())
    end)
end)

describe('WAR\'s weapon skill set', function()
    local gs
    before_each(function()
        gs = boot({tp = 1000})
        gs:engage()
    end)

    it('is sets.precast.WS[name] with no cap TP, Moonshade Earring in it', function()
        assert.same(jobby.worn_by(idle, {head = 'Volte Cap', body = 'Volte Jupon', neck = 'Fotia Gorget',
            ear1 = 'Moonshade Earring', ear2 = 'Brutal Earring', hands = 'Volte Bracers'}),
            weaponskill(gs, '/ws "Resolution" <t>'))
    end)

    it('swaps Moonshade Earring for sets.DayMaxTPWSEars by day when TP, with Moonshade\'s 250, is over 3200', function()
        gs.game.player.vitals.tp = 2951
        assert.same(jobby.worn_by(idle, {head = 'Volte Cap', body = 'Volte Jupon', neck = 'Fotia Gorget',
            ear1 = 'Cessance Earring', ear2 = 'Brutal Earring', hands = 'Volte Bracers'}),
            weaponskill(gs, '/ws "Resolution" <t>'))
    end)

    it('keeps Moonshade Earring on at 2950 TP, which Moonshade makes 3200', function()
        gs.game.player.vitals.tp = 2950
        assert.equal('Moonshade Earring', weaponskill(gs, '/ws "Resolution" <t>').left_ear)
    end)

    it('swaps Moonshade Earring for sets.MaxTP at night', function()
        gs:set_time(22 * 60)
        gs.game.player.vitals.tp = 3000
        assert.equal('Lugra Earring', weaponskill(gs, '/ws "Resolution" <t>').left_ear)
    end)

    it('swaps in sets.AccDayMaxTPWSEars by day when the offense mode is an accuracy one', function()
        gs:console('gs c set OffenseMode Acc')
        gs.game.player.vitals.tp = 3000
        local worn = weaponskill(gs, '/ws "Resolution" <t>')
        assert.equal('Odnowa Earring +1', worn.left_ear)
        assert.equal('Adamantite Armor', worn.body)
    end)

    it('swaps in sets.AccMaxTP at night when the offense mode is an accuracy one', function()
        gs:set_time(22 * 60)
        gs:console('gs c set OffenseMode Acc')
        gs.game.player.vitals.tp = 3000
        local worn = weaponskill(gs, '/ws "Resolution" <t>')
        assert.equal('Lugra Earring', worn.left_ear)
        assert.equal('Adamantite Armor', worn.body)
    end)

    it('swaps in sets.DayMaxTPWSEars, not sets.AccDayMaxTPWSEars, by day under Sneak Attack in an accuracy offense mode', function()
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Sneak Attack')
        gs.game.player.vitals.tp = 3000
        local worn = weaponskill(gs, '/ws "Resolution" <t>')
        assert.equal('Cessance Earring', worn.left_ear)
    end)

    it('has Lugra Earring in the set swapped for sets.DayWSEars by day', function()
        assert.equal('Cessance Earring', weaponskill(gs, '/ws "Ground Strike" <t>').left_ear)
    end)

    it('keeps Lugra Earring on at night', function()
        gs:set_time(22 * 60)
        assert.equal('Lugra Earring', weaponskill(gs, '/ws "Ground Strike" <t>').left_ear)
    end)

    it('swaps in sets.AccDayWSEars with Lugra Earring by day in an accuracy offense mode', function()
        gs:console('gs c set OffenseMode Acc')
        assert.equal('Odnowa Earring +1', weaponskill(gs, '/ws "Ground Strike" <t>').left_ear)
    end)

    -- Upheaval is a great axe's.
    local function upheaval(gs)
        gs:console('gs c set Weapons Conqueror')
        return weaponskill(gs, '/ws "Upheaval" <t>')
    end

    it('swaps in sets.DayWSEars by day below the cap when the set has Moonshade Earring and Lugra Earring', function()
        local worn = upheaval(gs)
        assert.equal('Cessance Earring', worn.left_ear)
        assert.equal('Lugra Earring', worn.right_ear)
    end)

    it('keeps Moonshade Earring on below the cap at night, with Lugra Earring in the set', function()
        gs:set_time(22 * 60)
        local worn = upheaval(gs)
        assert.equal('Moonshade Earring', worn.left_ear)
        assert.equal('Lugra Earring', worn.right_ear)
    end)

    it('swaps in sets.AccDayWSEars by day below the cap in an accuracy offense mode, with both earrings in the set', function()
        gs:console('gs c set OffenseMode Acc')
        assert.equal('Odnowa Earring +1', upheaval(gs).left_ear)
    end)

    it('swaps in sets.DayWSEars, not sets.AccDayWSEars, under Sneak Attack in an accuracy offense mode', function()
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Sneak Attack')
        assert.equal('Cessance Earring', upheaval(gs).left_ear)
    end)

    pending('has sets.WSCharge laid over it under Brazen Rush or Warrior\'s Charge: job_post_precast in data/WAR.lua '
        .. 'keeps to state.Buff.Charge, which job_setup never defines, so Sel never sets it for either buff')
end)

describe('WAR\'s tick with Samurai as the sub job', function()
    local function boot_hasso(options)
        options = options or {}
        options.sub_job = 'SAM'
        local gs = boot_ticking(options)
        gs:console('gs c set Weapons Conqueror')
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

    it('uses nothing out of combat', function()
        local gs = boot_hasso()
        gs:disengage()
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

describe('WAR\'s tick without Samurai as the sub job', function()
    it('uses no Hasso', function()
        local gs = boot_ticking({sub_job = 'WHM'})
        gs:console('gs c set Weapons Conqueror')
        gs:engage()
        gs:traffic()
        gs:play(3)
        assert.same({}, gs:actions())
    end)
end)

describe('WAR\'s stance', function()
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

describe('WAR\'s Auto Buff Mode in a fight', function()
    it('starts with Retaliation', function()
        local gs = boot_buffing()
        gs:play_until_action()
        assert.same({'Retaliation'}, gs:actions())
    end)

    it('goes on to Restraint with Retaliation up', function()
        local gs = boot_buffing()
        gs:gain_buff('Retaliation')
        gs:play_until_action()
        assert.same({'Restraint'}, gs:actions())
    end)

    it('goes on to Blood Rage with both up', function()
        local gs = boot_buffing()
        gs:gain_buff('Retaliation')
        gs:gain_buff('Restraint')
        gs:play_until_action()
        assert.same({'Blood Rage'}, gs:actions())
    end)

    it('skips Blood Rage with Warcry up and goes on to Berserk', function()
        local gs = boot_buffing()
        gs:gain_buff('Retaliation')
        gs:gain_buff('Restraint')
        gs:gain_buff('Warcry')
        gs:play_until_action()
        assert.same({'Berserk'}, gs:actions())
    end)

    it('goes on to Berserk with Blood Rage up', function()
        local gs = boot_buffing()
        gs:gain_buff('Retaliation')
        gs:gain_buff('Restraint')
        gs:gain_buff('Blood Rage')
        gs:play_until_action()
        assert.same({'Berserk'}, gs:actions())
    end)

    it('ends with Aggressor', function()
        local gs = boot_buffing()
        for _, buff in ipairs({'Retaliation', 'Restraint', 'Blood Rage', 'Berserk'}) do
            gs:gain_buff(buff)
        end
        gs:play_until_action()
        assert.same({'Aggressor'}, gs:actions())
    end)

    it('uses nothing once every buff is up', function()
        local gs = boot_buffing()
        for _, buff in ipairs({'Retaliation', 'Restraint', 'Blood Rage', 'Berserk', 'Aggressor'}) do
            gs:gain_buff(buff)
        end
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('passes over an ability on recast', function()
        local gs = boot_buffing()
        gs.game:start_ability_recast('Retaliation', 20)
        gs:play_until_action()
        assert.same({'Restraint'}, gs:actions())
    end)

    it('uses nothing out of a fight', function()
        local gs = boot_ticking()
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses nothing with Auto Buff Mode off', function()
        local gs = boot_buffing()
        gs:console('gs c set AutoBuffMode Off')
        gs:play(3)
        assert.same({}, gs:actions())
    end)
end)

describe('WAR\'s Warcry bookkeeping', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('notes Jobby as the one who used Warcry once it is used', function()
        gs:type('/ja "Warcry" <me>')
        gs:finish_action()
        assert.equal('Jobby', gs.user.lastwarcry)
    end)

    it('notes Jobby when Warcry comes up with its recast just started', function()
        gs.game:start_ability_recast('Warcry', 298)
        gs:gain_buff('Warcry')
        assert.equal('Jobby', gs.user.lastwarcry)
    end)

    it('notes nobody when Warcry comes up from another\'s use', function()
        gs.user.lastwarcry = 'Jobby'
        gs.game:start_ability_recast('Warcry', 297)
        gs:gain_buff('Warcry')
        assert.equal('', gs.user.lastwarcry)
    end)

    it('notes nobody when Warcry ends', function()
        gs.game:start_ability_recast('Warcry', 298)
        gs:gain_buff('Warcry')
        gs:lose_buff('Warcry')
        assert.equal('', gs.user.lastwarcry)
    end)
end)

describe('WAR\'s buff states', function()
    it('follow the buffs Jobby has when the file loads', function()
        local gs = boot({buffs = {'Berserk', 'Hasso'}})
        assert.is_truthy(gs.user.state.Buff.Berserk)
        assert.is_truthy(gs.user.state.Buff.Hasso)
        assert.is_falsy(gs.user.state.Buff.Aggressor)
    end)

    it('follow the buffs as they come and go', function()
        local gs = boot()
        gs:gain_buff('Mighty Strikes')
        assert.is_true(gs.user.state.Buff['Mighty Strikes'])
        gs:lose_buff('Mighty Strikes')
        assert.is_false(gs.user.state.Buff['Mighty Strikes'])
    end)
end)

describe('WAR\'s weapon skill set with state.Buff.Charge kept', function()
    local gs
    before_each(function()
        gs = boot({tp = 1000})
        gs.user.state.Buff.Charge = true
    end)

    it('has sets.WSCharge laid over it', function()
        assert.equal("Combatant's Torque", weaponskill(gs, '/ws "Resolution" <t>').neck)
    end)

    it('has sets.WSMightyCharge laid over it in place of sets.WSCharge with Mighty Strikes up too', function()
        gs:gain_buff('Mighty Strikes')
        local worn = weaponskill(gs, '/ws "Resolution" <t>')
        assert.equal('Volte Boots', worn.feet)
        assert.equal('Fotia Gorget', worn.neck)
    end)

    it('has sets.ACCWSCharge laid over it in an accuracy offense mode', function()
        gs:console('gs c set OffenseMode Acc')
        assert.equal('Null Belt', weaponskill(gs, '/ws "Resolution" <t>').waist)
    end)

    it('has sets.ACCWSMightyCharge laid over it in an accuracy offense mode with Mighty Strikes up too', function()
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Mighty Strikes')
        assert.equal('Karieyh Ring', weaponskill(gs, '/ws "Resolution" <t>').left_ring)
    end)

    it('has the plain sets laid over it under Sneak Attack in an accuracy offense mode', function()
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Sneak Attack')
        gs:gain_buff('Mighty Strikes')
        assert.equal('Volte Boots', weaponskill(gs, '/ws "Resolution" <t>').feet)
    end)
end)

-- Not engaged, as sets.engaged.Mighty wears sets.WSMighty's legs too.
describe('WAR\'s weapon skill set under Mighty Strikes', function()
    local gs
    before_each(function()
        gs = boot({tp = 1000})
    end)

    it('has sets.WSMighty laid over it', function()
        gs:gain_buff('Mighty Strikes')
        assert.equal('Volte Hose', weaponskill(gs, '/ws "Resolution" <t>').legs)
    end)

    it('has no sets.WSMighty laid over it without Mighty Strikes', function()
        assert.equal('Nyame Flanchard', weaponskill(gs, '/ws "Resolution" <t>').legs)
    end)

    it('has sets.AccWSMighty laid over it in an accuracy offense mode when the gear file names sets.ACCWSMighty too, '
        .. 'as the job file tests that one', function()
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Mighty Strikes')
        assert.equal('Chirich Ring +1', weaponskill(gs, '/ws "Resolution" <t>').right_ring)
    end)

    pending('has sets.AccWSMighty laid over it in an accuracy offense mode when the gear file names only that: '
        .. 'job_post_precast in data/WAR.lua tests sets.ACCWSMighty and equips sets.AccWSMighty')
end)
