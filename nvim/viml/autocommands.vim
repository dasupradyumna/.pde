"--------------------------------------- CUSTOM USER AUTOCOMMANDS ---------------------------------"

" TODO: exclude all filetypes that have a formatter / LSP
const s:trim_exclude = [ 'gitcommit', 'markdown' ]
function! s:trim_trailing_whitespace()
    if index(s:trim_exclude, &l:filetype) >= 0 | return | endif

    let view = winsaveview()
    %s:\s\+$::e
    call winrestview(view)
endfunction

function! s:enable_cursorline(enable)
    if a:enable | setlocal cursorline | else | setlocal nocursorline | endif
endfunction

function! s:set_statuscolumn_foldexpr()
    " reset statuscolumn to default (if an existing parser is uninstalled)
    setlocal statuscolumn<

    let supported = v:lua.require('nvim-treesitter.info').installed_parsers()
    " BUG: check using mapping from parser name to filetype (typically the same)
    if index(supported, &l:filetype) < 0 && !util#is_diffview_tabpage() | return | endif
    if util#is_diffview_panel() | return | endif

    let &l:statuscolumn ..= '%#LineNr#%{ui#statuscolumn_fold()} '
endfunction

augroup __user__
    autocmd!

    " trim all trailing whitespace before writing buffer
    autocmd BufWritePre * call <SID>trim_trailing_whitespace()

    " enable cursorline only in focused window
    autocmd VimEnter,WinEnter * call <SID>enable_cursorline(1)
    autocmd WinLeave * call <SID>enable_cursorline(0)

    " disable colorcolumn in buffers not associated with files
    autocmd BufEnter * if &buftype != '' | setlocal colorcolumn= | endif

    " display folds in statuscolumn when supported
    autocmd BufEnter * call <SID>set_statuscolumn_foldexpr()

augroup END
