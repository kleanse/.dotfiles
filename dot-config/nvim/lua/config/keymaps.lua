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
vim.keymap.set("n", "<Leader>tc", function()
  vim.wo.colorcolumn = #vim.wo.colorcolumn == 0 and "+1" or ""
end, { desc = "[T]oggle '[c]olorcolumn'" })

vim.keymap.set("n", "<Leader>td", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "[T]oggle [D]iagnostics" })

vim.keymap.set("n", "<Leader>tl", function()
  vim.wo.list = not vim.wo.list
end, { desc = "[T]oggle '[l]ist'" })

vim.keymap.set("n", "<Leader>ts", function()
  vim.wo.spell = not vim.wo.spell
end, { desc = "[T]oggle '[s]pell' check" })

vim.keymap.set("n", "<Leader>tt", function()
  vim.g.trim_blanks_on_write = not vim.g.trim_blanks_on_write
  local prefix = vim.g.trim_blanks_on_write and string.rep(" ", 2) or "no"
  vim.api.nvim_echo({ { prefix .. "trim" } }, false, {})
end, { desc = "[T]oggle [T]rim blanks on write" })

vim.keymap.set("n", "<Leader>tv", function()
  vim.wo.virtualedit = #vim.wo.virtualedit == 0 and "all" or ""
  vim.cmd("set virtualedit?")
end, { desc = "[T]oggle '[v]irtualedit'" })

vim.keymap.set("n", "<Leader>tw", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "[T]oggle '[w]rap'" })

vim.keymap.set("n", "<Leader>tx", function()
  if vim.g.syntax_on then
    vim.cmd("syntax off | TSDisable highlight")
  else
    vim.cmd("syntax on | TSEnable highlight")
  end
end, { desc = "[T]oggle synta[x] highlighting" })
