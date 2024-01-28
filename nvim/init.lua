-------------------------------------------- ENTRY POINT -------------------------------------------

--- temporary colorscheme
vim.cmd [[set tgc | colo retrobox]]

vim.cmd.source(vim.fn.stdpath 'config' .. '/viml/options.vim')
