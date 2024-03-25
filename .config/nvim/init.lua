-- Set "," as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will
--  be used)
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    See `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  ui = {
    -- If using a Nerd Font, set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons; otherwise, define a Unicode
    -- icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- [[ Import custom utility functions ]]
require('utils')

-- [[ Setting options ]]
-- See `:help vim.o`
vim.o.background = 'light'
vim.o.copyindent = true
vim.o.listchars = 'tab:--|,trail:·'
vim.o.mouse = 'a'          -- Enable mouse mode
vim.o.showmode = false     -- Redundant with nvim-lualine/lualine.nvim
vim.o.termguicolors = true -- Check if your terminal supports this
vim.o.textwidth = 79
vim.o.undofile = true      -- Save undo history
vim.o.wrapscan = false
vim.wo.breakindent = true  -- Enable break indent
vim.wo.colorcolumn = '+1'
vim.wo.signcolumn = 'yes'  -- Keep signcolumn on by default

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone'

-- Case insensitive searching unless '\C' or a capital appears in pattern
vim.o.ignorecase = true
vim.o.smartcase = true

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- [[ Basic Keymaps ]]
-- Keymaps for better default experience
--  See `:help vim.keymap.set()`
-- Remap Normal-mode commands ";" and "," to different keys for delay-free ","
-- behavior while using such a key for mapleader.
vim.keymap.set('n', '+', ';')
vim.keymap.set('n', '_', ',')

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Keep cursor centered when repeating searches, opening any closed folds if
-- necessary.
vim.keymap.set('n', 'n', 'nzvzz')
vim.keymap.set('n', 'N', 'Nzvzz')

vim.keymap.set('n', ';', vim.cmd.update, { desc = '":update" file' })
vim.keymap.set('n', '<M-e>', vim.cmd.Explore, { desc = 'Netrw explore directory of current file' })
vim.keymap.set('n', '<M-o>', vim.cmd.Rexplore, { desc = 'Netrw return to or from Explorer' })

-- Use CTRL-C for <Esc>: it is easier to reach.
vim.keymap.set('i', '<C-C>', '<Esc>')
vim.keymap.set('x', '<C-C>', '<Esc>')

-- Move text in Visual mode. Visual-mode "J" and "K" are overwritten; for the
-- former command, use ":join" instead. The latter might not need addressed:
-- Visual-mode "K" is rare.
vim.keymap.set('x', 'J', ":move '>+1<CR>gv=gv")
vim.keymap.set('x', 'K', ":move '<-2<CR>gv=gv")

-- Toggle settings
vim.keymap.set('n', '<Leader>l', function() vim.wo.list = not vim.wo.list end, { desc = "Toggle '[l]ist'" })
vim.keymap.set('n', '<Leader>sc', function() vim.wo.spell = not vim.wo.spell end, { desc = "Toggle '[s]pell' [c]heck" })
vim.keymap.set('n', '<Leader>cc', function()
  vim.wo.colorcolumn = #vim.wo.colorcolumn == 0 and '+1' or ''
end, { desc = "Toggle '[c]olor[c]olumn'" })
vim.keymap.set('n', '<Leader>ve', function()
  vim.wo.virtualedit = #vim.wo.virtualedit == 0 and 'all' or ''
  vim.cmd('set virtualedit?')
end, { desc = "Toggle '[v]irtual[e]dit'" })
vim.keymap.set('n', '<Leader>x', function()
  if vim.g.syntax_on then
    vim.cmd('syntax off | TSDisable highlight')
  else
    vim.cmd('syntax on | TSEnable highlight')
  end
end, { desc = "Toggle synta[x]" })

-- Use some common GNU-Readline keyboard shortcuts for the Command line.
-- Overwrite the Command-line commands CTRL-A, CTRL-B, and CTRL-F. CTRL-A is
-- not useful; CTRL-B's behavior is moved to CTRL-A; and CTRL-F expedites
-- editing complex commands.
vim.keymap.set('c', '<C-A>', '<Home>')
vim.keymap.set('c', '<C-B>', '<Left>')
vim.keymap.set('c', '<C-F>', '<Right>')
vim.keymap.set('c', '<M-b>', '<S-Left>')
vim.keymap.set('c', '<M-f>', '<S-Right>')

-- Transfer the default behavior of Command-line CTRL-F to CTRL-X.
vim.keymap.set('c', '<C-X>', '<C-F>')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
vim.cmd.highlight('InitLuaYankHighlight cterm=reverse gui=reverse guifg=#d8ccc4 guibg=#eee8d5')
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('yank-highlight', { clear = true }),
  pattern = '*',
  callback = function()
    vim.highlight.on_yank { higroup = 'InitLuaYankHighlight' }
  end,
})

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>f', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
