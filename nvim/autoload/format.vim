"----------------------------------------- CODE FORMATTING ----------------------------------------"

function! s:config_resolver(filename)
    return filereadable(a:filename)
                \ ? a:filename
                \ : printf('%s/conf/%s', stdpath('config'), a:filename)
endfunction

const s:bin = stdpath('data') .. '/mason/bin'

const s:lua = { 'exe': s:bin .. '/stylua', 'config': 'stylua.toml',
            \ 'commands': [{-> [s:lua.exe, '-f', s:config_resolver(s:lua.config), expand('%:.')]}] }

const s:python = { 'black': s:bin .. '/black', 'isort': s:bin .. '/isort',
            \ 'commands': [{-> [s:python.black, '--line-length', '100', expand('%:.')]},
            \              {-> [s:python.isort, '--profile', 'black', expand('%:.')]}] }

const s:rust = { 'exe': 'rustfmt', 'config': 'rustfmt.toml',
            \ 'commands': [{->[s:rust.exe, '-q',
            \                   '--config-path', s:config_resolver(s:rust.config), expand('%:.')]}]}

" formatting is enabled by default
let s:enabled = v:true

"----------------------------- FORMATTER FUNCTIONS ----------------------------"

function! format#enable()
    let s:enabled = v:true
endfunction

function! format#disable()
    let s:enabled = v:false
endfunction

function! format#buffer()
    if !s:enabled | return | endif

    " disable formatting in diffview.nvim tabpage for revision buffers
    " TODO: remove this if formatting is performed on buffer content instead of files
    if util#is_diffview_tabpage() && expand('%:.')->match('^diffview://') >= 0 | return | endif

    let formatter = s:->get(&l:filetype, {})
    if formatter->empty() | return | endif

    for Cmd in formatter.commands
        " FIX: system() is a blocking function call?
        let output = system(Cmd())
        if v:shell_error
            call v:lua.vim.notify("Formatting failed\n\n" .. output, 3) | return
        endif
    endfor
endfunction
