local commy = require('commy')
local harness = require('harness')

local idle = commy.rdm_idle

describe('gs c update', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('puts the set Sel picks back on over gear put on by hand', function()
        gs:console('gs equip sets.TreasureHunter')
        assert.equal('Volte Cap', gs:worn().head)
        gs:console('gs c update')
        assert.same(commy.worn_by(idle), gs:worn())
    end)

    it('with user, names the defense mode, Kiting and a stop on equipping when they are on', function()
        gs:console('gs c set DefenseMode Physical')
        gs:console('gs c toggle Kiting')
        gs:console('gs c set EquipStop precast')
        gs:chat()
        gs:console('gs c update user')
        assert.same({'Melee, Casting [Normal], Idle [Normal], Defense: Physical (PDT), Kiting',
            'Gear equips are blocked after [precast].  Use "//gs c reset equipstop" to turn it off.'}, gs:chat())
    end)

    it('with user, says what the melee modes are for a job file that leaves that to Sel', function()
        local war = commy.boot_war()
        war:console('gs c set OffenseMode Acc')
        war:console('gs c set DefenseMode Physical')
        war:console('gs c set PCTargetMode stpt')
        war:console('gs c toggle SelectNPCTargets')
        war:chat()
        war:console('gs c update user')
        assert.same({'Melee: Acc, WS: Match, Defense: Physical (PDT), Target PC: stpt, Target NPCs'}, war:chat())
    end)

    it('sets a buff Sel tracks back to whether it is up', function()
        gs:type('/ja "Saboteur" <me>')
        gs:finish_action()
        assert.is_true(gs.user.state.Buff.Saboteur)
        gs:console('gs c update')
        assert.is_false(gs.user.state.Buff.Saboteur)
    end)
end)

describe('gs c showtp', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('puts the engaged set on and says which', function()
        gs:console('gs c showtp')
        assert.same({'Showing current TP set: [Normal]'}, gs:chat())
        assert.same(commy.worn_by(idle, {head = "Bunzi's Hat", body = 'Lethargy Sayon +3'}), gs:worn())
    end)

    it('names the hybrid mode when it isn\'t Normal', function()
        gs:console('gs c set HybridMode DT')
        gs:chat()
        gs:console('gs c showtp')
        assert.same({'Showing current TP set: [Normal/DT]'}, gs:chat())
        assert.same(commy.worn_by(idle, {head = 'Malignance Chapeau', body = 'Lethargy Sayon +3'}), gs:worn())
    end)

    it('holds the engaged set on until it is given again', function()
        gs:console('gs c showtp')
        gs:console('gs c update')
        assert.equal("Bunzi's Hat", gs:worn().head)
        gs:console('gs c showtp')
        assert.same(commy.worn_by(idle), gs:worn())
    end)
end)

describe('gs c naked', function()
    it('takes everything off and holds it off until it is given again', function()
        local gs = commy.boot_rdm()
        gs:console('gs c naked')
        assert.same({}, gs:worn())
        gs:console('gs c update')
        assert.same({}, gs:worn())
        gs:console('gs c naked')
        assert.same(commy.worn_by(idle), gs:worn())
    end)
end)

describe('gs c forceequip', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('puts a piece in a slot and holds it there until given with nothing after it', function()
        gs:console('gs c forceequip neck Sanctity Necklace')
        assert.same(commy.worn_by(idle, {neck = 'Sanctity Necklace'}), gs:worn())
        gs:type('/ma "Cure III" <me>')
        gs:finish_action()
        assert.equal('Sanctity Necklace', gs:worn().neck)
        gs:console('gs c forceequip')
        assert.same(commy.worn_by(idle), gs:worn())
    end)

    it('takes the piece off with gs c enable all', function()
        gs:console('gs c forceequip neck Sanctity Necklace')
        gs:console('gs c enable all')
        assert.same(commy.worn_by(idle), gs:worn())
    end)

    pending('keeps the slot free after gs c enable all once a weapon set is chosen: handle_enable empties '
        .. 'internal_disable but leaves disabled_sets.User, so the next build_internal_disable (a weapon set, Doom, '
        .. 'showtp) puts the forced piece back on')
end)

describe('gs c showset', function()
    it('puts a set on by its name and holds it on until given with no set', function()
        local gs = commy.boot_rdm()
        gs:console('gs c showset sets.TreasureHunter')
        assert.same(commy.worn_by(idle, {head = 'Volte Cap', legs = 'Volte Hose'}), gs:worn())
        gs:console('gs c update')
        assert.equal('Volte Cap', gs:worn().head)
        gs:console('gs c showset')
        assert.same(commy.worn_by(idle), gs:worn())
    end)
end)

describe('gs c softequip', function()
    it('lays a set over the one Sel picks, until the next change of gear', function()
        local gs = commy.boot_rdm()
        gs:console('gs c softequip sets.Refresh_Received')
        assert.same(commy.worn_by(idle, {waist = 'Chaac Belt'}), gs:worn())
        gs:console('gs c update')
        assert.same(commy.worn_by(idle), gs:worn())
    end)
end)

describe('EquipStop', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('at precast keeps a spell\'s precast set on through midcast and after', function()
        gs:console('gs c set EquipStop precast')
        gs:traffic()
        gs:chat()
        gs:type('/ma "Cure III" <me>')
        assert.same({{equip = {head = "Bunzi's Hat", left_ring = 'Kishar Ring'}}, {action = 'Cure III', target = 'Commy'}},
            gs:traffic())
        assert.same({'Show Sets: Stopping at precast.'}, gs:chat())
        gs:finish_action()
        assert.same({}, gs:traffic())
    end)

    it('at midcast keeps a spell\'s midcast set on after it', function()
        gs:console('gs c set EquipStop midcast')
        gs:chat()
        gs:type('/ma "Cure III" <me>')
        assert.same({'Show Sets: Stopping at midcast.'}, gs:chat())
        gs:traffic()
        gs:finish_action()
        assert.same({}, gs:traffic())
        assert.equal("Bunzi's Rod", gs:worn().main)
    end)
end)

describe('gs c curecheat', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('puts sets.HPDown on, then casts Cure IV on Commy a moment later', function()
        local typed = commy.record_input(gs)
        gs:console('gs c curecheat')
        assert.same(commy.worn_by(idle, {ring2 = "Medada's Ring"}), gs:worn())
        assert.same({}, typed)
        gs:advance(0.2)
        assert.same({'/ma "Cure IV" <me>'}, typed)
    end)

    it('lays sets.HPCure over that Cure\'s midcast set, and only that Cure\'s', function()
        gs:console('gs c curecheat')
        gs:advance(0.2)
        assert.equal('Kaykaus Tights', gs:worn().legs)
        gs:finish_action()
        gs:advance(5)
        gs:type('/ma "Cure IV" <me>')
        assert.same(commy.worn_by(idle, {main = "Bunzi's Rod", head = 'Kaykaus Mitra +1', ring1 = 'Kishar Ring'}),
            gs:worn())
    end)
end)

describe('gs c weapons', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('sets the weapon set by name and puts it in hand', function()
        gs:console('gs c weapons Naegling')
        assert.equal('Naegling', gs.user.state.Weapons.value)
        assert.same(commy.worn_by(idle, {main = 'Naegling'}), gs:worn())
    end)

    it('with none sets Weapons None and lets the idle set\'s weapons back on', function()
        gs:console('gs c weapons Naegling')
        gs:console('gs c weapons none')
        assert.equal('None', gs.user.state.Weapons.value)
        assert.same(commy.worn_by(idle), gs:worn())
    end)

    it('with default sets Weapons back to its first set when the job has no default weapons', function()
        gs:console('gs c weapons Naegling')
        gs:console('gs c weapons default')
        assert.equal('None', gs.user.state.Weapons.value)
        assert.equal('Daybreak', gs:worn().main)
    end)

    it('says when there is no weapon set by that name, and keeps the weapons in hand', function()
        gs:console('gs c weapons Crocea')
        gs:chat()
        gs:console('gs c weapons Bogus')
        assert.same({'Error: A weapons set for [Bogus] does not exist.'}, gs:chat())
        assert.equal('Crocea', gs.user.state.Weapons.value)
        assert.equal('Crocea Mors', gs:worn().main)
    end)
end)

describe('gs c weapons initialize, for a red mage whose gear file names default weapons', function()
    -- Commy holding Crocea Mors, with the default weapons named as a gear file names them in user_job_setup.
    local function boot(sub_job)
        local gs = commy.boot_rdm({sub_job = sub_job})
        gs.user.default_weapons = 'Naegling'
        gs:console('gs c weapons Crocea')
        return gs
    end

    it('sets Weapons back to its first set with a mage\'s sub job', function()
        local gs = boot('WHM')
        gs:console('gs c weapons initialize')
        assert.equal('None', gs.user.state.Weapons.value)
    end)

    it('puts the default weapons in hand with a sub job that is no mage\'s', function()
        local gs = boot('WAR')
        gs:console('gs c weapons initialize')
        assert.same({'Naegling', 'Naegling'}, {gs.user.state.Weapons.value, gs:worn().main})
    end)
end)

describe('Sel\'s weapon sets for dual wield', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('are passed over by a cycle when Commy can\'t dual wield, whether named so or with a weapon in the sub', function()
        gs:console('gs c cycle Weapons')
        assert.equal('Naegling', gs.user.state.Weapons.value)
        gs:console('gs c cycle Weapons')
        assert.equal('Crocea', gs.user.state.Weapons.value)
        assert.same(commy.worn_by(idle, {main = 'Crocea Mors'}), gs:worn())
    end)

    it('are passed over backwards by a cycle back', function()
        gs:console('gs c set Weapons Crocea')
        gs:console('gs c cycleback Weapons')
        assert.equal('Naegling', gs.user.state.Weapons.value)
        assert.same(commy.worn_by(idle, {main = 'Naegling'}), gs:worn())
        gs:console('gs c cycleback Weapons')
        assert.equal('None', gs.user.state.Weapons.value)
    end)

    it('named for dual wield are passed over when set by name', function()
        gs:console('gs c set Weapons DualWeapons')
        assert.equal('Naegling', gs.user.state.Weapons.value)
        assert.same(commy.worn_by(idle, {main = 'Naegling'}), gs:worn())
    end)

    it('with a weapon in the sub are passed over when set by name, as User-Globals.lua has it', function()
        gs:console('gs c set Weapons Swords')
        assert.equal('Crocea', gs.user.state.Weapons.value)
        assert.same(commy.worn_by(idle, {main = 'Crocea Mors'}), gs:worn())
    end)

    pending('are passed over when a cycle comes to one named for dual wield right after one with a weapon in the sub: '
        .. 'User-Globals.lua\'s skip_dual_sets cycles on by the sub alone once Sel\'s check by the name has run, so '
        .. 'it stops at the one named for dual wield when that one\'s sub is a shield')
end)

describe('Sel\'s weapon sets for dual wield, with ninja as Commy\'s sub job', function()
    -- Sel looks for the trait with set_dual_wield five seconds after it loads; until then it takes Commy to have none.
    it('are stopped at by a cycle once Commy has the Dual Wield trait', function()
        local gs = commy.boot_rdm({sub_job = 'NIN'})
        gs.game:set_job_traits({'Dual Wield'})
        gs:advance(harness.sel_load_time)
        assert.is_true(gs.user.can_dual_wield)
        gs:console('gs c set Weapons None')
        local seen = {}
        for _ = 1, 3 do
            gs:console('gs c cycle Weapons')
            seen[#seen + 1] = gs.user.state.Weapons.value
        end
        assert.same({'DualWeapons', 'Naegling', 'Swords'}, seen)
    end)
end)
