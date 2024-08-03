
# Initialise Pure prompt
fpath+=("$HOME/.zsh/pure")
autoload -U promptinit; promptinit
prompt pure

# Load user aliases, functions & constants
source ~/.dotfiles/shell_utils.sh
