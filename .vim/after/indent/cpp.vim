vim9script
# Script overruling and adding to the distributed "cpp.vim" indent file.
# Language:	C++
# Maintainer:	Kenny Lam
# Last Change:	2022 Feb 28

b:undo_indent ..= "| setl cino<"

# 'cindent' is enabled in the distributed "cpp.vim" indent script.

# No further indenting of case labels in switch statements; no further
# indenting of scope declarations; and align lines to the first non-whitespace
# character after an unmatched opening parenthesis, including those at one
# nesting level deeper.
setlocal cinoptions+=:0,g0,(0,u0
