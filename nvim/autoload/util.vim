"---------------------------------------- UTILITIES MODULE ----------------------------------------"

" HACK: uses diffview.nvim internals
function! util#is_diffview_tabpage()
    return get(t:, 'diffview_view_initialized', v:false)
endfunction

function! util#is_diffview_panel()
    return match(&l:filetype, '^Diffview') == 0
endfunction
