local jobby = require('jobby')

local gear = {'Volte Cap', 'Null Masque', 'Volte Jupon', 'Adamantite Armor', 'Volte Bracers', 'Volte Hose',
    'Volte Boots', 'Fotia Gorget', "Combatant's Torque", 'Null Belt', 'Fotia Belt', 'Moonshade Earring',
    'Brutal Earring', 'Cessance Earring', 'Odnowa Earring +1', 'Karieyh Ring', 'Null Shawl'}

local function boot(options)
    options = options or {}
    options.items = gear
    return jobby.boot('MNK', options)
end

local function boot_ticking(options)
    options = options or {}
    options.items = gear
    return jobby.boot_ticking('MNK', options)
end

-- Jobby in a fight with Auto Buff Mode on.
local function boot_buffing(options)
    local gs = boot_ticking(options)
    gs:console('gs c set AutoBuffMode Auto')
    gs:monster_hits()
    return gs
end

-- What is worn once the weapon skill is out.
local function weaponskill(gs, line)
    gs:type(line)
    local traffic = gs:traffic()
    assert.is_truthy(traffic[#traffic] and traffic[#traffic].action, 'the weapon skill didn\'t go out')
    return gs:worn()
end

local function engaged_with(changes)
    local set = {head = 'Volte Cap', body = 'Volte Jupon'}
    for slot, item in pairs(changes) do
        set[slot] = item
    end
    return jobby.worn_by(jobby.full_idle, set)
end

describe('MNK\'s melee set', function()
    local gs
    before_each(function()
        gs = boot()
        gs:engage()
    end)

    it('is sets.engaged', function()
        assert.same(engaged_with({}), gs:worn())
    end)

    it('has sets.buff.Impetus laid over it while Impetus is up', function()
        gs:gain_buff('Impetus')
        assert.same(engaged_with({back = 'Null Shawl'}), gs:worn())
        gs:lose_buff('Impetus')
        assert.same(engaged_with({}), gs:worn())
    end)

    it('has sets.buff.Footwork laid over sets.engaged.Footwork while Footwork is up', function()
        gs:gain_buff('Footwork')
        assert.same(engaged_with({waist = 'Null Belt', feet = 'Volte Boots'}), gs:worn())
    end)

    it('has sets.buff.Boost laid over it while Boost is up', function()
        gs:gain_buff('Boost')
        assert.same(engaged_with({ring1 = 'Karieyh Ring'}), gs:worn())
    end)

    it('has all three buff sets laid over it with all three up', function()
        gs:gain_buff('Impetus')
        gs:gain_buff('Footwork')
        gs:gain_buff('Boost')
        assert.same(engaged_with({back = 'Null Shawl', waist = 'Null Belt', feet = 'Volte Boots',
            ring1 = 'Karieyh Ring'}), gs:worn())
    end)

    it('leaves the Impetus and Footwork sets off in the FullAcc offense mode', function()
        gs:console('gs c set OffenseMode FullAcc')
        gs:gain_buff('Impetus')
        gs:gain_buff('Footwork')
        assert.same(engaged_with({head = 'Null Masque'}), gs:worn())
    end)

    it('keeps the Boost set on in the FullAcc offense mode', function()
        gs:console('gs c set OffenseMode FullAcc')
        gs:gain_buff('Boost')
        assert.same(engaged_with({head = 'Null Masque', ring1 = 'Karieyh Ring'}), gs:worn())
    end)

    it('keeps the Impetus set on in the Acc offense mode', function()
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Impetus')
        assert.same(engaged_with({body = 'Adamantite Armor', back = 'Null Shawl'}), gs:worn())
    end)

    it('is sets.engaged.HF with Hundred Fists up', function()
        gs:gain_buff('Hundred Fists')
        assert.same(engaged_with({legs = 'Volte Hose'}), gs:worn())
    end)

    it('is sets.engaged.HF.Footwork with Hundred Fists and Footwork up', function()
        gs:gain_buff('Hundred Fists')
        gs:gain_buff('Footwork')
        assert.same(engaged_with({legs = 'Volte Hose', waist = 'Null Belt', hands = 'Volte Bracers',
            feet = 'Volte Boots'}), gs:worn())
    end)
end)

describe('MNK\'s idle set', function()
    it('has sets.buff.Boost laid over it while Boost is up', function()
        local gs = boot()
        gs:gain_buff('Boost')
        assert.same(jobby.worn_by(jobby.full_idle, {ring1 = 'Karieyh Ring'}), gs:worn())
        gs:lose_buff('Boost')
        assert.same(jobby.worn_by(jobby.full_idle), gs:worn())
    end)

    it('has no Impetus or Footwork set laid over it', function()
        local gs = boot()
        gs:gain_buff('Impetus')
        gs:gain_buff('Footwork')
        assert.same(jobby.worn_by(jobby.full_idle), gs:worn())
    end)
end)

describe('MNK\'s weapon skill set', function()
    local gs
    before_each(function()
        gs = boot({tp = 1000})
    end)

    it('is sets.precast.WS[name]', function()
        assert.same(jobby.worn_by(jobby.full_idle, {head = 'Volte Cap', neck = 'Fotia Gorget',
            ear1 = 'Moonshade Earring', ear2 = 'Brutal Earring', waist = 'Fotia Belt'}),
            weaponskill(gs, '/ws "Victory Smite" <t>'))
    end)

    it('swaps Moonshade Earring for sets.MaxTP when TP, with Moonshade\'s 250, is over 3200', function()
        gs.game.player.vitals.tp = 2951
        assert.equal('Cessance Earring', weaponskill(gs, '/ws "Victory Smite" <t>').left_ear)
    end)

    it('keeps Moonshade Earring on at 2950 TP', function()
        gs.game.player.vitals.tp = 2950
        assert.equal('Moonshade Earring', weaponskill(gs, '/ws "Victory Smite" <t>').left_ear)
    end)

    it('swaps in sets.AccMaxTP at the cap in an accuracy offense mode', function()
        gs:console('gs c set OffenseMode Acc')
        gs.game.player.vitals.tp = 3000
        local worn = weaponskill(gs, '/ws "Victory Smite" <t>')
        assert.equal('Odnowa Earring +1', worn.left_ear)
        assert.equal('Volte Jupon', worn.body)
    end)

    it('swaps in sets.MaxTP, not sets.AccMaxTP, under Sneak Attack', function()
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Sneak Attack')
        gs.game.player.vitals.tp = 3000
        assert.equal('Cessance Earring', weaponskill(gs, '/ws "Victory Smite" <t>').left_ear)
    end)

    it('has sets.buff.ImpetusWS laid over it for Victory Smite with Impetus up', function()
        gs:gain_buff('Impetus')
        assert.equal("Combatant's Torque", weaponskill(gs, '/ws "Victory Smite" <t>').neck)
    end)

    it('has sets.buff.ImpetusWS laid over it for Ascetic\'s Fury with Impetus up', function()
        gs:gain_buff('Impetus')
        assert.equal("Combatant's Torque", weaponskill(gs, '/ws "Ascetic\'s Fury" <t>').neck)
    end)

    it('has no Impetus set laid over it without Impetus', function()
        assert.equal('Fotia Gorget', weaponskill(gs, '/ws "Victory Smite" <t>').neck)
    end)

    it('has no Impetus set laid over it for another weapon skill', function()
        gs:gain_buff('Impetus')
        assert.equal('Fotia Gorget', weaponskill(gs, '/ws "Dragon Kick" <t>').neck)
    end)

    it('has sets.buff.Footwork laid over it for Dragon Kick with Footwork up, there being no sets.buff.FootworkWS', function()
        gs:gain_buff('Footwork')
        assert.equal('Volte Boots', weaponskill(gs, '/ws "Dragon Kick" <t>').feet)
    end)

    it('has sets.buff.Footwork laid over it for Tornado Kick with Footwork up', function()
        gs:gain_buff('Footwork')
        assert.equal('Volte Boots', weaponskill(gs, '/ws "Tornado Kick" <t>').feet)
    end)

    it('has no Footwork set laid over it for another weapon skill', function()
        gs:gain_buff('Footwork')
        assert.equal('Nyame Sollerets', weaponskill(gs, '/ws "Victory Smite" <t>').feet)
    end)

    -- A gear file that has no sets.buff.ImpetusWS, or has one for Footwork, which this one doesn't.
    it('has sets.buff.Impetus laid over it for Victory Smite when the gear file has no ImpetusWS set', function()
        gs.user.sets.buff.ImpetusWS = nil
        gs:gain_buff('Impetus')
        assert.equal('Null Shawl', weaponskill(gs, '/ws "Victory Smite" <t>').back)
    end)

    it('has sets.buff.FootworkWS laid over it for Dragon Kick with Footwork up when the gear file has one', function()
        gs.user.sets.buff.FootworkWS = {hands = 'Volte Bracers'}
        gs:gain_buff('Footwork')
        local worn = weaponskill(gs, '/ws "Dragon Kick" <t>')
        assert.equal('Volte Bracers', worn.hands)
        assert.equal('Nyame Sollerets', worn.feet)
    end)
end)

describe('MNK\'s defense set', function()
    it('is sets.defense.PDT over the engaged set in the Physical defense mode', function()
        local gs = boot()
        gs:engage()
        gs:console('gs c set DefenseMode Physical')
        assert.same(engaged_with({neck = "Combatant's Torque"}), gs:worn())
    end)
end)

describe('MNK\'s Boost', function()
    local function boost(gs)
        gs:type('/ja "Boost" <me>')
        return gs:worn()
    end

    it('wears sets.precast.JA.Boost and, out of combat, its OutOfCombat set', function()
        local gs = boot()
        assert.same(jobby.worn_by(jobby.full_idle, {hands = 'Volte Bracers', feet = 'Volte Boots'}), boost(gs))
    end)

    it('wears only sets.precast.JA.Boost when engaged', function()
        local gs = boot()
        gs:engage()
        local worn = boost(gs)
        assert.equal('Volte Bracers', worn.hands)
        assert.equal('Nyame Sollerets', worn.feet)
    end)

    it('wears only sets.precast.JA.Boost in a fight', function()
        local gs = boot()
        gs:monster_hits()
        local worn = boost(gs)
        assert.equal('Volte Bracers', worn.hands)
        assert.equal('Nyame Sollerets', worn.feet)
    end)
end)

describe('MNK\'s weapon skill under Auto Boost', function()
    local gs
    before_each(function()
        gs = boot({tp = 1000, sub_job = 'WAR'})
        gs:console('gs c toggle AutoBoost')
    end)

    it('is held for Warcry with a War sub job and Warcry ready', function()
        gs:type('/ws "Victory Smite" <t>')
        assert.same({'Warcry'}, gs:actions())
    end)

    it('is held for Boost when Warcry is on recast', function()
        gs.game:start_ability_recast('Warcry', 60)
        gs:type('/ws "Victory Smite" <t>')
        assert.same({'Boost'}, gs:actions())
    end)

    it('goes out when Warcry and Boost are both on recast', function()
        gs.game:start_ability_recast('Warcry', 60)
        gs.game:start_ability_recast('Boost', 60)
        gs:type('/ws "Victory Smite" <t>')
        assert.same({'Victory Smite'}, gs:actions())
    end)

    it('is held for Warcry, then Boost, then goes out', function()
        gs:type('/ws "Victory Smite" <t>')
        assert.same({'Warcry'}, gs:actions())
        gs:finish_action()
        gs.game:start_ability_recast('Warcry', 60)
        gs:advance(1.2)
        assert.same({'Boost'}, gs:actions())
        gs:finish_action()
        gs.game:start_ability_recast('Warcry', 60)
        gs.game:start_ability_recast('Boost', 60)
        gs:advance(1.2)
        assert.same({'Victory Smite'}, gs:actions())
    end)

    it('goes out at once with Auto Boost off', function()
        gs:console('gs c toggle AutoBoost')
        gs:type('/ws "Victory Smite" <t>')
        assert.same({'Victory Smite'}, gs:actions())
    end)

    it('is held for Boost, not Warcry, without a War sub job', function()
        local plain = boot({tp = 1000, sub_job = 'WHM'})
        plain:console('gs c toggle AutoBoost')
        plain:type('/ws "Victory Smite" <t>')
        assert.same({'Boost'}, plain:actions())
    end)

    it('is not held by Auto Buff Mode alone', function()
        gs:console('gs c toggle AutoBoost')
        gs:console('gs c set AutoBuffMode Auto')
        gs:type('/ws "Victory Smite" <t>')
        assert.same({'Victory Smite'}, gs:actions())
    end)

    pending('is held for Boost, not Warcry, while the sub job\'s abilities are restricted: job_precast in data/MNK.lua '
        .. 'checks only that the sub job is Warrior, so it holds the weapon skill for Warcry under SJ Restriction')
end)

describe('MNK\'s Auto Buff Mode in a fight', function()
    it('starts with Impetus', function()
        local gs = boot_buffing()
        gs:play_until_action()
        assert.same({'Impetus'}, gs:actions())
    end)

    it('goes on to Focus with Impetus up', function()
        local gs = boot_buffing()
        gs:gain_buff('Impetus')
        gs:play_until_action()
        assert.same({'Focus'}, gs:actions())
    end)

    it('uses Chakra first under 51% HP', function()
        local gs = boot_buffing()
        gs.game.player.vitals.hp, gs.game.player.vitals.hpp = 700, 50
        gs:play_until_action()
        assert.same({'Chakra'}, gs:actions())
    end)

    it('uses no Chakra at 51% HP', function()
        local gs = boot_buffing()
        gs.game.player.vitals.hp, gs.game.player.vitals.hpp = 750, 51
        gs:play_until_action()
        assert.same({'Impetus'}, gs:actions())
    end)

    it('passes over Chakra while it is on recast', function()
        local gs = boot_buffing()
        gs.game.player.vitals.hp, gs.game.player.vitals.hpp = 700, 50
        gs.game:start_ability_recast('Chakra', 30)
        gs:play_until_action()
        assert.same({'Impetus'}, gs:actions())
    end)

    it('passes over Impetus while it is on recast', function()
        local gs = boot_buffing()
        gs.game:start_ability_recast('Impetus', 30)
        gs:play_until_action()
        assert.same({'Focus'}, gs:actions())
    end)

    it('uses no Focus with Aggressor up', function()
        local gs = boot_buffing()
        gs:gain_buff('Impetus')
        gs:gain_buff('Aggressor')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('goes on to Berserk with a War sub job', function()
        local gs = boot_buffing({sub_job = 'WAR'})
        gs:gain_buff('Impetus')
        gs:gain_buff('Focus')
        gs:play_until_action()
        assert.same({'Berserk'}, gs:actions())
    end)

    it('goes on to Aggressor with a War sub job and Berserk up, Focus being on recast', function()
        local gs = boot_buffing({sub_job = 'WAR'})
        gs.game:start_ability_recast('Focus', 30)
        gs:gain_buff('Impetus')
        gs:gain_buff('Berserk')
        gs:play_until_action()
        assert.same({'Aggressor'}, gs:actions())
    end)

    it('uses nothing with a War sub job once Impetus, Focus and Berserk are up', function()
        local gs = boot_buffing({sub_job = 'WAR'})
        gs:gain_buff('Impetus')
        gs:gain_buff('Focus')
        gs:gain_buff('Berserk')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Berserk with the sub job\'s abilities restricted', function()
        local gs = boot_buffing({sub_job = 'WAR'})
        gs:gain_buff('Impetus')
        gs:gain_buff('Focus')
        gs:gain_buff('SJ Restriction')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses no Berserk without a War sub job', function()
        local gs = boot_buffing({sub_job = 'WHM'})
        gs:gain_buff('Impetus')
        gs:gain_buff('Focus')
        gs:play(3)
        assert.same({}, gs:actions())
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

describe('MNK\'s buff states', function()
    it('follow the buffs as they come and go', function()
        local gs = boot()
        gs:gain_buff('Hundred Fists')
        assert.is_true(gs.user.state.Buff['Hundred Fists'])
        gs:lose_buff('Hundred Fists')
        assert.is_false(gs.user.state.Buff['Hundred Fists'])
    end)

    it('start with Auto Boost off', function()
        local gs = boot()
        assert.is_false(gs.user.state.AutoBoost.value)
    end)
end)
