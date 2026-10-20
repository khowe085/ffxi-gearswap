local jobby = require('jobby')

local gear = {"Judge's Sword", 'Aern Sword', 'Trainee Sword', "Charmer's Merlin", "Tyrant's Ring", 'Moepapa Ring',
    'Mecisto. Mantle', "Bendis's Hairpin", "Theia's Hairpin", 'Sapphire Platemail', 'Jadeite Cuirie',
    'Diamond Haramaki', 'Sapphire Gauntlets', 'Jadeite Gloves', 'Diamond Kote', 'Sapphire Trousers',
    'Jadeite Chausses', 'Diamond Hiza.', 'Sapphire Leggings', 'Jadeite Jambeaux', 'Diamond Sune-Ate',
    "Orunmila's Torque", 'Phrenic Torque', 'Aptitude Mantle', 'Prosilio Belt', 'Moonshade Earring', 'Ishvara Earring',
    'Brutal Earring', 'Lugra Earring +1', "Hecate's Earring", 'Pixie Earring'}

-- What the idle set of Jobby's beastmaster gear file wears besides every gear file's.
local own_idle = {main = "Judge's Sword", back = 'Mecisto. Mantle'}

local idle = jobby.worn_by(own_idle)

-- What is worn with these changes over the idle set.
local function worn(changes)
    return jobby.worn_by(changes, idle)
end

-- The boot options of Jobby as a beastmaster with the idle set on, over a sub job of WAR with three merits in Sic's
-- recast, unless the options say otherwise. options are jobby.boot's, and food: the pet food and jugs in the bags, a
-- dozen of the food of each reward mode (Theta, Zeta and Eta) unless given.
local function boot_options(options)
    options = options or {}
    local items = {}
    for _, name in ipairs(gear) do
        items[#items + 1] = name
    end
    for _, item in ipairs(options.food or {{name = 'Pet Food Theta', count = 12}, {name = 'Pet Food Zeta', count = 12},
        {name = 'Pet Food Eta', count = 12}}) do
        items[#items + 1] = item
    end
    options.food = nil
    options.items = items
    options.wearing = own_idle
    options.sub_job = options.sub_job or 'WAR'
    options.merits = options.merits or {sic_recast = 3}
    return options
end

local function boot(options)
    return jobby.boot('BST', boot_options(options))
end

local function boot_ticking(options)
    return jobby.boot_ticking('BST', boot_options(options))
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
    end)

    -- The count of ready charges Jobby is told he has.
    local function charges()
        gs:console('gs c showcharge')
        local lines = gs:chat()
        assert.equal(1, #lines, table.concat(lines, '\n'))
        return tonumber(lines[1]:match('^~~~Current Ready Charges Available: %[(%d+)%]~~~$'))
    end

    it('are all three when Sic is ready', function()
        assert.equal(3, charges())
    end)

    it('come back one a charge timer, 19 seconds here', function()
        gs.game:start_ability_recast('Sic', 19)
        assert.equal(2, charges())
        gs.game:start_ability_recast('Sic', 20)
        assert.equal(1, charges())
    end)

    it('are none when the recast is all three timers', function()
        gs.game:start_ability_recast('Sic', 57)
        assert.equal(0, charges())
    end)

    it('take 5 seconds less a timer with Charmer\'s Merlin in the ready recast set', function()
        gs.user.sets.midcast.Pet.ReadyRecast.main = "Charmer's Merlin"
        gs.game:start_ability_recast('Sic', 15)
        assert.equal(1, charges())
    end)

    it('take 5 seconds less a timer with Desultor Tassets in the ready recast set', function()
        gs.user.sets.midcast.Pet.ReadyRecast.legs = 'Desultor Tassets'
        gs.game:start_ability_recast('Sic', 15)
        assert.equal(1, charges())
    end)

    it('take 5 seconds less a timer with Gleti\'s Breeches in the ready recast set', function()
        gs.user.sets.midcast.Pet.ReadyRecast.legs = "Gleti's Breeches"
        gs.game:start_ability_recast('Sic', 15)
        assert.equal(1, charges())
    end)

    it('take no less than 10 seconds a timer', function()
        gs.user.sets.midcast.Pet.ReadyRecast.main = "Charmer's Merlin"
        gs.user.sets.midcast.Pet.ReadyRecast.legs = 'Desultor Tassets'
        gs.game:start_ability_recast('Sic', 10)
        assert.equal(2, charges())
        gs.game:start_ability_recast('Sic', 11)
        assert.equal(1, charges())
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
        jobby.can_dual_wield(gs)
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
        jobby.can_dual_wield(gs)
        gs:type('/pet "Spur" <me>')
        assert.same({back = 'Aptitude Mantle', main = "Charmer's Merlin", sub = 'Aern Sword'}, gs:traffic()[1].equip)
    end)
end)

describe('BST\'s Bestial Loyalty and Call Beast', function()
    local function precast(gs, line)
        gs:type(line)
        return gs:traffic()[1].equip
    end

    it('wear the set of the jug pet chosen, with Bestial Loyalty\'s own set over it', function()
        assert.same({head = "Bendis's Hairpin", hands = 'Diamond Kote', legs = 'Diamond Hiza.',
            feet = 'Jadeite Jambeaux'}, precast(boot(), '/ja "Bestial Loyalty" <me>'))
    end)

    it('wear the same sets for Call Beast', function()
        assert.same({head = "Bendis's Hairpin", hands = 'Diamond Kote', legs = 'Diamond Hiza.',
            feet = 'Jadeite Jambeaux'}, precast(boot(), '/ja "Call Beast" <me>'))
    end)

    it('wear the set of the better pet when the jug of it is in the bags', function()
        local gs = boot({food = {{name = 'Bubbly Broth', count = 12}}})
        assert.same({head = "Bendis's Hairpin", hands = 'Jadeite Gloves', legs = 'Diamond Hiza.'},
            precast(gs, '/ja "Bestial Loyalty" <me>'))
    end)

    it('wear the set of the better pet for the other jug too', function()
        local gs = boot({food = {{name = 'Vis. Broth', count = 12}}})
        gs:console('gs c set JugMode DroopyDortwin')
        assert.same({head = "Bendis's Hairpin", hands = 'Sapphire Gauntlets', legs = 'Diamond Hiza.'},
            precast(gs, '/ja "Bestial Loyalty" <me>'))
    end)

    it('wear the set of the jug pet itself without the jug', function()
        local gs = boot({food = {}})
        gs:console('gs c set JugMode DroopyDortwin')
        assert.same({head = "Bendis's Hairpin", hands = 'Diamond Kote', legs = 'Diamond Hiza.'},
            precast(gs, '/ja "Bestial Loyalty" <me>'))
    end)
end)

describe('BST\'s Bestial Loyalty while it is on recast', function()
    it('is Call Beast, and Bestial Loyalty is held back', function()
        local gs = boot()
        gs.game:start_ability_recast('Bestial Loyalty', 60)
        assert.is_true(gs:type('/ja "Bestial Loyalty" <me>'))
        assert.same({'Call Beast'}, gs:actions())
    end)

    it('goes out when it is ready', function()
        local gs = boot()
        gs:type('/ja "Bestial Loyalty" <me>')
        assert.same({'Bestial Loyalty'}, gs:actions())
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
        return gs:actions()
    end

    it('goes out within 6 yalms of the target', function()
        assert.same({'Savage Blade'}, aimed_from(6))
    end)

    it('is cancelled farther away, and Jobby is told', function()
        assert.same({}, aimed_from(6.5))
        assert.same({'Savage Blade Canceled: [Out of Range]'}, gs:chat())
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
        gs:give_pet({name = 'DroopyDortwin'})
        gs:traffic()
    end)

    it('have the ready recast set on before they go out', function()
        gs:type('/pet "Foot Kick" <me>')
        local traffic = gs:traffic()
        assert.same({legs = 'Sapphire Trousers'}, traffic[1].equip)
        assert.equal('Foot Kick', traffic[2].action)
    end)

    it('have the ready recast set of the dual wielder\'s kind for a character who can dual wield', function()
        jobby.can_dual_wield(gs)
        gs:type('/pet "Foot Kick" <me>')
        assert.same({sub = "Charmer's Merlin"}, gs:traffic()[1].equip)
    end)
end)

describe('BST\'s ready moves, once the command is done', function()
    local gs
    before_each(function()
        gs = boot()
        gs:give_pet({name = 'DroopyDortwin'})
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
        assert.same({}, gs:chat())
        gs:advance(0.5)
        assert.same({'~~~Current Ready Charges Available: [3]~~~'}, gs:chat())
    end)
end)

describe('BST\'s TP bonus set for a ready move', function()
    -- The feet worn once the command for Choke Breath is done, Daring Roland, a Thief, having this much TP.
    local function feet_after(tp)
        local gs = boot()
        gs:give_pet({name = 'DaringRoland'})
        gs:set_pet_tp(tp)
        gs:traffic()
        gs:type('/pet "Choke Breath" <me>')
        gs:finish_action()
        return gs:worn().feet
    end

    it('is on while a pet of a job other than Warrior has under 2400 TP', function()
        assert.equal('Sapphire Leggings', feet_after(2399))
    end)

    it('is off from 2400 TP', function()
        assert.equal('Nyame Sollerets', feet_after(2400))
    end)

    pending('is off from 1900 TP for a Warrior pet, such as Droopy Dortwin, as job_post_aftercast in data/BST.lua '
        .. 'means: it reads PetJob, which nothing sets, so a pet of every job has the set on up to 2400 TP')
end)

describe('BST\'s Unleash', function()
    local gs
    before_each(function()
        gs = boot()
        gs:give_pet({name = 'DroopyDortwin'})
        gs:gain_buff('Unleash')
        gs:traffic()
        gs:chat()
    end)

    local function move(line)
        gs:type(line)
        gs:finish_action()
        return gs:worn()
    end

    it('locks the ready set in place with the first move, and says so', function()
        move('/pet "Foot Kick" <me>')
        assert.same({'Unleash is on, locking your current Ready set.'}, gs:chat())
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
        gs:chat()
        gs:lose_buff('Unleash')
        assert.same({'Unleash has worn, enabling all slots.'}, gs:chat())
        assert.equal('Nyame Mail', gs:worn().body)
    end)

    it('locks nothing when told not to, which is said', function()
        gs:console('gs c unleashlock')
        assert.same({'Unleash no longer locks gear.'}, gs:chat())
        move('/pet "Foot Kick" <me>')
        gs:pet_readies('Foot Kick')
        gs:pet_finishes('Foot Kick')
        assert.equal('Nyame Mail', gs:worn().body)
    end)

    it('locks again when told to, which is said', function()
        gs:console('gs c unleashlock')
        gs:console('gs c unleashlock')
        assert.same({'Unleash no longer locks gear.', 'Unleash now locks gear.'}, gs:chat())
        move('/pet "Foot Kick" <me>')
        gs:pet_readies('Foot Kick')
        gs:pet_finishes('Foot Kick')
        assert.equal('Sapphire Platemail', gs:worn().body)
    end)
end)

describe('BST\'s ready command', function()
    local function booted(pet_name, status)
        local gs = boot_ticking()
        gs:give_pet({name = pet_name, status = status or 1})
        gs:traffic()
        gs:chat()
        return gs
    end

    -- The actions that go out on the command and on the tick after it.
    local function sent(gs, command)
        gs:console(command)
        gs:play(6)
        return gs:actions()
    end

    for _, case in ipairs({{'aoe', 'Whirl Claws'}, {'buff', 'Wild Carrot'}, {'debuff', 'Dust Cloud'},
        {'magical', 'Dust Cloud'}}) do
        local kind, move = case[1], case[2]
        it('is ' .. move .. ' of the ' .. kind .. ' kind for Droopy Dortwin, and his default move on the next tick',
            function()
                assert.same({move, 'Foot Kick'}, sent(booted('DroopyDortwin'), 'gs c ready ' .. kind))
            end)
    end

    for _, kind in ipairs({'physical', 'default'}) do
        it('is Foot Kick of the ' .. kind .. ' kind for Droopy Dortwin, his default move, once', function()
            assert.same({'Foot Kick'}, sent(booted('DroopyDortwin'), 'gs c ready ' .. kind))
        end)
    end

    it('is the default move for the pet with no kind named, once', function()
        assert.same({'Foot Kick'}, sent(booted('DroopyDortwin'), 'gs c ready'))
    end)

    it('is Sic for a pet with no default move', function()
        assert.same({'Sic'}, sent(booted('FlowerpotMerle'), 'gs c ready'))
    end)

    it('is Sic for the default kind of a pet with no default move', function()
        assert.same({'Sic'}, sent(booted('FlowerpotMerle'), 'gs c ready default'))
    end)

    it('is turned down for a kind it doesn\'t know, which is said, and the default move goes out instead', function()
        local gs = booted('DroopyDortwin')
        assert.same({'Foot Kick'}, sent(gs, 'gs c ready hug'))
        assert.same({'Abort: Unknown ready type: hug'}, gs:chat())
    end)

    it('is turned down for a kind the pet has no move of, which is said, and its default move goes out instead',
        function()
            local gs = booted('ScissorlegXerin')
            assert.same({'Sensilla Blades'}, sent(gs, 'gs c ready buff'))
            assert.same({'Abort: No buff ready move for ScissorlegXerin.'}, gs:chat())
        end)

    it('is turned down with no charges, which is said twice', function()
        local gs = booted('DroopyDortwin')
        gs.game:start_ability_recast('Sic', 57)
        assert.same({}, sent(gs, 'gs c ready'))
        assert.same({'Abort: No pet charges!', 'Abort: No pet charges!'}, gs:chat())
    end)

    it('is turned down in town, which is said twice', function()
        local gs = booted('DroopyDortwin')
        gs.user.in_town = true
        assert.same({}, sent(gs, 'gs c ready'))
        assert.same({'Abort:You cannot use ready in town.', 'Abort:You cannot use ready in town.'}, gs:chat())
    end)

    it('has an idle pet fight when Jobby has a monster targeted, and the default move go out on the next tick',
        function()
            assert.same({'Fight', 'Foot Kick'}, sent(booted('DroopyDortwin', 0), 'gs c ready'))
        end)

    pending('sends the move of the kind named alone, nothing for a kind it doesn\'t know or one the pet has no move '
        .. 'of, and only Fight for an idle pet, and says once why it is turned down: job_self_command in data/BST.lua '
        .. 'doesn\'t mark ready as handled, so Sel calls handle_ready again with the kind taken off, which sends the '
        .. 'default move, or says again why not')
end)

describe('BST\'s pet fighting as Jobby engages', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is told to fight the target when it is idle and the target is near', function()
        gs:give_pet({name = 'DroopyDortwin'})
        gs:traffic()
        gs:engage()
        assert.same({'Fight'}, gs:actions())
    end)

    it('is left alone when it is engaged already', function()
        gs:give_pet({name = 'DroopyDortwin', status = 1})
        gs:traffic()
        gs:engage()
        assert.same({}, gs:actions())
    end)

    it('is left alone with AutoFightMode off', function()
        gs:give_pet({name = 'DroopyDortwin'})
        gs:console('gs c toggle AutoFightMode')
        gs:traffic()
        gs:engage()
        assert.same({}, gs:actions())
    end)

    it('is left alone when the target is 20 yalms away or more', function()
        gs:give_pet({name = 'DroopyDortwin'})
        gs.game.monster.distance = 400
        gs.env.refresh_globals()
        gs:traffic()
        gs:engage()
        assert.same({}, gs:actions())
    end)

    it('is not there to tell when there is none', function()
        gs:engage()
        assert.same({}, gs:actions())
    end)
end)

describe('BST\'s idle set with a pet out', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is the set for the Tank pet mode, over the pet idle set', function()
        gs:give_pet({name = 'DroopyDortwin'})
        assert.same(with_pet(), gs:worn())
    end)

    it('is the set for the DD pet mode in that mode, once an update has said so', function()
        gs:give_pet({name = 'DroopyDortwin'})
        gs:console('gs c set PetMode DD')
        gs:console('gs c update')
        assert.same(worn({back = 'Aptitude Mantle', ring2 = 'Moepapa Ring'}), gs:worn())
    end)

    pending('is the set for the DD pet mode as soon as that mode is set: job_state_change in data/BST.lua looks for '
        .. 'the field PetMode, and Sel hands it the mode\'s description, Pet Mode')

    it('is the engaged pet set for the mode, while the pet is engaged', function()
        gs:give_pet({name = 'DroopyDortwin'})
        gs:set_pet_status(1)
        assert.same(with_pet({waist = 'Prosilio Belt'}), gs:worn())
    end)

    it('is the plain idle set when the pet is gone', function()
        gs:give_pet({name = 'DroopyDortwin'})
        gs:take_pet()
        assert.same(worn(), gs:worn())
    end)

    it('is the plain idle set when there never was a pet', function()
        assert.same(worn(), gs:worn())
    end)

    it('has the dual wield pet set over it for a character who can dual wield', function()
        jobby.can_dual_wield(gs)
        gs:give_pet({name = 'DroopyDortwin'})
        assert.equal('Aern Sword', gs:worn().sub)
    end)

    it('has the dual wield engaged pet set over it while the pet is engaged, for a character who can dual wield', function()
        jobby.can_dual_wield(gs)
        gs:give_pet({name = 'DroopyDortwin'})
        gs:set_pet_status(1)
        assert.equal('Trainee Sword', gs:worn().sub)
    end)

    it('has no dual wield set over it for a character who can\'t', function()
        gs:give_pet({name = 'DroopyDortwin'})
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
        assert.same({'Jug Mode is now DroopyDortwin.', 'DroopyDortwin: Rabbit, Beast, Warrior'}, gs:chat())
    end)

    it('is shown on the command that asks for it', function()
        local gs = boot()
        gs:console('gs c DisplayPetInfo')
        assert.same({'ScissorlegXerin: Chapuli, Vermin, Warrior'}, gs:chat())
    end)
end)

describe('BST\'s Reward, kept by the tick', function()
    local gs
    before_each(function()
        gs = boot()
        gs:give_pet({name = 'DroopyDortwin', hpp = 33})
        gs:traffic()
    end)

    it('goes out for a pet under 34% HP', function()
        gs:play(5.5)
        assert.same({'Reward'}, gs:actions())
    end)

    it('waits while the pet has 34% HP', function()
        gs.game.pet.hpp = 34
        gs.env.refresh_globals()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('waits while Reward is on recast', function()
        gs.game:start_ability_recast('Reward', 30)
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('waits with AutoRewardMode off', function()
        gs:console('gs c toggle AutoRewardMode')
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('waits under amnesia', function()
        gs:gain_buff('amnesia')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('waits under impairment', function()
        gs:gain_buff('impairment')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    -- With only Pet Food Zeta in the bags, so that the food looked for is the reward mode's.
    local function with_zeta_only()
        gs = boot({food = {{name = 'Pet Food Zeta', count = 12}}})
        gs:give_pet({name = 'DroopyDortwin', hpp = 33})
        gs:traffic()
    end

    it('waits without the pet food of the reward mode', function()
        with_zeta_only()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('goes out for the food of another reward mode', function()
        with_zeta_only()
        gs:console('gs c set RewardMode Zeta')
        gs:play(5.5)
        assert.same({'Reward'}, gs:actions())
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
        assert.same({'Bestial Loyalty'}, gs:actions())
    end)

    it('is called with Call Beast when Bestial Loyalty is on recast', function()
        gs.game:start_ability_recast('Bestial Loyalty', 60)
        gs:play(5.5)
        assert.same({'Call Beast'}, gs:actions())
    end)

    it('is not called when both are on recast', function()
        gs.game:start_ability_recast('Bestial Loyalty', 60)
        gs.game:start_ability_recast('Call Beast', 60)
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('is not called in town', function()
        gs.user.in_town = true
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('is not called when there is a pet', function()
        gs:give_pet({name = 'DroopyDortwin'})
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('is not called with AutoCallPet off', function()
        gs:console('gs c toggle AutoCallPet')
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)
end)

describe('BST\'s ready moves, kept by the tick under AutoReadyMode', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c toggle AutoReadyMode')
    end)

    it('are the default move for an engaged pet with a charge', function()
        gs:give_pet({name = 'DroopyDortwin', status = 1})
        gs:traffic()
        gs:play(5.5)
        assert.same({'Foot Kick'}, gs:actions())
    end)

    it('are none for an engaged pet with no charge', function()
        gs:give_pet({name = 'DroopyDortwin', status = 1})
        gs.game:start_ability_recast('Sic', 57)
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('are Fight for an idle pet with a monster targeted', function()
        gs:give_pet({name = 'DroopyDortwin'})
        gs:traffic()
        gs:play(5.5)
        assert.same({'Fight'}, gs:actions())
    end)

    it('are none with no pet', function()
        gs:play(5.5)
        assert.same({}, gs:actions())
    end)

    it('are none with AutoReadyMode off', function()
        gs:console('gs c toggle AutoReadyMode')
        gs:give_pet({name = 'DroopyDortwin', status = 1})
        gs:traffic()
        gs:play(5.5)
        assert.same({}, gs:actions())
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

    -- A level 99 beastmaster with a sword and no shield or second weapon is fencing, which adds the 400 TP of its
    -- third tier to the 250 of Moonshade Earring; Sel counts none of the job point gifts (see the pending below).
    it('keep Moonshade Earring at 3200 TP with its bonus and Fencer\'s', function()
        local set = weaponskill(gs, 'Savage Blade', 2550)
        assert.same({'Moonshade Earring', 'Etiolation Earring'}, {set.left_ear, set.right_ear})
    end)

    it('give way to sets.MaxTP above that', function()
        local set = weaponskill(gs, 'Savage Blade', 2551)
        assert.same({'Ishvara Earring', 'Etiolation Earring'}, {set.left_ear, set.right_ear})
    end)

    pending('give way to sets.MaxTP from 2321 TP, as Fencer\'s job point gifts add 230 TP more at the 2100 job '
        .. 'points spent: get_fencer_gifts in libs/Sel-Utility.lua walks the gift tiers with ipairs, and they are '
        .. 'keyed by the job points spent, so it finds none')

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
        gs:set_time(22 * 60)
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
        assert.same({'Melee: Normal, WS: Match, Reward: Theta, Correlation: Neutral'}, gs:chat())
    end)

    pending('is shown by a gear file that defines no state.ExtraMeleeMode, such as data/Mytha/Mytha_Bst_Gear.lua: '
        .. 'display_current_job_state in data/BST.lua indexes it, which Sel doesn\'t define, and gs c update user, '
        .. 'which the pause key runs, raises an error')
end)
