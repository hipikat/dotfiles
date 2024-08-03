
# Initialise Pure prompt
fpath+=("$HOME/.zsh/pure")
autoload -U promptinit; promptinit
prompt pure

# Bind Option + Left Arrow to move backward by word
bindkey "^[[1;3D" backward-word

# Bind Option + Right Arrow to move forward by word
bindkey "^[[1;3C" forward-word

# Load user aliases & functions
source ~/.aliases
