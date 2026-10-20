local autoy = require('autoy')

local function on_me(name)
    return {action = name, target = 'Autoy'}
end

-- Autoy having just cast Haste. Sel's tick waits 3.85 seconds from the precast of Haste, a 3-second spell, and
-- 2.5 seconds from its end, before it acts again.
local function just_cast(options)
    local gs = autoy.boot(options)
    gs:type('/ma "Haste" <me>')
    gs:finish_action()
    gs:traffic()
    return gs
end

describe('Sel\'s MiniQueue', function()
    it('holds a spell typed during the wait after the last action, and casts it from the tick once the wait is over', function()
        local gs = just_cast()
        assert.is_true(gs:type('/ma "Phalanx" <me>'))
        assert.same({}, gs:action_entries())
        gs:play(4.5)
        assert.same({on_me('Phalanx')}, gs:action_entries())
    end)

    it('holds only the last spell typed during the wait', function()
        local gs = just_cast()
        gs:type('/ma "Phalanx" <me>')
        gs:type('/ma "Stoneskin" <me>')
        gs:play(4.5)
        assert.same({on_me('Stoneskin')}, gs:action_entries())
    end)

    it('lets a spell typed during the wait straight through when turned off', function()
        local gs = just_cast()
        gs:console('gs c toggle MiniQueue')
        gs:traffic()
        gs:type('/ma "Phalanx" <me>')
        assert.same({on_me('Phalanx')}, gs:action_entries())
    end)

    it('holds a spell typed while walking until the character stands', function()
        local gs = autoy.boot()
        gs.game:walk()
        gs:play(1.5)
        gs:traffic()
        assert.is_true(gs:type('/ma "Phalanx" <me>'))
        gs:play(2)
        assert.same({}, gs:action_entries())
        gs.game:stand()
        gs:play(1)
        assert.same({on_me('Phalanx')}, gs:action_entries())
    end)

    it('drops a held spell once the character walks off', function()
        local gs = just_cast()
        gs:type('/ma "Phalanx" <me>')
        gs.game:walk()
        gs:play(1.5)
        gs.game:stand()
        gs:play(4.5)
        assert.same({}, gs:action_entries())
    end)
end)
