----------------------------------------- UTILITIES MODULE -----------------------------------------

local M = {}

M.path = {
  config = vim.fn.stdpath 'config',
  data = vim.fn.stdpath 'data',
}

-- source vimscript file in config directory
function M.vim_source(file) vim.cmd.source(('%s/viml/%s.vim'):format(M.path.config, file)) end

return M
