#!/usr/bin/bash

# This script sets configuration variables for Sway depending on the output
# profile given by kanshi.

prgname="setvars"

case $1 in
wired)
	swaymsg 'set $term_options --override="font=monospace:size=16"'
	swaymsg 'set $floating_x 1421; set $floating_y 925'
	;;
nomad)
	swaymsg 'set $term_options ""'
	swaymsg 'set $floating_x 1094; set $floating_y 709'
	;;
*)
	echo "$prgname: unrecognized argument: $1"
	;;
esac
