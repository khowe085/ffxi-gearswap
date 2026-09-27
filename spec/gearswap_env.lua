-- Stand-in for the sandboxed environment GearSwap gives user files (see load_user_files in
-- refresh.lua). Records equip() calls so specs can assert on the gear an event puts on.
local gearswap_env = {}
gearswap_env.__index = gearswap_env

-- GearSwap's slot_map (statics.lua), which it matches case-insensitively.
local slot_aliases = {
	main = "main",
	sub = "sub",
	range = "range",
	ranged = "range",
	ammo = "ammo",
	head = "head",
	body = "body",
	hands = "hands",
	legs = "legs",
	feet = "feet",
	neck = "neck",
	waist = "waist",
	back = "back",
	ear1 = "ear1",
	left_ear = "ear1",
	learring = "ear1",
	lear = "ear1",
	ear2 = "ear2",
	right_ear = "ear2",
	rearring = "ear2",
	rear = "ear2",
	ring1 = "ring1",
	left_ring = "ring1",
	lring = "ring1",
	ring2 = "ring2",
	right_ring = "ring2",
	rring = "ring2",
}

-- slot_map's ids, which index GearSwap's disable_table.
local slot_ids = {
	main = 0,
	sub = 1,
	range = 2,
	ammo = 3,
	head = 4,
	body = 5,
	hands = 6,
	legs = 7,
	feet = 8,
	neck = 9,
	waist = 10,
	ear1 = 11,
	ear2 = 12,
	ring1 = 13,
	ring2 = 14,
	back = 15,
}

-- Mirrors the part of GearSwap's pathsearch order that specs rely on.
local search_dirs = { "libs/", "data/common/", "data/" }

-- The environment of the spec running now, for fn:schedule below to record into.
local current

-- Windower's functions library, which GearSwap loads, gives every function a :schedule(delay, ...)
-- method. Functions share one metatable, so this stands in for it across the whole test run.
debug.setmetatable(function() end, {
	__index = {
		schedule = function(fn, delay, ...)
			local args = { ... }
			table.insert(current.scheduled, {
				fn = function()
					return fn(unpack(args))
				end,
				delay = delay,
			})
		end,
	},
})

-- Stands in for the pending pet move when a spec only says one is pending (pet_in_action = true).
local some_pet_move = { english = "Pet Move", name = "Pet Move", type = "Monster", target = { type = "SELF" } }

-- Windower's texts library: an on-screen text box, hidden until shown.
local function new_text_box(settings)
	local box = { settings = settings, content = "", shown = false, x = settings.pos.x, y = settings.pos.y }
	function box:text(content)
		self.content = content
	end
	function box:show()
		self.shown = true
	end
	function box:hide()
		self.shown = false
	end
	function box:visible()
		return self.shown
	end
	function box:pos(x, y)
		if x then
			self.x, self.y = x, y
		end
		return self.x, self.y
	end
	return box
end

function gearswap_env.new()
	local gs = setmetatable({
		equips = {},
		chat = {},
		in_action = false,
		pet_in_action = false,
		cancelled = false,
		commands = {},
		scheduled = {},
		clock = 0,
		events = {},
		mobs = { me = { x = 0, y = 0, z = 0 } },
		known_spells = {},
		spell_resources = {},
		castable = true,
		screen = { ui_x_res = 1920, ui_y_res = 1080 },
		ability_recasts = {},
		spell_recasts = {},
		disabled = {},
		blocked = {},
	}, gearswap_env)
	current = gs

	local env = {
		string = string,
		math = math,
		table = table,
		os = setmetatable({
			clock = function()
				return gs.clock
			end,
		}, { __index = os }),
		type = type,
		tostring = tostring,
		tonumber = tonumber,
		pairs = pairs,
		ipairs = ipairs,
		next = next,
		select = select,
		unpack = unpack,
		error = error,
		pcall = pcall,
		assert = assert,
		print = print,
		setmetatable = setmetatable,
		getmetatable = getmetatable,
		rawget = rawget,
		rawset = rawset,
		player = {
			name = "Tester",
			status = "Idle",
			hp = 1000,
			tp = 1000,
			mp = 1000,
			main_job = "RDM",
			main_job_level = 99,
			sub_job = "NIN",
			sub_job_level = 49,
		},
		buffactive = {},
		world = { weather_element = "None", day_element = "Fire", area = "La Theine Plateau" },
		sets = { naked = {} },
	}
	env._G = env

	env.windower = {
		ffxi = {
			get_ability_recasts = function()
				return gs.ability_recasts
			end,
			get_spell_recasts = function()
				return gs.spell_recasts
			end,
			get_mob_by_target = function(target)
				return gs.mobs[target]
			end,
			get_spells = function()
				return gs.known_spells
			end,
		},
		register_event = function(name, handler)
			gs.events[name] = gs.events[name] or {}
			table.insert(gs.events[name], handler)
		end,
	}
	env.windower.raw_register_event = env.windower.register_event
	env.windower.get_windower_settings = function()
		return gs.screen
	end
	env.texts = {
		new = function(settings)
			gs.hud = new_text_box(settings)
			return gs.hud
		end,
	}
	env.cancel_spell = function()
		gs.cancelled = true
	end

	-- Like set_merge: keeps only slot keys, and holds back pieces for disabled slots until enable().
	env.equip = function(...)
		for i = 1, select("#", ...) do
			local sent = {}
			for key, item in pairs(select(i, ...)) do
				local slot = type(key) == "string" and slot_aliases[key:lower()]
				if slot and gs.disabled[slot] then
					gs.blocked[slot] = item
				elseif slot then
					sent[slot] = item
				end
			end
			gs.equips[#gs.equips + 1] = sent
		end
	end
	env.disable = function(...)
		for _, name in ipairs({ ... }) do
			gs.disabled[slot_aliases[name:lower()]] = true
		end
	end
	-- GearSwap's own enable() (reachable as gearswap.enable): unlocks and hands back what was held
	-- back, without sending it.
	local function internal_enable(...)
		local sending = {}
		for _, name in ipairs({ ... }) do
			local slot = slot_aliases[name:lower()]
			gs.disabled[slot] = nil
			sending[slot] = gs.blocked[slot]
			gs.blocked[slot] = nil
		end
		return sending
	end
	local slot_map = {}
	for alias, slot in pairs(slot_aliases) do
		slot_map[alias] = slot_ids[slot]
	end
	local disable_table = setmetatable({}, {
		__index = function(_, id)
			for slot, slotId in pairs(slot_ids) do
				if slotId == id then
					return gs.disabled[slot] or false
				end
			end
		end,
	})
	env.gearswap = {
		enable = internal_enable,
		slot_map = slot_map,
		disable_table = disable_table,
		res = { spells = gs.spell_resources },
		-- GearSwap's own check for a known spell your jobs and levels can cast.
		check_spell = function()
			return gs.castable
		end,
		-- GearSwap re-reads the game's state into player, buffactive, world and the like.
		refresh_globals = function()
			if gs.on_refresh then
				gs.on_refresh()
			end
		end,
	}
	-- Like user_enable: re-sends whatever was held back while the slots were disabled.
	env.enable = function(...)
		local sending = internal_enable(...)
		if next(sending) then
			env.equip(sending)
		end
		return sending
	end
	env.send_command = function(command)
		gs.commands[#gs.commands + 1] = command
	end
	env.add_to_chat = function(_, text)
		gs.chat[#gs.chat + 1] = text
	end
	env.midaction = function()
		return gs.in_action
	end
	-- Like user_pet_midaction: whether a pet move is pending, and if so which. pet_in_action is the
	-- move, or true for any move.
	env.pet_midaction = function()
		if not gs.pet_in_action then
			return false
		end
		return true, gs.pet_in_action == true and some_pet_move or gs.pet_in_action
	end
	env.include = function(name)
		return gs:include(name)
	end

	gs.env = env
	return gs
end

function gearswap_env:include(name)
	for _, dir in ipairs(search_dirs) do
		local path = dir .. name
		local file = io.open(path)
		if file then
			file:close()
			local chunk = assert(loadfile(path))
			return setfenv(chunk, self.env)()
		end
	end
	error("include() could not find " .. name, 2)
end

-- The gear GearSwap would end up sending for the equip() calls made so far: later calls win per
-- slot.
function gearswap_env:worn()
	local worn = {}
	for _, sent in ipairs(self.equips) do
		for slot, item in pairs(sent) do
			worn[slot] = item
		end
	end
	return worn
end

-- Runs what the job file scheduled, as if its delay had passed.
function gearswap_env:run_scheduled()
	local due = self.scheduled
	self.scheduled = {}
	for _, entry in ipairs(due) do
		entry.fn()
	end
end

-- Stands in for Windower raising an event the job file registered for.
function gearswap_env:fire(name, ...)
	for _, handler in ipairs(self.events[name] or {}) do
		handler(...)
	end
end

function gearswap_env:reset()
	self.equips = {}
	self.chat = {}
end

return gearswap_env
