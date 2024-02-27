--------------------------------------- PRODUCTIVITY PLUGINS ---------------------------------------

return {
  {
    'ggandor/leap.nvim',
    keys = { 'f', 'F', 't', 'T', 'S', '<C-N>', '<C-P>' },
    config = function()
      local config = require('leap').opts
      config.special_keys.next_target = '<C-N>'
      config.special_keys.prev_target = '<C-P>'
      require('leap.user').set_repeat_keys('<C-N>', '<C-P>')

      local function nxomap(lhs, rhs)
        vim.keymap.set({ 'n', 'x', 'o' }, lhs, rhs, { nowait = true, remap = false, silent = true })
      end
      local function nmap(lhs, rhs)
        vim.keymap.set('n', lhs, rhs, { nowait = true, remap = false, silent = true })
      end

      -- TODO: replace below with custom behavior using leap.leap() function
      nxomap('f', '<Plug>(leap-forward-to)')
      nxomap('F', '<Plug>(leap-backward-to)')
      nxomap('t', '<Plug>(leap-forward-till)')
      nxomap('T', '<Plug>(leap-backward-till)')
      nmap('S', '<Plug>(leap-from-window)')
    end,
  },
  {
    'kylechui/nvim-surround',
    keys = { 's', 'S', 'cs', 'cS', 'ds', 'ys', 'yss', 'yS', 'ySS', '<C-S>', '<C-g>S' },
    opts = {
      keymaps = { insert = '<C-S>', visual = 's', visual_line = 'S' },
      -- TODO: change neovim builtin text objects to match this
      aliases = { r = ')', R = '(', b = { '}', ']' }, B = { '{', '[' }, s = '' },
      move_cursor = false,
    },
  },
  {
    'folke/todo-comments.nvim',
    event = 'VeryLazy',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      local todo = require 'todo-comments'
      todo.setup {
        signs = false,
        keywords = {
          FIX = { icon = '󰠭 ' },
          HACK = { icon = '󰈸 ' },
          NOTE = { icon = '󰅺 ' },
          PERF = { icon = '󰥔 ' },
          TEST = { icon = '󰖷 ', alt = { 'CHECK' } },
          TODO = { icon = ' ', alt = { 'EXPLORE' } },
          WARN = { icon = ' ' },
        },
      }

      -- navigate todo items in a buffer
      vim.keymap.set('n', '[t', todo.jump_prev, { remap = false, nowait = true })
      vim.keymap.set('n', ']t', todo.jump_next, { remap = false, nowait = true })
    end,
  },
}
