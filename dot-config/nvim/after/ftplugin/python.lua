-- Script overruling and adding to the distributed "python.vim" ftplugin.
-- Language:	Python
-- Last Change:	2025 Jan 13

vim.b.undo_ftplugin = vim.b.undo_ftplugin .. "| setl fo<"

local setl = vim.opt_local

setl.formatoptions:remove("t")
setl.formatoptions:append("croqlj")
