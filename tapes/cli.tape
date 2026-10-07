# nuance-cli: the `cargo install nuance-cli` binary — usable from ANY shell
# (not just Nushell). Shows the install-free flow: set a theme directly,
# then open the ratatui picker with its instant live preview.
Output docs/cli.gif

Set Shell "bash"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 20
Set Width 1200
Set Height 620
Set Padding 24
Set LineHeight 1.2
Set TypingSpeed 55ms

Hide
Type "export HOME=/tmp/nuance-cli-tape-home && rm -rf $HOME && mkdir -p $HOME"
Enter
Type "export PROMPT_USER=sorin PROMPT_HOST=nuance"
Enter
Type "export PATH=$PWD/target/release:$PATH"
Enter
Type "clear"
Enter
Sleep 300ms
Show

Sleep 500ms
Type "nuance theme gruvbox"
Enter
Sleep 1.4s
Type "nuance theme"
Enter
Sleep 3s
Type "tokyo"
Sleep 900ms
Down
Sleep 600ms
Enter
Sleep 1.5s
