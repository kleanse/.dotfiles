-- Set "," as the leader key
--  See `:help mapleader`
-- NOTE: Must happen before plugins are required (otherwise, wrong leader will
-- be used)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Use a dark color scheme
vim.g.dark_mode = false

-- Set to true if you have installed and are using a Nerd Font
vim.g.have_nerd_font = true

-- Directory containing template files
vim.g.template_path = "~/.templates"

-- Remove trailing whitespace and blank lines at the start and end when writing
-- the current buffer
vim.g.trim_blanks_on_write = true

-- Enable dark mode if operating system's appearance is dark mode
if
  vim.uv.os_uname().sysname == "Darwin"
  and vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait().stdout == "Dark\n"
then
  vim.g.dark_mode = true
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

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim:ts=2:sts=2:sw=2:et:
