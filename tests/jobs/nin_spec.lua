local jobby = require('jobby')

local gear = {"Judge's Sword", 'Mecisto. Mantle', "Bendis's Hairpin", "Theia's Hairpin", 'Sapphire Platemail',
    'Jadeite Cuirie', 'Volte Jupon', 'Jadeite Chausses', 'Sapphire Gauntlets', 'Jadeite Gloves', 'Sapphire Trousers',
    'Diamond Haramaki', 'Diamond Kote', 'Diamond Sune-Ate', "Orunmila's Torque"}

local tools = {'Inoshishinofuda', 'Shikanofuda', 'Chonofuda'}

-- What the idle set of Jobby's ninja gear file wears besides every gear file's.
local own_idle = {main = "Judge's Sword", back = 'Mecisto. Mantle'}

local idle = jobby.worn_by(own_idle)

-- What is worn with these changes over the idle set.
local function worn(changes)
    return jobby.worn_by(changes, idle)
end

-- The boot options of Jobby as a ninja with the idle set on, over a sub job of WAR unless the options say otherwise.
-- options are jobby.boot's, and tools: the ninja tools Jobby has, as jobby.boot's items, the universal ones of each
-- kind in the inventory unless given.
local function boot_options(options)
    options = options or {}
    local items = {}
    for _, name in ipairs(gear) do
        items[#items + 1] = name
    end
    for _, item in ipairs(options.tools or tools) do
        items[#items + 1] = item
    end
    options.tools = nil
    options.items = items
    options.wearing = own_idle
    options.sub_job = options.sub_job or 'WAR'
    return options
end

local function boot(options)
    return jobby.boot('NIN', boot_options(options))
end

local function boot_ticking(options)
    return jobby.boot_ticking('NIN', boot_options(options))
end

describe('data/NIN.lua', function()
    it('takes Innin as the stance and Fire as the element', function()
        local gs = boot()
        assert.equal('Innin', gs.user.state.Stance.value)
        assert.equal('Fire', gs.user.state.ElementalMode.value)
    end)
end)

describe('NIN\'s ninjutsu', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('takes sets.midcast.Utsusemi for an Utsusemi, over sets.precast.FC.Utsusemi', function()
        gs:type('/ma "Utsusemi: Ni" <me>')
        assert.same(worn({head = "Theia's Hairpin", hands = 'Sapphire Gauntlets'}), gs:worn())
    end)

    it('takes sets.midcast.ElementalNinjutsu for an elemental ninjutsu', function()
        gs:type('/ma "Katon: Ni" <t>')
        assert.same(worn({head = "Bendis's Hairpin", hands = 'Jadeite Gloves'}), gs:worn())
    end)

    it('takes sets.midcast.NinjutsuBuff for a ninjutsu on itself that has no spell map of Sel\'s', function()
        gs:type('/ma "Kakka: Ichi" <me>')
        assert.same(worn({head = "Bendis's Hairpin", hands = 'Diamond Kote'}), gs:worn())
    end)

    it('takes sets.midcast.NinjutsuDebuff for a ninjutsu on a monster that has no spell map of Sel\'s', function()
        gs:type('/ma "Hojo: Ichi" <t>')
        assert.same(worn({head = "Bendis's Hairpin", legs = 'Sapphire Trousers'}), gs:worn())
    end)
end)

describe('NIN\'s elemental ninjutsu with Futae', function()
    local gs
    before_each(function()
        gs = boot()
        gs:gain_buff('Futae')
    end)

    it('has sets.buff.Futae over the midcast set', function()
        gs:type('/ma "Katon: Ni" <t>')
        assert.same(worn({head = "Bendis's Hairpin", hands = 'Jadeite Gloves', feet = 'Diamond Sune-Ate'}), gs:worn())
    end)

    it('has no sets.buff.Futae over it in the Proc casting mode', function()
        gs:console('gs c set CastingMode Proc')
        gs:type('/ma "Katon: Ni" <t>')
        assert.same(worn({head = "Bendis's Hairpin", hands = 'Jadeite Gloves'}), gs:worn())
    end)

    it('has no sets.buff.Futae over a ninjutsu that isn\'t elemental', function()
        gs:type('/ma "Hojo: Ichi" <t>')
        assert.same(worn({head = "Bendis's Hairpin", legs = 'Sapphire Trousers'}), gs:worn())
    end)
end)

describe('NIN\'s Migawari: Ichi', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('puts sets.buff.Migawari on the idle set once it is cast, before the buff itself shows', function()
        gs:type('/ma "Migawari: Ichi" <me>')
        gs:finish_action()
        assert.same(worn({neck = "Orunmila's Torque"}), gs:worn())
    end)

    it('puts nothing on when it was interrupted', function()
        gs:type('/ma "Migawari: Ichi" <me>')
        gs:interrupt_action()
        assert.same(worn(), gs:worn())
    end)

    it('puts sets.buff.Migawari on the engaged set once it is cast, which leaves the spell\'s hands where they are', function()
        gs:engage()
        gs:type('/ma "Migawari: Ichi" <me>')
        gs:finish_action()
        assert.same(worn({head = "Bendis's Hairpin", body = 'Sapphire Platemail', hands = 'Diamond Kote',
            neck = "Orunmila's Torque"}), gs:worn())
    end)

    it('takes sets.buff.Migawari off again when the buff wears off', function()
        gs:type('/ma "Migawari: Ichi" <me>')
        gs:finish_action()
        gs:gain_buff('Migawari')
        gs:lose_buff('Migawari')
        assert.same(worn(), gs:worn())
    end)
end)

describe('NIN\'s Migawari buff', function()
    local gs
    before_each(function()
        gs = boot()
        gs:gain_buff('Migawari')
    end)

    it('has sets.buff.Migawari over the idle set', function()
        assert.same(worn({neck = "Orunmila's Torque"}), gs:worn())
    end)

    it('has sets.buff.Migawari over the engaged set', function()
        gs:engage()
        assert.same(worn({head = "Bendis's Hairpin", body = 'Sapphire Platemail', neck = "Orunmila's Torque"}), gs:worn())
    end)
end)

describe('NIN\'s engaged set', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    local function engaged_with(changes)
        local set = {head = "Bendis's Hairpin", body = 'Sapphire Platemail'}
        for slot, item in pairs(changes or {}) do
            set[slot] = item
        end
        return worn(set)
    end

    it('has Yonin\'s set over it while Yonin is up', function()
        gs:gain_buff('Yonin')
        gs:engage()
        assert.same(engaged_with({body = 'Diamond Haramaki'}), gs:worn())
    end)

    it('has Innin\'s set over it while Innin is up', function()
        gs:gain_buff('Innin')
        gs:engage()
        assert.same(engaged_with({body = 'Volte Jupon'}), gs:worn())
    end)

    it('has Innin\'s set over it in the Fodder offense mode', function()
        gs:console('gs c set OffenseMode Fodder')
        gs:gain_buff('Innin')
        gs:engage()
        assert.same(engaged_with({body = 'Volte Jupon'}), gs:worn())
    end)

    it('has Yonin\'s set rather than Innin\'s with both up', function()
        gs:gain_buff('Innin')
        gs:gain_buff('Yonin')
        gs:engage()
        assert.same(engaged_with({body = 'Diamond Haramaki'}), gs:worn())
    end)

    it('goes without Innin\'s set in an accuracy mode', function()
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Innin')
        gs:engage()
        assert.same(engaged_with({body = 'Jadeite Cuirie'}), gs:worn())
    end)

    it('goes without Innin\'s set under a defense mode', function()
        gs:console('gs c set DefenseMode Physical')
        gs:gain_buff('Innin')
        gs:engage()
        assert.same(engaged_with({legs = 'Jadeite Chausses'}), gs:worn())
    end)

    it('goes without Yonin\'s set under a defense mode', function()
        gs:console('gs c set DefenseMode Physical')
        gs:gain_buff('Yonin')
        gs:engage()
        assert.same(engaged_with({legs = 'Jadeite Chausses'}), gs:worn())
    end)
end)

describe('NIN\'s stance, kept by the tick', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('puts Innin up in combat', function()
        gs:monster_hits()
        gs:play(5.5)
        assert.same({'Innin'}, gs:actions())
    end)

    it('puts nothing up out of combat', function()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('puts Yonin up in combat in the Yonin stance', function()
        gs:console('gs c set Stance Yonin')
        gs:monster_hits()
        gs:play(5.5)
        assert.same({'Yonin'}, gs:actions())
    end)

    it('puts nothing up in the None stance', function()
        gs:console('gs c set Stance None')
        gs:monster_hits()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('waits with Yonin up in the Innin stance', function()
        gs:monster_hits()
        gs:gain_buff('Yonin')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('waits with Innin up in the Yonin stance', function()
        gs:console('gs c set Stance Yonin')
        gs:monster_hits()
        gs:gain_buff('Innin')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('waits while Innin is on recast, without trying it', function()
        gs:monster_hits()
        gs.game:start_ability_recast('Innin', 30)
        gs:play(5.5)
        assert.same({}, gs:actions())
        assert.same({}, jobby.refusals(gs))
    end)

    it('waits while Yonin is on recast in the Yonin stance, without trying it', function()
        gs:console('gs c set Stance Yonin')
        gs:monster_hits()
        gs.game:start_ability_recast('Yonin', 30)
        gs:play(5.5)
        assert.same({}, gs:actions())
        assert.same({}, jobby.refusals(gs))
    end)
end)

describe('NIN\'s buffs kept by the tick', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set Stance None')
        gs:console('gs c set AutoBuffMode Auto')
    end)

    it('are Migawari first in combat', function()
        gs:monster_hits()
        gs:play(5.5)
        assert.same({'Migawari: Ichi'}, gs:actions())
    end)

    it('are Berserk next with a sub job of WAR', function()
        gs:monster_hits()
        gs:gain_buff('Migawari')
        gs:traffic()
        gs:play(5.5)
        assert.same({'Berserk'}, gs:actions())
    end)

    it('are Berserk when Migawari is on recast', function()
        gs:monster_hits()
        gs.game:start_spell_recast('Migawari: Ichi', 60)
        gs:play(5.5)
        assert.same({'Berserk'}, gs:actions())
    end)

    it('are Aggressor once Berserk is up', function()
        gs:monster_hits()
        gs:gain_buff('Migawari')
        gs:gain_buff('Berserk')
        gs:traffic()
        gs:play(5.5)
        assert.same({'Aggressor'}, gs:actions())
    end)

    it('are nothing once Migawari, Berserk and Aggressor are up', function()
        gs:monster_hits()
        gs:gain_buff('Migawari')
        gs:gain_buff('Berserk')
        gs:gain_buff('Aggressor')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('are no Berserk or Aggressor under a defense mode', function()
        gs:monster_hits()
        gs:gain_buff('Migawari')
        gs:console('gs c set DefenseMode Physical')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('are no Berserk or Aggressor in a defensive hybrid mode', function()
        gs:monster_hits()
        gs:gain_buff('Migawari')
        gs:console('gs c set HybridMode DT')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('are no Berserk or Aggressor under SJ Restriction', function()
        gs:monster_hits()
        gs:gain_buff('Migawari')
        gs:gain_buff('SJ Restriction')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('are nothing with AutoBuffMode off', function()
        gs:monster_hits()
        gs:console('gs c set AutoBuffMode Off')
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('are nothing out of combat', function()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)
end)

describe('NIN\'s buffup', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c buffup')
    end)

    it('is Myoshu first, with the tick', function()
        gs:play(5.5)
        assert.same({'Myoshu: Ichi'}, gs:actions())
    end)

    it('is Kakka once Myoshu is up', function()
        gs:gain_buff('Subtle Blow Plus')
        gs:traffic()
        gs:play(5.5)
        assert.same({'Kakka: Ichi'}, gs:actions())
    end)

    it('is done once both are up, which is said', function()
        gs = boot_ticking({buffs = {'Subtle Blow Plus', 'Store TP'}})
        gs:console('gs c buffup')
        gs:play(1)
        assert.same({}, gs:actions())
        assert.same({'All Default buffs are up!'}, gs:chat())
    end)
end)

describe('NIN\'s shadows kept by AutoShadowMode', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set Stance None')
        gs:console('gs c toggle AutoShadowMode')
    end)

    it('are Utsusemi: San first with none up', function()
        gs:play(5.5)
        assert.same({'Utsusemi: San'}, gs:actions())
    end)

    it('are Utsusemi: San with two up', function()
        gs:gain_buff('Copy Image (2)')
        gs:traffic()
        gs:play(5.5)
        assert.same({'Utsusemi: San'}, gs:actions())
    end)

    it('are nothing with three up', function()
        gs:gain_buff('Copy Image (3)')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('are Utsusemi: Ni when San is on recast', function()
        gs.game:start_spell_recast('Utsusemi: San', 60)
        gs:play(5.5)
        assert.same({'Utsusemi: Ni'}, gs:actions())
    end)

    it('are Utsusemi: Ichi when San and Ni are on recast', function()
        gs.game:start_spell_recast('Utsusemi: San', 60)
        gs.game:start_spell_recast('Utsusemi: Ni', 60)
        gs:play(5.5)
        assert.same({'Utsusemi: Ichi'}, gs:actions())
    end)

    it('are nothing, nor tried, when all three are on recast', function()
        gs.game:start_spell_recast('Utsusemi: San', 60)
        gs.game:start_spell_recast('Utsusemi: Ni', 60)
        gs.game:start_spell_recast('Utsusemi: Ichi', 60)
        gs:play(5.5)
        assert.same({}, gs:actions())
        assert.same({}, jobby.refusals(gs))
    end)

    it('are nothing with two up and San on recast, as Ni waits for fewer than two', function()
        gs.game:start_spell_recast('Utsusemi: San', 60)
        gs:gain_buff('Copy Image (2)')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('are nothing with AutoShadowMode off', function()
        gs:console('gs c toggle AutoShadowMode')
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)
end)

describe('NIN\'s Utsusemi', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('cancels the shadows left 0.1 seconds after Utsusemi: Ni goes out', function()
        gs:type('/ma "Utsusemi: Ni" <me>')
        assert.same({'Utsusemi: Ni'}, gs:actions())
        assert.same({}, gs:commands())
        gs:advance(0.1)
        assert.same({'cancel copy image*'}, gs:commands())
    end)

    it('cancels the shadows left 0.5 seconds after Utsusemi: Ichi goes out', function()
        gs:type('/ma "Utsusemi: Ichi" <me>')
        gs:advance(0.4)
        assert.same({}, gs:commands())
        gs:advance(0.1)
        assert.same({'cancel copy image*'}, gs:commands())
    end)

    it('is not cast over four or more shadows', function()
        gs:gain_buff('Copy Image (4+)')
        gs:traffic()
        gs:chat()
        gs:type('/ma "Utsusemi: Ni" <me>')
        assert.same({}, gs:actions())
        assert.same({'Abort: You have four or more shadows.'}, gs:chat())
    end)

    it('is cast over three shadows as Utsusemi: Ni', function()
        gs:gain_buff('Copy Image (3)')
        gs:traffic()
        gs:type('/ma "Utsusemi: Ni" <me>')
        assert.same({'Utsusemi: Ni'}, gs:actions())
    end)

    it('is not cast over three shadows as Utsusemi: Ichi', function()
        gs:gain_buff('Copy Image (3)')
        gs:traffic()
        gs:chat()
        gs:type('/ma "Utsusemi: Ichi" <me>')
        assert.same({}, gs:actions())
        assert.same({'Abort: You have three or more shadows.'}, gs:chat())
    end)
end)

describe('NIN\'s elemental commands', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('nuke with the highest tier of the element that is ready, at the target', function()
        gs:console('gs c elemental nuke')
        assert.same({{action = 'Katon: San', target = 'Apex Toad'}}, gs:action_entries())
    end)

    it('nuke with the next tier down when the highest is on recast', function()
        gs.game:start_spell_recast('Katon: San', 60)
        gs:console('gs c elemental nuke')
        assert.same({'Katon: Ni'}, gs:actions())
    end)

    it('nuke with the lowest tier when the others are on recast', function()
        gs.game:start_spell_recast('Katon: San', 60)
        gs.game:start_spell_recast('Katon: Ni', 60)
        gs:console('gs c elemental nuke')
        assert.same({'Katon: Ichi'}, gs:actions())
    end)

    it('nuke with nothing, and say so, when every tier is on recast', function()
        gs.game:start_spell_recast('Katon: San', 60)
        gs.game:start_spell_recast('Katon: Ni', 60)
        gs.game:start_spell_recast('Katon: Ichi', 60)
        gs:console('gs c elemental nuke')
        assert.same({}, gs:actions())
        assert.same({'Abort: All Fire nukes on cooldown.'}, gs:chat())
    end)

    it('nuke with the element chosen', function()
        gs:console('gs c set ElementalMode Ice')
        gs:console('gs c elemental nuke')
        assert.same({'Hyoton: San'}, gs:actions())
    end)

    pending('with a tier named cast that tier, as handle_job_elemental in data/NIN.lua means to: it compares the '
        .. 'command, which Sel has lowered, with San, Ni and Ichi')

    it('with proc cast the second tier', function()
        gs:console('gs c elemental proc')
        assert.same({'Katon: Ni'}, gs:actions())
    end)
end)

describe('NIN\'s Mijin Gakure', function()
    pending('has Nagi in hand while it is used, and the weapons back afterwards, as job_precast and job_aftercast in '
        .. 'data/NIN.lua mean: both test not state.Weapons.value == \'None\', which Lua reads as (not state.Weapons.value) '
        .. '== \'None\', always false')
end)

describe('NIN\'s ninja tools', function()
    it('are the universal ones in the inventory for a ninjutsu', function()
        local gs = boot()
        gs:type('/ma "Utsusemi: Ni" <me>')
        assert.same({'Utsusemi: Ni'}, gs:actions())
    end)

    it('are missing, and the cast stops with a word of it, when Jobby has none', function()
        local gs = boot({tools = {'Inoshishinofuda', 'Chonofuda'}})
        gs:type('/ma "Utsusemi: Ni" <me>')
        assert.same({}, gs:actions())
        assert.same({"Abort: You don't have the proper ninja tool available."}, gs:chat())
    end)

    it('are fetched from the satchel, when that is where the universal ones are', function()
        local gs = boot({tools = {'Inoshishinofuda', 'Chonofuda', {name = 'Shikanofuda', bag = 'satchel'}}})
        gs:type('/ma "Utsusemi: Ni" <me>')
        assert.same({}, gs:actions())
        assert.same({'get "Shikanofuda" satchel 99'}, gs:commands())
    end)
end)
