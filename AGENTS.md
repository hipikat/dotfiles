# Repository Guidance

## Shell command aliases

- `shell_utils.sh` is shared Bash and Zsh configuration. Verify changes with both `bash -n` and `zsh -n`.
- Keep the numbered index synchronized with the actual `###` headings. Put active command groups in section 1, behavioural and compatibility overrides in section 2, and observed typo aliases in section 3; do not use a generic legacy-candidate bucket for retained commands.
- Alphabetise sections and declarations where useful, but keep obvious command families together and give meaningful families their own heading rather than breaking them up for strict sorting.
- Treat a compact alias for a compound command as the family root (`dim` for `docker image`, `drn` for `docker run`, `gco` for `git commit`). Add dotted suffixes for variants (`dim.i`, `dim.rm`); do not split the root itself or introduce multiple new dots merely to expose every underlying word.
- Dots are valid in Bash and Zsh function names. When renaming a command family, update its internal calls and completion registrations together, then check for missing or duplicate declarations.
- Move substantial standalone workflows into executable scripts under `.bin/`; leave only concise aliases or wrappers in `shell_utils.sh`, as with `zombie-saver`.
- `_run` is intentionally pedagogical: it keeps aliases transparent, reinforces the underlying commands, and helps observers reproduce them without these dotfiles.
- Preserve `_run`'s stderr trace, shell-escaped argument display, argument boundaries, and direct `"$@"` execution.
- Use `_run` only when its trace is a concise, realistic command a person could usefully type instead. Complex functions should run their implementation machinery directly rather than expose noisy traces.
- Use `_runsh` only for fixed, trusted compound commands that are still useful to show verbatim. Pass dynamic data as trailing positional arguments; never interpolate it into the evaluated program.
- When a concise compound command is worth showing, prefer one complete `_runsh` trace over traces of nested ingredients.
- Keep alias-like functions minimal unless richer validation is explicitly requested.
- Test forwarded arguments containing spaces and shell metacharacters under both Bash and Zsh.

## Homebrew helpers

- Homebrew intersects multiple arguments to `brew uses`, so `br.uses` intentionally queries each formula separately.
