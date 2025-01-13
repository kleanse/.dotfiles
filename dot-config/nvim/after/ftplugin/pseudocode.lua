-- Language:	Pseudocode
-- Last Change:	2025 Jan 13

vim.b.undo_ftplugin = "setl fo<"

local setl = vim.opt_local

setl.formatoptions:remove("t")
setl.formatoptions:append("croqlj")
