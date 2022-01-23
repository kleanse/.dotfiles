vim9script
unlet! g:skip_defaults_vim
source $VIMRUNTIME/defaults.vim

const TEMPLATE_PATH = '~/vim/'

# Set options in alphabetical order.
set
	\ autoindent
	\ copyindent
	\ hlsearch
	\ nojoinspaces
	\ listchars=tab:--\|
	\ textwidth=79
	\ wildmode=longest,list
	\ nowrapscan

filetype plugin indent on

# User-defined functions. {{{
def g:Date(): string
	return strftime("%Y %b %d")
enddef

def g:Trim_peripheral_blank_lines()
	# g:Trim_peripheral_blank_lines() implementation {{{
	const total_lines = line("$")

	var n_starting_blank_lines = 0
	for i in range(1, total_lines)
		if getline(i) =~ '\S'
			break
		endif
		++n_starting_blank_lines
	endfor

	var n_ending_blank_lines = 0
	for i in range(total_lines, 1, -1)
		if getline(i) =~ '\S'
			break
		endif
		++n_ending_blank_lines
	endfor

	# Delete ending lines first; doing the reverse messes the line count
	# for the ending lines.
	deletebufline("%", total_lines - n_ending_blank_lines + 1, total_lines)
	deletebufline("%", 1, n_starting_blank_lines)

	const n_lines_deleted = n_starting_blank_lines + n_ending_blank_lines

	if n_lines_deleted == total_lines
		echomsg "--No lines in buffer--"
	elseif n_lines_deleted > &report
		echomsg (n_lines_deleted == 1)
			? n_lines_deleted .. " line less"
			: n_lines_deleted .. " fewer lines"
	endif
enddef
# }}}

def g:Trim_whitespace()
	# g:Trim_whitespace() implementation {{{
	const save_view = winsaveview()
	const save_search = getreg('/')
	:%substitute/\v\s+$//e
	winrestview(save_view)
	setreg('/', save_search)
enddef
# }}}
# }}}

# Internal functions. {{{
# Expects: the current buffer is empty.
# Ensures: read the template file with the extension or suffix {ext} into the
#	   current buffer and set the cursor's position to {curpos}. See
#	   TEMPLATE_PATH for where template files are searched.
def Load_template_file(ext: string, curpos: list<number>)
	# Load_template_file() implementation {{{
	silent execute "read" TEMPLATE_PATH .. "template" .. ext
	deletebufline("%", 1)
	cursor(curpos)
enddef
# }}}

def Set_header_macros()
	# Set_header_macros() implementation {{{
	const macro_name = ' ' .. expand("%:t")->toupper()->substitute(
				  '\.', '_' .. strftime("%m%d%Y") .. '_', '')
	setline(1, getline(1) .. macro_name)
	setline(2, getline(2) .. macro_name)
	setline('$', getline('$') .. ' //' .. macro_name)
enddef
# }}}

def Set_spell_highlights()
	# Set_spell_highlights() implementation {{{
	highlight SpellBad   cterm=nocombine ctermfg=15 ctermbg=1
	highlight SpellCap   cterm=nocombine ctermfg=15 ctermbg=4
	highlight SpellRare  cterm=nocombine ctermfg=15 ctermbg=5
	highlight SpellLocal cterm=nocombine ctermfg=15 ctermbg=6
	highlight MatchParen cterm=underline		ctermbg=7
enddef
# }}}

def Update_last_change()
	# Update_last_change() implementation {{{
	if &filetype == "help"
		setline(1, getline(1)->substitute(
			   '\v(Last change:).*$', '\1 ' .. Date(), ''))
	endif
enddef
# }}}
# }}}

# Autocommands {{{
augroup vimrc
	# Remove all vimrc autocommands.
	autocmd!
	autocmd BufNewFile  *.c       Load_template_file(".c", [5, 1])
					| startinsert!
					| redrawstatus
	autocmd BufNewFile  *.cpp     Load_template_file(".cpp", [5, 1])
					| startinsert!
					| redrawstatus
	autocmd BufNewFile  *.h       Load_template_file(".h", [4, 1])
					| Set_header_macros()
					| startinsert!
					| redrawstatus
	autocmd BufNewFile  Makefile  Load_template_file("_makefile", [2, 1])
					| execute "normal! A "
					| startinsert!
					| redrawstatus
	autocmd BufWritePre *	      silent Trim_peripheral_blank_lines()
					| silent Trim_whitespace()
					| retab
	autocmd BufWritePre *.txt     silent Update_last_change()
	autocmd ColorScheme solarized silent Set_spell_highlights()

	# Disable the insertion of spaces with <Tab> when editing a
	# Makefile. Note that some options have been set already and
	# are thus redundant. However, this verbosity is intended and
	# is part of this script's structure: files that require a
	# particular set of options will specify it fully, regardless
	# of its options' previous values. This practice enables such
	# option sets to be changed and understood more easily.
	#
	# Note that view-based options should be constant across all
	# file types to maintain a uniform editor appearance. Options
	# such as formatting ones are safe and even necessary to change
	# for specific file types.
	autocmd FileType make setlocal
		\ autoindent
		\ noexpandtab
		\ formatoptions-=t
		\ textwidth=79

	autocmd FileType python setlocal
		\ autoindent
		\ formatoptions=tcroqlj
		\ textwidth=79

	autocmd FileType vim setlocal
		\ autoindent
		\ copyindent
		\ foldmethod=marker
		\ formatoptions=tcroqlj
		\ textwidth=79

augroup END
# }}}

set background=light
colorscheme solarized

# Abbreviations {{{
inoreabbrev lc: Last change:
# }}}

# Commands {{{
# Like ":retab", but behaves like 'expandtab' is inverted, i.e., <Tab>s become
# spaces if 'expandtab' is off, and spaces become <Tab>s if 'expandtab' is on.
# Mnemonic: Inverted retab
# Use:
#	:[range]Iretab[!] [new_tabstop]
command -bang -range=% -nargs=? Iretab let &expandtab = !&expandtab
				       | <line1>,<line2>retab<bang> <args>
				       | let &expandtab = !&expandtab
# }}}

# Key mappings {{{
g:mapleader = ","
g:maplocalleader = g:mapleader

# Remap Normal-mode commands ";" and "," to different keys for delay-free ","
# behavior while using such a key for mapleader.
noremap  + ;
noremap  _ ,

# Quickly edit and source the vimrc file.
nnoremap <special> <Leader>ev :split $MYVIMRC<CR>
nnoremap <special> <Leader>sv :source $MYVIMRC<CR>

# Make "Y" consistent with "C" and "D".
nnoremap Y y$

# Keep cursor centered when repeating searches, opening any closed folds if
# necessary.
nnoremap n nzvzz
nnoremap N Nzvzz

# Disable highlighting for 'hlsearch'.
nnoremap <special> <Leader>h <Cmd>nohlsearch<CR>

# Toggle 'colorcolumn'.
nnoremap <special> <Leader>cc
	\ <Cmd>let &colorcolumn = (empty(&colorcolumn)) ? "+1" : ""<CR>

# Toggle 'list'
nnoremap <special> <Leader>l <Cmd>let &list = !&list<CR>

# Toggle 'spell'
nnoremap <special> <Leader>sp <Cmd>let &spell = !&spell<CR>

# Toggle 'virtualedit'.
nnoremap <special> <Leader>ve
	\ <Cmd>let &virtualedit = (empty(&virtualedit)) ? "all" : ""
	\ <Bar> set virtualedit?<CR>

# Toggle syntax highlighting: useful for editing help files.
nnoremap <special> <Leader>x
	\ <Cmd>if exists("g:syntax_on")
		\ <Bar> syntax off
	\ <Bar> else
		\ <Bar> syntax enable
	\ <Bar> endif<CR>

# Access system clipboard.
nnoremap <special> <Leader>p "+p
nnoremap <special> <Leader>P "+P
xnoremap <special> <Leader>p "-d"+P
xnoremap <special> <Leader>y "+y
xnoremap <special> <Leader>x "+d

# Move text in Visual mode. Visual-mode "J" and "K" are overwritten; for the
# former command, use ":join" instead. The latter might not need addressed:
# Visual-mode "K" is rare.
xnoremap <special> J :move '>+1<CR>gv=gv
xnoremap <special> K :move '<-2<CR>gv=gv

# Use CTRL-C for <Esc>: it is easier to reach.
inoremap <special> <C-C> <Esc>
xnoremap <special> <C-C> <Esc>

# Use some common GNU-Readline keyboard shortcuts for the Command line.
#     Set meta-key keycodes to what the terminal receives (can be identified by
# running "cat" without any arguments and entering the corresponding keys).
execute "set <M-F>=\<Esc>f"
execute "set <M-B>=\<Esc>b"
# Overwrite the Command-line commands CTRL-A, CTRL-B, and CTRL-F. CTRL-A is not
# useful; CTRL-B's behavior is moved to CTRL-A; and CTRL-F expedites editing
# complex commands.
cnoremap <special> <C-A> <Home>
cnoremap <special> <C-B> <Left>
cnoremap <special> <C-F> <Right>
cnoremap <special> <M-B> <S-Left>
cnoremap <special> <M-F> <S-Right>

# Transfer the default behavior of Command-line CTRL-F to CTRL-X.
cnoremap <special> <C-X> <C-F>

# Trim trailing whitespace.
# Mnemonic: "Trim WhiteSpace" or "Trailing WhiteSpace".
cnoremap <special> <Leader>tws call Trim_whitespace()
# Trim blank lines at the start and end of a file.
# Mnemonic: "Trim Blank Lines".
cnoremap <special> <Leader>tbl call Trim_peripheral_blank_lines()
# Trim blank lines at the start and end of a file and trailing whitespace.
# Mnemonic: "Trim All Excess".
cmap     <special> <Leader>tae <Leader>tbl <Bar> <Leader>tws

# Discard stdout from tee with '> /dev/null'
cnoremap <special> <Leader>w! w !sudo tee > /dev/null %
# }}}
