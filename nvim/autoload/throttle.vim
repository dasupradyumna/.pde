"---------------------------------------- THROTTLE WRAPPER ----------------------------------------"

const s:status = { 'RUNNING': 0, 'EXITED': 1, 'TIMEOUT': 2, 'FREE': 3 }

let s:ThrottleWrapper = { 'status': s:status.FREE }

function! s:new_ThrottleWrapper(timeout, callback, args)
    let wrapper = copy(s:ThrottleWrapper)
    return wrapper->extend({ 'callback': a:callback, 'args': a:args, 'timeout': a:timeout })
endfunction

function! s:wrapper_on_timeout(_) dict
    let self.status += s:status.TIMEOUT
endfunction

function! s:ThrottleWrapper.run(...)
    if self.status != s:status.FREE | return v:false | endif

    call timer_start(self.timeout, function('s:wrapper_on_timeout', [], self))

    let self.status = s:status.RUNNING
    call call(self.callback, a:0 > 0 ? a:000 : deepcopy(self.args))
    let self.status += s:status.EXITED

    return v:true
endfunction

function! throttle#wrap(timeout, callback, ...)
    return s:new_ThrottleWrapper(a:timeout, a:callback, a:000)
endfunction
