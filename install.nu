#!/usr/bin/env nu
# install.nu — link (or copy) the nushell prompt+theme into your autoload dir.
#
#   nu install.nu           # symlink (repo stays the source of truth)
#   nu install.nu --copy    # copy the files instead of symlinking
#
# Works on macOS and Linux. Requires Nushell >= 0.101.

def main [--copy] {
    let repo = $env.FILE_PWD
    let s = ($repo | path join "nushell-prompt.nu")
    let dest = ($nu.user-autoload-dirs | get 0)
    let d = ($dest | path join "nushell-prompt.nu")

    mkdir $dest
    print $"(ansi green_bold)nushell-prompt(ansi reset) → ($dest)"

    if (($d | path exists) or ($d | path type) == "symlink") { rm -f $d }
    if $copy {
        cp $s $d
        print $"  (ansi cyan)copied(ansi reset)  nushell-prompt.nu"
    } else {
        ^ln -s $s $d
        print $"  (ansi cyan)linked(ansi reset)  nushell-prompt.nu -> ($s)"
    }

    print ""
    print $"(ansi green_bold)✓ installed.(ansi reset) Open a new shell, or run: (ansi attr_bold)exec nu(ansi reset)"
    print "Commands: theme · theme-sync · prompt-style"
}
