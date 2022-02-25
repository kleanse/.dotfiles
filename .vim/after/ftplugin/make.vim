vim9script noclear

# Vim filetype plugin for make files.
# 2022 Feb 16 - Written by Kenny Lam.

if exists("b:did_ftplugin")
	finish
endif
b:did_ftplugin = 1

b:undo_ftplugin = "call " .. expand("<SID>") .. "Undo_ftplugin()"

# Disable the insertion of spaces with <Tab> when editing a Makefile. Note that
# some options have been set already and are thus redundant. However, this
# verbosity is intended and is part of this script's structure: files that
# require a particular set of options will specify it fully, regardless of its
# options' previous values. This practice enables such option sets to be
# changed and understood more easily.
#
# Note that view-based options should be constant across all file types to
# maintain a uniform editor appearance. Options such as formatting ones are
# safe and even necessary to change for specific file types.
setlocal
	\ autoindent
	\ formatoptions-=t
	\ noexpandtab
	\ textwidth=79

def Undo_ftplugin()
	# Undo_ftplugin() implementation {{{
	setlocal
		\ autoindent<
		\ expandtab<
		\ formatoptions<
		\ textwidth<
enddef
# }}}
