# Install WezTerm
winget install wez.wezterm

# Create a symbolic link for WezTerm configuration
New-Item -Force -ItemType SymbolicLink `
    -Path "$env:USERPROFILE\.wezterm.lua" `
    -Target "$PWD\dotfiles\.wezterm.lua"
