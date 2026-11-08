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
pub(crate) struct PickerItem {
    pub label: String,
    pub key: String,
}

/// Is `cmd` an executable file on `PATH`? Pure-Rust (no `sh`), so it also
/// works on native Windows, where `PATHEXT` extensions are tried too.
pub(crate) fn have(cmd: &str) -> bool {
    std::env::var_os("PATH").is_some_and(|path| find_in_path(cmd, &path))
}

fn find_in_path(cmd: &str, path: &std::ffi::OsStr) -> bool {
    let exts: Vec<String> = if cfg!(windows) {
        std::env::var("PATHEXT")
            .unwrap_or_else(|_| ".EXE;.CMD;.BAT;.COM".into())
            .split(';')
            .map(str::to_string)
            .collect()
    } else {
        Vec::new()
    };
    std::env::split_paths(path).any(|dir| {
        let base = dir.join(cmd);
        is_executable(&base)
            || exts
                .iter()
                .any(|e| is_executable(&dir.join(format!("{cmd}{e}"))))
    })
}

fn is_executable(p: &Path) -> bool {
    let Ok(meta) = fs::metadata(p) else {
        return false;
    };
    if !meta.is_file() {
        return false;
    }
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        meta.permissions().mode() & 0o111 != 0
    }
    #[cfg(not(unix))]
    {
        true
    }
}

/// Make sure `nu` is available. `nuance-cli` bundles everything it can
/// (the prompt script itself), but Nushell is a real binary we can't
/// statically link in — if it's missing and `cargo` is available (it must
/// be, since that's how you got this binary), offer to install it so the
/// whole flow stays a single `cargo install nuance-cli` away from working.
pub(crate) fn ensure_nu() -> Result<(), String> {
    if have("nu") {
        return Ok(());
    }
    let Some(install) = nu_installer(std::env::consts::OS, have) else {
        return Err(
            "Nushell (`nu`) is required and no installer (winget, brew, cargo) is on PATH.\n\
             Install it yourself: https://www.nushell.sh"
                .to_string(),
        );
    };
    let shown = install.join(" ");
    if !std::io::IsTerminal::is_terminal(&std::io::stdin()) {
        return Err(format!(
            "Nushell (`nu`) is required; refusing to auto-install in a non-interactive session.\n\
             Run `{shown}` or see https://www.nushell.sh"
        ));
    }
    eprintln!("\x1b[1;33m!\x1b[0m  nu not found — installing it with `{shown}` (one-time)…");
    match Command::new(install[0]).args(&install[1..]).status() {
        Ok(s) if s.success() && have("nu") => Ok(()),
        Ok(s) if s.success() => Err(format!(
            "`{shown}` succeeded but `nu` is not on PATH yet — open a new terminal and retry"
        )),
        _ => Err(format!("failed to install Nushell via `{shown}`")),
    }
}

/// How to install Nushell on `os`: the platform package manager when present
/// (a prebuilt binary in seconds), else `cargo install` (a 1-2 min build).
pub(crate) fn nu_installer(
    os: &str,
    have: impl Fn(&str) -> bool,
) -> Option<&'static [&'static str]> {
    const WINGET: &[&str] = &[
        "winget",
        "install",
        "--id",
        "Nushell.Nushell",
        "-e",
        "--accept-source-agreements",
        "--accept-package-agreements",
    ];
    const BREW: &[&str] = &["brew", "install", "nushell"];
    const CARGO: &[&str] = &["cargo", "install", "nu", "--locked"];
    let candidates: &[&'static [&'static str]] = match os {
        "windows" => &[WINGET, CARGO],
        "macos" | "linux" => &[BREW, CARGO],
        _ => &[CARGO],
    };
    candidates.iter().copied().find(|c| have(c[0]))
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

/// Nushell's autoload directory. Asking `nu` costs a process start (~20 ms)
/// on every command, so the answer is cached in the per-user cache dir,
/// keyed by the `nu` binary and the variables that move Nushell's config dir.
fn autoload_dir() -> Option<PathBuf> {
    let cache = user_cache_dir().map(|d| {
        d.join("nuance")
            .join(format!("autoload-{}.txt", dirs_key()))
    });
    if let Some(c) = &cache
        && let Ok(s) = fs::read_to_string(c)
    {
        let dir = PathBuf::from(s.trim());
        if dir.is_dir() {
            return Some(dir);
        }
    }
    let dir = nu_capture("$nu.user-autoload-dirs | get 0").map(PathBuf::from)?;
    if let Some(c) = &cache
        && let Some(parent) = c.parent()
        && fs::create_dir_all(parent).is_ok()
    {
        let _ = fs::write(c, dir.display().to_string());
    }
    Some(dir)
}

/// Everything that can change `$nu.user-autoload-dirs`.
fn dirs_key() -> String {
    let mut k = String::new();
    for v in [
        "PATH",
        "XDG_CONFIG_HOME",
        "XDG_DATA_HOME",
        "HOME",
        "APPDATA",
        "USERPROFILE",
    ] {
        k.push_str(&std::env::var(v).unwrap_or_default());
        k.push('\0');
    }
    fnv1a(k.as_bytes())
}

/// The per-user cache directory (never a shared one like /tmp: the cached
/// path decides where nuance writes and sources code).
fn user_cache_dir() -> Option<PathBuf> {
    let env = |k: &str| {
        std::env::var_os(k)
            .filter(|v| !v.is_empty())
            .map(PathBuf::from)
    };
    cache_dir_for(std::env::consts::OS, env)
}

fn cache_dir_for(os: &str, env: impl Fn(&str) -> Option<PathBuf>) -> Option<PathBuf> {
    match os {
        "windows" => env("LOCALAPPDATA"),
        "macos" => env("HOME").map(|h| h.join("Library").join("Caches")),
        _ => env("XDG_CACHE_HOME").or_else(|| env("HOME").map(|h| h.join(".cache"))),
    }
}

pub(crate) fn is_symlink(p: &Path) -> bool {
    fs::symlink_metadata(p).is_ok_and(|m| m.file_type().is_symlink())
}

/// Write via a sibling temp file + rename so a crash never leaves a
/// half-written autoload script (Nushell would choke on it at startup).
pub(crate) fn write_atomic(target: &Path, bytes: &[u8]) -> Result<(), String> {
    let tmp = target.with_extension("nu.tmp");
    fs::write(&tmp, bytes).map_err(|e| format!("write {}: {e}", tmp.display()))?;
    fs::rename(&tmp, target).map_err(|e| {
        let _ = fs::remove_file(&tmp);
        format!("rename {} -> {}: {e}", tmp.display(), target.display())
    })
}

/// Make sure Nushell will pick up nuance: if nothing is installed yet, vendor
/// the embedded script into the autoload directory. If the user already has
/// their own clone symlinked/copied there, leave it alone — it's the source
/// of truth (e.g. for `nuance update` on a git checkout).
pub(crate) fn ensure_installed() -> Result<PathBuf, String> {
    let dir = autoload_dir().ok_or_else(|| {
        "could not resolve Nushell's autoload directory — is `nu` installed and on PATH?"
            .to_string()
    })?;
    let target = dir.join(FILE);
    match vendor(&target, NUSHELL_PROMPT)? {
        Vendored::Installed => eprintln!(
            "\x1b[1;32m==>\x1b[0m installed nuance -> {}",
            target.display()
        ),
        Vendored::Refreshed => eprintln!(
            "\x1b[1;32m==>\x1b[0m updated nuance -> {}",
            target.display()
        ),
        Vendored::Current | Vendored::UserOwned => {}
    }
    Ok(target)
}

/// Doctor hint when the autoload copy is not the one this binary carries
/// (an install from before the refresh stamp, or a hand-edited copy).
pub(crate) fn drift_hint(target: &Path) -> Option<String> {
    drift_hint_for(target, NUSHELL_PROMPT)
}

fn drift_hint_for(target: &Path, script: &str) -> Option<String> {
    if is_symlink(target) {
        return None;
    }
    let current = fs::read(target).ok()?;
    (current != script.as_bytes()).then(|| {
        format!(
            "{} differs from the script bundled with nuance {} — to replace it: \
             delete it, then run any nuance command",
            target.display(),
            env!("CARGO_PKG_VERSION")
        )
    })
}

/// What [`vendor`] did with the autoload file.
#[derive(Debug, PartialEq, Eq)]
pub(crate) enum Vendored {
    /// There was none; the embedded script was written.
    Installed,
    /// An older copy this binary wrote earlier was replaced by the embedded one.
    Refreshed,
    /// Already identical to the embedded script.
    Current,
    /// A symlink or a copy the user changed: left alone.
    UserOwned,
}

/// Sidecar that records the hash of the copy we last wrote. Not a `.nu` file,
/// so Nushell's autoload ignores it.
fn stamp_path(target: &Path) -> PathBuf {
    target.with_extension("nu.vendored")
}

/// FNV-1a: stable across Rust versions and platforms (unlike `DefaultHasher`).
fn fnv1a(bytes: &[u8]) -> String {
    let h = bytes.iter().fold(0xcbf2_9ce4_8422_2325_u64, |h, b| {
        (h ^ u64::from(*b)).wrapping_mul(0x0100_0000_01b3)
    });
    format!("{h:016x}")
}

/// Keep `target` in sync with `script`. A copy written by an older nuance
/// (its hash matches the stamp) is refreshed after `cargo install --force`;
/// a symlinked checkout or a hand-edited copy is never touched.
pub(crate) fn vendor(target: &Path, script: &str) -> Result<Vendored, String> {
    if is_symlink(target) {
        return Ok(Vendored::UserOwned);
    }
    let stamp = stamp_path(target);
    let write = |what| -> Result<Vendored, String> {
        if let Some(dir) = target.parent() {
            fs::create_dir_all(dir).map_err(|e| format!("mkdir {}: {e}", dir.display()))?;
        }
        write_atomic(target, script.as_bytes())?;
        // Best effort: without a stamp the next upgrade just leaves the file alone.
        let _ = fs::write(&stamp, fnv1a(script.as_bytes()));
        Ok(what)
    };
    let Ok(current) = fs::read(target) else {
        return write(Vendored::Installed);
    };
    if current == script.as_bytes() {
        if !stamp.exists() {
            let _ = fs::write(&stamp, fnv1a(script.as_bytes()));
        }
        return Ok(Vendored::Current);
    }
    let ours = fs::read_to_string(&stamp).is_ok_and(|s| s.trim() == fnv1a(&current));
    if ours {
        write(Vendored::Refreshed)
    } else {
        Ok(Vendored::UserOwned)
    }
}

/// `source <file>` as Nushell source. A raw string (`r#'…'#`) takes the path
/// verbatim: Windows backslashes, spaces, quotes and backticks included.
pub(crate) fn source_cmd(file: &Path) -> String {
    let p = file.display().to_string();
    let mut hashes = String::from("#");
    while p.contains(&format!("'{hashes}")) {
        hashes.push('#');
    }
    format!("source r{hashes}'{p}'{hashes}")
}

/// Resolve the git checkout backing the autoload file, if any (so `update`
/// can `git pull` a real clone instead of the vendored copy).
pub(crate) fn repo_dir(target: &Path) -> Option<PathBuf> {
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
pub(crate) fn run_nu(file: &Path, script: &str) -> ExitCode {
    let full = format!("{}; {script}", source_cmd(file));
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
pub(crate) fn fetch_picker_items(file: &Path, nu_expr: &str) -> Result<Vec<PickerItem>, String> {
    let script = format!(
        "{}; ({nu_expr}) | each {{|r| {{key: $r.key, label: (escape-esc $r.label)}}}} | to json",
        source_cmd(file)
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

/// Remove nuance from Nushell's autoload directory. With `purge`, also delete
/// the state files and the `nuance/` directory (imported themes, user styles).
/// Deliberately does not go through `with_nu`, which would (re)install first.
pub(crate) fn uninstall(purge: bool) -> ExitCode {
    if let Err(e) = ensure_nu() {
        eprintln!("nuance: {e}");
        return ExitCode::FAILURE;
    }
    let mut removed: Vec<PathBuf> = Vec::new();
    if let Some(dir) = autoload_dir() {
        let target = dir.join(FILE);
        if (target.exists() || is_symlink(&target)) && fs::remove_file(&target).is_ok() {
            removed.push(target.clone());
        }
        let _ = fs::remove_file(stamp_path(&target));
    }
    if purge {
        for p in state_paths() {
            let gone = if p.is_dir() {
                fs::remove_dir_all(&p).is_ok()
            } else {
                p.exists() && fs::remove_file(&p).is_ok()
            };
            if gone {
                removed.push(p);
            }
        }
        if let Some(d) = user_cache_dir().map(|d| d.join("nuance"))
            && d.is_dir()
            && fs::remove_dir_all(&d).is_ok()
        {
            removed.push(d);
        }
    }
    if removed.is_empty() {
        println!("nothing to remove — nuance is not installed in Nushell's autoload directory.");
    } else {
        for p in &removed {
            println!("\x1b[1;32m\u{2713}\x1b[0m removed {}", p.display());
        }
        println!(
            "open a new shell (or run: exec nu) — the nuance binary itself stays; remove it with `cargo uninstall nuance-cli`."
        );
    }
    ExitCode::SUCCESS
}

/// The state files and directories nuance writes, as listed by the script's
/// own `nuance-state-paths` (the bundled copy, so it works after the autoload
/// file is gone and honors `NUANCE_CONFIG_DIR` / `NUANCE_CACHE_DIR`).
fn state_paths() -> Vec<PathBuf> {
    let tmp = std::env::temp_dir().join(format!("nuance-uninstall-{}.nu", std::process::id()));
    if fs::write(&tmp, NUSHELL_PROMPT).is_err() {
        return Vec::new();
    }
    let out = nu_capture(&format!(
        "{}; nuance-state-paths | to json",
        source_cmd(&tmp)
    ));
    let _ = fs::remove_file(&tmp);
    out.and_then(|j| serde_json::from_str::<Vec<PathBuf>>(&j).ok())
        .unwrap_or_default()
}

pub(crate) fn cmd_update(target: &Path) -> ExitCode {
    let Some(dir) = repo_dir(target) else {
        println!("nuance was installed via `cargo install nuance-cli` (no git checkout).");
        println!("To update:  cargo install --force nuance-cli   then: exec nu");
        return ExitCode::SUCCESS;
    };
    println!("\x1b[1;32m==>\x1b[0m updating {} …", dir.display());
    let status = Command::new("git")
        .arg("-C")
        .arg(&dir)
        .arg("pull")
        .arg("--ff-only")
        .status();
    match status {
        Ok(s) if s.success() => {
            println!("\x1b[1;32m\u{2713}\x1b[0m updated — open a new shell (or run: exec nu)");
            ExitCode::SUCCESS
        }
        _ => ExitCode::FAILURE,
    }
}

/// Quote a list of args as a space-separated sequence of double-quoted
/// Nushell string literals, safe to splice into a `nu -c` script.
pub(crate) fn quote(args: &[String]) -> String {
    args.iter()
        .map(|a| format!("\"{}\"", a.replace('\\', "\\\\").replace('"', "\\\"")))
        .collect::<Vec<_>>()
        .join(" ")
}

#[cfg(test)]
mod tests {
    #[cfg(unix)]
    #[test]
    fn find_in_path_requires_an_executable_file() {
        use std::os::unix::fs::PermissionsExt;
        let d = std::env::temp_dir().join(format!("nuance-path-{}", std::process::id()));
        fs::create_dir_all(&d).unwrap();
        let exe = d.join("tool-x");
        let plain = d.join("tool-plain");
        fs::write(&exe, "#!/bin/sh\n").unwrap();
        fs::write(&plain, "x").unwrap();
        fs::set_permissions(&exe, fs::Permissions::from_mode(0o755)).unwrap();
        fs::set_permissions(&plain, fs::Permissions::from_mode(0o644)).unwrap();
        let path = std::env::join_paths([d.clone()]).unwrap();
        assert!(find_in_path("tool-x", &path));
        assert!(!find_in_path("tool-plain", &path), "non-exec file");
        assert!(!find_in_path("missing", &path));
        assert!(!find_in_path("tool-x", std::ffi::OsStr::new("")));
        let _ = fs::remove_dir_all(&d);
    }

    #[test]
    fn have_finds_cargo_but_not_nonsense() {
        assert!(have("cargo"));
        assert!(!have("definitely-not-a-real-binary-xyz"));
    }

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
    fn write_atomic_writes_and_leaves_no_tmp() {
        let dir = std::env::temp_dir().join(format!("nuance-atomic-{}", std::process::id()));
        fs::create_dir_all(&dir).unwrap();
        let f = dir.join("x.nu");
        write_atomic(&f, b"one").unwrap();
        write_atomic(&f, b"two").unwrap();
        assert_eq!(fs::read_to_string(&f).unwrap(), "two");
        assert!(!dir.join("x.nu.tmp").exists());
        fs::remove_dir_all(&dir).ok();
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

    /// Regression: a path with spaces and backslash-letter sequences
    /// (`C:\Users\Maya Nadia\AppData`) must survive `source`.
    #[test]
    fn fetch_picker_items_sources_path_with_spaces_and_backslashes() {
        if Command::new("nu").arg("--version").output().is_err() {
            eprintln!("skipped: nu not installed");
            return;
        }
        let base = std::env::temp_dir().join(format!("nuance Maya Nadia {}", std::process::id()));
        // On Windows `\AppData` nests; on unix it is one odd directory name.
        let dir = if cfg!(windows) {
            base.join("AppData\\Roaming")
        } else {
            base.join("a\\AppData\\Roaming")
        };
        fs::create_dir_all(&dir).unwrap();
        let file = dir.join("prompt.nu");
        fs::write(
            &file,
            "def escape-esc [s] { $s }\ndef items [] { [{key: k1, label: L1}] }\n",
        )
        .unwrap();
        let items = fetch_picker_items(&file, "items");
        let _ = fs::remove_dir_all(&base);
        let items = items.unwrap();
        assert_eq!(items.len(), 1);
        assert_eq!(items[0].key, "k1");
    }

    fn scratch(tag: &str) -> PathBuf {
        let d = std::env::temp_dir().join(format!("nuance-vendor-{tag}-{}", std::process::id()));
        let _ = fs::remove_dir_all(&d);
        fs::create_dir_all(&d).unwrap();
        d
    }

    #[test]
    fn vendor_installs_when_missing() {
        let d = scratch("missing");
        let t = d.join("sub").join(FILE);
        assert_eq!(vendor(&t, "v1").unwrap(), Vendored::Installed);
        assert_eq!(fs::read_to_string(&t).unwrap(), "v1");
        assert!(stamp_path(&t).exists());
        let _ = fs::remove_dir_all(&d);
    }

    #[test]
    fn vendor_is_noop_when_current() {
        let d = scratch("current");
        let t = d.join(FILE);
        vendor(&t, "v1").unwrap();
        assert_eq!(vendor(&t, "v1").unwrap(), Vendored::Current);
        let _ = fs::remove_dir_all(&d);
    }

    /// Regression: `cargo install --force nuance-cli` left the old prompt
    /// script in the autoload dir forever.
    #[test]
    fn vendor_refreshes_copy_it_wrote_earlier() {
        let d = scratch("refresh");
        let t = d.join(FILE);
        vendor(&t, "v1").unwrap();
        assert_eq!(vendor(&t, "v2").unwrap(), Vendored::Refreshed);
        assert_eq!(fs::read_to_string(&t).unwrap(), "v2");
        assert_eq!(vendor(&t, "v2").unwrap(), Vendored::Current);
        let _ = fs::remove_dir_all(&d);
    }

    #[test]
    fn vendor_keeps_user_edited_copy() {
        let d = scratch("edited");
        let t = d.join(FILE);
        vendor(&t, "v1").unwrap();
        fs::write(&t, "mine").unwrap();
        assert_eq!(vendor(&t, "v2").unwrap(), Vendored::UserOwned);
        assert_eq!(fs::read_to_string(&t).unwrap(), "mine");
        let _ = fs::remove_dir_all(&d);
    }

    #[test]
    fn vendor_keeps_unstamped_copy() {
        let d = scratch("unstamped");
        let t = d.join(FILE);
        fs::write(&t, "clone").unwrap();
        assert_eq!(vendor(&t, "v2").unwrap(), Vendored::UserOwned);
        assert_eq!(fs::read_to_string(&t).unwrap(), "clone");
        let _ = fs::remove_dir_all(&d);
    }

    #[test]
    fn fnv1a_is_stable() {
        assert_eq!(fnv1a(b""), "cbf29ce484222325");
        assert_eq!(fnv1a(b"a"), "af63dc4c8601ec8c");
    }

    #[test]
    fn source_cmd_uses_raw_string() {
        let p = Path::new(r"C:\Users\Maya Nadia\AppData\x.nu");
        assert_eq!(
            source_cmd(p),
            r"source r#'C:\Users\Maya Nadia\AppData\x.nu'#"
        );
    }

    #[test]
    fn source_cmd_grows_hashes_past_quote_hash() {
        let p = Path::new("/tmp/a'#b'##c.nu");
        assert_eq!(source_cmd(p), "source r###'/tmp/a'#b'##c.nu'###");
    }

    /// Paths with quotes and backticks must source too (not only spaces).
    #[test]
    fn run_through_nu_with_hostile_path() {
        if Command::new("nu").arg("--version").output().is_err() {
            eprintln!("skipped: nu not installed");
            return;
        }
        let d = scratch("hostile");
        // `"`, `` ` `` and `*` are not valid in Windows file names.
        let name = if cfg!(windows) {
            "it's #1 & co"
        } else {
            "it's \"#1\" `x`"
        };
        let dir = d.join(name);
        fs::create_dir_all(&dir).unwrap();
        let file = dir.join("p.nu");
        fs::write(
            &file,
            "def escape-esc [s] { $s }\ndef items [] { [{key: k, label: l}] }\n",
        )
        .unwrap();
        let items = fetch_picker_items(&file, "items");
        let _ = fs::remove_dir_all(&d);
        assert_eq!(items.unwrap()[0].key, "k");
    }

    #[test]
    fn nu_installer_prefers_package_manager() {
        let all = |_: &str| true;
        assert_eq!(nu_installer("windows", all).unwrap()[0], "winget");
        assert_eq!(nu_installer("macos", all).unwrap()[0], "brew");
        assert_eq!(nu_installer("linux", all).unwrap()[0], "brew");
        assert_eq!(nu_installer("freebsd", all).unwrap()[0], "cargo");
    }

    #[test]
    fn nu_installer_falls_back_to_cargo_then_none() {
        let cargo_only = |c: &str| c == "cargo";
        assert_eq!(nu_installer("windows", cargo_only).unwrap()[0], "cargo");
        assert_eq!(nu_installer("macos", cargo_only).unwrap()[0], "cargo");
        assert!(nu_installer("linux", |_: &str| false).is_none());
    }

    #[test]
    fn cache_dir_per_os() {
        let env = |k: &str| match k {
            "HOME" => Some(PathBuf::from("/h")),
            "LOCALAPPDATA" => Some(PathBuf::from("/l")),
            _ => None,
        };
        assert_eq!(cache_dir_for("windows", env), Some(PathBuf::from("/l")));
        assert_eq!(
            cache_dir_for("macos", env),
            Some(Path::new("/h").join("Library").join("Caches"))
        );
        assert_eq!(
            cache_dir_for("linux", env),
            Some(Path::new("/h").join(".cache"))
        );
        let xdg = |k: &str| (k == "XDG_CACHE_HOME").then(|| PathBuf::from("/x"));
        assert_eq!(cache_dir_for("linux", xdg), Some(PathBuf::from("/x")));
        assert_eq!(cache_dir_for("windows", |_: &str| None), None);
    }

    #[test]
    fn drift_hint_only_for_differing_regular_file() {
        let d = scratch("drift");
        let t = d.join(FILE);
        assert_eq!(
            drift_hint_for(&t, "v1"),
            None,
            "missing file: nothing to say"
        );
        fs::write(&t, "v1").unwrap();
        assert_eq!(drift_hint_for(&t, "v1"), None);
        fs::write(&t, "old").unwrap();
        assert!(drift_hint_for(&t, "v1").unwrap().contains("differs"));
        let _ = fs::remove_dir_all(&d);
    }

    #[test]
    fn state_paths_come_from_the_script() {
        if Command::new("nu").arg("--version").output().is_err() {
            eprintln!("skipped: nu not installed");
            return;
        }
        let paths = state_paths();
        assert_eq!(paths.len(), 10, "{paths:?}");
        assert!(paths.iter().any(|p| p.ends_with("icons.txt")));
        assert!(paths.iter().any(|p| p.ends_with("current-theme.txt")));
    }
}
