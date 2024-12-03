"----------------------------------------- BUILTIN OPTIONS ----------------------------------------"

"--------------------------------- OS-SPECIFIC --------------------------------"

let s:config_path = stdpath('config')
if has('win32')
    set shell=pwsh shellcmdflag=-Command shellxquote=
    " HACK: excluding drive modifier on Windows works for 'spellfile' option
    let s:config_path = s:config_path[2:]
elseif has('linux')
    let $BASH_ENV = '~/.pde/dotfiles/bash/__nvim_bash_env.sh'
endif

"--------------------------------- EDIT-FORMAT --------------------------------"

set backspace+=nostop
set complete=
set expandtab
set formatoptions+=ro/n1
set selectmode=key
set shiftwidth=4
set softtabstop=-1
set textwidth=100

"--------------------------------- UX-BEHAVIOR --------------------------------"

set cdhome
set cedit=\<C-Q>
set confirm
set debug=msg
set gdefault
set ignorecase
set keymodel=startsel,stopsel
set matchpairs+=<:>
set mouse=
set report=0
set scrolloff=4
set sessionoptions=buffers,globals,help,tabpages,winsize
set shortmess=aoOsIcCF
set sidescrolloff=4
set smartcase
set spelloptions=camel
let &spellfile = s:config_path .. '/spell/en.utf-8.add'
set splitbelow splitright
set startofline
set switchbuf+=useopen
set updatetime=500
let &verbosefile = stdpath('data') .. '/verbose.txt'
set whichwrap=h,l,<,>,[,]

"--------------------------------- UI-DISPLAY ---------------------------------"

set cmdwinheight=10
set colorcolumn=+1
set cursorlineopt=line
let &diffopt = 'filler,context:3,vertical,closeoff,hiddenoff,foldcolumn:0,followwrap,internal,'
            \ .. 'indent-heuristic,linematch:60,algorithm:histogram'
set display+=uhex
set fillchars=diff:╳,eob:\ ,fold:\ ,msgsep:━
set foldtext=
set laststatus=3
set list listchars=leadmultispace:│\ \ \ ,tab:──,trail:· " HACK: temporary indenting
set noruler nowrap
set number numberwidth=2
set showtabline=0
set signcolumn=auto:1
let &statuscolumn = '%s%=%l '
set statusline=%{%ui#statusline()%}
set winbar=%{%ui#winbar()%}
