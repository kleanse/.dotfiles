vim9script
# Filetype plugin for Io files.
# Language:	Io
# Maintainer:	Kenny Lam
# Last Change:	2023 Mar 26

# Undo the side effects of this script.
b:undo_ftplugin = "| call " .. expand("<SID>") .. "Undo_ftplugin()"

# Associates default key sequences with plugin mappings.
const PLUG_NAMES = {
	[g:maplocalleader .. 'C']: '<Plug>io_c_comment;',
	[g:maplocalleader .. 'c']: '<Plug>io_comment;',
	[g:maplocalleader .. 'r']: '<Plug>io_run;',
}

# Associates plugin mappings with mapping modes (see "map-modes").
const PLUG_MODES = {
	'<Plug>io_c_comment;': 'x',
	'<Plug>io_comment;': 'x',
	'<Plug>io_run;': 'n',
}

setlocal formatoptions+=tcroqlj
setlocal path+=include,../include
setlocal textwidth=79

# Internal functions {{{
if !exists("*Undo_ftplugin")
def Undo_ftplugin()
	# Undo_ftplugin() implementation {{{
	setlocal formatoptions<
	setlocal path<
	setlocal textwidth<

	for [lhs, plug_name] in items(PLUG_NAMES)
		const mode = PLUG_MODES[plug_name]
		execute mode .. 'unmap <buffer>' plug_name
		if maparg(lhs, mode) == plug_name
			execute mode .. 'unmap <buffer>' lhs
		endif
	endfor
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
	if getline(a:firstline) =~ '\v^\s*#'
		execute l:range .. 'substitute`\v^\s*\zs# ?``'
	else
		execute l:range .. 'substitute`\v^%(# )?`# `'
	endif
	nohlsearch
endfunction
# }}}
endif

if !exists("*V_toggle_c_comment")
# Comment out lines selected in Visual mode if the first of such lines is not
# commented. Otherwise, uncomment them. (Note that this function is defined
# with ":function" so that "range" can be used; legacy syntax is in force.)
function V_toggle_c_comment() range
	" V_toggle_c_comment() implementation {{{
	let l:save_search = getreg('/')
	let l:range = a:firstline .. ',' .. a:lastline
	let l:xrange = (a:firstline + 1) .. ',' .. (a:lastline - 1)
	if getline(a:firstline) =~ '\v^\s*%(/\*|\*)'
		" First line is a comment: uncomment selected lines.
		if a:firstline == a:lastline
			execute a:firstline .. 's`\v^\s*\zs%(/\* ?| \* ?)``'
			execute a:firstline .. 's`\v\s*\*/\s*$``e'
		else
			execute l:range .. 's`\v^\s*\zs%(/\* ?| \*/| \* ?)``e'
		endif
	elseif a:firstline == a:lastline
		" Comment the one selected line.
		execute a:firstline .. 's`\v^`/\* `'
		execute a:firstline .. 's`\v$` \*/`'
	else
		" Comment selected lines.
		execute a:firstline .. 's`\v^`/\* `'
		if a:firstline + 1 <= a:lastline - 1
			execute l:xrange .. 's`\v^%(/\* | \* )?` \* `'
		endif
		if getline(a:lastline) =~ '\v^\s*%(\*/)?\s*$'
			call setline(a:lastline, ' */')
		else
			execute a:lastline .. 's`\v^%(/\* | \* )?` \* `'
			let l:next_line = a:lastline + 1
			if l:next_line <= line('$')
			 \ && getline(l:next_line) =~ '\v^\s*%(\*/)?\s*$'
				call setline(l:next_line, ' */')
			else
				call append(a:lastline, ' */')
			endif
			let l:save_vstart = getpos("'<")
			let l:vend = getpos("'>")
			let l:vend[1] += 1
			call setpos("'>", l:vend)
			call setpos("'<", l:save_vstart)
		endif
	endif
	nohlsearch
	call setreg('/', l:save_search)
endfunction
# }}}
endif
# }}}

# Mappings {{{
if !exists("g:no_plugin_maps") && !exists("g:no_io_maps")
	for [lhs, plug_name] in items(PLUG_NAMES)
		if !hasmapto(plug_name)
			execute PLUG_MODES[plug_name]
				.. 'map <buffer> <unique>' lhs plug_name
		endif
	endfor
	nnoremap <buffer> <unique> <Plug>io_run;
	       \ <Cmd>execute "!io " .. shellescape(expand("%"))<CR>
	xnoremap <buffer> <silent> <unique> <Plug>io_c_comment;
	       \ :<Home>silent <End>call <SID>V_toggle_c_comment()<CR>
	xnoremap <buffer> <silent> <unique> <Plug>io_comment;
	       \ :<Home>silent <End>call <SID>V_toggle_comment()<CR>
endif
# }}}
