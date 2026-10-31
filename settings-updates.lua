-- Flow Control reads this inherited startup setting as a boolean during data.lua.
-- Keep its original type so existing mod-settings.dat values remain valid, and
-- hide it because this compatibility mod provides its own pipe grouping.
local setting = data.raw["bool-setting"] and data.raw["bool-setting"]["flow-control-new-group"]
if setting then
	setting.hidden = true
end
