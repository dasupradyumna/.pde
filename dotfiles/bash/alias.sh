########################################### BASH ALIASES ###########################################

# convenience for parent directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# check and synchronize all installed packages
alias apt-sync='sudo apt update && sudo apt upgrade && sudo apt autoremove'

# change back to older directory silently
alias cb='cd ~-'

# quick open neovim
alias e='nvim'

# start jupyter-lab in the background suppressed output
alias jl='jupyter-lab &>/dev/null &'

# recursively remove directory
alias rmd='rm -rf'

# copy stdin content into clipboard
alias xcp='xclip -selection clipboard'

# create and enter a directory
mkcd() { mkdir -p "$1" && cd "$1"; }

# internal helper for getting git head similar to __git_ps1 output
__git_branch() {
    local branch= head=
    if [ -L '.git/HEAD' ]; then
        branch="$(git symbolic-ref HEAD 2>/dev/null)"
    elif __git_eread '.git/HEAD' head; then
        branch="${head#ref: }"
        [ "$head" == "$branch" ] && branch="($(git describe --contains --all HEAD))"
    fi

    echo -n "${branch##refs/heads/}"
}

############################## PYTHON VENV HELPERS #############################

create-venv() {
    python -m venv "$HOME/.venvs/$1" && echo "Created a python virtual environment \"$1\""
}

list-venv() {
    [ ! -d "$HOME/.venvs" ] && return

    local env_list="$(cd "$HOME/.venvs" && compgen -d "${COMP_WORDS[1]}")"
    echo -e "${env_list/ /\n}"
}

delete-venv() {
    local venv_dir="$HOME/.venvs/$1"
    if [ -z "$1" ]; then
        __render red
        echo 'ERROR: No python virtual environment specified!'
        return 1
    elif [ ! -d "$venv_dir" ]; then
        __render red
        echo "ERROR: Python environment \"$1\" does not exist!"
        return 1
    fi

    # confirmation from user
    local base="Delete the python virtual environment \"$1\"? (y/n) " invalid='Invalid choice! '
    local msg="$base"
    while true; do
        read -p "$msg" choice
        case "$choice" in
            [yY]) break ;;
            [nN]) echo Aborted.; return ;;
            *) [ ${#msg} -eq ${#base} ] && msg="$invalid$base";
                echo -en '\r\x1b[1A\x1b[0K' ;;  # moves cursor to and clears the previous line
        esac
    done

    [ -n "$VIRTUAL_ENV" ] && deactivate
    rm -rf "$venv_dir" && echo Done.
}

activate-venv() {
    local activate_file="$HOME/.venvs/$1/bin/activate"
    if [ -z "$1" ]; then
        __render red
        echo 'ERROR: No python virtual environment specified!'
        return 1
    elif [ ! -f "$activate_file" ]; then
        __render red
        echo "ERROR: Python environment \"$1\" does not exist!"
        return 1
    fi

    source "$activate_file"
}

# completion for above helpers listing existing environments
__venv_helper_completion() {
    COMPREPLY=()
    [ ${#COMP_WORDS[@]} -eq 2 ] && COMPREPLY=($(list-venv))
}
complete -F __venv_helper_completion activate-venv
complete -F __venv_helper_completion delete-venv
