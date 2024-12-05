-- Script overruling and adding to the distributed "html.vim" ftplugin.
-- Language:	HTML
-- Last Change:	2024 Dec 05

vim.b.undo_ftplugin = vim.b.undo_ftplugin .. "| setl et< sw<"

local setl = vim.opt_local

setl.expandtab = true
setl.shiftwidth = 2
