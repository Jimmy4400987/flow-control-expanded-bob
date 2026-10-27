-- Power Armour Replacer and its Space Age extension hide vanilla technologies
-- that 5dim still uses as prerequisites. Point those 5dim technologies at the
-- corresponding visible PAR research so their progression remains intact.
local function replace_prerequisite(technology_name, hidden_prerequisite, replacement_prerequisite)
	local technology = data.raw.technology and data.raw.technology[technology_name]
	local replacement = data.raw.technology and data.raw.technology[replacement_prerequisite]
	if not technology or not replacement or type(technology.prerequisites) ~= "table" then
		return
	end

	local found_hidden_prerequisite = false
	for i = #technology.prerequisites, 1, -1 do
		if technology.prerequisites[i] == hidden_prerequisite then
			table.remove(technology.prerequisites, i)
			found_hidden_prerequisite = true
		end
	end

	if not found_hidden_prerequisite then
		return
	end

	for _, prerequisite in ipairs(technology.prerequisites) do
		if prerequisite == replacement_prerequisite then
			return
		end
	end

	table.insert(technology.prerequisites, replacement_prerequisite)
	log(string.format(
		"Local Space Age Compatibility: %s now requires visible technology %s instead of hidden technology %s.",
		technology_name,
		replacement_prerequisite,
		hidden_prerequisite
	))
end

replace_prerequisite("5d-battery-equipment-2", "battery-mk3-equipment", "par-battery-tech-3")
replace_prerequisite("5d-mech-armor-2", "mech-armor", "par-mech-armour-tech-1")
replace_prerequisite("5d-spidertron-5", "discharge-defense-equipment", "par-shock-defense-tech-1")
