"--------------------------------------- CUSTOM USER AUTOCOMMANDS ---------------------------------"

" TODO: exclude all filetypes that have a formatter / LSP
function s:trim_trailing_whitespace()
    let l:view = winsaveview()
    %s:\s\+$::e
    call winrestview(l:view)
endfunction

function s:enable_cursorline(enable)
    if a:enable | setlocal cursorline | else | setlocal nocursorline | endif
endfunction

augroup __user__
    autocmd!

    " trim all trailing whitespace before writing buffer
    autocmd BufWritePre * call <SID>trim_trailing_whitespace()

    " enable cursorline only in focused window
    autocmd VimEnter,WinEnter * call <SID>enable_cursorline(1)
    autocmd WinLeave * call <SID>enable_cursorline(0)

    " disable color column in buffers not associated with files
    autocmd BufEnter * if &buftype != '' | setlocal colorcolumn= | endif

augroup END
