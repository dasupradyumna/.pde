"------------------------------------------- GREP SEARCH ------------------------------------------"

" setup rip-grep as the builtin grep tool and output format
const s:ripgrep = { 'exe': 'rg',
            \   'args': '--color=never --no-heading --line-number --smart-case --line-buffered --',
            \   'format': '\v^(.+):(\d+):.+$' }

" TODO: open a preview window to the right of results
let s:render = { 'buf': 0, 'win': { 'result': 0, 'preview': 0 } }
let s:search = { 'job': 0, 'no_results': v:true }

function! s:write_to_buffer(lines, start, end)
    call nvim_set_option_value('modifiable', v:true, { 'buf': s:render.buf })
    call nvim_buf_set_lines(s:render.buf, a:start, a:end, v:true, a:lines)
    call nvim_set_option_value('modifiable', v:false, { 'buf': s:render.buf })
endfunction

function! s:create_entry(_, match)
    let [filename, line] = util#matchstr(a:match, s:ripgrep.format)
    let filename = filename->fnamemodify(':.')
    return printf('%s [%s]', filename, line)
endfunction
function! s:process_results(matches)
    call s:write_to_buffer(a:matches->mapnew(function('s:create_entry')), -1, -1)

    " delete 'No matches found' placeholder when atleast 1 match has been found
    if s:search.no_results && !a:matches->empty()
        let s:search.no_results = v:false
        call s:write_to_buffer([], 0, 1)
    endif
endfunction
let s:search.worker = worker#create(50, function('s:process_results'))

function! s:search_job_on_event(_, data, event) dict
    if a:event == 'stdout'
        call s:search.worker.add(a:data
                    \               ->map({_,v->trim(v)})
                    \               ->filter({_,v->!empty(v)}))
    elseif a:event == 'exit'
        let s:search.job = 0
        call s:search.worker.stop()
    endif
endfunction
function! s:start_search_job(pattern)
    let s:search.no_results = v:true
    call s:search.worker.start()
    let s:search.job = jobstart([s:ripgrep.exe, s:ripgrep.args, a:pattern, getcwd()]->join(), {
                \ 'on_stdout': function('s:search_job_on_event'),
                \ 'on_exit': function('s:search_job_on_event') })
endfunction

function! s:buf_keymaps_down()
    return nvim_win_get_cursor(s:render.win.result)[0] == nvim_buf_line_count(s:render.buf)
                \ ? 'gg' : 'j'
endfunction
function! s:buf_keymaps_up()
    return nvim_win_get_cursor(s:render.win.result)[0] == 1 ? 'G' : 'k'
endfunction
function! s:buf_keymaps_open()
    return printf("0gf:setlocal winbar<\<CR>:keepjumps normal %sgg\<CR>",
                \ util#matchstr(nvim_get_current_line(), '^.* \[\v(\d+)]$')[0])
endfunction
function! s:create_buffer()
    let s:render.buf = nvim_create_buf(v:false, v:true)
    call nvim_set_option_value('buftype', 'nofile', { 'buf': s:render.buf })
    call nvim_set_option_value('modifiable', v:false, { 'buf': s:render.buf })

    call nvim_buf_set_keymap(s:render.buf, 'n', 'q', '<Cmd>quit<CR>', { 'noremap': v:true })
    call nvim_buf_set_keymap(s:render.buf, 'n', 'j', '<SID>buf_keymaps_down()',
                \                           { 'noremap': v:true, 'expr': v:true })
    call nvim_buf_set_keymap(s:render.buf, 'n', 'k', '<SID>buf_keymaps_up()',
                \                           { 'noremap': v:true, 'expr': v:true })
    call nvim_buf_set_keymap(s:render.buf, 'n', '<CR>', '<SID>buf_keymaps_open()',
                \                           { 'noremap': v:true, 'expr': v:true, 'silent': v:true })

    execute 'autocmd __user__ BufWipeout <buffer='..s:render.buf..'> let s:render.buf = 0'
endfunction

function! s:open_float()
    const screen_size = [&lines, &columns]
    const size = screen_size->mapnew({i,v->float2nr(v * 0.9)})
    const pos = size->mapnew({i,v->(screen_size[i] - v) / 2 - 1})
    let s:render.win.result = nvim_open_win(s:render.buf, v:true, { 'relative': 'editor',
                \ 'height': size[0], 'width': size[1], 'row': pos[0], 'col': pos[1],
                \ 'border': 'rounded',
                \ 'title': printf(' Search Results: %s ', getcwd()), 'title_pos': 'center' })
    " TODO: show total number of results in footer (and other stats?)
    " update first if case as well

    setlocal nospell cursorline nonumber statuscolumn= signcolumn=yes:1
    autocmd __user__ WinClosed *
                \ if expand('<amatch>') == s:render.win.result | let s:render.win.result = 0 | endif
endfunction

function! grep#search()
    if s:search.job | call jobstop(s:search.job) | endif
    if !s:render.buf | call s:create_buffer() | endif
    call s:write_to_buffer(['-- No matches found --'], 0, -1)

    " BUG: pressing <Esc> continues with empty pattern instead of cancelling
    let pattern = input('Search pattern: ')
    call s:start_search_job(pattern)

    if s:render.win.result
        call nvim_win_set_buf(s:render.win.result, s:render.buf)
    else
        call s:open_float()
    endif
endfunction

function! grep#search_filetype()
    call nvim_echo([['-- TO BE IMPLEMENTED [grep#search_filetype] --', 'Warn']], v:true, {})
endfunction

function! grep#search_directory()
    call nvim_echo([['-- TO BE IMPLEMENTED [grep#search_directory] --', 'Warn']], v:true, {})
endfunction
