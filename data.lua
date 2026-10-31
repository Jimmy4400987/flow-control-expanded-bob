------------------
---- data.lua ----
------------------

-- Bob's Logistics is the selected pipe system. Do not load Flow Control's
-- competing pipe shapes or valves when Bob's Logistics is active.
if mods["boblogistics"] then
	return
end

-- Load prototypes
require("prototypes.flowbob-pipes")
require("prototypes.flowbob-valves")
require("prototypes.reskin")

-- Make item group
local item_group =
{
	type = "item-group",
	name = "fluid-network",
	icon = "__base__/graphics/icons/storage-tank.png",
	icon_size = 64,
	icon_mipmaps = 4,
	inventory_order = "c-b",
	order = "aaa-b"
}	data:extend({item_group})
