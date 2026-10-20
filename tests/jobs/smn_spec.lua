local jobby = require('jobby')

local gear = {"Judge's Sword", 'Mecisto. Mantle', "Bendis's Hairpin", "Theia's Hairpin", 'Volte Cap',
    'Sapphire Platemail', 'Jadeite Cuirie', 'Diamond Haramaki', 'Ruby Robe', 'Volte Jupon', 'Sapphire Gauntlets',
    'Jadeite Gloves', 'Diamond Kote', 'Sapphire Trousers', 'Jadeite Chausses', 'Diamond Hiza.', 'Volte Hose',
    'Sapphire Leggings', 'Jadeite Jambeaux', 'Diamond Sune-Ate', 'Volte Boots', "Orunmila's Torque", 'Phrenic Torque',
    'Aptitude Mantle', 'Null Shawl', 'Prosilio Belt', "Tyrant's Ring", 'Ishvara Earring', 'Brutal Earring'}

-- What the idle set of Jobby's summoner gear file wears besides every gear file's.
local own_idle = {main = "Judge's Sword", back = 'Mecisto. Mantle'}

local idle = jobby.worn_by(own_idle)

-- What is worn with these changes over the idle set.
local function worn(changes)
    return jobby.worn_by(changes, idle)
end

-- Jobby as a summoner with the idle set on, over a sub job of RDM unless the options (jobby.boot's) say otherwise.
local function boot(options)
    options = options or {}
    options.items = gear
    options.wearing = own_idle
    options.sub_job = options.sub_job or 'RDM'
    return jobby.boot('SMN', options)
end

describe('data/SMN.lua', function()
    it('starts with no Pact Spam, Auto Favor and Auto Convert on', function()
        local gs = boot()
        assert.is_false(gs.user.state.PactSpamMode.value)
        assert.is_true(gs.user.state.AutoFavor.value)
        assert.is_true(gs.user.state.AutoConvert.value)
    end)
end)

describe('SMN\'s summoning', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('goes out when no avatar is out', function()
        gs:type('/ma "Ifrit" <me>')
        assert.same({'Ifrit'}, jobby.actions(gs))
    end)

    it('is turned down for the avatar that is out, while it has more than 50% HP', function()
        gs:give_pet({name = 'Ifrit', hpp = 51})
        gs:traffic()
        jobby.chat(gs)
        assert.is_true(gs:type('/ma "Ifrit" <me>'))
        assert.same({}, jobby.actions(gs))
        assert.same({'You already have that avatar active!'}, jobby.chat(gs))
    end)

    it('releases the avatar that is out first when it has 50% HP or less, and summons it again', function()
        gs:give_pet({name = 'Ifrit', hpp = 50})
        gs:traffic()
        gs:type('/ma "Ifrit" <me>')
        assert.same({'Release'}, jobby.actions(gs))
        gs:take_pet()
        gs:traffic()
        gs:advance(2)
        assert.same({'Ifrit'}, jobby.actions(gs))
    end)

    it('releases the avatar that is out first for another avatar, and summons that', function()
        gs:give_pet({name = 'Ifrit'})
        gs:traffic()
        gs:type('/ma "Garuda" <me>')
        assert.same({'Release'}, jobby.actions(gs))
        gs:take_pet()
        gs:traffic()
        gs:advance(2)
        assert.same({'Garuda'}, jobby.actions(gs))
    end)

    it('goes out for a spirit with an avatar out, which only another avatar waits on', function()
        gs:give_pet({name = 'Ifrit'})
        gs:traffic()
        gs:type('/ma "Fire Spirit" <me>')
        assert.same({'Fire Spirit'}, jobby.actions(gs))
    end)
end)

describe('SMN\'s blood pact with Astral Conduit up and not enough MP for it twice over', function()
    local gs
    before_each(function()
        gs = boot()
        gs:give_pet({name = 'Ifrit'})
        gs:gain_buff('Astral Conduit')
        gs.game.player.vitals.mp = 300
        gs:traffic()
        jobby.chat(gs)
    end)

    it('goes out, and Myrkr after it with the TP for Myrkr, which is said', function()
        gs.game.player.vitals.tp = 1000
        gs:type('/pet "Flaming Crush" <t>')
        assert.same({'Not enough MP to Pact while using Conduit, using Myrkr!'}, jobby.chat(gs))
        assert.same({'Flaming Crush'}, jobby.actions(gs))
        assert.same({'Myrkr'}, jobby.action_names(jobby.until_action(gs)))
    end)

    it('is Convert, not Myrkr, with less than 1000 TP', function()
        gs.game.player.vitals.tp = 999
        gs:type('/pet "Flaming Crush" <t>')
        assert.same({'Not enough MP to Pact while using Conduit, Converting!'}, jobby.chat(gs))
        assert.same({'Convert'}, jobby.actions(gs))
    end)

    it('is Convert with a sub job of RDM and Convert ready', function()
        gs:type('/pet "Flaming Crush" <t>')
        assert.same({'Not enough MP to Pact while using Conduit, Converting!'}, jobby.chat(gs))
        assert.same({'Convert'}, jobby.actions(gs))
    end)

    it('is Convert only with AutoConvert on', function()
        gs:console('gs c toggle AutoConvert')
        gs:type('/pet "Flaming Crush" <t>')
        assert.same({'Flaming Crush'}, jobby.actions(gs))
    end)

    it('is the pact itself when Convert is on recast', function()
        gs.game:start_ability_recast('Convert', 60)
        gs:type('/pet "Flaming Crush" <t>')
        assert.same({'Flaming Crush'}, jobby.actions(gs))
    end)

    it('is the pact itself when there is MP for it twice over', function()
        gs.game.player.vitals.mp = 329
        gs:type('/pet "Flaming Crush" <t>')
        assert.same({'Flaming Crush'}, jobby.actions(gs))
    end)
end)

-- What Jobby wears with Ifrit out on an Iceday: the avatar set of the pet idle sets, which is the deepest of them, and
-- the perpetuation set of Ifrit over it.
local ifrit_idle = {back = 'Aptitude Mantle', feet = 'Sapphire Leggings', legs = 'Sapphire Trousers'}

local function with_ifrit(changes)
    local set = {}
    for slot, item in pairs(ifrit_idle) do
        set[slot] = item
    end
    for slot, item in pairs(changes or {}) do
        set[slot] = item
    end
    return worn(set)
end

describe('SMN\'s blood pacts, once the pact is done', function()
    local gs
    before_each(function()
        gs = boot()
        gs:set_day(4)
        gs:give_pet({name = 'Ifrit'})
        gs:traffic()
    end)

    local function pact(line)
        gs:type(line)
        gs:finish_action()
        return gs:worn()
    end

    it('wear the set of the pact\'s name, with the avatar\'s set of the pact\'s map over it, magical for Flaming Crush', function()
        assert.same(with_ifrit({hands = 'Diamond Kote', legs = 'Jadeite Chausses'}), pact('/pet "Flaming Crush" <t>'))
    end)

    it('wear the physical pact set of the map and of the avatar, when the pact has no set of its own', function()
        assert.same(with_ifrit({body = 'Sapphire Platemail', legs = 'Volte Hose'}),
            pact('/pet "Poison Nails" <t>'))
    end)

    it('wear the magical pact set of the map and of the avatar for a magical pact', function()
        assert.same(with_ifrit({body = 'Jadeite Cuirie', legs = 'Jadeite Chausses'}),
            pact('/pet "Meteor Strike" <t>'))
    end)

    it('wear the ward set for a ward on Jobby, and the avatar\'s ward set is left out', function()
        assert.same(with_ifrit({body = 'Diamond Haramaki'}), pact('/pet "Inferno Howl" <me>'))
    end)

    it('wear the ward set and the avatar\'s ward set for a ward on a monster', function()
        assert.same(with_ifrit({body = 'Diamond Haramaki', legs = 'Diamond Hiza.'}), pact('/pet "Lunar Cry" <t>'))
    end)

    it('wear the AM set of the pact\'s name over the rest with Aftermath level 3', function()
        gs:gain_buff('Aftermath: Lv.3')
        assert.same(with_ifrit({hands = 'Diamond Kote', legs = 'Jadeite Chausses', waist = 'Prosilio Belt'}), pact('/pet "Flaming Crush" <t>'))
    end)

    it('wear the AM set of the map with Aftermath level 3, when the pact has no AM set of its own', function()
        gs:gain_buff('Aftermath: Lv.3')
        assert.same(with_ifrit({body = 'Sapphire Platemail', legs = 'Volte Hose', hands = 'Jadeite Gloves'}),
            pact('/pet "Poison Nails" <t>'))
    end)

    it('wear no AM set with Aftermath of a lower level', function()
        gs:gain_buff('Aftermath: Lv.2')
        assert.same(with_ifrit({hands = 'Diamond Kote', legs = 'Jadeite Chausses'}), pact('/pet "Flaming Crush" <t>'))
    end)

    it('wear the Acc set of the pact\'s name in the Resistant casting mode', function()
        gs:console('gs c set CastingMode Resistant')
        assert.same(with_ifrit({hands = 'Diamond Kote', legs = 'Jadeite Chausses', back = 'Null Shawl'}),
            pact('/pet "Flaming Crush" <t>'))
    end)

    it('wear the Acc set of the map in the Resistant casting mode, when the pact has no Acc set of its own', function()
        gs:console('gs c set CastingMode Resistant')
        assert.same(with_ifrit({body = 'Sapphire Platemail', legs = 'Volte Hose', feet = 'Volte Boots'}),
            pact('/pet "Poison Nails" <t>'))
    end)

    it('wear the Acc set of the map for a magical pact in the Resistant casting mode', function()
        gs:console('gs c set CastingMode Resistant')
        assert.same(with_ifrit({body = 'Jadeite Cuirie', legs = 'Jadeite Chausses', feet = 'Jadeite Jambeaux'}),
            pact('/pet "Meteor Strike" <t>'))
    end)

    it('wear no pet set while a defense mode is on, which leaves the idle set', function()
        gs:console('gs c set DefenseMode Physical')
        assert.same(with_ifrit({}), pact('/pet "Flaming Crush" <t>'))
    end)

    it('give way to the avatar\'s idle set once the avatar is done with the pact', function()
        pact('/pet "Flaming Crush" <t>')
        gs:pet_readies('Flaming Crush', 'ability')
        gs:pet_finishes('Flaming Crush', 'ability')
        assert.same(with_ifrit(), gs:worn())
    end)
end)

describe('SMN\'s Astral Conduit', function()
    local gs
    before_each(function()
        gs = boot()
        gs:set_day(4)
        gs:give_pet({name = 'Ifrit'})
        gs:gain_buff('Astral Conduit')
        gs:traffic()
        jobby.chat(gs)
    end)

    local function pact(line)
        gs:type(line)
        gs:finish_action()
        return gs:worn()
    end

    it('locks the set of the pact in its slots, which the avatar\'s idle set can\'t change', function()
        pact('/pet "Flaming Crush" <t>')
        assert.same({'Astral Conduit on, locking your Flaming Crush set.'}, jobby.chat(gs))
        gs:set_pet_status(1)
        assert.equal('Diamond Kote', gs:worn().hands)
    end)

    it('lets the engaged avatar\'s idle set change the slots of the pact when it doesn\'t lock them', function()
        gs:console('gs c conduitlock')
        pact('/pet "Flaming Crush" <t>')
        gs:set_pet_status(1)
        assert.equal('Jadeite Gloves', gs:worn().hands)
    end)

    it('can be told not to lock, and told to lock again, which is said', function()
        gs:console('gs c conduitlock')
        assert.same({'Astral Conduit no longer locks gear.'}, jobby.chat(gs))
        gs:console('gs c conduitlock')
        assert.same({'Astral Conduit now locks gear.'}, jobby.chat(gs))
        pact('/pet "Flaming Crush" <t>')
        gs:set_pet_status(1)
        assert.equal('Diamond Kote', gs:worn().hands)
    end)

    it('lets go of the slots when it wears off', function()
        pact('/pet "Flaming Crush" <t>')
        gs:set_pet_status(1)
        gs:advance(3)
        jobby.chat(gs)
        gs:lose_buff('Astral Conduit')
        assert.same({'Astral Conduit has worn, enabling all slots.'}, jobby.chat(gs))
        assert.equal('Jadeite Gloves', gs:worn().hands)
    end)

    it('locks the set of another pact, instead of the first one\'s', function()
        pact('/pet "Flaming Crush" <t>')
        gs:advance(4)
        gs:traffic()
        jobby.chat(gs)
        pact('/pet "Poison Nails" <t>')
        assert.same({'Astral Conduit on, locking your Poison Nails set.'}, jobby.chat(gs))
        gs:set_pet_status(1)
        assert.same({'Jadeite Gloves', 'Sapphire Platemail'}, {gs:worn().hands, gs:worn().body})
    end)

    pending('lets go of the slots when the avatar is released: job_pet_change only enables them when the offense mode '
        .. 'is None, which no gear file sets, and Astral Conduit wearing off then finds nothing locked')
end)

describe('SMN\'s spirits', function()
    local gs
    before_each(function()
        gs = boot()
        gs:set_day(4)
        gs:give_pet({name = 'FireSpirit'})
        gs:traffic()
    end)

    it('have the pet midcast set of their spell\'s skill on while the spell is cast', function()
        gs:pet_readies('Fire', 'spell')
        assert.equal("Orunmila's Torque", gs:worn().neck)
    end)

    it('have the casting mode\'s set in that casting mode', function()
        gs:console('gs c set CastingMode Resistant')
        gs:pet_readies('Fire', 'spell')
        assert.equal('Phrenic Torque', gs:worn().neck)
    end)

    it('give way to the idle set once the spell is cast', function()
        gs:pet_readies('Fire', 'spell')
        gs:pet_finishes('Fire', 'spell')
        assert.equal('Loricate Torque +1', gs:worn().neck)
    end)

    it('wear a spirit\'s idle set, over the pet\'s', function()
        assert.same(worn({back = 'Aptitude Mantle', feet = 'Jadeite Jambeaux'}), gs:worn())
    end)
end)

describe('SMN\'s avatars', function()
    it('have no pet midcast set on while their pact is being readied', function()
        local gs = boot()
        gs:set_day(4)
        gs:give_pet({name = 'Ifrit'})
        gs:traffic()
        gs:pet_readies('Flaming Crush', 'ability')
        assert.same(worn({back = 'Aptitude Mantle', feet = 'Sapphire Leggings', legs = 'Sapphire Trousers'}),
            gs:worn())
    end)
end)

describe('SMN\'s Pact Spam Mode', function()
    local gs
    before_each(function()
        gs = boot()
        gs:give_pet({name = 'Ifrit'})
        gs:console('gs c toggle PactSpamMode')
        gs:traffic()
    end)

    it('has the avatar do its rage pact again once it is done', function()
        gs:pet_readies('Poison Nails', 'ability')
        gs:pet_finishes('Poison Nails', 'ability')
        assert.same({'Poison Nails'}, jobby.actions(gs))
    end)

    it('waits for the pact recast', function()
        gs.game:start_ability_recast('Poison Nails', 30)
        gs:pet_readies('Poison Nails', 'ability')
        gs:pet_finishes('Poison Nails', 'ability')
        assert.same({}, jobby.actions(gs))
    end)

    it('is for rage pacts only', function()
        gs:pet_readies('Inferno Howl', 'ability', {target = 'player'})
        gs:pet_finishes('Inferno Howl', 'ability', {target = 'player'})
        assert.same({}, jobby.actions(gs))
    end)

    it('does nothing when it is off', function()
        gs:console('gs c toggle PactSpamMode')
        gs:pet_readies('Poison Nails', 'ability')
        gs:pet_finishes('Poison Nails', 'ability')
        assert.same({}, jobby.actions(gs))
    end)
end)

describe('SMN\'s idle set with an avatar out', function()
    local gs
    before_each(function()
        gs = boot()
        gs:set_day(4)
        gs:give_pet({name = 'Ifrit'})
        gs:traffic()
    end)

    it('is the avatar set of the pet idle sets with Ifrit\'s perpetuation set over it', function()
        assert.same(worn({back = 'Aptitude Mantle', feet = 'Sapphire Leggings', legs = 'Sapphire Trousers'}),
            gs:worn())
    end)

    it('has sets.perp.Day over it when the avatar\'s element is the day\'s', function()
        gs:set_day(0)
        gs:console('gs c update')
        assert.equal("Bendis's Hairpin", gs:worn().head)
    end)

    it('has no sets.perp.Day over it on another day', function()
        assert.equal('Nyame Helm', gs:worn().head)
    end)

    it('has sets.perp.Weather over it when the avatar\'s element is the weather\'s', function()
        gs:set_weather(4)
        gs:console('gs c update')
        assert.equal("Tyrant's Ring", gs:worn().left_ring)
    end)

    it('has the Favor set over it while Avatar\'s Favor is up', function()
        gs:gain_buff("Avatar's Favor")
        assert.equal("Orunmila's Torque", gs:worn().neck)
    end)

    it('has the engaged avatar set over it, and Ifrit\'s over that, once the avatar is engaged', function()
        gs:set_pet_status(1)
        assert.same(worn({back = 'Aptitude Mantle', waist = 'Prosilio Belt', feet = 'Diamond Sune-Ate',
            legs = 'Sapphire Trousers', hands = 'Jadeite Gloves'}), gs:worn())
    end)

    it('goes without the engaged set again once the avatar is idle', function()
        gs:set_pet_status(1)
        gs:set_pet_status(0)
        assert.equal('Nyame Gauntlets', gs:worn().hands)
        assert.equal('Plat. Mog. Belt', gs:worn().waist)
    end)

    it('is the plain idle set again once the avatar is gone', function()
        gs:take_pet()
        assert.same(worn(), gs:worn())
    end)
end)

describe('SMN\'s idle set with no avatar out', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('has sets.latent_refresh over it under 51% MP', function()
        gs.game.player.vitals.mpp = 50
        gs:console('gs c update')
        assert.equal('Ishvara Earring', gs:worn().left_ear)
    end)

    it('has no sets.latent_refresh over it from 51% MP', function()
        gs.game.player.vitals.mpp = 51
        gs:console('gs c update')
        assert.equal('Etiolation Earring', gs:worn().left_ear)
    end)

    it('has sets.buff.Sublimation over it while Sublimation is charging', function()
        gs:gain_buff('Sublimation: Activated')
        assert.equal('Brutal Earring', gs:worn().right_ear)
    end)
end)

describe('SMN\'s casting in the Proc casting mode', function()
    it('takes the Proc sets for a spell, in place of the sets of its own', function()
        local gs = boot()
        gs:console('gs c set CastingMode Proc')
        gs:type('/ma "Cure III" <me>')
        assert.equal("Theia's Hairpin", gs:traffic()[1].equip.head)
        assert.equal('Ruby Robe', gs:worn().body)
    end)

    it('takes the spell\'s own sets in another mode', function()
        local gs = boot()
        gs:type('/ma "Cure III" <me>')
        assert.equal('Volte Cap', gs:traffic()[1].equip.head)
        assert.equal('Volte Jupon', gs:worn().body)
    end)
end)

describe('SMN\'s pact command', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('needs an avatar', function()
        gs:console('gs c pact cure')
        assert.same({'Abort: You do not have an Avatar summoned.'}, jobby.chat(gs))
    end)

    it('is refused for a spirit', function()
        gs:give_pet({name = 'FireSpirit'})
        jobby.chat(gs)
        gs:console('gs c pact cure')
        assert.same({'Abort: Spirits cannot use blood pacts.'}, jobby.chat(gs))
    end)

    it('is refused in town', function()
        gs:give_pet({name = 'Carbuncle'})
        jobby.chat(gs)
        gs.user.in_town = true
        gs:console('gs c pact cure')
        assert.same({'Abort:You cannot use pacts in town.'}, jobby.chat(gs))
    end)

    it('needs a type of pact', function()
        gs:give_pet({name = 'Carbuncle'})
        jobby.chat(gs)
        gs:console('gs c pact')
        assert.same({'Abort: No blood pact type given.'}, jobby.chat(gs))
    end)

    it('is refused for a type it doesn\'t know', function()
        gs:give_pet({name = 'Carbuncle'})
        jobby.chat(gs)
        gs:console('gs c pact hug')
        assert.same({'Abort: Unknown blood pact type: hug'}, jobby.chat(gs))
    end)

    it('is refused for a type the avatar has no pact of', function()
        gs:give_pet({name = 'Garuda'})
        jobby.chat(gs)
        gs:console('gs c pact cure')
        assert.same({'Abort: Garuda does not have a pact of type [cure].'}, jobby.chat(gs))
    end)

    it('names the avatar\'s pact of that type, with no target for Shortcuts to aim', function()
        gs:give_pet({name = 'Carbuncle'})
        gs:console('gs c pact cure')
        assert.same({'/pet "Healing Ruby"'}, jobby.typed(gs))
    end)

    it('names the avatar\'s pact of a type with its own avatars', function()
        gs:give_pet({name = 'Ifrit'})
        gs:console('gs c pact buffspecial')
        assert.same({'/pet "Inferno Howl"'}, jobby.typed(gs))
    end)

    it('needs Astral Flow up for an astral flow pact', function()
        gs:give_pet({name = 'Carbuncle'})
        jobby.chat(gs)
        gs:console('gs c pact astralflow')
        assert.same({'Abort: Astral Flow not active.'}, jobby.chat(gs))
        assert.same({}, jobby.typed(gs))
    end)

    it('names the astral flow pact with Astral Flow up', function()
        gs:give_pet({name = 'Carbuncle'})
        gs:gain_buff('Astral Flow')
        gs:console('gs c pact astralflow')
        assert.same({'/pet "Searing Light"'}, jobby.typed(gs))
    end)
end)

describe('SMN\'s petweather command', function()
    it('casts the storm of the avatar\'s element with a sub job of SCH', function()
        local gs = boot({sub_job = 'SCH'})
        gs:give_pet({name = 'Ifrit'})
        gs:console('gs c petweather')
        assert.same({'Firestorm'}, jobby.actions(gs))
    end)

    it('casts the storm of Lightning for Ramuh, whose element GearSwap names Lightning', function()
        local gs = boot({sub_job = 'SCH'})
        gs:give_pet({name = 'Ramuh'})
        assert.equal('Lightning', gs.user.pet.element)
        gs:console('gs c petweather')
        assert.same({'Thunderstorm'}, jobby.actions(gs))
    end)

    it('casts the storm of Light for Carbuncle', function()
        local gs = boot({sub_job = 'SCH'})
        gs:give_pet({name = 'Carbuncle'})
        gs:console('gs c petweather')
        assert.same({'Aurorastorm'}, jobby.actions(gs))
    end)

    it('says Jobby can\'t cast storms without a sub job of SCH', function()
        local gs = boot()
        gs:give_pet({name = 'Ifrit'})
        gs:traffic()
        jobby.chat(gs)
        gs:console('gs c petweather')
        assert.same({'You can not cast storm spells.'}, jobby.chat(gs))
        assert.same({}, jobby.actions(gs))
    end)

    it('says there is no avatar when there is none', function()
        local gs = boot({sub_job = 'SCH'})
        gs:console('gs c petweather')
        assert.same({'You do not have an active avatar.'}, jobby.chat(gs))
        assert.same({}, jobby.actions(gs))
    end)
end)

describe('SMN\'s siphon command', function()
    local gs
    before_each(function()
        gs = boot()
        gs:set_day(0)
    end)

    it('summons the spirit of the day\'s element, siphons, and releases the spirit, a step at a time', function()
        gs:set_day(6)
        gs:console('gs c siphon')
        assert.same({'Light Spirit'}, jobby.actions(gs))
        gs:finish_action()
        gs:advance(4)
        assert.same({'Elemental Siphon'}, jobby.actions(gs))
        gs:finish_action()
        gs:advance(1.1)
        assert.same({'Release'}, jobby.actions(gs))
    end)

    it('releases the avatar that is out first', function()
        gs:give_pet({name = 'Ifrit'})
        gs:traffic()
        gs:console('gs c siphon')
        assert.same({'Release'}, jobby.actions(gs))
        gs:finish_action()
        gs:take_pet()
        gs:traffic()
        gs:advance(1.1)
        assert.same({'Fire Spirit'}, jobby.actions(gs))
    end)

    it('is refused in town', function()
        gs.user.in_town = true
        gs:console('gs c siphon')
        assert.same({'Cannot use Elemental Siphon in a city area.'}, jobby.chat(gs))
        assert.same({}, jobby.actions(gs))
    end)

    it('waits on the recast of Elemental Siphon', function()
        gs.game:start_ability_recast('Elemental Siphon', 30)
        gs:console('gs c siphon')
        local lines = jobby.chat(gs)
        assert.equal(1, #lines)
        assert.is_truthy(lines[1]:find('Abort: [Elemental Siphon] waiting on recast.', 1, true), lines[1])
        assert.same({}, jobby.actions(gs))
    end)
end)

describe('SMN\'s Avatar\'s Favor, kept by the tick', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is put up once an avatar is out', function()
        gs:give_pet({name = 'Ifrit'})
        gs:traffic()
        gs:play(5.5)
        assert.same({"Avatar's Favor"}, jobby.actions(gs))
    end)

    it('is left alone while it is up', function()
        gs:give_pet({name = 'Ifrit'})
        gs:gain_buff("Avatar's Favor")
        gs:traffic()
        gs:play(5.5)
        assert.same({}, jobby.actions(gs))
    end)

    it('is left alone while it is on recast', function()
        gs:give_pet({name = 'Ifrit'})
        gs.game:start_ability_recast("Avatar's Favor", 30)
        gs:traffic()
        gs:play(5.5)
        assert.same({}, jobby.actions(gs))
    end)

    it('is left alone with AutoFavor off', function()
        gs:give_pet({name = 'Ifrit'})
        gs:console('gs c toggle AutoFavor')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, jobby.actions(gs))
    end)

    it('is left alone with no avatar out', function()
        gs:play(5.5)
        assert.same({}, jobby.actions(gs))
    end)

    it('is left alone under amnesia', function()
        gs:give_pet({name = 'Ifrit'})
        gs:gain_buff('amnesia')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, jobby.actions(gs))
    end)
end)

describe('SMN\'s Sleepga pact', function()
    it('starts a timer for the sleep on the monster once it is done', function()
        local gs = boot()
        gs:give_pet({name = 'Diabolos'})
        gs:traffic()
        jobby.commands(gs)
        gs:type('/pet "Sleepga" <t>')
        gs:finish_action()
        assert.same({'timers c "Sleepga [Apex Toad]" 60 down spells/00220.png'}, jobby.commands(gs))
    end)

    pending('starts no timer with UseCustomTimers off, and wears the pet midcast set for the pact: job_aftercast in '
        .. 'data/SMN.lua tests UseCustomTimers and Sleep, or Sleepga, so Sleepga always takes the timer\'s branch and '
        .. 'never the blood pact\'s')
end)

describe('SMN\'s buffs kept by the tick under AutoBuffMode', function()
    it('are Reraise first, with a sub job that casts it', function()
        local gs = boot({sub_job = 'WHM'})
        gs:console('gs c set AutoBuffMode Auto')
        gs:play(5.5)
        assert.same({'Reraise'}, jobby.actions(gs))
    end)

    it('are nothing once Reraise, Haste, Refresh and Stoneskin, the list\'s buffs, are up', function()
        local gs = boot({sub_job = 'WHM'})
        gs:console('gs c set AutoBuffMode Auto')
        gs:gain_buff('Reraise')
        gs:gain_buff('Haste')
        gs:gain_buff('Refresh')
        gs:gain_buff('Stoneskin')
        gs:traffic()
        gs:play(5.5)
        assert.same({}, jobby.actions(gs))
    end)
end)
