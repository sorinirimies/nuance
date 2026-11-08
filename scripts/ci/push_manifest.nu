#!/usr/bin/env nu
# ──────────────────────────────────────────────────────────────────────────────
# nuance — Push a rendered manifest to a package-manager repo
# ──────────────────────────────────────────────────────────────────────────────
# Commits <file> as <dest> in github.com/<repo> (the Homebrew tap or the Scoop
# bucket). Needs $env.TAP_GITHUB_TOKEN (a token with contents:write on <repo>);
# without it the push is skipped with a warning so the release still succeeds.
#
# Usage: nu scripts/ci/push_manifest.nu <repo> <file> <dest> <version>
# ──────────────────────────────────────────────────────────────────────────────

export def remote_url [repo: string, token: string]: nothing -> string {
    $"https://x-access-token:($token)@github.com/($repo).git"
}

export def commit_message [dest: string, version: string]: nothing -> string {
    $"($dest | path basename | str replace --regex '\.(rb|json)$' ''): update to ($version)"
}

def main [repo: string, file: string, dest: string, version: string] {
    let token = ($env.TAP_GITHUB_TOKEN? | default "")
    if $token == "" {
        print $"::warning::TAP_GITHUB_TOKEN is not set — skipped pushing ($dest) to ($repo)"
        return
    }
    let src = ($file | path expand)
    let work = (mktemp -d)
    ^git clone --depth 1 (remote_url $repo $token) $work
    cd $work
    mkdir ($dest | path dirname)
    cp $src $dest
    ^git add $dest
    if (^git status --porcelain | str trim | is-empty) {
        print $"($repo): ($dest) already at ($version)"
        return
    }
    ^git -c user.name=nuance-release -c user.email=nuance-release@users.noreply.github.com commit -m (commit_message $dest $version)
    ^git push origin HEAD
    print $"✓ pushed ($dest) to ($repo)"
}
