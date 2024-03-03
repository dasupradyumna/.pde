----------------------------------------- UTILITIES MODULE -----------------------------------------

local M = {}

M.path = {
  config = vim.fn.stdpath 'config',
  data = vim.fn.stdpath 'data',
}

-- source vimscript file in config directory
function M.vim_source(file) vim.cmd.source(('%s/viml/%s.vim'):format(M.path.config, file)) end

---executes callback after the specified timeout
---@param timeout integer
---@param callback function
function M.schedule_after(timeout, callback)
  local timer = vim.uv.new_timer()
  timer:start(timeout, 0, function()
    timer:stop()
    timer:close()
    vim.schedule(callback)
  end)
end

M.throttle = {
  ---@enum ThrottleStatus throttle wrapper status
  status = {
    RUNNING = 0,
    EXITED = 1,
    TIMEOUT = 2,
    FREE = 3,
  },

  ---@class ThrottleWrapper
  ---@field status ThrottleStatus current status of the wrapper
  ---@field timeout integer minimum throttle timeout (in ms)
  ---@field callback function callback to throttle
  ---@field args any[] (optional) arguments for the callback

  ---@type table<string, ThrottleWrapper> list of registered wrappers
  wrappers = {},

  ---registers a callback under the specified name in throttle.wrappers
  ---@param name string registration name
  ---@param timeout integer minimum throttle timeout (in ms)
  ---@param callback function callback to throttle
  ---@param ... any callback arguments
  register_wrapper = function(name, timeout, callback, ...)
    M.throttle.wrappers[name] = setmetatable({
      callback = callback,
      args = { ... },
      timeout = timeout,
      status = M.throttle.status.FREE,
    }, {
      __call = function(self, ...)
        ---@cast self ThrottleWrapper
        if self.status ~= M.throttle.status.FREE then return end

        M.schedule_after(
          self.timeout,
          function() self.status = self.status + M.throttle.status.TIMEOUT end
        )

        self.status = M.throttle.status.RUNNING
        vim.schedule_wrap(self.callback)(
          unpack(select('#', ...) > 0 and { ... } or vim.deepcopy(self.args))
        )
        self.status = self.status + M.throttle.status.EXITED
      end,
    })
  end,
}

return M
