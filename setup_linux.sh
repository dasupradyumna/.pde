################################# WINDOWS SETUP ################################
# Install all necessary programs and tools required for the PDE and copy the
# configs to the appropriate system directories

# flag to update or full install
[ $# -eq 1 ] && update=true || update=false
# programs directory
program_dir="$PWD/programs"
# color escape sequences
c_red='\033[0;31m'
c_green='\033[0;32m'
c_cyan='\033[0;36m'
c_none='\033[m'

# writes information to stdout in cyan color
write-info() { echo -en "$c_cyan$1$c_none"; }

# creates programs directory and adds it to $PATH (if needed)
prepare-program-dir()
{
    mkdir -p "$program_dir"

    # do not add $program_dir to PATH if it is already present
    for p in ${PATH//:/ }; do [ "$p" == "$program_dir" ] && return; done

    write-info "Added '$program_dir' to \$PATH. Re-login for changes to take effect.\n\n"
    export_cmd="export PATH=$program_dir:\$PATH"
    # eval "$export_cmd" # FIX: will only work if sourced in a bash (not zsh) environment
    (echo "$export_cmd" | tee -a ~/.profile) &>/dev/null
}

# downloads the nightly appimage from the given URL to the programs directory
get-appimage-nightly()
{
    mini_url="$1"; file="$2"; sha256="$3"; bin="$4"

    write-info "Installing $mini_url -\n"
    file_url="https://github.com/$mini_url/releases/download/nightly/$file"
    cd "$program_dir"

    write-info " * Downloading appimage from '$file_url' ... "
    curl -L -o "$file" "$file_url" &>/dev/null
    write-info "Done\n"

    write-info " * Verifying SHA hash from '$file_url.$sha256' ... "
    file_sha="$(curl -L "$file_url.$sha256" 2>/dev/null)"
    [ "$file_sha" != "$(sha256sum "$file")" ] && {
        echo -e "\n${c_red}   ERROR: '$mini_url' appimage SHA hash did not match. " \
            "Aborting installation!$c_none"
        return 1
    }
    write-info "Done\n"

    write-info " * Creating symlink '$bin' for '$file' and making it executable ... "
    ln -sf "$PWD/$file" "./$bin"
    chmod u+x "./$bin"
    write-info "Done\n"

    write-info "Done.\n"
    cd ..
    return
}

# installs the configuration to the destination folder
install-config()
{
    [ $? -eq 1 ] && {
        write-info "Skipping config installation due to error in getting appimage.\n"
        return
    }
    [ $update == true ] && return

    source="$1"; destination="$2"
    write-info "Installing config from '$source' to '$destination'\n"
    ln -sf "$source" "$destination"
}

run-main()
{
    echo -en "${c_green}Executing script for PDE setup on Linux\n\n$c_none"

    prepare-program-dir

    # Install WezTerm (nightly) and its config
    get-appimage-nightly 'wez/wezterm' 'WezTerm-nightly-Ubuntu20.04.AppImage' 'sha256' 'wezterm'
    install-config "$PWD/wezterm" ~/.config
    write-info "\n"

    # Install Neovim (nightly) and its config
    get-appimage-nightly 'neovim/neovim' 'nvim.appimage' 'sha256sum' 'nvim'
    install-config "$PWD/nvim" ~/.config
    write-info "\n"

    # Install all dotfiles
    install-config "$PWD/dotfiles/.gitconfig" ~
    install-config "$PWD/dotfiles/.bash_aliases" ~
    write-info "\n"

    # Install RipGrep
    write-info "Checking for RipGrep updates -\n"
    sudo apt install -y ripgrep
    write-info "Done.\n\n"

    echo -en "${c_green}Completed PDE Setup\n$c_none"
}

run-main
