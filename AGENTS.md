# Repository Guidance

## Shell command aliases

- `shell_utils.sh` is shared Bash and Zsh configuration. Verify changes with both `bash -n` and `zsh -n`.
- `_run` is intentionally pedagogical: it keeps aliases transparent, reinforces the underlying commands, and helps observers reproduce them without these dotfiles.
- Preserve `_run`'s stderr trace, shell-escaped argument display, argument boundaries, and direct `"$@"` execution.
- Use `_run` for ordinary commands expressed as arguments.
- Use `_runsh` only for fixed, trusted compound shell programs such as pipelines or process substitutions. Pass dynamic data as trailing positional arguments; never interpolate it into the evaluated program.
- A compound operation should normally produce one complete, reproducible `_runsh` trace. Do not trace nested ingredients when that would conceal the operation connecting them.
- Keep alias-like functions minimal unless richer validation is explicitly requested.
- Test forwarded arguments containing spaces and shell metacharacters under both Bash and Zsh.

## Homebrew helpers

- `br.uses` intentionally queries each formula separately: Homebrew intersects multiple arguments to `brew uses`, while this helper requires their union.
- `br.uses` then exact-matches that union against `brew leaves`.
