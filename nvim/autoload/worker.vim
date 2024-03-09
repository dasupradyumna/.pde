"------------------------------------------ WORKER QUEUE ------------------------------------------"

let s:Worker = { 'active': v:false, 'jobs': [] }

function! s:new_Worker(timeout, callback, throttle_timeout = 0)
    let worker = deepcopy(s:Worker)
    return worker->extend({ 'callback': throttle#wrap(a:throttle_timeout, a:callback),
                \           'timeout': a:timeout })
endfunction

function! s:worker_loop(timer) dict
    if self.jobs->empty()
        " stop the timer only when the worker is inactive and all jobs have been processed
        if !self.active | call timer_stop(a:timer) | endif
        return
    endif

    " only remove a job if it has been processed successfully
    if call(self.callback.run, self.jobs[0])
        call remove(self.jobs, 0)
    endif
endfunction

function! s:Worker.add(...)
    call add(self.jobs, a:000)
endfunction

function! s:Worker.start()
    let self.active = v:true
    call timer_start(self.timeout, function('s:worker_loop', [], self), { 'repeat': -1 })
endfunction

function! s:Worker.stop()
    let self.active = v:false
endfunction

function! worker#create(...)
    return call(function('s:new_Worker'), a:000)
endfunction
