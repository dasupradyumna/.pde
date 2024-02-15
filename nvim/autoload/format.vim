"----------------------------------------- CODE FORMATTING ----------------------------------------"

function! s:config_resolver(filename)
    return filereadable(a:filename)
                \ ? a:filename
                \ : printf('%s/conf/%s', stdpath('config'), a:filename)
endfunction

const s:lua = { 'exe': stdpath('data') .. '/mason/bin/stylua', 'config': 'stylua.toml',
            \ 'command': {->[ s:lua.exe, '-f', s:config_resolver(s:lua.config), expand('%:.') ]} }

"----------------------------- FORMATTER FUNCTION -----------------------------"

function! format#buffer()
    let formatter = s:->get(&l:filetype, {})
    if formatter->empty() | return | endif

    " FIX: system() is a blocking function call?
    let output = system(formatter.command())
    if v:shell_error | call v:lua.vim.notify("Formatting failed\n\n" .. output, 3) | return | endif
    checktime %
endfunction
