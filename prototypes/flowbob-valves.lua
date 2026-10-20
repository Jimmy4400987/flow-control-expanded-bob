-----------------------------------------------------------------------
------ INFINITE THANKS TO KIRAZY FOR THE HELP AND DOCUMENTATION  ------
--------------- https://mods.factorio.com/user/Kirazy -----------------
-----------------------------------------------------------------------

------------------
---- data.lua ----
------------------

local valves =
{
	"flowbob-check-valve",
	"flowbob-overflow-valve",
	"flowbob-topup-valve-1",
	"flowbob-topup-valve-2",
}

-- These are the valve sprite sheets shipped with this mod.
local valve_graphics =
{
	["flowbob-check-valve"] = "bob-valve",
	["flowbob-overflow-valve"] = "bob-overflow-valve",
	["flowbob-topup-valve-1"] = "bob-topup-valve",
	["flowbob-topup-valve-2"] = "flowbob-topup-valve"
}
local valve_icon = "__flow-control-expanded-bob__/graphics/icon/valve/flowbob-topup-valve.png"

-- Items
local valve_check =
{
	type = "item",
	name = "flowbob-check-valve",
	icon = valve_icon,
	icon_size = 32,
	place_result = "flowbob-check-valve",
	stack_size = 100
}
data:extend({valve_check})
for _, valve_name in pairs(valves) do
	if valve_name ~= "flowbob-check-valve" then
		local valve = table.deepcopy(data.raw.item["flowbob-check-valve"])
		valve.name = valve_name
		valve.icon = valve_icon
		valve.place_result = valve_name
		data:extend({valve})
	end
end

-- Factorio 2.0 recipes require typed ingredients and results.
local valve_check_recipe =
{
	type = "recipe",
	name = "flowbob-check-valve",
	energy_required = 2,
	ingredients =
	{
		{type = "item", name = "iron-plate", amount = 1},
		{type = "item", name = "pipe", amount = 1},
		{type = "item", name = "iron-gear-wheel", amount = 1}
	},
	results = {{type = "item", name = "flowbob-check-valve", amount = 1}}
}
data:extend({valve_check_recipe})
for _, valve_name in pairs(valves) do
	if valve_name ~= "flowbob-check-valve" then
		local recipe = table.deepcopy(data.raw.recipe["flowbob-check-valve"])
		recipe.name = valve_name
		recipe.results[1].name = valve_name
		table.insert(recipe.ingredients, {type = "item", name = "electronic-circuit", amount = 1})
		data:extend({recipe})
	end
end

-- Factorio's native valve prototype provides one-way and threshold flow control.
local function make_animation(name, x)
	return
	{
		filename = "__flow-control-expanded-bob__/graphics/entity/valve/"..name..".png",
		width = 58,
		height = 55,
		x = x,
		frame_count = 1,
		shift = {0.28125, -0.078125}
	}
end

local check_valve =
{
	type = "valve",
	name = "flowbob-check-valve",
	icon = valve_icon,
	icon_size = 32,
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 0.1, result = "flowbob-check-valve"},
	max_health = 50,
	mode = "one-way",
	flow_rate = 100,
	fast_replaceable_group = "pipe",
	corpse = "small-remnants",
	resistances = {{type = "fire", percent = 80}},
	collision_box = {{-0.29, -0.45}, {0.29, 0.45}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	fluid_box =
	{
		volume = 100,
		pipe_covers = pipecoverspictures(),
		pipe_connections =
		{
			{direction = defines.direction.north, position = {0, 0}, flow_direction = "input-output"},
			{direction = defines.direction.south, position = {0, 0}, flow_direction = "output"}
		},
		hide_connection_info = true
	},
	vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
	animations =
	{
		north = make_animation(valve_graphics["flowbob-check-valve"], 0),
		east = make_animation(valve_graphics["flowbob-check-valve"], 58),
		south = make_animation(valve_graphics["flowbob-check-valve"], 116),
		west = make_animation(valve_graphics["flowbob-check-valve"], 174)
	}
}
data:extend({check_valve})

for _, valve_name in pairs(valves) do
	if valve_name ~= "flowbob-check-valve" then
		local valve = table.deepcopy(data.raw.valve["flowbob-check-valve"])
		valve.name = valve_name
		valve.icon = valve_icon
		valve.minable = {mining_time = 0.1, result = valve_name}
		for _, animation in pairs(valve.animations) do
			animation.filename = "__flow-control-expanded-bob__/graphics/entity/valve/"..valve_graphics[valve_name]..".png"
		end

		if valve_name == "flowbob-overflow-valve" then
			valve.mode = "overflow"
			valve.threshold = 0.8
		elseif valve_name == "flowbob-topup-valve-1" then
			valve.mode = "top-up"
			valve.threshold = 0.8
		elseif valve_name == "flowbob-topup-valve-2" then
			valve.mode = "top-up"
			valve.threshold = 0.2
		end
		data:extend({valve})
	end
end

for _, valve_name in pairs(valves) do
	table.insert(data.raw.technology["fluid-handling"].effects, {type = "unlock-recipe", recipe = valve_name})
end
