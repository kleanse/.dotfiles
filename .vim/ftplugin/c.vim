vim9script noclear

# Vim filetype plugin for c files.
# 2021 Dec 10 - Written by Kenny Lam.

if exists("b:did_ftplugin")
	finish
endif
b:did_ftplugin = 1

b:undo_ftplugin = "call " .. expand("<SID>") .. "Undo_ftplugin()"

# Associates default key sequences with plugin mappings.
const PLUG_NAMES = {
	[g:maplocalleader .. 'c']: '<Plug>c_comment;',
	[g:maplocalleader .. '<Space>']: '<Plug>c_make;',
}

# Associates plugin mappings with mapping modes (see "map-modes").
const PLUG_MODES = {
	'<Plug>c_make;': 'n',
	'<Plug>c_comment;': 'x',
}

setlocal
	\ cindent
	\ cinoptions=:0,(0,u0
	\ copyindent
	\ formatoptions=tcroqlj
	\ path+=include,../include
	\ textwidth=79

# Internal functions {{{
def Undo_ftplugin()
	# Undo_ftplugin() implementation {{{
	setlocal
		\ cindent<
		\ cinoptions<
		\ copyindent<
		\ formatoptions<
		\ path<
		\ textwidth<

	for [lhs, plug_name] in items(PLUG_NAMES)
		const mode = PLUG_MODES[plug_name]
		execute mode .. 'unmap <buffer>' plug_name
		if maparg(lhs, mode) == plug_name
			execute mode .. 'unmap <buffer>' lhs
		endif
	endfor
enddef
#}}}
#}}}

# Mappings {{{
if !exists("g:no_plugin_maps") && !exists("g:no_c_maps")
	for [lhs, plug_name] in items(PLUG_NAMES)
		if !hasmapto(plug_name)
			execute PLUG_MODES[plug_name]
				.. 'map <buffer> <unique>' lhs plug_name
		endif
	endfor
	nnoremap <buffer> <unique> <Plug>c_make; <Cmd>make<CR>
	xnoremap <buffer> <silent> <unique> <Plug>c_comment;
	       \ :<Home>silent <End>call klen#ft#c#v_toggle_comment()<CR>
endif
#}}}

# Register commands.
call setreg('c', "I// \<Esc>j")			# Comment
call setreg('u', "^3xj")			# Uncomment
call setreg('i', "F r{A};\<Esc>")		# Initialize
call setreg('s', "F r{A},\<Esc>j$")		# comma-Separated initialize
call setreg('n', "[{hD]}dd")			# No braces
call setreg('b', "A {\<Esc>jo}\<Esc>k^")	# Braces
