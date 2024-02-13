"---------------------------------------- STATUS RENDERING ----------------------------------------"

"----------------------------------- WINBAR -----------------------------------"

const s:diffview_panel = { 'File': 'status', 'FileHistory': 'log', 'FHOption': 'log options' }
const s:diffview_buf = { ':0:': 'INDEX', ':1:': 'BASE', ':2:': 'CURRENT', ':3:': 'INCOMING' }
function! s:winbar_bufname_diffview(bufname)
    " handle working directory buffers
    if a:bufname->match('^diffview://') < 0 | return 'WORK-TREE: ' .. a:bufname | endif

    " handle empty buffer
    if a:bufname == 'diffview://null' | return 'NULL' | endif

    " handle side panel buffers
    let name = a:bufname->matchstr('^diffview:///panels/\d/Diffview\zs.*\zePanel$')
    if !name->empty() | return 'git-' .. s:diffview_panel[name] | endif

    " handle revision buffers
    let pattern = printf('\v^diffview://%s/.git/([[:alnum:]:]+)/(.+)$',
                \ v:lua.vim.fs.normalize(getcwd()))
    let context = a:bufname->substitute(pattern, '\1 \2', '')->split()
    let context[0] = s:diffview_buf->get(context[0], 'COMMIT:' .. context[0])
    let context[1] = context[1]->fnamemodify(':gs;/;\\;')
    return context->join(': ')
endfunction

function! s:winbar_bufname()
    let bufname = expand('%:.')

    " handle empty buffer
    if bufname->empty() | return '[ EMPTY ]' | endif

    " handle git commit message editor
    if bufname->match('\v^\.git[\\/]COMMIT_EDITMSG$') == 0 | return 'git-commit message' | endif

    " handle diffview.nvim buffers
    if util#is_diffview_tabpage() | return s:winbar_bufname_diffview(bufname) | endif

    return bufname
endfunction

const s:gitsigns_hl = { '+': 'GitNew', '~': 'GitDirty', '-': 'GitDeleted' }
function! s:winbar_gitsigns()
    let status = b:->get('gitsigns_status', '')->split()
    if status->empty() || util#is_diffview_tabpage() | return '' | endif

    return status->map('printf("%%#%s#%s", s:gitsigns_hl[v:val[0]], v:val)')
                \ ->add('%#WinBarBG#')
                \ ->join()
endfunction

function! s:winbar_filetype()
    let filetype = &l:filetype
    if filetype->match('^Diffview\|gitcommit') == 0 | return '' | endif

    return printf('%%* %s ', filetype->empty() ? '-' : filetype->toupper())
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
    let width = 2 * nvim_buf_line_count(0)->len() + 9
    return '%' .. width .. '( %l/%L,%v %P%) '
endfunction

function! ui#statusline()
    return "%#TabLineSel# %{getcwd()->fnamemodify(':~')}  %*%=" .. s:statusline_ruler()
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
