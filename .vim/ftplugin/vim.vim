vim9script noclear

# Vim filetype plugin for vim files.
# 2022 Feb 16 - Written by Kenny Lam.

if exists("b:did_ftplugin")
	finish
endif
b:did_ftplugin = 1

b:undo_ftplugin = "call " .. expand("<SID>") .. "Undo_ftplugin()"

setlocal
	\ autoindent
	\ copyindent
	\ foldmethod=marker
	\ formatoptions=tcroqlj
	\ textwidth=79

def Undo_ftplugin()
	# Undo_ftplugin() implementation {{{
	setlocal
		\ autoindent<
		\ copyindent<
		\ foldmethod<
		\ formatoptions<
		\ textwidth<
enddef
# }}}
