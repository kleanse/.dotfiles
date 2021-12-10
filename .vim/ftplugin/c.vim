" Vim filetype plugin for c files.
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
setlocal cinoptions=:0,(0,u0

" Internal functions {{{
if !exists("*s:undo_ftplugin")
	function s:undo_ftplugin()
		setlocal
			\ cindent<
			\ copyindent<
			\ formatoptions<
			\ path<
			\ textwidth<

		xunmap <buffer> <Plug>c_comment;
	endfunction
endif

if !exists("*s:v_toggle_comment")
	" Comment out lines selected in Visual mode if the first of such lines
	" is not commented. Otherwise, uncomment them.
	function s:v_toggle_comment() range
		let l:range = a:firstline .. ',' .. a:lastline
		let l:xrange = (a:firstline + 1) .. ',' .. (a:lastline - 1)
		if getline(a:firstline) =~ '\v^%(/\* | \* )'
			execute l:range .. 'substitute`\v^%(/\* | \* | \*/)?``'
		else
			execute a:firstline .. 'substitute`\v^`/\* `'
			if a:firstline + 1 <= a:lastline - 1
				execute l:xrange
				      \ .. 'substitute`\v^%(/\* | \* )?` \* `'
			endif
			if getline(a:lastline) =~ '\v^%( \*/)?\s*$'
				call setline(a:lastline, ' */')
			else
				execute a:lastline
				      \ .. 'substitute`\v^%(/\* | \* )?` \* `'
				let l:next_line = a:lastline + 1
				if l:next_line <= line('$')
				 \ && getline(l:next_line) =~ '\v^%( \*/)?\s*$'
					call setline(l:next_line, ' */')
				else
					call append(a:lastline, ' */')
				endif
			endif
		endif
		nohlsearch
	endfunction
endif
" }}}

" Mappings {{{
" Comment out lines selected in Visual mode.
if !exists("no_plugin_maps") && !exists("no_c_maps")
	if !hasmapto('<Plug>c_comment;')
		xmap <buffer> <unique> <LocalLeader>c <Plug>c_comment;
	endif
	xnoremap <buffer> <silent> <unique> <Plug>c_comment;
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
