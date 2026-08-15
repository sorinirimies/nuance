//! Clap-derived argument parsing for the `nuance` binary.

use clap::{Parser, Subcommand};

#[derive(Parser, Debug)]
#[command(
    name = "nuance",
    about = "nuance — themeable, git-aware Nushell prompt",
    long_about = None,
    disable_help_subcommand = true
)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Option<Commands>,
}

#[derive(Subcommand, Debug)]
pub enum Commands {
    /// Pick a theme (ratatui TUI with live preview), or set + pin one by name
    Theme {
        /// Theme name, e.g. gruvbox, catppuccin-mocha, dracula
        name: Option<String>,
    },
    /// Pick a prompt style (ratatui TUI with live preview), or set one by name
    #[command(name = "prompt-style")]
    PromptStyle {
        /// Style name, e.g. full, compact, minimal, powerline
        name: Option<String>,
    },
    /// Pick a look — theme + style preset (ratatui TUI), or apply one by name
    Look {
        /// Look name, e.g. cyberpunk, gruvbox-minimal, tokyo-powerline
        name: Option<String>,
    },
    /// Follow the terminal's own theme automatically
    Sync,
    /// Pull the latest checkout (git installs), or point at `cargo install --force`
    Update,
}

pub fn usage() -> &'static str {
    "nuance — themeable, git-aware Nushell prompt

  nuance theme [name]          ratatui picker w/ live preview, or set + pin one
  nuance prompt-style [name]   ratatui picker w/ live preview, or set one
  nuance look [name]           ratatui picker w/ live preview, or apply one
  nuance sync                  follow the terminal's theme (auto-follow)
  nuance update                pull the latest checkout, then: exec nu
  nuance help                  this help

Set from a normal shell → applies to your next Nushell (run: exec nu).
"
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn usage_mentions_every_subcommand() {
        let u = usage();
        for cmd in ["theme", "prompt-style", "look", "sync", "update", "help"] {
            assert!(u.contains(cmd), "usage() missing `{cmd}`");
        }
    }

    #[test]
    fn parses_theme_with_name() {
        let cli = Cli::try_parse_from(["nuance", "theme", "gruvbox"]).unwrap();
        match cli.command {
            Some(Commands::Theme { name }) => assert_eq!(name.as_deref(), Some("gruvbox")),
            other => panic!("unexpected: {other:?}"),
        }
    }

    #[test]
    fn parses_theme_without_name() {
        let cli = Cli::try_parse_from(["nuance", "theme"]).unwrap();
        match cli.command {
            Some(Commands::Theme { name }) => assert_eq!(name, None),
            other => panic!("unexpected: {other:?}"),
        }
    }

    #[test]
    fn parses_prompt_style_subcommand_name() {
        let cli = Cli::try_parse_from(["nuance", "prompt-style", "powerline"]).unwrap();
        match cli.command {
            Some(Commands::PromptStyle { name }) => assert_eq!(name.as_deref(), Some("powerline")),
            other => panic!("unexpected: {other:?}"),
        }
    }

    #[test]
    fn parses_no_subcommand() {
        let cli = Cli::try_parse_from(["nuance"]).unwrap();
        assert!(cli.command.is_none());
    }

    #[test]
    fn rejects_unknown_subcommand() {
        assert!(Cli::try_parse_from(["nuance", "frobnicate"]).is_err());
    }

    #[test]
    fn parses_sync_and_update() {
        assert!(matches!(
            Cli::try_parse_from(["nuance", "sync"]).unwrap().command,
            Some(Commands::Sync)
        ));
        assert!(matches!(
            Cli::try_parse_from(["nuance", "update"]).unwrap().command,
            Some(Commands::Update)
        ));
    }
}
