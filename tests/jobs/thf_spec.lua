local jobby = require('jobby')

local gear = {'Volte Cap', 'Null Masque', 'Volte Jupon', 'Adamantite Armor', 'Volte Bracers', 'Volte Hose',
    'Volte Boots', 'Fotia Gorget', "Combatant's Torque", 'Null Belt', 'Fotia Belt', 'Moonshade Earring',
    'Brutal Earring', 'Cessance Earring', 'Odnowa Earring +1', 'Karieyh Ring', 'Chirich Ring +1', 'Null Shawl'}

local function boot(options)
    options = options or {}
    options.items = gear
    options.sub_job = options.sub_job or 'WAR'
    return jobby.boot('THF', options)
end

local function boot_ticking(options)
    options = options or {}
    options.items = gear
    options.sub_job = options.sub_job or 'WAR'
    return jobby.boot_ticking('THF', options)
end

-- What the idle set of Jobby's thief gear file wears, as the game shows it worn, with his dagger in hand.
local idle = jobby.worn_by(jobby.full_idle, jobby.weapons.THF)

local th = {head = 'Null Masque', waist = 'Null Belt'}

-- What is worn with the idle set on and the engaged set over it.
local function engaged_with(changes)
    local set = {head = 'Volte Cap', body = 'Volte Jupon', neck = 'Loricate Torque +1'}
    for slot, item in pairs(changes or {}) do
        set[slot] = item
    end
    return jobby.worn_by(idle, set)
end

-- The monster has been hit before, so Sel puts no treasure hunter gear on for it.
local function tag_the_monster(gs)
    gs.user.info.tagged_mobs[gs.game.monster.id] = gs.user.os.time()
end

describe('THF\'s weapon skill filter', function()
    it('sends Savage Blade in place of Rudra\'s Storm when Jobby has a sword\'s weapon skills', function()
        local gs = boot({tp = 1000, abilities = {'Fast Blade', 'Savage Blade'}})
        gs:type('/ws "Rudra\'s Storm" <t>')
        assert.same({'Savage Blade'}, gs:actions())
    end)

    it('sends nothing in place of Rudra\'s Storm when Jobby hasn\'t Fast Blade, which the job file takes for a '
        .. 'sword', function()
        local gs = boot({tp = 1000, abilities = {'Savage Blade'}})
        gs:type('/ws "Rudra\'s Storm" <t>')
        assert.same({}, gs:traffic())
    end)

    it('lets Rudra\'s Storm go out when Jobby has it', function()
        local gs = boot({tp = 1000, abilities = {'Fast Blade', 'Savage Blade', "Rudra's Storm"}})
        gs:type('/ws "Rudra\'s Storm" <t>')
        assert.same({"Rudra's Storm"}, gs:actions())
    end)
end)

describe('THF\'s weapon skill set by Sneak Attack and Trick Attack', function()
    local gs
    before_each(function()
        gs = boot({tp = 1000})
        gs:console('gs c set TreasureMode None')
    end)

    local function ws()
        return jobby.weaponskill(gs, '/ws "Rudra\'s Storm" <t>')
    end

    it('is sets.precast.WS[name] with neither up', function()
        local worn = ws()
        assert.equal('Fotia Belt', worn.waist)
        assert.equal('Defending Ring', worn.left_ring)
        assert.equal('Stikini Ring +1', worn.right_ring)
    end)

    it('is its SA set under Sneak Attack', function()
        gs:gain_buff('Sneak Attack')
        local worn = ws()
        assert.equal('Karieyh Ring', worn.left_ring)
        assert.equal('Stikini Ring +1', worn.right_ring)
    end)

    it('is its TA set under Trick Attack', function()
        gs:gain_buff('Trick Attack')
        local worn = ws()
        assert.equal('Defending Ring', worn.left_ring)
        assert.equal('Karieyh Ring', worn.right_ring)
    end)

    it('is its SATA set under both', function()
        gs:gain_buff('Sneak Attack')
        gs:gain_buff('Trick Attack')
        local worn = ws()
        assert.equal('Karieyh Ring', worn.left_ring)
        assert.equal('Chirich Ring +1', worn.right_ring)
    end)

    it('is its Acc set in an accuracy offense mode', function()
        gs:console('gs c set OffenseMode Acc')
        assert.equal('Null Shawl', ws().back)
    end)

    it('is its SA set, not its Acc one, under Sneak Attack in an accuracy offense mode', function()
        gs:console('gs c set OffenseMode Acc')
        gs:gain_buff('Sneak Attack')
        local worn = ws()
        assert.equal('Karieyh Ring', worn.left_ring)
        assert.equal('Moonbeam Cape', worn.back)
    end)

    it('is sets.precast.WS under Sneak Attack, laid over the Sneak Attack set already on, for a weapon skill with none '
        .. 'of its own', function()
        -- The Sneak Attack set names the weapon skill set's neck too, so the one laid last shows.
        gs.user.sets.buff['Sneak Attack'] = {body = 'Adamantite Armor', neck = "Combatant's Torque"}
        gs:gain_buff('Sneak Attack')
        assert.equal("Combatant's Torque", gs:worn().neck)
        assert.same(jobby.worn_by(idle, {neck = 'Fotia Gorget', ear1 = 'Moonshade Earring',
            ear2 = 'Brutal Earring', body = 'Adamantite Armor'}), jobby.weaponskill(gs, '/ws "Evisceration" <t>'))
    end)
end)

-- A dagger in one hand and nothing in the other is fencing, and the sub job Warrior gives the first tier of Fencer,
-- 200 TP.
describe('THF\'s Moonshade swap at the cap', function()
    local function ear_after(tp, setup)
        local gs = boot({tp = tp})
        gs:console('gs c set TreasureMode None')
        if setup then
            setup(gs)
        end
        return jobby.weaponskill(gs, '/ws "Rudra\'s Storm" <t>').left_ear
    end

    it('keeps Moonshade Earring on at 2750 TP, which Moonshade and Fencer make 3200', function()
        assert.equal('Moonshade Earring', ear_after(2750))
    end)

    it('swaps in sets.MaxTP over 3200 TP counting Moonshade\'s 250 and Fencer\'s 200', function()
        assert.equal('Cessance Earring', ear_after(2751))
    end)

    it('swaps in sets.AccMaxTP in an accuracy offense mode', function()
        assert.equal('Odnowa Earring +1', ear_after(3000, function(gs) gs:console('gs c set OffenseMode Acc') end))
    end)

    it('swaps in sets.MaxTP, not sets.AccMaxTP, under Sneak Attack in an accuracy offense mode', function()
        assert.equal('Cessance Earring', ear_after(3000, function(gs)
            gs:console('gs c set OffenseMode Acc')
            gs:gain_buff('Sneak Attack')
        end))
    end)

    it('swaps in sets.MaxTP, not sets.AccMaxTP, under Trick Attack in an accuracy offense mode', function()
        assert.equal('Cessance Earring', ear_after(3000, function(gs)
            gs:console('gs c set OffenseMode Acc')
            gs:gain_buff('Trick Attack')
        end))
    end)
end)

describe('THF\'s treasure hunter gear for a weapon skill', function()
    local function ws(mode, line, tp)
        local gs = boot({tp = tp or 1000})
        tag_the_monster(gs)
        gs:console('gs c set TreasureMode ' .. mode)
        return jobby.weaponskill(gs, line)
    end

    it('goes over Aeolian Edge in the Tag mode, on a monster already hit', function()
        local worn = ws('Tag', '/ws "Aeolian Edge" <t>')
        assert.equal('Null Masque', worn.head)
        assert.equal('Null Belt', worn.waist)
    end)

    it('goes over Cyclone in the Tag mode, on a monster already hit', function()
        local worn = ws('Tag', '/ws "Cyclone" <t>')
        assert.equal('Null Masque', worn.head)
        assert.equal('Null Belt', worn.waist)
    end)

    it('stays off Aeolian Edge in the None mode', function()
        local worn = ws('None', '/ws "Aeolian Edge" <t>')
        assert.equal('Nyame Helm', worn.head)
        assert.equal('Fotia Belt', worn.waist)
    end)

    it('stays off another weapon skill in the Tag mode, on a monster already hit', function()
        local worn = ws('Tag', '/ws "Rudra\'s Storm" <t>')
        assert.equal('Nyame Helm', worn.head)
        assert.equal('Fotia Belt', worn.waist)
    end)

    it('goes over any weapon skill in the SATA mode', function()
        local worn = ws('SATA', '/ws "Rudra\'s Storm" <t>')
        assert.equal('Null Masque', worn.head)
        assert.equal('Null Belt', worn.waist)
    end)

    it('goes over any weapon skill in the Fulltime mode', function()
        local worn = ws('Fulltime', '/ws "Rudra\'s Storm" <t>')
        assert.equal('Null Masque', worn.head)
        assert.equal('Null Belt', worn.waist)
    end)

    it('goes over Aeolian Edge instead of its Moonshade swap, which is left out', function()
        local worn = ws('Tag', '/ws "Aeolian Edge" <t>', 3000)
        assert.equal('Moonshade Earring', worn.left_ear)
    end)
end)

describe('THF\'s treasure hunter gear for Sneak Attack and Trick Attack', function()
    local function ja(mode, name)
        local gs = boot()
        tag_the_monster(gs)
        gs:console('gs c set TreasureMode ' .. mode)
        gs:type('/ja "' .. name .. '" <me>')
        return gs:worn()
    end

    it('goes over Sneak Attack in the SATA mode', function()
        local worn = ja('SATA', 'Sneak Attack')
        assert.equal('Null Masque', worn.head)
        assert.equal('Chirich Ring +1', worn.left_ring)
    end)

    it('goes over Trick Attack in the Fulltime mode', function()
        assert.equal('Null Masque', ja('Fulltime', 'Trick Attack').head)
    end)

    it('stays off Sneak Attack in the Tag mode', function()
        local worn = ja('Tag', 'Sneak Attack')
        assert.equal('Nyame Helm', worn.head)
        assert.equal('Chirich Ring +1', worn.left_ring)
    end)
end)

describe('THF\'s ranged attack', function()
    it('wears the treasure hunter set at midcast in the Tag mode, on a monster already hit', function()
        local gs = boot()
        tag_the_monster(gs)
        gs:type('/ra <t>')
        assert.same({{action = 'category 16', target = 'Apex Toad'}, {equip = th}}, gs:traffic())
        assert.same(jobby.worn_by(idle, th), gs:worn())
    end)

    it('wears no treasure hunter set in the None mode', function()
        local gs = boot()
        gs:console('gs c set TreasureMode None')
        gs:type('/ra <t>')
        assert.same(jobby.worn_by(idle), gs:worn())
    end)
end)

describe('THF\'s Ambush Mode', function()
    local function ambush_ws(setup)
        local gs = boot({tp = 1000})
        gs:console('gs c toggle AmbushMode')
        if setup then
            setup(gs)
        end
        return jobby.weaponskill(gs, '/ws "Rudra\'s Storm" <t>')
    end

    it('puts sets.Ambush on for a weapon skill', function()
        assert.equal('Volte Boots', ambush_ws().feet)
    end)

    it('puts no sets.Ambush on for a weapon skill under Sneak Attack', function()
        assert.equal('Nyame Sollerets', ambush_ws(function(gs) gs:gain_buff('Sneak Attack') end).feet)
    end)

    it('puts no sets.Ambush on for a weapon skill under Trick Attack', function()
        assert.equal('Nyame Sollerets', ambush_ws(function(gs) gs:gain_buff('Trick Attack') end).feet)
    end)

    it('puts no sets.Ambush on for a weapon skill with the mode off', function()
        local gs = boot({tp = 1000})
        assert.equal('Nyame Sollerets', jobby.weaponskill(gs, '/ws "Rudra\'s Storm" <t>').feet)
    end)

    it('lays sets.Ambush over the melee set', function()
        local gs = boot()
        gs:console('gs c toggle AmbushMode')
        gs:engage()
        assert.equal('Volte Boots', gs:worn().feet)
    end)

    pending('is left off by a gear file that doesn\'t define it: data/THF.lua never defines state.AmbushMode, but '
        .. 'reads it in job_post_precast and job_customize_melee_set, so a weapon skill or engaging raises a Lua error')
end)

describe('THF\'s melee set', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set TreasureMode None')
        gs:engage()
    end)

    it('is sets.engaged', function()
        assert.same(engaged_with({}), gs:worn())
    end)

    it('has the treasure hunter set laid over it in the Fulltime mode, on a monster already hit', function()
        tag_the_monster(gs)
        gs:console('gs c set TreasureMode Fulltime')
        assert.same(engaged_with(th), gs:worn())
    end)

    it('has no treasure hunter set laid over it in the SATA mode, on a monster already hit', function()
        tag_the_monster(gs)
        gs:console('gs c set TreasureMode SATA')
        assert.same(engaged_with({}), gs:worn())
    end)
end)

describe('THF\'s Sneak Attack and Trick Attack gear', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set TreasureMode None')
        gs:engage()
    end)

    it('is sets.buff[\'Sneak Attack\'] over the engaged set while Sneak Attack is up', function()
        gs:gain_buff('Sneak Attack')
        assert.same(engaged_with({body = 'Adamantite Armor'}), gs:worn())
    end)

    it('is sets.buff[\'Trick Attack\'] over the engaged set while Trick Attack is up', function()
        gs:gain_buff('Trick Attack')
        assert.same(engaged_with({hands = 'Volte Bracers'}), gs:worn())
    end)

    it('is both over the engaged set with both up', function()
        gs:gain_buff('Sneak Attack')
        gs:gain_buff('Trick Attack')
        assert.same(engaged_with({body = 'Adamantite Armor', hands = 'Volte Bracers'}), gs:worn())
    end)

    it('is on out of combat too, over the idle set', function()
        gs:disengage()
        gs:gain_buff('Sneak Attack')
        assert.same(jobby.worn_by(idle, {body = 'Adamantite Armor'}), gs:worn())
    end)

    it('keeps the engaged set from changing while Sneak Attack is up', function()
        gs:gain_buff('Sneak Attack')
        gs:console('gs c set OffenseMode Acc')
        assert.equal('Loricate Torque +1', gs:worn().neck)
    end)

    it('lets the engaged set change again once Sneak Attack is gone', function()
        gs:gain_buff('Sneak Attack')
        gs:console('gs c set OffenseMode Acc')
        gs:lose_buff('Sneak Attack')
        assert.equal('Fotia Gorget', gs:worn().neck)
    end)

    it('has the treasure hunter set over it in the SATA mode, on a monster already hit', function()
        tag_the_monster(gs)
        gs:console('gs c set TreasureMode SATA')
        gs:gain_buff('Sneak Attack')
        assert.same(engaged_with({body = 'Adamantite Armor', head = 'Null Masque', waist = 'Null Belt'}), gs:worn())
    end)

    it('has no treasure hunter set over it in the Tag mode, on a monster already hit', function()
        tag_the_monster(gs)
        gs:console('gs c set TreasureMode Tag')
        gs:gain_buff('Sneak Attack')
        assert.equal('Volte Cap', gs:worn().head)
    end)

    it('is gone from the states once a weapon skill has gone out', function()
        gs:set_tp(1000)
        gs:gain_buff('Sneak Attack')
        gs:gain_buff('Trick Attack')
        gs:gain_buff('Feint')
        gs:type('/ws "Rudra\'s Storm" <t>')
        gs:finish_action()
        assert.is_false(gs.user.state.Buff['Sneak Attack'])
        assert.is_false(gs.user.state.Buff['Trick Attack'])
        assert.is_false(gs.user.state.Buff['Feint'])
    end)

    it('is off again once a weapon skill has gone out, the engaged set coming back', function()
        gs:set_tp(1000)
        gs:gain_buff('Sneak Attack')
        gs:type('/ws "Rudra\'s Storm" <t>')
        gs:finish_action()
        assert.equal('Volte Jupon', gs:worn().body)
    end)

    it('is kept in the states when the weapon skill is interrupted', function()
        gs:set_tp(1000)
        gs:gain_buff('Sneak Attack')
        gs:type('/ws "Rudra\'s Storm" <t>')
        gs:interrupt_action()
        assert.is_true(gs.user.state.Buff['Sneak Attack'])
    end)
end)

describe('THF\'s Feint gear', function()
    it('is sets.buff.Feint laid over what is on after an ability, Feint being up', function()
        local gs = boot()
        gs:console('gs c set TreasureMode None')
        gs:gain_buff('Feint')
        gs:type('/ja "Provoke" <t>')
        gs:finish_action()
        assert.same(jobby.worn_by(idle, {legs = 'Volte Hose'}), gs:worn())
    end)

    it('is not worn after an ability without Feint', function()
        local gs = boot()
        gs:console('gs c set TreasureMode None')
        gs:type('/ja "Provoke" <t>')
        gs:finish_action()
        assert.same(jobby.worn_by(idle), gs:worn())
    end)

    it('has the treasure hunter set over it in the SATA mode', function()
        local gs = boot()
        gs:console('gs c set TreasureMode SATA')
        gs:gain_buff('Feint')
        gs:type('/ja "Provoke" <t>')
        gs:finish_action()
        assert.same(jobby.worn_by(idle,
            {legs = 'Volte Hose', head = 'Null Masque', waist = 'Null Belt'}), gs:worn())
    end)
end)

describe('THF\'s Auto Buff Mode with Warrior as the sub job', function()
    local function buffing(sub_job)
        local gs = boot_ticking({sub_job = sub_job})
        gs:console('gs c set TreasureMode None')
        gs:console('gs c set AutoBuffMode Auto')
        gs:monster_hits()
        return gs
    end

    it('starts with Berserk in a fight', function()
        local gs = buffing('WAR')
        gs:play_until_action()
        assert.same({'Berserk'}, gs:actions())
    end)

    it('goes on to Aggressor with Berserk up', function()
        local gs = buffing('WAR')
        gs:gain_buff('Berserk')
        gs:play_until_action()
        assert.same({'Aggressor'}, gs:actions())
    end)

    it('uses nothing with both up', function()
        local gs = buffing('WAR')
        gs:gain_buff('Berserk')
        gs:gain_buff('Aggressor')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('passes over Berserk while it is on recast', function()
        local gs = buffing('WAR')
        gs.game:start_ability_recast('Berserk', 60)
        gs:play_until_action()
        assert.same({'Aggressor'}, gs:actions())
    end)

    it('uses nothing without Warrior as the sub job', function()
        local gs = buffing('WHM')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    it('uses nothing out of a fight', function()
        local gs = boot_ticking({sub_job = 'WAR'})
        gs:console('gs c set TreasureMode None')
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(3)
        assert.same({}, gs:actions())
    end)

    pending('uses nothing while the sub job\'s abilities are restricted: job_check_buff in data/THF.lua checks only '
        .. 'that the sub job is Warrior, so it tries Berserk under SJ Restriction')
end)

describe('THF\'s status line', function()
    local function status(setup)
        local gs = boot()
        if setup then
            setup(gs)
        end
        gs:chat()
        gs:console('gs c update user')
        return gs:chat()
    end

    it('says the melee modes, the weapon skill mode and the treasure mode', function()
        assert.same({'Melee: Normal, WS: Match, TH: Tag'}, status())
    end)

    it('names the hybrid mode and the treasure mode in use', function()
        assert.same({'Melee: Acc/DT, WS: Normal, TH: SATA'}, status(function(gs)
            gs:console('gs c set OffenseMode Acc')
            gs:console('gs c set HybridMode DT')
            gs:console('gs c set WeaponskillMode Normal')
            gs:console('gs c set TreasureMode SATA')
        end))
    end)

    it('names the defense mode', function()
        assert.same({'Melee: Normal, WS: Match, Defense: Physical (PDT), TH: Tag'}, status(function(gs)
            gs:console('gs c set DefenseMode Physical')
        end))
    end)

    it('says when kiting is on', function()
        assert.same({'Melee: Normal, WS: Match, Kiting, TH: Tag'}, status(function(gs)
            gs:console('gs c toggle Kiting')
        end))
    end)

    it('names the combat form, which a weapon set with an engaged set of its name gives', function()
        assert.same({'Melee (Knife): Normal, WS: Match, TH: Tag'}, status(function(gs)
            gs:console('gs c set Weapons Knife')
        end))
    end)

    it('names the player targeting mode', function()
        assert.same({'Melee: Normal, WS: Match, Target PC: stpt, TH: Tag'}, status(function(gs)
            gs:console('gs c set PCTargetMode stpt')
        end))
    end)

    it('says when non-player characters are targeted', function()
        assert.same({'Melee: Normal, WS: Match, Target NPCs, TH: Tag'}, status(function(gs)
            gs:console('gs c toggle SelectNPCTargets')
        end))
    end)
end)

describe('THF\'s buff states', function()
    it('follow the buffs as they come and go', function()
        local gs = boot()
        gs:gain_buff('Trick Attack')
        assert.is_true(gs.user.state.Buff['Trick Attack'])
        gs:lose_buff('Trick Attack')
        assert.is_false(gs.user.state.Buff['Trick Attack'])
    end)
end)
