-------------------------------------------- ENTRY POINT -------------------------------------------

-- global user data
vim.g.user = vim.empty_dict()

local util = require 'user.util'

util.vim_source 'options'
util.vim_source 'keymaps'
util.vim_source 'autocommands'

-- bootstrap lazy.nvim plugin manager
local lazy_path = util.path.data .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazy_path) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim',
    '--branch=stable',
    lazy_path,
  }
end
vim.opt.runtimepath:prepend(lazy_path)
require('lazy').setup('plugins', {
  lockfile = util.path.data .. '/lazy-lock.json',
  -- CHECK: does this work & detect local plugin repos?
  dev = { path = '~/neovim_plugins', patterns = { 'dasupradyumna' }, fallback = true },
  install = { colorscheme = { 'retrobox' } },
  ui = { size = { width = 0.999, height = 0.95 }, border = 'rounded' },
})
