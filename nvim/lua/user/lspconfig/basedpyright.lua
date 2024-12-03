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
          reportMissingTypeArgument = 'none',
          reportMissingTypeStubs = 'none',
          reportUnknownArgumentType = 'none',
          reportUnknownLambdaType = 'none',
          reportUnknownMemberType = 'none',
          reportUnknownParameterType = 'none',
          reportUnknownVariableType = 'none',
          reportUnusedCallResult = 'none',
          -- WARN
          reportAssignmentType = 'warning',
          reportUnusedFunction = 'warning',
          reportUnusedImport = 'warning',
          reportUnusedParameter = 'warning',
          reportUnusedVariable = 'warning',
        },
        -- exclude = {},
        extraPaths = { vim.uv.cwd() },
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
