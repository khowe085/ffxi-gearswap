local gearswap_env = require("spec.gearswap_env")

local function magic(english, skill, spell_type)
	return {
		english = english,
		name = english,
		action_type = "Magic",
		skill = skill,
		type = spell_type,
		target = { type = "SELF", raw = "<me>" },
	}
end

local function ability(english, ability_type)
	return {
		english = english,
		name = english,
		action_type = "Ability",
		type = ability_type,
		target = { type = "SELF", raw = "<me>" },
	}
end

local function weapon_skill(english)
	return {
		english = english,
		name = english,
		action_type = "Ability",
		type = "WeaponSkill",
		skill = "Sword",
		target = { raw = "<t>" },
	}
end

local frazzle_ii = magic("Frazzle II", "Enfeebling Magic", "WhiteMagic")
local ranged_attack = { english = "Ranged", name = "Ranged", action_type = "Ranged Attack", type = "Misc" }

describe("Core", function()
	local gs, sets

	before_each(function()
		gs = gearswap_env.new()
		gs:include("Core.lua")
		sets = gs.env.sets
	end)

	it("creates an empty gear table for job files to fill", function()
		assert.are.same({}, gs.env.gear)
	end)

	describe("midcast", function()
		it("equips the set named after the spell", function()
			sets.midcast["Frazzle II"] = { body = "Frazzle II Body" }

			gs.env.midcast(frazzle_ii)

			assert.are.same({ body = "Frazzle II Body" }, gs:worn())
		end)

		it("falls back to the spell map set", function()
			sets.midcast.Frazzle = { body = "Frazzle Body" }

			gs.env.midcast(frazzle_ii)

			assert.are.same({ body = "Frazzle Body" }, gs:worn())
		end)

		it("falls back to the skill set", function()
			sets.midcast["Enfeebling Magic"] = { body = "Enfeebling Body" }

			gs.env.midcast(frazzle_ii)

			assert.are.same({ body = "Enfeebling Body" }, gs:worn())
		end)

		it("falls back to the spell type set", function()
			sets.midcast.WhiteMagic = { body = "White Magic Body" }

			gs.env.midcast(frazzle_ii)

			assert.are.same({ body = "White Magic Body" }, gs:worn())
		end)

		it("prefers spell name, then spell map, then skill, then type", function()
			sets.midcast["Frazzle II"] = { body = "Name Body" }
			sets.midcast.Frazzle = { body = "Map Body" }
			sets.midcast["Enfeebling Magic"] = { body = "Skill Body" }
			sets.midcast.WhiteMagic = { body = "Type Body" }
			local worn = {}

			for _, key in ipairs({ "Frazzle II", "Frazzle", "Enfeebling Magic", "WhiteMagic" }) do
				gs:reset()
				gs.env.midcast(frazzle_ii)
				worn[#worn + 1] = gs:worn().body
				sets.midcast[key] = nil
			end

			assert.are.same({ "Name Body", "Map Body", "Skill Body", "Type Body" }, worn)
		end)

		it("refines a skill set by the spell map", function()
			sets.midcast["Enfeebling Magic"] = {
				body = "Enfeebling Body",
				Frazzle = { body = "Enfeebling Frazzle Body" },
			}

			gs.env.midcast(frazzle_ii)

			assert.are.same({ body = "Enfeebling Frazzle Body" }, gs:worn())
		end)

		it("skips the skill set for spells whose potency ignores skill", function()
			sets.midcast["Healing Magic"] = { body = "Healing Body" }
			sets.midcast.WhiteMagic = { body = "White Magic Body" }

			gs.env.midcast(magic("Raise", "Healing Magic", "WhiteMagic"))

			assert.are.same({ body = "White Magic Body" }, gs:worn())
		end)

		it("uses the Cure set for Curaga spells without a Curaga set", function()
			sets.midcast.Cure = { body = "Cure Body" }
			sets.midcast["Healing Magic"] = { body = "Healing Body" }

			gs.env.midcast(magic("Curaga II", "Healing Magic", "WhiteMagic"))

			assert.are.same({ body = "Cure Body" }, gs:worn())
		end)

		it("uses the Cure set for Cure-family job maps without their own set", function()
			gs.env.job_get_spell_map = function(spell)
				if spell.english == "Cure III" then
					return "CureSelf"
				end
			end
			sets.midcast.Cure = { body = "Cure Body" }
			sets.midcast["Healing Magic"] = { body = "Healing Body" }

			gs.env.midcast(magic("Cure III", "Healing Magic", "WhiteMagic"))

			assert.are.same({ body = "Cure Body" }, gs:worn())
		end)

		it("layers the chosen set over FastRecast for magic", function()
			sets.midcast.FastRecast = { head = "Fast Recast Head", body = "Fast Recast Body" }
			sets.midcast.Frazzle = { body = "Frazzle Body" }

			gs.env.midcast(frazzle_ii)

			assert.are.same({ head = "Fast Recast Head", body = "Frazzle Body" }, gs:worn())
		end)

		it("keeps FastRecast when no midcast set matches, even beside a slot-named set", function()
			sets.midcast.FastRecast = { range = "Fast Recast Range" }
			sets.midcast.Ranged = { range = "Ranged Midcast Range" }

			gs.env.midcast(frazzle_ii)

			assert.are.same({ range = "Fast Recast Range" }, gs:worn())
		end)

		it("uses the RA set for ranged attacks", function()
			sets.midcast.RA = { range = "RA Midcast Range" }

			gs.env.midcast(ranged_attack)

			assert.are.same({ range = "RA Midcast Range" }, gs:worn())
		end)

		it("uses the RangedAttack set when the precast sets use that name", function()
			sets.precast.RangedAttack = { range = "RangedAttack Precast Range" }
			sets.midcast.RangedAttack = { range = "RangedAttack Midcast Range" }
			sets.midcast.RA = { range = "RA Midcast Range" }

			gs.env.midcast(ranged_attack)

			assert.are.same({ range = "RangedAttack Midcast Range" }, gs:worn())
		end)

		it("equips nothing for a ranged attack when there is no RA set", function()
			sets.midcast.Ranged = { range = "Ranged Name Range" }
			sets.midcast.Misc = { range = "Misc Type Range" }

			gs.env.midcast(ranged_attack)

			assert.are.same({}, gs:worn())
		end)

		it("uses the set named after an item", function()
			sets.midcast["Holy Water"] = { neck = "Holy Water Neck" }

			gs.env.midcast({ english = "Holy Water", name = "Holy Water", action_type = "Item", type = "Item" })

			assert.are.same({ neck = "Holy Water Neck" }, gs:worn())
		end)

		it("lays down FastRecast only for magic", function()
			sets.midcast.FastRecast = { head = "Fast Recast Head" }

			gs.env.midcast({ english = "Holy Water", name = "Holy Water", action_type = "Item", type = "Item" })
			gs.env.midcast({ english = "Ranged", name = "Ranged", action_type = "Ranged Attack", type = "Misc" })

			assert.are.same({}, gs:worn())
		end)

		it("equips nothing for weapon skills and job abilities", function()
			sets.midcast["Savage Blade"] = { body = "Savage Blade Body" }
			sets.midcast.Chainspell = { body = "Chainspell Body" }

			gs.env.midcast(weapon_skill("Savage Blade"))
			gs.env.midcast(ability("Chainspell", "JobAbility"))

			assert.are.same({}, gs:worn())
		end)

		it("runs midcast for abilities other than weapon skills and job abilities", function()
			sets.midcast.Waltz = { body = "Waltz Body" }

			gs.env.midcast(ability("Curing Waltz III", "Waltz"))

			assert.are.same({ body = "Waltz Body" }, gs:worn())
		end)

		it("uses the CastingMode sub-set of the chosen set", function()
			gs.env.state.CastingMode:options("Normal", "Resistant")
			gs.env.state.CastingMode:set("Resistant")
			sets.midcast.Frazzle = { body = "Frazzle Body", Resistant = { body = "Resistant Frazzle Body" } }

			gs.env.midcast(frazzle_ii)

			assert.are.same({ body = "Resistant Frazzle Body" }, gs:worn())
		end)

		it("uses the job file's spell map when job_get_spell_map returns one", function()
			gs.env.job_get_spell_map = function(_, defaultMap)
				if defaultMap == "Frazzle" then
					return "Potency"
				end
			end
			sets.midcast.Frazzle = { body = "Frazzle Body" }
			sets.midcast.Distract = { body = "Distract Body" }
			sets.midcast.Potency = { body = "Potency Body" }

			gs.env.midcast(frazzle_ii)
			local remapped = gs:worn()
			gs:reset()
			gs.env.midcast(magic("Distract II", "Enfeebling Magic", "WhiteMagic"))

			assert.are.same({ body = "Potency Body" }, remapped)
			assert.are.same({ body = "Distract Body" }, gs:worn())
		end)

		it("does not call job_post_midcast for weapon skills or job abilities", function()
			gs.env.job_post_midcast = function(spell)
				gs.env.equip({ body = "Post " .. spell.english })
			end

			gs.env.midcast(weapon_skill("Savage Blade"))

			assert.are.same({}, gs:worn())
		end)

		it("lets job_post_midcast layer gear over the chosen set", function()
			gs.env.job_post_midcast = function(spell, spellMap)
				gs.env.equip({ body = "Post " .. spell.english .. " " .. spellMap })
			end
			sets.midcast.Frazzle = { head = "Frazzle Head", body = "Frazzle Body" }

			gs.env.midcast(frazzle_ii)

			assert.are.same({ head = "Frazzle Head", body = "Post Frazzle II Frazzle" }, gs:worn())
		end)
	end)

	describe("precast", function()
		it("equips nothing for magic when no FC sets are defined", function()
			gs.env.precast(frazzle_ii)

			assert.are.same({}, gs:worn())
		end)

		it("equips nothing when the user file replaced sets.precast without that category", function()
			sets.precast = { FC = { head = "FC Head" } }

			gs.env.precast(weapon_skill("Savage Blade"))

			assert.are.same({}, gs:worn())
		end)

		it("equips the FC set for magic", function()
			sets.precast.FC = { head = "FC Head" }

			gs.env.precast(frazzle_ii)

			assert.are.same({ head = "FC Head" }, gs:worn())
		end)

		it("refines the FC set by skill", function()
			sets.precast.FC = { head = "FC Head" }
			sets.precast.FC["Enhancing Magic"] = { head = "Enhancing FC Head" }

			gs.env.precast(magic("Refresh II", "Enhancing Magic", "WhiteMagic"))

			assert.are.same({ head = "Enhancing FC Head" }, gs:worn())
		end)

		it("uses the CastingMode sub-set of the FC set", function()
			gs.env.state.CastingMode:options("Normal", "Resistant")
			gs.env.state.CastingMode:set("Resistant")
			sets.precast.FC = { head = "FC Head", Resistant = { head = "Resistant FC Head" } }

			gs.env.precast(frazzle_ii)

			assert.are.same({ head = "Resistant FC Head" }, gs:worn())
		end)

		it("equips the WS set named after the weapon skill, else the base WS set", function()
			sets.precast.WS = { head = "WS Head" }
			sets.precast.WS["Savage Blade"] = { head = "Savage Blade Head" }

			gs.env.precast(weapon_skill("Savage Blade"))
			local named = gs:worn()
			gs:reset()
			gs.env.precast(weapon_skill("Black Halo"))

			assert.are.same({ head = "Savage Blade Head" }, named)
			assert.are.same({ head = "WS Head" }, gs:worn())
		end)

		it("uses the OffenseMode sub-set of the WS set", function()
			gs.env.state.OffenseMode:options("Normal", "Acc")
			gs.env.state.OffenseMode:set("Acc")
			sets.precast.WS["Savage Blade"] = { head = "Savage Blade Head", Acc = { head = "Acc Savage Blade Head" } }

			gs.env.precast(weapon_skill("Savage Blade"))

			assert.are.same({ head = "Acc Savage Blade Head" }, gs:worn())
		end)

		it("equips the JA set named after the job ability", function()
			sets.precast.JA.Chainspell = { body = "Chainspell Body" }

			gs.env.precast(ability("Chainspell", "JobAbility"))

			assert.are.same({ body = "Chainspell Body" }, gs:worn())
		end)

		it("equips other ability types from their own table, else from the JA table", function()
			sets.precast.Waltz = { body = "Waltz Body" }
			sets.precast.JA["Box Step"] = { body = "Box Step Body" }

			gs.env.precast(ability("Curing Waltz III", "Waltz"))
			local ownTable = gs:worn()
			gs:reset()
			gs.env.precast(ability("Box Step", "Step"))

			assert.are.same({ body = "Waltz Body" }, ownTable)
			assert.are.same({ body = "Box Step Body" }, gs:worn())
		end)

		it("equips the RA set for ranged attacks, or the RangedAttack set when defined", function()
			local ranged = { english = "Ranged", name = "Ranged", action_type = "Ranged Attack", type = "Misc" }
			sets.precast.RA = { body = "RA Body" }

			gs.env.precast(ranged)
			local ra = gs:worn()
			gs:reset()
			sets.precast.RangedAttack = { body = "RangedAttack Body" }
			gs.env.precast(ranged)

			assert.are.same({ body = "RA Body" }, ra)
			assert.are.same({ body = "RangedAttack Body" }, gs:worn())
		end)

		it("equips the Item set named after the item", function()
			sets.precast.Item["Holy Water"] = { neck = "Holy Water Neck" }

			gs.env.precast({ english = "Holy Water", name = "Holy Water", action_type = "Item", type = "Item" })

			assert.are.same({ neck = "Holy Water Neck" }, gs:worn())
		end)

		it("lets job_post_precast layer gear over the chosen set", function()
			gs.env.job_post_precast = function(spell, spellMap)
				gs.env.equip({ body = "Post " .. spell.english .. " " .. spellMap })
			end
			sets.precast.FC = { head = "FC Head", body = "FC Body" }

			gs.env.precast(frazzle_ii)

			assert.are.same({ head = "FC Head", body = "Post Frazzle II Frazzle" }, gs:worn())
		end)

		it("still calls job_post_precast when no precast set applies", function()
			gs.env.job_post_precast = function(spell)
				gs.env.equip({ body = "Post " .. spell.english })
			end
			sets.precast = {}

			gs.env.precast(weapon_skill("Savage Blade"))

			assert.are.same({ body = "Post Savage Blade" }, gs:worn())
		end)
	end)

	describe("precast of an action that cannot happen", function()
		it("cancels any action while another is in flight, silently and without equipping", function()
			gs.in_action = true
			sets.precast.FC = { head = "FC Head" }
			gs.env.job_post_precast = function()
				gs.env.equip({ body = "Post Body" })
			end

			gs.env.precast(frazzle_ii)

			assert.is_true(gs.cancelled)
			assert.are.same({}, gs:worn())
			assert.are.same({}, gs.chat)
		end)

		it("cancels a weapon skill under 1000 TP", function()
			gs.env.player.tp = 999
			sets.precast.WS["Savage Blade"] = { head = "Savage Blade Head" }

			gs.env.precast(weapon_skill("Savage Blade"))

			assert.is_true(gs.cancelled)
			assert.are.same({}, gs:worn())
		end)

		it("cancels every kind of action while incapacitated", function()
			local actions =
				{ frazzle_ii, ability("Chainspell", "JobAbility"), weapon_skill("Savage Blade"), ranged_attack }
			local allowed = {}

			for _, buff in ipairs({ "terror", "sleep", "lullaby", "stun", "animated", "charm", "petrification" }) do
				gs.env.buffactive = { [buff] = 1 }
				for _, action in ipairs(actions) do
					gs.cancelled = false
					gs.env.precast(action)
					if not gs.cancelled then
						allowed[#allowed + 1] = buff .. " " .. action.english
					end
				end
			end

			assert.are.same({}, allowed)
		end)

		it("cancels abilities but not magic under Amnesia or Impairment", function()
			local outcomes = {}

			for _, buff in ipairs({ "amnesia", "impairment" }) do
				gs.env.buffactive = { [buff] = 1 }
				for _, action in ipairs({
					ability("Chainspell", "JobAbility"),
					weapon_skill("Savage Blade"),
					frazzle_ii,
				}) do
					gs.cancelled = false
					gs.env.precast(action)
					outcomes[#outcomes + 1] = buff .. " " .. action.english .. ": " .. tostring(gs.cancelled)
				end
			end

			assert.are.same({
				"amnesia Chainspell: true",
				"amnesia Savage Blade: true",
				"amnesia Frazzle II: false",
				"impairment Chainspell: true",
				"impairment Savage Blade: true",
				"impairment Frazzle II: false",
			}, outcomes)
		end)

		it("cancels magic but not abilities under Silence, Mute or Omerta", function()
			local outcomes = {}

			for _, buff in ipairs({ "silence", "mute", "omerta" }) do
				gs.env.buffactive = { [buff] = 1 }
				for _, action in ipairs({ frazzle_ii, weapon_skill("Savage Blade") }) do
					gs.cancelled = false
					gs.env.precast(action)
					outcomes[#outcomes + 1] = buff .. " " .. action.english .. ": " .. tostring(gs.cancelled)
				end
			end

			assert.are.same({
				"silence Frazzle II: true",
				"silence Savage Blade: false",
				"mute Frazzle II: true",
				"mute Savage Blade: false",
				"omerta Frazzle II: true",
				"omerta Savage Blade: false",
			}, outcomes)
		end)

		it("still lets you use items such as Echo Drops while silenced", function()
			gs.env.buffactive = { silence = 1 }

			gs.env.precast({ english = "Echo Drops", name = "Echo Drops", action_type = "Item", type = "Item" })

			assert.is_false(gs.cancelled)
		end)

		it("cancels actions when KO or not idle or engaged", function()
			local outcomes = {}

			for _, case in ipairs({
				{ status = "Idle", hp = 0 },
				{ status = "Resting", hp = 1000 },
				{ status = "Engaged", hp = 1000 },
				{ status = "Idle", hp = 1000 },
			}) do
				gs.env.player.status = case.status
				gs.env.player.hp = case.hp
				gs.cancelled = false
				gs.env.precast(frazzle_ii)
				outcomes[#outcomes + 1] = case.status .. " " .. case.hp .. ": " .. tostring(gs.cancelled)
			end

			assert.are.same(
				{ "Idle 0: true", "Resting 1000: true", "Engaged 1000: false", "Idle 1000: false" },
				outcomes
			)
		end)

		it("cancels a job ability only while its recast is known to be running", function()
			local chainspell = ability("Chainspell", "JobAbility")
			chainspell.recast_id = 0
			local outcomes = {}

			for _, recast in ipairs({ 30, 0, "unknown" }) do
				gs.ability_recasts = recast == "unknown" and {} or { [0] = recast }
				gs.cancelled = false
				gs.env.precast(chainspell)
				outcomes[#outcomes + 1] = recast .. ": " .. tostring(gs.cancelled)
			end

			assert.are.same({ "30: true", "0: false", "unknown: false" }, outcomes)
		end)

		it("ignores the running recast of charge-based abilities", function()
			local allowed = {}

			for _, recastId in ipairs({ 102, 195, 231, 255 }) do
				local stratagem = ability("Charged Ability", "JobAbility")
				stratagem.recast_id = recastId
				gs.ability_recasts = { [recastId] = 30 }
				gs.cancelled = false
				gs.env.precast(stratagem)
				allowed[#allowed + 1] = recastId .. ": " .. tostring(not gs.cancelled)
			end

			assert.are.same({ "102: true", "195: true", "231: true", "255: true" }, allowed)
		end)

		it("cancels a spell only while its recast is known to be running", function()
			local frazzle = magic("Frazzle II", "Enfeebling Magic", "WhiteMagic")
			frazzle.recast_id = 843
			local outcomes = {}

			for _, recast in ipairs({ 120, 0, "unknown" }) do
				gs.spell_recasts = recast == "unknown" and {} or { [843] = recast }
				gs.cancelled = false
				gs.env.precast(frazzle)
				outcomes[#outcomes + 1] = recast .. ": " .. tostring(gs.cancelled)
			end

			assert.are.same({ "120: true", "0: false", "unknown: false" }, outcomes)
		end)

		it("cancels with any recast left, even in the last moments Sel lets through", function()
			local chainspell = ability("Chainspell", "JobAbility")
			chainspell.recast_id = 0
			local frazzle = magic("Frazzle II", "Enfeebling Magic", "WhiteMagic")
			frazzle.recast_id = 843
			-- Ability recasts are in seconds, spell recasts in 1/60ths of a second.
			gs.ability_recasts = { [0] = 0.4 }
			gs.spell_recasts = { [843] = 40 }
			local cancelled = {}

			for _, action in ipairs({ chainspell, frazzle }) do
				gs.cancelled = false
				gs.env.precast(action)
				cancelled[#cancelled + 1] = gs.cancelled
			end

			assert.are.same({ true, true }, cancelled)
		end)
	end)

	describe("aftercast", function()
		it("equips nothing when the user file defines no status sets", function()
			for _, status in ipairs({ "Idle", "Engaged", "Resting" }) do
				gs.env.player.status = status
				gs.env.aftercast(frazzle_ii)
			end

			assert.are.same({}, gs:worn())
		end)

		it("equips the idle set when idle", function()
			sets.idle = { body = "Idle Body" }

			gs.env.aftercast(frazzle_ii)

			assert.are.same({ body = "Idle Body" }, gs:worn())
		end)

		it("uses the IdleMode sub-set of the idle set", function()
			gs.env.state.IdleMode:options("Normal", "DT")
			gs.env.state.IdleMode:set("DT")
			sets.idle = { body = "Idle Body", DT = { body = "DT Idle Body" } }

			gs.env.aftercast(frazzle_ii)

			assert.are.same({ body = "DT Idle Body" }, gs:worn())
		end)

		it("equips the engaged set when engaged", function()
			gs.env.player.status = "Engaged"
			sets.idle = { body = "Idle Body" }
			sets.engaged = { body = "Engaged Body" }

			gs.env.aftercast(frazzle_ii)

			assert.are.same({ body = "Engaged Body" }, gs:worn())
		end)

		it("uses the OffenseMode then HybridMode sub-sets of the engaged set", function()
			gs.env.player.status = "Engaged"
			gs.env.state.OffenseMode:options("Normal", "Acc")
			gs.env.state.OffenseMode:set("Acc")
			gs.env.state.HybridMode:options("Normal", "DT")
			gs.env.state.HybridMode:set("DT")
			sets.engaged = {
				body = "Engaged Body",
				Acc = { body = "Acc Body", DT = { body = "Acc DT Body" } },
			}

			gs.env.aftercast(frazzle_ii)

			assert.are.same({ body = "Acc DT Body" }, gs:worn())
		end)

		it("applies HybridMode even when the OffenseMode has no sub-set", function()
			gs.env.player.status = "Engaged"
			gs.env.state.OffenseMode:options("Normal", "Acc")
			gs.env.state.OffenseMode:set("Acc")
			gs.env.state.HybridMode:options("Normal", "DT")
			gs.env.state.HybridMode:set("DT")
			sets.engaged = { body = "Engaged Body", DT = { body = "DT Body" } }

			gs.env.aftercast(frazzle_ii)

			assert.are.same({ body = "DT Body" }, gs:worn())
		end)

		it("lets job_post_aftercast layer gear over the status set", function()
			gs.env.job_post_aftercast = function(spell, spellMap)
				gs.env.equip({ body = "Post " .. spell.english .. " " .. spellMap })
			end
			sets.idle = { head = "Idle Head", body = "Idle Body" }

			gs.env.aftercast(frazzle_ii)

			assert.are.same({ head = "Idle Head", body = "Post Frazzle II Frazzle" }, gs:worn())
		end)

		it("equips the resting set when resting", function()
			gs.env.player.status = "Resting"
			sets.idle = { body = "Idle Body" }
			sets.resting = { body = "Resting Body" }

			gs.env.aftercast(frazzle_ii)

			assert.are.same({ body = "Resting Body" }, gs:worn())
		end)

		it("treats a blank status as idle", function()
			gs.env.player.status = ""
			sets.idle = { body = "Idle Body" }

			gs.env.aftercast(frazzle_ii)

			assert.are.same({ body = "Idle Body" }, gs:worn())
		end)

		it("equips nothing at 0 HP", function()
			gs.env.player.hp = 0
			sets.idle = { body = "Idle Body" }

			gs.env.aftercast(frazzle_ii)

			assert.are.same({}, gs:worn())
		end)

		it("equips nothing for other statuses", function()
			gs.env.player.status = "Dead"
			sets.idle = { body = "Idle Body" }

			gs.env.aftercast(frazzle_ii)

			assert.are.same({}, gs:worn())
		end)
	end)

	describe("weapons", function()
		local temper = magic("Temper", "Enhancing Magic", "WhiteMagic")

		before_each(function()
			gs.env.state.Weapons:options("None", "Naegling", "Crocea")
			sets.weapons.Naegling = { main = "Naegling", sub = "Ammurapi Shield" }
			sets.weapons.Crocea = { main = "Crocea Mors", sub = "Ammurapi Shield" }
			sets.midcast.Temper = { main = "Pukulatmuj", body = "Temper Body" }
		end)

		it("wears the chosen weapon set over the idle set", function()
			gs.env.state.Weapons:set("Naegling")
			sets.idle = { main = "Idle Staff", body = "Idle Body" }

			gs.env.aftercast(temper)

			assert.are.same({ main = "Naegling", sub = "Ammurapi Shield", body = "Idle Body" }, gs:worn())
		end)

		it("leaves weapons to the sets when Weapons is None", function()
			sets.idle = { main = "Idle Staff", body = "Idle Body" }

			gs.env.aftercast(temper)

			assert.are.same({ main = "Idle Staff", body = "Idle Body" }, gs:worn())
		end)

		it("puts the weapons on and locks main, sub and range when engaging with a weapon set", function()
			gs.env.state.Weapons:set("Naegling")
			sets.engaged = { body = "Engaged Body" }

			gs.env.status_change("Engaged", "Idle")
			local engaged = gs:worn()
			gs:reset()
			gs.env.midcast(temper)

			assert.are.same({ main = "Naegling", sub = "Ammurapi Shield", body = "Engaged Body" }, engaged)
			assert.are.same({ body = "Temper Body" }, gs:worn())
			assert.are.same({ main = true, sub = true, range = true }, gs.disabled)
		end)

		it("unlocks weapon slots when disengaging", function()
			gs.env.state.Weapons:set("Naegling")
			gs.env.status_change("Engaged", "Idle")

			gs.env.status_change("Idle", "Engaged")
			gs:reset()
			gs.env.midcast(temper)

			assert.are.same({ main = "Pukulatmuj", body = "Temper Body" }, gs:worn())
			assert.are.same({}, gs.disabled)
		end)

		it("keeps weapon slots unlocked while engaged with Weapons None", function()
			gs.env.status_change("Engaged", "Idle")
			gs:reset()
			gs.env.midcast(temper)

			assert.are.same({ main = "Pukulatmuj", body = "Temper Body" }, gs:worn())
			assert.are.same({}, gs.disabled)
		end)

		it("swaps weapons right away when Weapons changes while engaged, then relocks", function()
			gs.env.state.Weapons:set("Naegling")
			gs.env.player.status = "Engaged"
			gs.env.status_change("Engaged", "Idle")
			gs:reset()

			gs.env.self_command("set Weapons Crocea")

			assert.are.same("Crocea Mors", gs:worn().main)
			assert.are.same({ main = true, sub = true, range = true }, gs.disabled)
		end)

		it("swaps weapons after the current action when Weapons changes mid-action while engaged", function()
			gs.env.state.Weapons:set("Naegling")
			gs.env.player.status = "Engaged"
			gs.env.status_change("Engaged", "Idle")
			gs.in_action = true
			gs.env.self_command("set Weapons Crocea")
			gs.in_action = false
			gs:reset()

			gs.env.aftercast(temper)

			assert.are.same("Crocea Mors", gs:worn().main)
			assert.are.same({ main = true, sub = true, range = true }, gs.disabled)
		end)

		it("drops weapon pieces held back by the lock instead of putting them on at unlock", function()
			gs.env.state.Weapons:set("Naegling")
			sets.midcast.Frazzle = { range = "Ullr", body = "Frazzle Body" }
			sets.idle = { body = "Idle Body" }
			gs.env.status_change("Engaged", "Idle")
			gs.env.midcast(frazzle_ii)
			gs:reset()

			gs.env.status_change("Idle", "Engaged")

			assert.are.same({ main = "Naegling", sub = "Ammurapi Shield", body = "Idle Body" }, gs:worn())
		end)

		it("wears the chosen weapon set over the engaged set", function()
			gs.env.state.Weapons:set("Naegling")
			sets.engaged = { main = "Engaged Sword", body = "Engaged Body" }

			gs.env.status_change("Engaged", "Idle")

			assert.are.same({ main = "Naegling", sub = "Ammurapi Shield", body = "Engaged Body" }, gs:worn())
		end)

		it("keeps the lock after a mid-fight weapon swap", function()
			gs.env.state.Weapons:set("Naegling")
			gs.env.player.status = "Engaged"
			gs.env.status_change("Engaged", "Idle")
			gs.env.self_command("set Weapons Crocea")
			sets.engaged = { range = "Engaged Range", body = "Engaged Body" }
			gs:reset()

			gs.env.aftercast(temper)

			assert.are.same({ body = "Engaged Body" }, gs:worn())
		end)

		it("does not release a lock you take after its own lock was released", function()
			gs.env.state.Weapons:set("Naegling")
			gs.env.status_change("Engaged", "Idle")
			gs.env.status_change("Idle", "Engaged")
			gs.env.disable("main")

			gs.env.aftercast(temper)

			assert.are.same({ main = true }, gs.disabled)
		end)

		it("keeps a weapon slot you locked yourself when releasing its own lock", function()
			gs.env.disable("main")
			gs.env.state.Weapons:set("Naegling")
			gs.env.status_change("Engaged", "Idle")
			gs:reset()

			gs.env.status_change("Idle", "Engaged")

			assert.are.same({ main = true }, gs.disabled)
			assert.is_nil(gs:worn().main)
		end)

		it("leaves slots you locked yourself alone", function()
			gs.env.player.status = "Engaged"
			gs.env.disable("main", "sub")
			gs.env.midcast(temper)

			gs.env.aftercast(temper)
			gs.env.file_unload("RDM.lua")

			assert.are.same({ body = "Temper Body" }, gs:worn())
			assert.are.same({ main = true, sub = true }, gs.disabled)
		end)

		it("locks before the first precast when already engaged, as after a reload mid-fight", function()
			gs.env.player.status = "Engaged"
			gs.env.state.Weapons:set("Naegling")
			sets.precast.FC = { main = "FC Staff", body = "FC Body" }

			gs.env.precast(temper)

			assert.are.same({ body = "FC Body" }, gs:worn())
			assert.are.same({ main = true, sub = true, range = true }, gs.disabled)
		end)

		it("releases its lock at the next precast once no longer engaged, as after a KO and raise", function()
			gs.env.state.Weapons:set("Naegling")
			gs.env.status_change("Engaged", "Idle")
			gs.env.player.status = "Idle"
			sets.precast.FC = { main = "FC Staff", body = "FC Body" }
			gs:reset()

			gs.env.precast(temper)

			assert.are.same({ main = "FC Staff", body = "FC Body" }, gs:worn())
			assert.are.same({}, gs.disabled)
		end)

		it("locks the current weapons before a mode change re-equips, as after a reload mid-fight", function()
			gs.env.player.status = "Engaged"
			gs.env.state.Weapons:set("Naegling")
			sets.engaged = { body = "Engaged Body" }

			gs.env.self_command("cycle OffenseMode")

			assert.are.same({ body = "Engaged Body" }, gs:worn())
			assert.are.same({ main = true, sub = true, range = true }, gs.disabled)
		end)

		it("locks the current weapons before gs c update re-equips, as after a reload mid-fight", function()
			gs.env.player.status = "Engaged"
			gs.env.state.Weapons:set("Naegling")
			sets.engaged = { body = "Engaged Body" }

			gs.env.self_command("update")

			assert.are.same({ body = "Engaged Body" }, gs:worn())
			assert.are.same({ main = true, sub = true, range = true }, gs.disabled)
		end)

		it("calls job_file_unload after releasing its lock on unload", function()
			local disabledDuringHook
			gs.env.job_file_unload = function()
				disabledDuringHook = next(gs.disabled) ~= nil
			end
			gs.env.state.Weapons:set("Naegling")
			gs.env.status_change("Engaged", "Idle")

			gs.env.file_unload("RDM.lua")

			assert.is_false(disabledDuringHook)
		end)

		it("unlocks weapon slots when the job file unloads", function()
			gs.env.state.Weapons:set("Naegling")
			gs.env.status_change("Engaged", "Idle")

			gs.env.file_unload("RDM.lua")

			assert.are.same({}, gs.disabled)
		end)
	end)

	describe("customize hooks", function()
		it("lets job_customize_idle_set change the idle set wherever it goes on", function()
			gs.env.job_customize_idle_set = function(idleSet)
				return { body = idleSet.body, feet = "Kiting Feet" }
			end
			sets.idle = { body = "Idle Body", feet = "Idle Feet" }

			gs.env.status_change("Idle", "Engaged")
			local afterStatusChange = gs:worn()
			gs:reset()
			gs.env.self_command("cycle OffenseMode")

			assert.are.same({ body = "Idle Body", feet = "Kiting Feet" }, afterStatusChange)
			assert.are.same({ body = "Idle Body", feet = "Kiting Feet" }, gs:worn())
		end)

		it("lets job_customize_melee_set change the engaged set", function()
			gs.env.job_customize_melee_set = function(meleeSet)
				return { body = meleeSet.body, feet = "Custom Feet" }
			end
			sets.engaged = { body = "Engaged Body", feet = "Engaged Feet" }

			gs.env.status_change("Engaged", "Idle")

			assert.are.same({ body = "Engaged Body", feet = "Custom Feet" }, gs:worn())
		end)
	end)

	describe("pets", function()
		local flaming_crush = ability("Flaming Crush", "BloodPactRage")

		it("puts the pet set on at the aftercast of your own pet command instead of idle gear", function()
			sets.midcast.Pet.BloodPactRage = { body = "Blood Pact Body" }
			sets.idle = { head = "Idle Head", body = "Idle Body" }

			gs.env.aftercast(flaming_crush)

			assert.are.same({ body = "Blood Pact Body" }, gs:worn())
		end)

		it("treats Blood Pact: Ward and BST Ready moves as pet commands too", function()
			sets.midcast.Pet.BloodPactWard = { body = "Ward Body" }
			sets.midcast.Pet.Monster = { body = "Ready Body" }
			sets.idle = { body = "Idle Body" }

			gs.env.aftercast(ability("Crimson Howl", "BloodPactWard"))
			local ward = gs:worn()
			gs:reset()
			gs.env.aftercast(ability("Foot Kick", "Monster"))

			assert.are.same({ body = "Ward Body" }, ward)
			assert.are.same({ body = "Ready Body" }, gs:worn())
		end)

		it("equips nothing for a pet move when the user file replaced sets.midcast without a Pet table", function()
			sets.midcast = { FastRecast = { head = "Fast Recast Head" } }

			gs.env.aftercast(flaming_crush)
			gs.env.pet_midcast(flaming_crush)

			assert.are.same({}, gs:worn())
		end)

		it("returns to idle gear when your pet command was interrupted", function()
			sets.midcast.Pet.BloodPactRage = { body = "Blood Pact Body" }
			sets.idle = { body = "Idle Body" }
			local interrupted = ability("Flaming Crush", "BloodPactRage")
			interrupted.interrupted = true

			gs.env.aftercast(interrupted)

			assert.are.same({ body = "Idle Body" }, gs:worn())
		end)

		it("puts the pet set on when the pet readies a move, as for moves it starts itself", function()
			sets.midcast.Pet["Healing Breath IV"] = { head = "Breath Head" }

			gs.env.pet_midcast(ability("Healing Breath IV", "Monster"))

			assert.are.same({ head = "Breath Head" }, gs:worn())
		end)

		it("returns to idle or engaged gear once the pet move is done", function()
			-- GearSwap still reports the pet's move as in progress while pet_aftercast runs.
			gs.pet_in_action = true
			gs.env.player.status = "Engaged"
			sets.engaged = { body = "Engaged Body" }

			gs.env.pet_aftercast(flaming_crush)

			assert.are.same({ body = "Engaged Body" }, gs:worn())
		end)

		it("leaves your own action's gear alone when the pet finishes mid-action", function()
			gs.in_action = true
			sets.idle = { body = "Idle Body" }

			gs.env.pet_aftercast(flaming_crush)

			assert.are.same({}, gs:worn())
		end)

		it("puts a pending pet move's set back on after your own action", function()
			local breath = ability("Healing Breath IV", "Monster")
			local savage_blade = weapon_skill("Savage Blade")
			sets.midcast.Pet["Healing Breath IV"] = { head = "Breath Head" }
			sets.precast.WS["Savage Blade"] = { head = "Savage Blade Head" }
			gs.env.pet_midcast(breath)
			gs.pet_in_action = breath

			gs.env.precast(savage_blade)
			gs.env.aftercast(savage_blade)

			assert.are.same({ head = "Breath Head" }, gs:worn())
		end)

		it("keeps the pet's gear on while its move is pending", function()
			gs.pet_in_action = true
			sets.idle = { body = "Idle Body" }
			gs.env.state.OffenseMode:options("Normal", "Acc")

			gs.env.aftercast(frazzle_ii)
			gs.env.status_change("Idle", "Engaged")
			gs.env.self_command("cycle OffenseMode")

			assert.are.same({}, gs:worn())
			assert.are.equal("Acc", gs.env.state.OffenseMode.current)
		end)
	end)

	describe("autows", function()
		before_each(function()
			gs.env.state.Weapons:options("Almace", "Naegling", "Club")
			gs.env.autows_list = {
				Almace = { { "Savage Blade", 1000 }, { "Chant du Cygne", "AM3" } },
				Naegling = { { "Savage Blade", 2000 } },
			}
		end)

		local function cycled_values(times)
			local values = {}
			for _ = 1, times do
				gs.env.self_command("cycle AutoWSMode")
				values[#values + 1] = gs.env.state.AutoWSMode.value
			end
			return values
		end

		it("cycles AutoWSMode through Off and the options for the chosen weapon", function()
			assert.are.same({ "Savage Blade 1000", "Chant du Cygne AM3", "Off" }, cycled_values(3))
		end)

		it("picks up an autows_list defined after load for the weapon selected at load", function()
			gs.env.state.Weapons:options("None", "Naegling")
			gs.env.autows_list = { None = { { "Victory Smite", 1000 } } }

			assert.are.same({ "Victory Smite 1000", "Off" }, cycled_values(2))
		end)

		it("picks up an autows_list replaced after the options were built", function()
			cycled_values(1)
			gs.env.autows_list = { Almace = { { "Chant du Cygne", 1000 } } }

			assert.are.same({ "Chant du Cygne 1000", "Off" }, cycled_values(2))
		end)

		it("offers only Off for a weapon without an autows_list entry", function()
			gs.env.state.Weapons:set("Club")

			assert.are.same({ "Off", "Off" }, cycled_values(2))
		end)

		it("turns AutoWS off and switches to the new weapon's options when Weapons changes", function()
			gs.env.self_command("cycle AutoWSMode")

			gs.env.self_command("set Weapons Naegling")
			local afterChange = gs.env.state.AutoWSMode.value

			assert.are.equal("Off", afterChange)
			assert.are.same({ "Savage Blade 2000", "Off" }, cycled_values(2))
		end)

		it("uses the chosen weapon skill once TP reaches its threshold while engaged", function()
			gs.env.self_command("cycle AutoWSMode")
			gs.env.player.status = "Engaged"

			gs:fire("tp change", 950, 700)
			gs:fire("tp change", 1150, 950)

			assert.are.same({ 'input /ws "Savage Blade" <t>' }, gs.commands)
		end)

		it("waits out the pause after your last action, as Sel does", function()
			gs.env.self_command("cycle AutoWSMode")
			gs.env.player.status = "Engaged"
			gs.env.aftercast(magic("Phalanx", "Enhancing Magic", "WhiteMagic"))

			gs.clock = 2.3
			gs:fire("tp change", 1050, 950)
			local duringPause = gs.commands
			gs.commands = {}
			gs.clock = 2.5
			gs:fire("tp change", 1150, 1050)

			assert.are.same({}, duringPause)
			assert.are.same({ 'input /ws "Savage Blade" <t>' }, gs.commands)
		end)

		it("does nothing while not engaged or with AutoWSMode Off", function()
			gs:fire("tp change", 1500, 900)
			gs.env.player.status = "Engaged"
			gs:fire("tp change", 1600, 1500)
			gs.env.self_command("cycle AutoWSMode")
			gs.env.player.status = "Idle"
			gs:fire("tp change", 1700, 1600)

			assert.are.same({}, gs.commands)
		end)

		it("waits for 3000 TP on an AM3 option until Aftermath: Lv.3 is up, then uses it at 1000", function()
			gs.env.self_command("set AutoWSMode Chant du Cygne AM3")
			gs.env.player.status = "Engaged"

			gs:fire("tp change", 2900, 2500)
			gs:fire("tp change", 3000, 2900)
			gs.env.buffactive = { ["aftermath: lv.3"] = 1 }
			gs:fire("tp change", 1000, 900)

			assert.are.same({ 'input /ws "Chant du Cygne" <t>', 'input /ws "Chant du Cygne" <t>' }, gs.commands)
		end)

		it("counts a higher Aftermath level as satisfying an AM2 option", function()
			gs.env.autows_list.Almace = { { "Chant du Cygne", "AM2" } }
			gs.env.self_command("cycle AutoWSMode")
			gs.env.player.status = "Engaged"

			gs:fire("tp change", 1900, 1500)
			gs.env.buffactive = { ["aftermath: lv.3"] = 1 }
			gs:fire("tp change", 1000, 900)

			assert.are.same({ 'input /ws "Chant du Cygne" <t>' }, gs.commands)
		end)

		it("leaves out autows_list entries missing the weapon skill or TP", function()
			gs.env.autows_list.Almace = { { "Savage Blade" }, { nil, 1000 }, { "Chant du Cygne", 1000 } }

			assert.are.same({ "Chant du Cygne 1000", "Off" }, cycled_values(2))
		end)

		it("never uses an option whose TP is not a number, AM2 or AM3", function()
			gs.env.autows_list.Almace = { { "Savage Blade", "AM1" } }
			gs.env.self_command("cycle AutoWSMode")
			gs.env.player.status = "Engaged"

			gs:fire("tp change", 3000, 2900)

			assert.are.same({}, gs.commands)
		end)

		it("sends nothing when the weapon skill is known to be impossible, as under Amnesia", function()
			gs.env.self_command("cycle AutoWSMode")
			gs.env.player.status = "Engaged"
			gs.env.buffactive = { amnesia = 1 }

			gs:fire("tp change", 1500, 900)

			assert.are.same({}, gs.commands)
		end)

		it("holds off while another action is in flight", function()
			gs.env.self_command("cycle AutoWSMode")
			gs.env.player.status = "Engaged"
			gs.in_action = true

			gs:fire("tp change", 1500, 900)

			assert.are.same({}, gs.commands)
		end)
	end)

	describe("ws buffs", function()
		local savage_blade = weapon_skill("Savage Blade")

		before_each(function()
			sets.precast.WS["Savage Blade"] = { head = "Savage Blade Head" }
		end)

		local function as_drk()
			gs.env.player.main_job = "DRK"
			gs.ability_recasts = { [87] = 0 }
		end

		-- Presses the weapon skill and lets any buff, re-fire and the weapon skill itself resolve.
		local function press()
			gs.commands = {}
			gs.env.precast(savage_blade)
			gs:run_scheduled()
			gs.env.aftercast(savage_blade)
			return gs.commands[1]
		end

		it("uses one buff per weapon skill: Last Resort, Berserk, Warcry, Aggressor, skipping active ones", function()
			gs.env.player.main_job, gs.env.player.sub_job = "WAR", "DRK"
			gs.ability_recasts = { [87] = 0, [1] = 0, [2] = 0, [4] = 0 }
			local used = {}

			for _, buff in ipairs({ "last resort", "berserk", "warcry", "aggressor" }) do
				used[#used + 1] = press()
				gs.env.buffactive[buff] = 1
			end
			used[#used + 1] = press() or "weapon skill"

			assert.are.same({
				'input /ja "Last Resort" <me>',
				'input /ja "Berserk" <me>',
				'input /ja "Warcry" <me>',
				'input /ja "Aggressor" <me>',
				"weapon skill",
			}, used)
		end)

		it("skips a main job's buff below the level that unlocks it", function()
			as_drk()
			gs.env.player.sub_job = "WAR"
			gs.ability_recasts = { [87] = 0, [1] = 0 }
			local results = {}

			for _, level in ipairs({ 14, 15 }) do
				gs.env.player.main_job_level = level
				results[#results + 1] = press()
			end

			assert.are.same({ 'input /ja "Berserk" <me>', 'input /ja "Last Resort" <me>' }, results)
		end)

		it("skips buffs on recast, not yet unlocked, or from a restricted sub job", function()
			local results = {}
			local ready = { [87] = 0, [1] = 0, [2] = 0, [4] = 0 }

			for _, case in ipairs({
				{ main = "RDM", sub = "WAR", subLevel = 49, recasts = { [1] = 30, [2] = 0, [4] = 0 } },
				{ main = "RDM", sub = "WAR", subLevel = 30, recasts = ready, buffs = { berserk = 1 } },
				{ main = "RDM", sub = "WAR", subLevel = 49, recasts = ready, buffs = { ["sj restriction"] = 1 } },
				{ main = "WAR", sub = "NIN", subLevel = 49, recasts = ready, buffs = { ["sj restriction"] = 1 } },
			}) do
				gs.env.player.main_job, gs.env.player.sub_job = case.main, case.sub
				gs.env.player.sub_job_level = case.subLevel
				gs.ability_recasts = case.recasts
				gs.env.buffactive = case.buffs or {}
				results[#results + 1] = press() or "weapon skill"
			end

			assert.are.same({
				'input /ja "Warcry" <me>',
				"weapon skill",
				"weapon skill",
				'input /ja "Berserk" <me>',
			}, results)
		end)

		it("skips Berserk while Defender is up, since each cancels the other", function()
			gs.env.player.main_job = "WAR"
			gs.ability_recasts = { [1] = 0, [2] = 0, [4] = 0 }
			gs.env.buffactive = { defender = 1 }

			assert.are.equal('input /ja "Warcry" <me>', press())
		end)

		it("goes straight to the weapon skill with AutoWSBuff off", function()
			as_drk()
			gs.env.self_command("set AutoWSBuff off")
			gs:reset()

			gs.env.precast(savage_blade)

			assert.is_false(gs.cancelled)
			assert.are.same({ head = "Savage Blade Head" }, gs:worn())
			assert.are.same({}, gs.commands)
		end)

		it("spends no buff on a weapon skill that can't happen", function()
			as_drk()
			gs.env.player.tp = 900

			gs.env.precast(savage_blade)

			assert.is_true(gs.cancelled)
			assert.are.same({}, gs.commands)
		end)

		it("uses a ready buff instead, then re-fires the weapon skill 1.1s later", function()
			as_drk()

			gs.env.precast(savage_blade)

			assert.is_true(gs.cancelled)
			assert.are.same({}, gs:worn())
			assert.are.same({ 'input /ja "Last Resort" <me>' }, gs.commands)
			assert.are.equal(1.1, gs.scheduled[1].delay)
			gs:run_scheduled()
			assert.are.same({ 'input /ja "Last Resort" <me>', 'input /ws "Savage Blade" <t>' }, gs.commands)
		end)

		it("holds auto buffs until the weapon skill its buff went ahead of goes off", function()
			as_drk()
			gs.env.buff_spell_lists = {
				Melee = { { Name = "Haste II", Buff = "Haste", SpellID = 511, When = "Always" } },
			}
			gs.spell_resources[511] = { id = 511, en = "Haste II", english = "Haste II", recast_id = 511 }
			gs.env.self_command("set AutoBuffMode Melee")
			local cast = {}
			local function buff_check_at(clock)
				gs.clock = clock
				gs.commands = {}
				gs:fire("prerender")
				cast[#cast + 1] = gs.commands[1] or "nothing"
			end

			gs.env.precast(savage_blade)
			gs.clock = 0.5
			gs.env.aftercast(ability("Last Resort", "JobAbility"))
			buff_check_at(0.9)
			gs:run_scheduled()
			gs.env.precast(savage_blade)
			gs.env.aftercast(savage_blade)
			buff_check_at(4)

			assert.are.same({ "nothing", 'input /ma "Haste II" <me>' }, cast)
		end)

		it("drops spammed presses while a buff and its re-fire are pending", function()
			as_drk()
			gs.env.precast(savage_blade)
			gs.cancelled = false

			gs.env.precast(savage_blade)

			assert.is_true(gs.cancelled)
			assert.are.same({ 'input /ja "Last Resort" <me>' }, gs.commands)
			assert.are.equal(1, #gs.scheduled)
		end)

		it("releases the lock once the weapon skill resolves", function()
			as_drk()
			gs.env.precast(savage_blade)
			gs:run_scheduled()
			gs.env.precast(savage_blade)
			gs.env.aftercast(savage_blade)
			gs.commands = {}

			gs.env.precast(savage_blade)

			assert.are.same({ 'input /ja "Last Resort" <me>' }, gs.commands)
		end)

		it("treats a press as fresh once 5s pass without the weapon skill resolving", function()
			as_drk()
			gs.env.precast(savage_blade)
			gs:run_scheduled()
			gs.clock = 5
			gs.commands = {}

			gs.env.precast(savage_blade)

			assert.are.same({ 'input /ja "Last Resort" <me>' }, gs.commands)
		end)

		it("lets its own re-fired weapon skill through", function()
			as_drk()
			gs.env.precast(savage_blade)
			gs:run_scheduled()
			gs.cancelled = false
			gs.commands = {}

			gs.env.precast(savage_blade)

			assert.is_false(gs.cancelled)
			assert.are.same({ head = "Savage Blade Head" }, gs:worn())
			assert.are.same({}, gs.commands)
		end)
	end)

	describe("spell maps", function()
		-- Core's own map for the spell: what it hands job_get_spell_map as the default.
		local function map_of(spell)
			local seen
			gs.env.job_get_spell_map = function(_, defaultMap)
				seen = defaultMap
			end
			gs.env.midcast(spell)
			return seen
		end

		it("maps Cure spells by light weather or day, Afflatus Solace and the weapon lock", function()
			local cure = magic("Cure III", "Healing Magic", "WhiteMagic")
			local maps = { map_of(cure) }

			gs.env.world.day_element = "Light"
			maps[#maps + 1] = map_of(cure)
			gs.env.world.weather_element = "Light"
			maps[#maps + 1] = map_of(cure)
			gs.env.buffactive["afflatus solace"] = 1
			maps[#maps + 1] = map_of(cure)
			gs.env.state.Weapons:options("None", "Naegling")
			gs.env.state.Weapons:set("Naegling")
			gs.env.player.status = "Engaged"
			maps[#maps + 1] = map_of(cure)

			assert.are.same({
				"Cure",
				"LightDayCure",
				"LightWeatherCure",
				"LightWeatherCureSolace",
				"MeleeLightWeatherCureSolace",
			}, maps)
		end)

		it("maps Curaga spells by light weather or day only", function()
			local curaga = magic("Curaga II", "Healing Magic", "WhiteMagic")
			local maps = { map_of(curaga) }

			gs.env.world.day_element = "Light"
			maps[#maps + 1] = map_of(curaga)
			gs.env.world.weather_element = "Light"
			gs.env.buffactive["afflatus solace"] = 1
			gs.env.state.Weapons:options("None", "Naegling")
			gs.env.state.Weapons:set("Naegling")
			gs.env.player.status = "Engaged"
			maps[#maps + 1] = map_of(curaga)

			assert.are.same({ "Curaga", "LightDayCuraga", "LightWeatherCuraga" }, maps)
		end)

		it("maps nukes by tier, leaving enfeebles, helixes and Occult casting alone", function()
			local function elemental(english)
				return map_of(magic(english, "Elemental Magic", "BlackMagic")) or "none"
			end
			local maps = { elemental("Stone II"), elemental("Thunder VI"), elemental("Burn"), elemental("Pyrohelix") }

			gs.env.state.CastingMode:options("Normal", "OccultAcumen")
			gs.env.state.CastingMode:set("OccultAcumen")
			maps[#maps + 1] = elemental("Thunder VI")

			assert.are.same({ "LowTierNuke", "HighTierNuke", "ElementalEnfeeble", "Helix", "none" }, maps)
		end)

		it("maps blue magic to Sel's categories, the first listed winning for a spell listed twice", function()
			local function blue(english)
				return map_of(magic(english, "Blue Magic", "BlueMagic")) or "none"
			end

			assert.are.same({ "PhysicalStr", "Magical", "Buff", "Physical", "MagicalMnd", "none" }, {
				blue("Sinker Drill"),
				blue("Tenebral Crush"),
				blue("Mighty Guard"),
				blue("Bilgestorm"),
				blue("Mind Blast"),
				blue("Not A Spell"),
			})
		end)

		it("maps ninjutsu without a map of its own by target: NinjutsuBuff or NinjutsuDebuff", function()
			local function ninjutsu(english, targetType)
				local spell = magic(english, "Ninjutsu", "Ninjutsu")
				spell.target = { type = targetType }
				return map_of(spell) or "none"
			end

			assert.are.same({ "NinjutsuBuff", "NinjutsuDebuff", "Utsusemi" }, {
				ninjutsu("Kakka: Ichi", "SELF"),
				ninjutsu("Kurayami: Ni", "MONSTER"),
				ninjutsu("Utsusemi: Ni", "SELF"),
			})
		end)

		it("maps Blood Pacts: Rage by magical or physical, Ward by whether it targets a monster", function()
			local function pact(english, pactType, targetType)
				local spell = ability(english, pactType)
				spell.target = { type = targetType }
				return map_of(spell) or "none"
			end

			assert.are.same(
				{ "MagicalBloodPactRage", "PhysicalBloodPactRage", "DebuffBloodPactWard", "BloodPactWard" },
				{
					pact("Flaming Crush", "BloodPactRage", "MONSTER"),
					pact("Predator Claws", "BloodPactRage", "MONSTER"),
					pact("Lunar Cry", "BloodPactWard", "MONSTER"),
					pact("Crimson Howl", "BloodPactWard", "SELF"),
				}
			)
		end)

		it("maps Indi- geomancy spells to Indi", function()
			assert.are.same({ "Indi", "none" }, {
				map_of(magic("Indi-Fury", "Geomancy", "Geomancy")) or "none",
				map_of(magic("Geo-Frailty", "Geomancy", "Geomancy")) or "none",
			})
		end)

		it("falls back from a Cure map with no set of its own straight to the Cure set, as Sel does", function()
			local cure = magic("Cure III", "Healing Magic", "WhiteMagic")
			sets.midcast.Cure = { body = "Cure Body" }
			sets.midcast.CureSolace = { body = "Cure Solace Body" }
			sets.midcast.LightWeatherCure = { body = "Light Weather Cure Body" }
			gs.env.buffactive["afflatus solace"] = 1
			gs.env.world.weather_element = "Light"

			gs.env.midcast(cure)

			assert.are.same({ body = "Cure Body" }, gs:worn())
		end)

		it("falls back from a Curaga variant to the Curaga set before the Cure set", function()
			gs.env.world.weather_element = "Light"
			sets.midcast.Curaga = { body = "Curaga Body" }
			sets.midcast.Cure = { body = "Cure Body" }

			gs.env.midcast(magic("Curaga II", "Healing Magic", "WhiteMagic"))

			assert.are.same({ body = "Curaga Body" }, gs:worn())
		end)
	end)

	describe("auto buffs", function()
		before_each(function()
			gs.env.buff_spell_lists = {
				Melee = {
					{ Name = "Haste II", Buff = "Haste", SpellID = 511, When = "Always" },
					{ Name = "Refresh III", Buff = "Refresh", SpellID = 894, When = "Always" },
				},
				Mage = {
					{ Name = "Stoneskin", Buff = "Stoneskin", SpellID = 54, When = "Always" },
				},
			}
			for id, name in pairs({ [511] = "Haste II", [894] = "Refresh III", [54] = "Stoneskin" }) do
				gs.spell_resources[id] = { id = id, en = name, english = name, recast_id = id }
			end
		end)

		-- One prerender, then advances the clock past the 0.5s tick interval.
		local function tick()
			gs:fire("prerender")
			gs.clock = gs.clock + 0.5
		end

		it("checks twice a second, not every frame", function()
			gs.env.self_command("set AutoBuffMode Melee")

			for _, clock in ipairs({ 0, 0, 0.49, 0.5 }) do
				gs.clock = clock
				gs:fire("prerender")
			end

			assert.are.same({ 'input /ma "Haste II" <me>', 'input /ma "Haste II" <me>' }, gs.commands)
		end)

		it("refreshes GearSwap's globals before checking, since raw events don't", function()
			gs.env.self_command("set AutoBuffMode Melee")
			gs.on_refresh = function()
				gs.env.buffactive = { haste = 1 }
			end

			tick()

			assert.are.same({ 'input /ma "Refresh III" <me>' }, gs.commands)
		end)

		it("starts Off, casting nothing, and cycles through Off and the list names alphabetically", function()
			tick()
			local values = { gs.env.state.AutoBuffMode.value }

			for _ = 1, 3 do
				gs.env.self_command("cycle AutoBuffMode")
				values[#values + 1] = gs.env.state.AutoBuffMode.value
			end

			assert.are.same({}, gs.commands)
			assert.are.same({ "Off", "Mage", "Melee", "Off" }, values)
		end)

		it("casts the first buff from the selected list that isn't up", function()
			gs.env.self_command("set AutoBuffMode Melee")

			tick()

			assert.are.same({ 'input /ma "Haste II" <me>' }, gs.commands)
		end)

		it("picks up buff_spell_lists replaced after the options were built", function()
			gs.env.self_command("set AutoBuffMode Melee")
			gs.env.buff_spell_lists = { Tank = {} }

			gs.env.self_command("set AutoBuffMode Tank")

			assert.are.equal("Tank", gs.env.state.AutoBuffMode.value)
		end)

		it("skips entries missing Name, Buff or SpellID", function()
			gs.env.buff_spell_lists = {
				Test = {
					{ Buff = "Haste", SpellID = 511 },
					{ Name = "Refresh III", SpellID = 894 },
					{ Name = "Haste II", Buff = "Haste" },
					{ Name = "Stoneskin", Buff = "Stoneskin", SpellID = 54 },
				},
			}
			gs.env.self_command("set AutoBuffMode Test")

			tick()

			assert.are.same({ 'input /ma "Stoneskin" <me>' }, gs.commands)
		end)

		it("skips buffs you don't have the MP for", function()
			gs.spell_resources[894].mp_cost = 60
			gs.env.self_command("set AutoBuffMode Melee")
			gs.env.buffactive = { haste = 1 }
			gs.env.player.mp = 50

			tick()

			assert.are.same({}, gs.commands)
		end)

		it("holds off while moving, just after an action, in a city or while invisible", function()
			gs.env.self_command("set AutoBuffMode Melee")
			local cast = {}
			local function next_cast()
				gs.commands = {}
				tick()
				cast[#cast + 1] = gs.commands[1] and "cast" or "held"
			end

			next_cast()
			gs.mobs.me = { x = 5, y = 0, z = 0 }
			next_cast()
			next_cast()
			gs.env.aftercast(magic("Protect V", "Enhancing Magic", "WhiteMagic"))
			next_cast()
			gs.clock = gs.clock + 2.5
			next_cast()
			gs.env.world.area = "Port Jeuno"
			next_cast()
			gs.env.world.area = "La Theine Plateau"
			gs.env.buffactive = { invisible = 1 }
			next_cast()

			assert.are.same({ "cast", "held", "cast", "held", "cast", "held", "held" }, cast)
		end)

		it("notices movement along any axis", function()
			gs.env.self_command("set AutoBuffMode Melee")
			local cast = {}
			local function next_cast()
				gs.commands = {}
				tick()
				cast[#cast + 1] = gs.commands[1] and "cast" or "held"
			end

			next_cast()
			for _, position in ipairs({ { x = 5, y = 0, z = 0 }, { x = 5, y = 5, z = 0 }, { x = 5, y = 5, z = 5 } }) do
				gs.mobs.me = position
				next_cast()
				next_cast()
			end

			assert.are.same({ "cast", "held", "cast", "held", "cast", "held", "cast" }, cast)
		end)

		it("waits as long as Sel does after each kind of action", function()
			gs.env.self_command("set AutoBuffMode Melee")
			local target = { type = "SELF" }
			local function interrupted(action, prefix)
				action.interrupted = true
				action.prefix = prefix
				return action
			end
			-- Whether a buff goes out this many seconds after the action.
			local function casts_after(action, seconds)
				gs.clock = gs.clock + 10
				gs.env.aftercast(action)
				gs.clock = gs.clock + seconds
				gs.commands = {}
				gs:fire("prerender")
				return gs.commands[1] ~= nil
			end
			local function waits(action, seconds)
				return not casts_after(action, seconds - 0.01) and casts_after(action, seconds + 0.01)
			end

			assert.is_true(waits(magic("Protect V", "Enhancing Magic", "WhiteMagic"), 2.4), "spell")
			assert.is_true(waits(weapon_skill("Savage Blade"), 2.2), "weapon skill")
			assert.is_true(waits(ability("Provoke", "JobAbility"), 0.3), "ability")
			assert.is_true(
				waits({ english = "Echo Drops", action_type = "Item", type = "Item", target = target }, 1),
				"item"
			)
			assert.is_true(
				waits({ english = "Ranged", action_type = "Ranged Attack", type = "Misc", target = target }, 0.35),
				"ranged attack"
			)
			assert.is_true(
				waits(interrupted(magic("Stun", "Dark Magic", "BlackMagic"), "/magic"), 1.25),
				"interrupted spell"
			)
			assert.is_true(
				casts_after(interrupted(ability("Provoke", "JobAbility"), "/jobability"), 0),
				"interrupted ability"
			)
		end)

		it("skips buffs it can't cast right now: on recast, not castable, or while silenced", function()
			gs.env.self_command("set AutoBuffMode Melee")
			local cast = {}
			local function next_cast()
				gs.commands = {}
				tick()
				cast[#cast + 1] = gs.commands[1] or "nothing"
			end

			gs.spell_recasts = { [511] = 30 }
			next_cast()
			gs.spell_recasts = {}
			gs.castable = false
			next_cast()
			gs.castable = true
			gs.env.buffactive = { silence = 1 }
			next_cast()

			assert.are.same({ 'input /ma "Refresh III" <me>', "nothing", "nothing" }, cast)
		end)

		it("casts only buffs whose When matches: Always, Engaged, Idle, Combat, OutOfCombat", function()
			gs.spell_resources[55] = { id = 55, en = "Aquaveil", english = "Aquaveil", recast_id = 55 }
			gs.env.buff_spell_lists = {
				Test = {
					{ Name = "Haste II", Buff = "Haste", SpellID = 511, When = "Engaged" },
					{ Name = "Aquaveil", Buff = "Aquaveil", SpellID = 55, When = "Idle" },
					{ Name = "Refresh III", Buff = "Refresh", SpellID = 894, When = "Combat" },
					{ Name = "Stoneskin", Buff = "Stoneskin", SpellID = 54, When = "OutOfCombat" },
				},
			}
			gs.env.self_command("set AutoBuffMode Test")
			local cast = {}
			local function next_cast()
				gs.commands = {}
				tick()
				cast[#cast + 1] = gs.commands[1] or "nothing"
			end

			next_cast()
			gs.env.buffactive = { aquaveil = 1 }
			next_cast()
			gs.env.player.status = "Engaged"
			next_cast()
			gs.env.buffactive = { aquaveil = 1, haste = 1 }
			gs.env.aftercast({
				english = "Dia II",
				action_type = "Magic",
				type = "WhiteMagic",
				target = { type = "MONSTER", hpp = 50 },
			})
			gs.clock = gs.clock + 3
			next_cast()

			assert.are.same({
				'input /ma "Aquaveil" <me>',
				'input /ma "Stoneskin" <me>',
				'input /ma "Haste II" <me>',
				'input /ma "Refresh III" <me>',
			}, cast)
		end)

		it("leaves combat 6s after your last action on a monster, once your battle target is gone", function()
			gs.env.buff_spell_lists = {
				Test = {
					{ Name = "Refresh III", Buff = "Refresh", SpellID = 894, When = "Combat" },
					{ Name = "Stoneskin", Buff = "Stoneskin", SpellID = 54, When = "OutOfCombat" },
				},
			}
			gs.env.self_command("set AutoBuffMode Test")
			gs.mobs.bt = { hpp = 40 }
			gs.env.aftercast({
				english = "Dia II",
				action_type = "Magic",
				type = "WhiteMagic",
				target = { type = "MONSTER", hpp = 50 },
			})
			local cast = {}
			local function cast_at(clock)
				gs.clock = clock
				gs.commands = {}
				tick()
				cast[#cast + 1] = gs.commands[1] or "nothing"
			end

			cast_at(3)
			cast_at(7)
			gs.mobs.bt = { hpp = 0 }
			cast_at(8)

			assert.are.same({
				'input /ma "Refresh III" <me>',
				'input /ma "Refresh III" <me>',
				'input /ma "Stoneskin" <me>',
			}, cast)
		end)

		it("enters combat only on an uninterrupted action against a live monster", function()
			gs.env.buff_spell_lists = {
				Test = { { Name = "Refresh III", Buff = "Refresh", SpellID = 894, When = "Combat" } },
			}
			gs.env.self_command("set AutoBuffMode Test")
			local cast = {}
			local function cast_after(interrupted, hpp)
				gs.env.aftercast({
					english = "Dia II",
					action_type = "Magic",
					type = "WhiteMagic",
					interrupted = interrupted,
					target = { type = "MONSTER", hpp = hpp },
				})
				gs.clock = gs.clock + 3
				gs.commands = {}
				tick()
				cast[#cast + 1] = gs.commands[1] and "cast" or "nothing"
			end

			cast_after(true, 50)
			cast_after(false, 0)
			cast_after(false, 50)

			assert.are.same({ "nothing", "nothing", "cast" }, cast)
		end)
	end)

	describe("auto th", function()
		before_each(function()
			gs.env.autoth_list = { "Provoke", "Dia II", "Box Step" }
			sets.TreasureHunter = { waist = "TH Belt" }
		end)

		it("layers the TH set over the first listed action's precast set by default", function()
			sets.precast.JA.Provoke = { body = "Provoke Body" }

			gs.env.precast(ability("Provoke", "JobAbility"))

			assert.are.same({ body = "Provoke Body", waist = "TH Belt" }, gs:worn())
		end)

		it("layers the TH set over a selected spell at midcast, not precast", function()
			local dia = magic("Dia II", "Enfeebling Magic", "WhiteMagic")
			sets.precast.FC = { head = "FC Head" }
			sets.midcast["Dia II"] = { body = "Dia Body" }
			gs.env.self_command("set AutoTHMode Dia II")
			gs:reset()

			gs.env.precast(dia)
			local precastWorn = gs:worn()
			gs:reset()
			gs.env.midcast(dia)

			assert.are.same({ head = "FC Head" }, precastWorn)
			assert.are.same({ body = "Dia Body", waist = "TH Belt" }, gs:worn())
		end)

		it("layers the TH set over a selected ranged attack at midcast, not precast", function()
			gs.env.autoth_list = { "Ranged" }
			sets.precast.RA = { head = "Snapshot Head" }
			sets.midcast.RA = { body = "RA Body" }

			gs.env.precast(ranged_attack)
			local precastWorn = gs:worn()
			gs:reset()
			gs.env.midcast(ranged_attack)

			assert.are.same({ head = "Snapshot Head" }, precastWorn)
			assert.are.same({ body = "RA Body", waist = "TH Belt" }, gs:worn())
		end)

		it("picks up an autoth_list replaced after the options were built", function()
			sets.precast.JA["Box Step"] = { body = "Box Step Body" }
			gs.env.precast(ability("Provoke", "JobAbility"))
			gs.env.autoth_list = { "Box Step" }
			gs:reset()

			gs.env.precast(ability("Box Step", "Step"))

			assert.are.same({ body = "Box Step Body", waist = "TH Belt" }, gs:worn())
		end)

		it("cycles AutoTHMode through the listed actions then Off, and only the selected one gets TH gear", function()
			sets.precast.JA.Provoke = { body = "Provoke Body" }
			sets.precast.JA["Box Step"] = { body = "Box Step Body" }
			gs.env.precast(ability("Box Step", "Step"))
			local unselected = gs:worn()
			local values = {}

			for _ = 1, 3 do
				gs.env.self_command("cycle AutoTHMode")
				values[#values + 1] = gs.env.state.AutoTHMode.value
			end
			gs:reset()
			gs.env.precast(ability("Provoke", "JobAbility"))

			assert.are.same({ body = "Box Step Body" }, unselected)
			assert.are.same({ "Dia II", "Box Step", "Off" }, values)
			assert.are.same({ body = "Provoke Body" }, gs:worn())
		end)
	end)

	describe("hud", function()
		-- The HUD line with Windower's color codes removed.
		local function hud_words()
			return (gs.hud.content:gsub("\\cs%(%d+,%d+,%d+%)", ""):gsub("^%s+", ""):gsub("%s+$", ""))
		end

		it("shows Sel's mode line at Sel's bottom-left spot, draggable", function()
			assert.is_true(gs.hud:visible())
			assert.is_true(gs.hud.settings.flags.draggable)
			assert.are.same({ 3, 1062 }, { gs.hud:pos() })
			assert.are.equal(
				"Auto WS Buff    Weapons: None    Offense: Normal / Normal    Casting: Normal",
				hud_words()
			)
		end)

		it("updates as soon as a command changes a mode, in yellow once off its first option", function()
			gs.env.state.OffenseMode:options("Normal", "Acc")

			gs.env.self_command("cycle OffenseMode")

			assert.are.equal("Auto WS Buff    Weapons: None    Offense: Acc / Normal    Casting: Normal", hud_words())
			assert.truthy(gs.hud.content:find("Offense: \\cs(255,192,0)Acc", 1, true))
		end)

		it("adds Auto WS, Auto Buff, Idle and Auto TH once they're on", function()
			gs.env.state.Weapons:options("None", "Naegling")
			gs.env.state.IdleMode:options("Normal", "DT")
			gs.env.autows_list = { Naegling = { { "Savage Blade", 1000 } } }
			gs.env.buff_spell_lists = { Melee = {} }
			gs.env.autoth_list = { "Provoke" }

			gs.env.self_command("set Weapons Naegling")
			gs.env.self_command("cycle AutoWSMode")
			gs.env.self_command("set AutoBuffMode Melee")
			gs.env.self_command("set IdleMode DT")

			assert.are.equal(
				"Auto WS: Savage Blade: 1000    Auto WS Buff    Auto Buff: Melee    Weapons: Naegling    "
					.. "Offense: Normal / Normal    Idle: DT    Casting: Normal    Auto TH: Provoke",
				hud_words()
			)
		end)

		it("sits 2px from the left and 20px from the bottom on screens other than 1920x1080", function()
			local positions = {}

			for _, screen in ipairs({ { 1920, 1200 }, { 2560, 1080 } }) do
				local other = gearswap_env.new()
				other.screen = { ui_x_res = screen[1], ui_y_res = screen[2] }
				other:include("Core.lua")
				positions[#positions + 1] = { other.hud:pos() }
			end

			assert.are.same({ { 2, 1180 }, { 2, 1060 } }, positions)
		end)

		it("hides and shows with gs c hud", function()
			gs.env.self_command("hud")
			local hidden = not gs.hud:visible()
			gs.env.self_command("hud")

			assert.is_true(hidden)
			assert.is_true(gs.hud:visible())
			assert.are.same({}, gs.chat)
		end)

		it("picks up changes made without a command on the next tick", function()
			gs.env.state.CastingMode:options("Normal", "Resistant")
			gs.env.state.CastingMode:set("Resistant")

			gs:fire("prerender")

			assert.are.equal(
				"Auto WS Buff    Weapons: None    Offense: Normal / Normal    Casting: Resistant",
				hud_words()
			)
		end)
	end)

	describe("status_change", function()
		it("equips the set for the new status", function()
			sets.idle = { body = "Idle Body" }
			sets.engaged = { body = "Engaged Body" }

			gs.env.status_change("Engaged", "Idle")

			assert.are.same({ body = "Engaged Body" }, gs:worn())
		end)

		it("leaves gear alone mid-action", function()
			gs.in_action = true
			sets.engaged = { body = "Engaged Body" }

			gs.env.status_change("Engaged", "Idle")

			assert.are.same({}, gs:worn())
		end)
	end)

	describe("self_command", function()
		before_each(function()
			gs.env.state.OffenseMode:options("Normal", "Acc")
		end)

		it("cycles a mode", function()
			gs.env.self_command("cycle OffenseMode")

			assert.are.equal("Acc", gs.env.state.OffenseMode.current)
		end)

		it("cycles forward through the options", function()
			gs.env.state.OffenseMode:options("Normal", "Acc", "FullAcc")

			gs.env.self_command("cycle OffenseMode")

			assert.are.equal("Acc", gs.env.state.OffenseMode.current)
		end)

		it("sets a mode to a value", function()
			gs.env.state.CastingMode:options("Normal", "Resistant")

			gs.env.self_command("set CastingMode Resistant")

			assert.are.equal("Resistant", gs.env.state.CastingMode.current)
		end)

		it("sets a value containing spaces", function()
			gs.env.state.IdleMode:options("Normal", "Refresh", "Refresh DT")

			gs.env.self_command("set IdleMode Refresh DT")

			assert.are.equal("Refresh DT", gs.env.state.IdleMode.current)
		end)

		it("turns a boolean mode on when set without a value", function()
			gs.env.state.Kiting = gs.env.M(false, "Kiting")

			gs.env.self_command("set Kiting")

			assert.is_true(gs.env.state.Kiting.value)
		end)

		it("re-equips the status set after a mode change", function()
			gs.env.player.status = "Engaged"
			sets.engaged = { body = "Engaged Body", Acc = { body = "Acc Body" } }

			gs.env.self_command("cycle OffenseMode")

			assert.are.same({ body = "Acc Body" }, gs:worn())
		end)

		it("changes the mode but leaves gear alone mid-action", function()
			gs.in_action = true
			sets.idle = { body = "Idle Body" }

			gs.env.self_command("cycle OffenseMode")

			assert.are.equal("Acc", gs.env.state.OffenseMode.current)
			assert.are.same({}, gs:worn())
		end)

		it("reports the new value in chat", function()
			gs.env.self_command("cycle OffenseMode")

			assert.are.same({ "Offense Mode: Acc" }, gs.chat)
		end)

		it("matches mode names regardless of case", function()
			gs.env.self_command("cycle offensemode")

			assert.are.equal("Acc", gs.env.state.OffenseMode.current)
		end)

		it("still recognizes the built-in modes after a job file includes Modes.lua again", function()
			gs:include("Modes.lua")

			gs.env.self_command("cycle OffenseMode")

			assert.are.equal("Acc", gs.env.state.OffenseMode.current)
		end)

		it("names a mode without a description by its state key, whatever case was typed", function()
			gs.env.state.Weapons = gs.env.M({ "Sword", "Dagger" })

			gs.env.self_command("cycle weapons")

			assert.are.same({ "Weapons: Dagger" }, gs.chat)
		end)

		it("treats state entries that are not modes as unknown modes", function()
			gs.env.state.Buff = {}

			gs.env.self_command("cycle Buff")

			assert.are.same({ "Unknown mode: Buff" }, gs.chat)
		end)

		it("reports an unknown mode instead of erroring", function()
			sets.idle = { body = "Idle Body" }

			gs.env.self_command("cycle NoSuchMode")

			assert.are.same({ "Unknown mode: NoSuchMode" }, gs.chat)
			assert.are.same({}, gs:worn())
		end)

		it("reports an unknown value instead of erroring", function()
			gs.env.state.CastingMode:options("Normal", "Resistant")
			sets.idle = { body = "Idle Body" }

			gs.env.self_command("set CastingMode Bogus")

			assert.are.same({ "Unknown Casting Mode value: Bogus" }, gs.chat)
			assert.are.equal("Normal", gs.env.state.CastingMode.current)
			assert.are.same({}, gs:worn())
		end)

		it("reports a missing value for a list mode instead of erroring", function()
			gs.env.self_command("set CastingMode")

			assert.are.same({ "Unknown Casting Mode value: " }, gs.chat)
		end)

		it("re-equips the status set on update, except mid-action", function()
			gs.env.player.status = "Engaged"
			sets.engaged = { body = "Engaged Body" }

			gs.env.self_command("update")
			local updated = gs:worn()
			gs:reset()
			gs.in_action = true
			gs.env.self_command("update")

			assert.are.same({ body = "Engaged Body" }, updated)
			assert.are.same({}, gs:worn())
			assert.are.same({}, gs.chat)
		end)

		it("toggles on/off modes and points list modes to cycle", function()
			gs.env.self_command("toggle AutoWSBuff")
			local afterToggle = gs.env.state.AutoWSBuff.value
			gs.env.self_command("toggle autowsbuff")
			gs.env.self_command("toggle OffenseMode")
			gs.env.self_command("toggle")

			assert.is_false(afterToggle)
			assert.is_true(gs.env.state.AutoWSBuff.value)
			assert.are.same({
				"Auto WS Buff: off",
				"Auto WS Buff: on",
				"Offense Mode isn't on/off: use gs c cycle OffenseMode",
				"Usage: gs c toggle <Mode>",
			}, gs.chat)
		end)

		it("shows usage when the mode name is missing", function()
			gs.env.self_command("cycle")
			gs.env.self_command("set")

			assert.are.same({ "Usage: gs c cycle <Mode>", "Usage: gs c set <Mode> <Value>" }, gs.chat)
		end)

		it("hands other commands to job_self_command, reporting only those it doesn't handle", function()
			local received = {}
			gs.env.job_self_command = function(command)
				received[#received + 1] = command
				return command == "warp"
			end

			gs.env.self_command("warp")
			gs.env.self_command("bogus thing")

			assert.are.same({ "warp", "bogus thing" }, received)
			assert.are.same({ "Unknown command: bogus thing" }, gs.chat)
		end)

		it("reports an unknown command instead of erroring", function()
			sets.idle = { body = "Idle Body" }

			gs.env.self_command("bogus")
			gs.env.self_command("frob OffenseMode")

			assert.are.same({ "Unknown command: bogus", "Unknown command: frob OffenseMode" }, gs.chat)
			assert.are.same({}, gs:worn())
		end)
	end)
end)
