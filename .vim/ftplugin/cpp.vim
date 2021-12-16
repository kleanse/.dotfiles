" Vim filetype plugin for cpp files.
" 2021 Dec 10 - Written by Kenny Lam.

if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

let b:undo_ftplugin = "call " .. expand("<SID>") .. "undo_ftplugin()"

" Associates default key sequences with plugin mappings.
let s:plug_names = {
	\ g:maplocalleader .. 'c': '<Plug>cpp_comment;',
	\ g:maplocalleader .. 'm': '<Plug>cpp_multiline_comment;',
\ }

setlocal
	\ cindent
	\ copyindent
	\ formatoptions=tcroqlj
	\ path+=include,../include
	\ textwidth=79

" Linux kernel coding style.
setlocal cinoptions=:0,g0,(0,u0

" Internal functions {{{
if !exists("*s:undo_ftplugin")
	function s:undo_ftplugin()
		" s:undo_ftplugin() implementation {{{
		setlocal
			\ cindent<
			\ copyindent<
			\ formatoptions<
			\ path<
			\ textwidth<

		for [l:lhs, l:plug_name] in items(s:plug_names)
			execute 'xunmap <buffer>' l:plug_name
			if maparg(l:lhs, 'x') ==# l:plug_name
				execute 'xunmap <buffer>' l:lhs
			endif
		endfor
	endfunction
	" }}}
endif

if !exists("*s:v_toggle_comment")
	" Comment out lines selected in Visual mode if the first of such lines
	" is not commented. Otherwise, uncomment them. The comment style is
	" C++.
	function s:v_toggle_comment() range
		" s:v_toggle_comment() implementation {{{
		let l:range = a:firstline .. ',' .. a:lastline
		if getline(a:firstline) =~ '\v^\s*//'
			execute l:range .. 'substitute`\v^\s*\zs// ?``'
		else
			execute l:range .. 'substitute`\v^%(// )?`// `'
		endif
		nohlsearch
	endfunction
	" }}}
endif
" }}}

" Mappings {{{
if !exists("no_plugin_maps") && !exists("no_cpp_maps")
	for [s:lhs, s:plug_name] in items(s:plug_names)
		if !hasmapto(s:plug_name)
			execute 'xmap <buffer> <unique>' s:lhs s:plug_name
		endif
	endfor
	unlet s:lhs s:plug_name
	xnoremap <buffer> <silent> <unique> <Plug>cpp_comment;
	       \ :<Home>silent <End>call <SID>v_toggle_comment()<CR>
	xnoremap <buffer> <silent> <unique> <Plug>cpp_multiline_comment;
	       \ :<Home>silent <End>call klen#ft#c#v_toggle_comment()<CR>
endif
"}}}

" Register commands.
call setreg('c', "I// j")      " Comment
call setreg('u', "^3xj")         " Uncomment
call setreg('i', "F r{A};")    " Initialize
call setreg('s', "F r{A},j$")  " comma-Separated initialize
call setreg('n', "[{hD]}dd")     " No braces
call setreg('b', "A {jo}k^") " Braces

let &cpoptions = s:save_cpo
