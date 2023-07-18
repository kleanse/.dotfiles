# This zshrc is used to open an ASCII table reference in the scratchpad of the
# Sway window manager and keep the Zsh session open.

swaymsg 'floating enable; resize set $floating_x $floating_y; move scratchpad'
view -c "set noruler | set colorcolumn=" ~/Programming/references/ascii_table.txt
