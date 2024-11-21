-- Set "," as the leader key
--  See `:help mapleader`
-- NOTE: Must happen before plugins are required (otherwise, wrong leader will
-- be used)
vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.g.dark_mode = false -- Use a dark color scheme
vim.g.have_nerd_font = true -- Set to true if you have installed and are using a Nerd Font
vim.g.template_path = "~/.templates" -- Directory containing template files
vim.g.trim_blanks_on_write = true -- Strip trailing whitespace and blank lines when writing current buffer

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
