local commy = require('commy')

describe('Sel, for a spell Commy can\'t cast', function()
    it('uses Prism Powder for Invisible when Commy has some', function()
        local gs = commy.boot_thf({extra_items = {{name = 'Prism Powder', count = 12}}})
        local typed, said = commy.run(gs, 'input /ma "Invisible" <me>')
        assert.same({'/item "Prism Powder" <me>'}, typed)
        assert.same({'You can\'t cast Invisible, attempting to use Prism Powder instead.'}, said)
    end)

    it('uses Silent Oil for Sneak when Commy has some', function()
        local gs = commy.boot_thf({extra_items = {{name = 'Silent Oil', count = 12}}})
        local typed, said = commy.run(gs, 'input /ma "Sneak" <me>')
        assert.same({'/item "Silent Oil" <me>'}, typed)
        assert.same({'You can\'t cast Sneak, attempting to use Silent Oil instead.'}, said)
    end)

    it('says so when Commy has no other way to Invisible or Sneak', function()
        local gs = commy.boot_thf()
        assert.same({'All attempts to use [Invisible] failed.'}, commy.said_for(gs, 'input /ma "Invisible" <me>'))
        assert.same({'All attempts to use [Sneak] failed.'}, commy.said_for(gs, 'input /ma "Sneak" <me>'))
    end)

    it('sets the Warp Ring to be used for Warp', function()
        local gs = commy.boot_thf()
        local typed, said = commy.run(gs, 'input /ma "Warp" <me>')
        assert.same({}, typed)
        assert.same({'You can\'t cast warp, attempting to use Warp Ring instead, /heal to cancel.'}, said)
        assert.same({true, 'Warp Ring', 'ring2'}, {gs.user.useItem, gs.user.useItemName, gs.user.useItemSlot})
    end)

    it('sends none of them to the game', function()
        local cases = {
            {'Invisible', {{name = 'Prism Powder', count = 12}}},
            {'Sneak', {{name = 'Silent Oil', count = 12}}},
            {'Invisible'}, {'Sneak'}, {'Warp'},
        }
        for _, case in ipairs(cases) do
            local gs = commy.boot_thf({extra_items = case[2]})
            local line = ('/ma "%s" <me>'):format(case[1])
            assert.is_true(gs:type(line), line)
            assert.same({{}, {}}, {gs:traffic(), gs:typed()}, line)
        end
    end)
end)
