local commy = require('commy')

describe('a spell Commy casts', function()
    local gs
    before_each(function()
        gs = commy.boot_rdm()
        gs:console('gs c set TreasureMode None')
    end)

    it('gives what is worn once it has gone out', function()
        assert.equal('Telchine Braconi', commy.cast(gs, '/ma "Barfira" <me>').legs)
        assert.equal('Barfira', gs.game.actions[#gs.game.actions].name)
    end)

    it('fails the test when another spell goes out in its place, as one Sel steps down for its recast', function()
        gs.game:start_spell_recast('Barfira', 30)
        local ok, failure = pcall(commy.cast, gs, '/ma "Barfira" <me>')
        assert.is_false(ok)
        assert.matches('/ma "Barfira" <me> didn\'t go out alone', tostring(failure), 1, true)
    end)

    it('fails the test for a line not in the /ma "Name" form, though nothing went out', function()
        local ok, failure = pcall(commy.cast, gs, '/magic "Barfira" <me>')
        assert.is_false(ok)
        assert.matches('a spell is typed as /ma "Name", not as /magic "Barfira" <me>', tostring(failure), 1, true)
        assert.same({}, gs:traffic())
    end)
end)
