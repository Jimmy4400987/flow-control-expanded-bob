--------------------------
---- data-updates.lua ----
--------------------------

-- Leave Flow Control's prototype updates disabled with Bob's Logistics.
if mods["boblogistics"] then
	return
end

-- Keep legacy valve prototypes through data-updates so dependent mods can finish
-- recipe and recycling updates. They are replaced in data-final-fixes.lua.
