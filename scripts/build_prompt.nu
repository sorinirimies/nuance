#!/usr/bin/env nu
# Build the single drop-in nushell-prompt.nu from the parts in nu/*.nu
# (concatenated in filename order).
#
#   nu scripts/build_prompt.nu           # rewrite nushell-prompt.nu
#   nu scripts/build_prompt.nu --check   # exit 1 if nushell-prompt.nu is stale (used by test.nu)
def main [--check] {
    let root = ($env.FILE_PWD | path dirname)
    let parts = (glob ($root | path join "nu" "*.nu") | sort)
    let out = ($parts | each {|f| open --raw $f } | str join "")
    let target = ($root | path join "nushell-prompt.nu")
    if $check {
        if (open --raw $target) != $out {
            print -e "nushell-prompt.nu is out of date — run: nu scripts/build_prompt.nu  (just build-prompt)"
            exit 1
        }
        return
    }
    $out | save -f $target
    print $"✓ nushell-prompt.nu built from ($parts | length) parts — ($out | lines | length) lines"
}
