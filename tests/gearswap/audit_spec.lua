local lfs = require('lfs')
local plain = require('plain')

local function boot()
    return plain.boot('Testy_WHM.lua')
end

local function path(gs)
    return gs.env.windower.addon_path .. 'data/audit/Testy.jsonl'
end

local function remove_record(gs)
    os.remove(path(gs))
end

-- The lines of the character's record file, each with its date made the same, or none when there is no file.
local function records(gs)
    local file = io.open(path(gs), 'rb')
    if not file then
        return {}
    end
    local lines = {}
    for line in file:lines() do
        lines[#lines + 1] = line:gsub('"date":"[^"]*"', '"date":"DATE"')
    end
    file:close()
    return lines
end

local function stats(gs, fields)
    local values = {['Maximum HP'] = 1700, ['Maximum MP'] = 1100, ['Main Job'] = 3, ['Main Job Level'] = 99, ['Sub Job'] = 5,
        ['Base STR'] = 40, ['Added STR'] = 12, ['Attack'] = 812, ['Defense'] = 1103, ['Fire Resistance'] = 5,
        ['Ice Resistance'] = 6, ['Master Level'] = 20}
    for label, value in pairs(fields or {}) do
        values[label] = value
    end
    gs:send(0x061, values)
end

-- The line /checkparam <me> answers with: message 712 to 715 from the player to themselves.
local function checkparam(gs, message, first, second, fields)
    gs:run(function()
        local values = {message_id = message, actor_id = gs.game.player.id, target_id = gs.game.player.id,
            param_1 = first, param_2 = second}
        for key, value in pairs(fields or {}) do
            values[key] = value
        end
        gs.game:send_action_message(values)
        gs.game:settle()
    end)
end

local function typed_checkparam(gs)
    for _, text in ipairs(gs.game.typed) do
        if text == '/checkparam <me>' then
            return true
        end
    end
    return false
end

local full_record = '{"args":["set","sets.precast.FastCast"],"buffs":[],"char_stats":{"attack":812,"defense":1103,'
    .. '"max_hp":1700,"max_mp":1100,"resistances":{"dark":0,"earth":0,"fire":5,"ice":6,"light":0,"lightning":0,'
    .. '"water":0,"wind":0},"stats":{"agi":0,"chr":0,"dex":0,"int":0,"mnd":0,"str":52,"vit":0},'
    .. '"stats_from_gear_and_buffs":{"agi":0,"chr":0,"dex":0,"int":0,"mnd":0,"str":12,"vit":0}},"char_stats_fresh":true,'
    .. '"character":"Testy","checkparam":{"evasion_defense":{"defense":900,"evasion":400},"primary":{"accuracy":250,'
    .. '"attack":300}},"date":"DATE","gear":{"ammo":"empty","back":"empty","body":"empty","feet":"empty","hands":"empty",'
    .. '"head":"Bunzi\'s Hat","left_ear":"empty","left_ring":"Kishar Ring","legs":"empty","main":"empty",'
    .. '"neck":"Loricate Torque +1","range":"empty","right_ear":"empty","right_ring":"empty","sub":"empty",'
    .. '"waist":"empty"},"job":{"main":"WHM","main_level":99,"master_level":20,"sub":"RDM","sub_level":49}}'

describe('gs audit', function()
    it('runs the test it is given, and says what the test says', function()
        local gs = boot()
        gs:console('gs audit set sets.precast.FastCast')
        assert.same({'GearSwap: Test: naked, then sets.precast.FastCast',
            'GearSwap: Test: user file off for 30 seconds while the test gear is on.'}, gs:chat())
        assert.same({head = "Bunzi's Hat", neck = 'Loricate Torque +1', left_ring = 'Kishar Ring'}, gs:worn())
    end)

    it('asks for /checkparam once the stats packets have stopped for a second', function()
        local gs = boot()
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:advance(0.9)
        assert.is_false(typed_checkparam(gs))
        gs:advance(0.2)
        assert.is_true(typed_checkparam(gs))
    end)

    it('waits for another stats packet while they keep coming', function()
        local gs = boot()
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:advance(0.8)
        stats(gs)
        gs:advance(0.8)
        assert.is_false(typed_checkparam(gs))
        gs:advance(0.3)
        assert.is_true(typed_checkparam(gs))
    end)

    it('asks anyway after 10 seconds when no stats packet comes, as when the gear was already on', function()
        local gs = boot()
        gs:console('gs audit set sets.precast.FastCast')
        gs:advance(9.9)
        assert.is_false(typed_checkparam(gs))
        gs:advance(0.2)
        assert.is_true(typed_checkparam(gs))
    end)

    it('writes the record once the /checkparam lines have stopped for a second and a half', function()
        local gs = boot()
        remove_record(gs)
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:advance(1.1)
        checkparam(gs, 712, 250, 300)
        checkparam(gs, 715, 400, 900)
        gs:advance(1.4)
        assert.same({}, records(gs))
        gs:advance(0.2)
        assert.same({full_record}, records(gs))
        remove_record(gs)
    end)

    it('says it appended the record', function()
        local gs = boot()
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:chat_lines()
        gs:advance(1.1)
        checkparam(gs, 712, 250, 300)
        gs:advance(1.6)
        assert.same({'GearSwap: Audit: appended to data/audit/Testy.jsonl.'}, gs:chat())
        remove_record(gs)
    end)

    it('waits for more /checkparam lines while they keep coming', function()
        local gs = boot()
        remove_record(gs)
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:advance(1.1)
        checkparam(gs, 712, 250, 300)
        gs:advance(1.0)
        checkparam(gs, 713, 200, 220)
        gs:advance(1.0)
        assert.same({}, records(gs))
        gs:advance(0.6)
        assert.equal(1, #records(gs))
        assert.is_truthy(records(gs)[1]:find('"auxiliary":{"accuracy":200,"attack":220}', 1, true))
        remove_record(gs)
    end)

    it('takes the lines for hand, off hand, ranged and evasion', function()
        local gs = boot()
        remove_record(gs)
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:advance(1.1)
        checkparam(gs, 712, 1, 2)
        checkparam(gs, 713, 3, 4)
        checkparam(gs, 714, 5, 6)
        checkparam(gs, 715, 7, 8)
        gs:advance(1.6)
        local record = records(gs)[1]
        for _, expected in ipairs({'"primary":{"accuracy":1,"attack":2}', '"auxiliary":{"accuracy":3,"attack":4}',
            '"ranged":{"accuracy":5,"attack":6}', '"evasion_defense":{"defense":8,"evasion":7}'}) do
            assert.is_truthy(record:find(expected, 1, true), expected)
        end
        remove_record(gs)
    end)

    it('leaves out a /checkparam line that is for someone else', function()
        local gs = boot()
        remove_record(gs)
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:advance(1.1)
        checkparam(gs, 712, 250, 300, {actor_id = 0x3333, target_id = 0x3333})
        gs:advance(1.6)
        assert.is_truthy(records(gs)[1]:find('"checkparam":{}', 1, true))
        remove_record(gs)
    end)

    it('takes a /checkparam line that has the player as its actor or its target alone', function()
        local gs = boot()
        remove_record(gs)
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:advance(1.1)
        checkparam(gs, 712, 11, 12, {actor_id = 0x3333})
        checkparam(gs, 713, 13, 14, {target_id = 0x3333})
        gs:advance(1.6)
        local record = records(gs)[1]
        assert.is_truthy(record:find('"primary":{"accuracy":11,"attack":12}', 1, true))
        assert.is_truthy(record:find('"auxiliary":{"accuracy":13,"attack":14}', 1, true))
        remove_record(gs)
    end)

    it('leaves out a message that is no /checkparam line', function()
        local gs = boot()
        remove_record(gs)
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:advance(1.1)
        checkparam(gs, 100, 250, 300)
        gs:advance(1.6)
        assert.is_truthy(records(gs)[1]:find('"checkparam":{}', 1, true))
        remove_record(gs)
    end)

    it('says so when no /checkparam line comes back, and the record has the stats only', function()
        local gs = boot()
        remove_record(gs)
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:chat_lines()
        gs:advance(2.7)
        assert.same({'GearSwap: Audit: no /checkparam lines came back; the record has the char stats only.',
            'GearSwap: Audit: appended to data/audit/Testy.jsonl.'}, gs:chat())
        local record = records(gs)[1]
        assert.is_truthy(record:find('"checkparam":{}', 1, true))
        assert.is_truthy(record:find('"char_stats":{"attack":812,', 1, true))
        remove_record(gs)
    end)

    it('says so when no stats packet has ever come, and the record has /checkparam only', function()
        local gs = boot()
        remove_record(gs)
        gs:console('gs audit set sets.precast.FastCast')
        gs:chat_lines()
        gs:advance(10.1)
        checkparam(gs, 712, 250, 300)
        gs:advance(1.6)
        assert.same({'GearSwap: Audit: no char stats packet has been seen; the record has /checkparam only.',
            'GearSwap: Audit: appended to data/audit/Testy.jsonl.'}, gs:chat())
        local record = records(gs)[1]
        assert.is_nil(record:find('"char_stats":', 1, true))
        assert.is_truthy(record:find('"char_stats_fresh":false', 1, true))
        remove_record(gs)
    end)

    it('says so when only an older stats packet was seen, and takes it, marked as not fresh', function()
        local gs = boot()
        remove_record(gs)
        stats(gs)
        gs:console('gs audit set sets.precast.FastCast')
        gs:chat_lines()
        gs:advance(10.1)
        checkparam(gs, 712, 250, 300)
        gs:advance(1.6)
        assert.same({'GearSwap: Audit: no char stats update came, so char_stats is the last one seen (fine if the gear was already on).',
            'GearSwap: Audit: appended to data/audit/Testy.jsonl.'}, gs:chat())
        local record = records(gs)[1]
        assert.is_truthy(record:find('"char_stats_fresh":false', 1, true))
        assert.is_truthy(record:find('"attack":812', 1, true))
        remove_record(gs)
    end)

    it('waits for a stats packet that comes after /checkparam, and takes it as the latest', function()
        local gs = boot()
        remove_record(gs)
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:advance(1.1)
        checkparam(gs, 712, 250, 300)
        gs:advance(1.0)
        stats(gs, {['Attack'] = 999})
        gs:advance(1.4)
        assert.same({}, records(gs))
        gs:advance(0.2)
        assert.is_truthy(records(gs)[1]:find('"attack":999', 1, true))
        remove_record(gs)
    end)

    it('lists the buffs the player has by name', function()
        local gs = boot()
        remove_record(gs)
        gs:gain_buff('Haste')
        gs:gain_buff('Protect')
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:advance(2.7)
        assert.is_truthy(records(gs)[1]:find('"buffs":["Haste","Protect"]', 1, true))
        remove_record(gs)
    end)

    it('adds a line to the character\'s file for each audit', function()
        local gs = boot()
        remove_record(gs)
        for _ = 1, 2 do
            gs:console('gs audit set sets.precast.FastCast')
            stats(gs)
            gs:advance(2.7)
        end
        assert.equal(2, #records(gs))
        remove_record(gs)
    end)

    it('makes the folder for the files when there is none', function()
        local gs = boot()
        remove_record(gs)
        lfs.rmdir(gs.env.windower.addon_path .. 'data/audit')
        assert.is_nil(lfs.attributes(gs.env.windower.addon_path .. 'data/audit'))
        gs:console('gs audit set sets.precast.FastCast')
        stats(gs)
        gs:advance(2.7)
        assert.equal(1, #records(gs))
        remove_record(gs)
    end)

    it('runs the test with an action: its args are in the record', function()
        local gs = plain.boot('Testy_Actions.lua')
        remove_record(gs)
        gs:console('gs audit precast Cure III')
        stats(gs)
        gs:advance(2.7)
        assert.is_truthy(records(gs)[1]:find('"args":["precast","Cure","III"]', 1, true))
        remove_record(gs)
    end)

    it('says how to use gs test when it is given nothing, and audits nothing', function()
        local gs = boot()
        remove_record(gs)
        gs:console('gs audit')
        assert.same({'GearSwap: Usage: //gs test set <set>  or  //gs test [precast|midcast] <action>'}, gs:chat())
        gs:advance(20)
        assert.is_false(typed_checkparam(gs))
        assert.same({}, records(gs))
    end)

    it('audits nothing when the test finds no such set', function()
        local gs = boot()
        gs:console('gs audit set sets.nothing')
        gs:advance(20)
        assert.is_false(typed_checkparam(gs))
    end)

    describe('is dropped by', function()
        local function dropped(act)
            local gs = boot()
            remove_record(gs)
            gs:console('gs audit set sets.precast.FastCast')
            stats(gs)
            act(gs)
            gs:advance(1.1)
            checkparam(gs, 712, 250, 300)
            gs:advance(3)
            assert.same({}, records(gs))
        end

        it('another gs test', function()
            dropped(function(gs)
                gs:console('gs test set sets.midcast.Cure')
            end)
        end)

        it('a bare gs enable', function()
            dropped(function(gs)
                gs:console('gs enable')
            end)
        end)

        it('a bare gs disable', function()
            dropped(function(gs)
                gs:console('gs disable')
            end)
        end)

        it('a user file load', function()
            dropped(function(gs)
                gs:console('gs load Testy_Events')
            end)
        end)

        it('gs naked', function()
            dropped(function(gs)
                gs:console('gs naked')
            end)
        end)

        it('another gs audit, which audits in its place', function()
            local gs = boot()
            remove_record(gs)
            gs:console('gs audit set sets.precast.FastCast')
            gs:console('gs audit set sets.midcast.Cure')
            stats(gs)
            gs:advance(1.1)
            checkparam(gs, 712, 1, 2)
            gs:advance(1.6)
            assert.equal(1, #records(gs))
            assert.is_truthy(records(gs)[1]:find('"args":["set","sets.midcast.Cure"]', 1, true))
            assert.is_truthy(records(gs)[1]:find('"primary":{"accuracy":1,"attack":2}', 1, true))
            remove_record(gs)
        end)
    end)
end)
