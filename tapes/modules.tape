# Context modules: exit code, toolchain version, background jobs … only when relevant.
Output docs/modules.gif

Set Shell "nu"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 20
Set Width 1200
Set TypingSpeed 55ms
Set Padding 24
Set LineHeight 1.2
Set Height 760

Hide
Type "$env.PROMPT_COMMAND = { || create_left_prompt }"
Enter
Type "$env.PROMPT_USER = 'sorin'"
Enter
Type "$env.PROMPT_HOST = 'nuance'"
Enter
Type "theme-apply catppuccin-mocha; $env.PROMPT_STYLE = 'capsule'"
Enter
Type "clear"
Enter
Sleep 300ms
Show

Sleep 600ms
Type "nuance modules"
Enter
Sleep 2.4s
Type "nuance modules enable status lang jobs"
Enter
Sleep 1s
Type "# toolchain shows inside a project"
Enter
Sleep 1.2s
Type "^false"
Enter
Sleep 1.4s
Type "# exit code only when a command fails"
Enter
Sleep 1s
Type "cd ~"
Enter
Sleep 1.6s
Type "# gone outside a project"
Enter
Sleep 2s

Hide
Type "nuance modules clear"
Enter
Sleep 500ms
