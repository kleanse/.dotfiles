vim.opt.background = vim.g.dark_mode and "dark" or "light"
vim.opt.cedit = vim.api.nvim_replace_termcodes("<C-O>", true, true, true)
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
vim.opt.tabline = "%!v:lua.Config.tabline.draw()"
