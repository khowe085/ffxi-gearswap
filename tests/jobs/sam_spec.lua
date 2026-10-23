local harness = require('harness')
local jobby = require('jobby')

local gear = {'Masamune', "Judge's Sword", 'Mecisto. Mantle', "Bendis's Hairpin", "Theia's Hairpin",
    'Sapphire Platemail', 'Jadeite Cuirie', 'Sapphire Gauntlets', 'Jadeite Gloves', 'Sapphire Trousers',
    'Jadeite Chausses', 'Diamond Haramaki', 'Sapphire Leggings', 'Jadeite Jambeaux', 'Diamond Kote', 'Diamond Hiza.',
    'Diamond Sune-Ate', "Orunmila's Torque", 'Moonshade Earring', 'Lugra Earring +1', 'Ishvara Earring',
    'Brutal Earring', "Hecate's Earring", 'Pixie Earring', 'Beastly Earring', 'Stealth Earring', 'Volte Bracers',
    'Volte Hose', 'Volte Jupon', 'Pitchfork +1'}

-- What the idle set of Jobby's samurai gear file wears besides every gear file's.
local own_idle = {main = 'Masamune', back = 'Mecisto. Mantle'}

local idle = jobby.worn_by(jobby.idle, own_idle)

-- What is worn with these changes over the idle set.
local function worn(changes)
    return jobby.worn_by(idle, changes)
end

-- Jobby as a samurai with the idle set on, over a sub job of WAR unless the options (jobby.boot's) say otherwise.
local function boot(options)
    options = options or {}
    options.items = gear
    options.wearing = own_idle
    options.sub_job = options.sub_job or 'WAR'
    return jobby.boot('SAM', options)
end

describe('data/SAM.lua', function()
    it('takes Hasso as the stance', function()
        local gs = boot()
        assert.equal('Hasso', gs.user.state.Stance.value)
    end)
end)

describe('SAM\'s weapon skill with AutoBuffMode off', function()
    it('goes out with its set, whatever the TP and recasts', function()
        local gs = boot()
        gs:set_tp(3000)
        assert.is_true(gs:type('/ws "Tachi: Shoha" <t>'))
        assert.same({
            {equip = {head = "Theia's Hairpin", neck = "Orunmila's Torque", hands = 'Volte Bracers',
                legs = 'Volte Hose'}},
            {action = 'Tachi: Shoha', target = 'Apex Toad'},
        }, gs:traffic())
    end)
end)

describe('SAM\'s weapon skill with AutoBuffMode on', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set AutoBuffMode Auto')
        gs:traffic()
    end)

    it('is held back for Sekkanoki with more than 1850 TP', function()
        gs:set_tp(1851)
        assert.is_true(gs:type('/ws "Tachi: Shoha" <t>'))
        assert.same({{action = 'Sekkanoki', target = 'Jobby'}}, gs:traffic())
    end)

    it('is held back for Meditate with 1850 TP or less', function()
        gs:set_tp(1850)
        gs:type('/ws "Tachi: Shoha" <t>')
        assert.same({{action = 'Meditate', target = 'Jobby'}}, gs:traffic())
    end)

    it('is held back for Meditate when Sekkanoki is on recast', function()
        gs:set_tp(3000)
        gs.game:start_ability_recast('Sekkanoki', 60)
        gs:type('/ws "Tachi: Shoha" <t>')
        assert.same({{action = 'Meditate', target = 'Jobby'}}, gs:traffic())
    end)

    it('is held back for Hagakure with less than 1500 TP once Meditate is on recast', function()
        gs:set_tp(1499)
        gs.game:start_ability_recast('Meditate', 60)
        gs:type('/ws "Tachi: Shoha" <t>')
        assert.same({{action = 'Hagakure', target = 'Jobby'}}, gs:traffic())
    end)

    it('is not held back for Hagakure with 1500 TP', function()
        gs:set_tp(1500)
        gs.game:start_ability_recast('Meditate', 60)
        gs:type('/ws "Tachi: Shoha" <t>')
        assert.same({'Tachi: Shoha'}, gs:actions())
    end)

    it('is not held back for Hagakure while Sekkanoki is up', function()
        gs:set_tp(1499)
        gs.game:start_ability_recast('Meditate', 60)
        gs:gain_buff('Sekkanoki')
        gs:traffic()
        gs:type('/ws "Tachi: Shoha" <t>')
        assert.same({'Tachi: Shoha'}, gs:actions())
    end)

    it('goes out when Sekkanoki, Meditate and Hagakure are all on recast', function()
        gs:set_tp(1000)
        gs.game:start_ability_recast('Sekkanoki', 60)
        gs.game:start_ability_recast('Meditate', 60)
        gs.game:start_ability_recast('Hagakure', 60)
        gs:type('/ws "Tachi: Shoha" <t>')
        assert.same({'Tachi: Shoha'}, gs:actions())
    end)

    it('is typed again 1.1 seconds after Sekkanoki goes out, and then waits for Meditate', function()
        gs:set_tp(3000)
        gs:type('/ws "Tachi: Shoha" <t>')
        gs:traffic()
        gs.game:start_ability_recast('Sekkanoki', 60)
        gs:finish_action()
        gs:advance(1.0)
        assert.same({}, gs:actions())
        gs:advance(0.2)
        assert.same({'Meditate'}, gs:actions())
    end)

    it('is typed again after Sekkanoki and Meditate, and goes out', function()
        gs:set_tp(3000)
        gs:type('/ws "Tachi: Shoha" <t>')
        gs.game:start_ability_recast('Sekkanoki', 60)
        gs:finish_action()
        gs:advance(1.2)
        gs.game:start_ability_recast('Meditate', 60)
        gs:finish_action()
        gs:traffic()
        gs:advance(1.2)
        assert.same({'Tachi: Shoha'}, gs:actions())
    end)
end)

describe('SAM\'s weapon skill typed with a spear in hand', function()
    -- The game lists a spear's weapon skills, Double Thrust among them, and no Tachi.
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set Weapons Spear')
        gs:set_tp(1000)
    end)

    for tachi, spear in pairs({['Tachi: Fudo'] = 'Stardiver', ['Tachi: Shoha'] = 'Impulse Drive',
        ['Tachi: Rana'] = 'Penta Thrust', ['Tachi: Gekko'] = 'Sonic Thrust', ['Tachi: Hobaku'] = 'Leg Sweep'}) do
        it('is ' .. spear .. ' for ' .. tachi, function()
            gs:type('/ws "' .. tachi .. '" <t>')
            assert.same({spear}, gs:actions())
        end)
    end

    it('is left alone when it isn\'t one of those', function()
        gs:type('/ws "Tachi: Kasha" <t>')
        assert.same({}, gs:actions())
    end)
end)

describe('SAM\'s weapon skill typed without a spear in hand', function()
    -- Stardiver is a spear's, but the job file takes only Double Thrust for a spear in hand.
    it('is left alone when Jobby hasn\'t Double Thrust, which the job file takes for a spear, whatever other spear '
        .. 'weapon skills he has, and Sel turns it down', function()
        local gs = boot({abilities = {'Stardiver'}, tp = 1000})
        gs:type('/ws "Tachi: Fudo" <t>')
        assert.same({}, gs:actions())
        assert.same({"Abort: You don't have access to [Tachi: Fudo]."}, gs:chat())
    end)
end)

describe('SAM\'s weapon skill set with Moonshade Earring in it', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('keeps Moonshade at 3200 TP with its bonus', function()
        assert.same(worn({head = "Theia's Hairpin", ear1 = 'Moonshade Earring', ear2 = 'Etiolation Earring'}),
            jobby.weaponskill(gs, '/ws "Tachi: Fudo" <t>', 2950))
    end)

    it('gives way to sets.MaxTP above 3200 TP with its bonus', function()
        assert.same(worn({head = "Theia's Hairpin", ear1 = 'Ishvara Earring', ear2 = 'Etiolation Earring'}),
            jobby.weaponskill(gs, '/ws "Tachi: Fudo" <t>', 2951))
    end)

    it('gives way to sets.AccMaxTP above that TP in an accuracy mode', function()
        gs:console('gs c set OffenseMode Acc')
        assert.same(worn({head = "Theia's Hairpin", ear1 = 'Brutal Earring', ear2 = 'Etiolation Earring'}),
            jobby.weaponskill(gs, '/ws "Tachi: Fudo" <t>', 3000))
    end)

    it('gives way to sets.DayMaxTPWSEars by day when sets.MaxTP holds Lugra Earring', function()
        gs.user.sets.MaxTP = {ear1 = 'Lugra Earring +1'}
        gs:set_time(12 * 60)
        assert.same(worn({head = "Theia's Hairpin", ear1 = 'Beastly Earring', ear2 = 'Etiolation Earring'}),
            jobby.weaponskill(gs, '/ws "Tachi: Fudo" <t>', 3000))
    end)

    it('gives way to sets.MaxTP itself at night when it holds Lugra Earring', function()
        gs.user.sets.MaxTP = {ear1 = 'Lugra Earring +1'}
        gs:set_time(22 * 60)
        assert.same(worn({head = "Theia's Hairpin", ear1 = 'Lugra Earring +1', ear2 = 'Etiolation Earring'}),
            jobby.weaponskill(gs, '/ws "Tachi: Fudo" <t>', 3000))
    end)

    it('gives way to sets.AccDayMaxTPWSEars by day in an accuracy mode when sets.AccMaxTP holds Lugra Earring', function()
        gs.user.sets.AccMaxTP = {ear1 = 'Lugra Earring +1'}
        gs:console('gs c set OffenseMode Acc')
        gs:set_time(12 * 60)
        assert.same(worn({head = "Theia's Hairpin", ear1 = 'Stealth Earring', ear2 = 'Etiolation Earring'}),
            jobby.weaponskill(gs, '/ws "Tachi: Fudo" <t>', 3000))
    end)

    it('gives way to sets.AccMaxTP itself at night in an accuracy mode when it holds Lugra Earring', function()
        gs.user.sets.AccMaxTP = {ear1 = 'Lugra Earring +1'}
        gs:console('gs c set OffenseMode Acc')
        gs:set_time(22 * 60)
        assert.same(worn({head = "Theia's Hairpin", ear1 = 'Lugra Earring +1', ear2 = 'Etiolation Earring'}),
            jobby.weaponskill(gs, '/ws "Tachi: Fudo" <t>', 3000))
    end)
end)

describe('SAM\'s weapon skill set with Lugra Earring in it', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('gives way to sets.DayWSEars by day', function()
        gs:set_time(12 * 60)
        assert.same(worn({head = "Theia's Hairpin", ear1 = "Hecate's Earring", ear2 = 'Etiolation Earring'}),
            jobby.weaponskill(gs, '/ws "Tachi: Gekko" <t>', 1000))
    end)

    it('gives way to sets.AccDayWSEars by day in an accuracy mode', function()
        gs:console('gs c set OffenseMode Acc')
        gs:set_time(12 * 60)
        assert.same(worn({head = "Theia's Hairpin", ear1 = 'Pixie Earring', ear2 = 'Etiolation Earring'}),
            jobby.weaponskill(gs, '/ws "Tachi: Gekko" <t>', 1000))
    end)

    it('stays at night', function()
        gs:set_time(22 * 60)
        assert.same(worn({head = "Theia's Hairpin", ear1 = 'Lugra Earring +1', ear2 = 'Etiolation Earring'}),
            jobby.weaponskill(gs, '/ws "Tachi: Gekko" <t>', 1000))
    end)
end)

describe('SAM\'s ranged weapon skill at 3200 TP with its bonus', function()
    pending('gives way to sets.RangedMaxTP, as job_post_precast in data/SAM.lua means: it compares spell.skill, which is '
        .. 'the skill\'s name by then, with the id 25')
end)

describe('SAM\'s weapon skill set with neither earring in it', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    -- What is worn with sets.precast.WS on, and these changes over it.
    local function ws_with(changes)
        return jobby.worn_by(worn({head = "Theia's Hairpin", neck = "Orunmila's Torque", hands = 'Volte Bracers',
            legs = 'Volte Hose'}), changes)
    end

    it('has Sekkanoki\'s set over it while Sekkanoki is up', function()
        gs:gain_buff('Sekkanoki')
        assert.same(ws_with({hands = 'Diamond Kote'}), jobby.weaponskill(gs, '/ws "Tachi: Shoha" <t>', 1000))
    end)

    it('has Sengikori\'s set over it while Sengikori is up', function()
        gs:gain_buff('Sengikori')
        assert.same(ws_with({legs = 'Diamond Hiza.'}), jobby.weaponskill(gs, '/ws "Tachi: Shoha" <t>', 1000))
    end)
end)

describe('SAM\'s engaged set', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    local function engaged_with(changes)
        return jobby.worn_by(worn({head = "Bendis's Hairpin", body = 'Sapphire Platemail', feet = 'Nyame Sollerets'}),
            changes)
    end

    it('has Hasso\'s set over it while Hasso is up', function()
        gs:gain_buff('Hasso')
        gs:engage()
        assert.same(engaged_with({feet = 'Sapphire Leggings'}), gs:worn())
    end)

    it('takes Hasso\'s set as Hasso is gained, and gives it up as Hasso wears', function()
        gs:engage()
        assert.same(engaged_with(), gs:worn())
        gs:gain_buff('Hasso')
        assert.same(engaged_with({feet = 'Sapphire Leggings'}), gs:worn())
        gs:lose_buff('Hasso')
        assert.same(engaged_with(), gs:worn())
    end)

    it('goes without Hasso\'s set under a defense mode', function()
        gs:console('gs c set DefenseMode Physical')
        gs:gain_buff('Hasso')
        gs:engage()
        assert.same(engaged_with({hands = 'Sapphire Gauntlets'}), gs:worn())
    end)

    it('goes without Hasso\'s set in the FullAcc offense mode', function()
        gs:console('gs c set OffenseMode FullAcc')
        gs:gain_buff('Hasso')
        gs:engage()
        assert.same(engaged_with(), gs:worn())
    end)

    it('keeps Hasso\'s set in the Acc offense mode', function()
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Hasso')
        gs:engage()
        assert.same(engaged_with({body = 'Jadeite Cuirie', feet = 'Sapphire Leggings'}), gs:worn())
    end)

    it('has Third Eye\'s set over it while Seigan and Third Eye are both up', function()
        gs:gain_buff('Seigan')
        gs:gain_buff('Third Eye')
        gs:engage()
        assert.same(engaged_with({feet = 'Jadeite Jambeaux'}), gs:worn())
    end)

    it('goes without Third Eye\'s set with Seigan alone', function()
        gs:gain_buff('Seigan')
        gs:engage()
        assert.same(engaged_with(), gs:worn())
    end)

    it('goes without Third Eye\'s set with Third Eye alone', function()
        gs:gain_buff('Third Eye')
        gs:engage()
        assert.same(engaged_with(), gs:worn())
    end)

    it('goes without Third Eye\'s set in an accuracy mode', function()
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Seigan')
        gs:gain_buff('Third Eye')
        gs:engage()
        assert.same(engaged_with({body = 'Jadeite Cuirie'}), gs:worn())
    end)

    it('looks for Hasso before Seigan and Third Eye, taking Hasso\'s set with all three up, though the game never '
        .. 'has Hasso and Seigan up at once', function()
        gs:gain_buff('Hasso')
        gs:gain_buff('Seigan')
        gs:gain_buff('Third Eye')
        gs:engage()
        assert.same(engaged_with({feet = 'Sapphire Leggings'}), gs:worn())
    end)
end)

describe('SAM casting with a sub job that casts', function()
    local gs
    before_each(function()
        gs = boot({sub_job = 'WHM'})
    end)

    it('wears sets.Reraise over the midcast set in the Reraise hybrid mode', function()
        gs:console('gs c set HybridMode Reraise')
        gs:type('/ma "Cure III" <me>')
        assert.same(worn({body = 'Diamond Haramaki'}), gs:worn())
    end)

    it('wears sets.Reraise in the physical defense mode that holds Reraise', function()
        gs:console('gs c set DefenseMode Physical')
        gs:console('gs c set PhysicalDefenseMode PDTReraise')
        gs:type('/ma "Cure III" <me>')
        assert.same(worn({hands = 'Jadeite Gloves', body = 'Diamond Haramaki'}), gs:worn())
    end)

    it('wears sets.Reraise in the magical defense mode that holds Reraise', function()
        gs:console('gs c set DefenseMode Magical')
        gs:console('gs c set MagicalDefenseMode MDTReraise')
        gs:type('/ma "Cure III" <me>')
        assert.same(worn({legs = 'Jadeite Chausses', body = 'Diamond Haramaki'}), gs:worn())
    end)

    it('wears no Reraise in the plain physical defense mode', function()
        gs:console('gs c set DefenseMode Physical')
        gs:type('/ma "Cure III" <me>')
        assert.same(worn({hands = 'Sapphire Gauntlets', body = 'Volte Jupon'}), gs:worn())
    end)

    it('wears no Reraise in another hybrid mode', function()
        gs:console('gs c set HybridMode DT')
        gs:type('/ma "Cure III" <me>')
        assert.same(worn({body = 'Volte Jupon'}), gs:worn())
    end)
end)

describe('SAM\'s Meikyo Shisui', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('holds its set on while it lasts, whatever sets are chosen', function()
        gs:type('/ja "Meikyo Shisui" <me>')
        gs:finish_action()
        gs:gain_buff('Meikyo Shisui')
        assert.same(worn({feet = 'Diamond Sune-Ate'}), gs:worn())
        gs:engage()
        gs:gain_buff('Hasso')
        assert.same(worn({head = "Bendis's Hairpin", body = 'Sapphire Platemail', feet = 'Diamond Sune-Ate'}), gs:worn())
    end)

    it('lets go of its set when it wears off', function()
        gs:type('/ja "Meikyo Shisui" <me>')
        gs:finish_action()
        gs:gain_buff('Meikyo Shisui')
        gs:engage()
        gs:gain_buff('Hasso')
        gs:lose_buff('Meikyo Shisui')
        assert.same(worn({head = "Bendis's Hairpin", body = 'Sapphire Platemail', feet = 'Sapphire Leggings'}), gs:worn())
    end)

end)

describe('SAM after a weapon skill with Meikyo Shisui up', function()
    local gs
    before_each(function()
        gs = boot()
        gs:gain_buff('Meikyo Shisui')
        gs:set_tp(1000)
        gs:type('/ws "Tachi: Shoha" <t>')
        gs:commands()
    end)

    it('cancels Meikyo Shisui with less than 750 TP left', function()
        gs:set_tp(749)
        gs:finish_action()
        assert.same({'cancel Meikyo Shisui'}, gs:commands())
    end)

    it('leaves Meikyo Shisui with 750 TP left', function()
        gs:set_tp(750)
        gs:finish_action()
        assert.same({}, gs:commands())
    end)
end)

describe('SAM after a weapon skill without Meikyo Shisui', function()
    it('leaves it alone with little TP left', function()
        local gs = boot()
        gs:set_tp(1000)
        gs:type('/ws "Tachi: Shoha" <t>')
        gs:commands()
        gs:set_tp(0)
        gs:finish_action()
        assert.same({}, gs:commands())
    end)
end)

describe('SAM\'s stance, kept by the tick', function()
    local gs
    before_each(function()
        gs = boot()
        gs:engage()
        gs:traffic()
    end)

    it('puts Hasso up when engaged with a two-handed weapon', function()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({'Hasso'}, gs:actions())
    end)

    it('puts Seigan up in the Seigan stance', function()
        gs:console('gs c set Stance Seigan')
        gs:play(harness.sel_load_time + 0.5)
        assert.same({'Seigan'}, gs:actions())
    end)

    it('puts nothing up in the None stance', function()
        gs:console('gs c set Stance None')
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)

    it('waits while Hasso is up', function()
        gs:gain_buff('Hasso')
        gs:traffic()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)

    it('waits while Seigan is up', function()
        gs:gain_buff('Seigan')
        gs:traffic()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)

    it('waits under SJ Restriction', function()
        gs:gain_buff('SJ Restriction')
        gs:traffic()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)

    it('waits while Hasso is on recast, without trying it', function()
        gs.game:start_ability_recast('Hasso', 30)
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
        assert.same({}, jobby.said(gs, '^Abort'))
    end)

    it('waits while Seigan is on recast in the Seigan stance, without trying it', function()
        gs:console('gs c set Stance Seigan')
        gs.game:start_ability_recast('Seigan', 30)
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
        assert.same({}, jobby.said(gs, '^Abort'))
    end)

    it('waits with a one-handed weapon in hand', function()
        gs:console('gs c set Weapons Sword')
        gs:traffic()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)

    it('waits when not engaged', function()
        gs:disengage()
        gs:traffic()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)
end)

describe('SAM\'s buffs kept by the tick under AutoBuffMode', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set AutoBuffMode Auto')
        gs:console('gs c set Stance None')
    end)

    it('are Berserk first with a sub job of WAR', function()
        gs:monster_hits()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({'Berserk'}, gs:actions())
    end)

    it('are Aggressor once Berserk is up', function()
        gs:monster_hits()
        gs:gain_buff('Berserk')
        gs:traffic()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({'Aggressor'}, gs:actions())
    end)

    it('are Aggressor when Berserk is on recast', function()
        gs:monster_hits()
        gs.game:start_ability_recast('Berserk', 60)
        gs:play(harness.sel_load_time + 0.5)
        assert.same({'Aggressor'}, gs:actions())
    end)

    it('are nothing once Berserk and Aggressor are up', function()
        gs:monster_hits()
        gs:gain_buff('Berserk')
        gs:gain_buff('Aggressor')
        gs:traffic()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)

    it('are nothing under SJ Restriction', function()
        gs:monster_hits()
        gs:gain_buff('SJ Restriction')
        gs:traffic()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)

    it('are nothing with AutoBuffMode off', function()
        gs:monster_hits()
        gs:console('gs c set AutoBuffMode Off')
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)

    it('are nothing out of combat', function()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)
end)

describe('SAM\'s buffs kept by the tick with a sub job of DRK', function()
    local gs
    before_each(function()
        gs = boot({sub_job = 'DRK'})
        gs:console('gs c set AutoBuffMode Auto')
        gs:console('gs c set Stance None')
        gs:monster_hits()
    end)

    it('are Last Resort', function()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({'Last Resort'}, gs:actions())
    end)

    it('are nothing while Last Resort is up', function()
        gs:gain_buff('Last Resort')
        gs:traffic()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)
end)
