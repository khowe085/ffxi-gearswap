local commy = require('commy')

local idle = commy.thf_idle
local th = {head = 'Volte Cap', legs = 'Volte Hose', waist = 'Chaac Belt'}

-- What sets.TreasureHunter of Commy_Thf_Gear.lua and the pieces given would put on.
local function with_th(pieces)
    local set = {}
    for slot, item in pairs(th) do
        set[slot] = item
    end
    for slot, item in pairs(pieces or {}) do
        set[slot] = item
    end
    return set
end

describe('THF.lua\'s Treasure Hunter modes', function()
    local gs
    before_each(function()
        gs = commy.boot_thf()
    end)

    it('are None, Tag, SATA and Fulltime for a thief, starting at Tag', function()
        local mode = gs.user.state.TreasureMode
        assert.same({'None', 'Tag', 'SATA', 'Fulltime'}, {mode[1], mode[2], mode[3], mode[4]})
        assert.equal('Tag', mode.value)
    end)

    it('in Fulltime, lay sets.TreasureHunter over the engaged set even at a monster tagged already', function()
        gs:console('gs c set TreasureMode Fulltime')
        gs:engage()
        commy.hit(gs)
        assert.same(commy.worn_by(idle, with_th({body = 'Malignance Tabard'})), gs:worn())
    end)

    it('in SATA, lay it over Sneak Attack\'s precast set', function()
        gs:console('gs c set TreasureMode SATA')
        gs:traffic()
        gs:type('/ja "Sneak Attack" <me>')
        assert.same(commy.worn_by(with_th({ring2 = "Medada's Ring"})), gs:traffic()[1].equip)
    end)

    it('in Tag, leave it off Sneak Attack', function()
        gs:type('/ja "Sneak Attack" <me>')
        assert.same({right_ring = "Medada's Ring"}, gs:traffic()[1].equip)
    end)

    it('in SATA, lay it over a weapon skill\'s precast set at a monster tagged already', function()
        gs:console('gs c set TreasureMode SATA')
        gs:engage()
        commy.hit(gs)
        assert.same(commy.worn_by(idle, {body = 'Malignance Tabard'}), gs:worn())
        gs:type('/ws "Evisceration" <t>')
        assert.same(commy.worn_by(idle, with_th({body = 'Malignance Tabard', neck = 'Sanctity Necklace'})), gs:worn())
    end)

    it('in Tag, leave it off a weapon skill at a monster tagged already', function()
        gs:engage()
        commy.hit(gs)
        gs:type('/ws "Evisceration" <t>')
        assert.same(commy.worn_by(idle, {body = 'Malignance Tabard', neck = 'Sanctity Necklace'}), gs:worn())
    end)

    it('in any but None, lay it over Aeolian Edge at a monster tagged already', function()
        gs:engage()
        commy.hit(gs)
        gs:type('/ws "Aeolian Edge" <t>')
        assert.same(commy.worn_by(idle, with_th({body = 'Malignance Tabard', neck = 'Sanctity Necklace'})), gs:worn())
    end)

    it('in None, leave it off Aeolian Edge', function()
        gs:console('gs c set TreasureMode None')
        gs:traffic()
        gs:type('/ws "Aeolian Edge" <t>')
        assert.same({neck = 'Sanctity Necklace'}, gs:traffic()[1].equip)
    end)

    it('in SATA, lay it with sets.buff[\'Sneak Attack\'] over the gear while Sneak Attack is up', function()
        gs:console('gs c set TreasureMode SATA')
        gs:gain_buff('Sneak Attack')
        assert.same(commy.worn_by(idle, with_th({back = 'Moonlight Cape'})), gs:worn())
    end)

    it('in Tag, put only sets.buff[\'Sneak Attack\'] over the gear while Sneak Attack is up', function()
        gs:gain_buff('Sneak Attack')
        assert.same(commy.worn_by(idle, {back = 'Moonlight Cape'}), gs:worn())
    end)
end)
