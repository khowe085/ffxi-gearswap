-------------------------------------------------------------------------------------------------------------------
-- Stands in for Windower's pack, a C module, so the tests run on a plain Lua 5.1. Like it, it adds string.pack and
-- string.unpack, in the formats GearSwap, Sel and Windower's libraries use:
--
--   <  >      little endian (the default) or big endian for the items after it
--   C  c  B   an unsigned byte, a signed byte, a byte read as a boolean
--   H  h      an unsigned or signed 16-bit integer
--   I  i      an unsigned or signed 32-bit integer
--   f         a 32-bit float
--   b<n>      an unsigned integer of n bits
--   q<n>      n bits, each read as a boolean (q alone is one)
--   A<n>  A*  n bytes, or the rest of the data, as they are
--   S<n>      a string of n bytes, read up to its first zero byte
--   z         a string that ends at a zero byte
--
-- Bits are read from the lowest bit of each byte up, as the packets library's field offsets count them, and an item
-- that isn't a bit field starts at the next whole byte. data:unpack(format, position) reads from the 1-based byte
-- position and returns the values alone. A format this doesn't know is an error, so a test that needs one says so.
-------------------------------------------------------------------------------------------------------------------

local floor, huge = math.floor, math.huge

local function format_items(format)
    local items = {}
    local position = 1
    while position <= #format do
        local code = format:sub(position, position)
        local count = format:match('^%d+', position + 1) or format:match('^%*', position + 1)
        position = position + 1 + (count and #count or 0)
        if code:match('%s') then
        elseif code:match('[<>CcBHhIifbqASz]') then
            items[#items + 1] = {code = code, count = count == '*' and '*' or tonumber(count)}
        else
            error(('tests/support/pack.lua does not know the format %q (in %q)'):format(code, format), 3)
        end
    end
    return items
end

local function read_bits(bytes, cursor, count)
    local value, scale = 0, 1
    for bit_index = cursor, cursor + count - 1 do
        local byte = bytes:byte(floor(bit_index / 8) + 1) or 0
        if floor(byte / 2 ^ (bit_index % 8)) % 2 == 1 then
            value = value + scale
        end
        scale = scale * 2
    end
    return value
end

local function read_integer(bytes, cursor, size, big_endian)
    local value = 0
    for i = 0, size - 1 do
        local byte = bytes:byte(cursor / 8 + i + 1) or 0
        value = value + byte * 256 ^ (big_endian and size - 1 - i or i)
    end
    return value
end

local function signed(value, bits)
    if value >= 2 ^ (bits - 1) then
        return value - 2 ^ bits
    end
    return value
end

-- A 32-bit IEEE 754 float, from its bits and to them.
local function to_float(word)
    local sign = word >= 2 ^ 31 and -1 or 1
    local exponent = floor(word / 2 ^ 23) % 256
    local fraction = word % 2 ^ 23
    if exponent == 255 then
        return fraction == 0 and sign * huge or 0 / 0
    elseif exponent == 0 then
        return sign * fraction * 2 ^ -149
    end
    return sign * (1 + fraction / 2 ^ 23) * 2 ^ (exponent - 127)
end

local function from_float(value)
    if value ~= value then
        return 0x7FC00000
    end
    local sign = 0
    if value < 0 or (value == 0 and 1 / value < 0) then
        sign, value = 2 ^ 31, -value
    end
    if value == 0 then
        return sign
    elseif value == huge then
        return sign + 0x7F800000
    end
    local mantissa, exponent = math.frexp(value)
    exponent = exponent + 126
    local fraction
    if exponent <= 0 then
        fraction = floor(mantissa * 2 ^ (23 + exponent) + 0.5)
        exponent = 0
    else
        fraction = floor((mantissa * 2 - 1) * 2 ^ 23 + 0.5)
        if fraction == 2 ^ 23 then
            fraction, exponent = 0, exponent + 1
        end
    end
    if exponent >= 255 then
        return sign + 0x7F800000
    end
    return sign + exponent * 2 ^ 23 + fraction
end

local function byte_aligned(cursor)
    return 8 * math.ceil(cursor / 8)
end

local integer_sizes = {C = 1, c = 1, B = 1, H = 2, h = 2, I = 4, i = 4}

function string.unpack(data, format, position)
    local cursor = 8 * ((position or 1) - 1)
    local big_endian = false
    local values = {}
    for _, item in ipairs(format_items(format)) do
        local code, count = item.code, item.count
        if code == '<' or code == '>' then
            big_endian = code == '>'
        elseif code == 'b' then
            values[#values + 1] = read_bits(data, cursor, count or 1)
            cursor = cursor + (count or 1)
        elseif code == 'q' then
            for _ = 1, count or 1 do
                values[#values + 1] = read_bits(data, cursor, 1) == 1
                cursor = cursor + 1
            end
        else
            cursor = byte_aligned(cursor)
            local start = cursor / 8 + 1
            if integer_sizes[code] then
                local size = integer_sizes[code]
                local value = read_integer(data, cursor, size, big_endian)
                if code == 'B' then
                    value = value ~= 0
                elseif code == 'c' or code == 'h' or code == 'i' then
                    value = signed(value, 8 * size)
                end
                values[#values + 1] = value
                cursor = cursor + 8 * size
            elseif code == 'f' then
                values[#values + 1] = to_float(read_integer(data, cursor, 4, big_endian))
                cursor = cursor + 32
            elseif code == 'A' then
                local length = count == '*' and #data - start + 1 or count or 1
                values[#values + 1] = data:sub(start, start + length - 1)
                cursor = cursor + 8 * length
            elseif code == 'S' then
                local length = count or 1
                values[#values + 1] = (data:sub(start, start + length - 1):match('^[^%z]*'))
                cursor = cursor + 8 * length
            elseif code == 'z' then
                local finish = data:find('\0', start, true) or #data + 1
                values[#values + 1] = data:sub(start, finish - 1)
                cursor = 8 * finish
            end
        end
    end
    return unpack(values)
end

-- The bytes of the packed data, as numbers, with the bits written so far.
local function writer()
    local bytes, cursor = {}, 0
    local self = {}

    function self.bits(value, count)
        for i = 0, count - 1 do
            local index = floor((cursor + i) / 8) + 1
            bytes[index] = bytes[index] or 0
            if floor(value / 2 ^ i) % 2 == 1 then
                bytes[index] = bytes[index] + 2 ^ ((cursor + i) % 8)
            end
        end
        cursor = cursor + count
    end

    function self.align()
        cursor = byte_aligned(cursor)
    end

    function self.integer(value, size, big_endian)
        value = floor(value) % 256 ^ size
        for i = 0, size - 1 do
            local shift = big_endian and size - 1 - i or i
            bytes[cursor / 8 + 1] = floor(value / 256 ^ shift) % 256
            cursor = cursor + 8
        end
    end

    function self.raw(text, length)
        for i = 1, length do
            bytes[cursor / 8 + 1] = text:byte(i) or 0
            cursor = cursor + 8
        end
    end

    function self.result()
        local chars = {}
        for i = 1, math.ceil(cursor / 8) do
            chars[i] = string.char(bytes[i] or 0)
        end
        return table.concat(chars)
    end

    return self
end

function string.pack(format, ...)
    local out = writer()
    local big_endian = false
    local values = {...}
    local next_value = 1
    local function take()
        local value = values[next_value]
        next_value = next_value + 1
        return value
    end
    for _, item in ipairs(format_items(format)) do
        local code, count = item.code, item.count
        if code == '<' or code == '>' then
            big_endian = code == '>'
        elseif code == 'b' then
            out.bits(take() or 0, count or 1)
        elseif code == 'q' then
            for _ = 1, count or 1 do
                out.bits(take() and 1 or 0, 1)
            end
        else
            out.align()
            if integer_sizes[code] then
                local value = take()
                if code == 'B' then
                    value = value and 1 or 0
                end
                out.integer(value or 0, integer_sizes[code], big_endian)
            elseif code == 'f' then
                out.integer(from_float(take() or 0), 4, big_endian)
            elseif code == 'A' or code == 'S' then
                local text = take() or ''
                out.raw(text, count == '*' and #text or count or 1)
            elseif code == 'z' then
                local text = take() or ''
                out.raw(text .. '\0', #text + 1)
            end
        end
    end
    return out.result()
end

return true
