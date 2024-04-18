------------------------------------- LANGUAGE SERVER PROTOCOL -------------------------------------

local mason_tools = { 'lua-language-server', 'stylua' }
local installed_lsps = { lua = 'lua_ls' }

return {
  {
    'williamboman/mason.nvim',
    lazy = true,
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
    config = function(_, opts)
      require('mason').setup(opts)

      ---installs the specified package and sets up a callback for failure
      local function install_and_check(pkg, ver)
        pkg:install(ver)
        pkg:on(
          'install:failed',
          vim.schedule_wrap(
            function(handle)
              vim.api.nvim_echo({
                { table.concat(handle.stdio.buffers.stdout), 'Warn' },
                { table.concat(handle.stdio.buffers.stderr), 'Error' },
                { '\n' },
              }, true, {})
            end
          )
        )
      end

      local registry = require 'mason-registry'
      for _, tool in ipairs(mason_tools) do
        local pkg = registry.get_package(tool)
        if not pkg:is_installed() then
          vim.schedule(function() install_and_check(pkg) end)
        else
          pkg:check_new_version(function(yes, result)
            if not yes or type(result) == 'string' then return end
            install_and_check(pkg, { version = result.latest_version })
          end)
        end
      end
    end,
  },
  {
    'neovim/nvim-lspconfig',
    ft = vim.tbl_keys(installed_lsps),
    dependencies = 'williamboman/mason.nvim',
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
          local function nnoremap(lhs, rhs, args)
            ---@diagnostic disable-next-line: redefined-local
            local rhs = args and function() rhs(args) end or rhs
            vim.keymap.set('n', lhs, rhs, { buffer = bufnr })
          end

          nnoremap('gd', vim.lsp.buf.definition, { reuse_win = true })
          nnoremap('gD', vim.lsp.buf.declaration, { reuse_win = true })
          nnoremap('gh', vim.lsp.buf.hover)
          nnoremap('gH', vim.lsp.buf.signature_help)
          nnoremap('gr', vim.lsp.buf.rename)
          nnoremap('gR', vim.lsp.buf.references)
          nnoremap('gs', vim.lsp.buf.document_symbol)
        end,
      })

      -- TODO: setup language servers lazily based on filetype
      --       currently all are setup when plugin is loaded
      for _, lsp in pairs(installed_lsps) do
        lspconfig[lsp].setup(require('user.lspconfig.' .. lsp))
      end

      vim.lsp.set_log_level 'WARN'

      -- make LspInfo floating window bordered
      require('lspconfig.ui.windows').default_options.border = 'rounded'
    end,
  },
}
