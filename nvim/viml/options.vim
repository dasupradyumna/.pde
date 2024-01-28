"----------------------------------------- BUILTIN OPTIONS ----------------------------------------"

"--------------------------------- OS-SPECIFIC --------------------------------"

let s:config_path = stdpath('config')
if has('win32')
    set shell=pwsh shellcmdflag=-Command
    let s:config_path = s:config_path[2:]
endif

"--------------------------------- EDIT-FORMAT --------------------------------"

set backspace+=nostop
set complete=
set expandtab
set formatoptions+=ro/n1
set selectmode=key
set shiftwidth=4
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
set report=0
set scrolloff=4
set sessionoptions=buffers,curdir,folds,help,options,tabpages,winsize
set shortmess=aoOsIcCF
set sidescrolloff=4
set smartcase
set spell spelloptions=camel
let &spellfile = s:config_path . '/spell/en.utf-8.add'
set splitbelow splitright
set startofline
set switchbuf+=useopen
set updatetime=500
let &verbosefile = stdpath('data') . '/verbose.txt'
set whichwrap=h,l,<,>,[,]

"--------------------------------- UI-DISPLAY ---------------------------------"

set cmdwinheight=10
set colorcolumn=+1
set cursorline
let &diffopt = 'filler,context:3,vertical,closeoff,hiddenoff,foldcolumn:0,followwrap,internal,'
            \ . 'indent-heuristic,linematch:60,algorithm:histogram'
set display+=uhex
set fillchars=diff:╱,eob:\  " TODO: add fold*, msgsep
set list listchars=tab:──,trail:·,extends:~,precedes:~
set nowrap
set number numberwidth=2
set signcolumn=auto:2
