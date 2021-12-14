" Library of string functions.
" Documentation supplied in klen_lib.txt.
"
" 2021 Oct 25 - Written by Kenny Lam.

let s:save_cpo = &cpoptions
set cpoptions&vim

function klen#str#byteidx_quote_positions(string, index)
	" klen#str#byteidx_quote_positions() implementation {{{
	" Strings delimited by single quotes and strings delimited by double
	" quotes do not overlap, so they can be merged and sorted correctly.
	let [l:quote_indices, l:unmatched_bidx]
		\ = s:find_quotes(a:string, '', v:true, v:true)
	let l:unmatched_bidx = get(l:unmatched_bidx, 0, -1)

	" Case 1: char at a:index is delimiter of a string.
	let i = index(l:quote_indices, a:index)
	if i >= 0
		return and(i, 1) ? [l:quote_indices[i - 1], l:quote_indices[i]]
			       \ : [l:quote_indices[i], l:quote_indices[i + 1]]
	endif

	" Case 2: a:index is in an unterminated string.
	if 0 <= l:unmatched_bidx && l:unmatched_bidx <= a:index
		return [l:unmatched_bidx, -1]
	endif

	" Case 3: a:index is within a string.
	call sort(l:quote_indices, 'f')
	for i in range(len(l:quote_indices))
		if l:quote_indices[i] > a:index
			if and(i, 1)
				return [l:quote_indices[i - 1],
				      \ l:quote_indices[i]]
			else
				break
			endif
		endif
	endfor
	return [-1, -1]
endfunction
"}}}

function klen#str#char_escaped(string, index, char = '\')
	" klen#str#char_escaped() implementation {{{
	let l:n_backs = 0
	for i in range(charidx(a:string, a:index) - 1, 0, -1)
		if slice(a:string, i, i + 1) ==# a:char
			let l:n_backs += 1
		else
			break
		endif
	endfor
	return and(l:n_backs, 1)
endfunction
"}}}

function klen#str#get_delimiters(string, delims, unmatched = v:false)
	" klen#str#get_delimiters() implementation {{{
	let l:matched_delims = [[], []]
	let l:unmatched_delims = [[], []]
	let l:next_opendelim_idx  = stridx(a:string, a:delims[0])
	let l:next_closedelim_idx = stridx(a:string, a:delims[1])
	while l:next_opendelim_idx != -1 || l:next_closedelim_idx != -1
		if l:next_opendelim_idx == -1
			let l:next_opendelim_idx = 0x7fffffff
		elseif l:next_closedelim_idx == -1
			let l:next_closedelim_idx = 0x7fffffff
		endif
		if l:next_opendelim_idx < l:next_closedelim_idx
			call klen#genlib#push(l:unmatched_delims[0],
					    \ l:next_opendelim_idx)
			let l:start_idx = l:next_opendelim_idx + 1
		else
			if !empty(l:unmatched_delims[0])
				call klen#genlib#push(l:matched_delims[0],
				   \ klen#genlib#peek(l:unmatched_delims[0]))
				call klen#genlib#push(l:matched_delims[1],
						    \ l:next_closedelim_idx)
				call klen#genlib#pop(l:unmatched_delims[0])
			else
				call klen#genlib#push(l:unmatched_delims[1],
						    \ l:next_closedelim_idx)
			endif
			let l:start_idx = l:next_closedelim_idx + 1
		endif
		let l:next_opendelim_idx  = stridx(a:string, a:delims[0],
						 \ l:start_idx)
		let l:next_closedelim_idx = stridx(a:string, a:delims[1],
						 \ l:start_idx)
	endwhile
	return (a:unmatched) ? l:matched_delims + l:unmatched_delims
			   \ : l:matched_delims
endfunction
"}}}

function klen#str#get_same_delimiters(string, delim, unmatched = v:false)
	" klen#str#get_same_delimiters() implementation {{{
	if a:delim ==# '"' || a:delim ==# "'"
		return s:find_quotes(a:string, a:delim, a:unmatched)
	endif
	let l:matched = []
	let l:unmatched = []
	let i = 0
	while i < len(a:string)
		if a:string[i] ==# a:delim
			if empty(l:unmatched)
				call klen#genlib#push(l:unmatched, i)
			else
				call klen#genlib#push(l:matched,
					\ klen#genlib#peek(l:unmatched))
				call klen#genlib#push(l:matched, i)
				call klen#genlib#pop(l:unmatched)
			endif
		endif
		let i += 1
	endwhile
	return (a:unmatched) ? [l:matched, l:unmatched] : l:matched
endfunction
"}}}

function klen#str#match_chars(expr, pat, start, end)
	" klen#str#match_chars() implementation {{{
	let l:start = a:start
	let l:end = a:end
	if type(a:expr) == v:t_string
		return s:str_match_chars(a:expr, a:pat, a:start, a:end)
	endif
	" Argument checking {{{
	if type(l:start) == v:t_number
		let l:start = [0, l:start]
	endif
	if type(l:end) == v:t_number
		let l:end = [len(a:expr) - 1, l:end]
	endif
	if l:end[0] < l:start[0] || l:start[0] == l:end[0]
	 \ && l:end[1] < l:start[1]
		return -1
	endif
	if l:start[1] < 0
		let l:start[1] = 0
	endif
	if l:end[1] < 0
		let l:end[1] = 0
	endif
	"}}}
	let l:n_chars = 0
	if l:start[0] == l:end[0]
		for l:char in split(slice(a:expr[l:start[0]], l:start[1],
					\ l:end[1]), '\zs')
			if l:char !~ a:pat
				return -1
			endif
			let l:n_chars += !&delcombine ?? strchars(l:char)
		endfor
		return l:n_chars
	endif
	for l:char in split(slice(a:expr[l:start[0]], l:start[1]), '\zs')
		if l:char !~ a:pat
			return -1
		endif
		let l:n_chars += !&delcombine ?? strchars(l:char)
	endfor
	" Account for new line.
	let l:n_chars += 1
	for l:str in a:expr[l:start[0] + 1 : l:end[0] - 1]
		for l:char in split(l:str, '\zs')
			if l:char !~ a:pat
				return -1
			endif
			let l:n_chars += !&delcombine ?? strchars(l:char)
		endfor
		let l:n_chars += 1
	endfor
	for l:char in split(slice(a:expr[l:end[0]], 0, l:end[1]), '\zs')
		if l:char !~ a:pat
			return -1
		endif
		let l:n_chars += !&delcombine ?? strchars(l:char)
	endfor
	return l:n_chars
endfunction
"}}}

" Local functions
function s:find_quotes(string, quote, unmatched = v:false, both = v:false)
	" If both is true, returns a List containing the byte indices of both
	" single quotes and double quotes. Quote is ignored in this case.
	"
	" A string is defined to be a sequence of characters delimited by
	" either single quotes or double quotes, where the opening quote
	" succeeds the start of line or a non-word character. Strings cannot be
	" nested, and they cannot span across multiple lines. Instances of the
	" quote delimiting a string can be used within the same string so long
	" as they are escaped with backslashes. Quotes within a string
	" delimited by the alternative quotes have no special meaning,
	" regardless of whether they are escaped.
	" s:find_quotes() implementation {{{
	let l:matched = []
	let l:unmatched = []
	" in_str  : True if inside a string.
	" quote   : Quote type of the surrounding string.
	" n_backs : Number of sequential backslashes before current character.
	" pc_is_wc: True if previous character is a word character.
	let l:state = #{
		\ in_str  : v:false,
		\ quote   : '',
		\ n_backs : 0,
		\ pc_is_wc: v:false,
	\ }
	let l:qt_pat = (a:both) ? '''\|"' : a:quote
	let l:bidx = 0	" Byte index of current character.
	for c in split(a:string, '\zs')
		" Track a valid instance of argument quote.
		if c =~ l:qt_pat
			if !l:state.in_str && !l:state.pc_is_wc
			 \ || l:state.in_str && l:state.quote ==# c
			 \ && !and(l:state.n_backs, 1)
				if empty(l:unmatched)
					call klen#genlib#push(l:unmatched,
							    \ l:bidx)
				else
					call klen#genlib#push(l:matched,
					   \ klen#genlib#peek(l:unmatched))
					call klen#genlib#push(l:matched,
							    \ l:bidx)
					call klen#genlib#pop(l:unmatched)
				endif
			endif
		endif
		" Update state.
		if c ==# "'" || c ==# '"'
			if !l:state.in_str && !l:state.pc_is_wc
				let l:state.in_str = v:true
				let l:state.quote = c
			elseif l:state.in_str && l:state.quote ==# c
			     \ && !and(l:state.n_backs, 1)
				let l:state.in_str = v:false
			endif
		endif
		if c ==# '\'
			let l:state.n_backs += 1
		else
			let l:state.n_backs = 0
		endif
		let l:state.pc_is_wc = c =~ '\w'
		let l:bidx += strlen(c)
	endfor
	return (a:unmatched) ? [l:matched, l:unmatched] : l:matched
endfunction
"}}}

function s:str_match_chars(string, pat, start, end)
	" s:str_match_chars() implementation {{{
	let l:start = a:start
	if l:start < 0
		let l:start = 0
	endif
	if a:end < l:start
		return -1
	endif
	let l:n_chars = 0
	for l:char in split(slice(a:string, l:start, a:end), '\zs')
		if l:char !~ a:pat
			return -1
		endif
		let l:n_chars += !&delcombine ?? strchars(l:char)
	endfor
	return l:n_chars
endfunction
"}}}

let &cpoptions = s:save_cpo
