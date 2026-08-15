//! Integration tests for the `nuance` CLI — covers the same behavior the
//! old POSIX `scripts/nuance` shell CLI + `test.bats` used to check, now that
//! this Rust binary is the only any-shell CLI (see the repo README).

use std::path::Path;
use std::process::{Command, Output};

fn have_nu() -> bool {
    Command::new("sh")
        .arg("-c")
        .arg("command -v nu >/dev/null 2>&1")
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

fn run(home: &Path, args: &[&str]) -> Output {
    Command::new(env!("CARGO_BIN_EXE_nuance"))
        .args(args)
        .env("HOME", home)
        // Windows isn't a target for this CLI, but keep HOME-only override simple/portable.
        .output()
        .expect("failed to run nuance binary")
}

fn config_dir(home: &Path) -> String {
    let out = Command::new("nu")
        .arg("-n")
        .arg("-c")
        .arg("$nu.default-config-dir")
        .env("HOME", home)
        .output()
        .expect("failed to run nu");
    String::from_utf8_lossy(&out.stdout).trim().to_string()
}

#[test]
fn help_prints_usage() {
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["help"]);
    assert!(out.status.success());
    let stdout = String::from_utf8_lossy(&out.stdout);
    assert!(stdout.contains("nuance theme"));
    assert!(stdout.contains("update"));
}

#[test]
fn no_args_prints_usage() {
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &[]);
    assert!(out.status.success());
    assert!(String::from_utf8_lossy(&out.stdout).contains("nuance"));
}

#[test]
fn unknown_subcommand_exits_non_zero() {
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["frobnicate"]);
    assert!(!out.status.success());
    assert!(String::from_utf8_lossy(&out.stdout).contains("nuance"));
}

#[test]
fn theme_sets_and_pins() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["theme", "gruvbox"]);
    assert!(out.status.success());
    assert!(String::from_utf8_lossy(&out.stdout).contains("gruvbox"));
    let cfg = config_dir(home.path());
    let pinned = std::fs::read_to_string(format!("{cfg}/current-theme.txt")).unwrap();
    assert_eq!(pinned.trim(), "gruvbox");
}

#[test]
fn theme_rejects_unknown_name() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["theme", "not-a-real-theme"]);
    assert!(String::from_utf8_lossy(&out.stdout).contains("unknown theme"));
}

#[test]
fn prompt_style_sets() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["prompt-style", "powerline"]);
    assert!(out.status.success());
    assert!(String::from_utf8_lossy(&out.stdout).contains("powerline"));
    let cfg = config_dir(home.path());
    let pinned = std::fs::read_to_string(format!("{cfg}/prompt-style.txt")).unwrap();
    assert_eq!(pinned.trim(), "powerline");
}

#[test]
fn look_applies_preset() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["look", "cyberpunk"]);
    assert!(out.status.success());
    assert!(String::from_utf8_lossy(&out.stdout).contains("cyberpunk"));
}

#[test]
fn first_run_vendors_prompt_script_into_autoload_dir() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["theme", "gruvbox"]);
    assert!(out.status.success());
    let dir = Command::new("nu")
        .arg("-n")
        .arg("-c")
        .arg("$nu.user-autoload-dirs | get 0")
        .env("HOME", home.path())
        .output()
        .unwrap();
    let dir = String::from_utf8_lossy(&dir.stdout).trim().to_string();
    assert!(Path::new(&dir).join("nushell-prompt.nu").exists());
}
