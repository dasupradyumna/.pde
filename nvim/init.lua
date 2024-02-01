-------------------------------------------- ENTRY POINT -------------------------------------------

--- temporary colorscheme
vim.cmd [[set tgc | colo retrobox]]

local util = require 'util'

util.vim_source 'options'
util.vim_source 'keymaps'
