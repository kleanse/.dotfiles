-- Script overruling and adding to the distributed "cmake.vim" ftplugin.
-- Language:	CMake
-- Last Change:	2024 Dec 03

vim.b.undo_ftplugin = vim.b.undo_ftplugin .. "| setl et< sw<"

vim.bo.expandtab = true
vim.bo.shiftwidth = 2
