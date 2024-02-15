---------------------------------------- LUA LANGUAGE SERVER ---------------------------------------

return {
  settings = {
    Lua = {
      addonManager = { enable = false },
      completion = { callSnippet = 'Replace', keywordSnippet = 'Replace' },
      diagnostics = {
        globals = { 'vim' },
        libraryFiles = 'Disable',
        workspaceEvent = 'OnChange',
      },
      format = { enable = false },
      hint = { enable = true }, -- CHECK: do they work?
      hover = { enumsLimit = 10, expandAlias = false },
      runtime = {
        version = 'LuaJIT',
        path = vim.list_extend({ 'lua/?.lua', 'lua/?/init.lua' }, vim.split(package.path, ';')),
      },
      workspace = {
        checkThirdParty = 'Disable',
        library = vim.api.nvim_get_runtime_file('', true),
      },
    },
  },
}
