local harness = require('harness')
local testy = require('testy')

local idle = {main = "Judge's Sword", head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard', feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt',
    ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1',
    back = 'Mecisto. Mantle'}

local pieces = {"Judge's Sword", 'Aern Sword', 'Trainee Sword', "Charmer's Merlin", 'Nyame Helm', 'Nyame Mail',
    'Nyame Gauntlets', 'Nyame Flanchard', 'Nyame Sollerets', 'Loricate Torque +1', 'Plat. Mog. Belt',
    'Etiolation Earring', 'Loquac. Earring', 'Defending Ring', 'Stikini Ring +1', "Tyrant's Ring", 'Moepapa Ring',
    'Mecisto. Mantle', "Bendis's Hairpin", "Theia's Hairpin", 'Sapphire Platemail', 'Jadeite Cuirie',
    'Diamond Haramaki', 'Sapphire Gauntlets', 'Jadeite Gloves', 'Diamond Kote', 'Sapphire Trousers',
    'Jadeite Chausses', 'Sapphire Leggings', 'Jadeite Jambeaux', 'Diamond Sune-Ate', "Orunmila's Torque",
    'Phrenic Torque', 'Aptitude Mantle', 'Prosilio Belt', 'Moonshade Earring', 'Ishvara Earring', 'Brutal Earring',
    'Lugra Earring +1', "Hecate's Earring", 'Pixie Earring'}

-- What is worn with these changes over the idle set.
local function worn(changes)
    return testy.worn_by(idle, changes)
end

-- Jobby as a beastmaster with the idle set on, over a sub job of WAR, with the merits and the pet food in its bags that
-- overrides name, and the pet food it has: Theta, Zeta and Eta unless told otherwise.
local function boot(overrides)
    overrides = overrides or {}
    local extra = overrides.extra_items or {{name = 'Pet Food Theta', count = 12}, {name = 'Pet Food Zeta', count = 12},
        {name = 'Pet Food Eta', count = 12}}
    overrides.extra_items = nil
    local items = {}
    for i, name in ipairs(pieces) do
        items[i] = {name = name}
    end
    for _, item in ipairs(extra) do
        items[#items + 1] = item
    end
    local options = {character = 'Jobby', main_job = 'BST', sub_job = 'WAR', expect_file = 'BST.lua', items = items,
        wearing = testy.worn_by(idle), merits = {sic_recast = 3}}
    for k, v in pairs(overrides) do
        options[k] = v
    end
    local gs = harness.boot(options)
    gs:console('gs c update')
    gs:traffic()
    return gs
end

-- The ability is on recast for these seconds from now on, whatever recast was asked before.
local function put_on_recast(gs, recast_id, seconds)
    local before = gs.game.ability_recasts
    gs.game.ability_recasts = function(game)
        local recasts = before(game)
        recasts[recast_id] = seconds
        return recasts
    end
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

-- Jobby has the Dual Wield trait from now on, as Sel finds out when it looks.
local function can_dual_wield(gs)
    local ffxi = gs.game.windower.ffxi
    local before = ffxi.get_abilities
    ffxi.get_abilities = function()
        local abilities = before()
        abilities.job_traits = {18}
        return abilities
    end
    gs.user.set_dual_wield()
    gs.game:settle()
    gs:traffic()
end

local function said(gs, text)
    return gs:log():find(text, 1, true) ~= nil
end

describe('data/BST.lua', function()
    it('starts with auto fight and auto reward on, auto ready and auto call off, and a Tank pet mode', function()
        local gs = boot()
        assert.is_true(gs.user.state.AutoFightMode.value)
        assert.is_true(gs.user.state.AutoRewardMode.value)
        assert.is_false(gs.user.state.AutoReadyMode.value)
        assert.is_false(gs.user.state.AutoCallPet.value)
        assert.equal('Tank', gs.user.state.PetMode.value)
        assert.equal('Theta', gs.user.state.RewardMode.value)
        assert.equal('ScissorlegXerin', gs.user.state.JugMode.value)
    end)

    it('takes 30 seconds for a ready charge, less 5 for the job points spent and 2 for each merit', function()
        local gs = boot({merits = {sic_recast = 3}})
        assert.equal(19, gs.user.base_chargetimer)
        gs = boot({merits = {sic_recast = 5}})
        assert.equal(15, gs.user.base_chargetimer)
    end)
end)

describe('BST\'s ready charges', function()
    local gs
    before_each(function()
        gs = boot()
        gs.game.commands = {}
    end)

    local function charges()
        gs:console('gs c showcharge')
        local count
        for entry in gs:log():gmatch('~~~Current Ready Charges Available: %[(%d+)%]~~~') do
            count = tonumber(entry)
        end
        return count
    end

    it('are all three when Sic is ready', function()
        assert.equal(3, charges())
    end)

    it('come back one a charge timer, 19 seconds here', function()
        put_on_recast(gs, 102, 19)
        assert.equal(2, charges())
    end)

    it('are none when the recast is all three timers', function()
        put_on_recast(gs, 102, 57)
        assert.equal(0, charges())
    end)

    it('take 5 seconds less a timer with Charmer\'s Merlin in the ready recast set', function()
        gs.user.sets.midcast.Pet.ReadyRecast.main = "Charmer's Merlin"
        put_on_recast(gs, 102, 14)
        assert.equal(2, charges())
    end)

    it('take 5 seconds less a timer with Desultor Tassets in the ready recast set', function()
        gs.user.sets.midcast.Pet.ReadyRecast.legs = 'Desultor Tassets'
        put_on_recast(gs, 102, 14)
        assert.equal(2, charges())
    end)

    it('take 5 seconds less a timer with Gleti\'s Breeches in the ready recast set', function()
        gs.user.sets.midcast.Pet.ReadyRecast.legs = "Gleti's Breeches"
        put_on_recast(gs, 102, 14)
        assert.equal(2, charges())
    end)

    it('take no less than 10 seconds a timer', function()
        gs.user.sets.midcast.Pet.ReadyRecast.main = "Charmer's Merlin"
        gs.user.sets.midcast.Pet.ReadyRecast.legs = 'Desultor Tassets'
        put_on_recast(gs, 102, 10)
        assert.equal(2, charges())
    end)
end)

describe('BST\'s Reward', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('has the set of the reward mode, with Reward\'s own over it, before it goes out', function()
        gs:type('/ja "Reward" <me>')
        local traffic = gs:traffic()
        assert.same({legs = 'Sapphire Trousers', ammo = 'Pet Food Theta', feet = 'Sapphire Leggings'},
            traffic[1].equip)
        assert.equal('Reward', traffic[2].action)
    end)

    it('has the set of another reward mode in that mode', function()
        gs:console('gs c set RewardMode Zeta')
        gs:type('/ja "Reward" <me>')
        assert.same({legs = 'Sapphire Trousers', ammo = 'Pet Food Zeta', feet = 'Jadeite Jambeaux'},
            gs:traffic()[1].equip)
    end)

    it('has the dual wield set too, for a character who can dual wield', function()
        can_dual_wield(gs)
        gs:type('/ja "Reward" <me>')
        assert.equal('Aern Sword', gs:traffic()[1].equip.sub)
    end)

    it('has no dual wield set for a character who can\'t', function()
        gs:type('/ja "Reward" <me>')
        assert.is_nil(gs:traffic()[1].equip.sub)
    end)
end)

describe('BST\'s Spur', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('has its set and the axe for it', function()
        gs:type('/pet "Spur" <me>')
        assert.same({back = 'Aptitude Mantle', main = "Charmer's Merlin"}, gs:traffic()[1].equip)
    end)

    it('has the axes for it for a character who can dual wield', function()
        can_dual_wield(gs)
        gs:type('/pet "Spur" <me>')
        assert.same({back = 'Aptitude Mantle', main = "Charmer's Merlin", sub = 'Aern Sword'}, gs:traffic()[1].equip)
    end)
end)

describe('BST\'s Bestial Loyalty and Call Beast', function()
    local function head_hands_after(gs, line)
        gs:type(line)
        local equip = gs:traffic()[1].equip
        return {head = equip.head, hands = equip.hands, legs = equip.legs}
    end

    it('wear the set of the jug pet chosen, with Bestial Loyalty\'s own set under it', function()
        local gs = boot()
        assert.same({head = "Bendis's Hairpin", hands = 'Diamond Kote', legs = 'Jadeite Chausses'},
            head_hands_after(gs, '/ja "Bestial Loyalty" <me>'))
    end)

    it('wear the same set for Call Beast', function()
        local gs = boot()
        assert.same({head = "Bendis's Hairpin", hands = 'Diamond Kote', legs = 'Jadeite Chausses'},
            head_hands_after(gs, '/ja "Call Beast" <me>'))
    end)

    it('wear the set of the better pet when the jug of it is in the bags', function()
        local gs = boot({extra_items = {{name = 'Bubbly Broth', count = 12}}})
        assert.same({head = "Bendis's Hairpin", hands = 'Jadeite Gloves'},
            head_hands_after(gs, '/ja "Bestial Loyalty" <me>'))
    end)

    it('wear the set of the better pet for the other jug too', function()
        local gs = boot({extra_items = {{name = 'Vis. Broth', count = 12}}})
        gs:console('gs c set JugMode DroopyDortwin')
        assert.same({head = "Bendis's Hairpin", hands = 'Sapphire Gauntlets'},
            head_hands_after(gs, '/ja "Bestial Loyalty" <me>'))
    end)

    it('wear the set of the jug pet itself without the jug', function()
        local gs = boot({extra_items = {}})
        gs:console('gs c set JugMode DroopyDortwin')
        assert.same({head = "Bendis's Hairpin", hands = 'Diamond Kote'},
            head_hands_after(gs, '/ja "Bestial Loyalty" <me>'))
    end)
end)

describe('BST\'s Bestial Loyalty while it is on recast', function()
    it('is Call Beast, and Bestial Loyalty is held back', function()
        local gs = boot()
        put_on_recast(gs, 94, 60)
        assert.is_true(gs:type('/ja "Bestial Loyalty" <me>'))
        assert.same({'Call Beast'}, actions(gs))
    end)

    it('goes out when it is ready', function()
        local gs = boot()
        gs:type('/ja "Bestial Loyalty" <me>')
        assert.same({'Bestial Loyalty'}, actions(gs))
    end)
end)

describe('BST\'s weapon skill', function()
    local gs
    before_each(function()
        gs = boot()
        gs.game.player.vitals.tp = 1000
    end)

    local function aimed_from(yalms, line)
        gs.game.monster.distance = yalms * yalms
        gs.env.refresh_globals()
        gs:type(line or '/ws "Savage Blade" <t>')
        return actions(gs)
    end

    it('goes out within 6 yalms of the target', function()
        assert.same({'Savage Blade'}, aimed_from(6))
    end)

    it('is cancelled farther away, and Jobby is told', function()
        assert.same({}, aimed_from(6.5))
        assert.is_true(said(gs, 'Savage Blade Canceled: [Out of Range]'))
    end)

    it('goes out for Mistral Axe from any distance', function()
        assert.same({'Mistral Axe'}, aimed_from(9, '/ws "Mistral Axe" <t>'))
    end)

    it('goes out for Bora Axe from any distance', function()
        assert.same({'Bora Axe'}, aimed_from(9, '/ws "Bora Axe" <t>'))
    end)
end)

-- What Jobby wears with a pet out in the Tank pet mode, idle: the set of a pet idle, and the Tank set under it.
local function with_pet(changes)
    local set = {back = 'Aptitude Mantle', ring1 = "Tyrant's Ring"}
    for slot, item in pairs(changes or {}) do
        set[slot] = item
    end
    return worn(set)
end

describe('BST\'s ready moves, as Jobby commands them', function()
    local gs
    before_each(function()
        gs = boot()
        gs:summon_pet({name = 'DroopyDortwin'})
        gs:traffic()
    end)

    it('have the ready recast set on before they go out', function()
        gs:type('/pet "Foot Kick" <me>')
        local traffic = gs:traffic()
        assert.same({legs = 'Sapphire Trousers'}, traffic[1].equip)
        assert.equal('Foot Kick', traffic[2].action)
    end)

    it('have the ready recast set of the dual wielder\'s kind for a character who can dual wield', function()
        can_dual_wield(gs)
        gs:type('/pet "Foot Kick" <me>')
        assert.same({sub = "Charmer's Merlin"}, gs:traffic()[1].equip)
    end)
end)

describe('BST\'s ready moves, once the command is done', function()
    local gs
    before_each(function()
        gs = boot()
        gs:summon_pet({name = 'DroopyDortwin'})
        gs:traffic()
    end)

    local function move(line)
        gs:type(line)
        gs:finish_action()
        return gs:worn()
    end

    it('have the pet WS set and the TP bonus set while the pet has little TP', function()
        assert.same(with_pet({body = 'Sapphire Platemail', feet = 'Sapphire Leggings'}),
            move('/pet "Foot Kick" <me>'))
    end)

    it('have the TP bonus set while the pet has under 2400 TP', function()
        gs:set_pet_tp(2399)
        assert.equal('Sapphire Leggings', move('/pet "Foot Kick" <me>').feet)
    end)

    it('have no TP bonus set while the pet has 2400 TP or more', function()
        gs:set_pet_tp(2400)
        assert.equal('Nyame Sollerets', move('/pet "Foot Kick" <me>').feet)
    end)

    it('have the set of the offense mode in that mode', function()
        gs:console('gs c set OffenseMode Acc')
        assert.equal('Jadeite Cuirie', move('/pet "Foot Kick" <me>').body)
    end)

    it('have the debuff set for a debuff, and the TP bonus set with it', function()
        assert.same(with_pet({body = 'Sapphire Platemail', hands = 'Sapphire Gauntlets', feet = 'Sapphire Leggings'}),
            move('/pet "Dust Cloud" <me>'))
    end)

    it('have the magic set for a magical move that is no debuff', function()
        assert.same(with_pet({body = 'Sapphire Platemail', neck = "Orunmila's Torque"}),
            move('/pet "Venom Spray" <me>'))
    end)

    it('have the offense mode\'s magic set in that mode', function()
        gs:console('gs c set OffenseMode Acc')
        assert.equal('Phrenic Torque', move('/pet "Venom Spray" <me>').neck)
    end)

    it('have the physical debuff set for a physical debuff, and the TP bonus set with it', function()
        assert.same(with_pet({body = 'Sapphire Platemail', hands = 'Jadeite Gloves', feet = 'Sapphire Leggings'}),
            move('/pet "Sudden Lunge" <me>'))
    end)

    it('have the multi-hit set for a move of several hits', function()
        assert.same(with_pet({body = 'Sapphire Platemail', hands = 'Diamond Kote'}), move('/pet "Pentapeck" <me>'))
    end)

    it('have the favorable correlation set in that mode', function()
        gs:console('gs c set CorrelationMode Favorable')
        assert.equal("Theia's Hairpin", move('/pet "Foot Kick" <me>').head)
    end)

    it('have no pet set under a defense mode', function()
        gs:console('gs c set DefenseMode Physical')
        assert.same(with_pet(), move('/pet "Foot Kick" <me>'))
    end)

    it('give way to the pet\'s idle set once the pet is done with the move', function()
        gs:type('/pet "Foot Kick" <me>')
        gs:finish_action()
        gs:pet_readies('Foot Kick')
        gs:pet_finishes('Foot Kick')
        assert.same(with_pet(), gs:worn())
    end)

    it('are followed by the count of ready charges left, half a second after the pet is done', function()
        gs:type('/pet "Foot Kick" <me>')
        gs:finish_action()
        gs:pet_readies('Foot Kick')
        gs:pet_finishes('Foot Kick')
        assert.is_nil(gs:log():find('Ready Charges', 1, true))
        gs:advance(0.5)
        assert.is_true(said(gs, '~~~Current Ready Charges Available: [3]~~~'))
    end)
end)

describe('BST\'s Unleash', function()
    local gs
    before_each(function()
        gs = boot()
        gs:summon_pet({name = 'DroopyDortwin'})
        gs:gain_buff('Unleash')
        gs:traffic()
    end)

    local function move(line)
        gs:type(line)
        gs:finish_action()
        return gs:worn()
    end

    it('locks the ready set in place with the first move, and says so', function()
        move('/pet "Foot Kick" <me>')
        assert.is_true(said(gs, 'Unleash is on, locking your current Ready set.'))
        gs:pet_readies('Foot Kick')
        gs:pet_finishes('Foot Kick')
        assert.equal('Sapphire Platemail', gs:worn().body)
    end)

    it('keeps the ready set under a defense mode', function()
        gs:console('gs c set DefenseMode Physical')
        assert.equal('Sapphire Platemail', move('/pet "Foot Kick" <me>').body)
    end)

    it('lets go of the slots when Unleash wears off, and says so', function()
        move('/pet "Foot Kick" <me>')
        gs:pet_readies('Foot Kick')
        gs:pet_finishes('Foot Kick')
        gs:advance(3)
        gs:lose_buff('Unleash')
        assert.is_true(said(gs, 'Unleash has worn, enabling all slots.'))
        assert.equal('Nyame Mail', gs:worn().body)
    end)

    it('locks nothing when told not to', function()
        gs:console('gs c unleashlock')
        assert.is_true(said(gs, 'Unleash no longer locks gear.'))
        move('/pet "Foot Kick" <me>')
        gs:pet_readies('Foot Kick')
        gs:pet_finishes('Foot Kick')
        assert.equal('Nyame Mail', gs:worn().body)
    end)

    it('locks again when told to', function()
        gs:console('gs c unleashlock')
        gs:console('gs c unleashlock')
        assert.is_true(said(gs, 'Unleash now locks gear.'))
    end)
end)

describe('BST\'s ready command', function()
    local function booted(pet_name, status)
        local gs = boot()
        gs:summon_pet({name = pet_name, status = status or 1})
        gs:traffic()
        return gs
    end

    for kind, move in pairs({aoe = 'Whirl Claws', buff = 'Wild Carrot', debuff = 'Dust Cloud', physical = 'Foot Kick',
        magical = 'Dust Cloud', default = 'Foot Kick'}) do
        it('is ' .. move .. ' of the ' .. kind .. ' kind for Droopy Dortwin', function()
            local gs = booted('DroopyDortwin')
            gs:console('gs c ready ' .. kind)
            assert.same({move}, actions(gs))
        end)
    end

    it('is the default move for the pet with no kind named', function()
        local gs = booted('DroopyDortwin')
        gs:console('gs c ready')
        assert.same({'Foot Kick'}, actions(gs))
    end)

    it('is Sic for a pet with no default move', function()
        local gs = booted('FlowerpotMerle')
        gs:console('gs c ready')
        assert.same({'Sic'}, actions(gs))
    end)

    it('is Sic for the default kind of a pet with no default move', function()
        local gs = booted('FlowerpotMerle')
        gs:console('gs c ready default')
        assert.same({'Sic'}, actions(gs))
    end)

    it('is turned down for a kind it doesn\'t know, which is said', function()
        local gs = booted('DroopyDortwin')
        gs:console('gs c ready hug')
        assert.is_true(said(gs, 'Abort: Unknown ready type: hug'))
    end)

    pending('is turned down for a kind it doesn\'t know and nothing else is sent: job_self_command in data/BST.lua '
        .. 'doesn\'t mark ready as handled, so Sel calls handle_ready again, with the kind taken off, and it sends the '
        .. 'default move')

    it('is turned down for a kind the pet has no move of', function()
        local gs = booted('ScissorlegXerin')
        gs:console('gs c ready buff')
        assert.is_true(said(gs, 'Abort: No buff ready move for ScissorlegXerin.'))
        assert.same({}, actions(gs))
    end)

    it('is turned down with no charges', function()
        local gs = booted('DroopyDortwin')
        put_on_recast(gs, 102, 57)
        gs:console('gs c ready')
        assert.is_true(said(gs, 'Abort: No pet charges!'))
        assert.same({}, actions(gs))
    end)

    it('is turned down in town', function()
        local gs = booted('DroopyDortwin')
        gs.user.in_town = true
        gs:console('gs c ready')
        assert.is_true(said(gs, 'Abort:You cannot use ready in town.'))
        assert.same({}, actions(gs))
    end)

    it('has an idle pet fight first, when Jobby has a monster targeted', function()
        local gs = booted('DroopyDortwin', 0)
        gs:console('gs c ready')
        assert.same({'Fight'}, actions(gs))
    end)
end)

describe('BST\'s pet fighting as Jobby engages', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is told to fight the target when it is idle and the target is near', function()
        gs:summon_pet({name = 'DroopyDortwin'})
        gs:traffic()
        gs:engage()
        assert.same({'Fight'}, actions(gs))
    end)

    it('is left alone when it is engaged already', function()
        gs:summon_pet({name = 'DroopyDortwin', status = 1})
        gs:traffic()
        gs:engage()
        assert.same({}, actions(gs))
    end)

    it('is left alone with AutoFightMode off', function()
        gs:summon_pet({name = 'DroopyDortwin'})
        gs:console('gs c toggle AutoFightMode')
        gs:traffic()
        gs:engage()
        assert.same({}, actions(gs))
    end)

    it('is left alone when the target is 20 yalms away or more', function()
        gs:summon_pet({name = 'DroopyDortwin'})
        gs.game.monster.distance = 400
        gs.env.refresh_globals()
        gs:traffic()
        gs:engage()
        assert.same({}, actions(gs))
    end)

    it('is not there to tell when there is none', function()
        gs:engage()
        assert.same({}, actions(gs))
    end)
end)

describe('BST\'s idle set with a pet out', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is the set for the Tank pet mode, over the pet idle set', function()
        gs:summon_pet({name = 'DroopyDortwin'})
        assert.same(with_pet(), gs:worn())
    end)

    it('is the set for the DD pet mode in that mode, once an update has said so', function()
        gs:summon_pet({name = 'DroopyDortwin'})
        gs:console('gs c set PetMode DD')
        gs:console('gs c update')
        assert.same(worn({back = 'Aptitude Mantle', ring2 = 'Moepapa Ring'}), gs:worn())
    end)

    pending('is the set for the DD pet mode as soon as that mode is set: job_state_change in data/BST.lua looks for '
        .. 'the field PetMode, and Sel hands it the mode\'s description, Pet Mode')

    it('is the engaged pet set for the mode, while the pet is engaged', function()
        gs:summon_pet({name = 'DroopyDortwin'})
        gs:set_pet_status(1)
        assert.same(with_pet({waist = 'Prosilio Belt'}), gs:worn())
    end)

    it('is the plain idle set when the pet is gone', function()
        gs:summon_pet({name = 'DroopyDortwin'})
        gs:dismiss_pet()
        assert.same(worn(), gs:worn())
    end)

    it('is the plain idle set when there never was a pet', function()
        assert.same(worn(), gs:worn())
    end)

    it('has the dual wield pet set over it for a character who can dual wield', function()
        can_dual_wield(gs)
        gs:summon_pet({name = 'DroopyDortwin'})
        assert.equal('Aern Sword', gs:worn().sub)
    end)

    it('has the dual wield engaged pet set over it while the pet is engaged, for a character who can dual wield', function()
        can_dual_wield(gs)
        gs:summon_pet({name = 'DroopyDortwin'})
        gs:set_pet_status(1)
        assert.equal('Trainee Sword', gs:worn().sub)
    end)

    it('has no dual wield set over it for a character who can\'t', function()
        gs:summon_pet({name = 'DroopyDortwin'})
        gs:set_pet_status(1)
        assert.is_nil(gs:worn().sub)
    end)

    it('is the pet idle set at once for a pet that was out when GearSwap loaded', function()
        gs = boot({pet = {name = 'DroopyDortwin'}})
        assert.same(with_pet(), gs:worn())
    end)
end)

describe('BST\'s jug pet', function()
    it('is shown when it is chosen', function()
        local gs = boot()
        gs:console('gs c set JugMode DroopyDortwin')
        gs:advance(0.01)
        assert.is_true(said(gs, 'DroopyDortwin: Rabbit, Beast, Warrior'))
    end)

    it('is shown on the command that asks for it', function()
        local gs = boot()
        gs:console('gs c DisplayPetInfo')
        assert.is_true(said(gs, 'ScissorlegXerin: Chapuli, Vermin, Warrior'))
    end)
end)

describe('BST\'s Reward, kept by the tick', function()
    local gs
    before_each(function()
        gs = boot()
        gs:summon_pet({name = 'DroopyDortwin', hpp = 33})
        gs:traffic()
    end)

    it('goes out for a pet under 34% HP', function()
        gs:play(5.5)
        assert.same({'Reward'}, actions(gs))
    end)

    it('waits while the pet has 34% HP', function()
        gs.game.pet.hpp = 34
        gs.env.refresh_globals()
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)

    it('waits while Reward is on recast', function()
        put_on_recast(gs, 103, 30)
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)

    it('waits with AutoRewardMode off', function()
        gs:console('gs c toggle AutoRewardMode')
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)

    it('waits under amnesia', function()
        gs:gain_buff('amnesia')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)

    it('waits under impairment', function()
        gs:gain_buff('impairment')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)

    it('waits without the pet food of the reward mode', function()
        gs = boot({extra_items = {{name = 'Pet Food Zeta', count = 12}}})
        gs:summon_pet({name = 'DroopyDortwin', hpp = 33})
        gs:traffic()
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)

    it('goes out for the food of another reward mode', function()
        gs:console('gs c set RewardMode Zeta')
        gs:play(5.5)
        assert.same({'Reward'}, actions(gs))
    end)
end)

describe('BST\'s pet, called by the tick under AutoCallPet', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c toggle AutoCallPet')
        gs:traffic()
    end)

    it('is called with Bestial Loyalty first', function()
        gs:play(5.5)
        assert.same({'Bestial Loyalty'}, actions(gs))
    end)

    it('is called with Call Beast when Bestial Loyalty is on recast', function()
        put_on_recast(gs, 94, 60)
        gs:play(5.5)
        assert.same({'Call Beast'}, actions(gs))
    end)

    it('is not called when both are on recast', function()
        put_on_recast(gs, 94, 60)
        put_on_recast(gs, 104, 60)
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)

    it('is not called in town', function()
        gs.user.in_town = true
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)

    it('is not called when there is a pet', function()
        gs:summon_pet({name = 'DroopyDortwin'})
        gs:traffic()
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)

    it('is not called with AutoCallPet off', function()
        gs:console('gs c toggle AutoCallPet')
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)
end)

describe('BST\'s ready moves, kept by the tick under AutoReadyMode', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c toggle AutoReadyMode')
    end)

    it('are the default move for an engaged pet with a charge', function()
        gs:summon_pet({name = 'DroopyDortwin', status = 1})
        gs:traffic()
        gs:play(5.5)
        assert.same({'Foot Kick'}, actions(gs))
    end)

    it('are none for an engaged pet with no charge', function()
        gs:summon_pet({name = 'DroopyDortwin', status = 1})
        put_on_recast(gs, 102, 57)
        gs:traffic()
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)

    it('are Fight for an idle pet with a monster targeted', function()
        gs:summon_pet({name = 'DroopyDortwin'})
        gs:traffic()
        gs:play(5.5)
        assert.same({'Fight'}, actions(gs))
    end)

    it('are none with no pet', function()
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)

    it('are none with AutoReadyMode off', function()
        gs:console('gs c toggle AutoReadyMode')
        gs:summon_pet({name = 'DroopyDortwin', status = 1})
        gs:traffic()
        gs:play(5.5)
        assert.same({}, actions(gs))
    end)

    it('are given up on a change of zone', function()
        gs.game:fire('zone change', 100, 288)
        gs.game:settle()
        assert.is_false(gs.user.state.AutoReadyMode.value)
    end)
end)

-- What is worn once the weapon skill is out, with the TP Jobby has.
local function weaponskill(gs, name, tp)
    gs.game.player.vitals.tp = tp
    gs:type('/ws "' .. name .. '" <t>')
    return gs:worn()
end

describe('BST\'s weapon skill sets', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    -- A level 99 beastmaster with a sword and no shield or second weapon is fencing, which adds 400 TP to the 250 of
    -- Moonshade Earring.
    it('keep Moonshade Earring at 3200 TP with its bonus and Fencer\'s', function()
        local set = weaponskill(gs, 'Savage Blade', 2550)
        assert.same({'Moonshade Earring', 'Etiolation Earring'}, {set.left_ear, set.right_ear})
    end)

    it('give way to sets.MaxTP above that', function()
        local set = weaponskill(gs, 'Savage Blade', 2551)
        assert.same({'Ishvara Earring', 'Etiolation Earring'}, {set.left_ear, set.right_ear})
    end)

    it('give way to sets.AccMaxTP above that in an accuracy mode', function()
        gs:console('gs c set OffenseMode Acc')
        local set = weaponskill(gs, 'Savage Blade', 2551)
        assert.same({'Brutal Earring', 'Etiolation Earring'}, {set.left_ear, set.right_ear})
    end)

    it('have sets.DayWSEars over Lugra Earring by day', function()
        local set = weaponskill(gs, 'Cloudsplitter', 1000)
        assert.same({"Hecate's Earring", 'Etiolation Earring'}, {set.left_ear, set.right_ear})
    end)

    it('keep Lugra Earring at night', function()
        gs.game:fire('time change', 22 * 60, 0)
        gs.game:settle()
        local set = weaponskill(gs, 'Cloudsplitter', 1000)
        assert.same({'Lugra Earring +1', 'Etiolation Earring'}, {set.left_ear, set.right_ear})
    end)

    it('have sets.AccDayWSEars over Lugra Earring by day in an accuracy mode', function()
        gs:console('gs c set OffenseMode Acc')
        local set = weaponskill(gs, 'Cloudsplitter', 1000)
        assert.same({'Pixie Earring', 'Etiolation Earring'}, {set.left_ear, set.right_ear})
    end)

    it('have sets.buff.Killer Instinct over them while Killer Instinct is up', function()
        gs:gain_buff('Killer Instinct')
        assert.equal('Aptitude Mantle', weaponskill(gs, 'Savage Blade', 1000).back)
    end)

    it('have none of that without Killer Instinct', function()
        assert.equal('Mecisto. Mantle', weaponskill(gs, 'Savage Blade', 1000).back)
    end)
end)

describe('BST\'s display of its state', function()
    it('names the modes, the reward mode and the correlation mode', function()
        local gs = boot()
        gs:console('gs c update user')
        assert.is_true(said(gs, 'Melee: Normal, WS: Match, Reward: Theta, Correlation: Neutral'))
    end)

    pending('is shown by a gear file that defines no state.ExtraMeleeMode, such as data/Mytha/Mytha_Bst_Gear.lua: '
        .. 'display_current_job_state in data/BST.lua indexes it, which Sel doesn\'t define, and gs c update user, '
        .. 'which the pause key runs, raises an error')
end)
