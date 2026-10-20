local commy = require('commy')

-- Runs a gs c command, lets a moment pass, and returns what was typed for it and what was said in the chat log.
local function run(gs, command)
    local typed = commy.record_input(gs)
    gs:console(command)
    gs:advance(0.1)
    return typed, gs:chat()
end

local function typed_for(gs, command)
    return (run(gs, command))
end

local function said_for(gs, command)
    local _, said = run(gs, command)
    return said
end

describe('gs c elemental', function()
    local gs, monster
    before_each(function()
        gs = commy.boot_rdm()
        monster = gs.game.monster.id
    end)

    it('spikes casts the element\'s spikes on Commy', function()
        assert.same({'/ma "Blaze Spikes" <me>'}, typed_for(gs, 'gs c elemental spikes'))
    end)

    it('barelement casts the bar spell against the element the mode\'s is strong against', function()
        assert.same({'/ma "Barblizzard" <me>'}, typed_for(gs, 'gs c elemental barelement'))
    end)

    it('tier3 casts that tier of the element\'s nuke', function()
        assert.same({'/ma "Fire III" ' .. monster}, typed_for(gs, 'gs c elemental tier3'))
    end)

    it('ara, aga3, helix, enfeeble, ninjutsu and ancientmagic cast the element\'s spell of that kind', function()
        local cast = {}
        for _, kind in ipairs({'ara', 'aga3', 'helix', 'enfeeble', 'ninjutsu', 'ancientmagic'}) do
            cast[#cast + 1] = typed_for(gs, 'gs c elemental ' .. kind)[1]
            gs:advance(5)
        end
        assert.same({'/ma "Fira" ' .. monster, '/ma "Firaga III" ' .. monster, '/ma "Pyrohelix" ' .. monster,
            '/ma "Burn" ' .. monster, '/ma "Katon: Ni" ' .. monster, '/ma "Flare" ' .. monster}, cast)
    end)

    it('aga casts the first tier when Commy can\'t cast the second', function()
        assert.equal('/ma "Firaga" ' .. monster, typed_for(gs, 'gs c elemental aga')[1])
    end)

    it('bardsong and carol cast the threnody and carol of the element the mode\'s is strong against', function()
        assert.same({'/ma "Ice Threnody" ' .. monster}, typed_for(gs, 'gs c elemental bardsong'))
        gs:advance(5)
        assert.same({'/ma "Ice Carol" ' .. monster}, typed_for(gs, 'gs c elemental carol'))
    end)

    it('threnody casts the element\'s threnody, the first tier when Commy can\'t cast the second', function()
        assert.equal('/ma "Fire Threnody" ' .. monster, typed_for(gs, 'gs c elemental threnody')[1])
    end)

    it('casts at Commy by me and at the battle target by bt', function()
        assert.same({'/ma "Fire III" ' .. gs.game.player.id}, typed_for(gs, 'gs c elemental tier3 <me>'))
        gs:advance(5)
        assert.same({'/ma "Fire III" ' .. monster}, typed_for(gs, 'gs c elemental tier3 bt'))
    end)

    it('casts at Commy when there is no target', function()
        gs.game.target_index = nil
        assert.same({'/ma "Fire III" ' .. gs.game.player.id}, typed_for(gs, 'gs c elemental tier3'))
    end)

    it('says when it is given no command, or one it doesn\'t know', function()
        assert.same({'Error: No elemental command given.'}, said_for(gs, 'gs c elemental'))
        assert.same({'Unrecognized elemental command.'}, said_for(gs, 'gs c elemental bogus'))
    end)

    pending('carol2 casts the element\'s Carol II: handle_elemental types "Ice Carol II " with a space before the '
        .. 'closing quote, as threnody does for a Threnody II')
end)

describe('gs c elemental, for a job file that leaves it to Sel', function()
    local gs
    before_each(function()
        gs = commy.boot_war()
    end)

    it('nuke casts the highest of tiers III, II and I that Commy can cast', function()
        assert.same({'/ma "Fire II" ' .. gs.game.monster.id}, typed_for(gs, 'gs c elemental nuke'))
    end)

    it('weather casts nothing without scholar or red mage as sub job', function()
        assert.same({}, typed_for(gs, 'gs c elemental weather'))
    end)

    it('weather casts Phalanx on Commy with red mage as sub job', function()
        local rdm = commy.boot_war({sub_job = 'RDM'})
        assert.same({'/ma "Phalanx" <me>'}, typed_for(rdm, 'gs c elemental weather'))
    end)
end)

describe('gs c shadows', function()
    it('casts Blink when Commy has no Utsusemi and can cast it', function()
        assert.same({'/ma "Blink" <me>'}, typed_for(commy.boot_rdm(), 'gs c shadows'))
    end)

    it('casts Utsusemi: Ni with ninja as sub job', function()
        local gs = commy.boot_war({sub_job = 'NIN', extra_items = {{name = 'Shihei', count = 10}}})
        assert.same({'/ma "Utsusemi: Ni" <me>'}, typed_for(gs, 'gs c shadows'))
        assert.same({{action = 'Utsusemi: Ni', target = 'Commy'}}, gs:traffic())
    end)

    it('says so when Commy can cast no shadows', function()
        assert.same({'No shadows available!'}, said_for(commy.boot_war(), 'gs c shadows'))
    end)
end)

describe('gs c enmity', function()
    it('casts the first enmity spell Commy can cast at the target', function()
        assert.same({'/ma "Flash" <t>'}, typed_for(commy.boot_rdm(), 'gs c enmity'))
        assert.same({'/ma "Stun" <t>'}, typed_for(commy.boot_war(), 'gs c enmity'))
    end)

    it('says so when the target isn\'t a monster', function()
        local gs = commy.boot_rdm()
        gs.game.target_index = nil
        assert.same({'Abort: You are not targeting a monster.'}, said_for(gs, 'gs c enmity'))
    end)
end)

describe('gs c smartstun', function()
    it('casts Stun at the target when Commy can', function()
        local gs = commy.boot_war()
        assert.same({'/ma "Stun" ' .. gs.game.monster.id}, typed_for(gs, 'gs c smartstun'))
    end)

    it('casts Stun at Commy when given me', function()
        local gs = commy.boot_war()
        assert.same({'/ma "Stun" ' .. gs.game.player.id}, typed_for(gs, 'gs c smartstun me'))
    end)

    it('says so when there is no target', function()
        local gs = commy.boot_war()
        gs.game.target_index = nil
        assert.same({'Smartstun could not find a valid target.'}, said_for(gs, 'gs c smartstun'))
    end)
end)

describe('gs c smartcure', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        gs.game.target_index = nil
    end)

    -- Commy's HP at the percentage, of 1800 as smartcure takes it to be with no target.
    local function at(hpp)
        gs.game.player.vitals.hpp = hpp
        gs.game.player.vitals.hp = 1800 * hpp / 100
    end

    it('casts Cure on Commy when Commy has no target and is missing under 170 HP', function()
        assert.same({'/ma "Cure" ' .. gs.game.player.id}, typed_for(gs, 'gs c smartcure'))
    end)

    it('casts Cure II for under 350 HP missing, Cure III for under 700, and Cure IV for more', function()
        local cast = {}
        for _, hpp in ipairs({85, 70, 50}) do
            at(hpp)
            cast[#cast + 1] = typed_for(gs, 'gs c smartcure')[1]
            gs:advance(10)
        end
        local me = gs.game.player.id
        assert.same({'/ma "Cure II" ' .. me, '/ma "Cure III" ' .. me, '/ma "Cure IV" ' .. me}, cast)
    end)

    it('cures the party member named, by the HP the party reports', function()
        gs.game.player.vitals.hp = 300
        gs.game.player.vitals.hpp = 50
        assert.same({'/ma "Cure II" ' .. gs.game.player.id}, typed_for(gs, 'gs c smartcure Commy'))
    end)

    it('picks its target by <stal> when the target is a monster, and cures the one picked in place of the emote the '
        .. 'pick sends', function()
        gs.game.target_index = gs.game.monster.index
        assert.same({'/dance motion <stal>'}, typed_for(gs, 'gs c smartcure'))
        local typed = commy.record_input(gs)
        local packets = gs.user.packets
        local picked = packets.build(packets.new('outgoing', 0x05D, {['Target ID'] = gs.game.player.id,
            ['Target Index'] = gs.game.player.index, ['Emote'] = 31, ['Type'] = 2}))
        assert.is_true(gs:send_from_client(0x05D, picked:sub(5)))
        assert.same({'/ma "Cure" ' .. gs.game.player.id}, typed)
    end)
end)

describe('gs c scholar', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
    end)

    it('light and dark use the arts when none are up', function()
        assert.same({'/ja "Light Arts" <me>'}, typed_for(gs, 'gs c scholar light'))
        assert.same({'/ja "Dark Arts" <me>'}, typed_for(gs, 'gs c scholar dark'))
    end)

    it('says so when a stratagem is asked for with no arts up', function()
        assert.same({'No arts has been activated yet.'}, said_for(gs, 'gs c scholar cost'))
    end)

    it('uses the Light Arts stratagem for what it is asked for while Light Arts is up', function()
        gs:gain_buff('Light Arts')
        local used = {}
        for _, command in ipairs({'light', 'cost', 'speed', 'aoe', 'power', 'duration', 'accuracy', 'enmity', 'addendum'}) do
            used[#used + 1] = typed_for(gs, 'gs c scholar ' .. command)[1]
        end
        assert.same({'/ja "Addendum: White" <me>', '/ja "Penury" <me>', '/ja "Celerity" <me>', '/ja "Accession" <me>',
            '/ja "Rapture" <me>', '/ja "Perpetuance" <me>', '/ja "Altruism" <me>', '/ja "Tranquility" <me>',
            '/ja "Addendum: White" <me>'}, used)
    end)

    it('uses the Dark Arts stratagem for what it is asked for while Dark Arts is up', function()
        gs:gain_buff('Dark Arts')
        local used = {}
        for _, command in ipairs({'dark', 'cost', 'speed', 'aoe', 'power', 'accuracy', 'enmity', 'skillchain', 'addendum'}) do
            used[#used + 1] = typed_for(gs, 'gs c scholar ' .. command)[1]
        end
        assert.same({'/ja "Addendum: Black" <me>', '/ja "Parsimony" <me>', '/ja "Alacrity" <me>',
            '/ja "Manifestation" <me>', '/ja "Ebullience" <me>', '/ja "Focalization" <me>', '/ja "Equanimity" <me>',
            '/ja "Immanence" <me>', '/ja "Addendum: Black" <me>'}, used)
    end)

    it('says what an arts lacks, or doesn\'t know', function()
        gs:gain_buff('Light Arts')
        assert.same({'Error: Light Arts does not have a skillchain command.'}, said_for(gs, 'gs c scholar skillchain'))
        assert.same({'Error: Unknown command [bogus]'}, said_for(gs, 'gs c scholar bogus'))
        gs:lose_buff('Light Arts')
        gs:gain_buff('Dark Arts')
        assert.same({'Error: Dark Arts does not have a duration command.'}, said_for(gs, 'gs c scholar duration'))
    end)

    it('light and dark use Accession and Manifestation once the addendum is up', function()
        gs:gain_buff('Addendum: White')
        assert.same({'/ja "Accession" <me>'}, typed_for(gs, 'gs c scholar light'))
        gs:lose_buff('Addendum: White')
        gs:gain_buff('Addendum: Black')
        assert.same({'/ja "Manifestation" <me>'}, typed_for(gs, 'gs c scholar dark'))
    end)

    it('cost uses Penury with Addendum: White up in place of Light Arts', function()
        gs:gain_buff('Addendum: White')
        assert.same({'/ja "Penury" <me>'}, typed_for(gs, 'gs c scholar cost'))
    end)

    it('power uses Ebullience with Addendum: Black up in place of Dark Arts', function()
        gs:gain_buff('Addendum: Black')
        assert.same({'/ja "Ebullience" <me>'}, typed_for(gs, 'gs c scholar power'))
    end)

    it('buff uses Light Arts unless Addendum: White is up', function()
        assert.same({'/ja "Light Arts" <me>'}, typed_for(gs, 'gs c scholar buff'))
        gs:gain_buff('Addendum: White')
        assert.same({}, typed_for(gs, 'gs c scholar buff'))
    end)

    it('says when it is given no command', function()
        assert.same({'Error: No scholar command given.'}, said_for(gs, 'gs c scholar'))
    end)
end)
