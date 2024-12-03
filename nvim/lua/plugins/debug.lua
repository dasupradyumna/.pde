-------------------------------------- DEBUG ADAPTER PROTOCOL --------------------------------------

local adapter_config = {
  python = {
    type = 'executable',
    command = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python',
    args = { '-m', 'debugpy.adapter' },
  },
}

local function nnoremap(lhs, rhs, args)
  ---@diagnostic disable-next-line: redefined-local
  local rhs = args and function() rhs(args) end or rhs
  vim.keymap.set('n', lhs, rhs)
end

local function nunmap(lhs) vim.keymap.del('n', lhs) end

return {
  {
    'mfussenegger/nvim-dap',
    -- lazy = true,
    config = function()
      local dap = require 'dap'
      dap.set_log_level 'TRACE'

      for lang, adapter in pairs { python = 'debugpy' } do
        dap.adapters[adapter] = adapter_config[lang]
      end

      -- global keymaps
      nnoremap('<leader>dbb', dap.toggle_breakpoint)
      nnoremap(
        '<leader>dbc',
        function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end
      )
      nnoremap(
        '<leader>dbh',
        function() dap.set_breakpoint(nil, vim.fn.input 'Breakpoint hit number: ') end
      )
      nnoremap(
        '<leader>dbl',
        function() dap.set_breakpoint(nil, nil, vim.fn.input 'Breakpoint log message: ') end
      )
      nnoremap('<leader>dbL', function()
        dap.list_breakpoints()
        vim.cmd.copen()
        -- util.tele.quickfix()
      end, '(dap) list breakpoints')
      nnoremap('<leader>dbC', dap.clear_breakpoints)

      -- session local debug keymaps
      local in_session = false
      dap.listeners.after.event_initialized.debug_map_keys = function()
        in_session = true
        nnoremap('<leader>dc', dap.continue)
        nnoremap('<leader>dp', dap.pause)
        nnoremap('<leader>dn', dap.step_over)
        nnoremap('<leader>di', dap.step_into)
        nnoremap('<leader>do', dap.step_out)
        nnoremap('<leader>dt', dap.terminate)
        nnoremap('<leader>dr', dap.restart)
        nnoremap('<leader>dsu', dap.up)
        nnoremap('<leader>dsd', dap.down)
      end
      local function debug_unmap_keys()
        if in_session then
          nunmap '<leader>dc'
          nunmap '<leader>dp'
          nunmap '<leader>dn'
          nunmap '<leader>di'
          nunmap '<leader>do'
          nunmap '<leader>dt'
          nunmap '<leader>dsu'
          nunmap '<leader>dsd'

          in_session = false
        end
      end
      dap.listeners.after.disconnect.debug_unmap_keys = debug_unmap_keys
      dap.listeners.after.event_exited.debug_unmap_keys = debug_unmap_keys
      dap.listeners.after.event_terminated.debug_unmap_keys = debug_unmap_keys
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    -- lazy = true,
    keys = { { '<leader>dl', '<Cmd>LaunchDebugger<CR>' } },
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
    config = function()
      local M = {}
      local dapui = require 'dapui'
      dapui.setup {
        icons = { expanded = '', collapsed = '', current_frame = '' },
        layouts = {
          {
            elements = { { id = 'scopes', size = 0.6 }, { id = 'watches', size = 0.4 } },
            size = 0.25,
            position = 'left',
          },
          {
            elements = { 'console' },
            size = 0.3,
            position = 'bottom',
          },
          {
            elements = { 'repl' },
            size = 0.25,
            position = 'right',
          },
          {
            elements = { { id = 'stacks', size = 0.5 }, { id = 'breakpoints', size = 0.5 } },
            size = 0.2,
            position = 'right',
          },
        },
        floating = { border = 'rounded', max_width = 60, max_height = 20 },
        controls = { enabled = false },
        render = { indent = 2, max_value_lines = 500 },
      }

      -- configure UI windows on startup / exit and session local UI keymaps
      local dap = require 'dap'
      local in_session = false
      dap.listeners.after.event_initialized.dapui_init_layout = function()
        in_session = true
        dapui.open { layout = 1 }
        dapui.open { layout = 2 }
        M.visible = true
        nnoremap('<leader>duv', M.element_toggler(1))
        nnoremap('<leader>duc', M.element_toggler(2))
        nnoremap('<leader>dur', M.element_toggler(3))
        nnoremap('<leader>dus', M.element_toggler(4))
        nnoremap('<leader>dut', M.toggle_layout)
      end
      local function dapui_clear_layout()
        if in_session then
          dapui.close { layout = 1 }
          dapui.close { layout = 3 }
          dapui.close { layout = 4 }
          nunmap '<leader>duv'
          nunmap '<leader>duc'
          nunmap '<leader>dur'
          nunmap '<leader>dus'
          nunmap '<leader>dut'

          in_session = false
        end
      end
      dap.listeners.after.disconnect.dapui_clear_layout = dapui_clear_layout
      dap.listeners.after.event_exited.dapui_clear_layout = dapui_clear_layout
      dap.listeners.after.event_terminated.dapui_clear_layout = dapui_clear_layout
      ---------------------------------------------------------------------------

      local layouts = require('dapui.windows').layouts

      ---indicates whether UI elements are visible
      ---@type boolean
      M.visible = false

      ---generates a toggler function for individual `dapui` layout elements
      ---@param id number `dapui` layout ID
      ---@return function # toggler function for layout `id`
      function M.element_toggler(id)
        if id > #layouts then
          vim.notify(
            'utils/dapui.lua:element_toggler: invalid `id` value, returning empty function',
            vim.log.levels.WARN
          )
          return function() end
        end
        return function()
          if M.visible then dapui.toggle { layout = id, reset = true } end
        end
      end

      ---caches the visible DAP UI window IDs
      ---@type table<number, boolean>
      M.open_win_ids = {}

      ---toggles the visibility of the `dapui` layout as a whole
      function M.toggle_layout()
        for id = #layouts, 1, -1 do
          if M.visible and layouts[id]:is_open() then
            M.open_win_ids[id] = true
            dapui.close { layout = id }
          elseif not M.visible and M.open_win_ids[id] then
            M.open_win_ids[id] = false
            dapui.open { layout = id, reset = true }
          end
        end
        M.visible = not M.visible
      end
      ---------------------------------------------------------------------------
    end,
  },
}
