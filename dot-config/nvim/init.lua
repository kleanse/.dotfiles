-- Set "," as the leader key
--  See `:help mapleader`
-- NOTE: Must happen before plugins are required (otherwise, wrong leader will
-- be used)
vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.g.dark_mode = false -- Use a dark color scheme
vim.g.format_on_write = true -- Apply formatters when writing current buffer
vim.g.have_nerd_font = true -- Set to true if you have installed and are using a Nerd Font
vim.g.template_path = "~/.templates" -- Directory containing template files

-- Filetype plugin settings
vim.g.ftplugin_sql_omni_key = "<C-Z>"

-- Change appearance automatically based on operating system's appearance
if vim.uv.os_uname().sysname == "Darwin" then
  -- Check and set vim.g.dark_mode to avoid screen flash when starting Nvim in
  -- dark mode and with vim.g.dark_mode set to false
  if vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait().stdout == "Dark\n" then
    vim.g.dark_mode = true
  end
  local dark_mode_on = vim.g.dark_mode ---@type boolean
  local timer = vim.uv.new_timer()
  timer:start(
    0,
    15 * 1000,
    vim.schedule_wrap(function()
      local os_mode = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait().stdout
      if os_mode == "Dark\n" then
        if not dark_mode_on then
          vim.api.nvim_set_option_value("background", "dark", {})
          vim.cmd.colorscheme("catppuccin")
          dark_mode_on = true
        end
      elseif dark_mode_on then
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd.colorscheme("gruvbox")
        dark_mode_on = false
      end
    end)
  )
end

_G.Config = require("util")

-- [[ Set options, key mappings, and autocommands ]]
require("config.autocmds")
require("config.keymaps")
require("config.options")

-- [[ Install `lazy.nvim` plugin manager ]]
-- https://github.com/folke/lazy.nvim
--  See `:help lazy.nvim.txt` for more info
require("config.lazy")

-- [[ Functions ]]

-- Pretty prints a Lua object.
function P(object)
  print(vim.inspect(object))
  return object
end
