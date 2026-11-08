#!/usr/bin/env nu
# ──────────────────────────────────────────────────────────────────────────────
# nuance — Distro packages and package-manager manifests
# ──────────────────────────────────────────────────────────────────────────────
# Works from the release archives in `dist/` (scripts/ci/package.nu); nothing is
# rebuilt. The Linux binaries are static musl, so the packages have no library
# dependencies — only a soft one on Nushell, which nuance drives at runtime.
#
#   packages   .deb + .rpm per Linux archive, with bash/zsh/fish completions
#              (needs dpkg-deb and rpmbuild: `sudo apt-get install -y rpm`)
#   manifests  Homebrew formula, Scoop manifest and AUR PKGBUILD with the
#              archives' sha256 filled in
#
# Usage:
#   nu scripts/ci/distro.nu tools                       (installs rpmbuild)
#   nu scripts/ci/distro.nu packages <version> [--dir dist]
#   nu scripts/ci/distro.nu verify <version> [--dir dist]   (installs the .deb)
#   nu scripts/ci/distro.nu manifests <version> [--dir dist] [--out dist/manifests]
# ──────────────────────────────────────────────────────────────────────────────

use apt.nu [commands]

export const APP = "nuance"
export const SUMMARY = "Themeable, git-aware Nushell prompt with a live-preview theme picker"
export const HOMEPAGE = "https://github.com/sorinirimies/nuance"
export const MAINTAINER = "Sorin Irimies <sorinirimies@gmail.com>"
export const LINUX_TARGETS = [x86_64-unknown-linux-musl aarch64-unknown-linux-musl]

export def deb_arch [target: string]: nothing -> string {
    if ($target | str starts-with "aarch64") { "arm64" } else { "amd64" }
}

export def rpm_arch [target: string]: nothing -> string {
    if ($target | str starts-with "aarch64") { "aarch64" } else { "x86_64" }
}

export def deb_name [version: string, target: string]: nothing -> string {
    $"($APP)_($version)_(deb_arch $target).deb"
}

export def rpm_name [version: string, target: string]: nothing -> string {
    $"($APP)-($version)-1.(rpm_arch $target).rpm"
}

# Files inside the package, relative to its root (completions are optional:
# they need a binary this host can run).
export def payload [completions: bool]: nothing -> list<string> {
    let base = [$"usr/bin/($APP)" $"usr/share/doc/($APP)/copyright"]
    if $completions {
        $base | append [
            $"usr/share/bash-completion/completions/($APP)"
            $"usr/share/zsh/vendor-completions/_($APP)"
            $"usr/share/fish/vendor_completions.d/($APP).fish"
        ]
    } else { $base }
}

export def deb_control [version: string, target: string]: nothing -> string {
    [
        $"Package: ($APP)"
        $"Version: ($version)"
        $"Architecture: (deb_arch $target)"
        $"Maintainer: ($MAINTAINER)"
        "Section: shells"
        "Priority: optional"
        "Recommends: nushell"
        $"Homepage: ($HOMEPAGE)"
        $"Description: ($SUMMARY)"
        " Run any nuance command once (e.g. `nuance theme`) to install the prompt"
        " into Nushell's autoload directory."
        ""
    ] | str join "\n"
}

export def rpm_spec [version: string, target: string, root: string, files: list<string>]: nothing -> string {
    [
        $"Name: ($APP)"
        $"Version: ($version)"
        "Release: 1"
        $"Summary: ($SUMMARY)"
        "License: MIT"
        $"URL: ($HOMEPAGE)"
        "Recommends: nushell"
        "AutoReqProv: no"
        # A prebuilt static binary: no debuginfo, no stripping, no build-id links
        # (which would also fail for a foreign-arch binary).
        "%global debug_package %{nil}"
        "%global __os_install_post %{nil}"
        "%global _build_id_links none"
        ""
        "%description"
        $SUMMARY
        ""
        "%install"
        $"cp -a '($root)/.' %{buildroot}/"
        ""
        "%files"
        ...($files | each {|f| $"/($f)" })
        ""
    ] | str join "\n"
}

# @KEY@ → value for every key in `vars`.
export def render [tpl: string, vars: record]: nothing -> string {
    $vars | items {|k, v| [$k ($v | into string)] } | reduce --fold $tpl {|it, acc| $acc | str replace --all $"@($it.0)@" $it.1 }
}

# Template → output file name.
export def outputs []: nothing -> list<record<tpl: string, out: string>> {
    [
        [packaging/homebrew/nuance.rb.in nuance.rb]
        [packaging/scoop/nuance.json.in nuance.json]
        [packaging/aur/PKGBUILD.in PKGBUILD]
    ] | each {|p| { tpl: $p.0, out: $p.1 } }
}

# sha256 of `<dir>/nuance-<target>.<ext>`; errors when it is missing, so a
# manifest never ships with a placeholder hash.
export def archive_sha [dir: string, target: string]: nothing -> string {
    let ext = if ($target | str contains "windows") { "zip" } else { "tar.gz" }
    let f = ($dir | path join $"($APP)-($target).($ext)")
    if not ($f | path exists) { error make {msg: $"($f) missing — download the release archives first"} }
    open --raw $f | hash sha256
}

def stage_root [archive: string, completions_from: string] {
    let root = (mktemp -d)
    # mktemp makes 0700 dirs; the package root becomes `/` when installed.
    ^chmod 755 $root
    let unpack = (mktemp -d)
    ^tar -xzf $archive -C $unpack
    mkdir ($root | path join usr bin) ($root | path join usr share doc $APP)
    cp ($unpack | path join $APP) ($root | path join usr bin $APP)
    ^chmod 755 ($root | path join usr bin $APP)
    cp LICENSE ($root | path join usr share doc $APP copyright)
    rm -rf $unpack
    let can = ($completions_from != "")
    if $can {
        for c in [[bash usr/share/bash-completion/completions/nuance] [zsh usr/share/zsh/vendor-completions/_nuance] [fish usr/share/fish/vendor_completions.d/nuance.fish]] {
            let dest = ($root | path join $c.1)
            mkdir ($dest | path dirname)
            ^$completions_from completions $c.0 | save -f $dest
        }
    }
    {root: $root, completions: $can}
}

# A binary from `dist` this host can execute, to generate completions with.
def runnable_binary [dir: string]: nothing -> string {
    let host = if $nu.os-info.arch == "aarch64" { "aarch64" } else { "x86_64" }
    if $nu.os-info.name != "linux" { return "" }
    let archive = ($dir | path join $"($APP)-($host)-unknown-linux-musl.tar.gz")
    if not ($archive | path exists) { return "" }
    let d = (mktemp -d)
    ^tar -xzf $archive -C $d
    $d | path join $APP
}

# rpmbuild for the Ubuntu runner (dpkg-deb is already there).
def "main tools" [] {
    let root = (^id -u | str trim) == "0"
    for c in (commands [rpm] $root) { run-external $c.0 ...($c | skip 1) }
}

def "main packages" [version: string, --dir: string = "dist"] {
    let dir = ($dir | path expand)
    let comp = (runnable_binary $dir)
    for t in $LINUX_TARGETS {
        let archive = ($dir | path join $"($APP)-($t).tar.gz")
        if not ($archive | path exists) { print $"skip ($t): no ($archive)"; continue }
        let s = (stage_root $archive $comp)
        let files = (payload $s.completions)

        let deb = (mktemp -d)
        ^chmod 755 $deb
        cp -r ($s.root | path join usr) $deb
        mkdir ($deb | path join DEBIAN)
        deb_control $version $t | save -f ($deb | path join DEBIAN control)
        ^dpkg-deb --root-owner-group --build $deb ($dir | path join (deb_name $version $t))
        rm -rf $deb

        let top = (mktemp -d)
        let spec = ($top | path join $"($APP).spec")
        rpm_spec $version $t $s.root $files | save -f $spec
        # `--target` (not BuildArch, which must match the host) sets the package arch.
        ^rpmbuild -bb --define $"_topdir ($top)" --target $"(rpm_arch $t)-linux" $spec
        cp (glob ($top | path join RPMS "**" "*.rpm") | first) ($dir | path join (rpm_name $version $t))
        rm -rf $top $s.root
        print $"✓ (deb_name $version $t), (rpm_name $version $t)"
    }
}

# Install the host's .deb, then check the binary runs and the completions landed.
def "main verify" [version: string, --dir: string = "dist"] {
    let t = if $nu.os-info.arch == "aarch64" { "aarch64-unknown-linux-musl" } else { "x86_64-unknown-linux-musl" }
    let deb = ($dir | path join (deb_name $version $t))
    ^sudo dpkg -i $deb
    let v = (^nuance --version | str trim)
    if not ($v | str contains $version) { error make {msg: $"installed nuance reports '($v)', expected ($version)"} }
    for f in (payload true) {
        if not (($"/($f)") | path exists) { error make {msg: $"/($f) missing after installing ($deb)"} }
    }
    ^sudo dpkg -r $APP
    print $"✓ ($deb) installs: ($v), completions included"
}

def "main manifests" [version: string, --dir: string = "dist", --out: string = "dist/manifests"] {
    let vars = {
        VERSION: $version
        SHA_MACOS_ARM: (archive_sha $dir aarch64-apple-darwin)
        SHA_MACOS_X86: (archive_sha $dir x86_64-apple-darwin)
        SHA_LINUX_ARM: (archive_sha $dir aarch64-unknown-linux-musl)
        SHA_LINUX_X86: (archive_sha $dir x86_64-unknown-linux-musl)
        SHA_WINDOWS_X86: (archive_sha $dir x86_64-pc-windows-msvc)
        SHA_LICENSE: (open --raw LICENSE | hash sha256)
    }
    mkdir $out
    for o in (outputs) {
        render (open --raw $o.tpl) $vars | save -f ($out | path join $o.out)
    }
    print $"rendered (outputs | length) manifests into ($out) for ($version)"
}

def main [] {
    print "usage: nu scripts/ci/distro.nu (packages|manifests) <version> [--dir dist]"
}
