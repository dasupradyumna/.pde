----------------------------------------------------------------------------------------------------

return {
  {
    'Exafunction/windsurf.vim',
    -- enabled = false,
    config = function()
      -- Customize the key mappings
      local function map(key, func, ...)
        local args = { ... }
        local callback = function() return vim.fn['codeium#' .. func](unpack(args)) end
        vim.keymap.set('i', key, callback, { expr = true, silent = true, nowait = true })
      end
      map('<C-X>', 'Clear')
      map('<A-n>', 'CycleCompletions', 1)
      map('<A-p>', 'CycleCompletions', -1)
      map('<C-A>', 'Accept')
      map('<A-c>', 'Complete')
      map('<A-w>', 'AcceptNextWord')
      map('<A-l>', 'AcceptNextLine')

      -- Disable the default tab mapping
      vim.g.codeium_no_map_tab = true
      -- Set the idle delay for completions
      vim.g.codeium_idle_delay = 75
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
  {
    -- NOTE: Seems to be much slower than windsurf (free model)
    'supermaven-inc/supermaven-nvim',
    enabled = false,
    opts = {
      keymaps = {
        accept_suggestion = '<C-A>',
        clear_suggestion = '<C-X>',
        accept_word = '<C-G>',
      },
    },
  },
}
