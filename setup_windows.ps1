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

# Install RipGrep
winget install BurntSushi.ripgrep.MSVC

# XXX: refactor below code

# Uninstall and reinstall git to use external OpenSSH
#
# This ensures that Git does not ship with internal SSH support and uses the
# SSH binaries configured externally by the PATH environment variable
# If both external and internal SSH binaries exist, git commit signing fails
# since it mixes up the SSH binaries used for signing
# Refer to https://github.com/git-for-windows/git/issues/3647
# and https://github.com/microsoft/winget-cli/discussions/3462
winget uninstall Git.Git
winget install --id=Git.Git --custom '/o:SSHOption=ExternalOpenSSH'
