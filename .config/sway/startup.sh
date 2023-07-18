#!/usr/bin/bash

swaymsg 'workspace 2'

swaymsg 'exec $browser'
# Let web browser finish initializing.
sleep 5

swaymsg 'workspace 1'

# Restart tmux server
tmux kill-server
# Start tmux; term_options is set by `kanshi`
swaymsg 'exec $term $term_options -e tmux'

### Open an ASCII table in the scratchpad for reference ###
# Delay opening this terminal window until the initial terminal window is
# opened to guarantee the ordering of `tmux` sessions.
sleep 1
swaymsg 'exec "$term $term_options -e tmux new-session -sref"'
# Wait until the new `tmux` session completes initialization before sending
# keys to it.
sleep 1
tmux send-keys -tref source Space ~/.scratchpad/.zshrc Enter
