vim9script
# Script overruling and adding to the distributed "vim.vim" ftplugin.
# Language:	Vim script
# Maintainer:	Kenny Lam
# Last Change:	2022 Feb 22

# Along with the side effects of the distributed ftplugin, undo the side
# effects of this script.
b:undo_ftplugin ..= "| call " .. expand("<SID>") .. "Undo_ftplugin()"

setlocal foldmethod=marker
setlocal formatoptions+=tcroqlj
setlocal textwidth=79

if !exists("*Undo_ftplugin")
def Undo_ftplugin()
	# Undo_ftplugin() implementation {{{
	setlocal foldmethod<
	setlocal formatoptions<
	setlocal textwidth<
enddef
# }}}
endif
