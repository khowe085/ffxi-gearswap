local jobby = require('jobby')

local gear = {'Pitchfork +1', 'Mecisto. Mantle', "Bendis's Hairpin", "Theia's Hairpin", 'Vishap Armet +3',
    'Sapphire Platemail', 'Jadeite Cuirie', 'Diamond Haramaki', 'Sapphire Leggings', 'Sapphire Gauntlets',
    'Jadeite Gloves', 'Diamond Kote', 'Sapphire Trousers', 'Jadeite Chausses', 'Diamond Hiza.', "Orunmila's Torque",
    'Moonshade Earring', 'Ishvara Earring', 'Brutal Earring', 'Aptitude Mantle', 'Volte Cap'}

-- What the idle set of Jobby's dragoon gear file wears besides every gear file's.
local own_idle = {main = 'Pitchfork +1', back = 'Mecisto. Mantle'}

local idle = jobby.worn_by(own_idle)

-- What is worn with these changes over the idle set.
local function worn(changes)
    return jobby.worn_by(changes, idle)
end

-- Jobby as a dragoon with the idle set on, over a sub job of WAR unless the options (jobby.boot's) say otherwise.
local function boot(options)
    options = options or {}
    options.items = gear
    options.wearing = own_idle
    options.sub_job = options.sub_job or 'WAR'
    return jobby.boot('DRG', options)
end

describe('data/DRG.lua', function()
    it('takes Hasso as the stance and a breath at 60% HP, which an update with a sub job of SAM keeps', function()
        local gs = boot({sub_job = 'SAM'})
        assert.equal('Hasso', gs.user.state.Stance.value)
        assert.equal(60, gs.user.Breath_HPP)
    end)

    it('drops the stance on an update unless the sub job is SAM', function()
        local gs = boot()
        assert.equal('None', gs.user.state.Stance.value)
    end)
end)

describe('DRG\'s breath trigger, with a Vishap head in the gear file\'s sets.midcast.HB_Trigger', function()
    local function breath_hpp(sub_job)
        return boot({sub_job = sub_job}).user.Breath_HPP
    end

    for _, sub_job in ipairs({'WHM', 'BLM', 'RDM', 'SMN', 'BLU', 'SCH', 'GEO'}) do
        it('is 45% HP with a sub job of ' .. sub_job .. ', as with no Vishap or Drachen head', function()
            assert.equal(45, breath_hpp(sub_job))
        end)
    end

    for _, sub_job in ipairs({'PLD', 'DRK', 'BRD', 'NIN', 'RUN'}) do
        it('is 35% HP with a sub job of ' .. sub_job .. ', as with no Vishap or Drachen head', function()
            assert.equal(35, breath_hpp(sub_job))
        end)
    end

    it('stays 60% HP with a sub job that doesn\'t say otherwise', function()
        assert.equal(60, breath_hpp('WAR'))
        assert.equal(60, breath_hpp('SAM'))
    end)

    pending('is 65% HP with a sub job of WHM, BLM, RDM, SMN, BLU, SCH or GEO, and 45% with PLD, DRK, BRD, NIN or RUN, '
        .. 'with the Vishap or Drachen head of sets.midcast.HB_Trigger: job_setup in data/DRG.lua reads the set for '
        .. 'the head, and Sel builds the gear file\'s sets only after job_setup, so the head it keeps is always empty')
end)

describe('DRG\'s weapon skill with a sub job of SAM and AutoBuffMode on', function()
    local gs
    before_each(function()
        gs = boot({sub_job = 'SAM'})
        gs:console('gs c set AutoBuffMode Auto')
        gs:traffic()
    end)

    it('is held back for Sekkanoki with more than 1850 TP', function()
        gs.game.player.vitals.tp = 1851
        assert.is_true(gs:type('/ws "Stardiver" <t>'))
        assert.same({'Sekkanoki'}, gs:actions())
    end)

    it('is held back for Meditate with 1850 TP or less', function()
        gs.game.player.vitals.tp = 1850
        gs:type('/ws "Stardiver" <t>')
        assert.same({'Meditate'}, gs:actions())
    end)

    it('is held back for Meditate when Sekkanoki is on recast', function()
        gs.game.player.vitals.tp = 3000
        gs.game:start_ability_recast('Sekkanoki', 60)
        gs:type('/ws "Stardiver" <t>')
        assert.same({'Meditate'}, gs:actions())
    end)

    it('goes out when Sekkanoki and Meditate are on recast', function()
        gs.game.player.vitals.tp = 3000
        gs.game:start_ability_recast('Sekkanoki', 60)
        gs.game:start_ability_recast('Meditate', 60)
        gs:type('/ws "Stardiver" <t>')
        assert.same({'Stardiver'}, gs:actions())
    end)

    it('goes out under SJ Restriction', function()
        gs:gain_buff('SJ Restriction')
        gs.game.player.vitals.tp = 3000
        gs:type('/ws "Stardiver" <t>')
        assert.same({'Stardiver'}, gs:actions())
    end)

    it('goes out with AutoBuffMode off', function()
        gs:console('gs c set AutoBuffMode Off')
        gs.game.player.vitals.tp = 3000
        gs:type('/ws "Stardiver" <t>')
        assert.same({'Stardiver'}, gs:actions())
    end)
end)

describe('DRG\'s weapon skill with a sub job of WAR and AutoBuffMode on', function()
    it('goes out whatever the TP, with no Sekkanoki or Meditate to hold it back', function()
        local gs = boot()
        gs:console('gs c set AutoBuffMode Auto')
        gs.game.player.vitals.tp = 3000
        gs:type('/ws "Stardiver" <t>')
        assert.same({'Stardiver'}, gs:actions())
    end)
end)

-- What is worn once the weapon skill is out, with the TP Jobby has.
local function weaponskill(gs, name, tp)
    gs.game.player.vitals.tp = tp
    gs:type('/ws "' .. name .. '" <t>')
    return gs:worn()
end

describe('DRG\'s weapon skill set with Moonshade Earring in it', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('keeps Moonshade at 3200 TP with its bonus', function()
        assert.same(worn({head = "Theia's Hairpin", ear1 = 'Moonshade Earring', ear2 = 'Etiolation Earring'}),
            weaponskill(gs, 'Stardiver', 2950))
    end)

    it('gives way to sets.MaxTP above that', function()
        assert.same(worn({head = "Theia's Hairpin", ear1 = 'Ishvara Earring', ear2 = 'Etiolation Earring'}),
            weaponskill(gs, 'Stardiver', 2951))
    end)

    it('gives way to sets.AccMaxTP above that in an accuracy mode', function()
        gs:console('gs c set OffenseMode Acc')
        assert.same(worn({head = "Theia's Hairpin", ear1 = 'Brutal Earring', ear2 = 'Etiolation Earring'}),
            weaponskill(gs, 'Stardiver', 3000))
    end)
end)

describe('DRG\'s jumps', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('wear their own set', function()
        gs:type('/ja "High Jump" <t>')
        assert.same(worn({legs = 'Sapphire Trousers'}), gs:worn())
    end)

    it('wear the set for the offense mode over it, in a mode it has one for', function()
        gs:console('gs c set OffenseMode Acc')
        gs:type('/ja "Jump" <t>')
        assert.same(worn({hands = 'Jadeite Gloves'}), gs:worn())
    end)

    it('wear their own set in an offense mode they have no set for', function()
        gs:console('gs c set OffenseMode Acc')
        gs:type('/ja "High Jump" <t>')
        assert.same(worn({legs = 'Sapphire Trousers'}), gs:worn())
    end)

    it('are the Spirit Jump set, with the offense mode\'s over it', function()
        gs:console('gs c set OffenseMode Acc')
        gs:type('/ja "Spirit Jump" <t>')
        assert.same(worn({hands = 'Diamond Kote', legs = 'Jadeite Chausses'}), gs:worn())
    end)

    it('have the offense mode\'s set over theirs, which Spirit Link doesn\'t, for it is no jump', function()
        gs:console('gs c set OffenseMode Acc')
        gs:type('/ja "Spirit Link" <me>')
        assert.same(worn({legs = 'Diamond Hiza.'}), gs:worn())
    end)

    it('give way to the idle set once done', function()
        gs:type('/ja "Jump" <t>')
        gs:finish_action()
        assert.same(worn(), gs:worn())
    end)
end)

describe('DRG\'s casting with a wyvern out and its HP low', function()
    local gs
    before_each(function()
        gs = boot({sub_job = 'WHM'})
        gs:give_pet({name = 'Wyvern'})
        gs.game.player.vitals.hpp = 40
        gs:traffic()
    end)

    it('wears sets.midcast.HB_Trigger over the midcast set', function()
        gs:type('/ma "Cure III" <me>')
        assert.same(worn({head = 'Vishap Armet +3'}), gs:worn())
    end)

    it('goes on wearing the trigger and the healing breath set when the spell is done, rather than the idle set', function()
        gs:type('/ma "Cure III" <me>')
        gs:finish_action()
        assert.same(worn({head = 'Vishap Armet +3', neck = "Orunmila's Torque"}), gs:worn())
    end)

    it('goes back to the idle set once the wyvern is done with its breath', function()
        gs:type('/ma "Cure III" <me>')
        gs:finish_action()
        gs:pet_readies('Restoring Breath', 'ability', {target = 'player'})
        gs:pet_finishes('Restoring Breath', 'ability', {category = 6, message = 100, target = 'player'})
        assert.same(worn(), gs:worn())
    end)

    it('wears no trigger at 25% HP or less', function()
        gs.game.player.vitals.hpp = 25
        gs:type('/ma "Cure III" <me>')
        assert.same(worn({head = 'Volte Cap'}), gs:worn())
    end)

    it('wears no trigger at 45% HP, the Breath_HPP of a sub job of WHM with the trigger head unread', function()
        gs.game.player.vitals.hpp = 45
        gs:type('/ma "Cure III" <me>')
        assert.same(worn({head = 'Volte Cap'}), gs:worn())
    end)

    it('wears no trigger and goes back to the idle set with no wyvern out', function()
        gs:take_pet()
        gs:type('/ma "Cure III" <me>')
        gs:finish_action()
        assert.same(worn(), gs:worn())
    end)
end)

describe('DRG\'s Steady Wing and breaths with a wyvern out', function()
    local gs
    before_each(function()
        gs = boot()
        gs:give_pet({name = 'Wyvern'})
        gs:traffic()
    end)

    it('go on wearing sets.HealingBreath after Steady Wing', function()
        gs:type('/pet "Steady Wing" <me>')
        gs:finish_action()
        assert.same(worn({neck = "Orunmila's Torque"}), gs:worn())
    end)

    it('go on wearing sets.HealingBreath after Restoring Breath', function()
        gs:type('/pet "Restoring Breath" <me>')
        gs:finish_action()
        assert.same(worn({neck = "Orunmila's Torque"}), gs:worn())
    end)

    it('go on wearing sets.SmitingBreath after Smiting Breath', function()
        gs:type('/pet "Smiting Breath" <t>')
        gs:finish_action()
        assert.same(worn({back = 'Aptitude Mantle'}), gs:worn())
    end)

    it('go back to the idle set once the wyvern is done', function()
        gs:type('/pet "Smiting Breath" <t>')
        gs:finish_action()
        gs:pet_readies('Smiting Breath', 'ability')
        gs:pet_finishes('Smiting Breath', 'ability', {category = 6, message = 100})
        assert.same(worn(), gs:worn())
    end)

    it('wear no breath set when Steady Wing was used with no wyvern out', function()
        gs:take_pet()
        gs:traffic()
        gs:type('/pet "Steady Wing" <me>')
        gs:finish_action()
        assert.same(worn(), gs:worn())
    end)
end)

describe('DRG\'s engaged set', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is sets.engaged with no wyvern out', function()
        gs:engage()
        assert.same(worn({head = "Bendis's Hairpin", body = 'Sapphire Platemail'}), gs:worn())
    end)

    it('is sets.engaged.Pet with a wyvern that was out when GearSwap loaded', function()
        gs = boot({pet = {name = 'Wyvern'}})
        gs:engage()
        assert.same(worn({head = "Bendis's Hairpin", body = 'Jadeite Cuirie'}), gs:worn())
    end)

    it('is sets.engaged.Pet with a wyvern called, once a buff has changed', function()
        gs:give_pet({name = 'Wyvern'})
        gs:gain_buff('Haste')
        gs:engage()
        assert.same(worn({head = "Bendis's Hairpin", body = 'Jadeite Cuirie'}), gs:worn())
    end)

    pending('is sets.engaged.Pet as soon as a wyvern is called: Sel updates the melee groups, where DRG\'s Pet group is '
        .. 'added, only at load and on a buff change, not on pet_change or on gs c update')

    it('is sets.engaged.SpiritSurge while Spirit Surge is up', function()
        gs:gain_buff('Spirit Surge')
        gs:engage()
        assert.same(worn({head = "Bendis's Hairpin", body = 'Sapphire Platemail', feet = 'Sapphire Leggings'}), gs:worn())
    end)

    it('is sets.engaged.Pet.SpiritSurge with a wyvern out and Spirit Surge up', function()
        gs:give_pet({name = 'Wyvern'})
        gs:gain_buff('Spirit Surge')
        gs:engage()
        assert.same(worn({head = "Bendis's Hairpin", body = 'Diamond Haramaki'}), gs:worn())
    end)

    it('goes without sets.engaged.SpiritSurge when Spirit Surge wears off', function()
        gs:gain_buff('Spirit Surge')
        gs:engage()
        gs:lose_buff('Spirit Surge')
        assert.same(worn({head = "Bendis's Hairpin", body = 'Sapphire Platemail'}), gs:worn())
    end)
end)

describe('DRG\'s Restoring Breath with a wyvern hurt', function()
    local gs
    before_each(function()
        gs = boot()
        gs:give_pet({name = 'Wyvern', hpp = 74})
        gs:traffic()
    end)

    it('is held back for Spirit Bond', function()
        assert.is_true(gs:type('/pet "Restoring Breath" <me>'))
        assert.same({'Spirit Bond'}, gs:actions())
    end)

    it('is typed again 1.1 seconds after Spirit Bond goes out, and then goes out', function()
        gs:type('/pet "Restoring Breath" <me>')
        gs.game:start_ability_recast('Spirit Bond', 60)
        gs:finish_action()
        gs:traffic()
        gs:advance(1.2)
        assert.same({'Restoring Breath'}, gs:actions())
    end)

    it('goes out without Spirit Bond when the wyvern has 75% HP or more', function()
        gs.game.pet.hpp = 75
        gs.env.refresh_globals()
        gs:type('/pet "Restoring Breath" <me>')
        assert.same({'Restoring Breath'}, gs:actions())
    end)

    it('goes out without Spirit Bond when that is on recast', function()
        gs.game:start_ability_recast('Spirit Bond', 60)
        gs:type('/pet "Restoring Breath" <me>')
        assert.same({'Restoring Breath'}, gs:actions())
    end)

    it('goes out without Spirit Bond when the target has 44% HP or less', function()
        gs.game.player.vitals.hpp = 44
        gs:type('/pet "Restoring Breath" <me>')
        assert.same({'Restoring Breath'}, gs:actions())
    end)

    it('goes out without Spirit Bond when AutoBondMode is off', function()
        gs:console('gs c toggle AutoBondMode')
        gs:type('/pet "Restoring Breath" <me>')
        assert.same({'Restoring Breath'}, gs:actions())
    end)

    it('goes out without Spirit Bond when the wyvern is gone', function()
        gs:take_pet()
        gs:traffic()
        gs:type('/pet "Restoring Breath" <me>')
        assert.same({'Restoring Breath'}, gs:actions())
    end)
end)

describe('DRG once the wyvern has done Restoring Breath', function()
    local gs
    before_each(function()
        gs = boot()
        gs:give_pet({name = 'Wyvern'})
        gs:type('/pet "Restoring Breath" <me>')
        gs:commands()
    end)

    it('cancels Spirit Bond', function()
        gs:pet_finishes('Restoring Breath', 'ability', {category = 6, message = 100, target = 'player'})
        assert.same({'cancel spirit bond'}, gs:commands())
    end)

    it('leaves Spirit Bond when AutoBondMode is off', function()
        gs:console('gs c toggle AutoBondMode')
        gs:commands()
        gs:pet_finishes('Restoring Breath', 'ability', {category = 6, message = 100, target = 'player'})
        assert.same({}, gs:commands())
    end)
end)

describe('DRG\'s Hasso, kept by the tick with a sub job of SAM', function()
    local gs
    before_each(function()
        gs = boot({sub_job = 'SAM'})
        gs:engage()
        gs:traffic()
    end)

    it('is put up when engaged with a two-handed weapon', function()
        gs:play(5.5)
        assert.same({'Hasso'}, gs:actions())
    end)

    it('is Seigan in the Seigan stance', function()
        gs:console('gs c set Stance Seigan')
        gs:play(5.5)
        assert.same({'Seigan'}, gs:actions())
    end)

    it('is nothing in the None stance', function()
        gs:console('gs c set Stance None')
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('waits while Hasso is up', function()
        gs:gain_buff('Hasso')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('waits under SJ Restriction', function()
        gs:gain_buff('SJ Restriction')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('waits while Hasso is on recast, without trying it', function()
        gs.game:start_ability_recast('Hasso', 30)
        gs:play(5.5)
        assert.same({}, gs:actions())
        assert.same({}, jobby.refusals(gs))
    end)
end)

describe('DRG\'s Hasso, kept by the tick with another sub job', function()
    it('is never put up', function()
        local gs = boot()
        gs:engage()
        gs:traffic()
        gs:console('gs c set Stance Hasso')
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)
end)

describe('DRG\'s jumps, kept by the tick under AutoJumpMode', function()
    pending('are Spirit Jump, Soul Jump, Jump and High Jump, then Spirit Link, as check_jump in data/DRG.lua means: '
        .. 'Sel-Utility.lua, which get_sets loads after the job file, defines check_jump again, and its version only '
        .. 'jumps with a sub job of DRG, Jump and High Jump alone')
end)

describe('DRG\'s buffs kept by the tick under AutoBuffMode', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set AutoBuffMode Auto')
        gs:console('gs c set Stance None')
    end)

    it('are Call Wyvern first, with no wyvern out', function()
        gs:monster_hits()
        gs:play(5.5)
        assert.same({'Call Wyvern'}, gs:actions())
    end)

    it('are nothing out of combat', function()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('are Berserk with a wyvern out and a sub job of WAR', function()
        gs:give_pet({name = 'Wyvern'})
        gs:monster_hits()
        gs:play(5.5)
        assert.same({'Berserk'}, gs:actions())
    end)

    it('are Aggressor once Berserk is up', function()
        gs:give_pet({name = 'Wyvern'})
        gs:monster_hits()
        gs:gain_buff('Berserk')
        gs:traffic()
        gs:play(5.5)
        assert.same({'Aggressor'}, gs:actions())
    end)

    it('are Berserk, and not Call Wyvern, when Call Wyvern is on recast', function()
        gs.game:start_ability_recast('Call Wyvern', 60)
        gs:monster_hits()
        gs:play(5.5)
        assert.same({'Berserk'}, gs:actions())
    end)

    it('are nothing under SJ Restriction once the wyvern is out', function()
        gs:give_pet({name = 'Wyvern'})
        gs:gain_buff('SJ Restriction')
        gs:monster_hits()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('are Call Wyvern even under SJ Restriction', function()
        gs:gain_buff('SJ Restriction')
        gs:monster_hits()
        gs:play(5.5)
        assert.same({'Call Wyvern'}, gs:actions())
    end)

    it('are nothing with AutoBuffMode off', function()
        gs:console('gs c set AutoBuffMode Off')
        gs:monster_hits()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)
end)

describe('DRG\'s buffs kept by the tick with a sub job of DRK', function()
    it('are Last Resort once the wyvern is out', function()
        local gs = boot({sub_job = 'DRK'})
        gs:console('gs c set AutoBuffMode Auto')
        gs:console('gs c set Stance None')
        gs:give_pet({name = 'Wyvern'})
        gs:monster_hits()
        gs:play(5.5)
        assert.same({'Last Resort'}, gs:actions())
    end)
end)
