local harness = require('harness')
local commy = require('commy')

local function sent_initialize(gs)
    return table.concat(gs:commands(), '\n'):find('gs c weapons initialize', 1, true) ~= nil
end

describe('Sel\'s check for dual wield', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        gs:advance(harness.sel_load_time + 0.1)
        gs:console('gs c set Weapons Naegling')
        gs:commands()
    end)

    it('takes the trait from a job abilities packet, and starts the weapons over', function()
        gs.game:set_job_traits({'Dual Wield'})
        gs:run(function()
            gs.game:receive(0x0AC, string.rep('\0', 64))
            gs.game:settle()
        end)
        gs:advance(1.1)
        assert.is_true(gs.user.can_dual_wield)
        assert.is_true(sent_initialize(gs))
    end)

    it('starts the weapons over on its next look after a sub job change', function()
        gs:change_sub_job('NIN', 49)
        gs:commands()
        gs:advance(harness.sel_load_time + 0.1)
        assert.is_true(sent_initialize(gs))
    end)
end)

-- The weapon set list, the Weapons options it gave and the one chosen, and the weapons in hand.
local function weapons_from_the_list(gs)
    local state = gs.user.state
    return {list = state.WeaponSets.value, options = {state.Weapons[1], state.Weapons[2], state.Weapons[3]},
        value = state.Weapons.value, main = gs:worn().main, sub = gs:worn().sub}
end

local function receive_job_traits(gs, names)
    gs.game:set_job_traits(names)
    gs:receive(0x0AC, string.rep('\0', 64))
    gs:advance(1.1)
end

describe('Sel\'s check for dual wield, for a red mage with ninja as sub job whose gear file names the weapon set '
    .. 'lists Default and Dual, when a fight restricts the sub job and the trait goes', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm({sub_job = 'NIN'})
        gs.user.state.WeaponSets:options('Default', 'Dual')
        gs.user.weapon_sets = {Default = {'Naegling', 'Crocea'}, Dual = {'DualWeapons', 'Swords'}}
        gs.user.default_weapons = 'Crocea'
        gs.user.default_dual_weapons = 'Swords'
        gs.game:set_job_traits({'Dual Wield'})
        gs:advance(harness.sel_load_time + 0.1)
    end)

    it('starts the weapons over when those chosen have a weapon in the sub', function()
        receive_job_traits(gs, {})
        assert.is_false(gs.user.can_dual_wield)
        assert.same({list = 'Default', options = {'Naegling', 'Crocea'}, value = 'Crocea', main = 'Crocea Mors',
            sub = 'Ammurapi Shield'}, weapons_from_the_list(gs))
    end)

    it('reads the trait a second after the packet, once the game has applied it', function()
        gs:receive(0x0AC, string.rep('\0', 64))
        gs.game:set_job_traits({})
        gs:advance(1.1)
        assert.same({list = 'Default', options = {'Naegling', 'Crocea'}, value = 'Crocea', main = 'Crocea Mors',
            sub = 'Ammurapi Shield'}, weapons_from_the_list(gs))
    end)

    it('starts the weapons over when those chosen are named for dual wield', function()
        gs:console('gs c set Weapons DualWeapons')
        receive_job_traits(gs, {})
        assert.same({list = 'Default', options = {'Naegling', 'Crocea'}, value = 'Crocea', main = 'Crocea Mors',
            sub = 'Ammurapi Shield'}, weapons_from_the_list(gs))
    end)

    it('leaves weapons that don\'t dual wield alone', function()
        gs:console('gs c set WeaponSets Default')
        gs:console('gs c set Weapons Naegling')
        receive_job_traits(gs, {})
        assert.same({list = 'Default', options = {'Naegling', 'Crocea'}, value = 'Naegling', main = 'Naegling',
            sub = 'Ammurapi Shield'}, weapons_from_the_list(gs))
    end)

    it('leaves the weapons alone when a packet keeps the trait', function()
        gs:console('gs c set Weapons DualWeapons')
        gs:commands()
        receive_job_traits(gs, {'Dual Wield'})
        assert.is_false(sent_initialize(gs))
        assert.same({list = 'Dual', options = {'DualWeapons', 'Swords'}, value = 'DualWeapons', main = 'Aern Sword',
            sub = 'Ammurapi Shield'}, weapons_from_the_list(gs))
    end)

    it('still puts the dual wield weapons back when a second packet without the trait came before it returns',
        function()
        receive_job_traits(gs, {})
        receive_job_traits(gs, {})
        receive_job_traits(gs, {'Dual Wield'})
        assert.same({list = 'Dual', options = {'DualWeapons', 'Swords'}, value = 'Swords', main = 'Murgleis',
            sub = 'Crocea Mors'}, weapons_from_the_list(gs))
    end)

    it('leaves weapons that don\'t dual wield alone when the trait comes back', function()
        gs:console('gs c set WeaponSets Default')
        gs:console('gs c set Weapons Naegling')
        receive_job_traits(gs, {})
        receive_job_traits(gs, {'Dual Wield'})
        assert.same({list = 'Default', options = {'Naegling', 'Crocea'}, value = 'Naegling', main = 'Naegling',
            sub = 'Ammurapi Shield'}, weapons_from_the_list(gs))
    end)

    it('puts the dual wield weapons back when the trait comes back', function()
        receive_job_traits(gs, {})
        receive_job_traits(gs, {'Dual Wield'})
        assert.same({list = 'Dual', options = {'DualWeapons', 'Swords'}, value = 'Swords', main = 'Murgleis',
            sub = 'Crocea Mors'}, weapons_from_the_list(gs))
    end)

    it('leaves weapons chosen while the trait was gone alone when it comes back', function()
        receive_job_traits(gs, {})
        gs:console('gs c set Weapons Naegling')
        receive_job_traits(gs, {'Dual Wield'})
        assert.same({list = 'Default', options = {'Naegling', 'Crocea'}, value = 'Naegling', main = 'Naegling',
            sub = 'Ammurapi Shield'}, weapons_from_the_list(gs))
    end)
end)

describe('Sel\'s check for dual wield, for a red mage with ninja as sub job whose gear file names no weapon set '
    .. 'lists, when a fight restricts the sub job and the trait goes', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm({sub_job = 'NIN'})
        gs.game:set_job_traits({'Dual Wield'})
        gs:advance(harness.sel_load_time + 0.1)
        gs:console('gs c set Weapons Swords')
    end)

    it('starts the weapons over, and puts the dual wield weapons back when the trait comes back', function()
        receive_job_traits(gs, {})
        assert.equal('None', gs.user.state.Weapons.value)
        receive_job_traits(gs, {'Dual Wield'})
        assert.equal('Swords', gs.user.state.Weapons.value)
        assert.same({'Murgleis', 'Crocea Mors'}, {gs:worn().main, gs:worn().sub})
    end)
end)
