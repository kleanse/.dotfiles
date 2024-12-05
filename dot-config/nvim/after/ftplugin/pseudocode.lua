-- Language:	Pseudocode
-- Last Change:	2024 Dec 05

vim.b.undo_ftplugin = "setl fo<"

local setl = vim.opt_local

setl.formatoptions:append("tcroqlj")
