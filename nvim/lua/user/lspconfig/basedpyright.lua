------------------------------------------- BASED-PYRIGHT ------------------------------------------

return {
  settings = {
    basedpyright = {
      disableLanguageServices = false,
      disableOrganizeImports = true,
      disableTaggedHints = false,
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = false,
        diagnosticMode = 'openFilesOnly',
        diagnosticSeverityOverrides = {
          -- NONE
          reportAny = 'none',
          reportImplicitStringConcatenation = 'none',
          reportMissingParameterType = 'none',
          -- INFO
          reportUnknownArgumentType = 'information',
          reportUnknownParameterType = 'information',
          reportUnknownVariableType = 'information',
          -- WARN
          reportUnusedImport = 'warning',
          reportUnusedCallResult = 'warning',
        },
        -- exclude = {},
        -- extraPaths = {},
        -- ignore = {},
        -- include = {},
        -- logLevel = 'Information',
        -- stubPath = '',
        typeCheckingMode = 'all',
        -- typeshedPaths = {},
        useLibraryCodeForTypes = true,
      },
    },
  },
}
