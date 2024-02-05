"---------------------------------------- STATUS RENDERING ----------------------------------------"

function! ui#winbar()
    return printf(' %s %s   %%#WinBarBG#%%=%%* %s ',
                \ &modified ? '*' : ' ',
                \ expand('%:.'),
                \ toupper(&filetype))
endfunction

function! s:statusline_ruler()
    let l:width = 2 * strlen(nvim_buf_line_count(0)) + 9
    return '%' . l:width . '( %l/%L,%v %P%) '
endfunction

function! ui#statusline()
    return "%#TabLineSel# %{fnamemodify(getcwd(), ':~')}  %*%=" .
                \ s:statusline_ruler()
endfunction
