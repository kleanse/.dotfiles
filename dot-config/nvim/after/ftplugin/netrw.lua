-- Language:	Netrw
-- Last Change:	2025 Jan 08

local map = vim.keymap.set
local feedkeys = vim.api.nvim_feedkeys
local plug_key = vim.api.nvim_replace_termcodes("<Plug>", true, false, true)

map("n", "cd", function()
  feedkeys(plug_key .. "NetrwLcd", "n", false)
  vim.schedule(vim.cmd.pwd)
end, { buffer = true, desc = "Netrw change current directory and print" })
