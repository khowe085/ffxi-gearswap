local harness = require('harness')
local testy = require('testy')

local idle = {main = "Judge's Sword", range = "Judge's Bow", head = 'Nyame Helm', body = 'Nyame Mail',
    hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1',
    waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring',
    ring2 = 'Stikini Ring +1', back = 'Mecisto. Mantle', ammo = 'Staunch Tathlum +1'}

local pieces = {"Judge's Sword", "Judge's Bow", 'Staunch Tathlum +1', 'Nyame Helm', 'Nyame Mail', 'Nyame Gauntlets',
    'Nyame Flanchard', 'Nyame Sollerets', 'Loricate Torque +1', 'Plat. Mog. Belt', 'Etiolation Earring',
    'Loquac. Earring', 'Defending Ring', 'Stikini Ring +1', 'Mecisto. Mantle', "Bendis's Hairpin", "Theia's Hairpin",
    'Sapphire Platemail', 'Jadeite Cuirie', 'Diamond Haramaki', 'Sapphire Leggings', 'Sapphire Gauntlets',
    'Jadeite Gloves', 'Diamond Kote', 'Jadeite Chausses', 'Sapphire Trousers', 'Diamond Hiza.', "Orunmila's Torque",
    'Phrenic Torque', 'Aptitude Mantle', 'Moonshade Earring', 'Ishvara Earring', 'Brutal Earring',
    "Hecate's Earring", 'Pixie Earring', 'Beastly Earring', 'Stealth Earring', 'Armageddon', 'Gastraphetes',
    'Annihilator', 'Gandiva', 'Yoichinoyumi'}

local ammunition = {'Chrono Arrow', 'Hauksbok Arrow', 'Chrono Bullet', 'Eradicating Bullet', 'Devastating Bullet',
    'Hauksbok Bullet', 'Animikii Bullet', 'Quelling Bolt', 'Hauksbok Bolt'}

-- What is worn with these changes over the idle set.
local function worn(changes)
    return testy.worn_by(idle, changes)
end

-- Jobby as a ranger with the idle set on, Staunch Tathlum +1 for ammo and 99 of each ammunition, over a sub job of
-- NIN, which has no Fencer to add TP to a weapon skill, unless told otherwise. counts say how many of an ammunition
-- there are instead.
local function boot(overrides)
    overrides = overrides or {}
    local counts = overrides.counts or {}
    overrides.counts = nil
    local items = {}
    for i, name in ipairs(pieces) do
        items[i] = {name = name}
    end
    for _, name in ipairs(ammunition) do
        items[#items + 1] = {name = name, count = counts[name] or 99}
    end
    local options = {character = 'Jobby', main_job = 'RNG', sub_job = 'NIN', expect_file = 'RNG.lua', items = items,
        wearing = testy.worn_by(idle)}
    for k, v in pairs(overrides) do
        options[k] = v
    end
    local gs = harness.boot(options)
    gs:console('gs c update')
    gs:traffic()
    return gs
end

-- The names of the actions among what GearSwap sent.
local function actions(gs)
    local names = {}
    for _, entry in ipairs(gs:traffic()) do
        if entry.action then
            names[#names + 1] = entry.action
        end
    end
    return names
end

-- The ammunition on once the ranged attack or weapon skill has been typed.
local function ammo_after(gs, line)
    gs:type(line)
    return gs:worn().ammo
end

describe('data/RNG.lua', function()
    it('takes the type of the ranged weapon from the weapon in the range slot', function()
        local gs = boot()
        assert.equal('Bow', gs.user.RangedWeaponType)
    end)

    it('takes the type from the weapon set that locks the range slot', function()
        local gs = boot()
        gs:console('gs c set Weapons Gun')
        assert.equal('Gun', gs.user.RangedWeaponType)
        gs:console('gs c set Weapons Crossbow')
        assert.equal('Crossbow', gs.user.RangedWeaponType)
        gs:console('gs c set Weapons Bow')
        assert.equal('Bow', gs.user.RangedWeaponType)
    end)

    it('takes the type from sets.midcast.RA.range when no weapons are locked', function()
        local gs = boot()
        gs.user.sets.midcast.RA.range = 'Annihilator'
        gs:console('gs c set Weapons Bow')
        gs:console('gs c set Weapons None')
        assert.equal('Gun', gs.user.RangedWeaponType)
    end)

    it('knows no type of ranged weapon when none is in the range slot', function()
        local gs = boot({wearing = testy.worn_by(idle, {range = 'empty'})})
        assert.equal('None', gs.user.RangedWeaponType)
    end)
end)

describe('RNG\'s ranged attack', function()
    local function ammo_for(weapons, line, mode)
        local gs = boot()
        gs:console('gs c set Weapons ' .. weapons)
        if mode then
            gs:console('gs c set RangedMode ' .. mode)
        end
        return ammo_after(gs, line or '/ra <t>')
    end

    it('has Chrono Arrow with a bow', function()
        assert.equal('Chrono Arrow', ammo_for('Bow'))
    end)

    it('has Chrono Bullet with a gun', function()
        assert.equal('Chrono Bullet', ammo_for('Gun'))
    end)

    it('has Quelling Bolt with a crossbow', function()
        assert.equal('Quelling Bolt', ammo_for('Crossbow'))
    end)

    it('has Chrono Arrow with a bow in the accuracy ranged mode', function()
        assert.equal('Chrono Arrow', ammo_for('Bow', nil, 'Acc'))
    end)

    it('has Eradicating Bullet with a gun in the accuracy ranged mode', function()
        assert.equal('Eradicating Bullet', ammo_for('Gun', nil, 'Acc'))
    end)

    it('takes the precast and midcast sets of ranged attacks, the weapon\'s set in precast', function()
        local gs = boot()
        gs:console('gs c set Weapons Gun')
        gs:traffic()
        gs:type('/ra <t>')
        local traffic = gs:traffic()
        assert.equal("Theia's Hairpin", traffic[1].equip.head)
        assert.same(worn({range = 'Armageddon', ammo = 'Chrono Bullet', head = "Theia's Hairpin",
            body = 'Sapphire Platemail'}), gs:worn())
    end)

    it('takes the midcast set of the ranged mode', function()
        local gs = boot()
        gs:console('gs c set RangedMode Acc')
        gs:type('/ra <t>')
        assert.equal('Jadeite Cuirie', gs:worn().body)
    end)

    it('goes on with the ammunition of the weapon, over what Jobby had on', function()
        local gs = boot()
        gs:type('/ra <t>')
        gs:finish_action()
        assert.equal('Chrono Arrow', gs:worn().ammo)
    end)
end)

describe('RNG\'s ranged weapon skill', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set Weapons Gun')
        gs.game.player.vitals.tp = 1000
        gs:traffic()
    end)

    it('has Chrono Bullet when it is not elemental', function()
        assert.equal('Chrono Bullet', ammo_after(gs, '/ws "Last Stand" <t>'))
    end)

    it('has Eradicating Bullet when it is not elemental, in the accuracy weapon skill mode', function()
        gs:console('gs c set WeaponskillMode Acc')
        assert.equal('Eradicating Bullet', ammo_after(gs, '/ws "Last Stand" <t>'))
    end)

    it('has Devastating Bullet when it is elemental', function()
        assert.equal('Devastating Bullet', ammo_after(gs, '/ws "Trueflight" <t>'))
    end)

    it('has Devastating Bullet when it is elemental, in the accuracy weapon skill mode', function()
        gs:console('gs c set WeaponskillMode Acc')
        assert.equal('Devastating Bullet', ammo_after(gs, '/ws "Trueflight" <t>'))
    end)

    it('has Chrono Arrow with a bow, whatever its kind', function()
        gs:console('gs c set Weapons Bow')
        assert.equal('Chrono Arrow', ammo_after(gs, '/ws "Apex Arrow" <t>'))
    end)

    it('has the ammunition of the weapon back once it is done, over the weapon skill\'s', function()
        gs:console('gs c set WeaponskillMode Acc')
        gs:type('/ws "Last Stand" <t>')
        gs:finish_action()
        assert.equal('Chrono Bullet', gs:worn().ammo)
    end)

    pending('has the Unlimited Shot ammunition (Hauksbok, Animikii) with Unlimited Shot up, as do_ammo_checks in '
        .. 'data/RNG.lua means: uses_ammo, which decides whether it is called, is false while Unlimited Shot is up')
end)

describe('RNG\'s weapon skill of another skill', function()
    local function ammo_for(weapons)
        local gs = boot()
        gs:console('gs c set Weapons ' .. weapons)
        gs.game.player.vitals.tp = 1000
        gs:traffic()
        return ammo_after(gs, '/ws "Savage Blade" <t>')
    end

    it('has Hauksbok Arrow with a bow, so that it spends none of the good ammunition', function()
        assert.equal('Hauksbok Arrow', ammo_for('Bow'))
    end)

    it('has Hauksbok Bullet with a gun', function()
        assert.equal('Hauksbok Bullet', ammo_for('Gun'))
    end)

    it('has Hauksbok Bolt with a crossbow', function()
        assert.equal('Hauksbok Bolt', ammo_for('Crossbow'))
    end)

    it('leaves the ammunition when Jobby has none of the Hauksbok kind', function()
        local items = {}
        for i, name in ipairs(pieces) do
            items[i] = {name = name}
        end
        local gs = harness.boot({character = 'Jobby', main_job = 'RNG', sub_job = 'NIN', expect_file = 'RNG.lua',
            items = items, wearing = testy.worn_by(idle), tp = 1000})
        gs:console('gs c update')
        gs:traffic()
        assert.equal('Staunch Tathlum +1', ammo_after(gs, '/ws "Savage Blade" <t>'))
    end)
end)

describe('RNG\'s default ammunition', function()
    it('is left alone with UseDefaultAmmo off, which leaves the ammunition Jobby had on', function()
        local gs = boot()
        gs:console('gs c toggle UseDefaultAmmo')
        assert.equal('Staunch Tathlum +1', ammo_after(gs, '/ra <t>'))
    end)

    it('is put on after any action that is done, once the range slot holds a weapon', function()
        local gs = boot()
        gs:type('/ja "Barrage" <me>')
        gs:finish_action()
        assert.equal('Chrono Arrow', gs:worn().ammo)
    end)

    it('is not put on once there is no weapon in the range slot', function()
        local gs = boot({wearing = testy.worn_by(idle, {range = 'empty'})})
        gs:type('/ja "Barrage" <me>')
        gs:finish_action()
        assert.equal('Staunch Tathlum +1', gs:worn().ammo)
    end)
end)

describe('RNG\'s warning of low ammunition', function()
    it('names the ammunition that is on and how much is left, under 15', function()
        local gs = boot({counts = {['Chrono Arrow'] = 14}, wearing = testy.worn_by(idle, {ammo = 'Chrono Arrow'})})
        gs:type('/ra <t>')
        assert.is_truthy(gs:log():find("Ammo 'Chrono Arrow' running low: (14) remaining.", 1, true))
    end)

    it('is left out from 15', function()
        local gs = boot({counts = {['Chrono Arrow'] = 15}, wearing = testy.worn_by(idle, {ammo = 'Chrono Arrow'})})
        gs:type('/ra <t>')
        assert.is_nil(gs:log():find('running low', 1, true))
    end)
end)

-- The monster is this far away, in yalms.
local function monster_at(gs, yalms)
    gs.game.monster.distance = yalms * yalms
    gs.env.refresh_globals()
end

describe('RNG\'s true shot, with the monster in the sweet spot of the weapon', function()
    local function feet_after_shot(weapons, yalms)
        local gs = boot()
        gs:console('gs c set Weapons ' .. weapons)
        monster_at(gs, yalms)
        gs:type('/ra <t>')
        return gs:worn().feet
    end

    it('has sets.TrueShot on for a gun between 5.03 and 6.31 yalms, as the two sizes add up', function()
        assert.equal('Sapphire Leggings', feet_after_shot('Gun', 5.03))
        assert.equal('Sapphire Leggings', feet_after_shot('Gun', 6.31))
    end)

    it('has no sets.TrueShot on for a gun out of that range', function()
        assert.equal('Nyame Sollerets', feet_after_shot('Gun', 5.01))
        assert.equal('Nyame Sollerets', feet_after_shot('Gun', 6.33))
    end)

    it('has sets.TrueShot on for a bow between 8.03 and 11.51 yalms', function()
        assert.equal('Sapphire Leggings', feet_after_shot('Bow', 8.03))
        assert.equal('Sapphire Leggings', feet_after_shot('Bow', 11.51))
        assert.equal('Nyame Sollerets', feet_after_shot('Bow', 8.0))
        assert.equal('Nyame Sollerets', feet_after_shot('Bow', 11.53))
    end)

    it('has sets.TrueShot on for a crossbow between 7.01 and 10.39 yalms', function()
        assert.equal('Sapphire Leggings', feet_after_shot('Crossbow', 7.01))
        assert.equal('Sapphire Leggings', feet_after_shot('Crossbow', 10.39))
        assert.equal('Nyame Sollerets', feet_after_shot('Crossbow', 6.99))
        assert.equal('Nyame Sollerets', feet_after_shot('Crossbow', 10.41))
    end)

    it('has no sets.TrueShot on with TrueShotMode off', function()
        local gs = boot()
        gs:console('gs c set Weapons Gun')
        gs:console('gs c toggle TrueShotMode')
        monster_at(gs, 5.5)
        gs:type('/ra <t>')
        assert.equal('Nyame Sollerets', gs:worn().feet)
    end)

    pending('has sets.TrueShot on for a ranged weapon skill that is not elemental, as job_post_precast in data/RNG.lua '
        .. 'means: it looks for the skill among the ids 25 and 26, and spell.skill is the skill\'s name by then')
end)

describe('RNG\'s ranged attack with a buff up', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('has sets.buff.Velocity Shot over the midcast set with Velocity Shot', function()
        gs:gain_buff('Velocity Shot')
        gs:type('/ra <t>')
        assert.same(worn({head = "Bendis's Hairpin", ammo = 'Chrono Arrow', body = 'Sapphire Platemail',
            back = 'Aptitude Mantle'}), gs:worn())
    end)

    it('has sets.buff.Barrage over the midcast set with Barrage', function()
        gs:gain_buff('Barrage')
        gs:type('/ra <t>')
        assert.equal('Diamond Hiza.', gs:worn().legs)
    end)

    it('has sets.buff.Camouflage over the midcast set with Camouflage', function()
        gs:gain_buff('Camouflage')
        gs:type('/ra <t>')
        assert.equal("Orunmila's Torque", gs:worn().neck)
    end)

    it('has the Acc set of sets.buff.Camouflage in the accuracy ranged mode', function()
        gs:console('gs c set RangedMode Acc')
        gs:gain_buff('Camouflage')
        gs:type('/ra <t>')
        assert.equal('Phrenic Torque', gs:worn().neck)
    end)

    it('has none of them without the buffs', function()
        gs:type('/ra <t>')
        assert.same(worn({head = "Bendis's Hairpin", ammo = 'Chrono Arrow', body = 'Sapphire Platemail'}), gs:worn())
    end)
end)

describe('RNG\'s ranged attack with Double Shot', function()
    local gs
    before_each(function()
        gs = boot()
        gs:gain_buff('Double Shot')
    end)

    it('has sets.buff.Double Shot over the midcast set', function()
        gs:type('/ra <t>')
        assert.equal('Diamond Kote', gs:worn().hands)
    end)

    it('has the set for the ranged mode in that mode', function()
        gs:console('gs c set RangedMode Acc')
        gs:type('/ra <t>')
        assert.equal('Jadeite Gloves', gs:worn().hands)
    end)

    it('has the set for the weapons locked, in place of the base set', function()
        gs:console('gs c set Weapons Gun')
        gs:type('/ra <t>')
        assert.same({legs = 'Jadeite Chausses', hands = 'Nyame Gauntlets'},
            {legs = gs:worn().legs, hands = gs:worn().hands})
    end)

    it('has the ranged mode\'s set of the weapons\' set in that mode', function()
        gs:console('gs c set Weapons Gun')
        gs:console('gs c set RangedMode Acc')
        gs:type('/ra <t>')
        assert.equal('Sapphire Trousers', gs:worn().legs)
    end)
end)

describe('RNG\'s ranged attack with Aftermath', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set Weapons Gun')
        gs:traffic()
    end)

    local function body_after_shot()
        gs:type('/ra <t>')
        return gs:worn().body
    end

    it('has the AM set of the midcast set when Armageddon has any Aftermath level', function()
        gs:gain_buff('Aftermath: Lv.1')
        assert.equal('Diamond Haramaki', body_after_shot())
    end)

    it('goes without the AM set when Aftermath wears off', function()
        gs:gain_buff('Aftermath: Lv.1')
        gs:lose_buff('Aftermath: Lv.1')
        assert.equal('Sapphire Platemail', body_after_shot())
    end)

    it('goes without the AM set for Gastraphetes under Aftermath level 1', function()
        gs:console('gs c set Weapons Crossbow')
        gs:gain_buff('Aftermath: Lv.1')
        assert.equal('Sapphire Platemail', body_after_shot())
    end)

    it('has the AM set for Gastraphetes under Aftermath level 3', function()
        gs:console('gs c set Weapons Crossbow')
        gs:gain_buff('Aftermath: Lv.3')
        assert.equal('Diamond Haramaki', body_after_shot())
    end)

    it('has the AM set\'s Double Shot variant under Double Shot', function()
        gs:gain_buff('Aftermath: Lv.2')
        gs:gain_buff('Double Shot')
        gs:console('gs c set RangedMode Acc')
        gs:type('/ra <t>')
        assert.same({legs = 'Jadeite Chausses', hands = 'Sapphire Gauntlets'},
            {legs = gs:worn().legs, hands = gs:worn().hands})
    end)
end)

describe('RNG\'s ranged attack with Flurry', function()
    local gs
    before_each(function()
        gs = boot()
        gs:add_party_member({name = 'Friend'})
    end)

    -- Friend casts Flurry on Jobby, as the server tells of it, and Flurry is up.
    local function flurried(spell_id)
        gs.game:send_action_packet({
            actor_id = gs.game.others[1].id, category = 4, param = spell_id,
            targets = {{id = gs.game.player.id, actions = {{message = 230, param = 265, reaction = 0, animation = 0,
                effect = 0, stagger = 0}}}},
        })
        gs.game:settle()
        gs:gain_buff('Flurry')
    end

    it('takes sets.precast.RA.Flurry after Flurry', function()
        flurried(845)
        gs:traffic()
        gs:type('/ra <t>')
        assert.equal('Sapphire Gauntlets', gs:traffic()[1].equip.hands)
    end)

    it('takes sets.precast.RA.Flurry2 after Flurry II', function()
        flurried(846)
        gs:traffic()
        gs:type('/ra <t>')
        assert.equal('Jadeite Gloves', gs:traffic()[1].equip.hands)
    end)

    it('takes the Flurry set of the weapons locked, in place of the base set', function()
        gs:console('gs c set Weapons Gun')
        flurried(845)
        gs:traffic()
        gs:type('/ra <t>')
        assert.equal('Diamond Kote', gs:traffic()[1].equip.hands)
    end)

    it('takes no Flurry set without Flurry', function()
        gs:type('/ra <t>')
        assert.is_nil(gs:traffic()[1].equip.hands)
    end)
end)

describe('RNG\'s statusammo command', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set Weapons Gun')
    end)

    it('names the ammunition to shoot, over the default', function()
        gs:console('gs c statusammo Devastating Bullet')
        assert.equal('Devastating Bullet', ammo_after(gs, '/ra <t>'))
    end)

    it('names no ammunition when it is given none', function()
        gs:console('gs c statusammo Devastating Bullet')
        gs:console('gs c statusammo')
        assert.equal('Chrono Bullet', ammo_after(gs, '/ra <t>'))
    end)

    pending('shoots Hauksbok ammunition, which is rare, with the weapons set to None: Sel\'s panic_swap_ammo reads '
        .. 'sets.weapons[state.Weapons.value], and there is no set for None')
end)

describe('RNG\'s update', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('puts Velocity Shot up when the user asks for the update and Velocity Shot isn\'t up', function()
        gs:console('gs c update user')
        assert.same({'Velocity Shot'}, actions(gs))
    end)

    it('puts nothing up in an update the user didn\'t ask for', function()
        gs:console('gs c update')
        assert.same({}, actions(gs))
    end)

    it('puts nothing up while Velocity Shot is up', function()
        gs:gain_buff('Velocity Shot')
        gs:traffic()
        gs:console('gs c update user')
        assert.same({}, actions(gs))
    end)
end)

describe('RNG\'s Moonshade Earring at 3200 TP with its bonus', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set Weapons Gun')
        gs:traffic()
    end)

    local function ears_after(name, tp)
        gs.game.player.vitals.tp = tp
        gs:type('/ws "' .. name .. '" <t>')
        return {gs:worn().left_ear, gs:worn().right_ear}
    end

    it('stays in the weapon skill set up to that', function()
        assert.same({'Moonshade Earring', 'Etiolation Earring'}, ears_after('Savage Blade', 2950))
    end)

    it('stays in the set of an elemental weapon skill up to that', function()
        assert.same({'Moonshade Earring', 'Etiolation Earring'}, ears_after('Trueflight', 2950))
    end)

    it('gives way to sets.MaxTP for a weapon skill that is neither ranged nor elemental', function()
        assert.same({'Beastly Earring', 'Etiolation Earring'}, ears_after('Savage Blade', 2951))
    end)

    it('gives way to sets.AccMaxTP for that in an accuracy mode', function()
        gs:console('gs c set WeaponskillMode Acc')
        assert.same({'Stealth Earring', 'Etiolation Earring'}, ears_after('Savage Blade', 3000))
    end)

    it('gives way to sets.MagicalMaxTP for an elemental weapon skill', function()
        assert.same({"Hecate's Earring", 'Etiolation Earring'}, ears_after('Trueflight', 3000))
    end)

    it('gives way to sets.MagicalAccMaxTP for that in an accuracy mode', function()
        gs:console('gs c set WeaponskillMode Acc')
        assert.same({'Pixie Earring', 'Etiolation Earring'}, ears_after('Trueflight', 3000))
    end)

    pending('gives way to sets.RangedMaxTP for a ranged weapon skill that is not elemental, and sets.RangedAccMaxTP in an '
        .. 'accuracy mode, as job_post_precast in data/RNG.lua means: it looks for the skill among the ids 25 and 26, '
        .. 'and spell.skill is the skill\'s name by then, so sets.MaxTP is what such a weapon skill gets')
end)

