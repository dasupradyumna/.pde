"---------------------------------------- UTILITIES MODULE ----------------------------------------"

" HACK: uses diffview.nvim internals
function! util#is_diffview_tabpage()
    return t:->get('diffview_view_initialized', v:false)
endfunction

function! util#is_diffview_panel()
    return &l:filetype->match('^Diffview') == 0
endfunction

function! util#try_require(path)
    try
        let module = v:lua.require(a:path)
        return [v:true, module]
    catch
        return [v:false, v:null]
    endtry
endfunction

" NOTE: limitation: can handle only upto 9 captures
function! util#matchstr(target, pattern, match_all = v:false)
    let matches = []
    try | call substitute(a:target, a:pattern, {m-> extend(matches, m)}, a:match_all ? 'g' : '')
    catch | return matches[1:]->filter({_,v-> !empty(v)})
    endtry
endfunction
