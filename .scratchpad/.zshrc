# This zshrc is used to open an ASCII table reference in the scratchpad of the
# Sway window manager and keep the Zsh session open.

swaymsg "floating enable; resize set 1100 720; move scratchpad"
view -c "set noruler" ~/Programs/references/ascii_table.txt
