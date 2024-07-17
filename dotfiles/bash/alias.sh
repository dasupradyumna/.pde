########################################### BASH ALIASES ###########################################

# convenience for parent directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# check and synchronize all installed packages
alias apt-sync='sudo apt update && sudo apt upgrade && sudo apt autoremove'

# change back to older directory silently
alias cb='cd ~-'

# update modules in container
dcp-mod() { docker cp "$1" "$2:/home/modules"; }

# quick open neovim
alias e='nvim'

# start jupyter-lab in the background suppressed output
alias jl='jupyter-lab &>/dev/null &'

# list the permissions of a file system object
alias lsmod='stat --printf " object: %n\n perms:  0%a\n"'

# recursively remove directory
alias rmd='rm -rf'

# copy stdin content into clipboard
alias xcp='xclip -selection clipboard'

# create and enter a directory
mkcd() { mkdir -p "$1" && cd "$1"; }

# wezterm set tab title
alias wstt='wezterm cli set-tab-title'

# internal helper for getting git head similar to __git_ps1 output
__git_branch() {
    local branch= head= git_dir="$(git rev-parse --git-dir 2>/dev/null)"
    if [ -L "$git_dir/HEAD" ]; then
        branch="$(git symbolic-ref HEAD 2>/dev/null)"
    elif __git_eread "$git_dir/HEAD" head; then
        branch="${head#ref: }"
        [ "$head" == "$branch" ] && branch="($(git describe --contains --all HEAD))"
    fi

    echo -n "${branch##refs/heads/}"
}

################################## GIT ALIASES #################################
# REMOVE: once lazygit workflow is setup

# commit
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit --amend -v'
alias gcan='git commit --amend --no-edit'
alias gce='git commit --allow-empty -v'

# branch
alias gbc='git switch -c'
alias gbC='git checkout'
alias gbd='git branch -d'
alias gbl='git branch'
alias gblv='git branch -v'
alias gbr='git branch -m'
alias gbs='git switch'

# logs
alias gl='git log'
alias glo='git log --oneline'
alias glog='git log --oneline --graph --all'

# remote
alias gp='git push'
alias gpf='git push -f'
alias gpsu='git push --set-upstream origin'
alias gP='git pull'

# stash
alias gsl='git stash list'
alias gsc='git stash push -m'
alias gsa='git stash apply'
alias gsd='git stash drop'
alias gsp='git stash pop'
alias gss='git stash show'

# working tree
alias gS='git status -sb'
alias gr='git reset --hard HEAD'

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
