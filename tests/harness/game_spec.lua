local Game = require('game')
local harness = require('harness')
local testy = require('testy')

describe('the stand-in game', function()
    it('stops a clock whose timers never run out, rather than running for ever', function()
        local game = Game.new({res = harness.resources()})
        local function again()
            game:schedule(again, 0)
        end
        game:schedule(again, 0)
        assert.has_error(function() game:advance(1) end, 'the game\'s timers never ran out; something keeps setting more')
    end)

    it('plays frames: the clock moves on a tenth of a second at a time, with prerender each frame', function()
        local game = Game.new({res = harness.resources()})
        local frames = {}
        game:register('prerender', function() frames[#frames + 1] = game.clock end)
        local start = game.clock
        game:play(1)
        assert.equal(10, #frames)
        assert.near(start + 0.1, frames[1], 1e-9)
        assert.near(start + 1, frames[10], 1e-9)
        assert.near(start + 1, game.clock, 1e-9)
    end)

    it('puts two copies of a piece named for two slots in those slots, one each', function()
        local gs = harness.boot(testy.whm({
            items = {{name = 'Stikini Ring +1'}, {name = 'Stikini Ring +1', bag = 'wardrobe'}},
            wearing = {left_ring = 'Stikini Ring +1', right_ring = 'Stikini Ring +1'},
        }))
        assert.same({left_ring = 'Stikini Ring +1', right_ring = 'Stikini Ring +1'}, gs:worn())
        assert.are_not.same(gs.game.equipment[13], gs.game.equipment[14])
    end)
end)
