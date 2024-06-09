############################################ LINUX SETUP ###########################################
# Setup all programs required for the PDE in Linux and install their configs appropriately

##################### GLOBAL VARIABLES #####################

# command-line options
update=false
no_wezterm=false

# relevant directories
program_dir="$HOME/.local/bin"
app_dir="$program_dir/app"

# color terminal escape sequences
c_RED='\033[0;31m'
c_GREEN='\033[0;32m'
c_CYAN='\033[0;36m'
c_NONE='\033[m'

##################### UTILITY FUNCTIONS ####################

# show help message and exit the script
show-help() {
    echo '
Usage: bash setup_linux.sh [-h] [-u] [--no-wezterm]
    -h : show this help message
    -u : update the programs without re-installing the config files (default: OFF)
    --no-wezterm : skip setting up wezterm (default: OFF)'
    exit $1 # exit with specified code
}

# write information
write-info() { echo -en "$c_CYAN$1$c_NONE"; }

# write an error message
write-error() { echo -e "\n$c_RED! ERROR: $1$c_NONE"; }

###################### CORE FUNCTIONS ######################

# downloads and extracts the nightly appimage from the given URL to the programs directory
get-appimage-nightly()
{
    # parameters
    local mini_url="$1"     # mini GitHub URL
    local file="$2"         # AppImage file name
    local sha256="$3"       # AppImage SHA256 file name
    local bin="$4"          # name of symlink binary

    write-info "Installing $mini_url -\n"
    local file_url="https://github.com/$mini_url/releases/download/nightly/$file"
    cd "$program_dir"

    # download appimage file
    write-info " * Downloading appimage from '$file_url' ... "
    curl -L -o "$file" "$file_url" &>/dev/null
    write-info "Done\n"

    # verify the downloaded appimage integrity
    write-info " * Verifying SHA hash from '$file_url.$sha256' ... "
    local file_sha="$(curl -L "$file_url.$sha256" 2>/dev/null)"
    [ "$file_sha" != "$(sha256sum "$file")" ] && {
        write-error "'$mini_url' appimage SHA has did not match. Aborting installation!"
        return 1
    }
    write-info "Done\n"

    # extract and install the appimage binaries
    write-info " * Extracting '$file' and creating an executable symlink '$bin' ... "
    rm -rf "$app_dir/$bin"
    chmod u+x "$file" && "./$file" --appimage-extract &>/dev/null
    mv 'squashfs-root' "$app_dir/$bin"
    rm -f "$file"
    ln -sf "$app_dir/$bin/AppRun" "$bin"
    write-info "Done\n"

    write-info "Done.\n"
    cd - &>/dev/null
    return
}

# installs the configuration to the destination folder
install-config()
{
    [ $? -eq 1 ] && {
        write-info 'Skipping config installation due to error in getting appimage\n'
        return
    }
    [ $update == true ] && return

    # parameters
    local source="$1"
    local destination="$2"

    write-info "Installed config from '$source' to '$destination'\n"
    ln -sf "$source" "$destination"
}

# downloads and extracts an apt package to the programs directory
apt-local-install()
{
    # parameters
    local package="$1"      # APT package name
    local binary="$2"       # package binary name

    write-info "Installing $package ... "
    cd "$program_dir"
    apt download "$package" &>/dev/null
    deb="$(find -type f -name "$package*.deb")"
    dpkg -x "$deb" "$package"
    mv "$package/usr/bin/$binary" .
    rm -rf "$package" "$deb"
    cd - &>/dev/null
    write-info "Done.\n"
}

####################### MAIN PIPELINE ######################

# parse the command-line arguments passed to it and issue relevant messages
parse-arguments() {
    # use getopt to parse arguments and show an error message if invalid arguments are found
    local args="$(getopt --options h,u --longoptions no-wezterm -- "$@" 2>./getopt_error)"
    [ $? -ne 0 ] && error 'Failed to parse command-line arguments'
    local getopt_error_msg="$(cat ./getopt_error && rm ./getopt_error)"
    [ -n "$getopt_error_msg" ] && { write-error "$getopt_error_msg" && show-help 1; }

    # change the relevant globals based on the parsed arguments
    eval "set -- $args"
    for arg in $@; do
        case "$arg" in
            -h) show-help 0 ;;
            -u) update=true ;;
            --no-wezterm) no_wezterm=true ;;
            --) ;;
            *) write-error 'setup_linux.sh does not take any positional arguments' && show-help 1 ;;
        esac
    done
}

# main function that downloads and installs all programs
run-main()
{
    echo -en "${c_GREEN}Executing script for PDE setup on Linux\n\n$c_NONE"

    mkdir -p "$app_dir"

    [ $no_wezterm == false ] && {
        # install WezTerm (nightly) and its config
        get-appimage-nightly 'wez/wezterm' 'WezTerm-nightly-Ubuntu20.04.AppImage' 'sha256' 'wezterm'
        install-config "$PWD/wezterm" "$HOME/.config"
        echo
    }

    # install Neovim (nightly) and its config
    get-appimage-nightly 'neovim/neovim' 'nvim.appimage' 'sha256sum' 'nvim'
    install-config "$PWD/nvim" "$HOME/.config"
    echo

    # install RipGrep locally
    apt-local-install ripgrep rg
    echo

    # install all dotfiles
    install-config "$PWD/dotfiles/.gitconfig" "$HOME"
    [ -z "$BASH_INIT_SOURCED" ] && \
        echo -e "\nsource $PWD/dotfiles/bash/init.sh" | tee -a "$HOME/.bashrc"
    [ $update == false ] && echo

    echo -en "${c_GREEN}Completed PDE Setup\n$c_NONE"
}

parse-arguments $@
run-main
