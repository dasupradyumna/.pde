####################################### CUSTOM COMMAND PROMPT ######################################

export PROMPT_COMMAND='
__prompt_exit_status="$([ $? -eq 0 ] && echo none || echo red)"

# HACK: because upstream indicators are not separated from branch with a whitespace
__prompt_git_branch="$(__git_branch)"
__prompt_git_state="$(__git_ps1 %s)"
__prompt_git_state="${__prompt_git_state#$__prompt_git_branch}"
'

# git prompt flags
# Reference: /usr/lib/git-core/git-sh-prompt
GIT_PS1_SHOWDIRTYSTATE=true         # * (unstaged), + (staged)
GIT_PS1_SHOWSTASHSTATE=true         # $
GIT_PS1_SHOWUNTRACKEDFILES=true     # %
GIT_PS1_SHOWUPSTREAM=true           # < if behind, > if ahead, = if in sync
GIT_PS1_COMPRESSSPARSESTATE=true    # ? if repo was sparse-checked out
GIT_PS1_DESCRIBE_STYLE=branch       # no. of commits away from newer branch / tag (detached HEAD)
# TODO: add support for sparse, rebase, merge, cherry-pick and revert (bare/git_dir also)

# disable python virtual environments from changing the prompt
VIRTUAL_ENV_DISABLE_PROMPT=true
conda config --set changeps1 false &>/dev/null

################### PRIMARY PROMPT STRING ##################

__prompt_job_status() { [ -n "$(jobs)" ] && { __render orange; echo -n '󰫢 '; }; }

__prompt_user_host() {
    # HACK: Check if in SSH session or inside a Docker container
    if [ -n "$(who -m)" ] || [ -f "/.dockerenv" ]; then
        __render green; echo -n "[$(whoami)@$(hostname)] ";
    fi
}

__prompt_cwd() {
    __render dark_blue
    echo -n "$(pwd | sed "s|^$HOME|~|")"
}

__prompt_git_info() {
    [ -z "$__prompt_git_branch" ] && return

    # TODO: make the branch symbol dynamic based on current repo state (detached, merge, rebase etc)
    # check oct_git_xxx in wezterm nerdfonts
    local git_info="$(__render red)  $(__render purple)$__prompt_git_branch"

    # parse the git state string
    local -A state
    for i in $(seq 0 ${#__prompt_git_state}); do
        case "${__prompt_git_state:$i:1}" in
            '%') state['untracked']=true ;;
            '*') state['unstaged']=true ;;
            '+') state['staged']=true ;;
            '$') state['stash']=true ;;
            '<') state['up_behind']=true ;;
            '>') state['up_ahead']=true ;;
            *) ;;
        esac
    done

    # upstream indicator
    [ -n "${state['up_behind']}" ] && git_info+="$(__render dark_blue)"
    [ -n "${state['up_ahead']}" ] && git_info+="$(__render dark_blue)"

    # stash indicator
    [ -n "${state['stash']}" ] && git_info+="$(__render blue) 󰍜"

    # commit status indicator
    git_info+=' '
    [ -n "${state['untracked']}" ] && git_info+="$(__render gray)"
    [ -n "${state['unstaged']}" ] && git_info+="$(__render red)"
    [ -n "${state['staged']}" ] && git_info+="$(__render green)"

    echo -n "$git_info"
    # echo -n " $(__render gray)$__prompt_git_state"
}

__prompt_python_env() {
    # NOTE: assumes both venv and conda environments will be active simultaneously
    __render dark_orange
    [ -n "$VIRTUAL_ENV" ] && echo -n "$(basename "$VIRTUAL_ENV") "
    [ -n "$CONDA_DEFAULT_ENV" ] && echo -n "$(basename "$CONDA_DEFAULT_ENV") "
}

__prompt_character() { __render "$__prompt_exit_status"; echo -n '  '; }

export PS1='
$(__prompt_job_status)$(__prompt_user_host)$(__prompt_cwd)$(__prompt_git_info)
$(__prompt_python_env)$(__prompt_character)$(__render none)'
