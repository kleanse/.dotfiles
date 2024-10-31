-- Set "," as the leader key
--  See `:help mapleader`
-- NOTE: Must happen before plugins are required (otherwise, wrong leader will
-- be used)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Set to true if you have installed and are using a Nerd Font
vim.g.have_nerd_font = true

-- Directory containing template files
vim.g.template_path = "~/.templates"

-- Remove trailing whitespace and blank lines at the start and end when writing
-- the current buffer
vim.g.trim_blanks_on_write = true

-- [[ Install `lazy.nvim` plugin manager ]]
-- https://github.com/folke/lazy.nvim
--  See `:help lazy.nvim.txt` for more info
require("config.lazy")

-- [[ Import custom utility functions ]]
local utils = require("utils")

-- [[ Set options ]]
--  See `:help vim.opt`
vim.opt.background = "light"
vim.opt.cedit = vim.api.nvim_replace_termcodes("<C-X>", true, true, true)
vim.opt.copyindent = true
vim.opt.listchars = { tab = "--|", trail = "·" }
vim.opt.mouse = "a" -- Enable mouse mode
vim.opt.showmode = false -- Redundant with mini.statusline
vim.opt.termguicolors = true -- Check if your terminal supports this
vim.opt.textwidth = 79
vim.opt.undofile = true -- Save undo history
vim.opt.wrapscan = false
vim.wo.breakindent = true -- Enable break indent
vim.wo.colorcolumn = "+1"
vim.wo.signcolumn = "yes" -- Keep signcolumn on by default

-- Set completeopt to have a better completion experience
vim.opt.completeopt = "menuone"

-- Case insensitive searching unless '\C' or a capital appears in pattern
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Sync clipboard between OS and Neovim
-- Schedule the setting after "UIEnter" because it can increase startup-time
-- Remove this option if you want your OS clipboard to remain independent
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Use a custom format for tab pages
vim.opt.tabline = "%!v:lua.Tabline()"

-- [[ Key mappings ]]
--  See `:help vim.keymap.set()`
-- Remap ";" and "," to different keys for delay-free "," behavior while using
-- such a key for mapleader
vim.keymap.set("", "+", ";")
vim.keymap.set("", "-", ",")

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

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

-- [[ Functions ]]

-- Pretty prints a Lua object.
function P(object)
  print(vim.inspect(object))
  return object
end

local get_icon
if _G.MiniIcons then
  -- Prefer 'mini.icons'
  get_icon = function(name)
    return (_G.MiniIcons.get("file", name))
  end
else
  -- Try falling back to 'nvim-web-devicons'
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if has_devicons then
    -- Use basename because it makes exact file name matching work
    get_icon = function(name)
      return (devicons.get_icon(vim.fn.fnamemodify(name, ":t"), nil, { default = true }))
    end
  end
end

-- Builds a custom format for 'tabline' that is based on the default format
-- produced by `draw_tabline()` in the Nvim source code.
function Tabline()
  local s = ""
  local col = 0
  local columns = vim.api.nvim_get_option_value("columns", {})
  local tabpages = vim.api.nvim_list_tabpages()

  for tabnr, tabpage in ipairs(tabpages) do
    if col >= columns - 4 then
      break
    end

    local startcol = col

    local bufnrlist = vim.fn.tabpagebuflist(tabnr)
    local winnr = vim.api.nvim_win_get_number(vim.api.nvim_tabpage_get_win(tabpage))
    local bufname = vim.api.nvim_buf_get_name(bufnrlist[winnr])

    -- Highlight current tab page
    local hlgroup = "%#TabLine#"
    if tabpage == vim.api.nvim_get_current_tabpage() then
      hlgroup = "%#TabLineSel#"
    end
    s = s .. hlgroup

    -- Set tab page number (for mouse clicks)
    s = s .. "%" .. tabnr .. "T"

    s = s .. " "
    col = col + 1

    local modified = false
    for _, bufnr in ipairs(bufnrlist) do
      if vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
        modified = true
        break
      end
    end

    local wincount = #vim.api.nvim_tabpage_list_wins(tabpage)
    if modified or wincount > 1 then
      if wincount > 1 then
        local len = #string.format("%d", wincount)
        if col + len >= columns - 3 then
          break
        end
        s = s .. "%#GruvboxTabLineTitle#" .. wincount .. hlgroup
        col = col + len
      end
      if modified then
        s = s .. "+"
        col = col + 1
      end
      s = s .. " "
      col = col + 1
    end

    if get_icon then
      s = s .. get_icon(bufname)
      s = s .. " "
      col = col + 2
    end

    -- Set tab page label
    local tabwidth = math.max(#tabpages > 0 and math.floor((columns - 1 + #tabpages / 2) / #tabpages) or 0, 6)
    local room = startcol - col + tabwidth - 1
    if room > 0 then
      local trbufname = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or "[No Name]"
      if trbufname == "" then
        trbufname = "[Temp]"
      end
      trbufname = string.sub(trbufname, -room)
      s = s .. trbufname
      col = col + #trbufname
    end
    s = s .. " "
    col = col + 1
  end

  s = s .. "%#TabLineFill#%T"

  local showcmd = vim.api.nvim_get_option_value("showcmd", {})
  local showcmdloc = vim.api.nvim_get_option_value("showcmdloc", {})
  if showcmd and showcmdloc == "tabline" then
    local sc_width = math.min(10, columns - col - (#tabpages > 1 and 3 or 0))
    if sc_width > 0 then
      s = s .. string.rep(" ", columns - sc_width - (#tabpages > 1 and 2 or 0) - col)
      s = s .. "%#TabLine#%S%#TabLineFill#"
    end
  end

  -- Right-align the label to close the current tab page
  if #tabpages > 1 then
    s = s .. "%=%#TabLine#%999XX"
  end

  return s
end

-- [[ Autocommands ]]
-- Highlight yanked text briefly
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Update the date following a "Last change:" string in the first 20 lines of
-- the current buffer
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("update-last-change", { clear = true }),
  pattern = "*",
  callback = function()
    utils.update_last_change()
  end,
})

-- Trim trailing whitespace and peripheral blank lines
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("trim-blanks", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.g.trim_blanks_on_write then
      utils.trim_peripheral_blank_lines()
      utils.trim_trailing_whitespace()
    end
  end,
})

-- Use a template file when editing new files of a specific type
local template_group = vim.api.nvim_create_augroup("edit-with-template", { clear = true })
vim.api.nvim_create_autocmd("BufNewFile", {
  group = template_group,
  pattern = "*.c",
  callback = function()
    utils.read_template_file(".c", { 5, 0 })
    vim.cmd.startinsert({ bang = true })
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  group = template_group,
  pattern = "*.cpp",
  callback = function()
    utils.read_template_file(".cpp", { 5, 0 })
    vim.cmd.startinsert({ bang = true })
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  group = template_group,
  pattern = "*.h",
  callback = function()
    utils.read_template_file(".h", { 4, 0 })
    utils.set_header_macros()
    vim.cmd.startinsert({ bang = true })
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  group = template_group,
  pattern = "*.html",
  callback = function()
    utils.read_template_file(".html", { 6, 11 })
    vim.cmd.startinsert()
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  group = template_group,
  pattern = "Makefile",
  callback = function()
    utils.read_template_file(".mk", { 2, 0 })
    vim.api.nvim_set_current_line(vim.api.nvim_get_current_line() .. " ")
    vim.cmd.startinsert({ bang = true })
  end,
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim:ts=2:sts=2:sw=2:et:
