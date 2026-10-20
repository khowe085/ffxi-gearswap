local commy = require('commy')

-- What is worn once the spell is out: the midcast set, with the spell map's set in it, over the idle set.
local function midcast(gs, line)
    local sent = #gs.game.actions
    gs:type(line)
    assert.equal(sent + 1, #gs.game.actions, 'the spell didn\'t go out')
    return gs:worn()
end

describe('Sel\'s spell map', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        -- So that a spell at the monster wears its own sets only, without sets.TreasureHunter over them.
        gs:console('gs c set TreasureMode None')
        gs:traffic()
    end)

    it('BarElement is the midcast set of a bar-element spell', function()
        assert.equal('Telchine Braconi', midcast(gs, '/ma "Barfire" <me>').legs)
    end)

    it('BarElement is the midcast set of each bar-element spell', function()
        assert.equal('Telchine Braconi', midcast(gs, '/ma "Barblizzard" <me>').legs)
    end)

    it('Enspell is the midcast set of an enspell', function()
        assert.equal('Chironic Hose', midcast(gs, '/ma "Enfire" <me>').legs)
    end)

    it('Enspell is the midcast set of a second-tier enspell', function()
        assert.equal('Chironic Hose', midcast(gs, '/ma "Enfire II" <me>').legs)
    end)

    it('StatusRemoval is the midcast set of an -na spell', function()
        assert.equal('Malignance Tights', midcast(gs, '/ma "Paralyna" <me>').legs)
    end)

    it('StatusRemoval is the midcast set of Erase', function()
        assert.equal('Malignance Tights', midcast(gs, '/ma "Erase" <me>').legs)
    end)

    it('Dia is the midcast set of Dia and Dia II', function()
        assert.equal('Volte Brais', midcast(gs, '/ma "Dia" <t>').legs)
        gs:finish_action()
        gs:advance(5)
        assert.equal('Volte Brais', midcast(gs, '/ma "Dia II" <t>').legs)
    end)

    it('Bio is the midcast set of Bio', function()
        assert.equal('Regal Cuffs', midcast(gs, '/ma "Bio" <t>').hands)
    end)

    it('Protect is the midcast set of Protect', function()
        assert.equal("Bunzi's Pants", midcast(gs, '/ma "Protect" <me>').legs)
    end)

    it('Shell is the midcast set of Shell', function()
        assert.equal('Lengo Pants', midcast(gs, '/ma "Shell" <me>').legs)
    end)

    it('Regen is the midcast set of Regen', function()
        assert.equal('Psycloth Lappas', midcast(gs, '/ma "Regen" <me>').legs)
    end)

    it('Spikes is the midcast set of a spikes spell', function()
        assert.equal('Querkening Brais', midcast(gs, '/ma "Blaze Spikes" <me>').legs)
    end)

    it('Raise is the midcast set of Raise', function()
        assert.equal('Telchine Gloves', midcast(gs, '/ma "Raise" <me>').hands)
    end)

    it('Temper is the midcast set of Temper', function()
        assert.equal('Chironic Gloves', midcast(gs, '/ma "Temper" <me>').hands)
    end)

    it('BoostStat is the midcast set of a Gain- spell', function()
        assert.equal('Amalric Gages', midcast(gs, '/ma "Gain-INT" <me>').hands)
    end)

    it('CureNuke, not Cure, is the midcast set of a Cure cast at a monster', function()
        local worn = midcast(gs, '/ma "Cure III" <t>')
        assert.same({'Merlinic Shalwar', 'Daybreak', 'Malignance Chapeau'}, {worn.legs, worn.main, worn.head})
    end)

    it('is none for a spell outside the maps, which keeps the idle set\'s legs and hands', function()
        local worn = midcast(gs, '/ma "Aquaveil" <me>')
        assert.same({'Nyame Flanchard', 'Nyame Gauntlets'}, {worn.legs, worn.hands})
    end)
end)

describe('RDM.lua\'s Cure spell maps', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('are none with the weapons free, in weather and on a day that aren\'t light', function()
        local worn = midcast(gs, '/ma "Cure III" <me>')
        assert.same({"Bunzi's Rod", 'Nyame Gauntlets'}, {worn.main, worn.hands})
    end)

    it('MeleeCure is the midcast set of a Cure while a weapon set is held', function()
        gs:console('gs c set Weapons Naegling')
        local worn = midcast(gs, '/ma "Cure III" <me>')
        assert.same({'Naegling', 'Kaykaus Cuffs'}, {worn.main, worn.hands})
    end)

    it('LightWeatherCure is the midcast set of a Cure in light weather', function()
        gs:set_weather(16)
        assert.equal("Bunzi's Gloves", midcast(gs, '/ma "Cure III" <me>').hands)
    end)

    it('LightDayCure is the midcast set of a Cure on Lightsday', function()
        gs:set_day(6)
        assert.equal("Shrieker's Cuffs", midcast(gs, '/ma "Cure III" <me>').hands)
    end)

    it('with no set of its own, gives way to sets.midcast.Cure, as MeleeLightWeatherCure does', function()
        gs:console('gs c set Weapons Naegling')
        gs:set_weather(16)
        local worn = midcast(gs, '/ma "Cure III" <me>')
        assert.same({'Naegling', 'Kaykaus Mitra +1', 'Nyame Gauntlets'}, {worn.main, worn.head, worn.hands})
    end)
end)
