vim9script
# Script overruling and adding to the distributed "python.vim" ftplugin.
# Language:	Python
# Maintainer:	Kenny Lam
# Last Change:	2022 Feb 22

# Along with the side effects of the distributed ftplugin, undo the side
# effects of this script.
b:undo_ftplugin ..= "| call " .. expand("<SID>") .. "Undo_ftplugin()"

setlocal formatoptions+=tcroqlj
setlocal textwidth=79

if !exists("*Undo_ftplugin")
def Undo_ftplugin()
	# Undo_ftplugin() implementation {{{
	setlocal formatoptions<
	setlocal textwidth<
enddef
# }}}
endif
