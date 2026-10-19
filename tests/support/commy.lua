-------------------------------------------------------------------------------------------------------------------
-- Commy, the made-up character the tests of Sel's commands, modes, status display, Treasure Hunter, spell maps and
-- event handling play: the gear each job's fixture gear file wears, the boot options that give it to them, and the
-- helpers those tests share.
-------------------------------------------------------------------------------------------------------------------

local testy = require('testy')

local commy = {}

commy.worn_by = testy.worn_by

-- Boot options for Commy on a job, holding the items named and wearing nothing, with the overrides laid over them.
-- extra_items, among the overrides, are items held besides the job's own ({name=, count=, bag=}).
local function options_for(job, items, overrides)
    local options = {items = {}}
    for k, v in pairs(job) do
        options[k] = v
    end
    for i, name in ipairs(items) do
        options.items[i] = {name = name}
    end
    for k, v in pairs(overrides or {}) do
        if k == 'extra_items' then
            for _, item in ipairs(v) do
                options.items[#options.items + 1] = item
            end
        else
            options[k] = v
        end
    end
    return options
end

-- Boots GearSwap with the options, puts the set Sel picks on, and starts the session with nothing sent or said.
local function boot(options, before_update)
    local gs = require('harness').boot(options)
    if before_update then
        before_update(gs)
    end
    gs:console('gs c update')
    gs:traffic()
    commy.chat(gs)
    return gs
end

-- The idle set of data/Commy/Commy_Rdm_Gear.lua.
commy.rdm_idle = {main = 'Daybreak', sub = 'Ammurapi Shield', ammo = 'Staunch Tathlum +1', head = 'Nyame Helm',
    body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard', feet = 'Nyame Sollerets',
    neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring',
    ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1', back = "Sucellos's Cape"}

local rdm_items = {
    'Naegling', 'Crocea Mors', 'Daybreak', "Bunzi's Rod", 'Ammurapi Shield', 'Staunch Tathlum +1', 'Nyame Helm',
    "Bunzi's Hat", 'Malignance Chapeau', 'Kaykaus Mitra +1', 'Volte Cap', 'Nyame Mail', 'Malignance Tabard',
    'Atrophy Tabard +3', 'Lethargy Sayon +3', 'Nyame Gauntlets', 'Kaykaus Cuffs', 'Chironic Gloves',
    'Telchine Gloves', "Bunzi's Gloves", 'Regal Cuffs', 'Amalric Gages', "Shrieker's Cuffs", 'Nyame Flanchard',
    'Telchine Braconi', 'Chironic Hose', 'Malignance Tights', 'Volte Brais', "Bunzi's Pants",
    'Lengo Pants', 'Psycloth Lappas', 'Merlinic Shalwar', 'Kaykaus Tights', 'Querkening Brais', 'Volte Hose',
    'Nyame Sollerets', 'Malignance Boots', 'Volte Boots', 'Loricate Torque +1', 'Sanctity Necklace',
    "Nicander's Necklace", 'Plat. Mog. Belt', 'Chaac Belt', "Orpheus's Sash", 'Etiolation Earring', 'Loquac. Earring',
    'Defending Ring', 'Stikini Ring +1', 'Kishar Ring', "Medada's Ring", "Sucellos's Cape",
}

-- Commy as a red mage with white mage as sub job, on the real data/RDM.lua with Commy_Rdm_Gear.lua, holding every
-- piece it names and wearing nothing.
function commy.rdm(overrides)
    return options_for({character = 'Commy', main_job = 'RDM', sub_job = 'WHM', expect_file = 'RDM.lua'}, rdm_items,
        overrides)
end

-- Commy as a red mage with the idle set on, and nothing sent or said yet.
function commy.boot_rdm(overrides)
    return boot(commy.rdm(overrides))
end

-- The idle set of data/Commy/Commy_War_Gear.lua.
commy.war_idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets', neck = 'Loricate Torque +1', waist = 'Plat. Mog. Belt', ear1 = 'Etiolation Earring',
    ear2 = 'Loquac. Earring', ring1 = 'Defending Ring', ring2 = 'Stikini Ring +1'}

local war_items = {
    'Nyame Helm', 'Volte Cap', 'Nyame Mail', 'Kingdom Aketon', 'Nyame Gauntlets', 'Nyame Flanchard', 'Volte Hose',
    'Nyame Sollerets', 'Volte Boots', 'Loricate Torque +1', 'Sanctity Necklace', 'Plat. Mog. Belt', 'Chaac Belt',
    'Reiki Yotai', 'Etiolation Earring', 'Loquac. Earring', 'Defending Ring', 'Stikini Ring +1', "Medada's Ring",
    'Moonlight Cape',
}

-- Commy as a warrior with black mage as sub job, on the real data/WAR.lua with Commy_War_Gear.lua, holding every
-- piece it names and wearing nothing.
function commy.war(overrides)
    return options_for({character = 'Commy', main_job = 'WAR', sub_job = 'BLM', expect_file = 'WAR.lua'}, war_items,
        overrides)
end

-- Commy as a warrior at noon, with the idle set on, and nothing sent or said yet.
function commy.boot_war(overrides)
    return boot(commy.war(overrides), function(gs)
        commy.game(gs, 'set_time', 12 * 60)
    end)
end

-- The idle set of data/Commy/Commy_Thf_Gear.lua.
commy.thf_idle = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets', legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets', waist = 'Plat. Mog. Belt'}

local thf_items = {
    'Nyame Helm', 'Volte Cap', 'Nyame Mail', 'Malignance Tabard', 'Nyame Gauntlets', 'Nyame Flanchard', 'Volte Hose',
    'Nyame Sollerets', 'Sanctity Necklace', 'Plat. Mog. Belt', 'Chaac Belt', "Medada's Ring", 'Moonlight Cape',
}

-- Commy as a thief with warrior as sub job and 1000 TP, on the real data/THF.lua with Commy_Thf_Gear.lua, with the
-- idle set on and nothing sent or said yet.
function commy.boot_thf(overrides)
    return boot(options_for({character = 'Commy', main_job = 'THF', sub_job = 'WAR', tp = 1000,
        expect_file = 'THF.lua'}, thf_items, overrides))
end

-- The lines put in the chat log since this was last asked of the session, without the codes GearSwap's
-- add_to_chat colours them with.
function commy.chat(gs)
    local log = gs.game.chat_log
    local lines = {}
    for i = (gs.commy_chat_seen or 0) + 1, #log do
        lines[#lines + 1] = (log[i].text:gsub('^\31.', ''):gsub('\30\1$', ''))
    end
    gs.commy_chat_seen = #log
    return lines
end

-- What GearSwap printed since this was last asked of the session.
function commy.printed(gs)
    local printed = gs.env.printed
    local lines = {}
    for i = (gs.commy_printed_seen or 0) + 1, #printed do
        lines[#lines + 1] = printed[i]
    end
    gs.commy_printed_seen = #printed
    return lines
end

-- Has the game do something, by the name of a method of support/game.lua's Game, and lets it settle, as the
-- session's own methods do.
function commy.game(gs, method, ...)
    local arguments = {n = select('#', ...), ...}
    gs:run(function()
        gs.game[method](gs.game, unpack(arguments, 1, arguments.n))
        gs.game:settle()
    end)
end

-- The id of the entry with that English name in a test resource (spells, monster_abilities and the like).
local function resource_id(resource, name)
    for id, entry in pairs(require('harness').resources()[resource]) do
        if type(entry) == 'table' and entry.en == name then
            return id
        end
    end
    error(('the test resources have no %s named %q'):format(resource, name), 3)
end

-- An action of the monster's at a target, Commy unless given, as the action packet the server sends of it:
-- category 1 a melee hit, 7 a TP move readied and 11 one used, 8 a spell begun and 4 one cast. name is the move or
-- spell, by its English name.
function commy.monster_acts(gs, category, name, target_id)
    local resource = (category == 7 or category == 11) and 'monster_abilities'
        or (category == 4 or category == 8) and 'spells'
    local id = resource and resource_id(resource, name) or 0
    -- The packet that begins an action names it in its target's action, with 24931 as its own param.
    local begins = category == 7 or category == 8
    gs:run(function()
        gs.game:send_action_packet({
            actor_id = gs.game.monster.id, category = category, param = begins and 24931 or id,
            targets = {{id = target_id or gs.game.player.id, actions = {{message = category == 1 and 1 or 0,
                param = begins and id or 100, reaction = 0, animation = 0, effect = 0, stagger = 0}}}},
        })
        gs.game:settle()
    end)
end

-- A melee hit of Commy's on the monster, as the action packet the server sends of it.
function commy.hit(gs)
    gs:run(function()
        gs.game:send_action_packet({category = 1, param = 0, targets = {{id = gs.game.monster.id, actions = {{
            message = 1, param = 100, reaction = 0, animation = 0, effect = 0, stagger = 0}}}}})
        gs.game:settle()
    end)
end

-- Commy defeats the monster: it is left at 0% HP, and the server's message says it was defeated.
function commy.defeat(gs)
    gs:run(function()
        gs.game.monster.hpp = 0
        gs.game:send_action_message({target_id = gs.game.monster.id, target_index = gs.game.monster.index,
            message_id = 6})
        gs.game:settle()
    end)
end

-- Notes each line typed through windower.chat.input from here on, as it is typed, whether GearSwap then takes it as
-- an action or lets it through to the game.
function commy.record_input(gs)
    local lines = {}
    local chat = gs.game.windower.chat
    local input = chat.input
    chat.input = function(text)
        lines[#lines + 1] = text
        return input(text)
    end
    return lines
end

return commy
