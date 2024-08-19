-- Script overruling and adding to the distributed "javascript.vim" ftplugin.
-- Language:	JavaScript
-- Last Change:	2024 Aug 19

vim.b.undo_ftplugin = vim.b.undo_ftplugin .. "| setl et< sw<"

vim.bo.expandtab = true
vim.bo.shiftwidth = 2
