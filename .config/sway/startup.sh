#!/usr/bin/bash

swaymsg 'workspace 1'

# Start tmux; $term_options is set by `kanshi`
swaymsg 'exec $term $term_options -e tmux'

### Open an ASCII table in the scratchpad for reference ###
# Delay opening this terminal window until the initial terminal window is
# opened to guarantee the ordering of `tmux` sessions.
swaymsg 'exec "sleep 1; $term $term_options -e tmux new-session -sref"'
# Wait a couple of seconds so that the new `tmux` session completes
# initialization before sending keys to it. (Add one second because these
# "exec" commands execute simultaneously.)
swaymsg 'exec "sleep 3; tmux send-keys -tref source Space ~/.scratchpad/.zshrc Enter"'
