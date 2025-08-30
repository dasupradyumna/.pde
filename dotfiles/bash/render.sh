####################################################################################################

###################### TERMINAL COLORS #####################

# FIX: update this with term colors after wezterm gets the same palette ??
declare -g -A __render_styles=(
    [none]='0'
    # color
    [blue]='38:2:130:207:255'
    [dark_blue]='38:2:80:176:224'
    [gray]='38:2:135:141:150'
    [green]='38:2:66:190:101'
    [orange]='38:2:224:160:118'
    [dark_orange]='38:2:202:112:80'
    [purple]='38:2:163:160:216'
    [red]='38:2:255:114:121'
    # thickness
    [bold]='1'
    [normal]='22'
)

# return the specified terminal control sequence surrounded by \[\033[...m\]
# Reference: https://stackoverflow.com/a/77033447
__render() { echo -en "\x01\x1b[${__render_styles["$1"]}m\x02"; }
