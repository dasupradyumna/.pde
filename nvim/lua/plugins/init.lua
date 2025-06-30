----------------------------------- SIMPLE PLUGINS CONFIGURATION -----------------------------------

return {
  {
    'dasupradyumna/midnight.nvim',
    cond = true,
    priority = 1000,
    config = function()
      local p = require('midnight.colors').palette
      local c = require('midnight.colors').components

      require('midnight').setup {
        WinBarBG = { fg = p.black, bg = c.bg },
        WinBarDiagError = { fg = c.error, bg = c.bg },
        WinBarDiagWarn = { fg = c.warn, bg = c.bg },
        WinBarDiagInfo = { fg = c.info, bg = c.bg },
        WinBarDiagHint = { fg = c.hint, bg = c.bg },
        WinBarGitNew = { fg = p.green[4], bg = c.bg },
        WinBarGitDirty = { fg = p.yellow[2], bg = c.bg },
        WinBarGitDeleted = { fg = p.red[3], bg = c.bg },
        Folded = { bg = p.gray[8] },
        SpellCap = {},
        DiagnosticUnderlineOk = {},
        DiagnosticUnderlineHint = {},
        DiagnosticUnderlineInfo = {},
        DiagnosticUnderlineWarn = {},
        DiagnosticUnderlineError = {},
        ['@lsp.type.variable.lua'] = {},
        NeoCodeiumSuggestion = { fg = c.tabsel, style = 'italic' },
        -- FIX: move to the colorscheme
        LazyReasonRequire = { link = 'Parameter' },
        MsgSeparator = { link = 'Border' },
        DiffviewDiffDelete = { fg = p.gray[7] },
        DiffviewDiffDeleteDim = { link = 'DiffviewDiffDelete' },
        ['@property.toml'] = { link = 'Parameter' }, -- to highlight/semantic/misc.lua
        ['@lsp.type.const.rust'] = { link = 'Constant' },
      }

      vim.api.nvim_command 'colorscheme midnight'
    end,
  },
  {
    'dasupradyumna/launch.nvim',
    dependencies = { 'mfussenegger/nvim-dap' },
    opts = {
      debug = {
        -- disable = true,
        adapters = { python = 'debugpy' },
        templates = {
          python = {
            request = 'launch',
            -- avoid debugpy's custom event "debugpyAttach" when starting subprocesses
            subProcess = false,
            console = 'integratedTerminal',
            cwd = vim.uv.cwd(),
            pythonPath = vim.fn.exepath 'python',
            stopOnEntry = true,
            justMyCode = false,
            showReturnValue = true,
          },
        },
      },
    },
  },
  { 'dasupradyumna/tabs.nvim', opts = {} },
  { 'dasupradyumna/ripgrep.nvim', cmd = { 'RGSearch', 'RGSearchDirectory' }, opts = {} },
}
