local jobby = require('jobby')

local gear = {"Terra's Staff", 'Daybreak', 'Ammurapi Shield', 'Kupo Shield', 'Volte Cap', 'Null Masque',
    'Amin Turban', 'Ischkur Turban', 'Azimuth Turban', 'Blistering Sallet', 'Blistering Sallet +1', 'Alhazen Hat',
    'Alhazen Hat +1', 'Sukeroku Hachi.', "Bendis's Hairpin", 'Blacksh. Hairpin', 'Pixie Hairpin +1',
    "Theia's Hairpin +1", 'Imp. Wing Hairpin', 'Volte Boots', 'Volte Hose', 'Volte Bracers', 'Volte Jupon',
    'Adamantite Armor', 'Fotia Gorget', "Combatant's Torque", 'Karieyh Ring', 'Null Belt', 'Null Shawl',
    'Cessance Earring', 'Moonshade Earring', 'Brutal Earring'}

local function boot(options)
    options = options or {}
    options.items = gear
    options.sub_job = options.sub_job or 'RDM'
    return jobby.boot('WHM', options)
end

local function boot_ticking(options)
    options = options or {}
    options.items = gear
    options.sub_job = options.sub_job or 'RDM'
    return jobby.boot_ticking('WHM', options)
end

-- What is worn with the idle set on and these changes over it, as Jobby's gear file has Terra's Staff in it.
local function idle_with(changes)
    changes.main = changes.main or "Terra's Staff"
    return jobby.worn_by(changes, jobby.full_idle)
end

local light_day, light_weather = 6, 16

-- The head worn once the spell has been cast and its midcast set is on.
local function head_after(gs, line)
    gs:type(line)
    return gs:worn().head
end

describe('WHM\'s cure sets', function()
    local rows = {
        {'a plain cure', {}, 'Volte Cap'},
        {'a cure under Afflatus Solace', {solace = true}, 'Null Masque'},
        {'a cure in Light weather', {weather = true}, 'Amin Turban'},
        {'a cure on a Light day', {day = true}, 'Ischkur Turban'},
        {'a cure in Light weather on a Light day', {weather = true, day = true}, 'Amin Turban'},
        {'a cure under Afflatus Solace in Light weather', {solace = true, weather = true}, 'Azimuth Turban'},
        {'a cure under Afflatus Solace on a Light day', {solace = true, day = true}, 'Blistering Sallet'},
        {'a cure under Afflatus Solace in Light weather on a Light day', {solace = true, weather = true, day = true},
            'Azimuth Turban'},
        {'a cure with the weapons locked', {weapons = true}, 'Blistering Sallet +1'},
        {'a cure with the weapons locked under Afflatus Solace', {weapons = true, solace = true}, 'Alhazen Hat'},
        {'a cure with the weapons locked in Light weather', {weapons = true, weather = true}, 'Alhazen Hat +1'},
        {'a cure with the weapons locked on a Light day', {weapons = true, day = true}, 'Sukeroku Hachi.'},
        {'a cure with the weapons locked under Afflatus Solace in Light weather',
            {weapons = true, solace = true, weather = true}, "Bendis's Hairpin"},
        {'a cure with the weapons locked under Afflatus Solace on a Light day',
            {weapons = true, solace = true, day = true}, 'Blacksh. Hairpin'},
        {'a cure with the weapons unlocked', {weapons = true, unlock = true}, 'Volte Cap'},
    }

    for _, row in ipairs(rows) do
        local description, setup, head = row[1], row[2], row[3]
        it(('wears %s for %s'):format(head, description), function()
            local gs = boot()
            if setup.solace then
                gs:gain_buff('Afflatus Solace')
            end
            gs:set_weather(setup.weather and light_weather or 0)
            gs:set_day(setup.day and light_day or 0)
            if setup.weapons then
                gs:console('gs c set Weapons Daybreak')
            end
            if setup.unlock then
                gs:console('gs c toggle UnlockWeapons')
            end
            assert.equal(head, head_after(gs, '/ma "Cure IV" <me>'))
        end)
    end
end)

describe('WHM\'s curaga sets', function()
    -- Curaga II rather than Curaga, since Sel picks a set by the spell's name ahead of its map.
    local function curaga_head(weather, day)
        local gs = boot()
        gs:set_weather(weather and light_weather or 0)
        gs:set_day(day and light_day or 0)
        return head_after(gs, '/ma "Curaga II" <me>')
    end

    it('is sets.midcast.Curaga for a plain curaga', function()
        assert.equal('Pixie Hairpin +1', curaga_head(false, false))
    end)

    it('is sets.midcast.LightWeatherCuraga in Light weather', function()
        assert.equal("Theia's Hairpin +1", curaga_head(true, false))
    end)

    it('is sets.midcast.LightDayCuraga on a Light day', function()
        assert.equal('Imp. Wing Hairpin', curaga_head(false, true))
    end)

    it('is the weather\'s set in Light weather on a Light day', function()
        assert.equal("Theia's Hairpin +1", curaga_head(true, true))
    end)

    it('is the spell\'s own set for the spell the gear file names', function()
        local gs = boot()
        gs:set_weather(light_weather)
        assert.equal('Pixie Hairpin +1', head_after(gs, '/ma "Curaga" <me>'))
    end)
end)

describe('WHM\'s status removal', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is held for Divine Caress when it is ready', function()
        gs:type('/ma "Poisona" <me>')
        assert.same({'Divine Caress'}, gs:actions())
    end)

    it('is held for Divine Caress for each spell of the status removal map', function()
        for _, spell in ipairs({'Paralyna', 'Silena', 'Blindna', 'Cursna', 'Stona', 'Viruna'}) do
            local fresh = boot()
            fresh:type('/ma "' .. spell .. '" <me>')
            assert.same({'Divine Caress'}, fresh:actions(), spell)
        end
    end)

    it('goes out a second after Divine Caress, with sets.buff[\'Divine Caress\'] over its midcast set', function()
        gs:type('/ma "Poisona" <me>')
        gs:traffic()
        gs:finish_action()
        gs.game:start_ability_recast('Divine Caress', 60)
        gs:gain_buff('Divine Caress')
        gs:advance(0.95)
        assert.same({}, gs:actions())
        gs:advance(0.1)
        assert.same({'Poisona'}, gs:actions())
        assert.same(idle_with({neck = 'Fotia Gorget', hands = 'Volte Bracers', feet = 'Volte Boots',
            ring1 = 'Karieyh Ring'}), gs:worn())
    end)

    it('goes out at once, with the status removal midcast set alone, without Divine Caress up and on recast', function()
        gs.game:start_ability_recast('Divine Caress', 60)
        gs:type('/ma "Poisona" <me>')
        assert.same({'Poisona'}, gs:actions())
        assert.same(idle_with({neck = 'Fotia Gorget', hands = 'Volte Bracers', feet = 'Volte Boots'}), gs:worn())
    end)

    it('goes out at once with Auto Caress off', function()
        gs:console('gs c toggle AutoCaress')
        gs:type('/ma "Poisona" <me>')
        assert.same({'Poisona'}, gs:actions())
    end)

    it('goes out at once under amnesia', function()
        gs:gain_buff('amnesia')
        gs:type('/ma "Poisona" <me>')
        assert.same({'Poisona'}, gs:actions())
    end)

    it('is not held for Divine Caress for Erase', function()
        gs:type('/ma "Erase" <me>')
        assert.same({'Erase'}, gs:actions())
    end)

    it('is not held for Divine Caress for Esuna, when the gear file puts it in the status removal map', function()
        gs.user.spell_maps.Esuna = 'StatusRemoval'
        gs:type('/ma "Esuna" <me>')
        assert.same({'Esuna'}, gs:actions())
    end)

    it('has Divine Caress\'s set over the midcast set of Erase, Divine Caress being up', function()
        gs:gain_buff('Divine Caress')
        gs:type('/ma "Erase" <me>')
        assert.equal('Karieyh Ring', gs:worn().left_ring)
    end)
end)

describe('WHM\'s Raise III and Arise', function()
    local gs
    before_each(function()
        gs = boot({sub_job = 'SCH'})
        gs:gain_buff('Light Arts')
    end)

    it('is held for Celerity with Light Arts up and a stratagem to spend', function()
        gs:type('/ma "Arise" <me>')
        assert.same({'Celerity'}, gs:actions())
    end)

    it('is held for Celerity for Raise III as well', function()
        gs:type('/ma "Raise III" <me>')
        assert.same({'Celerity'}, gs:actions())
    end)

    it('is held for Celerity with Addendum: White up', function()
        gs:lose_buff('Light Arts')
        gs:gain_buff('Addendum: White')
        gs:type('/ma "Arise" <me>')
        assert.same({'Celerity'}, gs:actions())
    end)

    it('goes out a second after Celerity', function()
        gs:type('/ma "Arise" <me>')
        gs:traffic()
        gs:finish_action()
        gs:gain_buff('Celerity')
        gs:advance(0.95)
        assert.same({}, gs:actions())
        gs:advance(0.1)
        assert.same({'Arise'}, gs:actions())
    end)

    it('goes out at once with Celerity up', function()
        gs:gain_buff('Celerity')
        gs:type('/ma "Arise" <me>')
        assert.same({'Arise'}, gs:actions())
    end)

    it('goes out at once with Auto Celerity off', function()
        gs:console('gs c toggle AutoCelerity')
        gs:type('/ma "Arise" <me>')
        assert.same({'Arise'}, gs:actions())
    end)

    it('goes out at once with no stratagem left', function()
        gs.game:start_ability_recast('Penury', 165)
        gs:type('/ma "Arise" <me>')
        assert.same({'Arise'}, gs:actions())
    end)

    it('goes out at once without Light Arts', function()
        gs:lose_buff('Light Arts')
        gs:type('/ma "Arise" <me>')
        assert.same({'Arise'}, gs:actions())
    end)
end)

describe('WHM\'s Devotion', function()
    local gs
    before_each(function()
        gs = boot()
        gs:chat()
    end)

    it('is blocked under 50% HP, with a notice', function()
        gs.game.player.vitals.hp, gs.game.player.vitals.hpp = 740, 49
        gs:type('/ja "Devotion" <me>')
        assert.same({}, gs:traffic())
        assert.same({'Abort: Blocking Devotion under 50% HP to prevent inefficient use.'}, gs:chat())
    end)

    it('goes out at 50% HP', function()
        gs.game.player.vitals.hp, gs.game.player.vitals.hpp = 750, 50
        gs:type('/ja "Devotion" <me>')
        assert.same({'Devotion'}, gs:actions())
    end)

    it('goes out under 50% HP with Block Low Devotion off', function()
        gs:console('gs c toggle BlockLowDevotion')
        gs.game.player.vitals.hp, gs.game.player.vitals.hpp = 740, 49
        gs:type('/ja "Devotion" <me>')
        assert.same({'Devotion'}, gs:actions())
    end)
end)

describe('WHM\'s bar spells', function()
    it('wear sets.midcast.BarElement', function()
        local gs = boot()
        gs:type('/ma "Barfire" <me>')
        assert.equal('Volte Jupon', gs:worn().body)
    end)

    it('wear sets.midcast.BarElement.LightArts with Light Arts up', function()
        local gs = boot()
        gs:gain_buff('Light Arts')
        gs:type('/ma "Barfire" <me>')
        assert.equal('Adamantite Armor', gs:worn().body)
    end)

    it('wear sets.midcast.BarElement.LightArts with Addendum: White up', function()
        local gs = boot()
        gs:gain_buff('Addendum: White')
        gs:type('/ma "Barblizzard" <me>')
        assert.equal('Adamantite Armor', gs:worn().body)
    end)
end)

describe('WHM\'s Proc casting mode', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set CastingMode Proc')
    end)

    it('wears sets.precast.FC.Proc for a spell', function()
        gs:type('/ma "Cure IV" <me>')
        assert.equal("Combatant's Torque", gs:worn().neck)
    end)

    it('wears sets.midcast.Proc in place of the spell\'s own midcast set', function()
        gs:type('/ma "Cure IV" <me>')
        assert.same(idle_with({neck = "Combatant's Torque", feet = 'Volte Boots', legs = 'Volte Hose'}), gs:worn())
    end)

    it('wears the spell\'s own sets again in the Normal casting mode', function()
        gs:console('gs c set CastingMode Normal')
        gs:type('/ma "Cure IV" <me>')
        assert.same(idle_with({neck = 'Fotia Gorget', feet = 'Volte Boots', head = 'Volte Cap'}), gs:worn())
    end)
end)

describe('WHM\'s weapon skill set', function()
    local function mystic_boon(tp)
        local gs = boot({tp = tp})
        gs:type('/ws "Mystic Boon" <t>')
        return gs:worn()
    end

    it('keeps Moonshade Earring on at 2950 TP, which Moonshade makes 3200', function()
        assert.equal('Moonshade Earring', mystic_boon(2950).left_ear)
    end)

    it('swaps Moonshade Earring for sets.MaxTP over 3200 TP counting Moonshade\'s 250', function()
        assert.equal('Cessance Earring', mystic_boon(2951).left_ear)
    end)
end)

describe('WHM\'s Sleep timers', function()
    local function cast_sleep(name, options)
        local gs = boot({sub_job = 'BLM'})
        if options and options.timers_off then
            gs:console('gs c toggle UseCustomTimers')
        end
        gs:commands()
        gs:type('/ma "' .. name .. '" <t>')
        if options and options.interrupted then
            gs:interrupt_action()
        else
            gs:finish_action()
        end
        return gs:commands()
    end

    it('starts a 60 second timer on the target when Sleep lands', function()
        assert.same({'timers c "Sleep [Apex Toad]" 60 down spells/00220.png'}, cast_sleep('Sleep'))
    end)

    it('starts a 60 second timer when Sleepga lands', function()
        assert.same({'timers c "Sleepga [Apex Toad]" 60 down spells/00220.png'}, cast_sleep('Sleepga'))
    end)

    it('starts no timer when Sleep is interrupted', function()
        assert.same({}, cast_sleep('Sleep', {interrupted = true}))
    end)

    it('starts no timer for Sleep with Use Custom Timers off', function()
        assert.same({}, cast_sleep('Sleep', {timers_off = true}))
    end)

    pending('starts no timer for Sleepga with Use Custom Timers off: job_aftercast in data/WHM.lua tests '
        .. 'state.UseCustomTimers.value and spell.english == \'Sleep\' or spell.english == \'Sleepga\', so Sleepga '
        .. 'starts one whatever the mode says')
end)

describe('WHM\'s idle set', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    local function low_mp()
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 400, 40
        gs:console('gs c update')
    end

    it('is sets.idle with Terra\'s Staff, the gear file\'s', function()
        assert.same(idle_with({}), gs:worn())
    end)

    it('has sets.latent_refresh and the grip over it under 51% MP, the staff being in the idle set', function()
        low_mp()
        assert.same(idle_with({waist = 'Null Belt', sub = 'Kupo Shield'}), gs:worn())
    end)

    it('has sets.TPEat over it too with TP', function()
        gs.game.player.vitals.tp = 300
        low_mp()
        assert.same(idle_with({waist = 'Null Belt', sub = 'Kupo Shield', ear1 = 'Cessance Earring'}), gs:worn())
    end)

    it('has no latent refresh set over it at 51% MP', function()
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 510, 51
        gs:console('gs c update')
        assert.same(idle_with({}), gs:worn())
    end)

    it('has sets.latent_refresh over it at 50% MP', function()
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 500, 50
        gs:console('gs c update')
        assert.equal('Null Belt', gs:worn().waist)
    end)

    it('has sets.TPEat over it with 1 TP', function()
        gs.game.player.vitals.tp = 1
        low_mp()
        assert.equal('Cessance Earring', gs:worn().left_ear)
    end)

    it('has no sets.TPEat over it with no TP', function()
        gs.game.player.vitals.tp = 0
        low_mp()
        assert.equal('Etiolation Earring', gs:worn().left_ear)
    end)

    it('has only sets.latent_refresh over it with the weapons locked', function()
        gs:console('gs c set Weapons Daybreak')
        gs.game.player.vitals.tp = 300
        low_mp()
        assert.same(idle_with({main = 'Daybreak', sub = 'Ammurapi Shield', waist = 'Null Belt'}), gs:worn())
    end)

    it('has no latent refresh set over it in the DT idle mode', function()
        gs:console('gs c set IdleMode DT')
        low_mp()
        assert.same(idle_with({head = 'Null Masque'}), gs:worn())
    end)

    it('has sets.buff.Sublimation over it while Sublimation charges', function()
        gs:gain_buff('Sublimation: Activated')
        assert.same(idle_with({back = 'Null Shawl'}), gs:worn())
    end)

    it('has sets.buff.DTSublimation over the DT idle set while Sublimation charges', function()
        gs:console('gs c set IdleMode DT')
        gs:gain_buff('Sublimation: Activated')
        assert.same(idle_with({head = 'Null Masque', back = 'Null Shawl', neck = "Combatant's Torque"}), gs:worn())
    end)

    it('leaves the latent refresh set off while Sublimation charges', function()
        gs:gain_buff('Sublimation: Activated')
        low_mp()
        assert.same(idle_with({back = 'Null Shawl'}), gs:worn())
    end)
end)

describe('WHM\'s status line', function()
    it('says the casting and idle modes, as a caster\'s does', function()
        local gs = boot()
        gs:chat()
        gs:console('gs c update user')
        local lines = gs:chat()
        assert.is_truthy(lines[#lines]:find('Casting [Normal], Idle [Normal]', 1, true), lines[#lines])
    end)
end)

describe('WHM\'s Auto Arts', function()
    -- Every buff Auto Buff Mode keeps up is up, so that only the arts are left for the tick to use.
    local buffed = {'Reraise', 'Haste', 'Aurorastorm', 'Refresh', 'Aquaveil', 'Stoneskin', 'Phalanx'}

    local function arts(options, auto_arts, auto_buff)
        local gs = boot_ticking(options)
        if auto_arts then
            gs:console('gs c set AutoArts true')
        end
        if auto_buff then
            gs:console('gs c set AutoBuffMode Auto')
        end
        return gs
    end

    it('is left alone by Auto Buff Mode: the buffs go first when Auto Arts is off', function()
        local gs = arts({sub_job = 'SCH'}, false, true)
        gs:play_until_action()
        assert.same({'Reraise IV'}, gs:actions())
    end)

    it('uses Afflatus Solace once Auto Arts is on, with Auto Buff Mode on', function()
        local gs = arts({sub_job = 'SCH', buffs = buffed}, true, true)
        gs:play_until_action()
        assert.same({'Afflatus Solace'}, gs:actions())
    end)

    it('uses Light Arts after Afflatus Solace with Scholar as the sub job', function()
        local gs = arts({sub_job = 'SCH', buffs = buffed}, true, true)
        gs:gain_buff('Afflatus Solace')
        gs:play_until_action()
        assert.same({'Light Arts'}, gs:actions())
    end)

    it('uses no Light Arts with Light Arts up', function()
        local gs = arts({sub_job = 'SCH', buffs = buffed}, true, true)
        gs:gain_buff('Afflatus Solace')
        gs:gain_buff('Light Arts')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Light Arts without Scholar as the sub job', function()
        local gs = arts({sub_job = 'RDM', buffs = buffed}, true, true)
        gs:gain_buff('Afflatus Solace')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Afflatus Solace with Afflatus Misery up', function()
        local gs = arts({buffs = buffed}, true, true)
        gs:gain_buff('Afflatus Misery')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Afflatus Solace while it is on recast', function()
        local gs = arts({buffs = buffed}, true, true)
        gs.game:start_ability_recast('Afflatus Solace', 60)
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses Afflatus Solace in a fight with Auto Arts on and Auto Buff Mode off', function()
        local gs = arts({}, true, false)
        gs:monster_hits()
        gs:play_until_action()
        assert.same({'Afflatus Solace'}, gs:actions())
    end)

    it('uses no Afflatus Solace out of a fight with Auto Arts on and Auto Buff Mode off', function()
        local gs = arts({}, true, false)
        gs:play(3)
        assert.same({}, gs:actions())
    end)
end)

describe('WHM\'s Auto Buff Mode', function()
    local function buffing(options)
        local gs = boot_ticking(options)
        gs:console('gs c set AutoBuffMode Auto')
        return gs
    end

    it('starts with Reraise IV', function()
        local gs = buffing()
        gs:play_until_action()
        assert.same({'Reraise IV'}, gs:actions())
    end)

    it('goes on to Haste with Reraise up', function()
        local gs = buffing()
        gs:gain_buff('Reraise')
        gs:play_until_action()
        assert.same({'Haste'}, gs:actions())
    end)

    it('skips Aurorastorm without Scholar as the sub job, and goes on to Refresh', function()
        local gs = buffing({sub_job = 'RDM'})
        gs:gain_buff('Reraise')
        gs:gain_buff('Haste')
        gs:play_until_action()
        assert.same({'Refresh'}, gs:actions())
    end)

    it('casts Aurorastorm with Scholar as the sub job', function()
        local gs = buffing({sub_job = 'SCH'})
        gs:gain_buff('Reraise')
        gs:gain_buff('Haste')
        gs:play_until_action()
        assert.same({'Aurorastorm'}, gs:actions())
    end)

    it('skips a spell on recast', function()
        local gs = buffing()
        gs.game:start_spell_recast('Reraise IV', 10)
        gs:play_until_action()
        assert.same({'Haste'}, gs:actions())
    end)

    it('skips Haste while it is on recast', function()
        local gs = buffing()
        gs:gain_buff('Reraise')
        gs.game:start_spell_recast('Haste', 10)
        gs:play_until_action()
        assert.same({'Refresh'}, gs:actions())
    end)

    it('skips a spell it hasn\'t the MP for', function()
        local gs = buffing()
        gs.game.player.vitals.mp = 45
        gs:play_until_action()
        assert.same({'Haste'}, gs:actions())
    end)

    it('casts nothing once every buff Jobby can cast is up', function()
        local gs = buffing()
        for _, buff in ipairs({'Reraise', 'Haste', 'Refresh', 'Aquaveil', 'Stoneskin', 'Phalanx'}) do
            gs:gain_buff(buff)
        end
        gs:play(3)
        assert.same({}, gs:actions())
    end)
end)

describe('WHM\'s buff up', function()
    it('casts the Default list in order, Reraise IV first', function()
        local gs = boot_ticking()
        gs:console('gs c buffup')
        gs:play_until_action()
        assert.same({'Reraise IV'}, gs:actions())
    end)

    it('goes on to Shellra V and then Protectra V', function()
        local gs = boot_ticking()
        gs:console('gs c buffup')
        gs:gain_buff('Reraise')
        gs:play_until_action()
        assert.same({'Shellra V'}, gs:actions())
        gs:finish_action()
        gs:gain_buff('Shell')
        gs:play_until_action()
        assert.same({'Protectra V'}, gs:actions())
    end)

    it('says so, and stops, when every buff it can cast is up', function()
        local gs = boot_ticking({buffs = {'Reraise', 'Shell', 'Protect', 'Auspice', 'Haste', 'Aquaveil', 'Stoneskin',
            'Blink', 'Phalanx'}})
        gs:chat()
        gs:console('gs c buffup')
        gs:play(1)
        assert.same({}, gs:actions())
        assert.same({'All Default buffs are up!'}, gs:chat())
        assert.equal('', gs.user.buffup)
    end)

    it('is told by name which list to cast', function()
        local gs = boot_ticking()
        gs:console('gs c buffup Self')
        gs:play_until_action()
        assert.same({'Reraise IV'}, gs:actions())
        gs:finish_action()
        gs:gain_buff('Reraise')
        gs:play_until_action()
        assert.same({'Aquaveil'}, gs:actions())
    end)

    it('says when there is no such list', function()
        local gs = boot_ticking()
        gs:chat()
        gs:console('gs c buffup Nonsense')
        assert.same({'Nonsense is not a buff list!'}, gs:chat())
    end)
end)

describe('WHM\'s elemental commands', function()
    local function nuke(mode, command, options)
        local gs = boot_ticking({sub_job = 'BLM'})
        gs:console('gs c set ElementalMode ' .. mode)
        if options and options.recasts then
            for spell, seconds in pairs(options.recasts) do
                gs.game:start_spell_recast(spell, seconds)
            end
        end
        gs:console('gs c elemental ' .. command)
        return gs:actions(), gs
    end

    it('nukes with Holy II in the Light mode', function()
        assert.same({'Holy II'}, (nuke('Light', 'nuke')))
    end)

    it('goes down to Holy when Holy II is on recast', function()
        assert.same({'Holy'}, (nuke('Light', 'nuke', {recasts = {['Holy II'] = 10}})))
    end)

    it('goes down to Banish III when Holy II and Holy are on recast', function()
        assert.same({'Banish III'}, (nuke('Light', 'nuke', {recasts = {['Holy II'] = 10, ['Holy'] = 10}})))
    end)

    it('smallnuke uses Banish II in the Light mode', function()
        assert.same({'Banish II'}, (nuke('Light', 'smallnuke')))
    end)

    it('smallnuke goes down to Banish when Banish II is on recast', function()
        assert.same({'Banish'}, (nuke('Light', 'smallnuke', {recasts = {['Banish II'] = 10}})))
    end)

    it('nukes with the highest tier Jobby can cast in another mode: Fire II from a level 49 Black Mage sub job', function()
        assert.same({'Fire II'}, (nuke('Fire', 'nuke')))
    end)

    it('goes down a tier when that one is on recast', function()
        assert.same({'Fire'}, (nuke('Fire', 'nuke', {recasts = {['Fire II'] = 10}})))
    end)

    it('smallnuke uses Fire II in another mode', function()
        assert.same({'Fire II'}, (nuke('Fire', 'smallnuke')))
    end)

    it('casts nothing, and says nothing, when every light nuke is on recast', function()
        local gs = boot_ticking({sub_job = 'BLM'})
        gs:console('gs c set ElementalMode Light')
        gs.game:start_spell_recast('Holy II', 10)
        gs.game:start_spell_recast('Holy', 10)
        gs.game:start_spell_recast('Banish III', 10)
        gs.game:start_spell_recast('Banish II', 10)
        gs.game:start_spell_recast('Banish', 10)
        gs:chat()
        gs:console('gs c elemental nuke')
        assert.same({}, gs:actions())
        assert.same({}, gs:chat())
    end)

    it('hands a command it doesn\'t know on to Sel\'s elemental commands', function()
        local gs = boot_ticking({sub_job = 'RDM'})
        gs:console('gs c set ElementalMode Fire')
        gs:console('gs c elemental barelement')
        assert.same({'Barblizzard'}, gs:actions())
    end)

    it('says so when every tier is on recast', function()
        local gs = boot_ticking({sub_job = 'BLM'})
        gs:console('gs c set ElementalMode Fire')
        gs.game:start_spell_recast('Fire II', 10)
        gs.game:start_spell_recast('Fire', 10)
        gs:chat()
        gs:console('gs c elemental nuke')
        assert.same({}, gs:actions())
        assert.same({'Abort: All Fire nukes on cooldown or or not enough MP.'}, gs:chat())
    end)
end)

describe('WHM\'s smart cure', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    local function smartcure(hp, hpp, recasts)
        gs.game.player.vitals.hp, gs.game.player.vitals.hpp = hp, hpp
        if recasts then
            for spell, seconds in pairs(recasts) do
                gs.game:start_spell_recast(spell, seconds)
            end
        end
        gs:console('gs c smartcure me')
        return gs:actions()
    end

    it('casts Cure on a target missing less than 250 HP', function()
        assert.same({'Cure'}, smartcure(1500, 100))
    end)

    it('casts Cure II when Cure is on recast', function()
        assert.same({'Cure II'}, smartcure(1500, 100, {['Cure'] = 10}))
    end)

    it('says so when the cures it would use are all on recast', function()
        gs:chat()
        assert.same({}, smartcure(1500, 100, {['Cure'] = 10, ['Cure II'] = 10}))
        assert.same({'Abort: Appropriate cures are on cooldown.'}, gs:chat())
    end)

    -- Jobby's HP and HP percentage for a target missing 333, 618, 1000 and 1500 HP, which fall in the four tiers
    -- above the first.
    local missing = {[333] = {1000, 75}, [618] = {1200, 66}, [1000] = {1000, 50}, [1500] = {1000, 40}}

    -- Each row: the HP missing, the cures on recast (by spell id), the cure cast, or nothing when they are all on
    -- recast.
    local rows = {
        {333, {}, 'Cure II'},
        {333, {2}, 'Cure III'},
        {333, {2, 3}, 'Cure'},
        {333, {2, 3, 1}, nil},
        {618, {}, 'Cure III'},
        {618, {3}, 'Cure IV'},
        {618, {3, 4}, 'Cure V'},
        {618, {3, 4, 5}, nil},
        {1000, {}, 'Cure V'},
        {1000, {5}, 'Cure IV'},
        {1000, {5, 4}, 'Cure VI'},
        {1000, {5, 4, 6}, 'Cure III'},
        {1000, {5, 4, 6, 3}, nil},
        {1500, {}, 'Cure VI'},
        {1500, {6}, 'Cure V'},
        {1500, {6, 5}, 'Cure IV'},
        {1500, {6, 5, 4}, 'Cure III'},
        {1500, {6, 5, 4, 3}, nil},
    }

    for _, row in ipairs(rows) do
        local hp_missing, busy, cure = row[1], row[2], row[3]
        local names = {'Cure', 'Cure II', 'Cure III', 'Cure IV', 'Cure V', 'Cure VI'}
        local recasts = {}
        for _, id in ipairs(busy) do
            recasts[names[id]] = 10
        end
        local busy_names = {}
        for _, id in ipairs(busy) do
            busy_names[#busy_names + 1] = names[id]
        end
        local when = #busy == 0 and 'with every cure ready' or ('with ' .. table.concat(busy_names, ', ') .. ' on recast')
        it(('casts %s on a target missing %d HP %s'):format(cure or 'nothing', hp_missing, when), function()
            gs:chat()
            local hp = missing[hp_missing]
            local sent = smartcure(hp[1], hp[2], recasts)
            if cure then
                assert.same({cure}, sent)
            else
                assert.same({}, sent)
                assert.same({'Abort: Appropriate cures are on cooldown.'}, gs:chat())
            end
        end)
    end

    -- A target missing exactly 250, 400, 900 and 1400 HP: the first HP missing of each tier above the one before.
    local at_boundary = {
        {750, 75, 'Cure II'}, {1200, 75, 'Cure III'}, {900, 50, 'Cure V'}, {1400, 50, 'Cure VI'},
    }

    for _, row in ipairs(at_boundary) do
        it(('casts %s on a target at %d%% HP with %d HP'):format(row[3], row[2], row[1]), function()
            assert.same({row[3]}, smartcure(row[1], row[2]))
        end)
    end

    describe('on a target', function()
        local function pal(hpp)
            return jobby.target_a_player(gs, {hpp = hpp})
        end

        it('given by its id', function()
            gs:console('gs c smartcure ' .. gs.game.player.id)
            assert.same({{action = 'Cure', target = 'Jobby'}}, gs:action_entries())
        end)

        it('given as <t>, estimating the HP it is missing from a 1800 HP maximum', function()
            pal(50)
            gs:console('gs c smartcure t')
            assert.same({'Cure V'}, gs:actions())
        end)

        pending('given by the name of a player nearby, who isn\'t targeted: handle_smartcure in data/WHM.lua takes the '
            .. 'player it finds by name only when is_valid is set, which Windower never sets on a mob (its mobs carry '
            .. 'valid_target), so it cures Jobby, where {action = \'Cure V\', target = \'Pal\'} ought to go out')

        pending('given by a name nobody answers to, which is the current target when that is valid: '
            .. 'handle_smartcure in data/WHM.lua tests is_valid on the current target too, which is never set, so it '
            .. 'cures Jobby')

        it('given by a name nobody answers to, which is Jobby when the current target isn\'t valid', function()
            jobby.target_a_player(gs, {valid_target = false})
            gs:console('gs c smartcure Nobody')
            assert.same({{action = 'Cure', target = 'Jobby'}}, gs:action_entries())
        end)

        it('not given, which is the current target when it is another player', function()
            pal(50)
            gs:console('gs c smartcure')
            assert.same({'Cure V'}, gs:actions())
        end)

        it('not given, which is Jobby when nothing is targeted', function()
            gs.game.target_index = nil
            gs:console('gs c smartcure')
            assert.same({{action = 'Cure', target = 'Jobby'}}, gs:action_entries())
        end)

        it('not given, which is sent on to the targeting of an ally when a monster is targeted', function()
            gs:console('gs c smartcure')
            local sent = false
            for _, command in ipairs(gs:commands()) do
                sent = sent or command == 'gs c smartcure <stal>'
            end
            assert.is_true(sent)
        end)

        it('who is dead, which is raised with Arise', function()
            pal(0).status = 2
            gs:console('gs c smartcure t')
            assert.same({{action = 'Arise', target = 'Pal'}}, gs:action_entries())
        end)
    end)

    pending('cures the battle target for smartcure bt: handle_smartcure in data/WHM.lua stores the battle target in '
        .. 'a variable called target, not cureTarget, a global it keeps from the last smartcure, so it cures whoever '
        .. 'that cured, or raises a Lua error when no smartcure has cured anyone yet')
end)

describe('WHM\'s buff states', function()
    it('follow the buffs as they come and go', function()
        local gs = boot()
        gs:gain_buff('Afflatus Solace')
        assert.is_true(gs.user.state.Buff['Afflatus Solace'])
        gs:lose_buff('Afflatus Solace')
        assert.is_false(gs.user.state.Buff['Afflatus Solace'])
    end)

    it('start with Auto Caress, Auto Celerity and Block Low Devotion on', function()
        local gs = boot()
        assert.is_true(gs.user.state.AutoCaress.value)
        assert.is_true(gs.user.state.AutoCelerity.value)
        assert.is_true(gs.user.state.BlockLowDevotion.value)
    end)
end)
