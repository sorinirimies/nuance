# Full-screen terminal theme: background, foreground, cursor and ANSI colors follow the theme.
Output docs/terminal.gif

Set Shell "nu"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 20
Set Width 1200
Set TypingSpeed 55ms
Set Padding 12
Set LineHeight 1.2
Set Height 640

Hide
Type "$env.PROMPT_COMMAND = { || create_left_prompt }"
Enter
Type "$env.PROMPT_USER = 'sorin'"
Enter
Type "$env.PROMPT_HOST = 'nuance'"
Enter
Type "theme-apply nord; $env.PROMPT_STYLE = 'powerline'"
Enter
Type "clear"
Enter
Sleep 300ms
Show

Sleep 600ms
Type "# by default only the prompt is themed…"
Enter
Sleep 800ms
Type "nuance terminal full"
Enter
Sleep 1.2s
Type "# …now the whole screen follows the theme"
Enter
Sleep 600ms
Type "ls src | select name size"
Enter
Sleep 1.2s
Type "nuance theme dracula"
Enter
Sleep 2.2s
Type "nuance theme catppuccin-latte"
Enter
Sleep 2.8s
Type "nuance theme gruvbox"
Enter
Sleep 2.2s
Type "nuance theme tokyo-night"
Enter
Sleep 2.2s
Type "nuance terminal off"
Enter
Sleep 2.5s

Hide
Type "nuance terminal off"
Enter
Sleep 500ms
