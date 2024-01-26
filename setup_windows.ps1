# Install WezTerm and its config
winget install wez.wezterm
New-Item -Force -ItemType SymbolicLink `
    -Path "$env:USERPROFILE\.config\wezterm" `
    -Target "$PWD\wezterm"

# Install Neovim (nightly) and its config
# TODO: installation logic
New-Item -Force -ItemType SymbolicLink `
    -Path "$env:LOCALAPPDATA\nvim" `
    -Target "$PWD\nvim"

# Install all dotfiles
New-Item -Force -ItemType SymbolicLink `
    -Path "$env:USERPROFILE\.gitconfig" `
    -Target "$PWD\dotfiles\.gitconfig"
