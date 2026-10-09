# nuance doctor: check nu version, truecolor, Nerd Font, install and current state.
# Recorded in an isolated HOME, so no real paths or personal state end up in the GIF.
Output docs/doctor.gif

Set Shell "bash"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 20
Set Width 1200
Set Height 720
Set Padding 24
Set LineHeight 1.2
Set TypingSpeed 55ms

Hide
Type "export HOME=/tmp/nuance-doctor-home XDG_CONFIG_HOME=/tmp/nuance-doctor-home/.config && rm -rf $HOME && mkdir -p $HOME"
Enter
Type "export PROMPT_USER=sorin PROMPT_HOST=nuance PS1='> '"
Enter
Type "export PATH=$PWD/target/release:$PATH"
Enter
Type "nuance theme nord >/dev/null && nuance prompt-style powerline >/dev/null && nuance modules enable lang >/dev/null"
Enter
Type "clear"
Enter
Sleep 300ms
Show

Sleep 600ms
Type "nuance doctor"
Enter
Sleep 4.5s
