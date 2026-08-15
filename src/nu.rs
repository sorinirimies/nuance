//! All interaction with the vendored `nushell-prompt.nu` script and the `nu`
//! binary lives here: locating/installing the script, running commands
//! inside a throwaway Nushell, and fetching the picker-item data (name +
//! live-rendered ANSI preview) that the ratatui TUI displays.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

use serde::Deserialize;

/// The nushell-prompt.nu source, vendored at compile time from the repo root.
/// This is what makes `cargo install nuance-cli` self-contained: no clone,
/// no `install.nu`, no network fetch at install- or run-time.
const NUSHELL_PROMPT: &str = include_str!("../nushell-prompt.nu");
const FILE: &str = "nushell-prompt.nu";

/// A single entry in an interactive picker: a stable key (theme/style/look
/// name) plus its live-rendered ANSI preview line.
#[derive(Debug, Clone, Deserialize)]
pub struct PickerItem {
    pub label: String,
    pub key: String,
}

pub fn have(cmd: &str) -> bool {
    Command::new("sh")
        .arg("-c")
        .arg(format!("command -v {cmd} >/dev/null 2>&1"))
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

/// Make sure `nu` is available. `nuance-cli` bundles everything it can
/// (the prompt script itself), but Nushell is a real binary we can't
/// statically link in — if it's missing and `cargo` is available (it must
/// be, since that's how you got this binary), offer to install it so the
/// whole flow stays a single `cargo install nuance-cli` away from working.
pub fn ensure_nu() -> Result<(), String> {
    if have("nu") {
        return Ok(());
    }
    if !have("cargo") {
        return Err(
            "Nushell (`nu`) is required and `cargo` isn't on PATH to auto-install it.\n\
             Install it yourself: https://www.nushell.sh"
                .to_string(),
        );
    }
    eprintln!("\x1b[1;33m!\x1b[0m  nu not found — installing it with `cargo install nu --locked` (one-time, ~1-2 min)…");
    let status = Command::new("cargo")
        .arg("install")
        .arg("nu")
        .arg("--locked")
        .status();
    match status {
        Ok(s) if s.success() => Ok(()),
        _ => Err("failed to install Nushell via `cargo install nu --locked`".to_string()),
    }
}

/// Run `nu -n -c "<script>"` and capture stdout, trimmed.
fn nu_capture(script: &str) -> Option<String> {
    let out = Command::new("nu")
        .arg("-n")
        .arg("-c")
        .arg(script)
        .output()
        .ok()?;
    if !out.status.success() {
        return None;
    }
    Some(String::from_utf8_lossy(&out.stdout).trim().to_string())
}

fn autoload_dir() -> Option<PathBuf> {
    nu_capture("$nu.user-autoload-dirs | get 0").map(PathBuf::from)
}

pub fn is_symlink(p: &Path) -> bool {
    fs::symlink_metadata(p)
        .map(|m| m.file_type().is_symlink())
        .unwrap_or(false)
}

/// Make sure Nushell will pick up nuance: if nothing is installed yet, vendor
/// the embedded script into the autoload directory. If the user already has
/// their own clone symlinked/copied there, leave it alone — it's the source
/// of truth (e.g. for `nuance update` on a git checkout).
pub fn ensure_installed() -> Result<PathBuf, String> {
    let dir = autoload_dir().ok_or_else(|| {
        "could not resolve Nushell's autoload directory — is `nu` installed and on PATH?"
            .to_string()
    })?;
    let target = dir.join(FILE);
    if target.exists() || is_symlink(&target) {
        return Ok(target);
    }
    fs::create_dir_all(&dir).map_err(|e| format!("mkdir {}: {e}", dir.display()))?;
    fs::write(&target, NUSHELL_PROMPT).map_err(|e| format!("write {}: {e}", target.display()))?;
    eprintln!(
        "\x1b[1;32m==>\x1b[0m installed nuance -> {}",
        target.display()
    );
    Ok(target)
}

/// Resolve the git checkout backing the autoload file, if any (so `update`
/// can `git pull` a real clone instead of the vendored copy).
pub fn repo_dir(target: &Path) -> Option<PathBuf> {
    if !is_symlink(target) {
        return None;
    }
    let real = fs::canonicalize(target).ok()?;
    let dir = real.parent()?.to_path_buf();
    if dir.join(".git").is_dir() {
        Some(dir)
    } else {
        None
    }
}

/// Run a nuance command inside a throwaway Nushell, inheriting stdio
/// (persists any state files it writes, e.g. current-theme.txt).
pub fn run_nu(file: &Path, script: &str) -> ExitCode {
    let full = format!("source \"{}\"; {script}", file.display());
    match Command::new("nu").arg("-n").arg("-c").arg(&full).status() {
        Ok(status) if status.success() => ExitCode::SUCCESS,
        Ok(_) => ExitCode::FAILURE,
        Err(e) => {
            eprintln!("nuance: failed to run `nu`: {e}");
            ExitCode::FAILURE
        }
    }
}

/// Fetch a JSON list of picker items by calling `<nu_expr> | to json` inside
/// a throwaway Nushell. Used to load all theme/style/look previews in a
/// single subprocess call, up front — so the ratatui TUI can redraw an
/// instant live preview on every keypress purely from memory afterwards.
/// Fetch a JSON list of picker items by calling `<nu_expr> | to json` inside
/// a throwaway Nushell. Used to load all theme/style/look previews in a
/// single subprocess call, up front — so the ratatui TUI can redraw an
/// instant live preview on every keypress purely from memory afterwards.
///
/// `to json` doesn't escape raw control bytes (the ESC in ANSI color codes),
/// which would otherwise be invalid JSON — so `nu_expr`'s items are piped
/// through the `escape-esc` helper (defined in nushell-prompt.nu) before
/// serializing, and un-escaped again here after parsing.
pub fn fetch_picker_items(file: &Path, nu_expr: &str) -> Result<Vec<PickerItem>, String> {
    let script = format!(
        "source \"{}\"; ({nu_expr}) | each {{|r| {{key: $r.key, label: (escape-esc $r.label)}}}} | to json",
        file.display()
    );
    let out = Command::new("nu")
        .arg("-n")
        .arg("-c")
        .arg(&script)
        .output()
        .map_err(|e| format!("failed to run `nu`: {e}"))?;
    if !out.status.success() {
        return Err(String::from_utf8_lossy(&out.stderr).trim().to_string());
    }
    let stdout = String::from_utf8_lossy(&out.stdout);
    let mut items: Vec<PickerItem> = serde_json::from_str(stdout.trim())
        .map_err(|e| format!("failed to parse nu output as JSON: {e}"))?;
    for item in &mut items {
        item.label = item.label.replace("\\u001b", "\u{1b}");
    }
    Ok(items)
}

pub fn cmd_update(target: &Path) -> ExitCode {
    match repo_dir(target) {
        Some(dir) => {
            println!("\x1b[1;32m==>\x1b[0m updating {} …", dir.display());
            let status = Command::new("git")
                .arg("-C")
                .arg(&dir)
                .arg("pull")
                .arg("--ff-only")
                .status();
            match status {
                Ok(s) if s.success() => {
                    println!(
                        "\x1b[1;32m\u{2713}\x1b[0m updated — open a new shell (or run: exec nu)"
                    );
                    ExitCode::SUCCESS
                }
                _ => ExitCode::FAILURE,
            }
        }
        None => {
            println!("nuance was installed via `cargo install nuance-cli` (no git checkout).");
            println!("To update:  cargo install --force nuance-cli   then: exec nu");
            ExitCode::SUCCESS
        }
    }
}

/// Quote a list of args as a space-separated sequence of double-quoted
/// Nushell string literals, safe to splice into a `nu -c` script.
pub fn quote(args: &[String]) -> String {
    args.iter()
        .map(|a| format!("\"{}\"", a.replace('\\', "\\\\").replace('"', "\\\"")))
        .collect::<Vec<_>>()
        .join(" ")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn quote_empty_args_is_empty_string() {
        assert_eq!(quote(&[]), "");
    }

    #[test]
    fn quote_wraps_each_arg_in_double_quotes() {
        let args = vec!["gruvbox".to_string()];
        assert_eq!(quote(&args), "\"gruvbox\"");
    }

    #[test]
    fn quote_joins_multiple_args_with_space() {
        let args = vec!["a".to_string(), "b".to_string()];
        assert_eq!(quote(&args), "\"a\" \"b\"");
    }

    #[test]
    fn quote_escapes_embedded_quotes_and_backslashes() {
        let args = vec![r#"weird"name\here"#.to_string()];
        assert_eq!(quote(&args), r#""weird\"name\\here""#);
    }

    #[test]
    fn nuance_theme_script_trims_cleanly_with_no_args() {
        let rest: Vec<String> = Vec::new();
        let script = format!("nuance theme {}", quote(&rest));
        assert_eq!(script.trim(), "nuance theme");
    }

    #[test]
    fn nuance_theme_script_includes_quoted_name() {
        let rest = vec!["gruvbox".to_string()];
        let script = format!("nuance theme {}", quote(&rest));
        assert_eq!(script.trim(), "nuance theme \"gruvbox\"");
    }

    #[test]
    fn is_symlink_false_for_missing_path() {
        assert!(!is_symlink(Path::new("/does/not/exist/nuance-test-marker")));
    }

    #[test]
    fn is_symlink_false_for_regular_file() {
        let dir = std::env::temp_dir().join(format!("nuance-cli-test-{}", std::process::id()));
        fs::create_dir_all(&dir).unwrap();
        let f = dir.join("regular.txt");
        fs::write(&f, "hi").unwrap();
        assert!(!is_symlink(&f));
        let _ = fs::remove_dir_all(&dir);
    }

    #[test]
    #[cfg(unix)]
    fn is_symlink_true_for_symlink() {
        let dir = std::env::temp_dir().join(format!("nuance-cli-test-sym-{}", std::process::id()));
        fs::create_dir_all(&dir).unwrap();
        let target = dir.join("target.txt");
        fs::write(&target, "hi").unwrap();
        let link = dir.join("link.txt");
        std::os::unix::fs::symlink(&target, &link).unwrap();
        assert!(is_symlink(&link));
        let _ = fs::remove_dir_all(&dir);
    }

    #[test]
    fn repo_dir_none_for_non_symlink() {
        let dir = std::env::temp_dir().join(format!("nuance-cli-test-repo-{}", std::process::id()));
        fs::create_dir_all(&dir).unwrap();
        let f = dir.join("plain.txt");
        fs::write(&f, "hi").unwrap();
        assert_eq!(repo_dir(&f), None);
        let _ = fs::remove_dir_all(&dir);
    }

    #[test]
    fn picker_item_deserializes_key_field() {
        let item: PickerItem = serde_json::from_str(r#"{"label":"l","key":"full"}"#).unwrap();
        assert_eq!(item.key, "full");
    }
}
