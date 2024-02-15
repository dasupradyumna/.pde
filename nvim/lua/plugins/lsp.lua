------------------------------------- LANGUAGE SERVER PROTOCOL -------------------------------------

return {
  -- TODO: add code to automatically install required tools on first startup
  {
    'williamboman/mason.nvim',
    opts = {
      max_concurrent_installers = 8,
      ui = {
        border = 'rounded',
        width = 0.99,
        height = 0.95,
        icons = { package_installed = '', package_pending = '', package_uninstalled = '󰜺' },
        keymaps = { uninstall_package = 'x' },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      local lspconfig = require 'lspconfig'

      lspconfig.util.default_config = vim.tbl_extend('force', lspconfig.util.default_config, {
        -- make hover and signature help floating windows rounded
        handlers = {
          ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
          ['textDocument/signatureHelp'] = vim.lsp.with(
            vim.lsp.handlers.signature_help,
            { border = 'rounded' }
          ),
        },
        on_attach = function(_, bufnr)
          local function nnoremap(lhs, rhs, opts)
            ---@diagnostic disable-next-line: redefined-local
            local rhs = opts and function() rhs(opts) end or rhs
            vim.keymap.set('n', lhs, rhs, { noremap = true, nowait = true, buffer = bufnr })
          end

          nnoremap('gd', vim.lsp.buf.definition, { reuse_win = true })
          nnoremap('gD', vim.lsp.buf.declaration, { reuse_win = true })
          nnoremap('gh', vim.lsp.buf.signature_help)
          nnoremap('gH', vim.lsp.buf.hover)
          nnoremap('gn', vim.diagnostic.goto_next)
          nnoremap('gN', vim.diagnostic.goto_prev)
          nnoremap('gr', vim.lsp.buf.rename)
          nnoremap('gR', vim.lsp.buf.references)
          nnoremap('gs', vim.lsp.buf.document_symbol)
        end,
      })

      -- TODO: lazy start language servers based on filetype
      local supported = { 'lua_ls' }
      for _, lsp in ipairs(supported) do
        lspconfig[lsp].setup(require('user.lspconfig.' .. lsp))
      end

      vim.lsp.set_log_level 'WARN'

      -- make LspInfo floating window bordered
      require('lspconfig.ui.windows').default_options.border = 'rounded'
    end,
  },
}
