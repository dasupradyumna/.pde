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

function! s:git_head_on_event(_, data, event) dict
    if a:event == 'stdout'
        let self.output ..= a:data->join()->trim()
    elseif a:event == 'exit'
        if !self.output->empty()
            let g:user.git_head = self.output
        elseif g:user->has_key('git_head')
            call remove(g:user, 'git_head')
        endif
    endif
endfunction
function! util#update_git_head()
    call jobstart('git symbolic-ref -q --short HEAD || git rev-parse --short HEAD', { 'output': '',
                \ 'on_stdout': function('s:git_head_on_event') ,
                \ 'on_exit': function('s:git_head_on_event') })
endfunction

" NOTE: limitation: can handle only upto 9 captures
function! util#matchstr(target, pattern, match_all = v:false)
    let matches = []
    try | call substitute(a:target, a:pattern, {m-> extend(matches, m)}, a:match_all ? 'g' : '')
    catch | return matches[1:]->filter({_,v-> !empty(v)})
    endtry
endfunction
