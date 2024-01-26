# Install WezTerm
winget install wez.wezterm

# Create a symbolic link for WezTerm configuration
New-Item -Force -ItemType SymbolicLink `
    -Path "$env:USERPROFILE\.config\wezterm" `
    -Target "$PWD\wezterm"

# Install all dotfiles
New-Item -Force -ItemType SymbolicLink `
    -Path "$env:USERPROFILE\.gitconfig" `
    -Target "$PWD\dotfiles\.gitconfig"
