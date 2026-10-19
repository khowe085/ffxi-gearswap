local jobby = require('jobby')

local pieces = {'Volte Cap', 'Volte Jupon', 'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Null Masque',
    'Adamantite Armor', 'Plumb Boots', "Orunmila's Torque", 'Weike Torque', 'Kaykaus Mitra +1', 'Sortiarius Earring',
    'Beatific Earring', 'Choleric Earring', 'Pensee Earring', 'Lunette Ring', 'Pernicious Ring', 'Gelatinous Ring',
    'Cacoethic Ring', 'Petrov Ring', 'Fortified Ring', 'Vertigo Ring', 'Dhanurveda Ring', 'Wanion Belt',
    'Prodigious Mantle', "Bunzi's Rod", 'Gozuki Mezuki'}

-- Jobby as a scholar with the idle set on. The options are those of a boot (sub_job, tp, buffs, spells) and
-- these besides:
--   mp         the MP of the 1000 he has
--   friend     true for a party member, Friend, near him
--   stranger   the squared distance of another player, Stranger, who is not in the party, true for 4 yalms
local function boot(options)
    options = options or {}
    local gs = jobby.boot('SCH', pieces, {sub_job = options.sub_job or 'RDM', tp = options.tp, buffs = options.buffs,
        spells = options.spells})
    if options.mp then
        gs.game.player.vitals.mp = options.mp
        gs.game.player.vitals.mpp = math.floor(options.mp / 10)
    end
    if options.friend then
        gs.game:add_party_member({name = 'Friend'})
    end
    if options.stranger then
        gs.game:add_party_member({name = 'Stranger', in_party = false,
            distance = type(options.stranger) == 'number' and options.stranger or 16})
    end
    gs:console('gs c update')
    gs:traffic()
    gs.game.chat_log, gs.game.commands, gs.game.typed = {}, {}, {}
    return gs
end

local function sets_of(gs)
    return gs.user.sets
end

local function said(gs, text)
    for _, entry in ipairs(gs.game.chat_log) do
        if entry.text:find(text, 1, true) then
            return true
        end
    end
    return false
end

local function ran(gs, start)
    local commands = {}
    for _, command in ipairs(gs.game.commands) do
        if command:sub(1, #start) == start then
            commands[#commands + 1] = command
        end
    end
    return commands
end

local function actions(gs)
    local names = {}
    for _, entry in ipairs(gs:traffic()) do
        names[#names + 1] = entry.action
    end
    return names
end

-- The actions sent, each as its name and its target's.
local function targeted(gs)
    local sent = {}
    for _, entry in ipairs(gs:traffic()) do
        if entry.action then
            sent[#sent + 1] = entry.action .. ' ' .. entry.target
        end
    end
    return sent
end

-- The actions the tick sent in its first moments (it starts five seconds after the file loads).
local function first_actions(gs)
    gs:play(5.3)
    return actions(gs)
end

-- What is worn once the spell's precast and midcast sets are on: the fast cast set, then the sets named over it.
local function cast(gs, line)
    gs:type(line)
    return gs:worn()
end

local function fast_cast(gs, ...)
    return jobby.worn_by(jobby.layer(sets_of(gs).precast.FC, ...))
end

describe('a cure by a scholar', function()
    local function cure(gs)
        return cast(gs, '/ma "Cure III" <me>')
    end

    it('wears sets.midcast.Cure', function()
        local gs = boot()
        assert.same(fast_cast(gs, sets_of(gs).midcast.Cure), cure(gs))
    end)

    it('wears sets.midcast.LightWeatherCure in light weather', function()
        local gs = boot()
        jobby.set_world(gs, {weather = 16})
        assert.same(fast_cast(gs, sets_of(gs).midcast.LightWeatherCure), cure(gs))
    end)

    it('wears sets.midcast.LightDayCure on a Lightsday', function()
        local gs = boot()
        jobby.set_world(gs, {day = 6})
        assert.same(fast_cast(gs, sets_of(gs).midcast.LightDayCure), cure(gs))
    end)

    it('wears the weather\'s set ahead of the day\'s', function()
        local gs = boot()
        jobby.set_world(gs, {day = 6, weather = 16})
        assert.same(fast_cast(gs, sets_of(gs).midcast.LightWeatherCure), cure(gs))
    end)

    describe('with a weapon set locking the weapons', function()
        local function locked()
            local gs = boot()
            gs:console('gs c set Weapons Staff')
            gs:traffic()
            return gs
        end

        it('wears sets.midcast.MeleeCure', function()
            local gs = locked()
            assert.same(fast_cast(gs, sets_of(gs).midcast.MeleeCure, {main = "Bunzi's Rod"}), cure(gs))
        end)

        it('wears sets.midcast.MeleeLightWeatherCure in light weather', function()
            local gs = locked()
            jobby.set_world(gs, {weather = 16})
            assert.same(fast_cast(gs, sets_of(gs).midcast.MeleeLightWeatherCure, {main = "Bunzi's Rod"}), cure(gs))
        end)

        it('wears sets.midcast.MeleeLightDayCure on a Lightsday', function()
            local gs = locked()
            jobby.set_world(gs, {day = 6})
            assert.same(fast_cast(gs, sets_of(gs).midcast.MeleeLightDayCure, {main = "Bunzi's Rod"}), cure(gs))
        end)

        it('wears sets.midcast.Cure again with UnlockWeapons on', function()
            local gs = locked()
            gs:console('gs c set UnlockWeapons true')
            gs:traffic()
            local worn = cure(gs)
            assert.equal('Gelatinous Ring', worn.left_ring)
        end)
    end)
end)

describe('a Curaga by a scholar on a player outside the party', function()
    it('is turned to an Accession Cure under Light Arts: Accession first, the Cure a second later', function()
        local gs = boot({sub_job = 'WHM', stranger = true, buffs = {'Light Arts'}})
        gs:type('/ma "Curaga" Stranger')
        assert.same({'Accession Jobby'}, targeted(gs))
        gs:gain_buff('Accession')
        gs:traffic()
        gs:advance(5)
        assert.same({'Cure Stranger'}, targeted(gs))
    end)

    it('is turned to the Cure at once with Accession up', function()
        local gs = boot({sub_job = 'WHM', stranger = true, buffs = {'Light Arts', 'Accession'}})
        gs:type('/ma "Curaga" Stranger')
        assert.same({'Cure Stranger'}, targeted(gs))
    end)

    it('is turned to the Cure under an Addendum: White as well', function()
        local gs = boot({sub_job = 'WHM', stranger = true, buffs = {'Addendum: White', 'Accession'}})
        gs:type('/ma "Curaga" Stranger')
        assert.same({'Cure Stranger'}, targeted(gs))
    end)

    it('is refused without an art, saying why', function()
        local gs = boot({sub_job = 'WHM', stranger = true})
        gs:type('/ma "Curaga" Stranger')
        assert.same({}, actions(gs))
        assert.is_true(said(gs, "Error: You can't Curaga outside of party."))
    end)

    it('is refused with no stratagem to spend, saying why', function()
        local gs = boot({sub_job = 'WHM', stranger = true, buffs = {'Light Arts'}})
        jobby.set_recasts(gs, {abilities = {[231] = 165}})
        gs:type('/ma "Curaga" Stranger')
        assert.same({}, actions(gs))
        assert.is_true(said(gs, 'Error: Not enough Stratagems to convert Curaga to Accesion Cure.'))
    end)

    it('goes out as it is on a member of the party', function()
        local gs = boot({sub_job = 'WHM', friend = true})
        gs:type('/ma "Curaga" Friend')
        assert.same({'Curaga Friend'}, targeted(gs))
    end)
end)

describe('a cure on a player too far to heal', function()
    it('is refused beyond 21 yalms, saying so', function()
        local gs = boot({friend = true})
        gs.game.others[1].distance = 22 ^ 2
        gs:type('/ma "Cure III" Friend')
        assert.same({}, actions(gs))
        assert.is_true(said(gs, 'Target out of range, too far to heal!'))
    end)

    it('goes out at 21 yalms', function()
        local gs = boot({friend = true})
        gs.game.others[1].distance = 21 ^ 2
        gs:type('/ma "Cure III" Friend')
        assert.same({'Cure III Friend'}, targeted(gs))
    end)
end)

describe('the set of a spell by its kind', function()
    it('is sets.midcast.LowTierNuke for a low tier nuke: Stone', function()
        local gs = boot()
        assert.same(fast_cast(gs, sets_of(gs).midcast.LowTierNuke), cast(gs, '/ma "Stone" <t>'))
    end)

    it('is sets.midcast.LowTierNuke for Fire II', function()
        local gs = boot()
        assert.same(fast_cast(gs, sets_of(gs).midcast.LowTierNuke), cast(gs, '/ma "Fire II" <t>'))
    end)

    it('is sets.midcast.HighTierNuke for a high tier nuke: Fire III', function()
        local gs = boot()
        assert.same(fast_cast(gs, sets_of(gs).midcast.HighTierNuke), cast(gs, '/ma "Fire III" <t>'))
    end)

    it('is sets.midcast.Helix for a helix, which is no nuke of either tier', function()
        local gs = boot()
        assert.same(fast_cast(gs, sets_of(gs).midcast.Helix), cast(gs, '/ma "Pyrohelix" <t>'))
    end)

    it('is sets.midcast["Enfeebling Magic"] for Dispel', function()
        local gs = boot()
        assert.same(fast_cast(gs, sets_of(gs).midcast['Enfeebling Magic']), cast(gs, '/ma "Dispel" <t>'))
    end)
end)

describe('the obi entries a scholar\'s precast fills', function()
    local function default_after(line)
        local gs = boot()
        gs:type(line)
        return gs.user.gear.default
    end

    it('are the cure ones for a cure', function()
        local default = default_after('/ma "Cure III" <me>')
        assert.equal('Prodigious Mantle', default.obi_back)
        assert.equal('Wanion Belt', default.obi_waist)
    end)

    it('are the low nuke ones for a low tier nuke', function()
        assert.equal('Plat. Mog. Belt', default_after('/ma "Stone" <t>').obi_waist)
    end)

    it('are the low nuke ones for a helix', function()
        assert.equal('Plat. Mog. Belt', default_after('/ma "Pyrohelix" <t>').obi_waist)
    end)

    it('are the high nuke ones for a high tier nuke', function()
        assert.equal('Hachirin-no-Obi', default_after('/ma "Fire III" <t>').obi_waist)
    end)

    it('are left as they were for a spell that is neither', function()
        assert.is_nil(default_after('/ma "Dispel" <t>').obi_waist)
    end)
end)

describe('the casting mode of a scholar', function()
    it('wears sets.precast.FC.Proc ahead of a spell in the Proc casting mode', function()
        local gs = boot()
        gs:console('gs c set CastingMode Proc')
        gs:traffic()
        gs:type('/ma "Stone" <t>')
        assert.same(jobby.request(sets_of(gs).precast.FC.Proc), gs:traffic()[1].equip)
    end)

    it('wears sets.precast.FC.OccultAcumen ahead of a spell in the OccultAcumen casting mode', function()
        local gs = boot()
        gs:console('gs c set CastingMode OccultAcumen')
        gs:traffic()
        gs:type('/ma "Stone" <t>')
        assert.same(jobby.request(sets_of(gs).precast.FC.OccultAcumen), gs:traffic()[1].equip)
    end)

    it('wears sets.precast.FC otherwise', function()
        local gs = boot()
        gs:type('/ma "Stone" <t>')
        assert.same(jobby.request(sets_of(gs).precast.FC), gs:traffic()[1].equip)
    end)
end)

describe('a spell cast under an art', function()
    local function with_art(buff, line)
        local gs = boot({buffs = {buff}})
        gs:type(line)
        return gs, gs:traffic()[1].equip
    end

    it('wears sets.precast.FC.Arts[the spell\'s name] over the fast cast set', function()
        local gs, equip = with_art('Dark Arts', '/ma "Dispel" <t>')
        assert.same(jobby.request(sets_of(gs).precast.FC, sets_of(gs).precast.FC.Arts.Dispel), equip)
    end)

    it('wears sets.precast.FC.Arts[the spell\'s map] when it has none by name', function()
        local gs, equip = with_art('Light Arts', '/ma "Cure III" <me>')
        assert.same(jobby.request(sets_of(gs).precast.FC, sets_of(gs).precast.FC.Arts.Cure), equip)
    end)

    it('wears sets.precast.FC.Arts[the spell\'s skill] when it has none by map', function()
        local gs, equip = with_art('Light Arts', '/ma "Regen" <me>')
        assert.same(jobby.request(sets_of(gs).precast.FC, sets_of(gs).precast.FC.Arts['Enhancing Magic']), equip)
    end)

    it('wears sets.precast.FC.Arts itself when it has none of those', function()
        local gs, equip = with_art('Dark Arts', '/ma "Stone" <t>')
        assert.same(jobby.request(sets_of(gs).precast.FC, sets_of(gs).precast.FC.Arts), equip)
    end)

    it('takes an addendum for its art', function()
        local gs, equip = with_art('Addendum: White', '/ma "Cure III" <me>')
        assert.same(jobby.request(sets_of(gs).precast.FC, sets_of(gs).precast.FC.Arts.Cure), equip)
    end)

    it('takes no set of the arts for a spell of the other art\'s magic', function()
        local gs, equip = with_art('Light Arts', '/ma "Stone" <t>')
        assert.same(jobby.request(sets_of(gs).precast.FC), equip)
    end)

    it('takes no set of the arts without an art', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        assert.same(jobby.request(sets_of(gs).precast.FC), gs:traffic()[1].equip)
    end)
end)

describe('the stratagems laid over a spell', function()
    local function with(buffs, line, setup)
        local gs = boot({buffs = buffs})
        if setup then
            setup(gs)
        end
        return gs, cast(gs, line)
    end

    it('wear sets.buff.Perpetuance over an enhancing spell', function()
        local gs, worn = with({'Perpetuance'}, '/ma "Regen" <me>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.Regen, sets_of(gs).buff.Perpetuance), worn)
    end)

    it('wear no sets.buff.Perpetuance over a spell that is not enhancing', function()
        local gs, worn = with({'Perpetuance'}, '/ma "Cure III" <me>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.Cure), worn)
    end)

    it('wear sets.buff.Rapture over a cure', function()
        local gs, worn = with({'Rapture'}, '/ma "Cure III" <me>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.Cure, sets_of(gs).buff.Rapture), worn)
    end)

    it('wear sets.buff.Penury over a cure', function()
        local gs, worn = with({'Penury'}, '/ma "Cure III" <me>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.Cure, sets_of(gs).buff.Penury), worn)
    end)

    it('wear sets.buff.Penury over a cure ahead of Parsimony', function()
        local gs, worn = with({'Penury', 'Parsimony'}, '/ma "Cure III" <me>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.Cure, sets_of(gs).buff.Penury), worn)
    end)

    it('wear sets.buff.Parsimony over a nuke', function()
        local gs, worn = with({'Parsimony'}, '/ma "Stone" <t>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.LowTierNuke, sets_of(gs).buff.Parsimony), worn)
    end)

    it('wear no sets.buff.Parsimony over a spell that is no nuke', function()
        local gs, worn = with({'Parsimony'}, '/ma "Dispel" <t>')
        assert.same(fast_cast(gs, sets_of(gs).midcast['Enfeebling Magic']), worn)
    end)

    it('wear sets.buff.Focalization over black magic', function()
        local gs, worn = with({'Focalization'}, '/ma "Stone" <t>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.LowTierNuke, sets_of(gs).buff.Focalization), worn)
    end)

    it('wear no sets.buff.Focalization over white magic', function()
        local gs, worn = with({'Focalization'}, '/ma "Cure III" <me>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.Cure), worn)
    end)

    it('wear sets.buff.Celerity over a spell of the weather\'s element', function()
        local gs, worn = with({'Celerity'}, '/ma "Cure III" <me>', function(gs)
            jobby.set_world(gs, {weather = 16})
        end)
        assert.same(fast_cast(gs, sets_of(gs).midcast.LightWeatherCure, sets_of(gs).buff.Celerity), worn)
    end)

    it('wear sets.buff.Alacrity over a spell of the weather\'s element', function()
        local gs, worn = with({'Alacrity'}, '/ma "Cure III" <me>', function(gs)
            jobby.set_world(gs, {weather = 16})
        end)
        assert.same(fast_cast(gs, sets_of(gs).midcast.LightWeatherCure, sets_of(gs).buff.Alacrity), worn)
    end)

    it('wear no sets.buff.Celerity over a spell of another element', function()
        local gs, worn = with({'Celerity'}, '/ma "Cure III" <me>', function(gs)
            jobby.set_world(gs, {weather = 6})
        end)
        assert.same(fast_cast(gs, sets_of(gs).midcast.Cure), worn)
    end)

    it('wear sets.buff.Ebullience over a nuke', function()
        local gs, worn = with({'Ebullience'}, '/ma "Stone" <t>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.LowTierNuke, sets_of(gs).buff.Ebullience), worn)
    end)

    it('wear sets.buff.Immanence over a nuke', function()
        local gs, worn = with({'Immanence'}, '/ma "Stone" <t>')
        assert.same(fast_cast(gs, sets_of(gs).midcast.LowTierNuke, sets_of(gs).buff.Immanence), worn)
    end)

    it('wear sets.buff.Klimaform over a nuke of the weather\'s element', function()
        local gs, worn = with({'Klimaform'}, '/ma "Stone" <t>', function(gs)
            jobby.set_world(gs, {weather = 8})
        end)
        assert.same(fast_cast(gs, sets_of(gs).midcast.LowTierNuke, sets_of(gs).buff.Klimaform), worn)
    end)

    it('wear no sets.buff.Klimaform over a nuke of another element', function()
        local gs, worn = with({'Klimaform'}, '/ma "Stone" <t>', function(gs)
            jobby.set_world(gs, {weather = 6})
        end)
        assert.same(fast_cast(gs, sets_of(gs).midcast.LowTierNuke), worn)
    end)

    it('wear no Ebullience, Immanence or Klimaform set in the Proc casting mode', function()
        local gs = boot({buffs = {'Ebullience', 'Immanence'}})
        gs:console('gs c set CastingMode Proc')
        gs:traffic()
        local worn = cast(gs, '/ma "Stone" <t>')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).precast.FC.Proc, sets_of(gs).midcast.LowTierNuke)), worn)
    end)

    it('wear sets.buff["Light Arts"] over an enfeebling spell under Light Arts', function()
        local gs, worn = with({'Light Arts'}, '/ma "Dispel" <t>')
        assert.same(fast_cast(gs, sets_of(gs).midcast['Enfeebling Magic'], sets_of(gs).buff['Light Arts']), worn)
    end)

    it('wear sets.buff["Dark Arts"] over an enfeebling spell under Dark Arts', function()
        local gs, worn = with({'Dark Arts'}, '/ma "Dispel" <t>')
        assert.same(fast_cast(gs, sets_of(gs).precast.FC.Arts.Dispel, sets_of(gs).midcast['Enfeebling Magic'],
            sets_of(gs).buff['Dark Arts']), worn)
    end)

    it('wear sets.buff["Dark Arts"] over an enfeebling spell under Addendum: Black', function()
        local gs, worn = with({'Addendum: Black'}, '/ma "Dispel" <t>')
        assert.equal('Volte Hose', worn.legs)
    end)
end)

describe('a stratagem used', function()
    it('is followed a second later by the charges left, which the recast says', function()
        local gs = boot({buffs = {'Light Arts'}})
        jobby.set_recasts(gs, {abilities = {[231] = 66}})
        gs:type('/ja "Penury" <me>')
        gs:finish_action()
        gs:advance(1)
        assert.is_true(said(gs, '~~~Current Stratagem Charges Available: [3]~~~'))
    end)

    it('is followed by it not before that second is over', function()
        local gs = boot({buffs = {'Light Arts'}})
        gs:type('/ja "Penury" <me>')
        gs:finish_action()
        gs:advance(.9)
        assert.is_false(said(gs, 'Current Stratagem Charges Available'))
    end)

    it('is not followed by the charges when it is an ability of another kind', function()
        local gs = boot()
        gs:type('/ja "Light Arts" <me>')
        gs:finish_action()
        gs:advance(2)
        assert.is_false(said(gs, 'Current Stratagem Charges Available'))
    end)

    it('is counted by gs c showcharge: five with none on recast, at level 99 with the job points', function()
        local gs = boot()
        gs:console('gs c showcharge')
        assert.is_true(said(gs, '~~~Current Stratagem Charges Available: [5]~~~'))
    end)

    it('is counted by gs c showcharge: a charge back for each 33 seconds of the recast', function()
        local gs = boot()
        jobby.set_recasts(gs, {abilities = {[231] = 99}})
        gs:console('gs c showcharge')
        assert.is_true(said(gs, '~~~Current Stratagem Charges Available: [2]~~~'))
    end)

    it('is counted with three charges at most by a scholar sub job at level 50 or more', function()
        local gs = jobby.boot('BLU', {}, {sub_job = 'SCH', sub_job_level = 60})
        gs:console('gs c update')
        assert.equal(3, gs.user.get_current_stratagem_count())
    end)
end)

describe('a sleep spell cast by a scholar', function()
    it('starts a timer of a minute for Sleep, with the target\'s name', function()
        local gs = boot()
        gs:type('/ma "Sleep" <t>')
        gs:finish_action()
        assert.same({'timers c "Sleep [Apex Toad]" 60 down spells/00220.png'}, ran(gs, 'timers'))
    end)

    it('starts a timer of a minute and a half for Sleep II', function()
        local gs = boot()
        gs:type('/ma "Sleep II" <t>')
        gs:finish_action()
        assert.same({'timers c "Sleep II [Apex Toad]" 90 down spells/00220.png'}, ran(gs, 'timers'))
    end)

    it('starts no timer with the custom timers state off', function()
        local gs = boot()
        gs:console('gs c toggle UseCustomTimers')
        gs:type('/ma "Sleep" <t>')
        gs:finish_action()
        assert.same({}, ran(gs, 'timers'))
    end)

    it('starts no timer for a spell that is not a sleep', function()
        local gs = boot()
        gs:type('/ma "Stone" <t>')
        gs:finish_action()
        assert.same({}, ran(gs, 'timers'))
    end)

    it('starts no timer for a sleep that is interrupted', function()
        local gs = boot()
        gs:type('/ma "Sleep" <t>')
        gs:interrupt_action()
        assert.same({}, ran(gs, 'timers'))
    end)
end)

describe('the idle set of a scholar', function()
    local function low_mp(gs)
        gs.game.player.vitals.mpp = 40
        gs.game.player.vitals.mp = 400
        gs:console('gs c update')
    end

    it('wears sets.latent_refresh under half MP', function()
        local gs = boot()
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).latent_refresh)), gs:worn())
    end)

    it('wears no sets.latent_refresh above half MP', function()
        local gs = boot()
        assert.same(jobby.worn_by({}), gs:worn())
    end)

    it('wears sets.latent_refresh_grip too with a staff in the idle set and the weapons free', function()
        local gs = boot()
        sets_of(gs).idle.main = 'Gozuki Mezuki'
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).latent_refresh, sets_of(gs).latent_refresh_grip,
            {main = 'Gozuki Mezuki'})), gs:worn())
    end)

    it('wears no sets.latent_refresh_grip with a weapon set locking the weapons', function()
        local gs = boot()
        sets_of(gs).idle.main = 'Gozuki Mezuki'
        gs:console('gs c set Weapons Staff')
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).latent_refresh, {main = "Bunzi's Rod"})), gs:worn())
    end)

    it('wears no sets.latent_refresh in the DT idle mode', function()
        local gs = boot()
        gs:console('gs c set IdleMode DT')
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.DT)), gs:worn())
    end)

    it('wears sets.buff.Sublimation while Sublimation is charging', function()
        local gs = boot({buffs = {'Sublimation: Activated'}})
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).buff.Sublimation)), gs:worn())
    end)

    it('wears sets.buff.DTSublimation while it is, in the DT idle mode', function()
        local gs = boot({buffs = {'Sublimation: Activated'}})
        gs:console('gs c set IdleMode DT')
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).idle.DT, sets_of(gs).buff.DTSublimation)), gs:worn())
    end)

    it('wears the Sublimation set and no sets.latent_refresh under half MP while Sublimation charges', function()
        local gs = boot({buffs = {'Sublimation: Activated'}})
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).buff.Sublimation)), gs:worn())
    end)

    it('wears the Sublimation set no more once it is done', function()
        local gs = boot({buffs = {'Sublimation: Activated'}})
        gs:lose_buff('Sublimation: Activated')
        gs:console('gs c update')
        assert.same(jobby.worn_by({}), gs:worn())
    end)

    it('wears sets.TPEat over the latent refresh set under half MP with some TP and a main weapon in the idle set', function()
        local gs = boot({tp = 100})
        sets_of(gs).idle.main = "Bunzi's Rod"
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).latent_refresh, sets_of(gs).TPEat, {main = "Bunzi's Rod"})),
            gs:worn())
    end)

    it('wears no sets.TPEat with no TP to spare', function()
        local gs = boot({tp = 10})
        sets_of(gs).idle.main = "Bunzi's Rod"
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.layer(sets_of(gs).latent_refresh, {main = "Bunzi's Rod"})), gs:worn())
    end)
end)

describe('gs c scholar', function()
    local function scholar(buffs, command)
        local gs = boot({buffs = buffs})
        gs:console('gs c scholar ' .. command)
        return gs, actions(gs)
    end

    local cases = {
        -- buffs, command, the ability used
        {{}, 'light', 'Light Arts'},
        {{'Light Arts'}, 'light', 'Addendum: White'},
        {{'Addendum: White'}, 'light', 'Accession'},
        {{}, 'dark', 'Dark Arts'},
        {{'Dark Arts'}, 'dark', 'Addendum: Black'},
        {{'Addendum: Black'}, 'dark', 'Manifestation'},
        {{}, 'buff', 'Light Arts'},
        {{'Light Arts'}, 'cost', 'Penury'},
        {{'Light Arts'}, 'speed', 'Celerity'},
        {{'Light Arts'}, 'aoe', 'Accession'},
        {{'Light Arts'}, 'power', 'Rapture'},
        {{'Light Arts'}, 'duration', 'Perpetuance'},
        {{'Light Arts'}, 'accuracy', 'Altruism'},
        {{'Light Arts'}, 'enmity', 'Tranquility'},
        {{'Light Arts'}, 'addendum', 'Addendum: White'},
        {{'Addendum: White'}, 'cost', 'Penury'},
        {{'Dark Arts'}, 'cost', 'Parsimony'},
        {{'Dark Arts'}, 'speed', 'Alacrity'},
        {{'Dark Arts'}, 'aoe', 'Manifestation'},
        {{'Dark Arts'}, 'power', 'Ebullience'},
        {{'Dark Arts'}, 'accuracy', 'Focalization'},
        {{'Dark Arts'}, 'enmity', 'Equanimity'},
        {{'Dark Arts'}, 'skillchain', 'Immanence'},
        {{'Dark Arts'}, 'addendum', 'Addendum: Black'},
        {{'Addendum: Black'}, 'power', 'Ebullience'},
    }

    for _, case in ipairs(cases) do
        local buffs, command, ability = unpack(case)
        local art = buffs[1] or 'no art'
        it(('uses %s for %s under %s'):format(ability, command, art), function()
            local gs, used = scholar(buffs, command)
            assert.same({ability}, used)
        end)
    end

    it('says so when no art is up for a stratagem', function()
        local gs, used = scholar({}, 'cost')
        assert.same({}, used)
        assert.is_true(said(gs, 'No arts has been activated yet.'))
    end)

    it('says so for a stratagem Light Arts lacks', function()
        local gs, used = scholar({'Light Arts'}, 'skillchain')
        assert.same({}, used)
        assert.is_true(said(gs, 'Error: Light Arts does not have a skillchain command.'))
    end)

    it('says so for a stratagem Dark Arts lacks', function()
        local gs, used = scholar({'Dark Arts'}, 'duration')
        assert.same({}, used)
        assert.is_true(said(gs, 'Error: Dark Arts does not have a duration command.'))
    end)

    it('says so for a command it does not know', function()
        local gs, used = scholar({'Light Arts'}, 'nothing')
        assert.same({}, used)
        assert.is_true(said(gs, 'Error: Unknown command [nothing]'))
    end)
end)

describe('gs c elemental on a scholar\'s nukes', function()
    -- Fire IV and V want an Addendum: Black, which the scholar has up.
    local function nuker(options)
        options = options or {}
        options.buffs = options.buffs or {'Addendum: Black'}
        return boot(options)
    end

    local function nuke(gs, command)
        gs:console('gs c elemental ' .. (command or 'nuke'))
        return actions(gs)
    end

    it('casts the highest tier of the element\'s nuke that is ready and affordable: Fire V', function()
        local gs = nuker()
        assert.same({'Fire V'}, nuke(gs))
    end)

    it('casts the next tier down while the highest is on recast', function()
        local gs = nuker()
        jobby.set_recasts(gs, {spells = {[148] = 6000}})
        assert.same({'Fire IV'}, nuke(gs))
    end)

    it('casts a tier more down while those are on recast', function()
        local gs = nuker()
        jobby.set_recasts(gs, {spells = {[148] = 6000, [147] = 6000}})
        assert.same({'Fire III'}, nuke(gs))
    end)

    it('casts the highest tier the MP buys', function()
        local gs = nuker({mp = 100})
        assert.same({'Fire III'}, nuke(gs))
    end)

    it('says so when nothing is ready and affordable', function()
        local gs = nuker({mp = 5})
        assert.same({}, nuke(gs))
        assert.is_true(said(gs, 'Abort: All Fire nukes on cooldown or or not enough MP.'))
    end)

    it('casts Fire II for a small nuke', function()
        local gs = nuker()
        assert.same({'Fire II'}, nuke(gs, 'smallnuke'))
    end)

    it('casts Fire for a small nuke while Fire II is on recast', function()
        local gs = nuker()
        jobby.set_recasts(gs, {spells = {[145] = 6000}})
        assert.same({'Fire'}, nuke(gs, 'smallnuke'))
    end)

    it('casts Banish II in the Light element', function()
        local gs = nuker({sub_job = 'WHM'})
        gs:console('gs c set ElementalMode Light')
        gs:traffic()
        assert.same({'Banish II'}, nuke(gs))
    end)

    it('casts Banish in the Light element while Banish II is on recast', function()
        local gs = nuker({sub_job = 'WHM'})
        gs:console('gs c set ElementalMode Light')
        jobby.set_recasts(gs, {spells = {[29] = 6000}})
        gs:traffic()
        assert.same({'Banish'}, nuke(gs))
    end)

    it('says so in the Light element when neither Banish is ready', function()
        local gs = nuker({sub_job = 'WHM'})
        gs:console('gs c set ElementalMode Light')
        jobby.set_recasts(gs, {spells = {[29] = 6000, [28] = 6000}})
        gs:traffic()
        assert.same({}, nuke(gs))
        assert.is_true(said(gs, 'Abort: Banishes on cooldown or not enough MP.'))
    end)

    it('casts the helix of the element, a second tier with the job points to spend', function()
        local gs = nuker()
        assert.same({'Pyrohelix II'}, nuke(gs, 'helix'))
    end)

    it('casts the first tier of the helix with fewer job points spent', function()
        local gs = nuker()
        gs.game.player.job_points.sch.jp_spent = 1000
        assert.same({'Pyrohelix'}, nuke(gs, 'helix'))
    end)

    it('casts the storm of the element on the caster, a second tier with the job points to spend', function()
        local gs = nuker()
        assert.same({'Firestorm II'}, nuke(gs, 'weather me'))
    end)

    it('casts the first tier of the storm with few job points spent', function()
        local gs = nuker()
        gs.game.player.job_points.sch.jp_spent = 50
        assert.same({'Firestorm'}, nuke(gs, 'weather me'))
    end)

    it('casts Klimaform when the storm of the element is up on the caster', function()
        local gs = nuker({buffs = {'Addendum: Black', 'Firestorm'}})
        assert.same({'Klimaform'}, nuke(gs, 'weather me'))
    end)

    it('casts the storm again rather than Klimaform when Klimaform is up', function()
        local gs = nuker({buffs = {'Addendum: Black', 'Firestorm', 'Klimaform'}})
        assert.same({'Firestorm II'}, nuke(gs, 'weather me'))
    end)

    it('casts the storm rather than Klimaform when Klimaform is on recast', function()
        local gs = nuker({buffs = {'Addendum: Black', 'Firestorm'}})
        jobby.set_recasts(gs, {spells = {[287] = 6000}})
        assert.same({'Firestorm II'}, nuke(gs, 'weather me'))
    end)
end)

describe('gs c elemental skillchain on a scholar', function()
    local function skillchainer(options)
        options = options or {}
        options.buffs = options.buffs or {'Dark Arts'}
        options.tp = options.tp or 0
        return boot(options)
    end

    local function chain(gs, command)
        gs:console('gs c elemental ' .. command)
        return actions(gs)
    end

    it('says so when no monster is targeted', function()
        local gs = skillchainer()
        gs.game.target_index = nil
        assert.same({}, chain(gs, 'skillchain1'))
        assert.is_true(said(gs, 'Abort: You are not targeting a monster.'))
    end)

    it('says so when the scholar is silenced', function()
        local gs = skillchainer({buffs = {'Dark Arts', 'silence'}})
        assert.same({}, chain(gs, 'skillchain1'))
        assert.is_true(said(gs, 'You are disabled, cancelling skillchain.'))
    end)

    it('says so with fewer than two stratagems', function()
        local gs = skillchainer()
        jobby.set_recasts(gs, {abilities = {[231] = 132}})
        assert.same({}, chain(gs, 'skillchain1'))
        assert.is_true(said(gs, 'Abort: You have less than two stratagems available.'))
    end)

    it('counts the Immanence up as a stratagem', function()
        local gs = skillchainer({buffs = {'Dark Arts', 'Immanence'}})
        jobby.set_recasts(gs, {abilities = {[231] = 132}})
        assert.same({}, chain(gs, 'skillchain1'))
        assert.is_false(said(gs, 'Abort: You have less than two stratagems available.'))
    end)

    it('starts Dark Arts when it is not up, and says why', function()
        local gs = skillchainer({buffs = {'Light Arts'}})
        assert.same({'Dark Arts'}, chain(gs, 'skillchain1'))
        assert.is_true(said(gs, "Can't use elemental skillchain commands without Dark Arts - Activating."))
    end)

    it('is an Immanence, an opening in the party chat and the first spell a second and a bit later', function()
        local gs = skillchainer()
        assert.same({'Immanence'}, chain(gs, 'skillchain1'))
        assert.same({'/p {Liquefaction} -Apex Toad- MB: {Fire} OPEN!'}, gs.game.typed)
        gs:advance(1.4)
        gs:finish_action()
        assert.same({'Stone'}, actions(gs))
    end)

    it('goes on with a second Immanence and the second spell, closing in the party chat', function()
        local gs = skillchainer()
        chain(gs, 'skillchain1')
        gs:advance(1.4)
        gs:finish_action()
        gs:advance(6)
        local names = actions(gs)
        assert.same({'Stone', 'Immanence', 'Pyrohelix'}, names)
        local party = {}
        for _, line in ipairs(gs.game.typed) do
            if line:sub(1, 3) == '/p ' then
                party[#party + 1] = line
            end
        end
        assert.same({'/p {Liquefaction} -Apex Toad- MB: {Fire} OPEN!', '/p {Liquefaction} -Apex Toad- MB: {Fire} CLOSE!'},
            party)
    end)

    it('is held back for a spell on recast, saying how long', function()
        local gs = skillchainer()
        jobby.set_recasts(gs, {spells = {[159] = 6000}})
        assert.same({}, chain(gs, 'skillchain1'))
        assert.is_true(said(gs, 'Abort: [Stone] waiting on recast. (0:01:40)'))
    end)

    it('is held back for the second spell on recast', function()
        local gs = skillchainer()
        jobby.set_recasts(gs, {spells = {[281] = 6000}})
        assert.same({}, chain(gs, 'skillchain1'))
        assert.is_true(said(gs, 'Abort: [Pyrohelix] waiting on recast. (0:01:40)'))
    end)

    it('takes the spells of the second kind of skillchain for skillchain2: Fire, then Ionohelix', function()
        local gs = skillchainer()
        chain(gs, 'skillchain2')
        assert.same({'/p {Fusion} -Apex Toad- MB: {Fire}, {Light} OPEN!'}, gs.game.typed)
        gs:advance(1.4)
        assert.same({'Fire'}, actions(gs))
    end)

    it('is for Fire alone at three steps', function()
        local gs = skillchainer()
        gs:console('gs c set ElementalMode Ice')
        gs:traffic()
        assert.same({}, chain(gs, 'skillchain3'))
        assert.is_true(said(gs, 'Abort: Fire is the only element with a consecutive 3-step skillchain.'))
    end)

    it('is Stone, Pyrohelix and Ionohelix at three steps in Fire', function()
        local gs = skillchainer()
        assert.same({'Immanence'}, chain(gs, 'skillchain3'))
        assert.same({'/p {Liquefaction} -Apex Toad- MB: {Fire} OPEN!'}, gs.game.typed)
    end)

    it('wants the stratagems of the steps: four at four steps', function()
        local gs = skillchainer()
        jobby.set_recasts(gs, {abilities = {[231] = 99}})
        assert.same({}, chain(gs, 'skillchain4'))
        assert.is_true(said(gs, 'Abort: You have less than four stratagems available.'))
    end)

    it('puts the casting mode to Proc for a skillchain of four steps', function()
        local gs = skillchainer()
        assert.same({'Immanence'}, chain(gs, 'skillchain4'))
        assert.equal('Proc', gs.user.state.CastingMode.value)
        assert.same({'/p Starting 4-Step {Skillchain} -Apex Toad-'}, gs.game.typed)
    end)

    it('puts the casting mode to Proc for a skillchain of five steps', function()
        local gs = skillchainer()
        assert.same({'Immanence'}, chain(gs, 'skillchain5'))
        assert.equal('Proc', gs.user.state.CastingMode.value)
    end)

    it('wants five stratagems at five steps', function()
        local gs = skillchainer()
        jobby.set_recasts(gs, {abilities = {[231] = 33}})
        assert.same({}, chain(gs, 'skillchain5'))
        assert.is_true(said(gs, 'Abort: You have less than five stratagems available.'))
    end)

    it('starts the Immanence of a skillchain of six steps when it is not up', function()
        local gs = skillchainer()
        assert.same({'Immanence'}, chain(gs, 'skillchain6'))
        assert.is_true(said(gs, 'Immanence not active, wait for stratagem cooldown. - Activating Immanence.'))
        assert.equal('Normal', gs.user.state.CastingMode.value)
    end)

    it('starts a skillchain of six steps with the spell once the Immanence is up', function()
        local gs = skillchainer({buffs = {'Dark Arts', 'Immanence'}})
        gs:console('gs c elemental skillchain6')
        assert.same({'Aero'}, actions(gs))
        assert.equal('Proc', gs.user.state.CastingMode.value)
    end)

    it('is a weapon skill with an Immanence, and the second spell after, in a weapon skill skillchain', function()
        local gs = skillchainer({tp = 1000})
        gs.game.monster.distance = 4
        gs:console('gs c elemental wsskillchain')
        assert.same({'Immanence'}, actions(gs))
        gs:advance(1.4)
        assert.same({'Rock Crusher'}, actions(gs))
    end)

    it('says so when a weapon skill skillchain has not the TP', function()
        local gs = skillchainer({tp = 999})
        assert.same({}, chain(gs, 'wsskillchain'))
        assert.is_true(said(gs, "Abort: You don't have enough TP for this skillchain."))
    end)

    it('says so when the weapon skill is not known', function()
        local gs = jobby.boot('SCH', pieces, {sub_job = 'RDM', tp = 1000, buffs = {'Dark Arts'},
            abilities = {'Starburst', 'Penury'}})
        gs:console('gs c update')
        gs:traffic()
        gs.game.chat_log = {}
        gs:console('gs c elemental wsskillchain')
        assert.same({}, actions(gs))
        assert.is_true(said(gs, "Abort: You don't have access to [Rock Crusher]."))
    end)

    pending('closes a skillchain by gs c elemental endskillchain: handle_job_elemental in data/SCH.lua reads '
        .. 'second_spell_id and skillchain, which that branch never sets, so the command stops in an error')
end)

describe('the tick of a scholar', function()
    describe('with AutoArts and AutoBuffMode on', function()
        -- With the spells of Auto's list up but the last, so the tick has no spell to cast.
        local function arts(options)
            options = options or {}
            options.buffs = options.buffs or {}
            options.buffs[#options.buffs + 1] = 'Haste'
            options.buffs[#options.buffs + 1] = 'Stoneskin'
            local gs = boot(options)
            gs:console('gs c set AutoBuffMode Auto')
            gs:console('gs c toggle AutoArts')
            return gs
        end

        it('begins Dark Arts when no art is up', function()
            local gs = arts()
            assert.same({'Dark Arts'}, first_actions(gs))
        end)

        it('begins no art with one up', function()
            local gs = arts({buffs = {'Light Arts'}})
            assert.same({}, first_actions(gs))
        end)

        it('begins no art while Dark Arts is on recast', function()
            local gs = arts()
            jobby.set_recasts(gs, {abilities = {[232] = 30}})
            assert.same({}, first_actions(gs))
        end)
    end)

    it('begins no art with AutoArts off, whatever the job file would do', function()
        local gs = boot({buffs = {'Haste', 'Stoneskin'}})
        gs:console('gs c set AutoBuffMode Auto')
        assert.same({}, first_actions(gs))
    end)

    it('begins Dark Arts in combat with AutoArts on', function()
        local gs = boot()
        gs:console('gs c toggle AutoArts')
        gs.user.in_combat = true
        assert.same({'Dark Arts'}, first_actions(gs))
    end)

    describe('under AutoBuffMode', function()
        local function buffer(options)
            options = options or {}
            options.buffs = options.buffs or {'Light Arts'}
            local gs = boot(options)
            gs:console('gs c set AutoBuffMode Auto')
            return gs
        end

        it('casts the first spell of buff_spell_lists.Auto it lacks the buff of: Haste', function()
            local gs = buffer()
            assert.same({'Haste'}, first_actions(gs))
        end)

        it('goes on to Stoneskin once Haste is up', function()
            local gs = buffer({buffs = {'Light Arts', 'Haste'}})
            assert.same({'Stoneskin'}, first_actions(gs))
        end)

        it('casts Klimaform in combat once those are up', function()
            local gs = buffer({buffs = {'Light Arts', 'Haste', 'Stoneskin'}})
            gs.user.in_combat = true
            assert.same({'Klimaform'}, first_actions(gs))
        end)

        it('casts no Klimaform out of combat', function()
            local gs = buffer({buffs = {'Light Arts', 'Haste', 'Stoneskin'}})
            assert.same({}, first_actions(gs))
        end)
    end)

    it('casts what a buffup lacks: Haste first in the Auto list', function()
        local gs = boot({buffs = {'Light Arts'}})
        gs:console('gs c buffup Auto')
        assert.same({'Haste'}, first_actions(gs))
    end)
end)
