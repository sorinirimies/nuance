# Themes: cycle color themes, showing syntax + table recoloring.
Output docs/themes.gif

Set Shell "nu"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 20
Set Width 1200
Set Height 600
Set Padding 24
Set LineHeight 1.2
Set TypingSpeed 45ms

Hide
Type "$env.PROMPT_COMMAND = { || create_left_prompt }"
Enter
Type "clear"
Enter
Sleep 300ms
Type "prompt-style compact"
Enter
Sleep 300ms
Type "clear"
Enter
Sleep 300ms
Show

Sleep 800ms
Type "theme gruvbox"
Enter
Type "ls | first 4 | select name size modified"
Enter
Sleep 2s
Type "theme catppuccin-mocha"
Enter
Type "ls | first 4 | select name size modified"
Enter
Sleep 2s
Type "theme dracula"
Enter
Type "ls | first 4 | select name size modified"
Enter
Sleep 2s
Type "theme nord"
Enter
Type "ls | first 4 | select name size modified"
Enter
Sleep 2s
Type "theme cyberpunk"
Enter
Type "ls | first 4 | select name size modified"
Enter
Sleep 2.2s
