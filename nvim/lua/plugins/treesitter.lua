------------------------------------------ NVIM-TREESITTER -----------------------------------------

return {
  'nvim-treesitter/nvim-treesitter',
  lazy = true,
  build = ':TSUpdate', -- update treesitter parsers along with the plugin
  config = function()
    require('nvim-treesitter.configs').setup { ---@diagnostic disable-line: missing-fields
      auto_install = false,
      -- parser options
      ensure_installed = {
        'bash',
        'c',
        'cmake',
        'cpp',
        'cuda',
        'json',
        'lua',
        'make',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'rust',
        'toml',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
      },
      -- module options
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<Tab>',
          node_decremental = '<S-Tab>',
          scope_incremental = '<CR>',
        },
      },
    }

    -- enable folding using treesitter nodes
    vim.o.foldmethod = 'expr'
    vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.o.foldlevelstart = 99
  end,
}
