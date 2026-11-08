# ~/.zshenv

# Source Cargo's environment if available.
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Directories to prepend to PATH, in priority order.
path_dirs=(
    /opt/homebrew/bin
    /usr/local/bin
    /opt/local/bin
)

# Include only directories that exist.
prepend=()
for dir in "${path_dirs[@]}"; do
    [[ -d "$dir" ]] && prepend+=("$dir")
done

# Preserve existing PATH entries, eliminating duplicates.
typeset -U path
path=("${prepend[@]}" "${path[@]}")
export PATH

# Clean up temporary variables.
unset path_dirs prepend dir
