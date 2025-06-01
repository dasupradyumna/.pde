#!/bin/bash
############################################ LINUX SETUP ###########################################
# Setup all programs required for the PDE in Linux and install their configs appropriately

##################### GLOBAL VARIABLES #####################

# Command-line options
UPDATE=false
PROGRAM_DIR="$HOME/.local/bin"
SKIP_WEZTERM=false
UNINSTALL=false

##################### UTILITY FUNCTIONS ####################

# Show help message and exit the script
show_help() {
    echo '
Usage: bash setup_linux.sh [-h] [-u] [-d] [--skip-wez] [--uninstall]
    -h : show this help message
    -u : update the programs without re-installing the config files (default: OFF)
    -d : program directory to install binaries (default: ~/.local/bin)
    --skip-wez : skip setting up wezterm (default: OFF)
    --uninstall : undo the filesystem changes made during setup'
    exit $1 # Exit with specified code
}

# Write information
write_info() { echo -en "\e[36m$1\e[m"; }

# Write an error message
write_error() { echo -e "\n\e[31m! ERROR: $1\e[m"; }

###################### CORE FUNCTIONS ######################

# Downloads and extracts the nightly appimage from the given URL to the programs directory
get_appimage_nightly() {
    local mini_url="$1"     # Mini GitHub URL
    local file="$2"         # AppImage file name
    local bin="$3"          # Name of symlink binary

    write_info "Installing $mini_url -\n"
    local file_url="https://github.com/$mini_url/releases/download/nightly/$file"
    cd "$PROGRAM_DIR"

    # Download appimage file
    write_info " * Downloading appimage from '$file_url' ... "
    curl -L -o "$file" "$file_url" &>/dev/null
    write_info 'Done\n'

    # Extract and install the appimage binaries
    write_info " * Extracting '$file' and creating an executable symlink '$bin' ... "
    rm -rf "$APP_DIR/$bin"
    chmod u+x "$file" && "./$file" --appimage-extract &>/dev/null
    mv 'squashfs-root' "$APP_DIR/$bin"
    rm -f "$file"
    ln -sf "$APP_DIR/$bin/usr/bin/$bin" "$bin"
    write_info 'Done\n'

    write_info 'Done.\n'
    cd - &>/dev/null
    return
}

# Downloads and extracts an apt package to the programs directory
apt_local_install() {
    local package="$1"      # APT package name
    local binary="$2"       # Package binary name

    write_info "Installing $package ... "
    cd "$PROGRAM_DIR"
    apt download "$package" &>/dev/null
    deb="$(find -type f -name "$package*.deb")"
    dpkg -x "$deb" "$package"
    mv "$package/usr/bin/$binary" .
    rm -rf "$package" "$deb"
    cd - &>/dev/null
    write_info 'Done.\n'
}

# Installs the configuration to the destination folder
install_config() {
    if [ $? -eq 1 ]; then
        write_info 'Skipping config installation due to error in getting appimage\n'
        return
    fi
    $UPDATE && return

    local source="$1"
    local destination="$2"

    write_info "Installed config from '$source' to '$destination'\n"
    ln -sf "$source" "$destination"
}

####################### MAIN PIPELINE ######################

# Parse the command-line arguments passed to it and issue relevant messages
parse_arguments() {
    # Use getopt to parse arguments and show an error message if invalid arguments are found
    local args="$(getopt -o hud: -l skip-wez,uninstall -- "$@" 2>./getopt_error)"
    [ $? -ne 0 ] && error 'Failed to parse command-line arguments'
    local getopt_error_msg="$(cat ./getopt_error && rm ./getopt_error)"
    [ -n "$getopt_error_msg" ] && { write_error "$getopt_error_msg" && show_help 1; }

    # Change the relevant globals based on the parsed arguments
    eval "set -- $args"
    while [ -n "$1" ]; do
        case "$1" in
            '-h') show_help 0 ;;
            '-u') UPDATE=true ;;
            '-d') PROGRAM_DIR="$2"; APP_DIR="$PROGRAM_DIR/appimages"; shift ;;
            '--skip-wez') SKIP_WEZTERM=true ;;
            '--uninstall') UNINSTALL=true ;;
            '--') ;;
            *) write_error 'setup_linux.sh does not take any positional arguments' && show_help 1 ;;
        esac
        shift
    done
}

# Main function that downloads and installs all programs
install_pde() {
    echo -en "\e[32mExecuting script for PDE setup on Linux\n\n\e[m"

    mkdir -p "$APP_DIR" "$HOME/.config" "$HOME/.ssh"

    if ! $SKIP_WEZTERM; then
        # Install WezTerm (nightly) and its config
        get_appimage_nightly 'wez/wezterm' 'WezTerm-nightly-Ubuntu20.04.AppImage' 'wezterm'
        install_config "$PWD/wezterm" "$HOME/.config"
        echo
    fi

    # Install Neovim (nightly) and its config
    get_appimage_nightly 'neovim/neovim' 'nvim-linux-x86_64.appimage' 'nvim'
    install_config "$PWD/nvim" "$HOME/.config"
    echo

    # Install RipGrep locally
    apt_local_install ripgrep rg
    echo

    # Install all dotfiles
    install_config "$PWD/dotfiles/.gitconfig" "$HOME"
    install_config "$PWD/dotfiles/ssh_config" "$HOME/.ssh/config"
    [ -z "$BASH_INIT_SOURCED" ] && \
        (echo -e "\nsource $PWD/dotfiles/bash/init.sh" | tee -a "$HOME/.bashrc") >/dev/null
    ! $UPDATE && echo

    echo -en "\e[32mCompleted PDE Setup\n\e[m"
}

uninstall_pde() {
    echo -en "\e[32mExecuting script to uninstall PDE on Linux\n\n\e[m"

    write_info "Removing programs from '$PROGRAM_DIR' and their configs from '$HOME/.config' ... "
    rm -rf "$APP_DIR" "$PROGRAM_DIR/nvim" "$HOME/.config/nvim" "$PROGRAM_DIR/rg"
    [ -L "$PROGRAM_DIR/wezterm" ] && rm -rf "$PROGRAM_DIR/wezterm" "$HOME/.config/wezterm"
    write_info 'Done.\n'

    write_info 'Removing installed dotfiles ... '
    rm -f "$HOME/.gitconfig" "$HOME/.ssh/config"
    write_info 'Done.\n'

    write_info "NOTE: Please remove the following line manually from '$HOME/.bashrc' -
        > source $PWD/dotfiles/bash/init.sh\n\n"

    echo -en "\e[32mUninstalled PDE\n\e[m"
}

parse_arguments $@
$UNINSTALL && uninstall_pde || install_pde
