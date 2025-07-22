#!/bin/bash
########################################### UBUNTU SETUP ###########################################
# Setup all programs required for the PDE in Ubuntu and install their configs appropriately

##################### GLOBAL VARIABLES #####################

SYSTEM_INSTALL=false
SKIP_CONFIGS=false
SKIP_THEME=false
UNINSTALL=false
SKIP_WEZTERM=false
INSTALL_DIR=~/.local
GIT_CLONE_PREFIX='git@github.com:'

# Clean up Neovim source directory on exit
set_exit_trap() {
    trap "tput cnorm; rm -rf $INSTALL_DIR/neovim ~/tmp-graphite-theme ~/tmp-tela-icons" EXIT;
}

##################### UTILITY FUNCTIONS ####################

# Show help message and exit the script
show_help() {
    echo '
Usage: ./setup_ubuntu.sh [-hsCTUW]
    -h : Show this help message
    -s : System install (/usr/local); if not set, fallback to user install (~/.local)
    -C : Skip copying configs
    -T : Skip installing theme and icons
    -U : Uninstall all programs and configs; if -s is set, uninstall from /usr/local
    -W : Skip installing wezterm
'
    exit $1 # Exit with specified code
}

# Log a message based on severity
log() {
    local prefix=
    local error_exit=false
    OPTIND=1 # Reset before each getopts call
    while getopts 'Eei' level; do
        case "$level" in
            E) prefix='\n\e[31mERROR'; error_exit=true ;; # Error and exit
            e) prefix='\n\e[31mERROR' ;; # Error
            i) prefix='\e[36mINFO' ;; # Information
        esac
        break
    done
    shift $((OPTIND - 1))

    echo -e "$prefix: $1\e[m"
    if $error_exit; then exit 1; fi
}

# Parse command-line options
parse_opts() {
    # Modify variables based on options
    abspath() { echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"; }
    while getopts ':hsCTUW' option; do
        case "$option" in
            h) show_help 0 ;;
            s) SYSTEM_INSTALL=true; INSTALL_DIR=/usr/local ;;
            C) SKIP_CONFIGS=true ;;
            T) SKIP_THEME=true ;;
            U) UNINSTALL=true ;;
            W) SKIP_WEZTERM=true ;;
            \?) log -e "Invalid command-line option '-$OPTARG'!"; show_help 1 ;;
            :) log -e "Command-line option '-$OPTARG' requires an argument!"; show_help 1 ;;
        esac
    done
    unset -f abspath
    shift $((OPTIND - 1))
    set_exit_trap

    # Raise error in case of any positional arguments
    if [ $# -ne 0 ]; then
        log -e "Positional arguments are not supported! Received: $(printf "'%s' " $@)"
        show_help 1
    fi

    log -i "Parsing command-line options ...
    - SYSTEM_INSTALL: $SYSTEM_INSTALL
    - SKIP_CONFIGS: $SKIP_CONFIGS
    - SKIP_THEME: $SKIP_THEME
    - UNINSTALL: $UNINSTALL
    - SKIP_WEZTERM: $SKIP_WEZTERM"
}

############################ MAIN PROGRAM FUNCTIONS ############################

# Install WezTerm nightly using AppImage
install_wezterm() {
    echo && log -i 'Installing WezTerm ...'
    cd bin

    # Download appimage
    local appimage=WezTerm-nightly-Ubuntu20.04.AppImage
    curl -L -o "$appimage" "https://github.com/wez/wezterm/releases/download/nightly/$appimage" || \
        log -E "Failed to download appimage - $appimage"
    log -i "Downloaded appimage - $appimage"

    # Extract appimage
    chmod u+x "$appimage" && "./$appimage" --appimage-extract 1>/dev/null || \
        log -E "Failed to extract appimage - $appimage"
    rm -rf "$appimage" .wezterm_appimage
    mv squashfs-root .wezterm_appimage
    log -i "Extracted appimage to '.wezterm_appimage' folder"

    # Create symlink to appimage binary
    ln -sf "$PWD/.wezterm_appimage/usr/bin/wezterm" wezterm || log -E 'Failed to create symlink'
    log -i "Created symlink: $PWD/wezterm -> $PWD/.wezterm_appimage/usr/bin/wezterm"

    cd ..
}

# Install APT package - system or local
apt_install() {
    local pkg="$1" binary="$2"

    # System installation
    if $SYSTEM_INSTALL; then
        sudo apt-get install -y "$pkg" &>/dev/null || log -E "Failed to install $pkg to system"
        log -i "Installed APT package $pkg to system"
        return
    fi

    # Local installation
    apt download "$pkg" &>/dev/null || log -E "Failed to download $pkg APT package"
    local deb_file="$(find -type f -name "$pkg*.deb")"
    dpkg -x "$deb_file" "$pkg" || log -E "Failed to extract $pkg APT package"
    mv "$pkg/usr/bin/$binary" bin
    rm -rf "$pkg" "$deb_file"
    log -i "installed APT package $pkg to '$PWD/bin'"
}

# Install Neovim nightly from source
install_neovim() {
    echo && log -i 'Installing Neovim ...'

    # Ensure Neovim dependencies are installed
    apt_install ripgrep rg
    apt_install xclip xclip

    # Clone Neovim repository
    git clone --depth 1 "${GIT_CLONE_PREFIX}neovim/neovim"
    log -i 'Cloned Neovim repository from GitHub'
    cd neovim

    # Build and install Neovim (nightly) from source
    tput sc
    {
        make -j8 CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX="$INSTALL_DIR" 2>&1 || \
            log -E 'Failed to build Neovim'

        if $SYSTEM_INSTALL; then sudo make install; else make install; fi || \
            log -E 'Failed to install Neovim'
    } | while IFS= read -r line; do
            local buffer=("${buffer[@]}" "$line")
            [ ${#buffer[@]} -gt 10 ] && buffer=("${buffer[@]:1}")
            # Below same as 'tput rc; tput ed'; `tput el` not needed because of newline
            echo -e '\e[u\e[J'
            for l in "${buffer[@]}"; do echo -e "\e[90m$l\e[m"; done
            sleep 0.25
        done || { echo && log -E 'Build-and-install process interrupted'; }
    [ "${PIPESTATUS[0]}" -ne 0 ] && exit 1 # Exit if first command failed (pipe runs in subshell)
    tput rc; tput ed
    log -i "Successfully built Neovim (nightly) from source and installed to '$INSTALL_DIR'"

    cd ..
}

# Copy a config file to its standard location via symlink
copy_configs() {
    local src="$1" dst="$2"
    if $SKIP_CONFIGS; then log -i "Skipped copying: $src" && return; fi

    ln -sf "$src" "$dst"
    log -i "Copied config via symlink: $src -> $dst"
}

# Install Graphite theme and Tela icons
# CHECK: this function has not been tested and verified
install_theme() {
    if $SKIP_THEME; then echo && log -i 'Skipping theme and icons installation' && return; fi

    echo && log -i 'Installing GTK theme and icons ...'
    cd # Clone repositories to HOME temporarily

    # Clone Graphite theme
    git clone --depth 1 "${GIT_CLONE_PREFIX}vinceliuice/Graphite-gtk-theme" tmp-graphite-theme
    cd tmp-graphite-theme
    ./install.sh --color dark --size compact --libadwaita --tweaks black rimless normal
    # BUG: weird behavior ; check https://github.com/vinceliuice/Graphite-gtk-theme/issues/197
    # sudo ./install.sh --color dark --gdm --tweaks black rimless normal
    cd ..
    log -i 'Installed Graphite theme to ~/.themes & its GTK4 assets to ~/.config/gtk-4.0'

    # Clone Tela icons
    git clone --depth 1 "${GIT_CLONE_PREFIX}vinceliuice/Tela-circle-icon-theme" tmp-tela-icons
    cd tmp-tela-icons
    ./install.sh -c black
    cd ..
    log -i 'Installed Tela circle icons to ~/.local/share/icons'

    log -i 'NOTE: Follow below steps to apply theme and icons:
    1. $ sudo apt install gnome-tweaks gnome-shell-extensions chrome-gnome-shell
    2. Visit "https://extensions.gnome.org/extension/19/user-themes" in web browser
    3. Install GNOME Shell integration browser extension and enable "User Themes" extension
    4. Open GNOME Tweaks and set theme and icons under Appearance section
    5. Reboot to apply changes to the system'
    cd ..
}

# Main install function
install_pde() {
    local start=$(date +%s)

    # Ensure relevant directories exist
    mkdir -p "$INSTALL_DIR/bin" ~/.config ~/.ssh

    # Check if Git is accessible
    if ! ssh -T git@github.com 2>&1 | grep -q 'successfully authenticated'; then
        echo && log -i 'Failed to connect to GitHub via SSH ; Falling back to HTTPS'
        GIT_CLONE_PREFIX='https://github.com/'
    fi

    # Install programs
    local pde_dir="$PWD"
    pushd "$INSTALL_DIR" 1>/dev/null
    if ! $SKIP_WEZTERM; then install_wezterm; copy_configs "$pde_dir/wezterm" ~/.config; fi
    install_neovim; copy_configs "$pde_dir/nvim" ~/.config
    popd 1>/dev/null

    # Install dotfiles
    echo && log -i 'Installing dotfiles ...'
    copy_configs "$PWD/dotfiles/.gitconfig" ~
    copy_configs "$PWD/dotfiles/ssh_config" ~/.ssh/config
    [ -z "$BASH_INIT_SOURCED" ] && \
        echo -e "\nsource $PWD/dotfiles/bash/init.sh" | tee -a ~/.bashrc 1>/dev/null

    # Install theme and icons
    install_theme

    local end=$(date +%s)
    local elapsed="$(date --utc --date "@$((end - start))" +%H:%M:%S)"
    echo && log -i "PDE Setup time: $elapsed"
}

# Main uninstall function
uninstall_pde() {
    # Remove programs
    cd "$INSTALL_DIR"
    rm -rf bin/wezterm bin/.wezterm_appimage ~/.config/wezterm
    rm -rf bin/nvim share/nvim/runtime ~/.config/nvim bin/rg bin/xclip
    cd ~-
    echo && log -i 'Removed all installed PDE programs'

    # Remove dotfiles
    rm -f ~/.gitconfig ~/.ssh/config
    log -i 'Removed all installed dotfiles'

    # Remove theme and icons
    rm -rf ~/.themes/Graphite-Dark-Compact* ~/.local/share/icons/Tela-circle-black*
    rm -rf ~/.config/gtk-4.0/assets ~/.config/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk-dark.css
    log -i 'Removed installed theme and icons'

    log -i "NOTE: Please remove the following line manually from '~/.bashrc' -
        > source $PWD/dotfiles/bash/init.sh"

    echo && log -i 'Uninstalled PDE'
}

set -e
parse_opts $@
tput civis
$UNINSTALL && uninstall_pde || install_pde
tput cnorm
