-- Replace the obsolete startup toggle with a hidden sentinel. Factorio requires a
-- setting's saved value to match its type; after the one-time migration from the
-- old bool setting, keeping the sentinel as a string prevents repeated warnings.
if data.raw["bool-setting"] and data.raw["bool-setting"]["flow-control-new-group"] then
	data.raw["bool-setting"]["flow-control-new-group"] = nil
	data:extend({
		{
			type = "string-setting",
			name = "flow-control-new-group",
			setting_type = "startup",
			default_value = "VOID",
			allowed_values = {"VOID"},
			hidden = true
		}
	})
end
