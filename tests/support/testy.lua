-------------------------------------------------------------------------------------------------------------------
-- Testy, the made-up character the tests play: the gear each job's fixture user file wears, the boot options that
-- give it to them, and the boot the red mage's tests share.
-------------------------------------------------------------------------------------------------------------------

local testy = {}

-- The game's name for each slot a set may name another way.
testy.game_slots = {ear1 = 'left_ear', ear2 = 'right_ear', ring1 = 'left_ring', ring2 = 'right_ring', ranged = 'range',
    lear = 'left_ear', rear = 'right_ear', lring = 'left_ring', rring = 'right_ring'}

-- What the game shows worn once the set is on over nothing, with the changes laid over it.
function testy.worn_by(set, changes)
    local worn = {}
    for slot, item in pairs(set) do
        worn[testy.game_slots[slot] or slot] = item
    end
    for slot, item in pairs(changes or {}) do
        worn[testy.game_slots[slot] or slot] = item ~= 'empty' and item or nil
    end
    return worn
end

-- The idle set of tests/fixture/data/Testy/Testy_WHM.lua.
testy.whm_idle = {main = 'Daybreak', sub = 'Ammurapi Shield', ammo = 'Staunch Tathlum +1', head = 'Nyame Helm',
    body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard', feet = 'Nyame Sollerets',
    neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring',
    ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1', back = "Alaunus's Cape"}

-- Testy as a white mage, on the plain user file Testy_WHM.lua, with every piece it names and its idle set on.
function testy.whm(overrides)
    local options = {
        main_job = 'WHM', sub_job = 'RDM', expect_file = 'Testy_WHM.lua',
        items = {
            {name = 'Daybreak'}, {name = "Bunzi's Rod"}, {name = 'Ammurapi Shield'}, {name = 'Staunch Tathlum +1'},
            {name = 'Nyame Helm'}, {name = "Bunzi's Hat"}, {name = 'Kaykaus Mitra +1'}, {name = 'Nyame Mail'},
            {name = 'Nyame Gauntlets'}, {name = 'Nyame Flanchard'}, {name = 'Nyame Sollerets'},
            {name = 'Loricate Torque +1'}, {name = 'Plat. Mog. Belt'}, {name = 'Etiolation Earring'},
            {name = 'Loquac. Earring'}, {name = 'Defending Ring'}, {name = 'Stikini Ring +1', bag = 'wardrobe'},
            {name = 'Kishar Ring', bag = 'wardrobe2'}, {name = "Alaunus's Cape"},
        },
        wearing = testy.worn_by(testy.whm_idle),
    }
    for k, v in pairs(overrides or {}) do
        options[k] = v
    end
    return options
end

-- The idle set of tests/fixture/data/Testy/Testy_Rdm_Gear.lua.
testy.rdm_idle = {main = 'Daybreak', sub = 'Ammurapi Shield', ammo = 'Staunch Tathlum +1', head = 'Nyame Helm',
    body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard', feet = 'Nyame Sollerets',
    neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring',
    ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1', back = "Sucellos's Cape"}

-- Testy as a red mage, with every piece Testy_Rdm_Gear.lua names and nothing on.
function testy.rdm(overrides)
    local options = {
        main_job = 'RDM', sub_job = 'WHM',
        items = {
            {name = 'Naegling'}, {name = 'Crocea Mors'}, {name = 'Daybreak'}, {name = "Bunzi's Rod"},
            {name = 'Ammurapi Shield'}, {name = 'Staunch Tathlum +1'}, {name = 'Nyame Helm'}, {name = "Bunzi's Hat"},
            {name = 'Malignance Chapeau'}, {name = 'Kaykaus Mitra +1'}, {name = 'Nyame Mail'},
            {name = 'Malignance Tabard'}, {name = 'Atrophy Tabard +3'}, {name = 'Lethargy Sayon +3'},
            {name = 'Nyame Gauntlets'}, {name = 'Nyame Flanchard'}, {name = 'Nyame Sollerets'},
            {name = 'Loricate Torque +1'}, {name = 'Plat. Mog. Belt'}, {name = 'Etiolation Earring'},
            {name = 'Loquac. Earring'}, {name = 'Defending Ring', bag = 'wardrobe'},
            {name = 'Stikini Ring +1', bag = 'wardrobe'}, {name = 'Kishar Ring', bag = 'wardrobe2'},
            {name = "Sucellos's Cape"},
        },
    }
    for k, v in pairs(overrides or {}) do
        options[k] = v
    end
    return options
end

-- Testy as a red mage with the idle set on, and what was sent until then taken as read.
function testy.boot_rdm()
    local gs = require('harness').boot(testy.rdm())
    gs:console('gs c update')
    gs:traffic()
    return gs
end

return testy
