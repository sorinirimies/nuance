# Transient prompt: finished prompts collapse to a single ❯ so scrollback stays clean.
Output docs/transient.gif

Set Shell "nu"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 20
Set Width 1200
Set TypingSpeed 55ms
Set Padding 24
Set LineHeight 1.2
Set Height 640

Hide
Type "$env.PROMPT_COMMAND = { || create_left_prompt }"
Enter
Type "$env.PROMPT_USER = 'sorin'"
Enter
Type "$env.PROMPT_HOST = 'nuance'"
Enter
Type "theme-apply tokyo-night; $env.PROMPT_STYLE = 'powerline'"
Enter
Type "clear"
Enter
Sleep 300ms
Show

Sleep 600ms
Type "# old prompts stay full-size…"
Enter
Sleep 500ms
Type "ls src | first 2 | select name size"
Enter
Sleep 1.2s
Type "date now"
Enter
Sleep 1.2s
Type "# …until transient is on"
Enter
Sleep 600ms
Type "nuance transient on"
Enter
Sleep 800ms
Type "ls src | first 2 | select name size"
Enter
Sleep 1.2s
Type "date now"
Enter
Sleep 1.2s
Type "ls src | length"
Enter
Sleep 2s

Hide
Type "nuance transient off"
Enter
Sleep 500ms
