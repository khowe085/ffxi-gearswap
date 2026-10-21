local harness = require('harness')
local jobby = require('jobby')

local gear = {"Judge's Sword", 'Mecisto. Mantle', "Bendis's Hairpin", "Theia's Hairpin", 'Sapphire Platemail',
    'Jadeite Cuirie', 'Jadeite Chausses', 'Diamond Haramaki', 'Sapphire Gauntlets', 'Jadeite Gloves',
    'Diamond Kote', 'Sapphire Trousers', 'Diamond Hiza.', 'Diamond Sune-Ate', "Orunmila's Torque", 'Prosilio Belt',
    "Tyrant's Ring", 'Aptitude Mantle', 'Carnwenhan', 'Daurdabla', 'Miracle Cheer', 'Marsyas', 'Ruby Robe',
    'Rage Platemail', 'Volte Brais', 'Volte Bracers', 'Terpander', 'Null Belt'}

-- What the idle set of Jobby's bard gear file wears besides every gear file's.
local own_idle = {main = "Judge's Sword", back = 'Mecisto. Mantle'}

local idle = jobby.worn_by(jobby.idle, own_idle)

-- What is worn with these changes over the idle set.
local function worn(changes)
    return jobby.worn_by(idle, changes)
end

-- Jobby as a bard with the idle set on, over a sub job of WHM unless the options (jobby.boot's) say otherwise.
local function boot(options)
    options = options or {}
    options.items = gear
    options.wearing = own_idle
    return jobby.boot('BRD', options)
end

describe('data/BRD.lua', function()
    it('starts with no extra songs, the default Carnwenhan mode and no automatic songs', function()
        local gs = boot()
        assert.equal('None', gs.user.state.ExtraSongsMode.value)
        assert.equal('Default', gs.user.state.CarnMode.value)
        assert.is_false(gs.user.state.AutoSongMode.value)
        assert.is_false(gs.user.state.AutoDummyMode.value)
    end)
end)

describe('BRD\'s songs on the party', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('take sets.precast.FC, over which the song class\'s midcast set goes', function()
        assert.is_true(gs:type('/ma "Valor Minuet V" <me>'))
        assert.same(worn({head = "Bendis's Hairpin", main = 'Carnwenhan', range = 'Terpander',
            body = 'Sapphire Platemail', legs = 'Volte Brais'}), gs:worn())
    end)

    it('take the song class set, then the spell map\'s over it', function()
        gs:type('/ma "Mage\'s Ballad" <me>')
        assert.same(worn({head = "Bendis's Hairpin", ring1 = "Tyrant's Ring", main = 'Carnwenhan',
            range = 'Terpander', body = 'Sapphire Platemail', hands = 'Volte Bracers', legs = 'Sapphire Trousers'}),
            gs:worn())
    end)

    it('take the song class set\'s casting mode in that casting mode', function()
        gs:console('gs c set CastingMode Resistant')
        gs:type('/ma "Valor Minuet V" <me>')
        assert.same(worn({head = "Bendis's Hairpin", main = 'Carnwenhan', body = 'Ruby Robe'}), gs:worn())
    end)

    it('give way to the idle set once done', function()
        gs:type('/ma "Valor Minuet V" <me>')
        gs:finish_action()
        assert.same(worn(), gs:worn())
    end)
end)

describe('BRD\'s songs on a monster', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('take sets.precast.FC.SongDebuff, a song of theirs having no set of its own in precast', function()
        gs:type('/ma "Foe Lullaby" <t>')
        local traffic = gs:traffic()
        assert.same({head = "Theia's Hairpin"}, traffic[1].equip)
    end)

    it('take the set of the song\'s name in precast, and not the debuff class\'s, when it has one', function()
        gs:type('/ma "Horde Lullaby" <t>')
        assert.same({head = "Bendis's Hairpin", left_ring = "Tyrant's Ring"}, gs:traffic()[1].equip)
    end)

    it('take the debuff class set, then the song\'s own set over it, and no dual wielder\'s set over them for a '
        .. 'character who can\'t dual wield', function()
        gs:type('/ma "Foe Lullaby" <t>')
        assert.same(worn({head = "Theia's Hairpin", main = 'Carnwenhan', body = 'Diamond Haramaki',
            hands = 'Sapphire Gauntlets', waist = 'Null Belt'}), gs:worn())
    end)

    it('take the spell map\'s set when the song has none of its own', function()
        gs:type('/ma "Horde Lullaby" <t>')
        assert.same(worn({head = "Bendis's Hairpin", ring1 = "Tyrant's Ring", main = 'Carnwenhan', body = 'Diamond Haramaki',
            hands = 'Volte Bracers', legs = 'Sapphire Trousers', waist = 'Null Belt'}), gs:worn())
    end)

    it('take the casting mode\'s set of each in that casting mode', function()
        gs:console('gs c set CastingMode Resistant')
        gs:type('/ma "Foe Lullaby" <t>')
        assert.same(worn({head = "Theia's Hairpin", main = 'Carnwenhan', body = 'Jadeite Cuirie',
            hands = 'Jadeite Gloves'}), gs:worn())
    end)

    it('have the dual wielder\'s set over them for a character who can', function()
        jobby.can_dual_wield(gs)
        gs:type('/ma "Foe Lullaby" <t>')
        assert.equal('Prosilio Belt', gs:worn().waist)
    end)
end)

describe('BRD\'s extra songs', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('are Dummy songs with the dummy class set in place of the song class\'s, and nothing in the range slot',
        function()
            gs:console('gs c set ExtraSongsMode Dummy')
            gs:type('/ma "Valor Minuet V" <me>')
            assert.same(worn({head = "Bendis's Hairpin", body = 'Rage Platemail'}), gs:worn())
        end)

    it('are FullLength songs with the extra song instrument over the song class set', function()
        gs:console('gs c set ExtraSongsMode FullLength')
        gs:type('/ma "Valor Minuet V" <me>')
        assert.same(worn({head = "Bendis's Hairpin", main = 'Carnwenhan', body = 'Sapphire Platemail',
            legs = 'Volte Brais', range = 'Daurdabla'}), gs:worn())
    end)

    it('are Cheer songs with Miracle Cheer in the range slot over the song class set', function()
        gs:console('gs c set ExtraSongsMode Cheer')
        gs:type('/ma "Valor Minuet V" <me>')
        assert.same(worn({head = "Bendis's Hairpin", main = 'Carnwenhan', body = 'Sapphire Platemail',
            legs = 'Volte Brais', range = 'Miracle Cheer'}), gs:worn())
    end)

    it('go back to None after the song', function()
        gs:console('gs c set ExtraSongsMode Dummy')
        gs:type('/ma "Valor Minuet V" <me>')
        assert.equal('None', gs.user.state.ExtraSongsMode.value)
    end)

    it('stay when the mode ends in Lock', function()
        gs:console('gs c set ExtraSongsMode FullLengthLock')
        gs:type('/ma "Valor Minuet V" <me>')
        assert.equal('FullLengthLock', gs.user.state.ExtraSongsMode.value)
        assert.equal('Daurdabla', gs:worn().range)
    end)

    it('stay as Cheer in CheerLock, with Miracle Cheer on', function()
        gs:console('gs c set ExtraSongsMode CheerLock')
        gs:type('/ma "Valor Minuet V" <me>')
        assert.equal('CheerLock', gs.user.state.ExtraSongsMode.value)
        assert.equal('Miracle Cheer', gs:worn().range)
    end)

    it('are Dummy songs held for the dummy class set under DummyLock', function()
        gs:console('gs c set ExtraSongsMode DummyLock')
        gs:type('/ma "Valor Minuet V" <me>')
        assert.equal('DummyLock', gs.user.state.ExtraSongsMode.value)
        assert.equal('Rage Platemail', gs:worn().body)
    end)

    it('wear no instrument for a song on a monster, whichever the mode', function()
        gs:console('gs c set ExtraSongsMode FullLength')
        gs:type('/ma "Foe Lullaby" <t>')
        assert.is_nil(gs:worn().range)
    end)
end)

describe('BRD\'s Pianissimo and Soul Voice', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('have the Pianissimo set, which the spell map\'s Pianissimo set takes the place of, over the song', function()
        gs:gain_buff('Pianissimo')
        gs:type('/ma "Mage\'s Ballad" <me>')
        assert.same(worn({head = "Bendis's Hairpin", ring1 = "Tyrant's Ring", main = 'Carnwenhan',
            range = 'Terpander', body = 'Sapphire Platemail', legs = 'Sapphire Trousers', hands = 'Jadeite Gloves'}),
            gs:worn())
    end)

    it('take the spell map\'s Pianissimo set rather than the general one', function()
        gs:gain_buff('Pianissimo')
        gs:type('/ma "Honor March" <me>')
        assert.same(worn({head = "Bendis's Hairpin", main = 'Carnwenhan', body = 'Sapphire Platemail',
            legs = 'Diamond Hiza.', range = 'Marsyas'}), gs:worn())
    end)

    it('have the Soul Voice set over the song', function()
        gs:gain_buff('Soul Voice')
        gs:type('/ma "Mage\'s Ballad" <me>')
        assert.same(worn({head = "Bendis's Hairpin", ring1 = "Tyrant's Ring", main = 'Carnwenhan',
            range = 'Terpander', body = 'Sapphire Platemail', legs = 'Sapphire Trousers', hands = 'Diamond Kote'}),
            gs:worn())
    end)

    it('take the spell map\'s Soul Voice set rather than the general one', function()
        gs:gain_buff('Soul Voice')
        gs:type('/ma "Advancing March" <me>')
        assert.same(worn({head = "Bendis's Hairpin", main = 'Carnwenhan', range = 'Terpander',
            body = 'Sapphire Platemail', legs = 'Jadeite Chausses', feet = 'Diamond Sune-Ate'}), gs:worn())
    end)

    it('are left out of a Dummy song', function()
        gs:console('gs c set ExtraSongsMode Dummy')
        gs:gain_buff('Pianissimo')
        gs:gain_buff('Soul Voice')
        gs:type('/ma "Mage\'s Ballad" <me>')
        assert.same(worn({head = "Bendis's Hairpin", ring1 = "Tyrant's Ring", body = 'Rage Platemail',
            hands = 'Volte Bracers', legs = 'Sapphire Trousers'}), gs:worn())
    end)

    it('have Miracle Cheer on a song under the Pianissimo mode while Pianissimo is up', function()
        gs:console('gs c toggle Pianissimode')
        gs:gain_buff('Pianissimo')
        gs:type('/ma "Mage\'s Ballad" <me>')
        assert.equal('Miracle Cheer', gs:worn().range)
    end)

    it('have no Miracle Cheer on a song under the Pianissimo mode without Pianissimo', function()
        gs:console('gs c toggle Pianissimode')
        gs:type('/ma "Mage\'s Ballad" <me>')
        assert.equal('Terpander', gs:worn().range)
    end)
end)

describe('BRD\'s Nightingale', function()
    it('puts the midcast set of the song\'s spell map on with the precast set, before the song goes out', function()
        local gs = boot()
        gs:gain_buff('Nightingale')
        gs:traffic()
        gs:type('/ma "Mage\'s Ballad" <me>')
        assert.same({
            {equip = {head = "Bendis's Hairpin", left_ring = "Tyrant's Ring", hands = 'Volte Bracers',
                legs = 'Sapphire Trousers'}},
            {action = 'Mage\'s Ballad', target = 'Jobby'},
            {equip = {main = 'Carnwenhan', range = 'Terpander', body = 'Sapphire Platemail'}},
        }, gs:traffic())
    end)

    it('leaves the midcast set, the spell map\'s with the rest, until after the song goes out without it', function()
        local gs = boot()
        gs:type('/ma "Mage\'s Ballad" <me>')
        assert.same({
            {equip = {head = "Bendis's Hairpin", left_ring = "Tyrant's Ring"}},
            {action = 'Mage\'s Ballad', target = 'Jobby'},
            {equip = {main = 'Carnwenhan', range = 'Terpander', body = 'Sapphire Platemail', hands = 'Volte Bracers',
                legs = 'Sapphire Trousers'}},
        }, gs:traffic())
    end)
end)

describe('BRD\'s song on a party member', function()
    local gs
    before_each(function()
        gs = boot()
        gs.game:add_party_member({name = 'Friend'})
    end)

    it('is held back for Pianissimo, which goes out in its place', function()
        gs:type('/ma "Mage\'s Ballad" Friend')
        assert.same({'Pianissimo'}, gs:actions())
    end)

    it('is typed again 1.1 seconds after, and goes out to the party member with Pianissimo up', function()
        gs:type('/ma "Mage\'s Ballad" Friend')
        gs:finish_action()
        gs:gain_buff('Pianissimo')
        gs:traffic()
        gs:advance(1.0)
        assert.same({}, gs:action_entries())
        gs:advance(0.2)
        assert.same({{action = 'Mage\'s Ballad', target = 'Friend'}}, gs:action_entries())
    end)

    it('goes out at once with Pianissimo up', function()
        gs:gain_buff('Pianissimo')
        gs:traffic()
        gs:type('/ma "Mage\'s Ballad" Friend')
        assert.same({'Mage\'s Ballad'}, gs:actions())
    end)

    it('is held back for Pianissimo only when the song itself is ready, and waits on its recast when not', function()
        gs.game:start_spell_recast("Mage's Ballad", 60)
        gs:type('/ma "Mage\'s Ballad" Friend')
        assert.same({}, gs:actions())
    end)

    it('goes out on Jobby with no Pianissimo', function()
        gs:type('/ma "Mage\'s Ballad" <me>')
        assert.same({'Mage\'s Ballad'}, gs:actions())
    end)
end)

describe('BRD\'s song aimed with <t> while Pianissimo is up', function()
    local gs
    before_each(function()
        gs = boot()
        gs:gain_buff('Pianissimo')
        gs:traffic()
    end)

    it('is held back, and typed again aimed with <stpt>, with a monster targeted', function()
        assert.is_true(gs:type('/ma "Mage\'s Ballad" <t>'))
        assert.same({}, gs:actions())
        local typed = gs:typed()
        assert.equal(1, #typed)
        assert.is_truthy(typed[1]:find('^/ma "Mage\'s Ballad" +<stpt>$'), typed[1])
    end)

    it('is left as it is aimed with <me>', function()
        gs:type('/ma "Mage\'s Ballad" <me>')
        assert.same({'Mage\'s Ballad'}, gs:actions())
    end)

    it('is left alone when it is aimed at a monster, a debuff song', function()
        gs:type('/ma "Foe Lullaby" <t>')
        assert.same({'Foe Lullaby'}, gs:actions())
    end)
end)

describe('BRD\'s Rudra\'s Storm', function()
    it('is Savage Blade when Jobby has Fast Blade, which the job file takes for a sword in hand', function()
        local gs = boot({abilities = {'Fast Blade', 'Savage Blade'}, tp = 1000})
        gs:type('/ws "Rudra\'s Storm" <t>')
        assert.same({'Savage Blade'}, gs:actions())
    end)

    it('is left alone when Jobby doesn\'t have Fast Blade, whatever other sword weapon skills he has', function()
        local gs = boot({abilities = {'Savage Blade'}, tp = 1000})
        gs:type('/ws "Rudra\'s Storm" <t>')
        assert.same({}, gs:actions())
    end)
end)

describe('BRD\'s dummy songs under AutoDummyMode', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c toggle AutoDummyMode')
    end)

    -- What the body slot wears once the song is out: the dummy class's body, or the song class's.
    local function body_after_song(song, target)
        gs:type('/ma "' .. song .. '" ' .. (target or '<me>'))
        return gs:worn().body
    end

    it('are used with two song buffs up and one extra song allowed', function()
        gs:gain_buff('March')
        gs:gain_buff('Minuet')
        assert.equal('Rage Platemail', body_after_song('Valor Minuet V'))
    end)

    it('are not used with fewer than two song buffs up', function()
        gs:gain_buff('March')
        assert.equal('Sapphire Platemail', body_after_song('Valor Minuet V'))
    end)

    it('are not used once the extra song is up too', function()
        gs:gain_buff('March')
        gs:gain_buff('Minuet')
        gs:gain_buff('Madrigal')
        assert.equal('Sapphire Platemail', body_after_song('Valor Minuet V'))
    end)

    it('are used with the extra song up too under Clarion Call, which allows one more', function()
        gs:gain_buff('March')
        gs:gain_buff('Minuet')
        gs:gain_buff('Madrigal')
        gs:gain_buff('Clarion Call')
        assert.equal('Rage Platemail', body_after_song('Valor Minuet V'))
    end)

    it('are not used for a song on a monster', function()
        gs:gain_buff('March')
        gs:gain_buff('Minuet')
        assert.equal('Diamond Haramaki', body_after_song('Foe Lullaby', '<t>'))
    end)

    it('stop counting a song buff once it wears off', function()
        gs:gain_buff('March')
        gs:gain_buff('Minuet')
        gs:lose_buff('Minuet')
        assert.equal('Sapphire Platemail', body_after_song('Valor Minuet V'))
    end)

    it('count song buffs only', function()
        gs:gain_buff('March')
        gs:gain_buff('Haste')
        assert.equal(1, gs.user.current_brd_buffs)
    end)

    it('are left alone with AutoDummyMode off, whatever the buffs', function()
        gs:console('gs c toggle AutoDummyMode')
        gs:gain_buff('March')
        gs:gain_buff('Minuet')
        assert.equal('Sapphire Platemail', body_after_song('Valor Minuet V'))
    end)
end)

describe('BRD\'s Carnwenhan, with the weapons locked to a sword', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c set Weapons Sword')
        gs:traffic()
    end)

    local function main_in_song(song, target)
        gs:type('/ma "' .. song .. '" ' .. (target or '<me>'))
        return gs:worn().main
    end

    it('stays out of a song with the Never mode', function()
        gs:console('gs c set CarnMode Never')
        assert.equal("Judge's Sword", main_in_song('Valor Minuet V'))
    end)

    it('goes on for a song with the Always mode', function()
        gs:console('gs c set CarnMode Always')
        assert.equal('Carnwenhan', main_in_song('Valor Minuet V'))
    end)

    it('goes on for a song on the party with the Default mode', function()
        assert.equal('Carnwenhan', main_in_song('Valor Minuet V'))
    end)

    it('goes on for a song on a monster with the Default mode while Jobby isn\'t engaged', function()
        assert.equal('Carnwenhan', main_in_song('Foe Lullaby', '<t>'))
    end)

    it('stays out of a song on a monster with the Default mode while Jobby is engaged', function()
        gs:engage()
        assert.equal("Judge's Sword", main_in_song('Foe Lullaby', '<t>'))
    end)

    it('goes on with the 300 mode under 300 TP', function()
        gs:console('gs c set CarnMode 300')
        gs.game.player.vitals.tp = 299
        assert.equal('Carnwenhan', main_in_song('Valor Minuet V'))
    end)

    it('stays out with the 300 mode from 300 TP', function()
        gs:console('gs c set CarnMode 300')
        gs.game.player.vitals.tp = 300
        assert.equal("Judge's Sword", main_in_song('Valor Minuet V'))
    end)

    it('goes on with the 1000 mode under 1000 TP, and stays out from there', function()
        gs:console('gs c set CarnMode 1000')
        gs.game.player.vitals.tp = 999
        assert.equal('Carnwenhan', main_in_song('Valor Minuet V'))
        gs:finish_action()
        gs.game.player.vitals.tp = 1000
        assert.equal("Judge's Sword", main_in_song('Blade Madrigal'))
    end)

    it('gives way to the sword once the song is done', function()
        gs:console('gs c set CarnMode Always')
        gs:type('/ma "Valor Minuet V" <me>')
        gs:finish_action()
        assert.equal("Judge's Sword", gs:worn().main)
    end)
end)

describe('BRD\'s cures', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    local function cure_hands()
        gs:type('/ma "Cure III" <me>')
        return gs:worn().hands
    end

    it('take sets.midcast.Cure on an ordinary day', function()
        assert.equal('Sapphire Gauntlets', cure_hands())
    end)

    it('take sets.midcast.LightWeatherCure in light weather', function()
        gs:set_weather(16)
        assert.equal('Jadeite Gloves', cure_hands())
    end)

    it('take sets.midcast.LightDayCure on a Lightsday', function()
        gs:set_day(6)
        assert.equal('Diamond Kote', cure_hands())
    end)

    it('take the light weather\'s set rather than the light day\'s when both are light', function()
        gs:set_day(6)
        gs:set_weather(16)
        assert.equal('Jadeite Gloves', cure_hands())
    end)

    it('take the light weather\'s set for a Curaga too', function()
        gs:set_weather(16)
        gs:type('/ma "Curaga" <me>')
        assert.equal('Jadeite Gloves', gs:worn().hands)
    end)

    it('take sets.midcast.Cure in the weather of another element', function()
        gs:set_weather(18)
        assert.equal('Sapphire Gauntlets', cure_hands())
    end)
end)

describe('BRD\'s idle set', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    local function update()
        gs:console('gs c update')
    end

    it('has sets.latent_refresh over it under 51% MP', function()
        gs.game.player.vitals.mpp = 50
        update()
        assert.same(worn({waist = 'Prosilio Belt'}), gs:worn())
    end)

    it('has no sets.latent_refresh over it from 51% MP', function()
        gs.game.player.vitals.mpp = 51
        update()
        assert.same(worn(), gs:worn())
    end)

    it('has no sets.latent_refresh over it in the DT idle mode', function()
        gs:console('gs c set IdleMode DT')
        gs.game.player.vitals.mpp = 50
        update()
        assert.same(worn({body = 'Sapphire Platemail'}), gs:worn())
    end)

    it('has sets.TPEat over it with TP, low MP and no weapons locked', function()
        gs.game.player.vitals.mpp = 50
        gs.game.player.vitals.tp = 11
        update()
        assert.same(worn({waist = 'Prosilio Belt', neck = "Orunmila's Torque"}), gs:worn())
    end)

    it('has no sets.TPEat over it with 10 TP or less', function()
        gs.game.player.vitals.mpp = 50
        gs.game.player.vitals.tp = 10
        update()
        assert.same(worn({waist = 'Prosilio Belt'}), gs:worn())
    end)

    it('has no sets.TPEat over it while the weapons are locked', function()
        gs:console('gs c set Weapons Sword')
        gs.game.player.vitals.mpp = 50
        gs.game.player.vitals.tp = 500
        update()
        assert.same(worn({waist = 'Prosilio Belt'}), gs:worn())
    end)

    it('has sets.TPEat over it with the weapons locked but unlocked', function()
        gs:console('gs c set Weapons Sword')
        gs:console('gs c toggle UnlockWeapons')
        gs.game.player.vitals.mpp = 50
        gs.game.player.vitals.tp = 500
        update()
        assert.same(worn({waist = 'Prosilio Belt', neck = "Orunmila's Torque"}), gs:worn())
    end)

    pending('has no sets.latent_refresh_grip over it with a staff in the idle set and the weapons locked to Judge\'s '
        .. 'Sword but UnlockWeapons on: job_customize_idle_set in data/BRD.lua looks at the idle set\'s main, and with '
        .. 'UnlockWeapons on Sel lays the weapon set over the idle set after it, so the job file adds '
        .. 'sets.latent_refresh_grip with Judge\'s Sword in hand')

    it('has sets.buff.Sublimation over it while Sublimation is charging', function()
        gs:gain_buff('Sublimation: Activated')
        assert.same(worn({back = 'Aptitude Mantle'}), gs:worn())
    end)

    it('has sets.buff.DTSublimation over the DT idle set while Sublimation is charging', function()
        gs:console('gs c set IdleMode DT')
        gs:gain_buff('Sublimation: Activated')
        assert.same(worn({body = 'Sapphire Platemail', back = 'Aptitude Mantle', neck = "Orunmila's Torque"}),
            gs:worn())
    end)
end)

describe('BRD\'s songs kept by AutoSongMode', function()
    local gs
    before_each(function()
        gs = boot()
        gs:console('gs c toggle AutoSongMode')
    end)

    it('are Honor March first', function()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({'Honor March'}, gs:actions())
    end)

    it('are Valor Minuet V once March is up', function()
        gs:gain_buff('March')
        gs:traffic()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({'Valor Minuet V'}, gs:actions())
    end)

    it('are Blade Madrigal once March and Minuet are up, as a full-length extra song', function()
        gs:gain_buff('March')
        gs:gain_buff('Minuet')
        gs:traffic()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({'Blade Madrigal'}, gs:actions())
        assert.equal('Daurdabla', gs:worn().range)
    end)

    it('are nothing once March, Minuet and Madrigal are up', function()
        gs:gain_buff('March')
        gs:gain_buff('Minuet')
        gs:gain_buff('Madrigal')
        gs:traffic()
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)

    it('are nothing with AutoSongMode off', function()
        gs:console('gs c toggle AutoSongMode')
        gs:play(harness.sel_load_time + 0.5)
        assert.same({}, gs:actions())
    end)

    it('are given up on a change of zone', function()
        gs.game:fire('zone change', 100, 288)
        gs.game:settle()
        assert.is_false(gs.user.state.AutoSongMode.value)
    end)
end)
