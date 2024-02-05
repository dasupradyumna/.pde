----------------------------------- SIMPLE PLUGINS CONFIGURATION -----------------------------------

return {
  {
    'dasupradyumna/midnight.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      local p = require('midnight.colors').palette
      local c = require('midnight.colors').components
      require('midnight').setup {
        WinBarBG = { fg = p.black, bg = c.bg},
        MsgSeparator = { link = 'Border' }, -- FIX: move to the colorscheme
      }

      vim.cmd.colorscheme 'midnight'
    end,
  }
}
