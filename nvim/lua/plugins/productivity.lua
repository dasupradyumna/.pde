--------------------------------------- PRODUCTIVITY PLUGINS ---------------------------------------

local function nxomap(lhs, rhs) vim.keymap.set({ 'n', 'x', 'o' }, lhs, rhs, {}) end
local function nmap(lhs, rhs) vim.keymap.set('n', lhs, rhs, {}) end

return {
  {
    'ggandor/leap.nvim',
    cond = true,
    keys = { 'c', 'd', 'v', 'y', 'f', 'F', 't', 'T', 'S', '<C-N>', '<C-P>' },
    config = function()
      local config = require('leap').opts
      config.special_keys.next_target = '<C-N>'
      config.special_keys.prev_target = '<C-P>'
      require('leap.user').set_repeat_keys('<C-N>', '<C-P>')

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
    cond = true,
    -- FIX: lazy-loading in modes other than normal does not work
    keys = { 's', 'cs', 'cS', 'ds', 'ys', 'yss', 'yS', 'ySS', '<C-S>', '<C-g>S' },
    opts = {
      keymaps = { insert = '<C-S>', visual = 's' },
      -- TODO: change neovim builtin text objects to match this
      aliases = { r = ')', R = '(', b = { '}', ']' }, B = { '{', '[' }, s = '' },
      move_cursor = false,
    },
  },
  {
    'folke/todo-comments.nvim',
    event = 'VeryLazy',
    dependencies = 'nvim-lua/plenary.nvim',
    opts = {
      signs = false,
      keywords = {
        FIX = { icon = '󰠭 ', alt = { 'BUG', 'ISSUE', 'REMOVE' } },
        HACK = { icon = '󰈸 ', alt = { 'XXX' } },
        NOTE = { icon = '󰅺 ', alt = { 'INFO' } },
        PERF = { icon = '󰥔 ', alt = { 'OPTIM' } },
        TEST = { icon = '󰖷 ', alt = { 'CHECK' } },
        TODO = { icon = ' ', alt = { 'EXPLORE' } },
        WARN = { icon = ' ', alt = {} },
      },
    },
    config = function(_, opts)
      local todo = require 'todo-comments'
      todo.setup(opts)

      -- navigate todo items in a buffer
      nmap('[t', todo.jump_prev)
      nmap(']t', todo.jump_next)

      require('user.util').throttle.register_wrapper(
        'todo_search',
        2000,
        require('todo-comments.search').search,
        vim.fn['ui#update_todo_stats'],
        { disable_not_found_warnings = true }
      )
    end,
  },
}
