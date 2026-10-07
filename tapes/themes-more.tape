# More themes: the newer additions (tokyo-night variants, nightfox, flexoki, …), with recolored tables.
Output docs/themes-more.gif

Set Shell "nu"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 20
Set Width 1200
Set Height 640
Set Padding 24
Set LineHeight 1.2
Set TypingSpeed 40ms

Hide
Type "$env.PROMPT_COMMAND = { || create_left_prompt }"
Enter
Type "$env.PROMPT_USER = 'sorin'"
Enter
Type "$env.PROMPT_HOST = 'nuance'"
Enter
Type "prompt-style compact"
Enter
Type "clear"
Enter
Sleep 300ms
Show

Sleep 700ms
Type "theme tokyo-night-storm"
Enter
Sleep 450ms
Type "ls | first 3 | select name size modified"
Enter
Sleep 1.6s
Type "theme nightfox"
Enter
Sleep 450ms
Type "ls | first 3 | select name size modified"
Enter
Sleep 1.6s
Type "theme kanagawa-dragon"
Enter
Sleep 450ms
Type "ls | first 3 | select name size modified"
Enter
Sleep 1.6s
Type "theme flexoki"
Enter
Sleep 450ms
Type "ls | first 3 | select name size modified"
Enter
Sleep 1.6s
Type "theme material-palenight"
Enter
Sleep 450ms
Type "ls | first 3 | select name size modified"
Enter
Sleep 1.6s
Type "theme synthwave-84"
Enter
Sleep 450ms
Type "ls | first 3 | select name size modified"
Enter
Sleep 1.6s
Type "theme horizon"
Enter
Sleep 450ms
Type "ls | first 3 | select name size modified"
Enter
Sleep 1.6s
Type "theme iceberg"
Enter
Sleep 450ms
Type "ls | first 3 | select name size modified"
Enter
Sleep 2s
