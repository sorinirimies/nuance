# nuance-cli

The `nuance` command — a `clap` CLI with a `ratatui` picker — installable with
Cargo:

```sh
cargo install nuance-cli
```

That's it — no clone, no `install.nu`, no bootstrap script. Everything
`nuance` needs is packaged inside the one binary:

- the [nushell-prompt.nu](https://github.com/sorinirimies/nuance) script is
  vendored at compile time and dropped into Nushell's autoload directory the
  first time you run any command — so the `theme` / `prompt-style` / `look`
  commands become available inside Nushell too, not just from this CLI.
- `nu` itself is a real external binary (not statically linkable) — if it's
  missing, `nuance` offers to `cargo install nu --locked` for you, since
  `cargo` is guaranteed to already be on your PATH.

```
nuance theme [name]          ratatui picker w/ live preview, or set + pin one
nuance prompt-style [name]   ratatui picker w/ live preview, or set one
nuance look [name]           ratatui picker w/ live preview, or apply one
nuance sync                  follow the terminal's theme (auto-follow)
nuance update                pull the latest checkout, then: exec nu
nuance help                  this help
```

## The picker

Running `nuance theme` (or `prompt-style` / `look`) with no name opens an
interactive `ratatui` picker instead of a plain list:

- every candidate's real rendered prompt (colors and all) is fetched **once**
  up front, in a single `nu` subprocess call
- moving the selection with `↑`/`↓` redraws the highlighted candidate's full
  live preview **instantly**, straight from memory — no `Enter` required
  first, and no extra `nu` calls per keystroke
- type to fuzzy-filter by name or by what's in the preview, `Enter` to apply,
  `Esc`/`Ctrl-C` to cancel without changing anything

This is the live "preview while you browse" experience Nushell's own
`input list` can't provide on its own (it has no per-highlight callback) —
`nuance-cli` gets it by rendering the data once and doing the interactive
part itself.

Changes are persisted (`~/.config/nushell/current-theme.txt`,
`prompt-style.txt`) and picked up the next time you start (or `exec`) `nu`.

See the [main nuance README](https://github.com/sorinirimies/nuance) for the
full list of themes, prompt styles, and screenshots.
