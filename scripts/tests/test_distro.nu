#!/usr/bin/env nu
# ── nuance · test_distro.nu ──────────────────────────────────────
# .deb/.rpm names and metadata, and the package-manager manifests.

use std/assert
use runner.nu *
use ../ci/distro.nu [deb_arch rpm_arch deb_name rpm_name payload deb_control rpm_spec render outputs archive_sha LINUX_TARGETS]
use ../ci/push_manifest.nu [remote_url commit_message]

def root [] { $env.CURRENT_FILE | path dirname | path join ".." ".." | path expand }

def "test distro: debian and rpm arch names" [] {
    assert equal (deb_arch x86_64-unknown-linux-musl) amd64
    assert equal (deb_arch aarch64-unknown-linux-musl) arm64
    assert equal (rpm_arch x86_64-unknown-linux-musl) x86_64
    assert equal (rpm_arch aarch64-unknown-linux-musl) aarch64
}

def "test distro: package file names" [] {
    assert equal (deb_name 1.2.3 aarch64-unknown-linux-musl) nuance_1.2.3_arm64.deb
    assert equal (rpm_name 1.2.3 x86_64-unknown-linux-musl) nuance-1.2.3-1.x86_64.rpm
}

def "test distro: linux packages come from the static musl archives" [] {
    assert ($LINUX_TARGETS | all {|t| $t | str ends-with "linux-musl" })
}

def "test distro: payload has completions only when generated" [] {
    assert equal (payload false) [usr/bin/nuance usr/share/doc/nuance/copyright]
    let full = payload true
    assert equal ($full | length) 5
    assert ($full | any {|f| $f | str ends-with "_nuance" })
}

def "test distro: deb control is valid-shaped" [] {
    let c = deb_control 1.2.3 x86_64-unknown-linux-musl
    assert ($c | str contains "Package: nuance\n")
    assert ($c | str contains "Version: 1.2.3\n")
    assert ($c | str contains "Architecture: amd64\n")
    assert ($c | str contains "Recommends: nushell\n")
    assert ($c | str ends-with "\n")
    # continuation lines of Description start with exactly one space
    let cont = $c | lines | skip until {|l| $l | str starts-with "Description:" } | skip 1 | where $it != ""
    assert ($cont | all {|l| ($l | str starts-with " ") and not ($l | str starts-with "  ") })
}

def "test distro: rpm spec lists every file and disables post-processing" [] {
    let s = rpm_spec 1.2.3 aarch64-unknown-linux-musl /stage (payload true)
    assert ($s | str contains "Version: 1.2.3\n")
    assert ($s | str contains "%global __os_install_post %{nil}")
    assert ($s | str contains "cp -a '/stage/.' %{buildroot}/")
    assert ($s | str contains "/usr/bin/nuance\n")
    assert not ($s | str contains "BuildArch")
}

def "test distro: render replaces every placeholder" [] {
    assert equal (render "a @X@ b @X@ @Y@" {X: 1, Y: two}) "a 1 b 1 two"
}

def "test distro: templates use only known placeholders" [] {
    let known = [VERSION SHA_MACOS_ARM SHA_MACOS_X86 SHA_LINUX_ARM SHA_LINUX_X86 SHA_WINDOWS_X86 SHA_LICENSE]
    for o in (outputs) {
        let used = open --raw (root | path join $o.tpl) | parse --regex '@(?<k>[A-Z_0-9]+)@' | get k | uniq
        for k in $used { assert ($k in $known) $"($o.tpl) uses unknown @($k)@" }
        assert ("VERSION" in $used) $"($o.tpl) never uses @VERSION@"
    }
}

def "test distro: manifests reference the release archive names" [] {
    let rb = open --raw (root | path join packaging homebrew nuance.rb.in)
    for t in [aarch64-apple-darwin x86_64-apple-darwin aarch64-unknown-linux-musl x86_64-unknown-linux-musl] {
        assert ($rb | str contains $"nuance-($t).tar.gz") $t
    }
    let scoop = open --raw (root | path join packaging scoop nuance.json.in) | from json
    assert equal $scoop.bin nuance.exe
    assert ($scoop.architecture."64bit".url | str ends-with "nuance-x86_64-pc-windows-msvc.zip")
}

def "test distro: archive_sha refuses a missing archive" [] {
    let d = mktemp -d
    let r = try { archive_sha $d x86_64-apple-darwin; "no error" } catch { "error" }
    assert equal $r "error"
    "x" | save ($d | path join nuance-x86_64-pc-windows-msvc.zip)
    assert equal (archive_sha $d x86_64-pc-windows-msvc) ("x" | hash sha256)
    rm -rf $d
}

def "test push_manifest: url and commit message" [] {
    assert equal (remote_url o/r t) "https://x-access-token:t@github.com/o/r.git"
    assert equal (commit_message Formula/nuance.rb 1.2.3) "nuance: update to 1.2.3"
    assert equal (commit_message bucket/nuance.json 1.2.3) "nuance: update to 1.2.3"
}

def "test distro: the release workflow builds, verifies and ships every channel" [] {
    let wf = open (root | path join .github workflows release.yml)
    let runs = $wf.jobs.publish.steps | get -o run | compact | str join "\n"
    for cmd in ["distro.nu tools" "distro.nu packages" "distro.nu verify" "distro.nu manifests"] {
        assert ($runs | str contains $cmd) $cmd
    }
    for job in [homebrew scoop aur] {
        assert ($job in ($wf.jobs | columns)) $job
        assert ("publish" in ($wf.jobs | get $job | get needs)) $"($job) runs after the GitHub release"
    }
    assert equal ($wf.jobs.aur.steps | where uses? =~ "deploy-aur" | get 0.with.pkgname) nuance-bin
}

def main [] { run-tests }
