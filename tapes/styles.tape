# Prompt styles: same theme, cycle through the layout styles.
Output docs/styles.gif

Set Shell "nu"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 20
Set Width 1200
Set Height 520
Set Padding 24
Set LineHeight 1.2
Set TypingSpeed 45ms

Hide
Type "$env.PROMPT_COMMAND = { || create_left_prompt }"
Enter
Type "clear"
Enter
Sleep 300ms
Type "theme tokyo-night"
Enter
Sleep 300ms
Type "clear"
Enter
Sleep 300ms
Show

Sleep 800ms
Type "prompt-style full"
Enter
Sleep 1.6s
Type "prompt-style lambda"
Enter
Sleep 1.6s
Type "prompt-style powerline"
Enter
Sleep 1.6s
Type "prompt-style slant"
Enter
Sleep 1.6s
Type "prompt-style capsule"
Enter
Sleep 1.6s
Type "prompt-style boxed"
Enter
Sleep 1.8s
Type "prompt-style bracket"
Enter
Sleep 1.8s
