" Library of general functions.
" Documentation supplied in klen_lib.txt.
"
" 2021 Oct 25 - Written by Kenny Lam.

let s:save_cpo = &cpoptions
set cpoptions&vim

function klen#genlib#peek(stack)
	" klen#genlib#peek() implementation {{{
	return a:stack[len(a:stack) - 1]
endfunction
"}}}

function klen#genlib#pop(stack)
	" klen#genlib#pop() implementation {{{
	call remove(a:stack, len(a:stack) - 1)
endfunction
"}}}

function klen#genlib#push(stack, item)
	" klen#genlib#push() implementation {{{
	call add(a:stack, a:item)
endfunction
"}}}

function klen#genlib#cursor_char(prev = v:false, pat = '')
	" klen#genlib#cursor_char() implementation {{{
	let l:csr_line = getline('.')
	let l:csr_idx = charcol('.') - 1
	let l:csr_char = ''
	if a:prev
		for i in range(l:csr_idx - 1, 0, -1)
			let l:char = slice(l:csr_line, i, i + 1)
			if l:char =~ a:pat
				let l:csr_char = l:char
				break
			endif
		endfor
	else
		for l:char in slice(l:csr_line, l:csr_idx)
			if l:char =~ a:pat
				let l:csr_char = l:char
				break
			endif
		endfor
	endif
	return l:csr_char
endfunction
"}}}

function klen#genlib#cursor_char_byte(prev = v:false, pat = '')
	" klen#genlib#cursor_char_byte() implementation {{{
	let l:csr_line = getline('.')
	let l:csr_idx = charcol('.') - 1
	let l:c_bidx = -1
	if a:prev
		for i in range(l:csr_idx - 1, 0, -1)
			let l:char = slice(l:csr_line, i, i + 1)
			if l:char =~ a:pat
				let l:c_bidx = i
				break
			endif
		endfor
	else
		for i in range(l:csr_idx, strcharlen(l:csr_line) - 1)
			let l:char = slice(l:csr_line, i, i + 1)
			if l:char =~ a:pat
				let l:c_bidx = i
				break
			endif
		endfor
	endif
	return byteidx(l:csr_line, l:c_bidx)
endfunction
"}}}

let &cpoptions = s:save_cpo
