############################################ ENTRY POINT ###########################################

# global flag to indicate that bash environment scripts have been sourced
export BASH_INIT_SOURCED=true

curr_dir="$(dirname $(realpath "$BASH_SOURCE"))"

##################### OPTIONS AND SETUP ####################

# automatically change directory without using 'cd' command
shopt -s autocd

# expand aliases even in non-interactive shells
# Reference: https://stackoverflow.com/a/18901595
shopt -s expand_aliases

#################### SOURCE SUB-MODULES ####################

source "$curr_dir/render.sh"
source "$curr_dir/alias.sh"
source "$curr_dir/prompt.sh"
source "$curr_dir/silent_autocd.sh"

# delete all global symbols so they do not pollute the environment
unset -v curr_dir
