vim9script
# Script overruling and adding to the distributed "cpp.vim" ftplugin.
# Language:	C++
# Maintainer:	Kenny Lam
# Last Change:	2022 Feb 22

# Along with the side effects of the distributed ftplugin, undo the side
# effects of this script.
b:undo_ftplugin ..= "| call " .. expand("<SID>") .. "Undo_ftplugin()"

# Associates default key sequences with plugin mappings.
const PLUG_NAMES = {
	[g:maplocalleader .. 'c']: '<Plug>cpp_comment;',
}

# Associates plugin mappings with mapping modes (see "map-modes").
const PLUG_MODES = {
	'<Plug>cpp_comment;': 'x',
}

# The distributed "cpp.vim" ftplugin sources "c.vim", "c_*.vim", and "c/*.vim"
# ftplugins, i.e., the ftplugin for C files. Options set in these ftplugins
# persist in this script, so they need not be repeated.

# Internal functions {{{
if !exists("*Undo_ftplugin")
def Undo_ftplugin()
	# Undo_ftplugin() implementation {{{
	for [lhs, plug_name] in items(PLUG_NAMES)
		const mode = PLUG_MODES[plug_name]
		execute mode .. 'unmap <buffer>' plug_name
		if maparg(lhs, mode) == plug_name
			execute mode .. 'unmap <buffer>' lhs
		endif
	endfor
	if maparg(g:maplocalleader .. 'm', 'x') == '<Plug>c_comment;'
		execute 'xunmap <buffer>' g:maplocalleader .. 'm'
	endif
enddef
# }}}
endif

if !exists("*V_toggle_comment")
# Comment out lines selected in Visual mode if the first of such lines is not
# commented. Otherwise, uncomment them. The comment style is C++. (Note that
# this function is defined with ":function" so that "range" can be used; legacy
# syntax is in force.)
function V_toggle_comment() range
	" V_toggle_comment() implementation {{{
	let l:range = a:firstline .. ',' .. a:lastline
	if getline(a:firstline) =~ '\v^\s*//'
		execute l:range .. 'substitute`\v^\s*\zs// ?``'
	else
		execute l:range .. 'substitute`\v^%(// )?`// `'
	endif
	nohlsearch
endfunction
# }}}
endif
# }}}

# Mappings {{{
if !exists("g:no_plugin_maps") && !exists("g:no_cpp_maps")
	# Map <LocalLeader>m to <Plug>c_comment; if the plugin mapping is
	# mapped to by its default key sequence (i.e., <LocalLeader>c).
	if maparg(g:maplocalleader .. 'c', 'x') == '<Plug>c_comment;'
		execute 'xunmap <buffer>' g:maplocalleader .. 'c'
		execute 'xmap <buffer> <unique>' g:maplocalleader .. 'm'
					       \ '<Plug>c_comment;'
	endif
	for [lhs, plug_name] in items(PLUG_NAMES)
		if !hasmapto(plug_name)
			execute PLUG_MODES[plug_name]
				.. 'map <buffer> <unique>' lhs plug_name
		endif
	endfor
	xnoremap <buffer> <silent> <unique> <Plug>cpp_comment;
	       \ :<Home>silent <End>call <SID>V_toggle_comment()<CR>
endif
# }}}
