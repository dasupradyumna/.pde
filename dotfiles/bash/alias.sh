########################################### BASH ALIASES ###########################################

# check and synchronize all installed packages
alias apt-sync='sudo apt update && sudo apt upgrade && sudo apt autoremove'

# directory stack helpers
alias dls='dirs -v'
alias dcd='pushd 1>/dev/null'
alias drm='popd 1>/dev/null'
alias dcn='pushd +1 1>/dev/null'
alias dcp='pushd -0 1>/dev/null'

# interactive bash in container
dex() {
    local container="$1" cmd
    if [ -z "$container" ] || [ $# -gt 2 ]; then
        echo -e '\e[31mUsage: dex <container_name> [command]\e[0m' && return 1
    fi
    [ $# -eq 1 ] && cmd=() || cmd=('-c' "$2")

    [ -z "$(docker ps -q -f name="$container")" ] && docker start "$container" &>/dev/null
    docker exec -it "$container" bash "${cmd[@]}"
}
__dex_complete() {
    local containers="$(docker ps -a --format '{{.Names}}')"
    COMPREPLY=()
    [ $COMP_CWORD -eq 1 ] && COMPREPLY=($(compgen -W "$containers" "${COMP_WORDS[1]}"))
}
complete -F __dex_complete dex

# quick open neovim
alias e='nvim'

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

################################ VIMAAN-HELPERS ################################

s() {
    server_name="$1"
    role="${2:-mtr}"

    vssh -role="$role" -server_name="$server_name"
}
declare -a __server_list=(
    "1blr3-dev-sn1"
    "1sjc5-dev-sn5"
    "25lan5-prod-sn1"
)
complete -W "${__server_list[*]}" s

mdh() {
    local cred usage='Usage: mdh LOCATION MODE [SRC] [DST]
    LOCATION : ( blr:XXX | sjc:XXX | ops ) - XXX is last octet of IP address
    MODE : ( ssh | scp ) - Specify SRC and DST only in "scp" mode
                         - Prefix SRC or DST with "mdh:" to indicate MDH path'

    case "$1" in
        blr:*|sjc:*)
            local user='vimaan-comp' octet="${1#*:}"
            if [ -z "$octet" ]; then
                echo -e "\e[31mBLR/SJC MDH IP octet missing!\n$usage\e[0m" && return 1
            fi
            [ "${1%%:*}" == 'blr' ] && cred="$user@10.72.99.$octet" || cred="$user@172.20.2.$octet"
            ;;
        ops) cred='daniel@172.20.4.118' ;;
        *) echo -e "\e[31mInvalid MDH location!\n$usage\e[0m" && return 1 ;;
    esac

    case "$2" in
        ssh) sshpass -p 'svdrone17' ssh "$cred" ;;
        # TODO: add support for remote-remote transfer
        scp) local src="$3" dst="$4"
            if [ -z "$src" ] || [ -z "$dst" ]; then
                echo -e "\e[31mMissing SCP src/dst paths!\n$usage\e[0m" && return 1
            fi
            [ "${src:0:4}" == 'MDH:' ] && src="$cred:${src:4}"
            [ "${dst:0:4}" == 'MDH:' ] && dst="$cred:${dst:4}"
            # TODO: how to display progress bar? scp disables it if not writing to terminal
            sshpass -p 'svdrone17' scp -r -v "$src" "$dst" 2>&1 | \
                grep -vE '^OpenSSH|^Auth|debug1|^Sink|^Bytes' ;;
        *) echo -e "\e[31mInvalid mode!\n$usage\e[0m" && return 1 ;;
    esac
}
__mdh_complete() {
    COMPREPLY=()
    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=($(compgen -W 'blr: sjc: ops' "${COMP_WORDS[1]}"))
        compopt -o nospace
    elif [ "${COMP_WORDS[1]}" == 'ops' ] && [ $COMP_CWORD -eq 2 ]; then
        COMPREPLY=($(compgen -W 'ssh scp' "${COMP_WORDS[2]}"))
    elif [ "${COMP_WORDS[1]}" != 'ops' ] && [ $COMP_CWORD -eq 4 ]; then
        COMPREPLY=($(compgen -W 'ssh scp' "${COMP_WORDS[4]}"))
    else
        COMPREPLY=($(compgen -f "${COMP_WORDS[$COMP_CWORD]}"))
    fi
}
complete -F __mdh_complete mdh

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
    if [ -z "$1" ]; then
        __render red
        echo 'ERROR: No python virtual environment specified!'
        return 1
    elif [ -d "$HOME/.venvs/$1" ]; then
        __render red
        echo "ERROR: Cannot create python virtual environment \"$1\" ; it already exists!"
        return 1
    fi

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
        echo "ERROR: Python virtual environment \"$1\" does not exist!"
        return 1
    fi

    # confirmation from user
    if ! __user_continue "Delete the python virtual environment \"$1\"?"; then return; fi

    [ "$VIRTUAL_ENV" == "$venv_dir" ] && deactivate
    rm -r "$venv_dir" || return 1
}

activate-venv() {
    local venv_dir="$HOME/.venvs/$1"
    if [ -z "$1" ]; then
        __render red
        echo 'ERROR: No python virtual environment specified!'
        return 1
    elif [ ! -d "$venv_dir" ]; then
        __render orange
        echo "WARN: Python virtual environment \"$1\" does not exist!"
        __render none

        if ! __user_continue "Create one?"; then return; fi
        create-venv "$1" || return 1
    fi

    source "$venv_dir/bin/activate"
}

# completion for above helpers listing existing environments
__venv_helper_completion() {
    COMPREPLY=()
    [ ${#COMP_WORDS[@]} -eq 2 ] && COMPREPLY=($(list-venv))
}
complete -F __venv_helper_completion activate-venv
complete -F __venv_helper_completion delete-venv
