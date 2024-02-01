----------------------------------------- UTILITIES MODULE -----------------------------------------

local M = {}

function M.vim_source(file)
  vim.cmd.source(('%s/viml/%s.vim'):format(vim.fn.stdpath 'config', file))
end

return M
