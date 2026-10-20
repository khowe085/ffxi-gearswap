local jobby = require('jobby')

local gear = {'Daybreak', 'Ammurapi Shield', "Terra's Staff", 'Kupo Shield', 'Volte Cap', 'Null Masque',
    'Volte Jupon', 'Adamantite Armor', 'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Fotia Gorget',
    "Combatant's Torque", 'Karieyh Ring', 'Chirich Ring +1', 'Null Belt', 'Null Shawl', 'Amin Turban',
    'Ischkur Turban', 'Azimuth Turban', 'Blistering Sallet', 'Blistering Sallet +1', 'Alhazen Hat', 'Alhazen Hat +1',
    'Sukeroku Hachi.', "Bendis's Hairpin", 'Blacksh. Hairpin', 'Moonshade Earring', 'Brutal Earring',
    'Cessance Earring', 'Regal Cuffs'}

local function boot(options)
    options = options or {}
    options.items = gear
    options.sub_job = options.sub_job or 'WHM'
    return jobby.boot('BLM', options)
end

local function boot_ticking(options)
    options = options or {}
    options.items = gear
    options.sub_job = options.sub_job or 'WHM'
    return jobby.boot_ticking('BLM', options)
end

local light_day, light_weather = 6, 16

-- The worn gear in a slot once the spell has been cast and its midcast set is on.
local function worn_after(gs, line)
    gs:type(line)
    return gs:worn()
end

describe('BLM\'s cure sets', function()
    local function cure_head(setup, spell)
        local gs = boot()
        gs:set_weather(setup.weather and light_weather or 0)
        gs:set_day(setup.day and light_day or 0)
        if setup.weapons then
            gs:console('gs c set Weapons Staff')
        end
        return worn_after(gs, '/ma "' .. (spell or 'Cure IV') .. '" <me>').head
    end

    it('is sets.midcast.Cure for a plain cure', function()
        assert.equal('Blistering Sallet +1', cure_head({}))
    end)

    it('is sets.midcast.LightWeatherCure in Light weather', function()
        assert.equal('Alhazen Hat', cure_head({weather = true}))
    end)

    it('is sets.midcast.LightDayCure on a Light day', function()
        assert.equal('Alhazen Hat +1', cure_head({day = true}))
    end)

    it('is the weather\'s set in Light weather on a Light day', function()
        assert.equal('Alhazen Hat', cure_head({weather = true, day = true}))
    end)

    it('is sets.midcast.MeleeCure with the weapons locked', function()
        assert.equal('Sukeroku Hachi.', cure_head({weapons = true}))
    end)

    it('is sets.midcast.MeleeLightWeatherCure with the weapons locked in Light weather', function()
        assert.equal("Bendis's Hairpin", cure_head({weapons = true, weather = true}))
    end)

    it('is sets.midcast.MeleeLightDayCure with the weapons locked on a Light day', function()
        assert.equal('Blacksh. Hairpin', cure_head({weapons = true, day = true}))
    end)

    it('is the same for a curaga', function()
        assert.equal('Alhazen Hat', cure_head({weather = true}, 'Curaga II'))
        assert.equal('Sukeroku Hachi.', cure_head({weapons = true}, 'Curaga II'))
    end)

    it('is sets.midcast.Cure again with the weapons unlocked', function()
        local gs = boot()
        gs:console('gs c set Weapons Staff')
        gs:console('gs c toggle UnlockWeapons')
        assert.equal('Blistering Sallet +1', worn_after(gs, '/ma "Cure IV" <me>').head)
    end)
end)

describe('BLM\'s nuke sets', function()
    local function head_after(line, setup)
        local gs = boot()
        if setup then
            setup(gs)
        end
        return worn_after(gs, line).head
    end

    it('is sets.midcast.LowTierNuke for a low tier nuke', function()
        assert.equal('Volte Cap', head_after('/ma "Fire" <t>'))
        assert.equal('Volte Cap', head_after('/ma "Thunder II" <t>'))
    end)

    it('is sets.midcast.HighTierNuke for a high tier nuke', function()
        assert.equal('Amin Turban', head_after('/ma "Fire III" <t>'))
        assert.equal('Amin Turban', head_after('/ma "Blizzard IV" <t>'))
    end)

    it('is sets.midcast.HighTierNuke for the ancient magic', function()
        assert.equal('Amin Turban', head_after('/ma "Flare" <t>'))
    end)

    it('is the elemental skill\'s set for an elemental enfeeble, which has no nuke map', function()
        assert.equal('Ischkur Turban', head_after('/ma "Burn" <t>'))
    end)

    it('has sets.MagicBurst over it while Magic Burst Mode is Single, once', function()
        local gs = boot()
        gs:console('gs c set MagicBurstMode Single')
        assert.equal('Volte Bracers', worn_after(gs, '/ma "Fire III" <t>').hands)
        gs:finish_action()
        assert.equal('Off', gs.user.state.MagicBurstMode.value)
    end)

    it('keeps sets.MagicBurst on every nuke while Magic Burst Mode is Lock', function()
        local gs = boot()
        gs:console('gs c set MagicBurstMode Lock')
        assert.equal('Volte Bracers', worn_after(gs, '/ma "Fire III" <t>').hands)
        gs:finish_action()
        assert.equal('Lock', gs.user.state.MagicBurstMode.value)
    end)

    it('has no burst set over it with Magic Burst Mode off', function()
        assert.equal('Nyame Gauntlets', worn_after(boot(), '/ma "Fire III" <t>').hands)
    end)

    it('has sets.ResistantMagicBurst over it in the Resistant casting mode', function()
        local gs = boot()
        gs:console('gs c set MagicBurstMode Lock')
        gs:console('gs c set CastingMode Resistant')
        local worn = worn_after(gs, '/ma "Fire III" <t>')
        assert.equal('Volte Bracers', worn.hands)
        assert.equal('Adamantite Armor', worn.body)
    end)

    it('has sets.RecoverMP over it under 35% MP', function()
        local gs = boot()
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 340, 34
        assert.equal('Null Belt', worn_after(gs, '/ma "Fire III" <t>').waist)
    end)

    it('has no sets.RecoverMP over it at 35% MP', function()
        local gs = boot()
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 350, 35
        assert.equal('Plat. Mog. Belt', worn_after(gs, '/ma "Fire III" <t>').waist)
    end)
end)

describe('BLM\'s casting modes', function()
    it('Proc puts sets.precast.FC.Proc on for a spell', function()
        local gs = boot()
        gs:console('gs c set CastingMode Proc')
        assert.equal("Combatant's Torque", worn_after(gs, '/ma "Fire" <t>').neck)
    end)

    it('Proc puts sets.midcast.Proc on in place of the spell\'s own midcast set', function()
        local gs = boot()
        gs:console('gs c set CastingMode Proc')
        local worn = worn_after(gs, '/ma "Fire" <t>')
        assert.equal('Volte Hose', worn.legs)
        assert.equal('Nyame Helm', worn.head)
    end)

    it('OccultAcumen puts sets.precast.FC.OccultAcumen on for a spell', function()
        local gs = boot()
        gs:console('gs c set CastingMode OccultAcumen')
        assert.equal('Volte Hose', worn_after(gs, '/ma "Fire" <t>').legs)
    end)

    it('OccultAcumen leaves the spell\'s own midcast set, there being no sets.midcast.OccultAcumen', function()
        local gs = boot()
        gs:console('gs c set CastingMode OccultAcumen')
        assert.equal('Volte Cap', worn_after(gs, '/ma "Fire" <t>').head)
    end)

    it('Proc and OccultAcumen leave the burst sets off', function()
        for _, mode in ipairs({'Proc', 'OccultAcumen'}) do
            local gs = boot()
            gs:console('gs c set CastingMode ' .. mode)
            gs:console('gs c set MagicBurstMode Lock')
            assert.equal('Nyame Gauntlets', worn_after(gs, '/ma "Fire" <t>').hands, mode)
        end
    end)
end)

describe('BLM\'s Death Mode', function()
    local function death_cast(spell)
        local gs = boot()
        gs:console('gs c set DeathMode Single')
        gs:type('/ma "' .. spell .. '" <t>')
        return gs
    end

    it('wears sets.idle.Death over the idle set', function()
        local gs = boot()
        gs:console('gs c set DeathMode Lock')
        assert.same(jobby.worn_by({body = 'Adamantite Armor'}, jobby.full_idle), gs:worn())
        gs:console('gs c set DeathMode Off')
        assert.same(jobby.worn_by({}, jobby.full_idle), gs:worn())
    end)

    it('puts sets.precast.FC.Death on for any spell', function()
        assert.equal('Volte Bracers', death_cast('Cure IV'):traffic()[1].equip.hands)
    end)

    it('puts the spell\'s own Death precast set over it, when the gear file has one', function()
        assert.equal('Karieyh Ring', death_cast('Fire'):worn().left_ring)
    end)

    it('puts the spell map\'s Death precast set over it, when there is none for the spell', function()
        assert.equal('Karieyh Ring', death_cast('Fire III'):worn().right_ring)
    end)

    it('puts the spell skill\'s Death precast set over it, when there is none for the spell or its map', function()
        assert.equal('Volte Boots', death_cast('Aspir'):worn().feet)
    end)

    it('puts the spell map\'s Death midcast set over sets.midcast.Death', function()
        assert.equal('Null Masque', death_cast('Fire'):worn().head)
    end)

    it('puts the spell skill\'s Death midcast set over sets.midcast.Death when the map has none', function()
        assert.equal('Azimuth Turban', death_cast('Fire III'):worn().head)
    end)

    it('puts the spell\'s own Death midcast set over sets.midcast.Death, when the gear file has one', function()
        assert.equal('Sukeroku Hachi.', death_cast('Stone'):worn().head)
    end)

    it('leaves sets.midcast.Death on, putting sets.precast.FC.Death over it, when nothing is named for the spell', function()
        local worn = death_cast('Aspir'):worn()
        assert.equal('Blistering Sallet', worn.head)
        assert.equal('Volte Bracers', worn.hands)
    end)

    it('puts only sets.midcast.Death on for Death itself', function()
        local worn = death_cast('Death'):worn()
        assert.equal('Blistering Sallet', worn.head)
        assert.equal('Regal Cuffs', worn.hands)
    end)

    it('takes the Death sets over the Proc casting mode', function()
        local gs = boot()
        gs:console('gs c set CastingMode Proc')
        gs:console('gs c set DeathMode Single')
        gs:type('/ma "Aspir" <t>')
        assert.equal('Loricate Torque +1', gs:worn().neck)
        assert.equal('Volte Bracers', gs:worn().hands)
    end)

    it('goes back to Off once Death is cast, in the Single mode', function()
        local gs = death_cast('Death')
        gs:finish_action()
        assert.equal('Off', gs.user.state.DeathMode.value)
        assert.same(jobby.worn_by({}, jobby.full_idle), gs:worn())
    end)

    it('stays Single when Death is interrupted', function()
        local gs = death_cast('Death')
        gs:interrupt_action()
        assert.equal('Single', gs.user.state.DeathMode.value)
    end)

    it('stays Single when another spell is cast', function()
        local gs = death_cast('Fire')
        gs:finish_action()
        assert.equal('Single', gs.user.state.DeathMode.value)
    end)

    it('stays Lock when Death is cast', function()
        local gs = boot()
        gs:console('gs c set DeathMode Lock')
        gs:type('/ma "Death" <t>')
        gs:finish_action()
        assert.equal('Lock', gs.user.state.DeathMode.value)
    end)
end)

describe('BLM\'s Mana Wall', function()
    local gs
    before_each(function()
        gs = boot()
        gs:gain_buff('Mana Wall')
    end)

    it('has sets.buff[\'Mana Wall\'] laid over the idle set', function()
        assert.same(jobby.worn_by({neck = "Combatant's Torque"}, jobby.full_idle), gs:worn())
        gs:lose_buff('Mana Wall')
        assert.same(jobby.worn_by({}, jobby.full_idle), gs:worn())
    end)

    it('has sets.buff[\'Mana Wall\'] laid over the melee set', function()
        gs:engage()
        assert.same(jobby.worn_by({head = 'Volte Cap', body = 'Volte Jupon', neck = "Combatant's Torque"},
            jobby.full_idle), gs:worn())
    end)

    it('has sets.buff[\'Mana Wall\'] laid over the defense set', function()
        gs:console('gs c set DefenseMode Physical')
        assert.same(jobby.worn_by({head = 'Null Masque', neck = "Combatant's Torque"}, jobby.full_idle), gs:worn())
    end)

    it('has sets.buff[\'Mana Wall\'] put back after a spell\'s midcast set in a fight in a DT idle mode', function()
        gs:monster_hits()
        gs:console('gs c set IdleMode DT')
        gs:type('/ma "Fire II" <t>')
        assert.equal("Combatant's Torque", gs:worn().neck)
    end)

    it('leaves the spell\'s precast set\'s neck on after its midcast outside a DT idle mode', function()
        gs:monster_hits()
        gs:type('/ma "Fire II" <t>')
        assert.equal('Fotia Gorget', gs:worn().neck)
    end)

    it('leaves the spell\'s precast set\'s neck on after its midcast out of a fight', function()
        gs:console('gs c set IdleMode DT')
        gs:type('/ma "Fire II" <t>')
        assert.equal('Fotia Gorget', gs:worn().neck)
    end)
end)

describe('BLM\'s idle set', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    local function low_mp()
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 400, 40
        gs:console('gs c update')
    end

    it('has sets.latent_refresh over it under 51% MP', function()
        low_mp()
        assert.same(jobby.worn_by({waist = 'Null Belt'}, jobby.full_idle), gs:worn())
    end)

    it('has no latent refresh set over it in the DT idle mode', function()
        gs:console('gs c set IdleMode DT')
        low_mp()
        assert.same(jobby.worn_by({head = 'Null Masque'}, jobby.full_idle), gs:worn())
    end)

    it('has sets.latent_refresh and the grip over the Sphere idle set under 51% MP, its main being a staff', function()
        gs:console('gs c set IdleMode Sphere')
        low_mp()
        assert.same(jobby.worn_by({main = "Terra's Staff", waist = 'Null Belt', sub = 'Kupo Shield'},
            jobby.full_idle), gs:worn())
    end)

    it('has no grip over it with the weapons locked', function()
        gs:console('gs c set IdleMode Sphere')
        gs:console('gs c set Weapons Staff')
        low_mp()
        assert.same(jobby.worn_by({main = 'Daybreak', sub = 'Ammurapi Shield', waist = 'Null Belt'},
            jobby.full_idle), gs:worn())
    end)

    it('has sets.buff.Sublimation over it while Sublimation charges', function()
        gs:gain_buff('Sublimation: Activated')
        assert.same(jobby.worn_by({back = 'Null Shawl'}, jobby.full_idle), gs:worn())
    end)

    it('has sets.buff.DTSublimation over the DT idle set while Sublimation charges', function()
        gs:console('gs c set IdleMode DT')
        gs:gain_buff('Sublimation: Activated')
        assert.same(jobby.worn_by({head = 'Null Masque', back = 'Null Shawl', ring1 = 'Karieyh Ring'},
            jobby.full_idle), gs:worn())
    end)
end)

describe('BLM\'s weapon skill set', function()
    local function myrkr(tp)
        local gs = boot({tp = tp})
        gs:type('/ws "Myrkr" <me>')
        return gs:worn()
    end

    it('keeps Moonshade Earring on at 2950 TP, which Moonshade makes 3200', function()
        assert.equal('Moonshade Earring', myrkr(2950).left_ear)
    end)

    it('swaps Moonshade Earring for sets.MaxTP over 3200 TP counting Moonshade\'s 250', function()
        assert.equal('Cessance Earring', myrkr(2951).left_ear)
    end)
end)

describe('BLM\'s Sleep timers', function()
    local function timers(spell)
        local gs = boot({sub_job = 'RDM'})
        gs:commands()
        gs:type('/ma "' .. spell .. '" <t>')
        gs:finish_action()
        return gs:commands()
    end

    it('starts a 60 second timer when Sleep lands', function()
        assert.same({'timers c "Sleep [Apex Toad]" 60 down spells/00220.png'}, timers('Sleep'))
    end)

    it('starts a 60 second timer when Sleepga lands', function()
        assert.same({'timers c "Sleepga [Apex Toad]" 60 down spells/00220.png'}, timers('Sleepga'))
    end)

    it('starts a 90 second timer when Sleep II lands', function()
        assert.same({'timers c "Sleep II [Apex Toad]" 90 down spells/00220.png'}, timers('Sleep II'))
    end)

    it('starts a 90 second timer when Sleepga II lands', function()
        assert.same({'timers c "Sleepga II [Apex Toad]" 90 down spells/00220.png'}, timers('Sleepga II'))
    end)

    it('starts no timer when Sleep is interrupted', function()
        local gs = boot()
        gs:type('/ma "Sleep" <t>')
        gs:interrupt_action()
        assert.same({}, gs:commands())
    end)

    pending('starts no timer with Use Custom Timers off: job_aftercast in data/BLM.lua never reads '
        .. 'state.UseCustomTimers, so each Sleep that lands starts one')
end)

describe('BLM\'s Manawell', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is used first for Impact, which then goes out a second later', function()
        gs:type('/ma "Impact" <t>')
        assert.same({'Manawell'}, gs:actions())
        gs:finish_action()
        gs.game:start_ability_recast('Manawell', 60)
        gs:advance(0.95)
        assert.same({}, gs:actions())
        gs:advance(0.1)
        assert.same({'Impact'}, gs:actions())
    end)

    it('is not used for Impact with Auto Manawell off', function()
        gs:console('gs c toggle AutoManawell')
        gs:type('/ma "Impact" <t>')
        assert.same({'Impact'}, gs:actions())
    end)

    it('is not used for Impact while it is on recast', function()
        gs.game:start_ability_recast('Manawell', 60)
        gs:type('/ma "Impact" <t>')
        assert.same({'Impact'}, gs:actions())
    end)

    it('is not used for Impact under amnesia', function()
        gs:gain_buff('amnesia')
        gs:type('/ma "Impact" <t>')
        assert.same({'Impact'}, gs:actions())
    end)

    it('is not used for another spell', function()
        gs:type('/ma "Meteor" <t>')
        assert.same({'Meteor'}, gs:actions())
    end)

    it('is used for Meteor in the OccultAcumen casting mode when Jobby hasn\'t the MP', function()
        gs:console('gs c set CastingMode OccultAcumen')
        gs.game.player.vitals.mp = 400
        gs:type('/ma "Meteor" <t>')
        assert.same({'Manawell'}, gs:actions())
    end)

    it('is not used for Meteor in the OccultAcumen casting mode when Jobby has the MP', function()
        gs:console('gs c set CastingMode OccultAcumen')
        gs.game.player.vitals.mp = 418
        gs:type('/ma "Meteor" <t>')
        assert.same({'Meteor'}, gs:actions())
    end)
end)

describe('BLM\'s Auto Arts', function()
    local buffed = {'Reraise', 'Haste', 'Stoneskin'}

    it('uses Dark Arts with Scholar as the sub job once Auto Arts is on, in a fight', function()
        local gs = boot_ticking({sub_job = 'SCH', buffs = buffed})
        gs:console('gs c set AutoArts true')
        gs:engage()
        gs:traffic()
        gs:play_until_action()
        assert.same({'Dark Arts'}, gs:actions())
    end)

    it('uses Dark Arts with Auto Buff Mode on, out of a fight', function()
        local gs = boot_ticking({sub_job = 'SCH', buffs = buffed})
        gs:console('gs c set AutoArts true')
        gs:console('gs c set AutoBuffMode Auto')
        gs:play_until_action()
        assert.same({'Dark Arts'}, gs:actions())
    end)

    it('uses nothing with Auto Arts off', function()
        local gs = boot_ticking({sub_job = 'SCH', buffs = buffed})
        gs:engage()
        gs:traffic()
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Dark Arts with Dark Arts up', function()
        local gs = boot_ticking({sub_job = 'SCH', buffs = buffed})
        gs:console('gs c set AutoArts true')
        gs:console('gs c set AutoBuffMode Auto')
        gs:gain_buff('Dark Arts')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Dark Arts with Light Arts up', function()
        local gs = boot_ticking({sub_job = 'SCH', buffs = buffed})
        gs:console('gs c set AutoArts true')
        gs:console('gs c set AutoBuffMode Auto')
        gs:gain_buff('Light Arts')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Dark Arts while the sub job\'s abilities are restricted', function()
        local gs = boot_ticking({sub_job = 'SCH', buffs = buffed})
        gs:console('gs c set AutoArts true')
        gs:console('gs c set AutoBuffMode Auto')
        gs:gain_buff('SJ Restriction')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Dark Arts without Scholar as the sub job', function()
        local gs = boot_ticking({sub_job = 'WHM', buffs = buffed})
        gs:console('gs c set AutoArts true')
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(3)
        assert.same({}, gs:actions())
    end)
end)

describe('BLM\'s Auto Buff Mode', function()
    local function buffing(options)
        local gs = boot_ticking(options)
        gs:console('gs c set AutoBuffMode Auto')
        return gs
    end

    it('starts with Reraise', function()
        local gs = buffing()
        gs:play_until_action()
        assert.same({'Reraise'}, gs:actions())
    end)

    it('goes on to Haste with Reraise up', function()
        local gs = buffing()
        gs:gain_buff('Reraise')
        gs:play_until_action()
        assert.same({'Haste'}, gs:actions())
    end)

    it('goes on to Stoneskin when Jobby can\'t cast Refresh', function()
        local gs = buffing()
        gs:gain_buff('Reraise')
        gs:gain_buff('Haste')
        gs:play_until_action()
        assert.same({'Stoneskin'}, gs:actions())
    end)

    it('casts Klimaform only in a fight', function()
        local gs = buffing({sub_job = 'SCH', buffs = {'Reraise', 'Stoneskin'}})
        gs:play(3)
        assert.same({}, gs:actions())
        gs:monster_hits()
        gs:play_until_action()
        assert.same({'Klimaform'}, gs:actions())
    end)

    pending('keeps Reraise on recast from being cast: the Auto and Default lists in data/BLM.lua give Reraise the '
        .. 'spell id 113, Rainstorm\'s, so its recast is read from the wrong spell')
end)

describe('BLM\'s elemental commands', function()
    local function command(mode, name, recasts, mp)
        local gs = boot_ticking({sub_job = 'WHM'})
        gs:console('gs c set ElementalMode ' .. mode)
        if recasts then
            for spell, seconds in pairs(recasts) do
                gs.game:start_spell_recast(spell, seconds)
            end
        end
        if mp then
            gs.game.player.vitals.mp = mp
        end
        gs:console('gs c elemental ' .. name)
        return gs:actions(), gs
    end

    it('nukes with the highest tier, Fire VI, in another mode', function()
        assert.same({'Fire VI'}, (command('Fire', 'nuke')))
    end)

    it('goes down a tier when that one is on recast', function()
        assert.same({'Fire V'}, (command('Fire', 'nuke', {['Fire VI'] = 10})))
    end)

    it('goes down a tier when Jobby hasn\'t the MP', function()
        assert.same({'Fire V'}, (command('Fire', 'nuke', nil, 338)))
    end)

    pending('nukes with Fire VI with just its cost in MP, 339: handle_job_elemental in data/BLM.lua takes a tier only '
        .. 'with more MP than it costs (actual_cost < player.mp), so it goes down to Fire V')

    it('casts nothing more once the nuke is done', function()
        local _, gs = command('Fire', 'nuke')
        gs:finish_action()
        gs:play(10)
        assert.same({}, gs:actions())
    end)

    it('smallnuke uses the second tier', function()
        assert.same({'Fire II'}, (command('Fire', 'smallnuke')))
    end)

    it('says so when every tier is on recast', function()
        local recasts = {}
        for _, spell in ipairs({'Fire VI', 'Fire V', 'Fire IV', 'Fire III', 'Fire II', 'Fire'}) do
            recasts[spell] = 10
        end
        local gs = boot_ticking()
        gs:console('gs c set ElementalMode Fire')
        for spell, seconds in pairs(recasts) do
            gs.game:start_spell_recast(spell, seconds)
        end
        gs:chat()
        gs:console('gs c elemental nuke')
        assert.same({}, gs:actions())
        assert.same({'Abort: All Fire nukes on cooldown or or not enough MP.'}, gs:chat())
    end)

    it('nukes with Banish II in the Light mode', function()
        assert.same({'Banish II'}, (command('Light', 'nuke')))
    end)

    it('goes down to Banish when Banish II is on recast in the Light mode', function()
        assert.same({'Banish'}, (command('Light', 'nuke', {['Banish II'] = 10})))
    end)

    it('casts the ancient magic of the element', function()
        assert.same({'Flare'}, (command('Fire', 'ancientmagic')))
    end)

    it('casts the second tier of the ancient magic', function()
        assert.same({'Flare II'}, (command('Fire', 'ancientmagic2')))
    end)

    it('casts the highest tier of the aoe nuke, the -ja one', function()
        assert.same({'Firaja'}, (command('Fire', 'aga')))
    end)

    it('goes down the aoe tiers on recast', function()
        assert.same({'Firaga III'}, (command('Fire', 'aga', {['Firaja'] = 10})))
        assert.same({'Firaga II'}, (command('Fire', 'aga', {['Firaja'] = 10, ['Firaga III'] = 10})))
        assert.same({'Firaga'}, (command('Fire', 'aga', {['Firaja'] = 10, ['Firaga III'] = 10, ['Firaga II'] = 10})))
    end)

    it('casts the -ja nuke for aja', function()
        assert.same({'Firaja'}, (command('Fire', 'aja')))
    end)

    it('says so when every aoe tier is on recast', function()
        local gs = boot_ticking()
        gs:console('gs c set ElementalMode Fire')
        gs.game:start_spell_recast('Firaja', 10)
        gs.game:start_spell_recast('Firaga III', 10)
        gs.game:start_spell_recast('Firaga II', 10)
        gs.game:start_spell_recast('Firaga', 10)
        gs:chat()
        gs:console('gs c elemental aga')
        assert.same({}, gs:actions())
        assert.same({'Abort: All Fire aoe nukes on cooldown or or not enough MP.'}, gs:chat())
    end)

    it('says so when both Banishes are on recast in the Light mode', function()
        local gs = boot_ticking()
        gs:console('gs c set ElementalMode Light')
        gs.game:start_spell_recast('Banish', 10)
        gs.game:start_spell_recast('Banish II', 10)
        gs:chat()
        gs:console('gs c elemental nuke')
        assert.same({}, gs:actions())
        assert.same({'Abort: Banishes on cooldown or not enough MP.'}, gs:chat())
    end)

    it('hands a command it doesn\'t know on to Sel\'s elemental commands', function()
        local gs = boot_ticking({sub_job = 'RDM'})
        gs:console('gs c set ElementalMode Fire')
        gs:console('gs c elemental barelement')
        assert.same({'Barblizzard'}, gs:actions())
    end)
end)

describe('BLM\'s status line', function()
    it('says the casting and idle modes, as a caster\'s does', function()
        local gs = boot()
        gs:console('gs c update user')
        local lines = gs:chat()
        assert.is_truthy(lines[#lines]:find('Casting [Normal], Idle [Normal]', 1, true), lines[#lines])
    end)
end)

describe('BLM\'s buff states', function()
    it('follow the buffs as they come and go', function()
        local gs = boot()
        gs:gain_buff('Manafont')
        assert.is_true(gs.user.state.Buff['Manafont'])
        gs:lose_buff('Manafont')
        assert.is_false(gs.user.state.Buff['Manafont'])
    end)

    it('start with Auto Manawell on and Death Mode off', function()
        local gs = boot()
        assert.is_true(gs.user.state.AutoManawell.value)
        assert.equal('Off', gs.user.state.DeathMode.value)
    end)
end)
