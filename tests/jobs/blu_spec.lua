local harness = require('harness')
local jobby = require('jobby')

local pieces = {'Volte Cap', 'Volte Jupon', 'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Null Masque',
    'Adamantite Armor', 'Plumb Boots', "Orunmila's Torque", 'Weike Torque', 'Loricate Torque', 'Sortiarius Earring',
    'Beatific Earring', 'Choleric Earring', 'Pensee Earring', 'Moonshade Earring', 'Lunette Ring', 'Pernicious Ring',
    'Gelatinous Ring', 'Cacoethic Ring', 'Petrov Ring', 'Fortified Ring', 'Vertigo Ring', 'Dhanurveda Ring',
    'Wanion Belt', 'Prodigious Mantle', 'Malignance Chapeau', 'Malignance Tabard', 'Naegling', 'Gozuki Mezuki',
    'Fotia Gorget', 'Sanctity Necklace', "Combatant's Torque"}

-- The boot options of Jobby as a blue mage, knowing only the spells named, which the game gives him in his blue magic
-- set.
local function blue_mage(spells, overrides)
    local options = overrides or {}
    options.spells, options.items = spells, pieces
    options.sub_job = options.sub_job or 'NIN'
    return options
end

-- Jobby as a blue mage with the idle set on (see blue_mage).
local function boot(spells, overrides)
    return jobby.boot('BLU', blue_mage(spells, overrides))
end

-- As boot, and past the five seconds Sel waits after loading before its tick acts.
local function boot_ticking(spells, overrides)
    return jobby.boot_ticking('BLU', blue_mage(spells, overrides))
end

local function sets_of(gs)
    return gs.user.sets
end

local function blue(gs, list)
    return sets_of(gs).midcast['Blue Magic'][list]
end

-- What is worn once the spell is out: the Blue Magic fast cast set and the set of the spell's list over the idle set.
local function midcast_worn(gs, line)
    gs:type(line)
    return gs:worn()
end

local function blue_over_fast_cast(gs, ...)
    return jobby.worn_by(jobby.idle, jobby.layer(sets_of(gs).precast.FC['Blue Magic'], ...))
end

-- The actions the tick sent in its first moments: it starts five seconds after the file loads, and acts again once
-- the first action's delay is over.
local function first_actions(gs)
    gs:play(harness.sel_load_time + 0.3)
    return gs:actions()
end

describe('the set a blue spell takes from its list in blue_magic_maps', function()
    local spells_by_list = {
        {'PhysicalAcc', 'Heavy Strike', '<t>'},
        {'PhysicalStr', 'Vertical Cleave', '<t>'},
        {'PhysicalDex', 'Foot Kick', '<t>'},
        {'PhysicalVit', 'Power Attack', '<t>'},
        {'PhysicalAgi', 'Helldive', '<t>'},
        {'PhysicalInt', 'Mandibular Bite', '<t>'},
        {'PhysicalMnd', 'Screwdriver', '<t>'},
        {'PhysicalChr', 'Bludgeon', '<t>'},
        {'PhysicalHP', 'Final Sting', '<t>'},
        {'Magical', 'Blastbomb', '<t>'},
        {'MagicalMnd', 'Magic Hammer', '<t>'},
        {'MagicalChr', 'Eyes On Me', '<t>'},
        {'MagicalVit', 'Thermal Pulse', '<t>'},
        {'MagicalDex', 'Charged Whisker', '<t>'},
        {'MagicAccuracy', 'Sheep Song', '<t>'},
        {'Breath', 'Poison Breath', '<t>'},
        {'Stun', 'Head Butt', '<t>'},
        {'SkillBasedBuff', 'Diamondhide', '<me>'},
        {'Buff', 'Cocoon', '<me>'},
    }

    for _, entry in ipairs(spells_by_list) do
        local list, spell, target = unpack(entry)
        it(('is sets.midcast["Blue Magic"].%s for %s'):format(list, spell), function()
            local gs = boot({spell})
            assert.same(blue_over_fast_cast(gs, blue(gs, list)), midcast_worn(gs, ('/ma "%s" %s'):format(spell, target)))
        end)
    end

    it('is sets.midcast["Blue Magic"].MagicalAgi for Crashing Thunder, which needs Unbridled Learning up', function()
        local gs = boot({'Crashing Thunder'})
        gs:gain_buff('Unbridled Learning')
        gs:traffic()
        assert.same(blue_over_fast_cast(gs, blue(gs, 'MagicalAgi')), midcast_worn(gs, '/ma "Crashing Thunder" <t>'))
    end)

    it('gives each list a set of its own, so each case above can tell the lists apart', function()
        local gs = boot({})
        local seen = {}
        for list, set in pairs(sets_of(gs).midcast['Blue Magic']) do
            if type(set) == 'table' and not list:find('^Unlocked') and list ~= 'AoEHealing' then
                local key = set.ring1 .. '/' .. set.ear1
                assert.is_nil(seen[key], list .. ' wears what ' .. tostring(seen[key]) .. ' does')
                seen[key] = list
            end
        end
    end)
end)

describe('a blue spell the lists leave out or hold twice', function()
    it('takes sets.midcast["Blue Magic"] itself when no list holds it', function()
        local gs = boot({'Polar Roar'})
        gs:gain_buff('Unbridled Learning')
        gs:traffic()
        assert.same(jobby.worn_by(jobby.idle,
            jobby.layer(sets_of(gs).precast.FC['Blue Magic'], sets_of(gs).midcast['Blue Magic'])),
            midcast_worn(gs, '/ma "Polar Roar" <t>'))
    end)

    it('takes the set of one of the lists that hold it, as Lua happens to order them', function()
        local gs = boot({'Hecatomb Wave'})
        local worn = midcast_worn(gs, '/ma "Hecatomb Wave" <t>')
        local breath = blue_over_fast_cast(gs, blue(gs, 'Breath'))
        local accuracy = blue_over_fast_cast(gs, blue(gs, 'MagicAccuracy'))
        assert.is_true(pcall(assert.same, breath, worn) or pcall(assert.same, accuracy, worn))
    end)
end)

describe('the casting mode and a blue spell', function()
    it('takes the list set\'s Resistant sub-table in the Resistant casting mode', function()
        local gs = boot({'Blastbomb'})
        gs:console('gs c set CastingMode Resistant')
        gs:traffic()
        assert.same(blue_over_fast_cast(gs, blue(gs, 'Magical').Resistant), midcast_worn(gs, '/ma "Blastbomb" <t>'))
    end)

    it('stays at the list set when it has no Resistant sub-table', function()
        local gs = boot({'Foot Kick'})
        gs:console('gs c set CastingMode Resistant')
        gs:traffic()
        assert.same(blue_over_fast_cast(gs, blue(gs, 'PhysicalDex')), midcast_worn(gs, '/ma "Foot Kick" <t>'))
    end)

    it('wears sets.precast.FC.Proc ahead of the spell in the Proc casting mode', function()
        local gs = boot({'Foot Kick'})
        gs:console('gs c set CastingMode Proc')
        gs:traffic()
        gs:type('/ma "Foot Kick" <t>')
        assert.same(jobby.layer(sets_of(gs).precast.FC.Proc), gs:traffic()[1].equip)
    end)

    it('wears sets.precast.FC["Blue Magic"] ahead of the spell otherwise', function()
        local gs = boot({'Foot Kick'})
        gs:type('/ma "Foot Kick" <t>')
        assert.same(jobby.layer(sets_of(gs).precast.FC['Blue Magic']), gs:traffic()[1].equip)
    end)
end)

describe('a spell that needs Unbridled Learning', function()
    it('is cancelled with a message when the buff isn\'t up and nothing asks to use it', function()
        local gs = boot({'Cesspool'})
        gs:type('/ma "Cesspool" <t>')
        assert.same({}, gs:traffic())
        assert.same({'Abort: Unbridled Learning not active.'}, gs:chat())
    end)

    it('goes out at once with Unbridled Learning up', function()
        local gs = boot({'Cesspool'})
        gs:gain_buff('Unbridled Learning')
        gs:traffic()
        gs:type('/ma "Cesspool" <t>')
        assert.same({'Cesspool'}, gs:actions())
    end)

    it('goes out with Unbridled Wisdom up too', function()
        local gs = boot({'Cesspool'})
        gs:gain_buff('Unbridled Wisdom')
        gs:traffic()
        gs:type('/ma "Cesspool" <t>')
        assert.same({'Cesspool'}, gs:actions())
    end)

    it('is held back for Unbridled Learning, and cast a second later, in the Auto Unbridled mode', function()
        local gs = boot({'Cesspool'})
        gs:console('gs c set AutoUnbridled true')
        gs:type('/ma "Cesspool" <t>')
        assert.same({{action = 'Unbridled Learning', target = 'Jobby'}}, gs:traffic())
        gs:gain_buff('Unbridled Learning')
        gs:traffic()
        gs:advance(1)
        assert.same({'Cesspool'}, gs:actions())
    end)

    it('is held back for Unbridled Learning when AutoBuffMode is on', function()
        local gs = boot({'Cesspool'})
        gs:console('gs c set AutoBuffMode Auto')
        gs:type('/ma "Cesspool" <t>')
        assert.same({{action = 'Unbridled Learning', target = 'Jobby'}}, gs:traffic())
    end)

    it('is held back for Unbridled Learning while a buffup is going', function()
        local gs = boot({'Cesspool'})
        gs:console('gs c buffup')
        gs:type('/ma "Cesspool" <t>')
        assert.same({{action = 'Unbridled Learning', target = 'Jobby'}}, gs:traffic())
    end)

    it('is cancelled, not held back, when Unbridled Learning is on recast', function()
        local gs = boot({'Cesspool'})
        gs:console('gs c set AutoUnbridled true')
        gs.game:start_ability_recast('Unbridled Learning', 100)
        gs:chat()
        gs:type('/ma "Cesspool" <t>')
        assert.same({}, gs:traffic())
        assert.same({'Abort: Unbridled Learning not active.'}, gs:chat())
    end)

    it('is cancelled, not held back, with a minute of its own recast left, with the word that Unbridled Learning is '
        .. 'not active', function()
        local gs = boot({'Cesspool'})
        gs:console('gs c set AutoUnbridled true')
        gs.game:start_spell_recast('Cesspool', 60)
        gs:chat()
        gs:type('/ma "Cesspool" <t>')
        assert.same({}, gs:traffic())
        assert.same({'Abort: Unbridled Learning not active.'}, gs:chat())
    end)

    pending('is cancelled, not held back, with 30 seconds of its own recast left: job_filter_precast in data/BLU.lua '
        .. 'turns the recast to seconds and holds that against spell_latency, which is in sixtieths of a second, so it '
        .. 'takes a spell with under 48 seconds left for ready and uses Unbridled Learning on it')

    it('is the only kind of blue spell the filter holds back', function()
        local gs = boot({'Foot Kick'})
        gs:console('gs c set AutoUnbridled true')
        gs:type('/ma "Foot Kick" <t>')
        assert.same({'Foot Kick'}, gs:actions())
    end)
end)

describe('a weapon skill when a club is in hand', function()
    -- Shining Strike is a club weapon skill: with it known and the sword ones not, the job file sends the club's
    -- counterpart, so one macro does for either weapon.
    local counterparts = {
        {'Chant du Cygne', 'Realmrazer'}, {'Sanguine Blade', 'Flash Nova'}, {'Flat Blade', 'Brainshaker'},
        {'Expiacion', 'Judgment'}, {'Vorpal Blade', 'True Strike'}, {'Savage Blade', 'Black Halo'},
    }
    local club_skills = {'Shining Strike', 'Realmrazer', 'Flash Nova', 'Brainshaker', 'Judgment', 'True Strike',
        'Black Halo'}

    for _, pair in ipairs(counterparts) do
        local sword, club = unpack(pair)
        it(('is %s in place of %s'):format(club, sword), function()
            local gs = boot({'Foot Kick'}, {tp = 1000, abilities = club_skills})
            gs:type(('/ws "%s" <t>'):format(sword))
            assert.same({{action = club, target = 'Apex Toad'}}, gs:traffic())
        end)
    end

    it('is left alone when no club weapon skill is known', function()
        local gs = boot({'Foot Kick'}, {tp = 1000, abilities = {'Requiescat'}})
        gs:type('/ws "Chant du Cygne" <t>')
        assert.same({}, gs:traffic())
        assert.same({}, gs:commands())
        assert.same({"Abort: You don't have access to [Chant du Cygne]."}, gs:chat())
    end)
end)

describe('a weapon skill at the TP cap', function()
    local function engaged(overrides)
        local gs = boot({'Foot Kick'}, overrides)
        gs:engage()
        gs:traffic()
        return gs
    end

    local function engaged_worn(gs, ...)
        return jobby.worn_by(jobby.idle, jobby.layer(sets_of(gs).engaged, ...))
    end

    it('trades the Moonshade Earring for sets.MaxTP from 2951 TP', function()
        local gs = engaged({tp = 2951})
        gs:type('/ws "Chant du Cygne" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Chant du Cygne'], sets_of(gs).MaxTP), gs:worn())
    end)

    it('trades it when the Moonshade Earring is in the other ear too', function()
        local gs = engaged({tp = 3000})
        gs:type('/ws "Savage Blade" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Savage Blade'], sets_of(gs).MaxTP), gs:worn())
    end)

    it('keeps the Moonshade Earring at 2950 TP', function()
        local gs = engaged({tp = 2950})
        gs:type('/ws "Chant du Cygne" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Chant du Cygne']), gs:worn())
    end)

    it('wears sets.AccMaxTP in the Acc offense mode', function()
        local gs = engaged({tp = 3000})
        gs:console('gs c set OffenseMode Acc')
        gs:traffic()
        gs:type('/ws "Chant du Cygne" <t>')
        assert.same(jobby.worn_by(jobby.idle,
            jobby.layer(sets_of(gs).engaged.Acc, sets_of(gs).precast.WS['Chant du Cygne'], sets_of(gs).AccMaxTP)),
            gs:worn())
    end)

    it('keeps the set of a weapon skill with no Moonshade Earring', function()
        local gs = engaged({tp = 3000})
        gs:type('/ws "Requiescat" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS.Requiescat), gs:worn())
    end)

    it('is followed by sets.Learning in the learning mode', function()
        local gs = engaged({tp = 2000})
        gs:console('gs c toggle LearningMode')
        gs:traffic()
        gs:type('/ws "Requiescat" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS.Requiescat, sets_of(gs).Learning), gs:worn())
    end)
end)

describe('a blue healing spell', function()
    it('wears sets.midcast["Blue Magic"].UnlockedHealing and sets.Self_Healing on its caster when weapons are free', function()
        local gs = boot({'Pollen'})
        assert.same(blue_over_fast_cast(gs, blue(gs, 'Healing'), blue(gs, 'UnlockedHealing'), sets_of(gs).Self_Healing),
            midcast_worn(gs, '/ma "Pollen" <me>'))
    end)

    it('wears the unlocked set but no sets.Self_Healing for a spell on someone else', function()
        local gs = boot({'Magic Fruit'})
        gs.game:add_party_member({name = 'Friend'})
        assert.same(blue_over_fast_cast(gs, blue(gs, 'Healing'), blue(gs, 'UnlockedHealing')),
            midcast_worn(gs, '/ma "Magic Fruit" Friend'))
    end)

    it('wears sets.Self_Healing alone, without the unlocked set, when a weapon set locks the weapons', function()
        local gs = boot({'Pollen'})
        gs:console('gs c set Weapons Naegling')
        gs:traffic()
        assert.same(jobby.worn_by(jobby.idle, jobby.layer(sets_of(gs).precast.FC['Blue Magic'], blue(gs, 'Healing'),
            sets_of(gs).Self_Healing, {main = 'Naegling'})), midcast_worn(gs, '/ma "Pollen" <me>'))
    end)

    it('wears the unlocked set again once UnlockWeapons is on', function()
        local gs = boot({'Pollen'})
        gs:console('gs c set Weapons Naegling')
        gs:console('gs c set UnlockWeapons true')
        gs:traffic()
        local worn = midcast_worn(gs, '/ma "Pollen" <me>')
        assert.equal('Volte Bracers', worn.hands)
    end)

    for _, spell in ipairs({'Healing Breeze', 'White Wind'}) do
        it(('wears sets.midcast["Blue Magic"].UnlockedAoEHealing, and not sets.Self_Healing, for %s on its caster'):format(spell), function()
            local gs = boot({spell})
            assert.same(blue_over_fast_cast(gs, blue(gs, 'Healing'), blue(gs, 'UnlockedHealing'),
                blue(gs, 'UnlockedAoEHealing')), midcast_worn(gs, ('/ma "%s" <me>'):format(spell)))
        end)
    end

    it('wears sets.midcast["Blue Magic"].AoEHealing for an area spell on its caster when weapons are locked', function()
        local gs = boot({'Healing Breeze'})
        gs:console('gs c set Weapons Naegling')
        gs:traffic()
        assert.same(jobby.worn_by(jobby.idle, jobby.layer(sets_of(gs).precast.FC['Blue Magic'], blue(gs, 'Healing'),
            blue(gs, 'AoEHealing'), {main = 'Naegling'})), midcast_worn(gs, '/ma "Healing Breeze" <me>'))
    end)
end)

describe('the buffs a blue mage keeps up', function()
    local cases = {
        {'Chain Affinity', 'Chain Affinity'}, {'Burst Affinity', 'Burst Affinity'}, {'Azure Lore', 'Azure Lore'},
        {'Diffusion', 'Diffusion'},
    }

    for _, case in ipairs(cases) do
        local buff, set = unpack(case)
        it(('wear sets.buff["%s"] over a blue spell\'s set while the buff is up'):format(set), function()
            local gs = boot({'Foot Kick'})
            gs:gain_buff(buff)
            gs:traffic()
            assert.same(blue_over_fast_cast(gs, blue(gs, 'PhysicalDex'), sets_of(gs).buff[set]),
                midcast_worn(gs, '/ma "Foot Kick" <t>'))
        end)
    end

    it('wear their sets together', function()
        local gs = boot({'Foot Kick'})
        gs:gain_buff('Chain Affinity')
        gs:gain_buff('Azure Lore')
        gs:traffic()
        assert.same(blue_over_fast_cast(gs, blue(gs, 'PhysicalDex'), sets_of(gs).buff['Chain Affinity'],
            sets_of(gs).buff['Azure Lore']), midcast_worn(gs, '/ma "Foot Kick" <t>'))
    end)

    it('stop at the end of the buff', function()
        local gs = boot({'Foot Kick'})
        gs:gain_buff('Chain Affinity')
        gs:lose_buff('Chain Affinity')
        gs:traffic()
        assert.same(blue_over_fast_cast(gs, blue(gs, 'PhysicalDex')), midcast_worn(gs, '/ma "Foot Kick" <t>'))
    end)

    it('are not laid over a spell that is not blue magic', function()
        local gs = boot({'Refresh'}, {sub_job = 'RDM'})
        gs:gain_buff('Chain Affinity')
        gs:traffic()
        gs:type('/ma "Refresh" <me>')
        assert.equal(sets_of(gs).precast.FC.head, gs:worn().head)
    end)
end)

describe('the learning mode', function()
    it('wears sets.Learning in the idle set', function()
        local gs = boot({'Foot Kick'})
        gs:console('gs c toggle LearningMode')
        assert.same(jobby.worn_by(jobby.idle, jobby.layer(sets_of(gs).Learning)), gs:worn())
    end)

    it('wears sets.Learning in the engaged set', function()
        local gs = boot({'Foot Kick'})
        gs:console('gs c toggle LearningMode')
        gs:engage()
        assert.same(jobby.worn_by(jobby.idle, jobby.layer(sets_of(gs).engaged, sets_of(gs).Learning)), gs:worn())
    end)

    it('wears sets.Learning through a blue spell', function()
        local gs = boot({'Foot Kick'})
        gs:console('gs c toggle LearningMode')
        gs:traffic()
        assert.same(blue_over_fast_cast(gs, blue(gs, 'PhysicalDex'), sets_of(gs).Learning),
            midcast_worn(gs, '/ma "Foot Kick" <t>'))
    end)

    it('takes sets.Learning off again when toggled off', function()
        local gs = boot({'Foot Kick'})
        gs:console('gs c toggle LearningMode')
        gs:console('gs c toggle LearningMode')
        assert.same(jobby.worn_by(jobby.idle), gs:worn())
    end)
end)

describe('the idle set under half MP', function()
    local function low_mp(gs)
        gs.game.player.vitals.mpp = 40
        gs.game.player.vitals.mp = 400
        gs:console('gs c update')
    end

    it('wears sets.latent_refresh in the Normal idle mode', function()
        local gs = boot({'Foot Kick'})
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.idle, jobby.layer(sets_of(gs).latent_refresh)), gs:worn())
    end)

    it('wears it with sets.Learning over it in the learning mode', function()
        local gs = boot({'Foot Kick'})
        gs:console('gs c toggle LearningMode')
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.idle, jobby.layer(sets_of(gs).latent_refresh, sets_of(gs).Learning)), gs:worn())
    end)

    it('wears sets.idle.DT alone in the DT idle mode', function()
        local gs = boot({'Foot Kick'})
        gs:console('gs c set IdleMode DT')
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.idle, jobby.layer(sets_of(gs).idle.DT)), gs:worn())
    end)

    it('wears sets.latent_refresh_grip too with a staff in the idle set and the weapons free', function()
        local gs = boot({'Foot Kick'})
        sets_of(gs).idle.main = 'Gozuki Mezuki'
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.idle, jobby.layer(sets_of(gs).latent_refresh, sets_of(gs).latent_refresh_grip,
            {main = 'Gozuki Mezuki'})), gs:worn())
    end)

    it('wears no sets.latent_refresh_grip with a weapon set locking the weapons', function()
        local gs = boot({'Foot Kick'})
        sets_of(gs).idle.main = 'Gozuki Mezuki'
        gs:console('gs c set Weapons Naegling')
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.idle, jobby.layer(sets_of(gs).latent_refresh, {main = 'Naegling'})), gs:worn())
    end)

    it('wears no sets.latent_refresh_grip with a weapon in the idle set that is no staff', function()
        local gs = boot({'Foot Kick'})
        sets_of(gs).idle.main = 'Naegling'
        low_mp(gs)
        assert.same(jobby.worn_by(jobby.idle, jobby.layer(sets_of(gs).latent_refresh, {main = 'Naegling'})), gs:worn())
    end)

    it('wears sets.idle alone above half MP', function()
        local gs = boot({'Foot Kick'})
        assert.same(jobby.worn_by(jobby.idle), gs:worn())
    end)
end)

describe('gs c curecheat', function()
    it('wears sets.HPDown and casts Magic Fruit on its caster a second later', function()
        local gs = boot({'Magic Fruit'})
        gs:console('gs c curecheat')
        assert.same({{equip = {neck = 'Loricate Torque'}}}, gs:traffic())
        gs:advance(1)
        assert.same({'Magic Fruit'}, gs:actions())
    end)

    it('says so when there is no sets.HPDown', function()
        local gs = boot({'Magic Fruit'})
        sets_of(gs).HPDown = nil
        gs:console('gs c curecheat')
        assert.same({}, gs:traffic())
        assert.same({"You don't have a sets.HPDown to cheat with."}, gs:chat())
    end)
end)

describe('the tick of a blue mage', function()
    describe('with the sub job Scholar', function()
        local function scholar(overrides)
            local gs = boot({'Foot Kick'}, overrides or {sub_job = 'SCH'})
            gs:console('gs c set AutoBuffMode Auto')
            return gs
        end

        it('uses Light Arts when AutoArts and AutoBuffMode are on', function()
            local gs = scholar()
            gs:console('gs c toggle AutoArts')
            assert.same({'Light Arts'}, first_actions(gs))
        end)

        it('leaves Light Arts alone while AutoArts is off, whatever the job file would do', function()
            local gs = scholar()
            assert.same({}, first_actions(gs))
        end)

        it('leaves Light Arts alone with an art up', function()
            local gs = scholar({sub_job = 'SCH', buffs = {'Light Arts'}})
            gs:console('gs c toggle AutoArts')
            assert.same({}, first_actions(gs))
        end)

        it('leaves Light Arts alone with another sub job', function()
            local gs = scholar({sub_job = 'RDM'})
            gs:console('gs c toggle AutoArts')
            assert.same({}, first_actions(gs))
        end)

        it('leaves Light Arts alone while it is on recast', function()
            local gs = scholar()
            gs:console('gs c toggle AutoArts')
            gs.game:start_ability_recast('Light Arts', 60)
            gs:chat()
            assert.same({}, first_actions(gs))
            assert.same({}, jobby.said(gs))
        end)
    end)

    describe('under AutoBuffMode', function()
        local function buffer(spells, overrides)
            local gs = boot(spells, overrides or {sub_job = 'RDM'})
            gs:console('gs c set AutoBuffMode Auto')
            return gs
        end

        it('casts the first spell of buff_spell_lists.Auto it lacks the buff of: Erratic Flutter for Haste', function()
            local gs = buffer({'Erratic Flutter', 'Battery Charge', 'Refresh'})
            assert.same({'Erratic Flutter'}, first_actions(gs))
        end)

        it('moves on to Battery Charge when idle, once Haste is up', function()
            local gs = buffer({'Erratic Flutter', 'Battery Charge', 'Refresh'}, {sub_job = 'RDM', buffs = {'Haste'}})
            assert.same({'Battery Charge'}, first_actions(gs))
        end)

        it('casts nothing while every buff its conditions call for is up', function()
            local gs = buffer({'Erratic Flutter', 'Battery Charge', 'Nat. Meditation'},
                {sub_job = 'RDM', buffs = {'Haste', 'Refresh'}})
            assert.same({}, first_actions(gs))
        end)

        it('casts Nat. Meditation for Attack Boost once engaged', function()
            local gs = buffer({'Erratic Flutter', 'Battery Charge', 'Nat. Meditation'},
                {sub_job = 'RDM', buffs = {'Haste', 'Refresh'}})
            gs:engage()
            gs:traffic()
            assert.same({'Nat. Meditation'}, first_actions(gs))
        end)

        it('skips a spell it hasn\'t the MP for', function()
            local gs = buffer({'Erratic Flutter', 'Battery Charge'})
            gs.game.player.vitals.mp = 10
            gs:chat()
            assert.same({}, first_actions(gs))
            assert.same({}, jobby.said(gs))
        end)

        it('casts Mighty Guard in combat with Unbridled Learning up', function()
            local gs = buffer({'Mighty Guard'},
                {sub_job = 'RDM', buffs = {'Haste', 'Refresh', 'Attack Boost', 'Unbridled Learning'}})
            gs.user.in_combat = true
            assert.same({'Mighty Guard'}, first_actions(gs))
        end)

        it('uses Unbridled Learning for Mighty Guard in combat when it is ready', function()
            local gs = buffer({'Mighty Guard'}, {sub_job = 'RDM', buffs = {'Haste', 'Refresh', 'Attack Boost'}})
            gs.user.in_combat = true
            assert.same({'Unbridled Learning'}, first_actions(gs))
        end)

        it('leaves Mighty Guard alone in combat when Unbridled Learning is not ready', function()
            local gs = buffer({'Mighty Guard'}, {sub_job = 'RDM', buffs = {'Haste', 'Refresh', 'Attack Boost'}})
            gs.game:start_ability_recast('Unbridled Learning', 100)
            gs.user.in_combat = true
            gs:chat()
            assert.same({}, first_actions(gs))
            assert.same({}, jobby.said(gs))
        end)
    end)

    describe('with the sub job Warrior, in combat under AutoBuffMode', function()
        local function warrior(buffs)
            local gs = boot({'Foot Kick'}, {sub_job = 'WAR', buffs = buffs})
            gs:console('gs c set AutoBuffMode Auto')
            gs.user.in_combat = true
            return gs
        end

        it('uses Berserk, then Aggressor', function()
            local gs = warrior({'Haste', 'Refresh', 'Attack Boost'})
            assert.same({'Berserk'}, first_actions(gs))
            gs = warrior({'Haste', 'Refresh', 'Attack Boost', 'Berserk'})
            assert.same({'Aggressor'}, first_actions(gs))
        end)

        it('uses neither once both are up', function()
            local gs = warrior({'Haste', 'Refresh', 'Attack Boost', 'Berserk', 'Aggressor'})
            assert.same({}, first_actions(gs))
        end)

        it('uses neither out of combat', function()
            local gs = warrior({'Haste', 'Refresh', 'Attack Boost'})
            gs.user.in_combat = false
            assert.same({}, first_actions(gs))
        end)
    end)

    describe('during a buffup', function()
        it('casts what the list lacks: Erratic Flutter first in the Default list', function()
            local gs = boot({'Erratic Flutter', 'Battery Charge', 'Refresh'})
            gs:console('gs c buffup')
            assert.same({'Erratic Flutter'}, first_actions(gs))
        end)

        it('takes the named list: Carcharian Verve first in Cleave once the rest are up', function()
            local gs = boot({'Carcharian Verve'}, {buffs = {'Haste', 'Refresh', 'Phalanx', 'Stoneskin', 'Blink'}})
            gs:console('gs c buffup Cleave')
            gs:gain_buff('Unbridled Learning')
            gs:traffic()
            assert.same({'Carcharian Verve'}, first_actions(gs))
        end)

        it('says so and stops when each spell of the list it can cast has its buff up', function()
            local gs = boot_ticking({'Erratic Flutter'}, {buffs = {'Haste'}})
            gs:console('gs c buffup')
            gs:play(1)
            assert.same({'All Default buffs are up!'}, gs:chat())
            assert.same('', gs.user.buffup)
        end)
    end)
end)
