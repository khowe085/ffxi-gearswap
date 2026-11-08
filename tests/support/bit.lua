-------------------------------------------------------------------------------------------------------------------
-- Stands in for LuaJIT's bit library, which Windower's Lua has built in and a plain Lua 5.1 lacks. Like LuaJIT's,
-- each function works on 32-bit integers and returns a signed one, so bit.band(0xFFFFFFFF, 0xFFFFFFFF) is -1.
-------------------------------------------------------------------------------------------------------------------

local floor = math.floor

local bit = {}

local function unsigned(x)
    return floor(x) % 2 ^ 32
end

function bit.tobit(x)
    x = unsigned(x)
    if x >= 2 ^ 31 then
        return x - 2 ^ 32
    end
    return x
end

-- Combines the bits of the numbers one place at a time, keeping a bit where keep(count of ones, count of numbers).
local function combine(keep, ...)
    local values = {...}
    for i, value in ipairs(values) do
        values[i] = unsigned(value)
    end
    local result, scale = 0, 1
    for _ = 1, 32 do
        local ones = 0
        for i, value in ipairs(values) do
            ones = ones + value % 2
            values[i] = floor(value / 2)
        end
        if keep(ones, #values) then
            result = result + scale
        end
        scale = scale * 2
    end
    return bit.tobit(result)
end

function bit.band(...)
    return combine(function(ones, count) return ones == count end, ...)
end

function bit.bor(...)
    return combine(function(ones) return ones > 0 end, ...)
end

function bit.bxor(...)
    return combine(function(ones) return ones % 2 == 1 end, ...)
end

function bit.bnot(x)
    return bit.tobit(2 ^ 32 - 1 - unsigned(x))
end

function bit.lshift(x, n)
    return bit.tobit(unsigned(x) * 2 ^ (n % 32))
end

function bit.rshift(x, n)
    return bit.tobit(floor(unsigned(x) / 2 ^ (n % 32)))
end

function bit.arshift(x, n)
    return bit.tobit(floor(bit.tobit(x) / 2 ^ (n % 32)))
end

function bit.tohex(x, n)
    n = n or 8
    local digits = ('%08x'):format(unsigned(x))
    if n < 0 then
        digits, n = digits:upper(), -n
    end
    return digits:sub(-n)
end

return bit
