# nuance configure: guided setup — pick a look, transient prompt, extra segments.
# Runs in an isolated HOME so it never touches your real Nushell config.
Output docs/configure.gif

Set Shell "bash"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 20
Set Width 1200
Set Height 760
Set Padding 24
Set LineHeight 1.2
Set TypingSpeed 60ms

Hide
Type "export HOME=/tmp/nuance-configure-home XDG_CONFIG_HOME=/tmp/nuance-configure-home/.config && rm -rf $HOME && mkdir -p $HOME"
Enter
Type "export PROMPT_USER=sorin PROMPT_HOST=nuance PS1='> '"
Enter
Type "export PATH=$PWD/target/release:$PATH"
Enter
Type "clear"
Enter
Sleep 300ms
Show

Sleep 600ms
Type "nuance configure"
Enter
Sleep 4s
Type "dracula-agn"
Sleep 1.4s
Enter
Sleep 1.5s
Down
Sleep 700ms
Enter
Sleep 1.5s
Space
Sleep 500ms
Down
Sleep 300ms
Down
Sleep 300ms
Down
Sleep 300ms
Down
Sleep 300ms
Down
Sleep 300ms
Down
Sleep 300ms
Space
Sleep 1s
Enter
Sleep 2.5s
