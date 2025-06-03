################################## NEOVIM CUSTOM BASH ENVIRONMENT ##################################

# Expand aliases even in non-interactive shells
# Reference: https://stackoverflow.com/a/18901595
# Needed for access to `__git_branch` in statusline
shopt -s expand_aliases
source "$(dirname $(realpath "$BASH_SOURCE"))/utils.sh"
