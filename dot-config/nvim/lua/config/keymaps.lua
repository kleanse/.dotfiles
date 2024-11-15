local jump_map = Config.map.jump.set
local toggle_map = Config.map.toggle.set
local map = vim.keymap.set

-- Remap ";" and "," to different keys for delay-free "," behavior while using
-- such a key for mapleader
map("", "+", ";")
map("", "-", ",")

-- Remap for dealing with word wrap
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Move tabs
map("n", "gy", function()
  if vim.v.count ~= 0 then
    vim.cmd.tabmove(vim.v.count)
  elseif vim.api.nvim_tabpage_get_number(0) == 1 then
    vim.cmd.tabmove("$")
  else
    vim.cmd.tabmove("-")
  end
end, { desc = "Move the current tab page to the left" })

map("n", "gl", function()
  if vim.v.count ~= 0 then
    vim.cmd.tabmove(vim.v.count)
  elseif vim.api.nvim_tabpage_get_number(0) == #vim.api.nvim_list_tabpages() then
    vim.cmd.tabmove("0")
  else
    vim.cmd.tabmove("+")
  end
end, { desc = "Move the current tab page to the right" })

-- Reference local ASCII table
map("n", "<Leader>va", "<Cmd>split $ASCII_REFERENCE | view<CR>", { desc = "View ASCII reference file in a new split" })

-- Keep cursor centered when repeating searches, opening any closed folds if
-- necessary
map("n", "n", "nzvzz")
map("n", "N", "Nzvzz")

map("n", "<Leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix list" })
jump_map("q", { next = vim.cmd.cnext, prev = vim.cmd.cprevious }, { name = "error" })

map("n", ";", vim.cmd.update, { desc = '":update" file' })
map("n", "<M-b>", "<C-^>")
map("n", "<M-e>", vim.cmd.Explore, { desc = "Netrw explore directory of current file" })
map("n", "<M-o>", vim.cmd.Rexplore, { desc = "Netrw return to or from Explorer" })

map("n", "<Leader>l", vim.cmd.Lazy, { desc = "Open Lazy" })
map("n", "<Leader>m", vim.cmd.Mason, { desc = "Open Mason" })

map("n", "<Leader>OT", function()
  vim.cmd.only()
  vim.cmd.tabonly()
end, { desc = "Only This window" })

map("n", "<leader>n", vim.cmd.enew, { desc = "Edit new buffer" })

-- Use CTRL-C for <Esc>: it is easier to reach
map("i", "<C-C>", "<Esc>")
map("x", "<C-C>", "<Esc>")

map("i", "<C-L>", "<C-X><C-L>")

-- Move text in Visual mode. Visual-mode "J" and "K" are overwritten; for the
-- former command, use ":join" instead. The latter might not need addressed:
-- Visual-mode "K" is rare
map("x", "J", ":move '>+1<CR>gv=gv", { desc = "Move selected text down one line" })
map("x", "K", ":move '<-2<CR>gv=gv", { desc = "Move selected text up one line" })

-- Use some common GNU-Readline keyboard shortcuts for the Command line
-- Overwrite the Command-line commands CTRL-A, CTRL-B, and CTRL-F. CTRL-A is
-- not useful; CTRL-B's behavior is moved to CTRL-A; and CTRL-F expedites
-- editing complex commands
map("c", "<C-A>", "<Home>")
map("c", "<C-B>", "<Left>")
map("c", "<C-F>", "<Right>")
map("c", "<M-b>", "<S-Left>")
map("c", "<M-f>", "<S-Right>")

-- Overload Command-line CTRL-D: it still performs its normal behavior, but if
-- a character is under the cursor, it executes the GNU-Readline behavior
-- (i.e., delete the character).
map("c", "<C-D>", function()
  return vim.fn.getcmdpos() > #vim.fn.getcmdline() and "<C-D>" or "<Del>"
end, { desc = "Delete character or list", expr = true })

-- Toggle settings
toggle_map("<Leader>tc", "colorcolumn", { states = { on = "+1", off = "" } })
toggle_map("<Leader>td", {
  get = function()
    return vim.diagnostic.is_enabled()
  end,
  set = function(state)
    vim.diagnostic.enable(state)
  end,
}, { name = "diagnostics", echo = true })
toggle_map("<Leader>tl", "list")
toggle_map("<Leader>to", {
  get = function()
    local is_open = vim.fn.getloclist(0, { winid = 0 }).winid ~= 0
    return is_open
  end,
  set = function(state)
    if state then
      vim.cmd.lopen()
    else
      vim.cmd.lclose()
    end
  end,
}, { desc_name = "location list window" })
toggle_map("<Leader>tq", {
  get = function()
    local is_open = vim.fn.getqflist({ winid = 0 }).winid ~= 0
    return is_open
  end,
  set = function(state)
    if state then
      vim.cmd.copen()
    else
      vim.cmd.cclose()
    end
  end,
}, { desc_name = "quickfix window" })
toggle_map("<Leader>ts", "spell")
toggle_map(
  "<Leader>tt",
  "vim.g.trim_blanks_on_write",
  { name = "trim", desc_name = "trim blanks on write", echo = true }
)
toggle_map("<Leader>tv", "virtualedit", { states = { on = "all", off = "" }, echo = true })
toggle_map("<Leader>tw", "wrap", { echo = true })
toggle_map("<Leader>tx", {
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
