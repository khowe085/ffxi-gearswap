-------------------------------------------------------------------------------------------------------------------
-- Windower's Lua lets a method be called on a literal ('%d items':format(n), "I":pack(id), 0:char(), true:fn()) or
-- on a table constructor, and a function expression be called where it stands (function() ... end()), none of which
-- a plain Lua 5.1 will parse. load() reads a file as Windower's Lua does by first putting each such expression in
-- parentheses; nothing else in the source changes, line numbers included. Strings and comments are read as Lua
-- reads them, so what is inside one is left alone.
-------------------------------------------------------------------------------------------------------------------

local dialect = {}

local keywords = {}
for word in ('and break do else elseif end false for function if in local nil not or repeat return then true until while'):gmatch('%a+') do
    keywords[word] = true
end

-- The position after the long bracket ([[...]], [==[...]==]) that opens at start, or nil when none opens there.
local function long_bracket_end(source, start)
    local equals = source:match('^%[(=*)%[', start)
    if not equals then
        return nil
    end
    local _, finish = source:find(']' .. equals .. ']', start + #equals + 2, true)
    return (finish or #source) + 1
end

-- The position after the quoted string that opens at start.
local function quoted_end(source, start)
    local quote = source:sub(start, start)
    local position = start + 1
    while true do
        local found = source:find('[\\' .. quote .. '\n]', position)
        if not found then
            return #source + 1
        elseif source:sub(found, found) == '\\' then
            position = found + 2
        else
            return found + 1
        end
    end
end

-- Splits the source into tokens: the kind of each (space, comment, string, number, name, keyword, op) and where it
-- starts and ends, every character of the source in exactly one.
local function tokenize(source)
    local kinds, starts, finishes = {}, {}, {}
    local position, length = 1, #source
    while position <= length do
        local byte = source:byte(position)
        local char = string.char(byte)
        local finish, kind
        if char:find('%s') then
            finish, kind = (source:find('%S', position) or length + 1), 'space'
        elseif char == '-' and source:sub(position + 1, position + 1) == '-' then
            finish = long_bracket_end(source, position + 2) or (source:find('\n', position, true) or length + 1)
            kind = 'comment'
        elseif char == '"' or char == "'" then
            finish, kind = quoted_end(source, position), 'string'
        elseif char == '[' and long_bracket_end(source, position) then
            finish, kind = long_bracket_end(source, position), 'string'
        elseif char:find('[%a_]') then
            local _, last = source:find('^[%w_]+', position)
            finish = last + 1
            kind = keywords[source:sub(position, last)] and 'keyword' or 'name'
        elseif char:find('%d') or (char == '.' and source:find('^%.%d', position)) then
            local _, last = source:find('^0[xX]%x*', position)
            if not last then
                _, last = source:find('^%d*%.?%d*', position)
                local _, exponent = source:find('^[eE][%+%-]?%d+', last + 1)
                last = exponent or last
            end
            finish, kind = last + 1, 'number'
        else
            local three, two = source:sub(position, position + 2), source:sub(position, position + 1)
            if three == '...' then
                finish = position + 3
            elseif two == '..' or two == '==' or two == '~=' or two == '<=' or two == '>=' then
                finish = position + 2
            else
                finish = position + 1
            end
            kind = 'op'
        end
        local n = #kinds + 1
        kinds[n], starts[n], finishes[n] = kind, position, finish - 1
        position = finish
    end
    return kinds, starts, finishes
end

function dialect.translate(source)
    local kinds, starts, finishes = tokenize(source)
    local count = #kinds
    local function text(i)
        return source:sub(starts[i], finishes[i])
    end

    -- Where each table constructor and each function expression ends.
    local closing = {}
    local braces, blocks = {}, {}
    for i = 1, count do
        local kind, word = kinds[i], (kinds[i] == 'op' or kinds[i] == 'keyword') and text(i)
        if word == '{' then
            braces[#braces + 1] = i
        elseif word == '}' then
            local open = table.remove(braces)
            if open then
                closing[open] = i
            end
        elseif word == 'function' or word == 'if' or word == 'do' or word == 'repeat' then
            blocks[#blocks + 1] = i
        elseif word == 'end' or word == 'until' then
            local open = table.remove(blocks)
            if open and text(open) == 'function' then
                closing[open] = i
            end
        end
    end

    -- The next token that isn't space or a comment, and whether a line ended on the way.
    local function next_token(i)
        local newline = false
        for j = i + 1, count do
            if kinds[j] == 'space' or kinds[j] == 'comment' then
                newline = newline or text(j):find('\n') ~= nil
            else
                return j, newline
            end
        end
    end

    -- Whether the string or table constructor at i is a call's argument, as in T{1, 2} or f'x', which plain Lua
    -- already lets a method be called on.
    local function argument(i)
        for j = i - 1, 1, -1 do
            if kinds[j] ~= 'space' and kinds[j] ~= 'comment' then
                local word = text(j)
                return kinds[j] == 'name' or word == ')' or word == ']' or word == '}'
            end
        end
        return false
    end

    local opens, closes = {}, {}
    for i = 1, count do
        local kind, last = kinds[i], nil
        local word = text(i)
        if kind == 'number' or (kind == 'keyword' and (word == 'true' or word == 'false' or word == 'nil')) then
            last = i
        elseif kind == 'string' and not argument(i) then
            last = i
        elseif kind == 'op' and word == '{' and not argument(i) then
            last = closing[i]
        elseif kind == 'keyword' and word == 'function' then
            local after = next_token(i)
            if after and text(after) == '(' then
                last = closing[i]
            end
        end
        if last then
            local after, newline = next_token(last)
            local follower = after and text(after)
            if follower == ':' or (word == 'function' and follower == '(' and not newline) then
                opens[i] = (opens[i] or 0) + 1
                closes[last] = (closes[last] or 0) + 1
            end
        end
    end

    local pieces = {}
    for i = 1, count do
        if opens[i] then
            pieces[#pieces + 1] = ('('):rep(opens[i])
        end
        pieces[#pieces + 1] = text(i)
        if closes[i] then
            pieces[#pieces + 1] = (')'):rep(closes[i])
        end
    end
    return table.concat(pieces)
end

local cache = {}

-- Compiles a file of Windower's Lua, as loadfile does. A file's text is translated once a run.
function dialect.load(path)
    local file, problem = io.open(path, 'rb')
    if not file then
        return nil, problem
    end
    local source = file:read('*a')
    file:close()
    local translated = cache[source]
    if not translated then
        translated = dialect.translate((source:gsub('^#[^\n]*', '')))
        cache[source] = translated
    end
    return loadstring(translated, '@' .. path)
end

return dialect
