-----------------------------------------------------------------------
------ INFINITE THANKS TO KIRAZY FOR THE HELP AND DOCUMENTATION  ------
--------------- https://mods.factorio.com/user/Kirazy -----------------
-----------------------------------------------------------------------

------------------------------
---- data-final-fixes.lua ----
------------------------------

-- Bob's Logistics links the vanilla pump to bob-pump-2 as an upgrade. Some
-- 2.1 mod combinations change the vanilla pump's fast-replaceable group after
-- Bob creates its pump prototypes, which makes Factorio reject that upgrade
-- chain. Keep the Bob pumps in the same group as the vanilla pump.
if mods["boblogistics"] and data.raw.pump and data.raw.pump.pump then
	local pump_group = data.raw.pump.pump.fast_replaceable_group
	for _, name in ipairs({ "bob-pump-2", "bob-pump-3", "bob-pump-4" }) do
		local pump = data.raw.pump[name]
		if pump then
			pump.fast_replaceable_group = pump_group
		end
	end
end

-- Bob's Space Age integration moves the turbo-belt unlock to logistics-4.
-- With some overhaul mods, that replacement leaves logistics-4 depending on
-- itself, which makes Factorio report a technology cycle.
local logistics_4 = data.raw.technology and data.raw.technology["logistics-4"]
if logistics_4 and logistics_4.prerequisites then
	for i = #logistics_4.prerequisites, 1, -1 do
		if logistics_4.prerequisites[i] == "logistics-4" then
			table.remove(logistics_4.prerequisites, i)
		end
	end
end

-- When Bob's Logistics is active, keep its pipe set and remove Flow Control's
-- competing prototypes after other mods have finished their compatibility edits.
if mods["boblogistics"] then
	local removed_items = {}
	local removed_recipes = {}

	local function remove_flow_control_prototype(name)
		removed_items[name] = true
		removed_recipes[name] = true
		data.raw.recipe[name] = nil
		data.raw.item[name] = nil
		if data.raw["storage-tank"] then
			data.raw["storage-tank"][name] = nil
		end
		if data.raw.valve then
			data.raw.valve[name] = nil
		end
	end

	local shapes = { "straight", "junction", "elbow" }
	for _, shape in ipairs(shapes) do
		remove_flow_control_prototype("pipe-" .. shape)
	end

	for _, material in ipairs({
		"brass", "bronze", "copper", "ceramic", "stone", "plastic",
		"steel", "titanium", "tungsten", "copper-tungsten", "nitinol",
	}) do
		for _, shape in ipairs(shapes) do
			remove_flow_control_prototype("pipe-" .. material .. "-" .. shape)
		end
	end

	for _, name in ipairs({
		"flowbob-check-valve",
		"flowbob-overflow-valve",
		"flowbob-topup-valve-1",
		"flowbob-topup-valve-2",
	}) do
		remove_flow_control_prototype(name)
	end

	local function list_references_removed_item(list)
		for _, entry in pairs(list or {}) do
			local name = type(entry) == "table" and (entry.name or entry[1]) or entry
			if name and removed_items[name] then
				return true
			end
		end
		return false
	end

	local function recipe_references_removed_item(recipe)
		if recipe.result and removed_items[recipe.result] then
			return true
		end
		if list_references_removed_item(recipe.ingredients) or list_references_removed_item(recipe.results) then
			return true
		end
		for _, difficulty in ipairs({ "normal", "expensive" }) do
			local variant = recipe[difficulty]
			if variant and ((variant.result and removed_items[variant.result])
				or list_references_removed_item(variant.ingredients)
				or list_references_removed_item(variant.results)) then
				return true
			end
		end
		return false
	end

	for name, recipe in pairs(data.raw.recipe) do
		if recipe_references_removed_item(recipe) then
			removed_recipes[name] = true
			data.raw.recipe[name] = nil
		end
	end

	for _, technology in pairs(data.raw.technology) do
		for i = #(technology.effects or {}), 1, -1 do
			local effect = technology.effects[i]
			if effect.type == "unlock-recipe" and removed_recipes[effect.recipe] then
				table.remove(technology.effects, i)
			end
		end
	end

	-- Flow Control moves these Bob/vanilla items into its own group; restore the
	-- normal Factorio pipe subgroup.
	for _, name in ipairs({ "pipe", "pipe-to-ground", "pump" }) do
		local item = data.raw.item[name]
		if item then
			item.subgroup = "energy-pipe-distribution"
		end
	end
	if data.raw["item-subgroup"] then
		-- Some mods still assign recipes here whenever Flow Control is enabled.
		-- Keep the subgroup as a harmless compatibility target after removing its pipes.
		local pipe_subgroup = data.raw["item-subgroup"]["pipe-distribution"]
		if pipe_subgroup then
			pipe_subgroup.group = "logistics"
		else
			data:extend({
				{
					type = "item-subgroup",
					name = "pipe-distribution",
					group = "logistics",
					order = "da",
				}
			})
		end
	end
	if data.raw["item-group"] then
		data.raw["item-group"]["fluid-network"] = nil
	end

	return
end

-- Load the: SUPER-DUPER-VALVE-NUKER (once again just to make sure they got NUKED!)
require("utils.super-duper-valve-nuker")

-- Add Space Age freezing support to the pipe and valve prototypes from this mod.
require("prototypes.space-age")

-- Apply final fixes
require("prototypes.overrides")

-- Fetch functions from library
local make_subgroup = require("utils.lib").make_subgroup
local assign_subgroup = require("utils.lib").assign_subgroup

-- Setup materials
local materials =
{
	["copper"] = {row = 1},
	["stone"] = {row = 3},
	["bronze"] = {row = 4},
	["steel"] = {row = 5},
	["plastic"] = {row = 6},
	["brass"] = {row = 7},
	["titanium"] = {row = 8},
	["ceramic"] = {row = 9},
	["tungsten"] = {row = 10},
	["nitinol"] = {row = 11},
	["copper-tungsten"] = {row = 12},
}

-- Generate subgroups for bob pipes
make_subgroup("valves-1",		"z-y-01") -- angel valves
make_subgroup("valves-2",		"z-y-02") -- valves
make_subgroup("pipes-row-1",	"z-z-01") -- copper
make_subgroup("pipes-row-2",	"z-z-02") -- iron
make_subgroup("pipes-row-3",	"z-z-03") -- stone
make_subgroup("pipes-row-4",	"z-z-04") -- bronze
make_subgroup("pipes-row-5",	"z-z-05") -- steel
make_subgroup("pipes-row-6",	"z-z-06") -- plastic
make_subgroup("pipes-row-7",	"z-z-07") -- brass
make_subgroup("pipes-row-8",	"z-z-08") -- titanium
make_subgroup("pipes-row-9",	"z-z-09") -- ceramic
make_subgroup("pipes-row-10",	"z-z-10") -- tungsten
make_subgroup("pipes-row-11",	"z-z-11") -- nitinol
make_subgroup("pipes-row-12",	"z-z-12") -- copper-tungsten

-- Assign subgroup to valves
assign_subgroup("valve-inspector",			"valves-1", "1") -- Angels petrochem
assign_subgroup("valve-converter",			"valves-1", "2") -- Angels petrochem
assign_subgroup("flowbob-check-valve",		"valves-2", "1")
assign_subgroup("flowbob-overflow-valve",	"valves-2", "2")
assign_subgroup("flowbob-topup-valve-1",	"valves-2", "3")
assign_subgroup("flowbob-topup-valve-2",	"valves-2", "4")
assign_subgroup("void-pump",				"valves-2", "5") -- Bobplates

-- Assign subgroup to pipes
assign_subgroup("pipe", 			"pipes-row-2", "1") -- Base
assign_subgroup("pipe-to-ground", 	"pipes-row-2", "2") -- Base
assign_subgroup("pipe-straight",	"pipes-row-2", "3") -- Flow control
assign_subgroup("pipe-junction",	"pipes-row-2", "4") -- Flow control
assign_subgroup("pipe-elbow",		"pipes-row-2", "5") -- Flow control
for material, parameters in pairs(materials) do
	-- Assign material to row
	local subgroup_row = "pipes-row-"..parameters.row

	-- Assign subgroup
	assign_subgroup(material.."-pipe",				subgroup_row, "1") -- pipe
	assign_subgroup(material.."-pipe-to-ground",	subgroup_row, "2") -- pipe to ground
	assign_subgroup("pipe-"..material.."-straight", subgroup_row, "3") -- straight
	assign_subgroup("pipe-"..material.."-junction", subgroup_row, "4") -- junction
	assign_subgroup("pipe-"..material.."-elbow", 	subgroup_row, "5") -- elbow
end

-- Generate subgroups for other entities
make_subgroup("storage-tanks-1",	"a-a-1") -- storage tanks
make_subgroup("storage-tanks-2",	"a-a-2") -- storage tanks
make_subgroup("pumpjacks-1",		"a-b-1") -- oil pumpjacks
make_subgroup("pumpjacks-2",		"a-b-2") -- water pumpjacks
make_subgroup("pumpjacks-3",		"a-b-3") -- ground water pumpjacks
make_subgroup("compressors-1",		"a-c-1") -- compressors
make_subgroup("compressors-2",		"a-c-2") -- barreling pumps
make_subgroup("pumps",				"a-d-1") -- pumps
make_subgroup("offshore-pumps",		"a-e-1") -- offshore pumps

-- Storage tanks
assign_subgroup("bob-small-inline-storage-tank",	"storage-tanks-1", "01") -- Bobplates
assign_subgroup("bob-small-storage-tank",			"storage-tanks-1", "02") -- Bobplates
assign_subgroup("storage-tank",						"storage-tanks-1", "03") -- Boblogistics
assign_subgroup("bob-storage-tank-all-corners",		"storage-tanks-1", "04") -- Boblogistics
assign_subgroup("storage-tank-2",					"storage-tanks-1", "05") -- Boblogistics
assign_subgroup("bob-storage-tank-all-corners-2",	"storage-tanks-1", "06") -- Boblogistics
assign_subgroup("storage-tank-3",					"storage-tanks-1", "07") -- Boblogistics
assign_subgroup("bob-storage-tank-all-corners-3",	"storage-tanks-1", "08") -- Boblogistics
assign_subgroup("storage-tank-4",					"storage-tanks-1", "09") -- Boblogistics
assign_subgroup("bob-storage-tank-all-corners-4",	"storage-tanks-1", "10") -- Boblogistics
assign_subgroup("angels-storage-tank-1",			"storage-tanks-2", "01") -- Angels petrochem
assign_subgroup("angels-storage-tank-2",			"storage-tanks-2", "02") -- Angels petrochem
assign_subgroup("angels-storage-tank-3",			"storage-tanks-2", "03") -- Angels petrochem
assign_subgroup("angels-pressure-tank-1",			"storage-tanks-2", "04") -- Angels addons - storage options

-- Pumps
assign_subgroup("pump",			"pumps") -- Base
assign_subgroup("bob-pump-2",	"pumps") -- Boblogistics
assign_subgroup("bob-pump-3",	"pumps") -- Boblogistics
assign_subgroup("bob-pump-4",	"pumps") -- Boblogistics

-- Compressors and barreling pumps
assign_subgroup("air-pump",			"compressors-1") -- Bobplates
assign_subgroup("air-pump-2",		"compressors-1") -- Bobplates
assign_subgroup("air-pump-3",		"compressors-1") -- Bobplates
assign_subgroup("air-pump-4",		"compressors-1") -- Bobplates
assign_subgroup("water-pump",		"compressors-2") -- Bobplates
assign_subgroup("water-pump-2",		"compressors-2") -- Bobplates
assign_subgroup("water-pump-3",		"compressors-2") -- Bobplates
assign_subgroup("water-pump-4",		"compressors-2") -- Bobplates
assign_subgroup("barreling-pump",	"compressors-2") -- Angels refining

-- Pumpjacks
assign_subgroup("pumpjack",				"pumpjacks-1") -- Base
assign_subgroup("bob-pumpjack-1",		"pumpjacks-1") -- Bobmining
assign_subgroup("bob-pumpjack-2",		"pumpjacks-1") -- Bobmining
assign_subgroup("bob-pumpjack-3",		"pumpjacks-1") -- Bobmining
assign_subgroup("bob-pumpjack-4",		"pumpjacks-1") -- Bobmining
assign_subgroup("water-miner-1",		"pumpjacks-2") -- Bobmining
assign_subgroup("water-miner-2",		"pumpjacks-2") -- Bobmining
assign_subgroup("water-miner-3",		"pumpjacks-2") -- Bobmining
assign_subgroup("water-miner-4",		"pumpjacks-2") -- Bobmining
assign_subgroup("water-miner-5",		"pumpjacks-2") -- Bobmining
assign_subgroup("water-pumpjack-1",		"pumpjacks-3") -- P-U-M-P-S
assign_subgroup("water-pumpjack-2",		"pumpjacks-3") -- P-U-M-P-S
assign_subgroup("water-pumpjack-3",		"pumpjacks-3") -- P-U-M-P-S
assign_subgroup("water-pumpjack-4",		"pumpjacks-3") -- P-U-M-P-S
assign_subgroup("water-pumpjack-5",		"pumpjacks-3") -- P-U-M-P-S

-- Offshore pumps
assign_subgroup("offshore-pump-0",		"offshore-pumps") -- P-U-M-P-S
assign_subgroup("offshore-pump-1",		"offshore-pumps") -- P-U-M-P-S
assign_subgroup("offshore-pump-2",		"offshore-pumps") -- P-U-M-P-S
assign_subgroup("offshore-pump-3",		"offshore-pumps") -- P-U-M-P-S
assign_subgroup("offshore-pump-4",		"offshore-pumps") -- P-U-M-P-S
if not mods ["P-U-M-P-S"] then
	assign_subgroup("offshore-pump",	"offshore-pumps") -- Base
end
