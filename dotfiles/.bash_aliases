# create and enter a directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# check and synchronize all installed packages
alias apt-sync='sudo apt update && sudo apt upgrade && sudo apt autoremove'

# git
alias g='git'
