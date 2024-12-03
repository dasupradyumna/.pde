----------------------------------------- UTILITIES MODULE -----------------------------------------
-- CHECK: is throttle wrapper needed?

local M = {}

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

        vim.defer_fn(
          function() self.status = self.status + M.throttle.status.TIMEOUT end,
          self.timeout
        )

        self.status = M.throttle.status.RUNNING
        self.callback(unpack(select('#', ...) > 0 and { ... } or vim.deepcopy(self.args)))
        self.status = self.status + M.throttle.status.EXITED
      end,
    })
  end,
}

return M
