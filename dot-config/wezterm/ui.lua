local wezterm = require("wezterm")
local M = {}

local function get_appearance()
  return wezterm.gui and wezterm.gui.get_appearance() or "Light"
end

local function scheme_for_appearance(appearance)
  return appearance == "Light" and "GruvboxLight" or "Catppuccin Mocha"
end

function M.apply_to_config(config)
  config.color_scheme = scheme_for_appearance(get_appearance())
  config.font = wezterm.font("MesloLGS Nerd Font")
  config.font_size = 16
  config.hide_tab_bar_if_only_one_tab = true
  -- Requires the wezterm terminfo file, which can be compiled and installed with
  -- the following shell commands:
  -- tempfile=$(mktemp) \
  --   && curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo \
  --   && tic -x -o ~/.terminfo $tempfile \
  --   && rm $tempfile
  config.term = "wezterm"
  config.window_padding = { top = 0, right = 0, bottom = 0, left = 0 }
end

return M
