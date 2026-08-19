#!/usr/bin/env nu
# scripts/install.nu — cross-platform deploy for nuance.
# Pure Nushell; works anywhere Nushell runs (macOS / Linux / Windows / WSL).
#
# From a clone:
#   nu scripts/install.nu            # symlink (repo stays the source of truth)
#   nu scripts/install.nu --copy     # copy instead of symlinking
#
# One-liners (no clone needed — downloads to a real temp file first, then
# runs it as a script, so $env.FILE_PWD resolves and the git-clone fallback
# below works correctly):
#   curl -fsSL https://raw.githubusercontent.com/sorinirimies/nuance/main/scripts/install.nu -o /tmp/nuance-install.nu && nu /tmp/nuance-install.nu
#   wget -qO /tmp/nuance-install.nu https://raw.githubusercontent.com/sorinirimies/nuance/main/scripts/install.nu && nu /tmp/nuance-install.nu
#   nu -c 'http get https://raw.githubusercontent.com/sorinirimies/nuance/main/scripts/install.nu | save -f /tmp/nuance-install.nu; nu /tmp/nuance-install.nu'

const REPO_URL = "https://github.com/sorinirimies/nuance.git"
const FILE = "nushell-prompt.nu"

# Find the repo root: this script lives in scripts/, the prompt file lives
# one level up. If that's missing (e.g. run standalone, fetched via the
# one-liner into /tmp), clone the repo instead.
def resolve-root []: nothing -> string {
    let here = ($env.FILE_PWD? | default "" | path dirname)
    if (($here | is-not-empty) and (($here | path join $FILE) | path exists)) { return $here }
    let cache = ($env.XDG_CACHE_HOME? | default ($env.HOME | path join ".cache") | path join "nuance")
    print $"(ansi cyan)fetching(ansi reset) ($REPO_URL) ..."
    rm -rf $cache
    # Skip LFS media (the demo GIFs) — install only needs the code, and this
    # turns a ~1.5 min clone into ~1 s.
    with-env { GIT_LFS_SKIP_SMUDGE: "1" } { ^git clone --depth 1 $REPO_URL $cache }
    $cache
}

def main [--copy] {
    let root = (resolve-root)
    let src = ($root | path join $FILE)
    let dest = ($nu.user-autoload-dirs | get 0)
    let target = ($dest | path join $FILE)

    mkdir $dest
    print $"(ansi green_bold)nuance(ansi reset) → ($dest)"

    if (($target | path exists) or (($target | path type) == "symlink")) { rm -f $target }
    if $copy {
        cp $src $target
        print $"  (ansi cyan)copied(ansi reset)  ($FILE)"
    } else {
        ^ln -s $src $target
        print $"  (ansi cyan)linked(ansi reset)  ($FILE) -> ($src)"
    }

    print ""
    print $"(ansi green_bold)✓ installed.(ansi reset) Open a new shell, or run: (ansi attr_bold)exec nu(ansi reset)"
    print "Try:  theme cyberpunk   ·   prompt-style cyberpunk   ·   nuance update"
    print "Want `theme`/`prompt-style`/`look` from bash/zsh/fish too? cargo install nuance-cli"
}
