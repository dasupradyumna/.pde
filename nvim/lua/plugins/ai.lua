----------------------------------------------------------------------------------------------------

return {
  {
    'monkoose/neocodeium',
    cond = true,
    config = function()
      local nc = require 'neocodeium'
      nc.setup {
        show_label = false,
      }

      -- Customize the key mappings
      local function map(key, func, ...)
        local args = { ... }
        local callback = function() return nc[func](unpack(args)) end
        vim.keymap.set('i', key, callback, { expr = true, silent = true, nowait = true })
      end
      map('<C-X>', 'clear')
      map('<C-A>', 'accept')
      map('<A-w>', 'accept_word')
      map('<A-l>', 'accept_line')
      map('<A-n>', 'cycle', 1)
      map('<A-p>', 'cycle', -1)
    end,
  },
  {
    'github/copilot.vim',
    enabled = false,
    config = function()
      vim.keymap.set(
        'i',
        '<C-g>',
        function() return vim.fn['copilot#Accept']() end,
        { expr = true, silent = true }
      )
      vim.keymap.set(
        'i',
        '<c-x>',
        function() return vim.fn['copilot#Clear']() end,
        { expr = true, silent = true }
      )
    end,
  },
}
