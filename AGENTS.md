# Repository Guidance

## Shell command aliases

- `shell_utils.sh` is shared Bash and Zsh configuration. Verify changes with both `bash -n` and `zsh -n`.
- `_run` is intentionally pedagogical: it keeps aliases transparent, reinforces the underlying commands, and helps observers reproduce them without these dotfiles.
- Preserve `_run`'s stderr trace, shell-escaped argument display, argument boundaries, and direct `"$@"` execution.
- Use `_run` only when its trace is a concise, realistic command a person could usefully type instead. Complex functions should run their implementation machinery directly rather than expose noisy traces.
- Use `_runsh` only for fixed, trusted compound commands that are still useful to show verbatim. Pass dynamic data as trailing positional arguments; never interpolate it into the evaluated program.
- When a concise compound command is worth showing, prefer one complete `_runsh` trace over traces of nested ingredients.
- Keep alias-like functions minimal unless richer validation is explicitly requested.
- Test forwarded arguments containing spaces and shell metacharacters under both Bash and Zsh.

## Homebrew helpers

- Homebrew intersects multiple arguments to `brew uses`, so `br.uses` intentionally queries each formula separately.
