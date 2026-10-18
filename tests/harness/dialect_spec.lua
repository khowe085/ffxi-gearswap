local dialect = require('dialect')

describe('reading Windower\'s Lua', function()
    it('puts a literal that a method is called on in parentheses', function()
        assert.equal("x = ('%d items'):format(n) .. (\"I\"):pack(id) .. (0):char() .. (0x50):char()",
            dialect.translate("x = '%d items':format(n) .. \"I\":pack(id) .. 0:char() .. 0x50:char()"))
        assert.equal('f = (true):fn() or ([[long]]):upper()', dialect.translate('f = true:fn() or [[long]]:upper()'))
    end)

    it('puts a table constructor or a function expression that is called in parentheses', function()
        assert.equal('x = ({1, {2}}):map(f)', dialect.translate('x = {1, {2}}:map(f)'))
        assert.equal('cond = (function() if a then return 1 end end)()',
            dialect.translate('cond = function() if a then return 1 end end()'))
        assert.equal('(function() end):schedule(1)', dialect.translate('function() end:schedule(1)'))
    end)

    it('leaves alone what plain Lua reads the same', function()
        local source = table.concat({
            "local function f(s) return s:upper() end",
            "t.x = T{1, 2}:contains(1) and a['k']:lower() or s:format('a:b')",
            "-- a comment with 'quotes':format() and [[brackets]]",
            "--[==[ a block comment, 0:char() ]==] y = f'x' .. 'it''s'",
            "z = x1:foo() + 2 - -3 .. '\\'' .. \"\\\"\"",
            "local g = function(a) return a end",
            "h = function() end",
            "(i)()",
        }, '\n')
        assert.equal(source, dialect.translate(source))
    end)

    it('keeps each line where it was', function()
        local translated = dialect.translate("a = 'x':upper()\n\nb = 1:char()\n")
        assert.equal("a = ('x'):upper()\n\nb = (1):char()\n", translated)
    end)
end)
