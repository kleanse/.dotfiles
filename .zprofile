if [[ -x "/opt/homebrew/bin/brew" ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Start one instance of ssh-agent and have it cache decrypted private keys for
# one hour.
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" > /dev/null
fi

if [[ -z ${DISPLAY} && ${XDG_VTNR} -eq 1 ]]; then
	exec sway
fi
