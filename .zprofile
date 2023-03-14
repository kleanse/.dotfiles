if [[ -x "/opt/homebrew/bin/brew" ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ -z ${DISPLAY} && ${XDG_VTNR} -eq 1 ]]; then
	exec sway
fi
