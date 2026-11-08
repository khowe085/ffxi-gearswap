local harness = require('harness')
local commy = require('commy')

-- The message of the error fn raises, without the place it was raised from.
local function error_of(fn)
    local ok, message = pcall(fn)
    assert.is_false(ok, 'it raised no error')
    return (tostring(message):gsub('^.-:%d+: ', ''))
end

describe('Sel\'s list mode', function()
    local gs, M
    before_each(function()
        gs = harness.boot(commy.rdm())
        M = gs.user.M
    end)

    it('starts on its first option, which is also its default', function()
        local m = M{'Normal', 'Acc', 'Att'}
        assert.equal('Normal', m.value)
        assert.equal('Normal', m.current)
        assert.equal('Normal', m.default)
        assert.equal(1, m.index)
    end)

    it('reads its fields in any case', function()
        local m = M{'Normal', 'Acc'}
        m:cycle()
        assert.equal('Acc', m.Value)
        assert.equal('Acc', m.CURRENT)
        assert.equal(2, m.Index)
    end)

    it('keeps the description it was made with', function()
        local m = M{['description'] = 'Offense Mode', 'Normal', 'Acc'}
        assert.equal('Offense Mode', m.description)
    end)

    it('is Normal alone when made with no options', function()
        local m = M{['description'] = 'Hybrid Mode'}
        assert.equal('Normal', m.value)
        assert.equal(1, #m)
    end)

    it('takes its options as arguments, with no description', function()
        local m = M('Single', 'Lock')
        assert.equal('Single', m.value)
        assert.equal(2, #m)
        assert.is_nil(m.description)
    end)

    it('counts its options with #', function()
        assert.equal(3, #M{'Normal', 'Acc', 'Att'})
    end)

    it('cycles forward, and from the last option to the first', function()
        local m = M{'Normal', 'Acc', 'Att'}
        assert.equal('Acc', m:cycle())
        assert.equal('Att', m:cycle())
        assert.equal('Normal', m:cycle())
    end)

    it('cycles back, and from the first option to the last', function()
        local m = M{'Normal', 'Acc', 'Att'}
        assert.equal('Att', m:cycleback())
        assert.equal('Acc', m:cycleback())
    end)

    it('steps forward when toggled, as a cycle does', function()
        local m = M{'Normal', 'Acc'}
        assert.equal('Acc', m:toggle())
        assert.equal('Normal', m:toggle())
    end)

    it('notes the way it was last cycled in cycle_direction', function()
        local m = M{'Normal', 'Acc'}
        m:cycleback()
        assert.equal('backward', gs.user.cycle_direction)
        m:cycle()
        assert.equal('forward', gs.user.cycle_direction)
    end)

    it('is set to an option by its name, in any case', function()
        local m = M{'Normal', 'Acc', 'Att'}
        assert.equal('Att', m:set('Att'))
        assert.equal('Acc', m:set('acc'))
        assert.equal(2, m.index)
    end)

    it('refuses an option it doesn\'t have, and stays where it was', function()
        local m = M{'Normal', 'Acc'}
        m:set('Acc')
        assert.equal('Unknown mode value: Bogus', error_of(function() m:set('Bogus') end))
        assert.equal('Acc', m.value)
    end)

    it('refuses to be set to nothing', function()
        local m = M{'Normal', 'Acc'}
        assert.equal('List variable cannot be set to nil.', error_of(function() m:set() end))
    end)

    it('goes back to its first option when reset', function()
        local m = M{'Normal', 'Acc', 'Att'}
        m:set('Att')
        assert.equal('Normal', m:reset())
    end)

    it('takes a new list of options, keeping its description, and starts it at the first', function()
        local m = M{['description'] = 'Idle Mode', 'Normal', 'DT'}
        m:set('DT')
        m:options('Refresh', 'DT', 'Regen')
        assert.equal('Refresh', m.value)
        assert.equal(3, #m)
        assert.equal('Idle Mode', m.description)
        assert.is_false(m:contains('Normal'))
    end)

    it('is Normal alone when given an empty list of options', function()
        local m = M{'Acc', 'Att'}
        m:options()
        assert.equal('Normal', m.value)
        assert.equal(1, #m)
    end)

    it('says whether an option is in its list, by its exact name', function()
        local m = M{'Normal', 'Acc'}
        assert.is_true(m:contains('Acc'))
        assert.is_false(m:contains('acc'))
        assert.is_false(m:contains('Att'))
    end)

    it('has a value unless the option is None or empty', function()
        local m = M{'None', 'Naegling', ''}
        assert.is_false(m.has_value)
        m:set('Naegling')
        assert.is_true(m.has_value)
        m:set('')
        assert.is_false(m.has_value)
    end)

    it('can\'t be unset', function()
        local m = M{'Normal', 'Acc'}
        assert.equal('Cannot unset a list mode class.', error_of(function() m:unset() end))
    end)

    it('prints as its description, its options and the current one', function()
        local m = M{['description'] = 'Casting Mode', 'Normal', 'Resistant'}
        m:cycle()
        assert.equal('Casting Mode: {Normal, Resistant} (Resistant)', tostring(m))
        assert.equal('{Normal, Resistant} (Normal)', tostring(M{'Normal', 'Resistant'}))
    end)

    pending('is reset by m:default(), as Sel-Modes.lua\'s header says: m.default reads the default option, so '
        .. 'm:default() calls a string and raises an error')
end)

describe('Sel\'s boolean mode', function()
    local M
    before_each(function()
        M = harness.boot(commy.rdm()).user.M
    end)

    it('is off when made with false or nothing, and reads off as its current', function()
        for _, m in ipairs({M(false), M()}) do
            assert.is_false(m.value)
            assert.equal('off', m.current)
            assert.is_false(m.index)
        end
    end)

    it('is on when made with true, with the description it was given', function()
        local m = M(true, 'Display Mode')
        assert.is_true(m.value)
        assert.equal('on', m.current)
        assert.equal('Display Mode', m.description)
        assert.is_true(m.default)
    end)

    it('flips when toggled, cycled or cycled back', function()
        local m = M(false)
        assert.equal('on', m:toggle())
        assert.equal('off', m:cycle())
        assert.equal('on', m:cycleback())
    end)

    it('is set on with no value', function()
        local m = M(false)
        assert.equal('on', m:set())
    end)

    it('is set by a boolean, or by on, off, true or false in any case', function()
        local m = M(false)
        assert.equal('on', m:set(true))
        assert.equal('off', m:set(false))
        assert.equal('on', m:set('On'))
        assert.equal('off', m:set('OFF'))
        assert.equal('on', m:set('true'))
        assert.equal('off', m:set('False'))
    end)

    it('refuses any other word', function()
        local m = M(false)
        assert.equal('Unrecognized value: maybe', error_of(function() m:set('maybe') end))
        assert.equal('Unrecognized value type: number', error_of(function() m:set(1) end))
    end)

    it('is turned off when unset, and back to its default when reset', function()
        local m = M(true)
        assert.equal('off', m:unset())
        assert.equal('on', m:reset())
    end)

    it('always has a value', function()
        assert.is_true(M(false).has_value)
    end)

    it('can\'t be given a list of options, nor be asked whether it contains one', function()
        local m = M(false)
        assert.equal('Can only revise the options list for a list mode class.', error_of(function() m:options('a') end))
        assert.equal('Cannot test for containment on a boolean mode class.', error_of(function() m:contains('on') end))
    end)

    it('prints as its description, Boolean and whether it is on', function()
        assert.equal('Kiting: Boolean (on)', tostring(M(true, 'Kiting')))
        assert.equal('Boolean (off)', tostring(M(false)))
    end)
end)

describe('Sel\'s string mode', function()
    local M
    before_each(function()
        M = harness.boot(commy.rdm()).user.M
    end)

    it('holds the string it was made with', function()
        local m = M{['description'] = 'Combat Form', ['string'] = 'DW'}
        assert.equal('DW', m.value)
        assert.equal('DW', m.current)
        assert.equal('Combat Form', m.description)
    end)

    it('is set to any string, and refuses anything else', function()
        local m = M{['string'] = ''}
        assert.equal('Sword', m:set('Sword'))
        assert.equal('Unrecognized value type: number', error_of(function() m:set(5) end))
    end)

    it('is emptied when unset, and back to the string it was made with when reset', function()
        local m = M{['string'] = 'DW'}
        m:set('Sword')
        assert.equal('', m:unset())
        assert.equal('DW', m:reset())
    end)

    it('has a value only while its string isn\'t empty', function()
        local m = M{['string'] = ''}
        assert.is_false(m.has_value)
        m:set('DW')
        assert.is_true(m.has_value)
    end)

    it('stays as it is when cycled', function()
        local m = M{['string'] = 'DW'}
        assert.equal('DW', m:cycle())
        assert.equal('DW', m:cycleback())
    end)

    it('prints as its description, String and its string', function()
        assert.equal('Combat Form: String (DW)', tostring(M{['description'] = 'Combat Form', ['string'] = 'DW'}))
    end)
end)

describe('Sel\'s mode constructor', function()
    it('refuses anything but strings, a table or a boolean', function()
        local M = harness.boot(commy.rdm()).user.M
        assert.equal('Unable to construct a mode table with the provided parameters.', error_of(function() M(5) end))
    end)
end)
