" Vim filetype plugin for cpp files.
" 2021 Dec 10 - Written by Kenny Lam.

if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

let b:undo_ftplugin = "call " .. expand("<SID>") .. "undo_ftplugin()"

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
		setlocal
			\ cindent<
			\ copyindent<
			\ formatoptions<
			\ path<
			\ textwidth<

		xunmap <buffer> <Plug>cpp_comment;
		if maparg(g:maplocalleader .. 'c', 'x')
		 \ ==# '<Plug>cpp_comment;'
			xunmap <buffer> <LocalLeader>c
		endif
	endfunction
endif

if !exists("*s:v_toggle_comment")
	" Comment out lines selected in Visual mode if the first of such lines
	" is not commented. Otherwise, uncomment them.
	function s:v_toggle_comment() range
		let l:range = a:firstline .. ',' .. a:lastline
		if getline(a:firstline) =~ '\v^\s*//'
			execute l:range .. 'substitute`\v^\s*\zs// ?``'
		else
			execute l:range .. 'substitute`\v^%(// )?`// `'
		endif
		nohlsearch
	endfunction
endif
" }}}

" Mappings {{{
" Comment out lines selected in Visual mode.
if !exists("no_plugin_maps") && !exists("no_cpp_maps")
	if !hasmapto('<Plug>cpp_comment;')
		xmap <buffer> <unique> <LocalLeader>c <Plug>cpp_comment;
	endif
	xnoremap <buffer> <silent> <unique> <Plug>cpp_comment;
		\ :<Home>silent <End>call <SID>v_toggle_comment()<CR>
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
