local wezterm = require("wezterm")
local M = {}

function M.apply_to_config(config)
  config.send_composed_key_when_left_alt_is_pressed = false
  config.send_composed_key_when_right_alt_is_pressed = false
end

return M
