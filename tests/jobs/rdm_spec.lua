local jobby = require('jobby')

local gear = {'Naegling', 'Crocea Mors', 'Murgleis', 'Regal Gem', 'Ullr', 'Zodiac Ring', "Orpheus's Sash",
    'Karin Obi', 'Hachirin-no-Obi', "Terra's Staff", 'Enki Strap', 'Kupo Shield', 'Ammurapi Shield', 'Volte Cap',
    'Null Masque', 'Volte Jupon', 'Adamantite Armor', 'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Fotia Gorget',
    "Combatant's Torque", 'Karieyh Ring', 'Chirich Ring +1', 'Null Belt', 'Null Shawl', 'Amin Turban', 'Ischkur Turban',
    'Azimuth Turban', 'Blistering Sallet +1', 'Alhazen Hat', 'Alhazen Hat +1', 'Sukeroku Hachi.', "Bendis's Hairpin",
    'Blacksh. Hairpin', 'Moonshade Earring', 'Brutal Earring', 'Cessance Earring', 'Odnowa Earring +1',
    'Ishvara Earring', 'Telos Earring', 'Gozuki Mezuki'}

local function without(names, removed)
    local kept = {}
    for _, name in ipairs(names) do
        if not removed[name] then
            kept[#kept + 1] = name
        end
    end
    return kept
end

local function boot(options)
    options = options or {}
    options.items = options.items or gear
    options.sub_job = options.sub_job or 'WHM'
    return jobby.boot('RDM', options)
end

local function boot_ticking(options)
    options = options or {}
    options.items = options.items or gear
    options.sub_job = options.sub_job or 'WHM'
    return jobby.boot_ticking('RDM', options)
end

-- What the idle set of Jobby's red mage gear file wears, as the game shows it worn, with his sword in hand.
local idle = jobby.worn_by(jobby.full_idle, jobby.weapons.RDM)

local light_day, light_weather = 6, 16

local function worn_after(gs, line)
    gs:type(line)
    return gs:worn()
end

describe('RDM\'s weapon skill filter', function()
    -- A club in hand gives the weapon skill Shining Strike, a dagger Wasp Sting; Jobby has the club's and the
    -- dagger's weapon skills a swap sends, and not the sword's it types.
    local club = {'Shining Strike', 'Black Halo', 'Brainshaker', 'True Strike', 'Starlight'}
    local dagger = {'Wasp Sting', 'Exenterator', 'Aeolian Edge', 'Evisceration', 'Energy Drain'}

    local function sent(known, typed)
        local gs = boot({tp = 1000, abilities = known})
        gs:type('/ws "' .. typed .. '" <t>')
        local traffic = gs:traffic()
        return gs:actions(traffic), traffic
    end

    it('sends Black Halo in place of Savage Blade with a club\'s weapon skills', function()
        assert.same({'Black Halo'}, (sent(club, 'Savage Blade')))
    end)

    it('sends Shining Strike in place of Shining Blade with a club\'s weapon skills', function()
        assert.same({'Shining Strike'}, (sent(club, 'Shining Blade')))
    end)

    it('sends Brainshaker in place of Flat Blade with a club\'s weapon skills', function()
        assert.same({'Brainshaker'}, (sent(club, 'Flat Blade')))
    end)

    it('sends Starlight, aimed at Jobby, in place of Sanguine Blade with a club\'s weapon skills', function()
        local _, traffic = sent(club, 'Sanguine Blade')
        assert.same({action = 'Starlight', target = 'Jobby'}, traffic[#traffic])
    end)

    it('sends Exenterator in place of Savage Blade with a dagger\'s weapon skills', function()
        assert.same({'Exenterator'}, (sent(dagger, 'Savage Blade')))
    end)

    it('sends Aeolian Edge in place of Circle Blade with a dagger\'s weapon skills', function()
        assert.same({'Aeolian Edge'}, (sent(dagger, 'Circle Blade')))
    end)

    it('sends Energy Drain in place of Sanguine Blade with a dagger\'s weapon skills', function()
        assert.same({'Energy Drain'}, (sent(dagger, 'Sanguine Blade')))
    end)

    it('sends nothing in place of Shining Blade with a dagger\'s weapon skills, which have no swap for it', function()
        assert.same({}, (sent(dagger, 'Shining Blade')))
    end)

    it('sends nothing in place of Flat Blade with a dagger\'s weapon skills', function()
        assert.same({}, (sent(dagger, 'Flat Blade')))
    end)

    it('sends nothing without a club\'s or a dagger\'s weapon skills', function()
        assert.same({}, (sent({'Requiescat'}, 'Savage Blade')))
    end)

    it('takes the club\'s swap when Jobby has the dagger\'s weapon skills as well', function()
        local both = {}
        for _, name in ipairs(club) do both[#both + 1] = name end
        for _, name in ipairs(dagger) do both[#both + 1] = name end
        assert.same({'Black Halo'}, (sent(both, 'Savage Blade')))
    end)

    it('lets a weapon skill Jobby has go out as it is', function()
        assert.same({'Savage Blade'}, (sent({'Savage Blade', 'Shining Strike'}, 'Savage Blade')))
    end)

    pending('sends True Strike, or Evisceration, in place of Chant du Cygne: job_filtered_action in data/RDM.lua '
        .. 'compares the name with "Chant Du Cygne", which no weapon skill is called')
end)

describe('RDM\'s Phalanx', function()
    it('cast on another player is cast as Phalanx II instead, on that player', function()
        local gs = boot()
        jobby.target_a_player(gs)
        gs:type('/ma "Phalanx" <t>')
        assert.same({{action = 'Phalanx II', target = 'Pal'}}, gs:action_entries())
    end)

    it('cast on oneself is cast as it is', function()
        local gs = boot()
        gs:type('/ma "Phalanx" <me>')
        assert.same({'Phalanx'}, gs:actions())
    end)
end)

describe('RDM\'s Convert', function()
    it('is stopped with no MP, with a notice', function()
        local gs = boot()
        gs.game.player.vitals.mp, gs.game.player.vitals.mpp = 0, 0
        gs:chat()
        gs:type('/ja "Convert" <me>')
        assert.same({}, gs:traffic())
        assert.same({'Abort: Convert will fail with 0 MP.'}, gs:chat())
    end)

    it('goes out with MP', function()
        local gs = boot()
        gs:type('/ja "Convert" <me>')
        assert.same({'Convert'}, gs:actions())
    end)

    local function convert(tp, mode)
        local gs = boot()
        gs:console('gs c set Weapons Naegling')
        gs:set_tp(tp)
        if mode then
            gs:console('gs c set MurgleisMode ' .. mode)
        end
        gs:type('/ja "Convert" <me>')
        return gs:worn().main, gs
    end

    it('puts Murgleis on through the weapon lock, the first Murgleis Mode being Always', function()
        assert.equal('Murgleis', (convert(3000)))
    end)

    it('puts the weapon set\'s main back once Convert is done', function()
        local _, gs = convert(0)
        gs:finish_action()
        assert.equal('Naegling', gs:worn().main)
    end)

    it('leaves the weapon set\'s main on in Murgleis Mode Never', function()
        assert.equal('Naegling', (convert(0, 'Never')))
    end)

    it('puts Murgleis on in Murgleis Mode 500 with TP under 500', function()
        assert.equal('Murgleis', (convert(499, '500')))
    end)

    it('leaves the weapon set\'s main on in Murgleis Mode 500 with 500 TP', function()
        assert.equal('Naegling', (convert(500, '500')))
    end)

    it('keeps the weapon set\'s weapons locked without Murgleis', function()
        local gs = boot({items = without(gear, {Murgleis = true})})
        gs:console('gs c set Weapons EnspellMelee')
        gs:type('/ja "Convert" <me>')
        assert.equal('Ammurapi Shield', gs:worn().sub)
    end)
end)

describe('RDM\'s buff weapons', function()
    local function main_after(line, tp, mode)
        local gs = boot()
        gs:console('gs c set Weapons Naegling')
        gs:set_tp(tp)
        if mode then
            gs:console('gs c set BuffWeaponsMode ' .. mode)
        end
        return worn_after(gs, line).main
    end

    it('stay locked for an enspell, the first Buff Weapons Mode being Never', function()
        assert.equal('Naegling', main_after('/ma "Enfire" <me>', 0))
    end)

    it('let an enspell\'s midcast weapons through in Buff Weapons Mode Always', function()
        assert.equal('Crocea Mors', main_after('/ma "Enfire" <me>', 3000, 'Always'))
    end)

    it('let an enspell\'s midcast weapons through in Buff Weapons Mode 500 with TP under 500', function()
        assert.equal('Crocea Mors', main_after('/ma "Enfire" <me>', 499, '500'))
    end)

    it('stay locked for an enspell in Buff Weapons Mode 500 with 500 TP', function()
        assert.equal('Naegling', main_after('/ma "Enfire" <me>', 500, '500'))
    end)

    it('let Temper II\'s midcast weapons through in Buff Weapons Mode Always', function()
        assert.equal('Crocea Mors', main_after('/ma "Temper II" <me>', 0, 'Always'))
    end)

    it('let Phalanx II\'s midcast weapons through on oneself in Buff Weapons Mode Always', function()
        assert.equal('Crocea Mors', main_after('/ma "Phalanx II" <me>', 0, 'Always'))
    end)

    it('stay locked for Phalanx II on another player', function()
        local gs = boot()
        jobby.target_a_player(gs)
        gs:console('gs c set Weapons Naegling')
        gs:console('gs c set BuffWeaponsMode Always')
        assert.equal('Naegling', worn_after(gs, '/ma "Phalanx II" <t>').main)
    end)

    it('stay locked for Haste', function()
        assert.equal('Naegling', main_after('/ma "Haste" <me>', 0, 'Always'))
    end)

    it('go back to the weapon set\'s once the spell is done', function()
        local gs = boot()
        gs:console('gs c set Weapons Naegling')
        gs:console('gs c set BuffWeaponsMode Always')
        gs:type('/ma "Enfire" <me>')
        gs:finish_action()
        assert.equal('Naegling', gs:worn().main)
    end)
end)

describe('RDM\'s Chainspell and Spontaneity', function()
    -- The midcast set of Haste, wearing body Volte Jupon, is on before the spell goes out.
    local function precast_equip(setup)
        local gs = boot()
        if setup then
            setup(gs)
        end
        gs:type('/ma "Haste" <me>')
        return gs:traffic()[1].equip
    end

    it('put the midcast set on at precast under Chainspell', function()
        assert.equal('Volte Jupon', precast_equip(function(gs) gs:gain_buff('Chainspell') end).body)
    end)

    it('put the midcast set on at precast under Spontaneity', function()
        assert.equal('Volte Jupon', precast_equip(function(gs) gs:gain_buff('Spontaneity') end).body)
    end)

    it('leave the precast set alone otherwise', function()
        assert.is_nil(precast_equip().body)
    end)
end)

describe('RDM\'s weapon skill set', function()
    local function ws(tp, line, mode)
        local gs = boot({tp = tp})
        if mode then
            gs:console('gs c set OffenseMode ' .. mode)
        end
        return jobby.weaponskill(gs, line)
    end

    it('keeps Moonshade Earring on at 2950 TP, which reaches 3000 only with Moonshade', function()
        assert.equal('Moonshade Earring', ws(2950, '/ws "Savage Blade" <t>').left_ear)
    end)

    it('swaps Moonshade Earring for sets.MaxTP from 2951 TP', function()
        assert.equal('Cessance Earring', ws(2951, '/ws "Savage Blade" <t>').left_ear)
    end)

    it('swaps in sets.AccMaxTP at the cap in an accuracy offense mode', function()
        assert.equal('Odnowa Earring +1', ws(3000, '/ws "Savage Blade" <t>', 'Acc').left_ear)
    end)

    it('swaps in sets.MaxTP, not sets.AccMaxTP, under Sneak Attack in an accuracy offense mode', function()
        local gs = boot({tp = 3000})
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Sneak Attack')
        assert.equal('Cessance Earring', jobby.weaponskill(gs, '/ws "Savage Blade" <t>').left_ear)
    end)

    it('swaps in sets.MagicalMaxTP at the cap for an elemental weapon skill', function()
        assert.equal('Ishvara Earring', ws(3000, '/ws "Seraph Blade" <t>').left_ear)
    end)

    it('swaps in sets.MagicalAccMaxTP at the cap for an elemental weapon skill in an accuracy offense mode', function()
        assert.equal('Telos Earring', ws(3000, '/ws "Seraph Blade" <t>', 'Acc').left_ear)
    end)

    -- A gear file with no sets for the magical weapon skills.
    it('swaps in sets.MaxTP at the cap for an elemental weapon skill when the gear file has no magical sets', function()
        local gs = boot({tp = 3000})
        gs.user.sets.MagicalMaxTP, gs.user.sets.MagicalAccMaxTP = nil, nil
        assert.equal('Cessance Earring', jobby.weaponskill(gs, '/ws "Seraph Blade" <t>').left_ear)
    end)

    it('swaps in sets.MagicalMaxTP in an accuracy offense mode when the gear file has no accuracy one', function()
        local gs = boot({tp = 3000})
        gs.user.sets.MagicalAccMaxTP = nil
        gs:console('gs c set OffenseMode Acc')
        assert.equal('Ishvara Earring', jobby.weaponskill(gs, '/ws "Seraph Blade" <t>').left_ear)
    end)
end)

-- Sel counts a weapon's TP Bonus from the hand it works in: a Magian weapon's, Thibron's +1000, from either hand, and
-- an Aeonic weapon's, Sequence's +500, from the main hand only. Each TP here reaches the cap with the weapon's bonus
-- and stays short of it without, with or without Moonshade's +250, so the hand alone decides.
describe('RDM\'s weapon skill set by the TP Bonus of the weapons in hand', function()
    -- Jobby with the Dual Wield trait a Ninja sub job gives, holding those weapons, once Savage Blade has gone out at
    -- that TP.
    local function ws(tp, wearing)
        local gs = boot({sub_job = 'NIN', items = {'Thibron', 'Sequence', unpack(gear)}, wearing = wearing})
        jobby.can_dual_wield(gs)
        return jobby.weaponskill(gs, '/ws "Savage Blade" <t>', tp)
    end

    it('swaps Moonshade Earring for sets.MaxTP at 2000 TP with Thibron\'s +1000 from the sub slot', function()
        assert.equal('Cessance Earring', ws(2000, {main = 'Naegling', sub = 'Thibron'}).left_ear)
    end)

    it('swaps Moonshade Earring for sets.MaxTP at 2500 TP with Sequence\'s +500 from the main hand', function()
        assert.equal('Cessance Earring', ws(2500, {main = 'Sequence'}).left_ear)
    end)

    it('keeps Moonshade Earring on at 2500 TP with Sequence in the sub slot, whose TP Bonus works from the main hand only', function()
        assert.equal('Moonshade Earring', ws(2500, {main = 'Naegling', sub = 'Sequence'}).left_ear)
    end)
end)

describe('RDM\'s midcast set for an elemental spell', function()
    local function ammo_after(line, weapons)
        local gs = boot()
        if weapons then
            gs:console('gs c set Weapons ' .. weapons)
        end
        return worn_after(gs, line).ammo
    end

    it('puts Regal Gem on for a nuke when the set names Ullr and the weapon set empties the range slot', function()
        assert.equal('Regal Gem', ammo_after('/ma "Fire III" <t>', 'Ullr'))
    end)

    it('puts Regal Gem on for an enfeeble the same way', function()
        assert.equal('Regal Gem', ammo_after('/ma "Paralyze" <t>', 'Ullr'))
    end)

    it('puts Regal Gem on for a dark spell the same way', function()
        assert.equal('Regal Gem', ammo_after('/ma "Bio" <t>', 'Ullr'))
    end)

    it('leaves the ammo alone without that weapon set', function()
        assert.equal('Staunch Tathlum +1', ammo_after('/ma "Fire III" <t>', 'Naegling'))
        assert.equal('Staunch Tathlum +1', ammo_after('/ma "Fire III" <t>'))
    end)

    it('leaves the ammo alone for Impact', function()
        assert.equal('Staunch Tathlum +1', ammo_after('/ma "Impact" <t>', 'Ullr'))
    end)

    it('leaves the ammo alone for a spell of another skill', function()
        assert.equal('Staunch Tathlum +1', ammo_after('/ma "Cure IV" <me>', 'Ullr'))
    end)
end)

describe('RDM\'s enfeebling spells', function()
    it('have sets.buff.Saboteur laid over the midcast set under Saboteur', function()
        local gs = boot()
        gs:gain_buff('Saboteur')
        local worn = worn_after(gs, '/ma "Paralyze" <t>')
        assert.equal('Volte Hose', worn.legs)
        assert.equal('Null Masque', worn.head)
    end)

    it('have the spell\'s Stymie set laid over the midcast set under Stymie, when it has one', function()
        local gs = boot()
        gs:gain_buff('Stymie')
        local worn = worn_after(gs, '/ma "Slow" <t>')
        assert.equal('Volte Jupon', worn.body)
        assert.equal('Nyame Gauntlets', worn.hands)
    end)

    it('have sets.buff.Stymie laid over the midcast set under Stymie, when the spell has no Stymie set', function()
        local gs = boot()
        gs:gain_buff('Stymie')
        assert.equal('Volte Bracers', worn_after(gs, '/ma "Paralyze" <t>').hands)
    end)

    it('have both laid over the midcast set under Stymie and Saboteur', function()
        local gs = boot()
        gs:gain_buff('Stymie')
        gs:gain_buff('Saboteur')
        local worn = worn_after(gs, '/ma "Paralyze" <t>')
        assert.equal('Volte Bracers', worn.hands)
        assert.equal('Volte Hose', worn.legs)
    end)

    it('have neither laid over them without the buffs', function()
        local worn = worn_after(boot(), '/ma "Paralyze" <t>')
        assert.equal('Nyame Gauntlets', worn.hands)
        assert.equal('Nyame Flanchard', worn.legs)
    end)

    it('have no Saboteur set laid over a dark spell, Saboteur being for enfeebling spells only', function()
        local gs = boot()
        gs:gain_buff('Saboteur')
        assert.equal('Nyame Flanchard', worn_after(gs, '/ma "Bio" <t>').legs)
    end)

    it('have sets.midcast[\'Enfeebling Magic\'].Resistant in the Resistant casting mode', function()
        local gs = boot()
        gs:console('gs c set CastingMode Resistant')
        assert.equal('Ischkur Turban', worn_after(gs, '/ma "Paralyze" <t>').head)
    end)

    it('keep the Resistant set off under Stymie in the Resistant casting mode', function()
        local gs = boot()
        gs:console('gs c set CastingMode Resistant')
        gs:gain_buff('Stymie')
        assert.equal('Null Masque', worn_after(gs, '/ma "Paralyze" <t>').head)
    end)
end)

describe('RDM\'s enhancing spells', function()
    it('have sets.midcast[\'Enhancing Magic\'] laid over their own set', function()
        local worn = worn_after(boot(), '/ma "Haste" <me>')
        assert.equal('Volte Cap', worn.head)
        assert.equal('Volte Jupon', worn.body)
    end)

    it('have sets.midcast[\'Enhancing Magic\'] alone when nothing is named for them', function()
        local worn = worn_after(boot(), '/ma "Blink" <me>')
        assert.equal('Volte Cap', worn.head)
        assert.equal('Nyame Mail', worn.body)
    end)

    it('have the set of the spell map laid over it for an enspell', function()
        local worn = worn_after(boot(), '/ma "Enfire" <me>')
        assert.equal('Volte Cap', worn.head)
        assert.equal('Volte Bracers', worn.hands)
    end)

    it('have sets.buff.ComposureOther laid over them on another player under Composure', function()
        local gs = boot()
        jobby.target_a_player(gs)
        gs:gain_buff('Composure')
        assert.equal('Volte Boots', worn_after(gs, '/ma "Haste" <t>').feet)
    end)

    it('have no ComposureOther set on oneself under Composure', function()
        local gs = boot()
        gs:gain_buff('Composure')
        assert.equal('Nyame Sollerets', worn_after(gs, '/ma "Haste" <me>').feet)
    end)

    it('have no ComposureOther set on another player without Composure', function()
        local gs = boot()
        jobby.target_a_player(gs)
        assert.equal('Nyame Sollerets', worn_after(gs, '/ma "Haste" <t>').feet)
    end)

    it('have sets.Self_Phalanx laid over them for Phalanx II on oneself', function()
        assert.equal('Null Belt', worn_after(boot(), '/ma "Phalanx II" <me>').waist)
    end)

    it('have no Self_Phalanx set for Phalanx II on another player', function()
        local gs = boot()
        jobby.target_a_player(gs)
        assert.equal('Plat. Mog. Belt', worn_after(gs, '/ma "Phalanx II" <t>').waist)
    end)

    it('have sets.Self_Refresh laid over them for Refresh II on oneself', function()
        assert.equal('Karieyh Ring', worn_after(boot(), '/ma "Refresh II" <me>').left_ring)
    end)

    it('have no Self_Refresh set for Refresh II on another player', function()
        local gs = boot()
        jobby.target_a_player(gs)
        assert.equal('Chirich Ring +1', worn_after(gs, '/ma "Refresh II" <t>').left_ring)
    end)

    it('have the spell\'s SIRD set laid over them in the SIRD casting mode in a fight', function()
        local gs = boot()
        gs:console('gs c set CastingMode SIRD')
        gs:monster_hits()
        assert.equal('Adamantite Armor', worn_after(gs, '/ma "Haste" <me>').body)
    end)

    it('have the spell map\'s SIRD set laid over them when the spell has none', function()
        local gs = boot()
        gs:console('gs c set CastingMode SIRD')
        gs:monster_hits()
        assert.equal('Adamantite Armor', worn_after(gs, '/ma "Enfire" <me>').body)
    end)

    it('have no SIRD set laid over them out of a fight', function()
        local gs = boot()
        gs:console('gs c set CastingMode SIRD')
        assert.equal('Volte Jupon', worn_after(gs, '/ma "Haste" <me>').body)
    end)

    it('have no SIRD set laid over them in another casting mode', function()
        local gs = boot()
        gs:monster_hits()
        assert.equal('Volte Jupon', worn_after(gs, '/ma "Haste" <me>').body)
    end)

    describe('when Jobby can dual wield', function()
        local gs
        before_each(function()
            gs = boot()
            jobby.can_dual_wield(gs)
        end)

        it('have the spell\'s DW set laid over them', function()
            assert.equal("Combatant's Torque", worn_after(gs, '/ma "Haste" <me>').neck)
        end)

        it('have the spell map\'s DW set laid over them when the spell has none', function()
            assert.equal('Volte Hose', worn_after(gs, '/ma "Enfire" <me>').legs)
        end)

        it('have sets.Self_Phalanx.DW laid over sets.Self_Phalanx for Phalanx II on oneself', function()
            local worn = worn_after(gs, '/ma "Phalanx II" <me>')
            assert.equal('Null Belt', worn.waist)
            assert.equal("Combatant's Torque", worn.neck)
        end)
    end)

    it('have no DW set laid over them when Jobby can\'t dual wield', function()
        local gs = boot()
        assert.equal('Loricate Torque +1', worn_after(gs, '/ma "Haste" <me>').neck)
        assert.equal('Nyame Flanchard', worn_after(boot(), '/ma "Enfire" <me>').legs)
    end)
end)

describe('RDM\'s cure sets', function()
    local function cure_head(setup, spell)
        local gs = boot()
        gs:set_weather(setup.weather and light_weather or 0)
        gs:set_day(setup.day and light_day or 0)
        if setup.weapons then
            gs:console('gs c set Weapons Naegling')
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
    end)

    it('is sets.midcast.Cure for a map the gear file has no set for', function()
        local gs = boot()
        gs.user.sets.midcast.MeleeLightWeatherCure = nil
        gs:set_weather(light_weather)
        gs:console('gs c set Weapons Naegling')
        assert.equal('Blistering Sallet +1', worn_after(gs, '/ma "Cure IV" <me>').head)
    end)
end)

describe('RDM\'s nuke sets', function()
    local function head_after(line)
        return worn_after(boot(), line).head
    end

    it('is sets.midcast.LowTierNuke for a low tier nuke', function()
        assert.equal('Volte Cap', head_after('/ma "Fire" <t>'))
        assert.equal('Volte Cap', head_after('/ma "Thunder II" <t>'))
    end)

    it('is sets.midcast.HighTierNuke for a high tier nuke', function()
        assert.equal('Amin Turban', head_after('/ma "Fire III" <t>'))
    end)
end)

describe('RDM\'s idle set', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('has sets.latent_refresh over it under 51% MP', function()
        jobby.low_mp(gs)
        assert.same(jobby.worn_by(idle, {waist = 'Null Belt'}), gs:worn())
    end)

    it('has sets.latent_refresh and the grip over the Sphere idle set under 51% MP, its main being a staff', function()
        gs:console('gs c set IdleMode Sphere')
        jobby.low_mp(gs)
        assert.same(jobby.worn_by(idle,
            {main = "Terra's Staff", waist = 'Null Belt', sub = 'Enki Strap'}), gs:worn())
    end)

    it('has sets.latent_refresh but no grip over the Sphere idle set under 51% MP when its main is no staff',
        function()
        gs:console('gs c set IdleMode Sphere')
        gs.user.sets.idle.Sphere.main = 'Naegling'
        gs:traffic()
        jobby.low_mp(gs)
        assert.same({}, jobby.subs_asked(gs))
        assert.same({'Naegling', 'Null Belt'}, {gs:worn().main, gs:worn().waist})
    end)

    it('has sets.TPEat over it too with more than 10 TP', function()
        gs:console('gs c set IdleMode Sphere')
        gs:set_tp(11)
        jobby.low_mp(gs)
        assert.same(jobby.worn_by(idle, {main = "Terra's Staff", waist = 'Null Belt', sub = 'Enki Strap',
            ear1 = 'Cessance Earring'}), gs:worn())
    end)

    it('has no sets.TPEat over it with 10 TP', function()
        gs:console('gs c set IdleMode Sphere')
        gs:set_tp(10)
        jobby.low_mp(gs)
        assert.same(jobby.worn_by(idle,
            {main = "Terra's Staff", waist = 'Null Belt', sub = 'Enki Strap'}), gs:worn())
    end)

    it('has no grip or sets.TPEat over the Sphere idle set with the weapons locked to a staff', function()
        gs:console('gs c set IdleMode Sphere')
        gs:console('gs c set Weapons Staff')
        gs:set_tp(300)
        jobby.low_mp(gs)
        assert.same(jobby.worn_by(idle, {main = 'Gozuki Mezuki', waist = 'Null Belt'}), gs:worn())
    end)

    it('has the grip and sets.TPEat over the Sphere idle set with the weapons locked to a staff but UnlockWeapons on',
        function()
        gs:console('gs c set IdleMode Sphere')
        gs:console('gs c set Weapons Staff')
        gs:console('gs c toggle UnlockWeapons')
        gs:set_tp(300)
        jobby.low_mp(gs)
        assert.same(jobby.worn_by(idle, {main = 'Gozuki Mezuki', waist = 'Null Belt', sub = 'Enki Strap',
            ear1 = 'Cessance Earring'}), gs:worn())
    end)

    pending('has no grip over the Sphere idle set with the weapons locked to Naegling but UnlockWeapons on: '
        .. 'job_customize_idle_set in data/RDM.lua looks at the idle set\'s main, Terra\'s Staff, and with '
        .. 'UnlockWeapons on Sel lays the weapon set over the idle set after it, so the idle set asks for Enki Strap '
        .. 'beside Naegling, a one-handed sword, which the game refuses')

    pending('has the grip over the Normal idle set, which names no main, with the weapons locked to a staff but '
        .. 'UnlockWeapons on: job_customize_idle_set in data/RDM.lua looks at the idle set\'s main, and Sel lays the '
        .. 'weapon set over the idle set only after it, so the job file adds neither the grip nor sets.TPEat with '
        .. 'Gozuki Mezuki in hand')

    it('has no latent refresh set over it in the DT idle mode', function()
        gs:console('gs c set IdleMode DT')
        jobby.low_mp(gs)
        assert.same(jobby.worn_by(idle, {head = 'Null Masque'}), gs:worn())
    end)
end)

describe('RDM\'s idle set with Scholar, whose ability Sublimation is, as the sub job', function()
    local gs
    before_each(function()
        gs = boot({sub_job = 'SCH'})
    end)

    it('has sets.buff.Sublimation over it while Sublimation charges', function()
        gs:gain_buff('Sublimation: Activated')
        assert.same(jobby.worn_by(idle, {back = 'Null Shawl'}), gs:worn())
    end)

    it('has sets.buff.DTSublimation over the DT idle set while Sublimation charges', function()
        gs:console('gs c set IdleMode DT')
        gs:gain_buff('Sublimation: Activated')
        assert.same(jobby.worn_by(idle,
            {head = 'Null Masque', back = 'Null Shawl', ring1 = 'Karieyh Ring'}), gs:worn())
    end)
end)

describe('RDM\'s enspell', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is noted when its buff comes up, and forgotten when it ends', function()
        gs:gain_buff('Enfire')
        assert.equal('Enfire', gs.user.enspell)
        gs:lose_buff('Enfire')
        assert.equal('', gs.user.enspell)
    end)

    it('is the last one to come up', function()
        gs:gain_buff('Enfire')
        gs:gain_buff('Enthunder')
        assert.equal('Enthunder', gs.user.enspell)
    end)

    it('stays noted when another enspell ends', function()
        gs:gain_buff('Enfire')
        gs:gain_buff('Enthunder')
        gs:lose_buff('Enfire')
        assert.equal('Enthunder', gs.user.enspell)
    end)

    it('is not noted for another buff', function()
        gs:gain_buff('Haste')
        assert.equal('', gs.user.enspell)
    end)

    -- Sel runs job_setup again on a change of sub job, which finds the enspell up from the buffs it knows.
    it('is found among the buffs Jobby has when the job is set up again', function()
        gs:gain_buff('Enthunder')
        gs.user.enspell = ''
        gs.user.job_setup()
        assert.equal('Enthunder', gs.user.enspell)
    end)

    it('is forgotten when none of the buffs Jobby has is one', function()
        gs.user.enspell = 'Enfire'
        gs:gain_buff('Haste')
        gs.user.job_setup()
        assert.equal('', gs.user.enspell)
    end)

    it('puts the melee set of the Enspell group on, engaged', function()
        gs:engage()
        gs:gain_buff('Enfire')
        assert.same(jobby.worn_by(idle,
            {head = 'Volte Cap', body = 'Volte Jupon', legs = 'Volte Hose'}), gs:worn())
    end)

    it('puts the melee set of the Enspell2 group on for an enspell II, engaged', function()
        gs:engage()
        gs:gain_buff('Enfire II')
        assert.same(jobby.worn_by(idle,
            {head = 'Volte Cap', body = 'Volte Jupon', feet = 'Volte Boots'}), gs:worn())
    end)

    it('takes the group off again when the enspell ends', function()
        gs:engage()
        gs:gain_buff('Enfire')
        gs:lose_buff('Enfire')
        assert.same(jobby.worn_by(idle, {head = 'Volte Cap', body = 'Volte Jupon'}), gs:worn())
    end)
end)

describe('RDM\'s melee set with an enspell up and an Enspell weapon set', function()
    local function engaged(options)
        options = options or {}
        local gs = boot({items = options.items})
        gs:console('gs c set Weapons EnspellMelee')
        if options.offense then
            gs:console('gs c set OffenseMode ' .. options.offense)
        end
        if options.weather then
            gs:set_weather(options.weather)
        end
        if options.day then
            gs:set_day(options.day)
        end
        gs:engage()
        gs:gain_buff(options.enspell or 'Enfire')
        return gs:worn()
    end

    it('has the enspell element\'s set laid over it', function()
        assert.equal('Volte Bracers', engaged().hands)
    end)

    it('has the set of the element laid over it for another enspell', function()
        local worn = engaged({enspell = 'Enthunder'})
        assert.equal('Volte Bracers', worn.hands)
        assert.equal('Adamantite Armor', worn.body)
    end)

    it('has no element set when the gear file has none for the element', function()
        assert.equal('Nyame Gauntlets', engaged({enspell = 'Enblizzard'}).hands)
    end)

    it('has Orpheus\'s Sash laid over it', function()
        assert.equal("Orpheus's Sash", engaged().waist)
    end)

    it('has the element\'s obi laid over it on that element\'s day, without the sash', function()
        local worn = engaged({items = without(gear, {["Orpheus's Sash"] = true})})
        assert.equal('Karin Obi', worn.waist)
    end)

    it('has the element\'s obi laid over it in that element\'s weather', function()
        local worn = engaged({items = without(gear, {["Orpheus's Sash"] = true}), weather = 4, day = 1})
        assert.equal('Karin Obi', worn.waist)
    end)

    it('has Hachirin-no-Obi laid over it on that element\'s day, without the sash or the obi', function()
        local worn = engaged({items = without(gear, {["Orpheus's Sash"] = true, ['Karin Obi'] = true})})
        assert.equal('Hachirin-no-Obi', worn.waist)
    end)

    it('has Hachirin-no-Obi laid over it in that element\'s weather, without the sash or the obi', function()
        local worn = engaged({items = without(gear, {["Orpheus's Sash"] = true, ['Karin Obi'] = true}),
            weather = 4, day = 1})
        assert.equal('Hachirin-no-Obi', worn.waist)
    end)

    it('has Orpheus\'s Sash laid over it on another day with no weather, and no obi without the sash', function()
        local worn = engaged({weather = 0, day = 1})
        assert.equal("Orpheus's Sash", worn.waist)
        local plain = engaged({items = without(gear, {["Orpheus's Sash"] = true}), weather = 0, day = 1})
        assert.equal('Plat. Mog. Belt', plain.waist)
    end)

    it('has Zodiac Ring laid over it on the enspell element\'s day when the set leaves the ring slot alone', function()
        assert.equal('Zodiac Ring', engaged().right_ring)
    end)

    pending('has Zodiac Ring laid over it on the enspell element\'s day when the set names ring2: '
        .. 'job_customize_melee_set in data/RDM.lua equips the ring itself, and Sel equips the set it returns after, '
        .. 'so the set\'s ring2 takes the slot back')

    it('has no Zodiac Ring laid over it in an accuracy offense mode', function()
        assert.equal('Stikini Ring +1', engaged({offense = 'Acc'}).right_ring)
    end)

    it('has no Zodiac Ring laid over it on another day', function()
        assert.equal('Stikini Ring +1', engaged({day = 1}).right_ring)
    end)

    it('has none of it without an Enspell weapon set', function()
        local gs = boot()
        gs:console('gs c set Weapons Naegling')
        gs:engage()
        gs:gain_buff('Enfire')
        assert.equal('Nyame Gauntlets', gs:worn().hands)
        assert.equal('Plat. Mog. Belt', gs:worn().waist)
    end)

    pending('has Hachirin-no-Obi laid over it on that element\'s day in the weather of an element that neither helps '
        .. 'nor hinders it, without the sash or the obi: job_customize_melee_set in data/RDM.lua tests '
        .. 'data.elements.weak_to[world.weather_element] alone, where the day\'s check compares it with the '
        .. 'enspell\'s element, so any elemental weather counts against the enspell, and Enfire on Firesday in Winds '
        .. 'goes without it')

    pending('has the set of the lightning element laid over it for Enthunder II: data.elements.enspells_lookup in '
        .. 'libs/Sel-Mappings.lua gives Enthunder II the element Thunder, not Lightning, so sets.element.enspell.Lightning '
        .. 'and the day and weather checks never match it')
end)

describe('RDM\'s elemental commands', function()
    -- The actions the command sent, with their targets, and the session. options: sub_job, recasts (spell name to
    -- seconds) and setup, which runs just before the command.
    local function sent(mode, name, options)
        options = options or {}
        local gs = boot_ticking({sub_job = options.sub_job})
        gs:console('gs c set ElementalMode ' .. mode)
        for spell, seconds in pairs(options.recasts or {}) do
            gs.game:start_spell_recast(spell, seconds)
        end
        if options.setup then
            options.setup(gs)
        end
        gs:console('gs c elemental ' .. name)
        return gs:action_entries(), gs
    end

    it('enspell casts the enspell of the element on oneself', function()
        assert.same({{action = 'Enfire', target = 'Jobby'}}, (sent('Fire', 'enspell')))
        assert.same({{action = 'Enblizzard', target = 'Jobby'}}, (sent('Ice', 'enspell')))
    end)

    it('enspell2 casts the second enspell of the element', function()
        assert.same({{action = 'Enfire II', target = 'Jobby'}}, (sent('Fire', 'enspell2')))
    end)

    it('weather casts Phalanx II on oneself without Scholar as the sub job', function()
        assert.same({{action = 'Phalanx II', target = 'Jobby'}}, (sent('Light', 'weather me')))
    end)

    it('weather casts the element\'s storm with Scholar as the sub job', function()
        assert.same({{action = 'Aurorastorm', target = 'Jobby'}}, (sent('Light', 'weather me', {sub_job = 'SCH'})))
    end)

    it('weather casts Klimaform on oneself, with Scholar as the sub job, while the element\'s storm is up', function()
        local gs = boot_ticking({sub_job = 'SCH', buffs = {'Aurorastorm'}})
        gs:console('gs c set ElementalMode Light')
        gs:console('gs c elemental weather me')
        assert.same({'Klimaform'}, gs:actions())
    end)

    it('weather casts the storm again once Klimaform is up', function()
        local gs = boot_ticking({sub_job = 'SCH', buffs = {'Aurorastorm', 'Klimaform'}})
        gs:console('gs c set ElementalMode Light')
        gs:console('gs c elemental weather me')
        assert.same({'Aurorastorm'}, gs:actions())
    end)

    it('nuke casts the highest tier Jobby can cast, Fire V, at the target', function()
        assert.same({{action = 'Fire V', target = 'Apex Toad'}}, (sent('Fire', 'nuke')))
    end)

    it('nuke casts at Jobby when given me', function()
        assert.same({{action = 'Fire V', target = 'Jobby'}}, (sent('Fire', 'nuke me')))
    end)

    it('nuke goes down a tier when Jobby hasn\'t the MP for the higher', function()
        assert.same({{action = 'Fire IV', target = 'Apex Toad'}}, (sent('Fire', 'nuke', {setup = function(gs)
            gs.game.player.vitals.mp = 200
        end})))
    end)

    it('nuke says so when Jobby hasn\'t the MP for any tier', function()
        local actions, gs = sent('Fire', 'nuke', {setup = function(gs)
            gs.game.player.vitals.mp = 5
            gs:chat()
        end})
        assert.same({}, actions)
        assert.same({'Abort: All Fire nukes on cooldown or or not enough MP.'}, gs:chat())
    end)

    pending('nuke casts Fire V with just its cost in MP, 228: handle_job_elemental in data/RDM.lua takes a tier only '
        .. 'with more MP than it costs (actual_cost < player.mp), so it goes down to Fire IV')

    it('nuke casts nothing more once the spell is done', function()
        local _, gs = sent('Fire', 'nuke')
        gs:finish_action()
        gs:play(10)
        assert.same({}, gs:actions())
    end)

    it('nuke goes down a tier when that one is on recast', function()
        assert.same({{action = 'Fire IV', target = 'Apex Toad'}}, (sent('Fire', 'nuke', {recasts = {['Fire V'] = 10}})))
    end)

    it('smallnuke casts the second tier', function()
        assert.same({{action = 'Fire II', target = 'Apex Toad'}}, (sent('Fire', 'smallnuke')))
    end)

    it('nuke casts Banish II in the Light mode', function()
        assert.same({{action = 'Banish II', target = 'Apex Toad'}}, (sent('Light', 'nuke')))
    end)

    it('nuke goes down to Banish when Banish II is on recast in the Light mode', function()
        assert.same({{action = 'Banish', target = 'Apex Toad'}},
            (sent('Light', 'nuke', {recasts = {['Banish II'] = 10}})))
    end)

    it('nuke says so when both Banishes are on recast in the Light mode', function()
        local actions, gs = sent('Light', 'nuke', {recasts = {['Banish'] = 10, ['Banish II'] = 10}, setup = function(gs)
            gs:chat()
        end})
        assert.same({}, actions)
        assert.same({'Abort: Banishes on cooldown or not enough MP.'}, gs:chat())
    end)

    it('hands a command it doesn\'t know on to Sel\'s elemental commands', function()
        assert.same({{action = 'Barblizzard', target = 'Jobby'}}, (sent('Fire', 'barelement')))
    end)

    it('says so when every tier is on recast', function()
        local recasts = {}
        for _, spell in ipairs({'Fire V', 'Fire IV', 'Fire III', 'Fire II', 'Fire'}) do
            recasts[spell] = 10
        end
        local actions, gs = sent('Fire', 'nuke', {recasts = recasts, setup = function(gs)
            gs:chat()
        end})
        assert.same({}, actions)
        assert.same({'Abort: All Fire nukes on cooldown or or not enough MP.'}, gs:chat())
    end)
end)

describe('RDM\'s Auto Arts', function()
    -- Every buff Auto Buff Mode keeps up is up, so that only the arts are left for the tick to use.
    local buffed = {'Refresh', 'Haste', 'Reraise', 'Aurorastorm'}

    local function with_buffed(...)
        local buffs = {...}
        for _, buff in ipairs(buffed) do
            buffs[#buffs + 1] = buff
        end
        return buffs
    end

    -- Jobby with Auto Arts on, and Auto Buff Mode on unless auto_buff is false.
    local function arts(options, auto_buff)
        local gs = boot_ticking(options)
        gs:console('gs c set AutoArts true')
        if auto_buff ~= false then
            gs:console('gs c set AutoBuffMode Auto')
        end
        return gs
    end

    it('uses Composure with Auto Arts on and Auto Buff Mode on', function()
        local gs = arts({buffs = buffed})
        gs:play_until_action()
        assert.same({'Composure'}, gs:actions())
    end)

    it('uses Composure in a fight with Auto Buff Mode off', function()
        local gs = arts({}, false)
        gs:monster_hits()
        gs:play_until_action()
        assert.same({'Composure'}, gs:actions())
    end)

    it('uses nothing out of a fight with Auto Buff Mode off', function()
        local gs = arts({}, false)
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses Composure ahead of the spells of gs c buffup', function()
        local gs = arts({}, false)
        gs:console('gs c buffup')
        gs:play_until_action()
        assert.same({'Composure'}, gs:actions())
    end)

    it('uses no Composure with Composure up', function()
        local gs = arts({buffs = with_buffed('Composure')})
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Composure while it is on recast', function()
        local gs = arts({buffs = buffed})
        gs.game:start_ability_recast('Composure', 60)
        gs:chat()
        gs:play(3)
        assert.same({}, gs:actions())
        assert.same({}, gs:chat())
    end)

    it('uses Light Arts after Composure with Scholar as the sub job', function()
        local gs = arts({sub_job = 'SCH', buffs = with_buffed('Composure')})
        gs:play_until_action()
        assert.same({'Light Arts'}, gs:actions())
    end)

    it('uses no Light Arts with Light Arts up', function()
        local gs = arts({sub_job = 'SCH', buffs = with_buffed('Composure', 'Light Arts')})
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Light Arts with Dark Arts up', function()
        local gs = arts({sub_job = 'SCH', buffs = with_buffed('Composure', 'Dark Arts')})
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Light Arts while the sub job\'s abilities are restricted', function()
        local gs = arts({sub_job = 'SCH', buffs = with_buffed('Composure', 'SJ Restriction')})
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses nothing in town', function()
        local gs = arts({zone = 230})
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Composure with Auto Arts off, under Auto Buff Mode', function()
        local gs = boot_ticking({buffs = buffed})
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Composure with Auto Arts off, under gs c buffup, which goes straight to its spells', function()
        local gs = boot_ticking({buffs = {'Haste'}})
        gs:console('gs c buffup')
        gs:play_until_action()
        assert.same({'Refresh III'}, gs:actions())
    end)
end)

describe('RDM\'s Auto Buff Mode', function()
    local function buffing(mode, options)
        local gs = boot_ticking(options)
        gs:console('gs c set AutoBuffMode ' .. mode)
        return gs
    end

    it('AutoMelee starts with Phalanx II', function()
        local gs = buffing('AutoMelee')
        gs:play_until_action()
        assert.same({'Phalanx II'}, gs:actions())
    end)

    it('AutoMelee goes on to Temper II with Phalanx, Haste and Refresh up', function()
        local gs = buffing('AutoMelee')
        for _, buff in ipairs({'Phalanx', 'Haste', 'Refresh'}) do
            gs:gain_buff(buff)
        end
        gs:play_until_action()
        assert.same({'Temper II'}, gs:actions())
    end)

    it('AutoMage starts with Phalanx II too, and goes on to Gain-INT', function()
        local gs = buffing('AutoMage')
        gs:play_until_action()
        assert.same({'Phalanx II'}, gs:actions())
        gs:finish_action()
        for _, buff in ipairs({'Phalanx', 'Haste', 'Refresh'}) do
            gs:gain_buff(buff)
        end
        gs:play_until_action()
        assert.same({'Gain-INT'}, gs:actions())
    end)

    it('has the modes Off, Auto, AutoMelee and AutoMage', function()
        local gs = boot()
        gs:console('gs c cycle AutoBuffMode')
        assert.equal('Auto', gs.user.state.AutoBuffMode.value)
        gs:console('gs c cycle AutoBuffMode')
        assert.equal('AutoMelee', gs.user.state.AutoBuffMode.value)
        gs:console('gs c cycle AutoBuffMode')
        assert.equal('AutoMage', gs.user.state.AutoBuffMode.value)
        gs:console('gs c cycle AutoBuffMode')
        assert.equal('Off', gs.user.state.AutoBuffMode.value)
    end)
end)

describe('RDM\'s buff up', function()
    it('is told by name which list to cast: Odin starts with Refresh III', function()
        local gs = boot_ticking()
        gs:console('gs c buffup Odin')
        gs:play_until_action()
        assert.same({'Refresh III'}, gs:actions())
    end)
end)

describe('RDM\'s status line', function()
    it('says the casting and idle modes, as a caster\'s does', function()
        local gs = boot()
        gs:console('gs c update user')
        assert.same({'Melee, Casting [Normal], Idle [Normal]'}, gs:chat())
    end)
end)

describe('RDM\'s buff states', function()
    it('follow the buffs as they come and go', function()
        local gs = boot()
        gs:gain_buff('Saboteur')
        assert.is_true(gs.user.state.Buff.Saboteur)
        gs:lose_buff('Saboteur')
        assert.is_false(gs.user.state.Buff.Saboteur)
    end)

    it('start with Buff Weapons Mode Never and Murgleis Mode Always', function()
        local gs = boot()
        assert.equal('Never', gs.user.state.BuffWeaponsMode.value)
        assert.equal('Always', gs.user.state.MurgleisMode.value)
    end)
end)
