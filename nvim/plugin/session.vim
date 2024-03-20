"---------------------------------- AUTOMATIC SESSION MANAGEMENT ----------------------------------"

" standard data directory for all sessions
const s:session_folder = stdpath('data') .. '/sessions'

let s:session = { 'disabled': v:false }

function! s:is_current_session_empty()
    return nvim_list_bufs()->filter({i,v-> nvim_get_option_value('buftype', { 'buf': v }) == ''
                \                          && nvim_buf_get_name(v) != ''})
                \ ->empty()
endfunction

function! s:session.save()
    if self.disabled | return | endif
    if s:is_current_session_empty()  | call self.delete() | return | endif

    call mkdir(s:session_folder, 'p')
    execute 'mksession!' self.filepath
endfunction

function! s:session.load()
    let self.filepath = printf('%s/%s.vim', s:session_folder,
                \ getcwd(-1, -1)->substitute('@', '@@', 'g')->substitute('[/\:]', '@', 'g'))

    if self.disabled | return | endif
    if !filereadable(self.filepath) | echom 'No session found' | return | endif

    silent %bwipeout!
    try
        execute 'silent source' self.filepath
    catch
        let s:session.disabled = v:true
        call nvim_echo([["ERROR: Failed to load session!\n\n" .. v:exception, 'Error']], v:true, {})
    endtry
endfunction

function! s:session.delete()
    call delete(self.filepath)
endfunction

" session management commands
command! SessionSave call s:session.save()
command! SessionLoad call s:session.load()
command! SessionDelete call s:session.delete()
command! SessionEnable let s:session.disabled = v:false
command! SessionDisable let s:session.disabled = v:true

augroup __session__
    autocmd!

    " restore existing session if any, when entering Neovim or the current directory
    autocmd VimEnter,DirChanged * ++nested SessionLoad

    " save current session, when leaving Neovim or the current directory
    autocmd VimLeavePre,DirChangedPre * SessionSave

augroup END
