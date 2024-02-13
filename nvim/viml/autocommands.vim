"--------------------------------------- CUSTOM AUTOCOMMANDS --------------------------------------"

"-------------------------------- USER-DEFINED --------------------------------"

" TODO: exclude all filetypes that have a formatter / LSP
const s:trim_exclude = [ 'gitcommit', 'markdown' ]
function! s:trim_trailing_whitespace()
    if s:trim_exclude->index(&l:filetype) >= 0 | return | endif

    let view = winsaveview()
    %s:\s\+$::e
    call winrestview(view)
endfunction

function! s:set_statuscolumn_foldexpr()
    " reset statuscolumn to default (if an existing parser is uninstalled)
    setlocal statuscolumn<

    let supported = v:lua.require('nvim-treesitter.info').installed_parsers()
    " BUG: check using mapping from parser name to filetype (typically the same)
    if supported->index(&l:filetype) < 0 && !util#is_diffview_tabpage() | return | endif
    if util#is_diffview_panel() | return | endif

    let &l:statuscolumn ..= '%#LineNr#%{ui#statuscolumn_fold()} '
endfunction

augroup __user__
    autocmd!

    " trim all trailing whitespace before writing buffer
    autocmd BufWritePre * call <SID>trim_trailing_whitespace()

    " enable cursorline only in focused window
    autocmd VimEnter,WinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline

    " disable colorcolumn in buffers not associated with files
    autocmd BufWinEnter * if &buftype != '' | setlocal colorcolumn= | endif

    " display folds in statuscolumn when supported
    autocmd BufWinEnter * call <SID>set_statuscolumn_foldexpr()

augroup END

"----------------------------------- PLUGINS ----------------------------------"

function! s:diffview_customize_commit_log_panel()
    setlocal statuscolumn<
    nnoremap <buffer> q <Cmd>quit<CR>
endfunction

augroup __plugins__
    autocmd!

    " customize diffview.nvim commit log panel behavior
    autocmd BufEnter diffview://*/.git/log/*/commit_log call s:diffview_customize_commit_log_panel()

augroup END
