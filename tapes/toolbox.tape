# The toolbox: preview without applying, your own style, share a look, list what's available.
# Recorded in an isolated HOME, so no real paths or personal state end up in the GIF.
Output docs/toolbox.gif

Set Shell "bash"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 20
Set Width 1200
Set Height 820
Set Padding 24
Set LineHeight 1.2
Set TypingSpeed 50ms

Hide
Type "export HOME=/tmp/nuance-toolbox-home XDG_CONFIG_HOME=/tmp/nuance-toolbox-home/.config && rm -rf $HOME && mkdir -p $HOME"
Enter
Type "export PROMPT_USER=sorin PROMPT_HOST=nuance PS1='> '"
Enter
Type "export PATH=$PWD/target/release:$PATH"
Enter
Type "mkdir -p $HOME/code/nuance && cd $HOME/code/nuance && git init -q -b main && touch Cargo.toml notes.md && git add Cargo.toml"
Enter
Type "nuance theme tokyo-night >/dev/null"
Enter
Type "clear"
Enter
Sleep 300ms
Show

Sleep 600ms
Type "# render any theme + style without applying it"
Enter
Sleep 500ms
Type "nuance preview dracula pastel"
Enter
Sleep 2s
Type "nuance preview catppuccin-mocha spaceship"
Enter
Sleep 2s
Type "# make your own style, then share the look"
Enter
Sleep 500ms
Type "nuance style new mine"
Enter
Sleep 2s
Type "nuance prompt-style mine"
Enter
Sleep 1.5s
Type "nuance export"
Enter
Sleep 2.5s
Type "nuance list modules"
Enter
Sleep 3s
