-------------------------------------------- ENTRY POINT -------------------------------------------

local util = require 'util'

util.vim_source 'options'
util.vim_source 'keymaps'
util.vim_source 'autocommands'

-- bootstrap lazy.nvim plugin manager
local lazy_path = util.path.data .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazy_path) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim',
    '--branch=stable',
    lazy_path
  }
end
vim.opt.runtimepath:prepend(lazy_path)
require('lazy').setup('plugins', {
  lockfile = util.path.data .. '/lazy-lock.json',
  ui = { size = { width = 0.999, height = 0.95 }, border = 'rounded' },
})
