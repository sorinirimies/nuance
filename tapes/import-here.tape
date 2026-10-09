# Import any terminal theme, then pin a different look to one directory tree.
Output docs/import-here.gif

Set Shell "nu"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 20
Set Width 1200
Set TypingSpeed 55ms
Set Padding 24
Set LineHeight 1.2
Set Height 820

Hide
Type "$env.PROMPT_COMMAND = { || create_left_prompt }"
Enter
Type "$env.PROMPT_USER = 'sorin'"
Enter
Type "$env.PROMPT_HOST = 'nuance'"
Enter
Type "$env.NUANCE_THEMES_DIR = (mktemp -d)"
Enter
Type "$env.PROMPT_STYLE = 'compact'; mkdir /tmp/nuance-prod; clear"
Enter
Sleep 300ms
Show

Sleep 600ms
Type "# import a Ghostty/kitty/alacritty theme"
Enter
Sleep 600ms
Type "nuance import 'Everforest Dark Hard' --name ef-hard"
Enter
Sleep 1.4s
Type "nuance theme ef-hard"
Enter
Sleep 1s
Type "ls src | first 3 | select name size"
Enter
Sleep 1.8s
Type "# pin a look to one directory tree"
Enter
Sleep 600ms
Type "cd /tmp/nuance-prod"
Enter
Sleep 600ms
Type "nuance here gruvbox cyberpunk"
Enter
Sleep 1.8s
Type "cd .."
Enter
Sleep 1.4s
Type "# leave it and the old look is back"
Enter
Sleep 2s

Hide
Type "'auto' | save -f (theme-state-path); rm -rf /tmp/nuance-prod"
Enter
Sleep 1s
