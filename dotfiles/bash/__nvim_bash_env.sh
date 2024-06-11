################################## NEOVIM CUSTOM BASH ENVIRONMENT ##################################

# expand aliases even in non-interactive shells
# Reference: https://stackoverflow.com/a/18901595
shopt -s expand_aliases

# define git prompt helpers
source /usr/lib/git-core/git-sh-prompt

source "$(dirname $(realpath "$BASH_SOURCE"))/alias.sh"
