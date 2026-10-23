local harness = require('harness')
local testy = require('testy')

local function boot()
    return harness.boot(testy.whm())
end

describe('the mobs the stand-in game adds', function()
    it('hold their distance squared, as Windower gives it, and stand that many yalms along the x axis', function()
        local gs = boot()
        local mob = gs.game:add_mob({name = 'Moogle', distance = 4 ^ 2})
        local seen = gs.game.windower.ffxi.get_mob_by_index(mob.index)
        assert.same({16, 4, 'Moogle'}, {seen.distance, seen.x, seen.name})
    end)

    it('take the next index when they are given none, one game after another counting from 0x500', function()
        local gs = boot()
        assert.same({0x500, 0x501}, {gs.game:add_mob({}).index, gs.game:add_party_member({}).index})
        assert.equal(0x500, boot().game:add_mob({}).index)
    end)

    it('are handed out as copies, which GearSwap may write into', function()
        local gs = boot()
        local mob = gs.game:add_mob({name = 'Moogle'})
        gs.game.windower.ffxi.get_mob_by_index(mob.index).name = 'Changed'
        assert.equal('Moogle', gs.game.windower.ffxi.get_mob_by_index(mob.index).name)
    end)

    it('are listed by name when asked for by name', function()
        local gs = boot()
        local moogle = gs.game:add_mob({name = 'Nomad Moogle'})
        gs.game:add_mob({name = 'Other'})
        assert.same({[moogle.index] = 'Nomad Moogle'}, gs.game.windower.ffxi.get_mob_list('Nomad Moogle'))
    end)

    it('are all listed when no name is given', function()
        local gs = boot()
        gs.game:add_mob({name = 'Other'})
        local count = 0
        for _ in pairs(gs.game.windower.ffxi.get_mob_list()) do
            count = count + 1
        end
        assert.equal(3, count)
    end)

    it('can be removed', function()
        local gs = boot()
        local mob = gs.game:add_mob({name = 'Moogle'})
        gs.game:remove_mob(mob.index)
        assert.is_nil(gs.game.windower.ffxi.get_mob_by_index(mob.index))
    end)

    it('are the target when the game is told to target them', function()
        local gs = boot()
        local mob = gs.game:add_mob({name = 'Moogle'})
        gs.game:target(mob.index)
        assert.equal('Moogle', gs.game.windower.ffxi.get_mob_by_target('<t>').name)
    end)

    it('are the subtarget, <st>, when the game is told so', function()
        local gs = boot()
        local mob = gs.game:add_mob({name = 'Moogle'})
        gs.game:subtarget(mob.index)
        assert.equal('Moogle', gs.game.windower.ffxi.get_mob_by_target('<st>').name)
    end)

    it('are monsters, to GearSwap and by their spawn type, when added as one', function()
        local gs = boot()
        gs.game:target(gs.game:add_mob({name = 'Goblin', monster = true}).index)
        gs.env.refresh_globals()
        assert.same({'MONSTER', 16}, {gs.env.player.target.type, gs.env.player.target.spawn_type})
    end)

    it('say a change of target with the target change event, which is handed the new target\'s index', function()
        local gs = boot()
        local mob = gs.game:add_mob({name = 'Moogle'})
        local seen = {}
        gs.game:register('target change', function(...) seen[#seen + 1] = {...} end)
        gs.game:target(mob.index)
        gs.game:target(mob.index)
        gs.game:target(nil)
        assert.same({{mob.index}, {0}}, seen)
    end)
end)

describe('the battle target in the stand-in game, <bt>', function()
    local function battle_target(gs)
        local mob = gs.game.windower.ffxi.get_mob_by_target('<bt>')
        return mob and mob.name
    end

    it('is none while no one has claimed the monster', function()
        assert.is_nil(battle_target(boot()))
    end)

    it('is the monster the character has claimed, whatever is targeted', function()
        local gs = boot()
        gs.game.monster.claim_id = gs.game.player.id
        gs.game:target(gs.game:add_party_member({name = 'Pal', in_party = false}).index)
        assert.equal('Apex Toad', battle_target(gs))
    end)

    it('is the monster a member of the alliance has claimed', function()
        local gs = boot()
        local member = gs.game:add_party_member({name = 'Friend', slot = 'a10'})
        gs.game.monster.claim_id = member.id
        assert.equal('Apex Toad', battle_target(gs))
    end)

    it('is none for a monster another player has claimed', function()
        local gs = boot()
        gs.game.monster.claim_id = gs.game:add_party_member({name = 'Stranger', in_party = false}).id
        assert.is_nil(battle_target(gs))
    end)

    it('is the targeted monster of two the character has claimed', function()
        local gs = boot()
        gs.game.monster.claim_id = gs.game.player.id
        local other = gs.game:add_mob({name = 'Goblin', monster = true, claim_id = gs.game.player.id})
        gs.game:target(other.index)
        assert.equal('Goblin', battle_target(gs))
    end)

    it('is a monster the character has claimed besides the toad, when neither the toad nor the target is', function()
        local gs = boot()
        gs.game:add_mob({name = 'Goblin', monster = true, claim_id = gs.game.player.id})
        gs.game:target(gs.game:add_mob({name = 'Moogle'}).index)
        assert.equal('Goblin', battle_target(gs))
    end)

    it('is claimed by the character once the monster acts on it', function()
        local gs = boot()
        gs:monster_hits()
        assert.equal(gs.game.player.id, gs.game.monster.claim_id)
        assert.equal('Apex Toad', battle_target(gs))
    end)

    it('is claimed by the character once an action of theirs lands on the monster', function()
        local gs = boot()
        gs:type('/ma "Dia" <t>')
        gs:finish_action()
        assert.equal(gs.game.player.id, gs.game.monster.claim_id)
        assert.equal('Apex Toad', battle_target(gs))
    end)

    it('is not claimed by an action of the character\'s that is interrupted before it lands', function()
        local gs = boot()
        gs:type('/ma "Dia" <t>')
        gs:interrupt_action()
        assert.is_nil(battle_target(gs))
    end)

    it('is no NPC, though an action of the character\'s lands on it', function()
        local gs = boot()
        gs.game:target(gs.game:add_mob({name = 'Moogle'}).index)
        gs:type('/ma "Dia" <t>')
        gs:finish_action()
        assert.same({{action = 'Dia', target = 'Moogle'}}, gs:action_entries())
        assert.is_nil(battle_target(gs))
    end)
end)
