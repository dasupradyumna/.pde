---------------------------------------- TYPE SPECIFICATIONS ---------------------------------------
---@meta _

----------------------------------- LIBUV API ----------------------------------

---@diagnostic disable:inject-field

---get high-resolution time duration (upto a nanosecond) from UNIX epoch or arbitrary time point
---@param clock_id 'monotonic' | 'realtime' realtime uses UNIX epoch, monotonic uses arbitrary epoch
---@return { nsec: integer, sec: integer } # time duration from specified epoch
---@nodiscard
function vim.uv.clock_gettime(clock_id) end

---returns the current working directory
---@return string
---@nodiscard
function vim.uv.cwd() end

---returns the file system status for the given path
---@param path string
---@return table? # file system info about given path (`nil` upon failure)
---@nodiscard
function vim.uv.fs_stat(path) end

---creates and returns a new timer instance
---@return uv_timer_t
---@nodiscard
function vim.uv.new_timer() end

---@class uv_handle_t
local uv_handle_t = {}

---close the handle and free its resources
function uv_handle_t:close() end

---returns true if handle is active, false if its inactive
---@return boolean
---@nodiscard
function uv_handle_t:is_active() end

---@class uv_timer_t : uv_handle_t
local uv_timer_t = {}

---start the current timer with the given specification
---@param timeout_ms integer initial timeout (in ms)
---@param repeat_ms integer repeat time (in ms)
---@param callback function function that is called repeatedly
function uv_timer_t:start(timeout_ms, repeat_ms, callback) end

---stop the timer and cancel callback loop
function uv_timer_t:stop() end
