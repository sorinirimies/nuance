#!/usr/bin/env nu
# Did any *direct* dependency actually change in Cargo.lock?
#
# Cargo.lock moves almost daily from transitive patch bumps. Those are fine to
# commit but do not warrant a release. A release is only warranted when a crate
# declared in Cargo.toml ([dependencies], [dev-dependencies],
# [build-dependencies]) resolved to a different version.
#
# Prints "true" / "false" on stdout (details go to stderr).
#
# Usage:
#   nu scripts/direct_deps_changed.nu --before <old Cargo.lock> --after Cargo.lock

# Sorted unique versions locked for `name`.
export def versions_of [pkgs: table, name: string]: nothing -> list<string> {
    $pkgs | where name == $name | get version | uniq | sort
}

# Direct deps whose locked version set differs. Pure — unit testable.
export def changed_direct [
    direct: list<string>
    before: table
    after: table
]: nothing -> list<string> {
    $direct | where {|n| (versions_of $before $n) != (versions_of $after $n) }
}

def main [
    --before: string
    --after: string = "Cargo.lock"
    --manifest: string = "Cargo.toml"
] {
    let m = (open $manifest)
    let direct = (["dependencies" "dev-dependencies" "build-dependencies"]
        | each {|k| $m | get -o $k | default {} | columns }
        | flatten | uniq)
    let b = (open --raw $before | from toml | get package | select name version)
    let a = (open --raw $after | from toml | get package | select name version)
    let changed = (changed_direct $direct $b $a)

    if ($changed | is-empty) {
        print -e "No direct dependency changed (transitive-only lock churn)."
        print "false"
    } else {
        print -e $"Direct dependencies changed: ($changed | str join ', ')"
        print "true"
    }
}
