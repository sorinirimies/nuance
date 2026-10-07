# nuance doctor: check nu version, truecolor, Nerd Font, install and current state.
Output docs/doctor.gif

Set Shell "nu"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 20
Set Width 1200
Set TypingSpeed 55ms
Set Padding 24
Set LineHeight 1.2
Set Height 780

Hide
Type "$env.PROMPT_COMMAND = { || create_left_prompt }"
Enter
Type "$env.PROMPT_USER = 'sorin'"
Enter
Type "$env.PROMPT_HOST = 'nuance'"
Enter
Type "theme-apply nord; $env.PROMPT_STYLE = 'full'"
Enter
Type "clear"
Enter
Sleep 300ms
Show

Sleep 600ms
Type "nuance doctor"
Enter
Sleep 4s
