vim9script
unlet! g:skip_defaults_vim
source $VIMRUNTIME/defaults.vim

const TEMPLATE_PATH = '~/vim/'

# Set options in alphabetical order.
set
	\ autoindent
	\ copyindent
	\ hlsearch
	\ listchars=tab:--\|
	\ nojoinspaces
	\ nowrapscan
	\ textwidth=79
	\ visualbell t_vb=
	\ wildmode=longest,list

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
	if n_starting_blank_lines != total_lines
		for i in range(total_lines, 1, -1)
			if getline(i) =~ '\S'
				break
			endif
			++n_ending_blank_lines
		endfor
	endif

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


# Functions for mimicking GNU-Readline shortcuts {{{

# Data used for the overloaded Command-line keys CTRL-U and CTRL-W and
# overwritten Command-line key CTRL-Y.
final CMDLINE = {
	buf: "",	# String that can be pasted with Command-line CTRL-Y.
	lastpos: -1,	# The cursor position of the last post-backward-kill
			# operation.
	lastline: "",	# The line of the last post-backward-kill operation.
}

# Used for overloading Command-line CTRL-U and CTRL-W.
# Expects: mode() == "c" && {delchar} is a backspacing character (e.g.,
#	   "\<BS>", "\<C-H>", "\<C-W>", etc.).
# Ensures: returns a string to be interpreted in the {rhs} of a mapping. This
#	   string effectively saves the string deleted by {delchar} into a
#	   local buffer. If this function is invoked in succession, the deleted
#	   strings are concatenated.
def Backward_kill_pre(delchar: string): string
	# Backward_kill_pre() implementation {{{
	const curpos = getcmdpos()
	const curline = getcmdline()
	if curpos != 1
	   && (curpos != CMDLINE.lastpos || curline != CMDLINE.lastline)
		CMDLINE.buf = ""
	endif
	return delchar .. "\<ScriptCmd>Backward_kill_post('"
		.. curline->substitute("'", "''", "g") .. "', "
		.. curpos .. ")\<CR>"
enddef
# }}}

# Expects: {preline} is the Command-line line and {prepos} is the Command-line
#	   position of a pre-backward-kill operation.
#	   mode() == "c" && 1 <= {prepos} <= len({preline})
# Ensures: the string between {prepos} and the current position on {preline} is
#	   prepended to a local buffer (not a register so that data is not
#	   clobbered).
def Backward_kill_post(preline: string, prepos: number)
	# Backward_kill_post() implementation {{{
	const curpos = getcmdpos()
	const deleted_str = (prepos == 1) ? ""
					  : preline[curpos - 1 : prepos - 2]
	CMDLINE.buf = deleted_str .. CMDLINE.buf
	CMDLINE.lastpos = curpos
	CMDLINE.lastline = getcmdline()
enddef
# }}}

# Expects: none
# Ensures: returns a string to be interpreted in the {rhs} of a mapping. This
#	   string effectively deletes the character under the cursor if such a
#	   character exists; otherwise, it lists the names that match the
#	   pattern in front of the cursor (i.e., the default behavior of
#	   Command-line CTRL-D).
def Delete_char_or_list(): string
	# Delete_char_or_list() implementation {{{
	return (getcmdpos() > getcmdline()->len()) ? "\<C-D>" : "\<Del>"
enddef
# }}}

# Expects: mode() == "c"
# Ensures: returns a string to be interpreted in the {rhs} of a mapping. This
#	   string effectively pastes the content of CMDLINE.buf before the
#	   cursor.
def Put_cmdline_buffer(): string
	# Put_cmdline_buffer implementation {{{
	return "\<C-R>\<C-R>='"
		.. CMDLINE.buf->substitute("'", "''", "g") .. "'\<CR>"
enddef
# }}}
# }}}


# Expects: the current buffer is empty.
# Ensures: read the template file with the extension {ext} into the current
#	   buffer and set the cursor's position to {curpos}. See TEMPLATE_PATH
#	   for where template files are searched.
def Load_template_file(ext: string, curpos: list<number>)
	# Load_template_file() implementation {{{
	silent execute "read" TEMPLATE_PATH .. "template" .. ext
	deletebufline("%", 1)
	cursor(curpos)
enddef
# }}}

# Expects: current buffer is the template file with the ".h" extension found in
#	   TEMPLATE_PATH.
# Ensures: sets the values for the "ifndef" guard in the current file based on
#	   the file's name and current date (yyyymmdd).
def Set_header_macros()
	# Set_header_macros() implementation {{{
	const macro_name = ' ' .. expand("%:t")->toupper()->substitute(
				  '\.', '_' .. strftime("%Y%m%d") .. '_', '')
	setline(1, getline(1) .. macro_name)
	setline(2, getline(2) .. macro_name)
	setline('$', getline('$') .. ' //' .. macro_name)
enddef
# }}}

# Expects: none
# Ensures: change the highlighting of spelling highlight groups.
def Set_spell_highlights()
	# Set_spell_highlights() implementation {{{
	highlight SpellBad   cterm=nocombine ctermfg=15 ctermbg=1
	highlight SpellCap   cterm=nocombine ctermfg=15 ctermbg=4
	highlight SpellRare  cterm=nocombine ctermfg=15 ctermbg=5
	highlight SpellLocal cterm=nocombine ctermfg=15 ctermbg=6
	highlight MatchParen cterm=underline		ctermbg=7
enddef
# }}}

# Expects: none
# Ensures: updates the date found after the first occurrence of the string
#	   "Last change:" in the first 20 lines of the current file. The format
#	   of the new date may be specified (see strftime() for valid formats).
#	   If no format is given, the date returned by g:Date() is used.
def Update_last_change(format = '')
	# Update_last_change() implementation {{{
	const pat = '\vLast [Cc]hange:'
	var limit = 20	# Number of starting lines to read.
	if line('$') < limit
		limit = line('$')
	endif
	for i in range(1, limit)
		const line = getline(i)
		if line =~ pat
			var c = ""
			if line !~ pat .. '\s'
				c = "\t"
			endif
			setline(i, line->substitute(pat .. '\s*\zs.*$',
				   c .. ((format->empty())
					? g:Date() : strftime(format)), ''))
			break
		endif
	endfor
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
	autocmd BufWritePre *	      silent g:Trim_peripheral_blank_lines()
					| silent g:Trim_whitespace()
					| silent Update_last_change()
					| retab
	autocmd ColorScheme solarized
			| try
				| silent Set_spell_highlights()
	#\ Reloading a Vim9 script deletes all existing script-local
	#\ functions and variables. Thus, the above function will not exist
	#\ when this autocmd triggers from a reload. (See "vim9-reload" for
	#\ more information.)
			| catch /^Vim(eval):E117:.*Set_spell_highlights/
			| endtry
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
command -bang -range=% -nargs=? Iretab {
	&expandtab = !&expandtab
	:<line1>,<line2>retab<bang> <args>
	&expandtab = !&expandtab
}
# }}}


# Key mappings {{{
g:mapleader = ","
g:maplocalleader = g:mapleader

# Remap Normal-mode commands ";" and "," to different keys for delay-free ","
# behavior while using such a key for mapleader.
noremap  + ;
noremap  _ ,

# Overwrite Normal-mode ";" to save the current buffer quickly and show all
# listed buffers (so that a buffer switch may be performed without issuing
# ":ls" first).
nnoremap <special> ; <Cmd>update <Bar> buffers<CR>

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
nmap <special> <Leader>p "+p
nmap <special> <Leader>P "+P
xmap <special> <Leader>p "-d"+P
xmap <special> <Leader>y "+y
xmap <special> <Leader>x "+d

# Enable system-clipboard access for the Wayland window system (requires the
# "wl-clipboard" utility program).
if exists("$WAYLAND_DISPLAY")
	nnoremap <special> "+p
			 \ <Cmd>let @+ = system('wl-paste --no-newline')<CR>"+p
	nnoremap <special> "+P
			 \ <Cmd>let @+ = system('wl-paste --no-newline')<CR>"+P
	xnoremap <special> "+y "+y<Cmd>call system('wl-copy', @+)<CR>
	xnoremap <special> "+d "+d<Cmd>call system('wl-copy', @+)<CR>
endif

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

# Overwrite Command-line CTRL-Y: its default behavior is currently not being
# exploited. Also, overload Command-line CTRL-U and CTRL-W: their default
# behaviors are preserved, but, in conjunction with CTRL-Y, they behave similar
# to the corresponding GNU-Readline shortcut keys: text deleted via CTRL-U and
# CTRL-W can be retrieved with CTRL-Y.
cnoremap <special> <expr> <C-U> <SID>Backward_kill_pre("\<C-U>")
cnoremap <special> <expr> <C-W> <SID>Backward_kill_pre("\<C-W>")
cnoremap <special> <expr> <C-Y> <SID>Put_cmdline_buffer()
# Overload Command-line CTRL-D: it still performs its normal behavior, but if a
# character is under the cursor, it executes the GNU-Readline behavior (i.e.,
# delete the character).
cnoremap <special> <expr> <C-D> <SID>Delete_char_or_list()

# Trim trailing whitespace.
# Mnemonic: "Trim WhiteSpace" or "Trailing WhiteSpace".
cnoremap <special> <Leader>tws call g:Trim_whitespace()
# Trim blank lines at the start and end of a file.
# Mnemonic: "Trim Blank Lines".
cnoremap <special> <Leader>tbl call g:Trim_peripheral_blank_lines()
# Trim blank lines at the start and end of a file and trailing whitespace.
# Mnemonic: "Trim All Excess".
cmap     <special> <Leader>tae <Leader>tbl <Bar> <Leader>tws

# Clever trick to write files belonging to the root user when Vim was launched
# without super user privileges. Ignore standard output from 'tee' by piping it
# to /dev/null, i.e., '> /dev/null'.
cnoremap <special> <Leader>w! w !sudo tee "%" > /dev/null
# }}}
