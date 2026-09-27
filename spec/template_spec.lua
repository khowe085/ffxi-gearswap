local gearswap_env = require("spec.gearswap_env")

describe("Template", function()
	local gs

	before_each(function()
		gs = gearswap_env.new()
	end)

	it("loads with the core and runs a full cast without errors", function()
		local spell = {
			english = "Frazzle II",
			name = "Frazzle II",
			action_type = "Magic",
			skill = "Enfeebling Magic",
			type = "WhiteMagic",
			target = { type = "SELF", raw = "<me>" },
		}

		assert.has_no.errors(function()
			gs:include("Template.lua")
			gs.env.get_sets()
			gs.env.precast(spell)
			gs.env.midcast(spell)
			gs.env.aftercast(spell)
			gs.env.self_command("cycle OffenseMode")
		end)
	end)

	it("leaves unfilled gear pieces nil so the layer beneath shows through", function()
		gs:include("Template.lua")
		gs.env.get_sets()
		local sets = gs.env.sets
		sets.midcast.FastRecast = { head = "Fast Recast Head" }
		sets.midcast.Frazzle = { head = gs.env.gear.af_head, body = "Frazzle Body" }

		gs.env.midcast({
			english = "Frazzle II",
			name = "Frazzle II",
			action_type = "Magic",
			skill = "Enfeebling Magic",
			type = "WhiteMagic",
		})

		assert.are.same({ head = "Fast Recast Head", body = "Frazzle Body" }, gs:worn())
	end)

	it("defines skeletons for the job hooks", function()
		gs:include("Template.lua")

		for _, hook in ipairs({
			"job_get_spell_map",
			"job_post_precast",
			"job_post_midcast",
			"job_post_aftercast",
			"job_customize_idle_set",
			"job_customize_melee_set",
			"job_self_command",
			"job_file_unload",
			"job_post_job_change",
			"job_filter_precast",
		}) do
			assert.are.equal("function", type(gs.env[hook]), hook)
		end
	end)
end)
