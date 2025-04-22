"--------------------------------------- CUSTOM AUTOCOMMANDS --------------------------------------"

"-------------------------------- USER-DEFINED --------------------------------"

" TODO: exclude all filetypes that have a formatter / LSP
const s:trim_exclude = ['gitcommit', 'lua', 'markdown', 'python']
function! s:trim_trailing_whitespace()
    if s:trim_exclude->index(&l:filetype) >= 0 | return | endif

    let view = winsaveview()
    %substitute:\s\+$::e
    call winrestview(view)
endfunction

function! s:set_statuscolumn_foldexpr()
    " reset statuscolumn to default (if an existing parser is uninstalled)
    setlocal statuscolumn<

    let installed = v:lua.require('nvim-treesitter.info').installed_parsers()
    let required = v:lua.vim.treesitter.language.get_lang(&l:filetype)
    if installed->index(required) < 0 && !util#is_diffview_tabpage() | return | endif
    if util#is_diffview_panel() || &l:filetype == 'help' | return | endif

    let &l:statuscolumn ..= '%#LineNr#%{ui#statuscolumn_fold()} '
endfunction

function! s:switch_cursorline(enable)
    if &l:filetype->match('^ripgrep_nvim') >= 0 | return | endif

    if a:enable | setlocal cursorline | else | setlocal nocursorline | endif
endfunction

augroup __user__
    autocmd!

    " trim all trailing whitespace before writing buffer
    autocmd BufWritePre * call s:trim_trailing_whitespace()

    " enable cursorline only in focused window
    autocmd VimEnter,WinEnter * call s:switch_cursorline(v:true)
    autocmd WinLeave * call s:switch_cursorline(v:false)

    if !exists('g:user.neovim_git_mode')

        " disable colorcolumn in buffers not associated with files
        autocmd BufWinEnter * if &buftype != '' | setlocal colorcolumn= | endif

        " format buffers using the configured formatters
        autocmd BufWritePost * call format#buffer()

        " display folds in statuscolumn when supported
        autocmd BufWinEnter * call s:set_statuscolumn_foldexpr()

        autocmd TermOpen * setlocal nospell nonumber

    endif
augroup END

"----------------------------------- PLUGINS ----------------------------------"

function! s:diffview_customize_commit_log()
    setlocal statuscolumn<
    nnoremap <buffer> q <Cmd>quit<CR>
endfunction

if !exists('g:user.neovim_git_mode')
    augroup __plugin__
        autocmd!

        " customize diffview.nvim commit log panel behavior
        autocmd BufEnter diffview://*/.git/log/*/commit_log call s:diffview_customize_commit_log()

    augroup END
endif
