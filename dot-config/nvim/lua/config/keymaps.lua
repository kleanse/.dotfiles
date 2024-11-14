-- Remap ";" and "," to different keys for delay-free "," behavior while using
-- such a key for mapleader
vim.keymap.set("", "+", ";")
vim.keymap.set("", "-", ",")

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Move tabs
vim.keymap.set("n", "gy", function()
  if vim.v.count ~= 0 then
    vim.cmd.tabmove(vim.v.count)
  elseif vim.api.nvim_tabpage_get_number(0) == 1 then
    vim.cmd.tabmove("$")
  else
    vim.cmd.tabmove("-")
  end
end, { desc = "Move the current tab page to the left" })

vim.keymap.set("n", "gl", function()
  if vim.v.count ~= 0 then
    vim.cmd.tabmove(vim.v.count)
  elseif vim.api.nvim_tabpage_get_number(0) == #vim.api.nvim_list_tabpages() then
    vim.cmd.tabmove("0")
  else
    vim.cmd.tabmove("+")
  end
end, { desc = "Move the current tab page to the right" })

-- Reference local ASCII table
vim.keymap.set(
  "n",
  "<Leader>va",
  "<Cmd>split $ASCII_REFERENCE | view<CR>",
  { desc = "[V]iew [A]SCII reference file in a new split" }
)

-- Keep cursor centered when repeating searches, opening any closed folds if
-- necessary
vim.keymap.set("n", "n", "nzvzz")
vim.keymap.set("n", "N", "Nzvzz")

vim.keymap.set("n", "<Leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
Config.map.jump.set("q", { next = "<Cmd>cnext<CR>", prev = "<Cmd>cprevious<CR>" }, { name = "error" })

vim.keymap.set("n", ";", vim.cmd.update, { desc = '":update" file' })
vim.keymap.set("n", "<M-b>", "<C-^>")
vim.keymap.set("n", "<M-e>", vim.cmd.Explore, { desc = "Netrw explore directory of current file" })
vim.keymap.set("n", "<M-o>", vim.cmd.Rexplore, { desc = "Netrw return to or from Explorer" })

-- Use CTRL-C for <Esc>: it is easier to reach
vim.keymap.set("i", "<C-C>", "<Esc>")
vim.keymap.set("x", "<C-C>", "<Esc>")

vim.keymap.set("i", "<C-L>", "<C-X><C-L>")

-- Move text in Visual mode. Visual-mode "J" and "K" are overwritten; for the
-- former command, use ":join" instead. The latter might not need addressed:
-- Visual-mode "K" is rare
vim.keymap.set("x", "J", ":move '>+1<CR>gv=gv", { desc = "Move selected text down one line" })
vim.keymap.set("x", "K", ":move '<-2<CR>gv=gv", { desc = "Move selected text up one line" })

-- Use some common GNU-Readline keyboard shortcuts for the Command line
-- Overwrite the Command-line commands CTRL-A, CTRL-B, and CTRL-F. CTRL-A is
-- not useful; CTRL-B's behavior is moved to CTRL-A; and CTRL-F expedites
-- editing complex commands
vim.keymap.set("c", "<C-A>", "<Home>")
vim.keymap.set("c", "<C-B>", "<Left>")
vim.keymap.set("c", "<C-F>", "<Right>")
vim.keymap.set("c", "<M-b>", "<S-Left>")
vim.keymap.set("c", "<M-f>", "<S-Right>")

-- Overload Command-line CTRL-D: it still performs its normal behavior, but if
-- a character is under the cursor, it executes the GNU-Readline behavior
-- (i.e., delete the character).
vim.keymap.set("c", "<C-D>", function()
  return vim.fn.getcmdpos() > #vim.fn.getcmdline() and "<C-D>" or "<Del>"
end, { desc = "Delete character or list", expr = true })

-- Toggle settings
Config.map.toggle.set("<Leader>tc", "colorcolumn", { states = { on = "+1", off = "" } })
Config.map.toggle.set("<Leader>td", {
  get = function()
    return vim.diagnostic.is_enabled()
  end,
  set = function(state)
    vim.diagnostic.enable(state)
  end,
}, { name = "diagnostics", echo = true })
Config.map.toggle.set("<Leader>tl", "list")
Config.map.toggle.set("<Leader>ts", "spell")
Config.map.toggle.set(
  "<Leader>tt",
  "vim.g.trim_blanks_on_write",
  { name = "trim", desc_name = "trim blanks on write", echo = true }
)
Config.map.toggle.set("<Leader>tv", "virtualedit", { states = { on = "all", off = "" }, echo = true })
Config.map.toggle.set("<Leader>tw", "wrap", { echo = true })
Config.map.toggle.set("<Leader>tx", {
  get = function()
    return vim.g.syntax_on
  end,
  set = function(state)
    if state then
      vim.cmd("syntax on | TSEnable highlight")
    else
      vim.cmd("syntax off | TSDisable highlight")
    end
  end,
}, { desc_name = "syntax highlighting" })
