-- Factorio 2.1's freezing mechanic is enabled by Space Age. Flow Control's
-- pipe sections are storage-tank prototypes, so they need their own heat and
-- frozen visuals instead of inheriting the updates applied to vanilla pipes.
if not (mods["space-age"] and feature_flags["freezing"]) then
	return
end

local frozen_pipe_pictures = data.raw.pipe.pipe.pictures
local frozen_pipe_covers = data.raw.pipe.pipe.fluid_box.pipe_covers_frozen
if not (frozen_pipe_pictures and frozen_pipe_covers) then
	return
end

local deepcopy = util.table.deepcopy
local directions_by_shape = {
	straight = {
		north = "straight_vertical_frozen",
		east = "straight_horizontal_frozen",
		south = "straight_vertical_frozen",
		west = "straight_horizontal_frozen",
	},
	junction = {
		north = "t_down_frozen",
		east = "t_left_frozen",
		south = "t_up_frozen",
		west = "t_right_frozen",
	},
	elbow = {
		north = "corner_down_right_frozen",
		east = "corner_down_left_frozen",
		south = "corner_up_left_frozen",
		west = "corner_up_right_frozen",
	},
}

local function add_pipe_freezing_support(entity, shape)
	if not entity or not entity.fluid_box or not entity.pictures then
		return
	end

	entity.heating_energy = "1kW"
	entity.fluid_box.pipe_covers_frozen = deepcopy(frozen_pipe_covers)
	entity.pictures.frozen_patch = {}
	for direction, picture_name in pairs(directions_by_shape[shape]) do
		local picture = frozen_pipe_pictures[picture_name]
		if picture then
			entity.pictures.frozen_patch[direction] = deepcopy(picture)
		end
	end
end

-- Flow Control's original restricted pipes.
add_pipe_freezing_support(data.raw["storage-tank"]["pipe-straight"], "straight")
add_pipe_freezing_support(data.raw["storage-tank"]["pipe-junction"], "junction")
add_pipe_freezing_support(data.raw["storage-tank"]["pipe-elbow"], "elbow")

-- Material-specific pipes added by Flow Control Expanded for Bob's Logistics.
for _, material in pairs({
	"brass",
	"bronze",
	"copper",
	"ceramic",
	"stone",
	"plastic",
	"steel",
	"titanium",
	"tungsten",
	"copper-tungsten",
	"nitinol",
}) do
	for shape in pairs(directions_by_shape) do
		add_pipe_freezing_support(data.raw["storage-tank"]["pipe-" .. material .. "-" .. shape], shape)
	end
end

-- Custom valves need heating and frozen covers on Aquilo, like vanilla valves.
local valve_pictures = {
	north = "straight_vertical_frozen",
	east = "straight_horizontal_frozen",
	south = "straight_vertical_frozen",
	west = "straight_horizontal_frozen",
}
for _, name in pairs({
	"flowbob-check-valve",
	"flowbob-overflow-valve",
	"flowbob-topup-valve-1",
	"flowbob-topup-valve-2",
}) do
	local valve = data.raw.valve[name]
	if valve then
		valve.heating_energy = "20kW"
		valve.fluid_box.pipe_covers_frozen = deepcopy(frozen_pipe_covers)
		valve.frozen_patch = {}
		for direction, picture_name in pairs(valve_pictures) do
			local picture = frozen_pipe_pictures[picture_name]
			if picture then
				valve.frozen_patch[direction] = deepcopy(picture)
			end
		end
	end
end
