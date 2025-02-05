######################################## INTERNAL UTILITIES ########################################

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

# helper to prompt user for yes / no input
__user_continue() {
    local prompt="$1 (y/n) " invalid='Invalid choice!'
    local msg="$prompt"
    while true; do
        read -p "$msg" choice
        case "$choice" in
            [yY]) return 0 ;;
            [nN]) return 1 ;;
            *) [ ${#msg} -eq ${#prompt} ] && msg="$invalid $prompt";
                echo -en '\r\x1b[1A\x1b[0K' ;;  # moves cursor to and clears the previous line
        esac
    done
}
