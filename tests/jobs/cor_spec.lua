local jobby = require('jobby')

local pieces = {'Volte Cap', 'Volte Jupon', 'Volte Bracers', 'Volte Hose', 'Volte Boots', 'Null Masque',
    'Adamantite Armor', 'Plumb Boots', "Orunmila's Torque", 'Weike Torque', 'Sortiarius Earring', 'Beatific Earring',
    'Choleric Earring', 'Pensee Earring', 'Moonshade Earring', 'Wanion Belt', 'Prodigious Mantle',
    'Malignance Chapeau', "Luzaf's Ring", 'Death Penalty', 'Compensator'}

local default_bullets = {['Eminent Bullet'] = 40, ['Orichalc. Bullet'] = 40, ['Living Bullet'] = 40,
    ['Animikii Bullet'] = 40}

-- Jobby as a corsair with the idle set on, a gun in hand and bullets in the inventory. The options are the boot
-- options and these besides: bullets (the count of each bullet owned, 40 of each by default), ammo (the bullet
-- worn, one of those owned, Eminent Bullet by default) and items (more pieces).
local function boot(options)
    options = options or {}
    local items = {}
    for _, name in ipairs(pieces) do
        items[#items + 1] = name
    end
    for _, item in ipairs(options.items or {}) do
        items[#items + 1] = item
    end
    for name, count in pairs(options.bullets or default_bullets) do
        if count > 0 then
            items[#items + 1] = {name = name, count = count}
        end
    end
    options.wearing = {range = 'Death Penalty', ammo = options.ammo or 'Eminent Bullet'}
    for slot, item in pairs(jobby.idle) do
        options.wearing[slot] = item
    end
    options.bullets, options.ammo, options.items = nil, nil, nil
    local gs = jobby.boot('COR', items, options)
    gs:console('gs c update')
    gs:traffic()
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

-- The console commands run so far that start with the text.
local function ran(gs, start)
    local commands = {}
    for _, command in ipairs(gs.game.commands) do
        if command:sub(1, #start) == start then
            commands[#commands + 1] = command
        end
    end
    return commands
end

local gun = {range = 'Death Penalty', ammo = 'Eminent Bullet'}

-- What is worn once the action's sets are on, with the gun and its bullet worn over the idle set.
local function worn_with(...)
    return jobby.worn_by(jobby.layer(gun, ...))
end

-- What went out since last asked: each run of equip requests, and the name of each action.
local function equips(gs)
    local sent = {}
    for _, entry in ipairs(gs:traffic()) do
        sent[#sent + 1] = entry.equip or entry.action
    end
    return sent
end

local function actions(gs)
    local names = {}
    for _, entry in ipairs(gs:traffic()) do
        names[#names + 1] = entry.action
    end
    return names
end

describe('a ranged attack', function()
    it('wears sets.precast.RA[the gun] ahead of it, then sets.midcast.RA', function()
        local gs = boot()
        gs:type('/ra <t>')
        assert.same({jobby.request(sets_of(gs).precast.RA['Death Penalty']), 'category 16',
            jobby.request(sets_of(gs).midcast.RA)}, equips(gs))
    end)

    it('wears sets.midcast.RA.Acc in the Acc ranged mode', function()
        local gs = boot()
        gs:console('gs c set RangedMode Acc')
        gs:traffic()
        gs:type('/ra <t>')
        assert.same(worn_with(sets_of(gs).precast.RA['Death Penalty'], sets_of(gs).midcast.RA.Acc), gs:worn())
    end)

    it('takes the gun as the combat weapon', function()
        local gs = boot()
        gs:type('/ra <t>')
        assert.equal('Death Penalty', gs.user.state.CombatWeapon.value)
    end)

    it('wears sets.precast.RA.Flurry over the precast set under Flurry', function()
        local gs = boot()
        gs:gain_buff('Flurry')
        gs:traffic()
        gs:type('/ra <t>')
        assert.same(jobby.request(sets_of(gs).precast.RA['Death Penalty'], sets_of(gs).precast.RA.Flurry),
            gs:traffic()[1].equip)
    end)

    it('wears sets.precast.RA.Flurry2 under the stronger Flurry', function()
        local gs = boot()
        gs:gain_buff('Flurry')
        gs.user.lastflurry = 2
        gs:traffic()
        gs:type('/ra <t>')
        assert.same(jobby.request(sets_of(gs).precast.RA['Death Penalty'], sets_of(gs).precast.RA.Flurry2),
            gs:traffic()[1].equip)
    end)

    it('wears neither Flurry set without the buff', function()
        local gs = boot()
        gs:type('/ra <t>')
        assert.same(jobby.request(sets_of(gs).precast.RA['Death Penalty']), gs:traffic()[1].equip)
    end)

    it('wears sets.buff["Triple Shot"] over the midcast set under Triple Shot', function()
        local gs = boot()
        gs:gain_buff('Triple Shot')
        gs:traffic()
        gs:type('/ra <t>')
        assert.same(worn_with(sets_of(gs).precast.RA['Death Penalty'], sets_of(gs).midcast.RA,
            sets_of(gs).buff['Triple Shot']), gs:worn())
    end)

    it('wears the Triple Shot set of the ranged mode when it has one', function()
        local gs = boot()
        gs:gain_buff('Triple Shot')
        gs:console('gs c set RangedMode Acc')
        gs:traffic()
        gs:type('/ra <t>')
        assert.same(worn_with(sets_of(gs).precast.RA['Death Penalty'], sets_of(gs).midcast.RA.Acc,
            sets_of(gs).buff['Triple Shot'].Acc), gs:worn())
    end)

    pending('wears sets.buff.Barrage over the midcast set under Barrage: job_post_midcast in data/COR.lua reads '
        .. 'state.Buff.Barrage, which only data/RNG.lua declares, so a corsair with Ranger as the sub job never wears it')

    it('wears sets.TrueShot on a target in the sweet spot', function()
        local gs = boot()
        gs.game.monster.distance = 36
        gs:type('/ra <t>')
        assert.same(worn_with(sets_of(gs).precast.RA['Death Penalty'], sets_of(gs).midcast.RA, sets_of(gs).TrueShot),
            gs:worn())
    end)

    it('wears sets.TrueShot at the far edge of the sweet spot, and not beyond it', function()
        local gs = boot()
        gs.game.monster.distance = 6.3 ^ 2
        gs:type('/ra <t>')
        assert.equal('Weike Torque', gs:worn().neck)
        gs = boot()
        gs.game.monster.distance = 6.4 ^ 2
        gs:type('/ra <t>')
        assert.equal('Loricate Torque +1', gs:worn().neck)
    end)

    it('wears sets.TrueShot not at all closer than the sweet spot', function()
        local gs = boot()
        gs.game.monster.distance = 4.9 ^ 2
        gs:type('/ra <t>')
        assert.equal('Loricate Torque +1', gs:worn().neck)
    end)

    it('leaves sets.TrueShot off with the True Shot mode off', function()
        local gs = boot()
        gs:console('gs c toggle TrueShotMode')
        gs.game.monster.distance = 36
        gs:traffic()
        gs:type('/ra <t>')
        assert.equal('Loricate Torque +1', gs:worn().neck)
    end)

    it('wears the AM set of the gun while Aftermath: Lv.3 is up on Death Penalty', function()
        local gs = boot()
        gs:gain_buff('Aftermath: Lv.3')
        gs:traffic()
        gs:type('/ra <t>')
        assert.same(jobby.request(sets_of(gs).precast.RA['Death Penalty'].AM), gs:traffic()[1].equip)
    end)

    it('wears no AM set under another level of Aftermath', function()
        local gs = boot()
        gs:gain_buff('Aftermath: Lv.1')
        gs:traffic()
        gs:type('/ra <t>')
        assert.same(jobby.request(sets_of(gs).precast.RA['Death Penalty']), gs:traffic()[1].equip)
    end)

    it('wears the AM set no more once Aftermath is gone', function()
        local gs = boot()
        gs:gain_buff('Aftermath: Lv.3')
        gs:lose_buff('Aftermath: Lv.3')
        gs:traffic()
        gs:type('/ra <t>')
        assert.same(jobby.request(sets_of(gs).precast.RA['Death Penalty']), gs:traffic()[1].equip)
    end)

    it('puts the default bullet back on afterwards', function()
        local gs = boot({bullets = {['Bronze Bullet'] = 40, ['Eminent Bullet'] = 40}, ammo = 'Bronze Bullet'})
        gs:type('/ja "Fire Shot" <t>')
        gs:finish_action()
        assert.equal('Eminent Bullet', gs:worn().ammo)
    end)

    it('leaves the bullet alone afterwards with the default ammo mode off', function()
        local gs = boot({bullets = {['Bronze Bullet'] = 40, ['Eminent Bullet'] = 40}, ammo = 'Bronze Bullet'})
        gs:console('gs c toggle UseDefaultAmmo')
        gs:type('/ja "Fire Shot" <t>')
        gs:finish_action()
        assert.equal('Bronze Bullet', gs:worn().ammo)
    end)
end)

describe('a Quick Draw shot', function()
    it('wears sets.precast.CorsairShot', function()
        local gs = boot()
        gs:type('/ja "Fire Shot" <t>')
        assert.same({jobby.request(sets_of(gs).precast.CorsairShot), 'Fire Shot'}, equips(gs))
    end)

    it('wears the set of the shot, Light Shot, when there is one', function()
        local gs = boot()
        gs:type('/ja "Light Shot" <t>')
        assert.same({jobby.request(sets_of(gs).precast.CorsairShot['Light Shot']), 'Light Shot'}, equips(gs))
    end)

    it('wears sets.precast.CorsairShot.Proc in the Proc casting mode', function()
        local gs = boot()
        gs:console('gs c set CastingMode Proc')
        gs:traffic()
        gs:type('/ja "Fire Shot" <t>')
        assert.same(jobby.request(sets_of(gs).precast.CorsairShot.Proc), gs:traffic()[1].equip)
    end)

    it('wears sets.precast.CorsairShot.Proc in the Proc weapon skill mode', function()
        local gs = boot()
        gs:console('gs c set WeaponskillMode Proc')
        gs:traffic()
        gs:type('/ja "Fire Shot" <t>')
        assert.same(jobby.request(sets_of(gs).precast.CorsairShot.Proc), gs:traffic()[1].equip)
    end)

    it('wears sets.precast.CorsairShot.Damage in the Fodder casting mode', function()
        local gs = boot()
        gs:console('gs c set CastingMode Fodder')
        gs:traffic()
        gs:type('/ja "Fire Shot" <t>')
        assert.same(jobby.request(sets_of(gs).precast.CorsairShot.Damage), gs:traffic()[1].equip)
    end)

    it('wears the shot\'s own set, not the Proc one, for Light Shot even in the Proc mode', function()
        local gs = boot()
        gs:console('gs c set CastingMode Proc')
        gs:traffic()
        gs:type('/ja "Light Shot" <t>')
        assert.same(jobby.request(sets_of(gs).precast.CorsairShot['Light Shot']), gs:traffic()[1].equip)
    end)

    it('is cast by gs c elemental quickdraw in the element chosen', function()
        local gs = boot()
        gs:console('gs c elemental quickdraw')
        assert.same({'Fire Shot'}, {gs:traffic()[2].action})
    end)

    it('is cast by gs c elemental quickdraw in another element once it is chosen', function()
        local gs = boot()
        gs:console('gs c set ElementalMode Light')
        gs:traffic()
        gs:console('gs c elemental quickdraw')
        assert.same({'Light Shot'}, {gs:traffic()[2].action})
    end)

    pending('says it will use the bullet worn when no Quick Draw bullet is owned: do_ammo_checks in data/COR.lua '
        .. 'has that branch, but job_precast only calls it when uses_ammo (libs/Sel-Utility.lua) holds, and that '
        .. 'is never so for a Corsair shot')

    it('is held back while a Trump Card is fetched from the satchel, and tried again a second later', function()
        local gs = boot({items = {{name = 'Trump Card', bag = 'satchel', count = 10}}})
        gs:type('/ja "Fire Shot" <t>')
        assert.same({}, gs:traffic())
        assert.same({'get "Trump Card" satchel'}, ran(gs, 'get '))
        gs:advance(1)
        assert.same({'get "Trump Card" satchel', 'get "Trump Card" satchel'}, ran(gs, 'get '))
    end)

    it('goes out when the Trump Card is in the inventory', function()
        local gs = boot({items = {{name = 'Trump Card', count = 10}}})
        gs:type('/ja "Fire Shot" <t>')
        assert.same('Fire Shot', gs:traffic()[2].action)
        assert.same({}, ran(gs, 'get '))
    end)
end)

describe('the bullets a ranged action needs', function()
    it('are left alone when there are plenty', function()
        local gs = boot()
        gs:type('/ra <t>')
        assert.same({'category 16'}, {gs:traffic()[2].action})
        assert.is_false(said(gs, 'LOW AMMO WARNING'))
    end)

    it('stop a ranged attack when there are none, saying which', function()
        local gs = boot({bullets = {['Bronze Bullet'] = 40}, ammo = 'Bronze Bullet'})
        gs:type('/ra <t>')
        assert.same({}, gs:traffic())
        assert.is_true(said(gs, 'No ammo (Eminent Bullet) available for that action.'))
    end)

    it('warn at the warning limit, and let the attack go', function()
        local gs = boot({bullets = {['Eminent Bullet'] = 15}})
        gs:type('/ra <t>')
        assert.same('category 16', gs:traffic()[2].action)
        assert.is_true(said(gs, '****  LOW AMMO WARNING: Eminent Bullet ****'))
    end)

    it('do not warn above the warning limit', function()
        local gs = boot({bullets = {['Eminent Bullet'] = 16}})
        gs:type('/ra <t>')
        assert.is_false(said(gs, 'LOW AMMO WARNING'))
    end)

    it('are held back for Quick Draw when the bullet is the same', function()
        local gs = boot({bullets = {['Eminent Bullet'] = 1}})
        gs.user.gear.QDbullet = 'Eminent Bullet'
        gs:type('/ra <t>')
        assert.same({}, gs:traffic())
        assert.is_true(said(gs, 'No ammo will be left for Quick Draw.  Cancelling.'))
    end)

    it('are held back three at a time for Quick Draw under Triple Shot', function()
        local gs = boot({bullets = {['Eminent Bullet'] = 3}})
        gs.user.gear.QDbullet = 'Eminent Bullet'
        gs:gain_buff('Triple Shot')
        gs:traffic()
        gs:type('/ra <t>')
        assert.same({}, gs:traffic())
        assert.is_true(said(gs, 'No ammo will be left for Quick Draw.  Cancelling.'))
    end)

    it('are enough for Quick Draw under Triple Shot with four left', function()
        local gs = boot({bullets = {['Eminent Bullet'] = 4}})
        gs.user.gear.QDbullet = 'Eminent Bullet'
        gs:gain_buff('Triple Shot')
        gs:traffic()
        gs:type('/ra <t>')
        assert.same('category 16', gs:traffic()[2].action)
    end)

    it('for a ranged weapon skill are the weapon skill bullet', function()
        local gs = boot({tp = 1000, bullets = {['Bronze Bullet'] = 40, ['Eminent Bullet'] = 40}, ammo = 'Bronze Bullet'})
        gs:type('/ws "Last Stand" <t>')
        assert.same({}, gs:traffic())
        assert.is_true(said(gs, 'No ammo (Orichalc. Bullet) available for that action.'))
    end)

    it('for a magical weapon skill are the magic bullet', function()
        local gs = boot({tp = 1000, bullets = {['Bronze Bullet'] = 40}, ammo = 'Bronze Bullet'})
        gs:type('/ws "Leaden Salute" <t>')
        assert.same({}, gs:traffic())
        assert.is_true(said(gs, 'No ammo (Living Bullet) available for that action.'))
    end)

    pending('swap a Rare bullet worn for the default one with no weapon set: panic_swap_ammo in libs/Sel-Utility.lua '
        .. 'reads sets.weapons[state.Weapons.value], and with Weapons at None there is no such set, so a ranged attack '
        .. 'with Animikii Bullet worn stops in an error')

    it('for a weapon skill may be the one worn when it is the ranged attack bullet', function()
        local gs = boot({tp = 1000, bullets = {['Eminent Bullet'] = 40}})
        gs:type('/ws "Last Stand" <t>')
        assert.same('Last Stand', gs:traffic()[2].action)
        assert.is_true(said(gs, 'No weaponskill ammo available, using equipped ammo: (Eminent Bullet)'))
    end)

    it('are not asked for a melee weapon skill', function()
        local gs = boot({tp = 1000, bullets = {['Bronze Bullet'] = 40}, ammo = 'Bronze Bullet'})
        gs:type('/ws "Evisceration" <t>')
        assert.same({'Evisceration'}, actions(gs))
    end)
end)

describe('a Corsair roll', function()
    it('wears sets.precast.CorsairRoll and Luzaf\'s Ring over the idle set', function()
        local gs = boot()
        gs:type('/ja "Chaos Roll" <me>')
        assert.same({jobby.request(sets_of(gs).precast.CorsairRoll, sets_of(gs).precast.LuzafRing), 'Chaos Roll'},
            equips(gs))
    end)

    it('wears the set of the roll, Fighter\'s Roll, when there is one', function()
        local gs = boot()
        gs:type('/ja "Fighter\'s Roll" <me>')
        assert.same(jobby.request(sets_of(gs).precast.CorsairRoll["Fighter's Roll"], sets_of(gs).precast.LuzafRing),
            gs:traffic()[1].equip)
    end)

    it('goes without Luzaf\'s Ring with the Luzaf ring mode off', function()
        local gs = boot()
        gs:console('gs c toggle LuzafRing')
        gs:traffic()
        gs:type('/ja "Chaos Roll" <me>')
        assert.same(jobby.request(sets_of(gs).precast.CorsairRoll), gs:traffic()[1].equip)
    end)

    it('is followed by Luzaf\'s Ring alone for Double-Up', function()
        local gs = boot()
        gs:type('/ja "Double-Up" <me>')
        assert.same(jobby.request(sets_of(gs).precast.LuzafRing), gs:traffic()[1].equip)
    end)

    it('wears sets.precast.CorsairRoll.Recast in the Recast roll mode', function()
        local gs = boot()
        gs:console('gs c set RollMode Recast')
        gs:traffic()
        gs:type('/ja "Chaos Roll" <me>')
        assert.same(jobby.request(sets_of(gs).precast.CorsairRoll, sets_of(gs).precast.LuzafRing,
            sets_of(gs).precast.CorsairRoll.Recast), gs:traffic()[1].equip)
    end)

    it('wears sets.precast.CorsairRoll.Weak in the WeakLock roll mode, without the lock in its name', function()
        local gs = boot()
        gs:console('gs c set RollMode WeakLock')
        gs:traffic()
        gs:type('/ja "Chaos Roll" <me>')
        assert.same(jobby.request(sets_of(gs).precast.CorsairRoll, sets_of(gs).precast.LuzafRing,
            sets_of(gs).precast.CorsairRoll.Weak), gs:traffic()[1].equip)
    end)

    it('puts the roll mode back to None once the roll is done', function()
        local gs = boot()
        gs:console('gs c set RollMode Recast')
        gs:type('/ja "Chaos Roll" <me>')
        gs:finish_action()
        assert.equal('None', gs.user.state.RollMode.value)
    end)

    it('keeps a roll mode that locks', function()
        local gs = boot()
        gs:console('gs c set RollMode RecastLock')
        gs:type('/ja "Chaos Roll" <me>')
        gs:finish_action()
        assert.equal('RecastLock', gs.user.state.RollMode.value)
    end)

    it('says what the roll gives and which numbers are lucky, with the size Luzaf\'s Ring makes it', function()
        local gs = boot()
        gs:type('/ja "Fighter\'s Roll" <me>')
        gs:finish_action()
        assert.is_true(said(gs, "Fighter's Roll provides a bonus to Double Attack Rate.  Roll size: Large"))
        assert.is_true(said(gs, 'Lucky roll is 5, Unlucky roll is 9.'))
    end)

    it('says the roll is small without Luzaf\'s Ring', function()
        local gs = boot()
        gs:console('gs c toggle LuzafRing')
        gs:type('/ja "Fighter\'s Roll" <me>')
        gs:finish_action()
        assert.is_true(said(gs, "Fighter's Roll provides a bonus to Double Attack Rate.  Roll size: Small"))
    end)

    it('says nothing of the roll with the display off', function()
        local gs = boot()
        gs.user.displayroll = false
        gs:type('/ja "Fighter\'s Roll" <me>')
        gs:finish_action()
        assert.is_false(said(gs, 'Lucky roll is'))
    end)
end)

describe('a Corsair roll with a weapon set locking the gun', function()
    local function locked(compensator, tp)
        local gs = boot({tp = tp})
        gs:console('gs c set Weapons Ranged')
        gs:console('gs c set CompensatorMode ' .. compensator)
        gs:traffic()
        gs:type('/ja "Chaos Roll" <me>')
        return gs:worn()
    end

    it('leaves the gun on in the Never compensator mode', function()
        assert.equal('Death Penalty', locked('Never', 0).range)
    end)

    it('puts the Compensator on in the Always compensator mode', function()
        assert.equal('Compensator', locked('Always', 2000).range)
    end)

    it('puts the Compensator on under the TP the compensator mode names', function()
        assert.equal('Compensator', locked('1000', 500).range)
    end)

    it('leaves the gun on over the TP the compensator mode names', function()
        assert.equal('Death Penalty', locked('1000', 1500).range)
    end)
end)

describe('Fold', function()
    it('wears sets.precast.FoldDoubleBust under two busts', function()
        local gs = boot()
        gs:gain_buff('Bust')
        gs:gain_buff('Bust')
        gs:traffic()
        gs:type('/ja "Fold" <me>')
        assert.same(jobby.request(sets_of(gs).precast.FoldDoubleBust), gs:traffic()[1].equip)
    end)

    it('wears nothing of the sort under one bust', function()
        local gs = boot()
        gs:gain_buff('Bust')
        gs:traffic()
        gs:type('/ja "Fold" <me>')
        assert.same({'Fold'}, actions(gs))
    end)
end)

describe('a weapon skill at the TP cap', function()
    local function engaged(tp)
        local gs = boot({tp = tp})
        gs:engage()
        gs:traffic()
        return gs
    end

    local function engaged_worn(gs, ...)
        return worn_with(sets_of(gs).engaged, ...)
    end

    it('wears sets.MagicalMaxTP for an elemental weapon skill', function()
        local gs = engaged(3000)
        gs:type('/ws "Leaden Salute" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Leaden Salute'], sets_of(gs).MagicalMaxTP), gs:worn())
    end)

    it('wears sets.MagicalAccMaxTP for it in the Acc offense mode', function()
        local gs = engaged(3000)
        gs:console('gs c set OffenseMode Acc')
        gs:traffic()
        gs:type('/ws "Leaden Salute" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS['Leaden Salute'], sets_of(gs).MagicalAccMaxTP), gs:worn())
    end)

    it('wears sets.MaxTP for a melee weapon skill', function()
        local gs = engaged(3000)
        gs:type('/ws "Evisceration" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS.Evisceration, sets_of(gs).MaxTP), gs:worn())
    end)

    it('wears sets.AccMaxTP for it in the Acc offense mode', function()
        local gs = engaged(3000)
        gs:console('gs c set OffenseMode Acc')
        gs:traffic()
        gs:type('/ws "Evisceration" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS.Evisceration, sets_of(gs).AccMaxTP), gs:worn())
    end)

    it('swaps from 3000 TP with the Moonshade Earring counted in', function()
        local gs = engaged(2750)
        gs:type('/ws "Evisceration" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS.Evisceration, sets_of(gs).MaxTP), gs:worn())
    end)

    it('keeps the Moonshade Earring below that', function()
        local gs = engaged(2740)
        gs:type('/ws "Evisceration" <t>')
        assert.same(engaged_worn(gs, sets_of(gs).precast.WS.Evisceration), gs:worn())
    end)

    pending('wears sets.RangedMaxTP for a ranged weapon skill: job_post_precast in data/COR.lua tests spell.skill '
        .. 'against 26, but GearSwap gives a weapon skill its skill by name, so Last Stand takes sets.MaxTP')
end)

describe('a weapon skill when a spear weapon skill is known', function()
    -- Wasp Sting is the weapon skill the job file reads as a spear in hand, and sends the dagger's skill for a sword's.
    local known = {'Wasp Sting', 'Evisceration', 'Aeolian Edge'}

    it('is Evisceration in place of Savage Blade', function()
        local gs = boot({tp = 1000, abilities = known})
        gs:type('/ws "Savage Blade" <t>')
        assert.same({'Evisceration'}, actions(gs))
    end)

    it('is Aeolian Edge in place of Circle Blade', function()
        local gs = boot({tp = 1000, abilities = known})
        gs:type('/ws "Circle Blade" <t>')
        assert.same({'Aeolian Edge'}, actions(gs))
    end)

    it('is left alone without it', function()
        local gs = boot({tp = 1000, abilities = {'Evisceration', 'Aeolian Edge'}})
        gs:type('/ws "Savage Blade" <t>')
        assert.same({}, actions(gs))
    end)
end)
