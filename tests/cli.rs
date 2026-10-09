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
    run_in(home, home, args)
}

/// Like `run`, but with an explicit working directory (for `nuance here`).
fn run_in(home: &Path, cwd: &Path, args: &[&str]) -> Output {
    Command::new(env!("CARGO_BIN_EXE_nuance"))
        .current_dir(cwd)
        .args(args)
        .env("HOME", home)
        // Force full isolation from the outer environment: on Linux, Nushell
        // (and XDG-aware tools generally) prefer XDG_CONFIG_HOME/XDG_CACHE_HOME
        // over deriving a path from HOME when those vars are set — if the CI
        // runner has them set globally, every test's subprocess would collide
        // on the *same real* config dir despite each test using its own
        // tempdir HOME, causing flaky cross-test failures under `cargo test`'s
        // default parallelism (e.g. prompt_style_sets seeing a value written
        // by a concurrently-running look_applies_preset). Pin them under the
        // same per-test tempdir so HOME is the only thing that matters.
        .env("XDG_CONFIG_HOME", home.join(".config"))
        .env("XDG_CACHE_HOME", home.join(".cache"))
        .env("XDG_DATA_HOME", home.join(".local/share"))
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
        .env("XDG_CONFIG_HOME", home.join(".config"))
        .env("XDG_CACHE_HOME", home.join(".cache"))
        .env("XDG_DATA_HOME", home.join(".local/share"))
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
        .env("XDG_CONFIG_HOME", home.path().join(".config"))
        .env("XDG_CACHE_HOME", home.path().join(".cache"))
        .env("XDG_DATA_HOME", home.path().join(".local/share"))
        .output()
        .unwrap();
    let dir = String::from_utf8_lossy(&dir.stdout).trim().to_string();
    assert!(Path::new(&dir).join("nushell-prompt.nu").exists());
}

#[test]
fn transient_persists_and_reports_state() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["transient", "on"]);
    assert!(out.status.success());
    let cfg = config_dir(home.path());
    let saved = std::fs::read_to_string(format!("{cfg}/transient.txt")).unwrap();
    assert_eq!(saved.trim(), "on");
    let out = run(home.path(), &["transient"]);
    assert!(String::from_utf8_lossy(&out.stdout).contains("transient prompt: "));
    let out = run(home.path(), &["transient", "sideways"]);
    assert!(String::from_utf8_lossy(&out.stdout).contains("unknown mode"));
}

#[test]
fn modules_enable_persists_and_rejects_unknown() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["modules", "enable", "lang", "jobs"]);
    assert!(out.status.success());
    let cfg = config_dir(home.path());
    let saved = std::fs::read_to_string(format!("{cfg}/modules.txt")).unwrap();
    assert_eq!(saved.lines().collect::<Vec<_>>(), ["lang", "jobs"]);

    let out = run(home.path(), &["modules", "disable", "jobs"]);
    assert!(out.status.success());
    let saved = std::fs::read_to_string(format!("{cfg}/modules.txt")).unwrap();
    assert_eq!(saved.lines().collect::<Vec<_>>(), ["lang"]);

    let out = run(home.path(), &["modules", "enable", "bogus"]);
    assert!(String::from_utf8_lossy(&out.stdout).contains("usage:"));
    let out = run(home.path(), &["modules"]);
    let listing = String::from_utf8_lossy(&out.stdout);
    assert!(listing.contains("status") && listing.contains("lang"));
}

#[test]
fn import_creates_a_selectable_theme() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let scheme = home.path().join("sample-scheme");
    std::fs::write(
        &scheme,
        "palette = 1=#ff5555\npalette = 2=#50fa7b\npalette = 3=#f1fa8c\n\
         palette = 4=#bd93f9\npalette = 5=#ff79c6\npalette = 6=#8be9fd\n\
         palette = 8=#6272a4\nbackground = #282a36\nforeground = #f8f8f2\n",
    )
    .unwrap();
    let out = run(
        home.path(),
        &["import", scheme.to_str().unwrap(), "--name", "My Sample"],
    );
    assert!(out.status.success());
    assert!(String::from_utf8_lossy(&out.stdout).contains("imported"));
    let cfg = config_dir(home.path());
    assert!(Path::new(&format!("{cfg}/nuance/themes/my-sample.nuon")).exists());

    // …and it can be pinned like any built-in theme.
    let out = run(home.path(), &["theme", "my-sample"]);
    assert!(String::from_utf8_lossy(&out.stdout).contains("my-sample"));
    let pinned = std::fs::read_to_string(format!("{cfg}/current-theme.txt")).unwrap();
    assert_eq!(pinned.trim(), "my-sample");

    // Built-in names are protected.
    let out = run(
        home.path(),
        &["import", scheme.to_str().unwrap(), "--name", "dracula"],
    );
    assert!(String::from_utf8_lossy(&out.stdout).contains("built-in"));
}

#[test]
fn here_writes_and_clears_dot_nuance() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let work = tempfile::tempdir().unwrap();
    let out = run_in(home.path(), work.path(), &["here", "dracula", "powerline"]);
    assert!(out.status.success());
    let body = std::fs::read_to_string(work.path().join(".nuance")).unwrap();
    assert!(body.contains("theme = \"dracula\""), "got: {body}");
    assert!(body.contains("style = \"powerline\""), "got: {body}");

    let out = run_in(home.path(), work.path(), &["here", "not-a-theme"]);
    assert!(String::from_utf8_lossy(&out.stdout).contains("unknown theme"));

    let out = run_in(home.path(), work.path(), &["here", "clear"]);
    assert!(out.status.success());
    assert!(!work.path().join(".nuance").exists());
}

#[test]
fn doctor_reports_checks() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["doctor"]);
    assert!(out.status.success());
    let stdout = String::from_utf8_lossy(&out.stdout);
    for check in [
        "nushell version",
        "truecolor",
        "autoload file",
        "transient prompt",
    ] {
        assert!(
            stdout.contains(check),
            "doctor output missing `{check}`:\n{stdout}"
        );
    }
}

fn stdout(o: &Output) -> String {
    String::from_utf8_lossy(&o.stdout).to_string()
}

#[test]
fn list_and_current_emit_json() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["list", "themes", "--json"]);
    assert!(out.status.success());
    let v: serde_json::Value = serde_json::from_str(stdout(&out).trim()).expect("valid JSON");
    assert!(v.as_array().unwrap().len() >= 60, "expected many themes");
    assert!(v
        .as_array()
        .unwrap()
        .iter()
        .any(|t| t["name"] == "gruvbox" && t["light"] == false));

    let out = run(home.path(), &["list", "styles", "--json"]);
    let v: serde_json::Value = serde_json::from_str(stdout(&out).trim()).unwrap();
    assert!(v
        .as_array()
        .unwrap()
        .iter()
        .any(|s| s["name"] == "powerline"));

    let out = run(home.path(), &["current", "--json"]);
    let v: serde_json::Value = serde_json::from_str(stdout(&out).trim()).unwrap();
    for k in ["theme", "style", "transient", "modules", "colors", "git"] {
        assert!(v.get(k).is_some(), "current is missing `{k}`");
    }
}

#[test]
fn preview_renders_without_applying() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let work = tempfile::tempdir().unwrap();
    let out = run_in(home.path(), work.path(), &["preview", "dracula", "bracket"]);
    assert!(out.status.success());
    assert!(
        stdout(&out).contains('['),
        "bracket style should render brackets"
    );
    // nothing was pinned
    let cfg = config_dir(home.path());
    assert!(!Path::new(&format!("{cfg}/current-theme.txt")).exists());
    let out = run(home.path(), &["preview", "no-such-theme"]);
    assert!(stdout(&out).contains("unknown theme"));
}

#[test]
fn export_and_import_round_trip() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let out = run(
        home.path(),
        &["import", "nuance:1:nord:agnoster:lang+jobs:dir"],
    );
    assert!(out.status.success());
    assert!(stdout(&out).contains("applied"));
    let cfg = config_dir(home.path());
    let theme = std::fs::read_to_string(format!("{cfg}/current-theme.txt")).unwrap();
    assert_eq!(theme.trim(), "nord");
    let style = std::fs::read_to_string(format!("{cfg}/prompt-style.txt")).unwrap();
    assert_eq!(style.trim(), "agnoster");
    let modules = std::fs::read_to_string(format!("{cfg}/modules.txt")).unwrap();
    assert_eq!(modules.lines().collect::<Vec<_>>(), ["lang", "jobs"]);

    // a fresh shell exports exactly what was imported
    let out = run(home.path(), &["export"]);
    assert_eq!(stdout(&out).trim(), "nuance:1:nord:agnoster:lang+jobs:dir");

    let out = run(home.path(), &["import", "nuance:1:no-such-theme:full::off"]);
    assert!(stdout(&out).contains("unknown theme"));
}

#[test]
fn integration_and_appearance_persist() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let cfg = config_dir(home.path());
    let out = run(home.path(), &["integration", "off"]);
    assert!(out.status.success());
    assert_eq!(
        std::fs::read_to_string(format!("{cfg}/integration.txt"))
            .unwrap()
            .trim(),
        "off"
    );
    let out = run(home.path(), &["integration", "status"]);
    assert!(stdout(&out).contains("off"));

    let out = run(home.path(), &["appearance", "dracula", "tokyo-night-day"]);
    assert!(out.status.success());
    assert_eq!(
        std::fs::read_to_string(format!("{cfg}/appearance.txt"))
            .unwrap()
            .trim(),
        "dracula,tokyo-night-day"
    );
    assert_eq!(
        std::fs::read_to_string(format!("{cfg}/current-theme.txt"))
            .unwrap()
            .trim(),
        "appearance"
    );
    run(home.path(), &["appearance", "off"]);
    assert!(!Path::new(&format!("{cfg}/appearance.txt")).exists());
}

#[test]
fn custom_style_can_be_created_and_used() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["style", "new", "mine"]);
    assert!(out.status.success());
    let cfg = config_dir(home.path());
    assert!(Path::new(&format!("{cfg}/nuance/styles/mine.nuon")).exists());
    let out = run(home.path(), &["prompt-style", "mine"]);
    assert!(stdout(&out).contains("prompt style set to"));
    let out = run(home.path(), &["style", "new", "powerline"]);
    assert!(stdout(&out).contains("built-in"));
}

#[test]
fn completions_are_generated() {
    let home = tempfile::tempdir().unwrap();
    for shell in ["bash", "zsh", "fish"] {
        let out = run(home.path(), &["completions", shell]);
        assert!(out.status.success(), "{shell}");
        let text = stdout(&out);
        assert!(
            text.contains("nuance"),
            "{shell} completions mention nuance"
        );
        assert!(
            text.contains("uninstall"),
            "{shell} completions list subcommands"
        );
    }
}

#[test]
fn uninstall_removes_the_autoload_file_and_purges_state() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let cfg = config_dir(home.path());
    run(home.path(), &["theme", "gruvbox"]); // installs + pins
    assert!(Path::new(&format!("{cfg}/autoload/nushell-prompt.nu")).exists());
    assert!(Path::new(&format!("{cfg}/current-theme.txt")).exists());

    let out = run(home.path(), &["uninstall"]);
    assert!(out.status.success());
    assert!(stdout(&out).contains("removed"));
    assert!(!Path::new(&format!("{cfg}/autoload/nushell-prompt.nu")).exists());
    assert!(
        Path::new(&format!("{cfg}/current-theme.txt")).exists(),
        "state survives a plain uninstall"
    );

    let out = run(home.path(), &["uninstall", "--purge"]);
    assert!(out.status.success());
    assert!(!Path::new(&format!("{cfg}/current-theme.txt")).exists());

    let out = run(home.path(), &["uninstall"]);
    assert!(stdout(&out).contains("nothing to remove"));
}

#[test]
fn doctor_can_clear_errors() {
    if !have_nu() {
        eprintln!("skip: nushell not installed");
        return;
    }
    let home = tempfile::tempdir().unwrap();
    let out = run(home.path(), &["doctor", "--clear-errors"]);
    assert!(out.status.success());
    assert!(stdout(&out).contains("cleared"));
}
