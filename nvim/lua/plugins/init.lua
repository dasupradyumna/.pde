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
        WinBarBG = { fg = p.black, bg = c.bg },
        Folded = { bg = p.gray[8] },
        -- FIX: move to the colorscheme
        LazyReasonRequire = { link = 'Parameter' },
        MsgSeparator = { link = 'Border' },
        DiffviewDiffDeleteDim = { fg = p.gray[7] },
      }

      vim.cmd.colorscheme 'midnight'
    end,
  },
}
