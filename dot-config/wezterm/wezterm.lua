local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("keymaps").apply_to_config(config)
require("ui").apply_to_config(config)

return config
