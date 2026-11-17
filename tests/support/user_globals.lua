-------------------------------------------------------------------------------------------------------------------
-- What a test of a mechanism in User-Globals.lua gives it in place of the user's own lists, since the user changes
-- them as they like and no test may rest on them: the buffs Auto WS Buff takes before a weapon skill, and the weapon
-- skills Auto WS takes in place of its choice when HP or MP is low. The file keeps the second, and what it works out of
-- the first as it loads, in locals no test reaches by name, so these find them in the functions that use them.
-------------------------------------------------------------------------------------------------------------------

local user_globals = {}

-- The buffs the tests of Auto WS Buff have it take before a weapon skill, in order, as User-Globals.lua's ws_buffs
-- lists them: the ability's name, the job and level it comes with, its recast id, and the buff that holds it back.
user_globals.ws_buffs = {
    {name = 'Last Resort', job = 'DRK', level = 15, recast = 87},
    {name = 'Berserk', job = 'WAR', level = 15, recast = 1, unless = 'Defender'},
    {name = 'Warcry', job = 'WAR', level = 35, recast = 2},
    {name = 'Aggressor', job = 'WAR', level = 45, recast = 4},
}

-- The weapon skills the tests of Auto WS have it take in place of its choice, in order, as User-Globals.lua's
-- autows_restore lists them: the weapon skill's id and name, and the HP or MP percent under which it comes first.
user_globals.restore_weaponskills = {
    {id = 47, name = 'Sanguine Blade', hpp = 41},
    {id = 105, name = 'Catastrophe', hpp = 41},
    {id = 109, name = 'Entropy', mpp = 31},
    {id = 171, name = 'Mystic Boon', mpp = 31},
}

-- The value of the local that the function, or a function it holds, keeps by that name.
local function local_of(fn, name, seen)
    seen = seen or {}
    seen[fn] = true
    local index = 1
    while true do
        local held_name, held = debug.getupvalue(fn, index)
        if not held_name then
            return nil
        end
        if held_name == name then
            return held
        end
        if type(held) == 'function' and not seen[held] then
            local found = local_of(held, name, seen)
            if found ~= nil then
                return found
            end
        end
        index = index + 1
    end
end

local function clear(t)
    for key in pairs(t) do
        t[key] = nil
    end
end

-- Turns Auto WS Buff on with these buffs, in order, in place of the user's: for the weapon skill's check, and for the
-- abilities that the tick of a job file's own buffing leaves to Auto WS Buff, which User-Globals.lua takes from the
-- list as it loads. Given the user environment, so that a boot's user function can call it.
function user_globals.give_ws_buffs(user, buffs)
    user.state.AutoWSBuff:set(true)
    user.ws_buffs = buffs
    if user.job_check_buff then
        local left_to_ws_buff = assert(local_of(user.job_check_buff, 'ws_buff_recast_ids'),
            'User-Globals.lua keeps no ws_buff_recast_ids, the abilities it holds back from the job file\'s tick')
        clear(left_to_ws_buff)
        for _, buff in ipairs(buffs) do
            left_to_ws_buff[buff.recast] = true
        end
    end
end

-- Has Auto WS take these weapon skills in place of its choice when HP or MP is low, in place of the user's: the list
-- that the handler of the game's TP change event picks from. Given the session.
function user_globals.give_restore_weaponskills(gs, weaponskills)
    for _, entry in ipairs(gs.game.handlers['tp change'] or {}) do
        local restore = local_of(entry.handler, 'autows_restore')
        if restore then
            clear(restore)
            for i, weaponskill in ipairs(weaponskills) do
                restore[i] = weaponskill
            end
            return
        end
    end
    error('User-Globals.lua keeps no autows_restore, the weapon skills Auto WS puts first when HP or MP is low')
end

return user_globals
