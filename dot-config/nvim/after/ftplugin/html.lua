-- Script overruling and adding to the distributed "html.vim" ftplugin.
-- Language:	HTML
-- Last Change:	2024 Aug 15

vim.b.undo_ftplugin = vim.b.undo_ftplugin .. "| setl et< sw<"

vim.bo.expandtab = true
vim.bo.shiftwidth = 2
