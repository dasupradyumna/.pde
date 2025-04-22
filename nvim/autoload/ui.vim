"---------------------------------------- STATUS RENDERING ----------------------------------------"

"----------------------------------- WINBAR -----------------------------------"

const s:diffview = {
            \ 'panel': { 'File': 'status', 'FileHistory': 'log', 'FHOption': 'log options' },
            \ 'buffer': { ':0:': 'INDEX', ':1:': 'BASE', ':2:': 'CURRENT', ':3:': 'INCOMING' }
            \ }
function! s:winbar_bufname_diffview(bufname)
    " handle working directory buffers
    if a:bufname->match('^diffview://') < 0 | return 'WORK-TREE: ' .. a:bufname | endif

    " handle empty buffer
    if a:bufname == 'diffview://null' | return 'NULL' | endif

    " handle side panel buffers
    let name = util#matchstr(a:bufname, '\v^diffview:///panels/\d/Diffview(.*)Panel$')
    if !name->empty() | return 'git-' .. s:diffview.panel[name[0]] | endif

    " handle revision buffers
    let pattern = printf('\v^diffview://%s/.git/([[:alnum:]:]+)/(.+)$', t:diffview_toplevel_dir)
    let context = util#matchstr(a:bufname, pattern)
    let context[0] = s:diffview.buffer->get(context[0], 'COMMIT:' .. context[0])
    let context[1] = context[1]->fnamemodify(':gs;/;\\;')
    return context->join(': ')
endfunction

function! s:winbar_bufname()
    " FIX: :lcd causes the names to change constantly in other windows (same tabpage)
    let bufname = expand('%:.')

    " handle help buffers
    if &l:filetype == 'help' | return 'HELP: ' .. bufname->fnamemodify(':t:r') | endif

    " handle empty buffer
    if bufname->empty() | return '[ EMPTY ]' | endif

    " handle terminal buffer
    let terminfo = util#matchstr(bufname, '\v^term://(\f+)//\d+:(.+)$')
    if !terminfo->empty()
        return printf('TERM: (%s) %s', terminfo[0], terminfo[1])
    endif

    " handle git commit message editor
    if bufname->match('\v^\.git[\\/]COMMIT_EDITMSG$') == 0 | return 'git-commit message' | endif

    " handle git rebase interactive editor
    if bufname->match('\v^\.git[\\/]rebase-merge[\\/]git-rebase-todo') == 0
        return 'git-rebase interactive'
    endif

    " handle diffview.nvim buffers
    if util#is_diffview_tabpage() | return s:winbar_bufname_diffview(bufname) | endif

    return bufname
endfunction

const s:diagnostic_render = [['Error', ''], ['Warn', ''], ['Info', ''], ['Hint', '']]
function! s:winbar_diagnostics_map(index, value)
    if a:value->empty() | return a:value | endif

    let [hl, icon] = s:diagnostic_render[a:index]
    return printf('%%#WinBarDiag%s#%s %d', hl, icon, a:value)
endfunction
function! s:winbar_diagnostics()
    let diagnostics = v:lua.vim.diagnostic.count(0)
    if diagnostics->empty() | return '' | endif

    return diagnostics->map(function('s:winbar_diagnostics_map'))
                \ ->filter({_,v-> !v->empty()})
                \ ->insert('')->add('%#WinBarBG#')->join()
endfunction

const s:gitsigns_hl = { '+': 'New', '~': 'Dirty', '-': 'Deleted' }
function! s:winbar_gitsigns()
    let status = b:->get('gitsigns_status', '')->split()
    if status->empty() || util#is_diffview_tabpage() | return '' | endif

    return status->map({_,v-> printf("%%#WinBarGit%s#%s", s:gitsigns_hl[v[0]], v)})
                \ ->add('%#WinBarBG#')
                \ ->join()
endfunction

function! ui#winbar()
    return printf(' %s %s   %%#WinBarBG#%s%%=%s',
                \ &l:modified ? '*' : ' ',
                \ s:winbar_bufname(),
                \ s:winbar_diagnostics(),
                \ s:winbar_gitsigns())
endfunction

"--------------------------------- STATUSLINE ---------------------------------"

function! s:statusline_git_head()
    let head = util#git_head()
    return head->empty() ? '' : '%#Operator# 󰊢 ' .. head
endfunction

let s:todo = {
            \ 'render': { 'FIX': '󰠭 ', 'HACK': '󰈸 ', 'NOTE': '󰅺 ', 'PERF': '󰥔 ',
            \             'TEST': '󰖷 ', 'TODO': ' ', 'WARN': ' ' },
            \ 'stats': {},
            \ }
function! ui#update_todo_stats(entries)
    let s:todo.stats = {}
    for entry in a:entries
        let s:todo.stats[entry.tag] = s:todo.stats->get(entry.tag, 0) + 1
    endfor
endfunction
function! s:statusline_todo_stats()
    " disable for the home directory
    if getcwd() == $HOME | return '' | endif

    let [ok, config] = util#try_require('todo-comments.config')
    if !ok || !config.loaded | return '' | endif

    " update todo statistics using a throttled search function from todo-comments.nvim
    lua require('user.util').throttle.wrappers.todo_search()

    let out = []
    for keyword in s:todo.stats->keys()->sort()
        call add(out, printf('%%#TodoFg%s#%s%d',
                    \ keyword, s:todo.render[keyword], s:todo.stats[keyword]))
    endfor
    return out->add('')->join()
endfunction

function! s:statusline_ruler()
    let width = 2 * nvim_buf_line_count(0)->len() + 1
    return ' %' .. width .. '(%l/%L%),%2(%v%) '
endfunction

" PERF: cache statusline components (global, tab, window scopes) for more responsive rendering
"       git_head and todo_stats are a bit slow since they depend on shell processes
function! ui#statusline()
    return exists('g:user.neovim_git_mode')
                \ ? printf('%%#TabLineSel#  %s  %%*%%=%%#WinBarBG#%%#CursorLine#%s',
                \           getcwd()->fnamemodify(':t'),
                \           s:statusline_ruler())
                \ : printf('%%#TabLineSel#  %s  %s%%*%%=%s%%=%s%%#WinBarBG#%%#CursorLine#%s',
                \           getcwd()->fnamemodify(':t'),
                \           s:statusline_git_head(),
                \           v:lua.require('tabs').status(),
                \           s:statusline_todo_stats(),
                \           s:statusline_ruler())
endfunction

"-------------------------------- STATUSCOLUMN --------------------------------"

function! ui#statuscolumn_fold()
    let foldlevel = foldlevel(v:lnum)

    " start of a fold
    if util#is_diffview_tabpage()
                \ ? foldlevel == foldlevel(v:lnum - 1) + 1
                \ : nvim_treesitter#foldexpr()[0] == '>'
        return foldclosed(v:lnum) > 0 ? '' : ''
    endif

    return ' '
endfunction
