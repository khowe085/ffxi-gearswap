-------------------------------------------------------------------------------------------------------------------
-- Jobby, the made-up character the tests of the job files in data/ play (tests/jobs): the boot options for each job,
-- over the fixture gear file tests/fixture/data/Jobby/Jobby_<Job>_Gear.lua that job loads, and the sets as they are
-- worn; what Jobby is told and types but the lines User-Globals.lua gives five seconds after his file first loads; what
-- is worn once a weapon skill he types has gone out; and what a test gives him besides: the Dual Wield trait, and
-- another player as his target.
-------------------------------------------------------------------------------------------------------------------

local assert = require('luassert')
local harness = require('harness')
local testy = require('testy')

local jobby = {}

-- What every Jobby gear file's idle set wears, as the game shows it worn.
jobby.idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', left_ear = 'Etiolation Earring',
    right_ear = 'Loquac. Earring', left_ring = 'Defending Ring', right_ring = 'Stikini Ring +1'}

-- What the idle set of the gear files of WAR, MNK, WHM, BLM, RDM, THF, PLD and DRK wears: every gear file's, with an
-- ammo and a back.
jobby.full_idle = testy.worn_by(jobby.idle, {ammo = 'Staunch Tathlum +1', back = 'Moonbeam Cape'})

-- What the game shows worn once the set is on and the changes are laid over it: a slot named in the set's own terms
-- (ring1) or the game's (left_ring), a piece or 'empty'.
jobby.worn_by = testy.worn_by

-- The weapon each job's boot puts in Jobby's hand, over the idle set, since the game lets him use only the weapon
-- skills of the weapons he holds: one of the type whose weapon skills the job's tests type, for each job whose tests
-- type one other than hand-to-hand's and whose gear file's idle set names no weapon (an idle set's weapon would take
-- its place at the first update). The jobs not named hold what their gear file's idle set does, or nothing, which is
-- hand-to-hand. A boot's wearing can name another, or 'empty'.
jobby.weapons = {BLM = {main = 'Gozuki Mezuki'}, BLU = {main = "Judge's Sword"}, COR = {main = 'Qutrub Knife'},
    DNC = {main = 'Qutrub Knife'}, DRK = {main = 'Apocalypse'}, PLD = {main = "Judge's Sword"},
    RDM = {main = "Judge's Sword"}, RUN = {main = 'Epeolatry'}, SCH = {main = "Terra's Staff"},
    THF = {main = 'Qutrub Knife'}, WAR = {main = 'Ragnarok'}}

-- The pieces of the idle sets, which every job can wear.
local idle_items = {'Nyame Helm', 'Nyame Mail', 'Nyame Gauntlets', 'Nyame Flanchard', 'Nyame Sollerets',
    'Loricate Torque +1', 'Plat. Mog. Belt', 'Etiolation Earring', 'Loquac. Earring', 'Defending Ring',
    'Stikini Ring +1', 'Staunch Tathlum +1', 'Moonbeam Cape'}

local slots = {main = true, sub = true, range = true, ammo = true, head = true, neck = true, left_ear = true,
    right_ear = true, body = true, hands = true, left_ring = true, right_ring = true, back = true, waist = true,
    legs = true, feet = true}

-- The sets laid one over another, as the pieces they hold by the game's slot names: only the slots, since a set a
-- gear file builds can hold the sets under it too.
function jobby.layer(...)
    local merged = {}
    for _, set in ipairs({...}) do
        for slot, item in pairs(set) do
            slot = testy.game_slots[slot] or slot
            if slots[slot] then
                merged[slot] = item
            end
        end
    end
    return merged
end

-- Boots Jobby as that job, with the pieces of the idle sets, the job's weapon and the items given in the inventory and
-- every gear file's idle set and the job's weapon on, and has Sel update the gear once, with nothing sent, typed, run
-- or said since. A weapon the idle set names and the boot doesn't put on is in hand by then, which takes the TP the
-- boot gave. options are a boot's (see harness.boot), with these in place of the harness's:
--   items     the names of the pieces Jobby has besides the idle sets', or {name =, bag =, count =} for one that
--             needs more; the job's weapon is added only when the items don't name it, so a test that holds it in
--             both hands names it twice
--   wearing   slot name to the name of an item, worn when GearSwap loads over the idle set and the weapon
--   sub_job   WHM unless given
function jobby.boot(job, options)
    local boot = {character = 'Jobby', main_job = job, sub_job = 'WHM', expect_file = job .. '.lua'}
    for key, value in pairs(options or {}) do
        boot[key] = value
    end
    boot.items = {}
    local had = {}
    local function add(item)
        item = type(item) == 'table' and item or {name = item}
        boot.items[#boot.items + 1] = item
        had[item.name] = true
    end
    for _, name in ipairs(idle_items) do
        add(name)
    end
    for _, item in ipairs((options or {}).items or {}) do
        add(item)
    end
    local weapons = jobby.weapons[job] or {}
    for _, name in pairs(weapons) do
        if not had[name] then
            add(name)
        end
    end
    boot.wearing = testy.worn_by(testy.worn_by(jobby.idle, weapons), (options or {}).wearing)
    local gs = harness.boot(boot)
    gs:console('gs c update')
    gs:forget()
    return gs
end

-- As boot, and past the seconds Sel waits after loading before its tick acts, with nothing sent since.
function jobby.boot_ticking(job, options)
    local gs = jobby.boot(job, options)
    gs:play(harness.sel_load_time + 1)
    gs:forget()
    return gs
end

-- What is worn once the weapon skill typed (a line such as '/ws "Savage Blade" <t>') has gone out. The test fails
-- when it didn't, or when another action went out since the actions were last read.
function jobby.weaponskill(gs, line)
    gs:type(line)
    assert.same({line:match('^/ws "(.-)"')}, gs:actions(), 'the weapon skill typed didn\'t go out')
    return gs:worn()
end

-- What Jobby has targeted is another player, Pal, standing in front of him, who isn't in the party. fields are over
-- Pal's (see Game:add_party_member). Returns Pal as the game holds him.
function jobby.target_a_player(gs, fields)
    local pal = {name = 'Pal', in_party = false}
    for key, value in pairs(fields or {}) do
        pal[key] = value
    end
    pal = gs.game:add_party_member(pal)
    gs.game:target(pal.index)
    return pal
end

-- What User-Globals.lua gives five seconds after Jobby's file first loads: the report of the gs validate it runs, when
-- Jobby has every piece the sets name, and the /lockstyle on it types, the first the game is given, since Sel's own
-- waits fifteen seconds after a load. A later load or sub job change gives them again, and those are kept.
local load_report = {'GearSwap: Checking for items in gear sets that are not in your inventory.',
    'GearSwap: Final count = 0'}
local load_lock = {'/lockstyle on'}

-- The lines just read of one of the game's lists, but the first entry in the whole list of each of the lines given.
-- text_of gives an entry's text as the lines read give it.
local function but_the_first(list, read, lines, text_of)
    local left = {}
    for _, line in ipairs(lines) do
        left[line] = true
    end
    local first = {}
    for i, entry in ipairs(list) do
        local text = text_of(entry)
        if left[text] then
            first[i] = true
            left[text] = nil
        end
    end
    local start = #list - #read
    local kept = {}
    for i, line in ipairs(read) do
        if not first[start + i] then
            kept[#kept + 1] = line
        end
    end
    return kept
end

local function chat_text(entry)
    return harness.chat_line(entry).text
end

local function as_is(line)
    return line
end

-- The lines put in the chat since it was last read, but that gs validate's report; only those the pattern finds, when
-- one is given. Many lines that turn an action down begin with Abort, but not all, so a test of a guard whose refusal
-- says something else matches that line.
function jobby.said(gs, pattern)
    local lines = {}
    for _, line in ipairs(but_the_first(gs.game.chat_log, gs:chat(), load_report, chat_text)) do
        if not pattern or line:find(pattern) then
            lines[#lines + 1] = line
        end
    end
    return lines
end

-- The lines typed since this was last asked that reached the game, but that /lockstyle on.
function jobby.typed(gs)
    return but_the_first(gs.game.typed, gs:typed(), load_lock, as_is)
end

-- Jobby has the Dual Wield trait from now on, as Sel finds out when it looks, with nothing sent since. Sel starts the
-- weapons over when it looks, as five seconds after a load (gs c weapons initialize), which in a Jobby gear file, with
-- no DualWeapons set, puts Weapons back at its first option, None.
function jobby.can_dual_wield(gs)
    gs.game:set_job_traits({'Dual Wield'})
    gs:run(function()
        gs.user.set_dual_wield()
        gs.game:settle()
    end)
    gs:traffic()
end

return jobby
