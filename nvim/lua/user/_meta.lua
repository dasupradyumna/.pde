---------------------------------------- TYPE SPECIFICATIONS ---------------------------------------
---@meta _

----------------------------------- LIBUV API ----------------------------------

---@diagnostic disable:inject-field

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
function vim.uv.new_timer() end

---@class uv_timer_t
local uv_timer_t = {}

---start the current timer with the given specification
---@param timeout_ms integer initial timeout (in ms)
---@param repeat_ms integer repeat time (in ms)
---@param callback function function that is called repeatedly
function uv_timer_t:start(timeout_ms, repeat_ms, callback) end

---stop the timer and cancel callback loop
function uv_timer_t:stop() end

---close the timer and free its handle
function uv_timer_t:close() end
