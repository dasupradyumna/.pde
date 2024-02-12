"---------------------------------------- STATUS RENDERING ----------------------------------------"

"----------------------------------- WINBAR -----------------------------------"

const s:diffview_panel = { 'File': 'status', 'FileHistory': 'log', 'FHOption': 'log options' }
const s:diffview_buf = { ':0:': 'INDEX', ':1:': 'BASE', ':2:': 'CURRENT', ':3:': 'INCOMING' }
function! s:winbar_bufname_diffview(bufname)
    " handle working directory buffers
    if match(a:bufname, '^diffview://') < 0 | return 'WORK-TREE: ' .. a:bufname | endif

    " handle empty buffer
    if a:bufname == 'diffview://null' | return 'NULL' | endif

    " handle side panel buffers
    let name = matchstr(a:bufname, '^diffview:///panels/\d/Diffview\zs.*\zePanel$')
    if !empty(name) | return 'git-' .. s:diffview_panel[name] | endif

    " handle revision buffers
    let pattern = printf('\v^diffview://%s/.git/([[:alnum:]:]+)/(.+)$',
                \ v:lua.vim.fs.normalize(getcwd()))
    let context = split(substitute(a:bufname, pattern, '\1 \2', ''))
    let context[0] = get(s:diffview_buf, context[0], 'COMMIT:' .. context[0])
    let context[1] = fnamemodify(context[1], ':gs;/;\\;')
    return join(context, ': ')
endfunction

function! s:winbar_bufname()
    let bufname = expand('%:.')

    " handle empty buffer
    if empty(bufname) | return '[ EMPTY ]' | endif

    " handle git commit message editor
    if match(bufname, '\v^\.git[\\/]COMMIT_EDITMSG$') == 0 | return 'git-commit message' | endif

    " handle diffview.nvim buffers
    if util#is_diffview_tabpage() | return s:winbar_bufname_diffview(bufname) | endif

    return bufname
endfunction

const s:gitsigns_hl = { '+': 'GitNew', '~': 'GitDirty', '-': 'GitDeleted' }
function! s:winbar_gitsigns()
    let status = split(get(b:, 'gitsigns_status', ''))
    if empty(status) || util#is_diffview_tabpage() | return '' | endif

    return join(add(map(status, 'printf("%%#%s#%s", s:gitsigns_hl[v:val[0]], v:val)'),
                \ '%#WinBarBG#'))
endfunction

function! s:winbar_filetype()
    if match(&l:filetype, '^Diffview\|gitcommit') == 0 | return '' | endif

    return printf('%%* %s ', &l:filetype == '' ? '-' : toupper(&l:filetype))
endfunction

function! ui#winbar()
    return printf(' %s %s   %%#WinBarBG#%%=%s%s',
                \ &l:modified ? '*' : ' ',
                \ s:winbar_bufname(),
                \ s:winbar_gitsigns(),
                \ s:winbar_filetype())
endfunction

"--------------------------------- STATUSLINE ---------------------------------"

function! s:statusline_ruler()
    let width = 2 * strlen(nvim_buf_line_count(0)) + 9
    return '%' .. width .. '( %l/%L,%v %P%) '
endfunction

function! ui#statusline()
    return "%#TabLineSel# %{fnamemodify(getcwd(),':~')}  %*%=" .. s:statusline_ruler()
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
    " end of a fold
    if foldlevel - 1 == foldlevel(v:lnum + 1) | return foldlevel == 1 ? '╰' : '├' | endif
    " everywhere else
    return foldlevel ? '│' : ' '
endfunction
