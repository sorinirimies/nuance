//! `nuance` — CLI + ratatui TUI usable from any shell (bash/zsh/fish/
//! PowerShell/…), installed via `cargo install nuance-cli`.
//!
//! Everything needed is packaged inside this one binary:
//!   - the `nushell-prompt.nu` script is vendored at compile time
//!     (`nu::NUSHELL_PROMPT`) and dropped into Nushell's autoload directory
//!     on first use — no clone, no `install.nu`, no network fetch.
//!   - argument parsing is `clap` (derive), see `cli.rs`.
//!   - `theme`/`prompt-style`/`look` with no name open a `ratatui` picker
//!     (see `tui.rs`) with an *instant* live preview: all candidates are
//!     rendered once via a single `nu` call up front, then arrow-key
//!     movement redraws the highlighted item's real rendered prompt
//!     straight from memory — no Enter needed, unlike Nushell's own
//!     `input list`, which has no per-highlight callback.
//!
//! `nu` itself is still a real external binary (not statically linked) —
//! if it's missing, `nuance` offers to `cargo install nu --locked` for you,
//! since `cargo` is guaranteed to be present (that's how you got `nuance`).

mod ansi;
mod cli;
mod nu;
mod tui;

use std::path::Path;
use std::process::ExitCode;

use clap::Parser;
use cli::{Cli, Commands};

fn main() -> ExitCode {
    let raw: Vec<String> = std::env::args().collect();

    // Fast-path "help" / no-args to keep exact historical output + exit
    // codes (previously covered by `test.bats` parity tests for the old
    // bash CLI, now covered by tests/cli.rs).
    if raw.len() <= 1 || raw[1] == "help" {
        print!("{}", cli::usage());
        return ExitCode::SUCCESS;
    }

    let parsed = match Cli::try_parse_from(&raw) {
        Ok(c) => c,
        Err(e) => {
            use clap::error::ErrorKind;
            if matches!(e.kind(), ErrorKind::DisplayHelp | ErrorKind::DisplayVersion) {
                print!("{e}");
                return ExitCode::SUCCESS;
            }
            print!("{}", cli::usage());
            return ExitCode::FAILURE;
        }
    };

    match parsed.command {
        None => {
            print!("{}", cli::usage());
            ExitCode::SUCCESS
        }
        Some(Commands::Sync) => with_nu(|target| nu::run_nu(target, "nuance sync theme")),
        Some(Commands::Update) => with_nu(nu::cmd_update),
        Some(Commands::Theme { name }) => {
            pick_or_apply(name, "theme", "theme-picker-items", "nuance theme")
        }
        Some(Commands::PromptStyle { name }) => pick_or_apply(
            name,
            "prompt style",
            "style-picker-items",
            "nuance prompt-style",
        ),
        Some(Commands::Look { name }) => {
            pick_or_apply(name, "look", "look-picker-items", "nuance look")
        }
    }
}

/// Make sure `nu` is available and nuance is installed into its autoload
/// dir, then run `f` with the resolved script path.
fn with_nu(f: impl FnOnce(&Path) -> ExitCode) -> ExitCode {
    if let Err(e) = nu::ensure_nu() {
        eprintln!("nuance: {e}");
        return ExitCode::FAILURE;
    }
    match nu::ensure_installed() {
        Ok(target) => f(&target),
        Err(e) => {
            eprintln!("nuance: {e}");
            ExitCode::FAILURE
        }
    }
}

/// Shared logic for `theme`/`prompt-style`/`look`: with a name, apply it
/// directly; with no name, load every candidate's live preview once and
/// open the ratatui picker.
fn pick_or_apply(
    name: Option<String>,
    label: &str,
    picker_expr: &str,
    apply_prefix: &str,
) -> ExitCode {
    with_nu(|target| match name {
        Some(n) => {
            let script = format!("{apply_prefix} {}", nu::quote(&[n]));
            nu::run_nu(target, &script)
        }
        None => {
            let items = match nu::fetch_picker_items(target, picker_expr) {
                Ok(v) => v,
                Err(e) => {
                    eprintln!("nuance: failed to load {label} previews: {e}");
                    return ExitCode::FAILURE;
                }
            };
            match tui::pick(items, label) {
                Ok(Some(choice)) => {
                    let script = format!("{apply_prefix} {}", nu::quote(&[choice]));
                    nu::run_nu(target, &script)
                }
                Ok(None) => {
                    println!("cancelled.");
                    ExitCode::SUCCESS
                }
                Err(e) => {
                    eprintln!("nuance: tui error: {e}");
                    ExitCode::FAILURE
                }
            }
        }
    })
}
