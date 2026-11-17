local plain = require('plain')
local testy = require('testy')

local calls, events = plain.calls, plain.names

-- Testy on the user file Testy_Actions.lua, the game then told it is these jobs: the file doesn't depend on the job.
local function boot(jobs, extra_items)
    local items = testy.whm().items
    for _, item in ipairs(extra_items or {}) do
        items[#items + 1] = item
    end
    local gs = plain.boot('Testy_Actions.lua', {items = items})
    local player = gs.game.player
    player.main_job_id, player.sub_job_id = jobs.main, jobs.sub
    player.main_job_level, player.sub_job_level = jobs.main_level or 99, jobs.sub_level or 49
    gs.env._settings.debug_mode = true
    plain.refresh(gs)
    gs:chat_lines()
    return gs
end

-- Types the line, and says whether the action went on to its precast, with the reason debug mode gave when not.
local function cast(gs, line)
    gs:type(line)
    local went = events(calls(gs))[2] == 'precast'
    local reasons = {}
    for _, text in ipairs(gs:chat()) do
        local reason = text:match('^GearSwap %(Debug Mode%): (Unable to .*)$')
        if reason then
            reasons[#reasons + 1] = reason
        end
    end
    gs:traffic()
    return went, reasons[1]
end

local scholar, white_mage, red_mage, ninja = 20, 3, 5, 13

describe('a spell that needs the Addendum', function()
    it('is refused to a scholar whose sub job can\'t cast it, without the Addendum', function()
        local gs = boot({main = scholar, sub = red_mage})
        local went, reason = cast(gs, '/ma Poisona <me>')
        assert.is_false(went)
        assert.equal('Unable to execute command. Addendum required for that spell (Poisona)', reason)
    end)

    it('is cast by a scholar with Addendum: White up', function()
        local gs = boot({main = scholar, sub = red_mage})
        gs:gain_buff('Addendum: White')
        assert.is_true((cast(gs, '/ma Poisona <me>')))
    end)

    it('is cast by a scholar whose sub job can cast it at its level', function()
        local gs = boot({main = scholar, sub = white_mage})
        assert.is_true((cast(gs, '/ma Poisona <me>')))
    end)

    it('is refused to a scholar whose sub job has the spell above its level', function()
        local gs = boot({main = scholar, sub = white_mage, sub_level = 5})
        local went, reason = cast(gs, '/ma Poisona <me>')
        assert.is_false(went)
        assert.matches('Addendum required', reason)
    end)

    it('is cast by a white mage with a scholar sub job, whatever the Addendum', function()
        local gs = boot({main = white_mage, sub = scholar})
        assert.is_true((cast(gs, '/ma Poisona <me>')))
    end)

    it('is refused to a white mage with a scholar sub job when the white mage can\'t cast it itself', function()
        local gs = boot({main = white_mage, sub = scholar, main_level = 3})
        local went, reason = cast(gs, '/ma Poisona <me>')
        assert.is_false(went)
        assert.matches('Addendum required', reason)
    end)

    it('is cast by a scholar with no Addendum when it is not one of the spells that need it', function()
        local gs = boot({main = scholar, sub = red_mage})
        assert.is_true((cast(gs, '/ma "Cure III" <me>')))
    end)
end)

describe('a spell the job has at a higher level', function()
    it('is refused with the reason for it', function()
        local gs = boot({main = white_mage, sub = red_mage, main_level = 10, sub_level = 5})
        local went, reason = cast(gs, '/ma "Cure III" <me>')
        assert.is_false(went)
        assert.equal('Unable to execute command. You do not have access to that spell (Cure III)', reason)
    end)

    it('is cast at exactly its level', function()
        local gs = boot({main = white_mage, sub = red_mage, main_level = 21, sub_level = 5})
        assert.is_true((cast(gs, '/ma "Cure III" <me>')))
    end)

    it('is refused a level below', function()
        local gs = boot({main = white_mage, sub = red_mage, main_level = 20, sub_level = 5})
        assert.is_false((cast(gs, '/ma "Cure III" <me>')))
    end)
end)

describe('a spell the character doesn\'t know', function()
    it('is refused with the reason for it', function()
        local gs = boot({main = white_mage, sub = red_mage})
        gs.game.spells[3] = nil
        local went, reason = cast(gs, '/ma "Cure III" <me>')
        assert.is_false(went)
        assert.equal('Unable to execute command. You do not know that spell (Cure III)', reason)
    end)
end)

describe('a ninjutsu spell', function()
    local utsusemi = '/nin "Utsusemi: Ichi" <me>'

    it('is refused to a ninja with none of the tools, with the reason for it', function()
        local gs = boot({main = ninja, sub = red_mage})
        local went, reason = cast(gs, utsusemi)
        assert.is_false(went)
        assert.equal('Unable to make action packet. You do not have the proper tools.', reason)
    end)

    it('is cast by a ninja with the tools for it', function()
        local gs = boot({main = ninja, sub = red_mage}, {{name = 'Shihei'}})
        assert.is_true((cast(gs, utsusemi)))
    end)

    it('is cast by a ninja with the tools for every spell, and none of the single ones', function()
        local gs = boot({main = ninja, sub = red_mage}, {{name = 'Shikanofuda'}})
        assert.is_true((cast(gs, utsusemi)))
    end)

    it('is not cast by a ninja sub job with only the tools for every spell', function()
        local gs = boot({main = white_mage, sub = ninja, main_level = 99, sub_level = 49}, {{name = 'Shikanofuda'}})
        local went, reason = cast(gs, utsusemi)
        assert.is_false(went)
        assert.equal('Unable to make action packet. You do not have the proper tools.', reason)
    end)

    it('is cast by a ninja sub job with the tools for it', function()
        local gs = boot({main = white_mage, sub = ninja, sub_level = 49}, {{name = 'Shihei'}})
        assert.is_true((cast(gs, utsusemi)))
    end)

    it('is refused to a job that isn\'t a ninja, whatever the tools', function()
        local gs = boot({main = white_mage, sub = red_mage}, {{name = 'Shihei'}})
        local went, reason = cast(gs, utsusemi)
        assert.is_false(went)
        assert.matches('You do not have access to that spell', reason)
    end)
end)

describe('a weapon skill or ability the character lacks', function()
    it('is refused with the reason for it', function()
        local gs = boot({main = white_mage, sub = red_mage})
        gs.game.weapon_skills = {}
        gs.game.job_abilities = {}
        local _, ws = cast(gs, '/ws "Black Halo" <t>')
        local _, ja = cast(gs, '/ja "Divine Seal" <me>')
        assert.same({'Unable to execute command. You do not have access to that weapon skill.',
            'Unable to execute command. You do not have access to that job ability.'}, {ws, ja})
    end)
end)
