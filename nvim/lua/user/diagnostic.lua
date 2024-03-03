-------------------------------------------- DIAGNOSTICS -------------------------------------------

local pretty_source = {
  ['Lua Diagnostics.'] = 'lua_ls',
  ['Lua Syntax Check.'] = 'lua_ls',
}

vim.diagnostic.config {
  virtual_text = {
    virt_text_pos = 'right_align',
    spacing = 0,
    prefix = '',
  },
  signs = false,
  float = {
    focusable = false,
    border = 'rounded',
    header = '',
    source = false,
    format = function(diag)
      return ('%s: %s [%s]'):format(
        pretty_source[diag.source] or diag.source,
        diag.message,
        diag.code
      )
    end,
    prefix = ' ',
    suffix = ' ',
  },
  update_in_insert = true,
  severity_sort = true,
}
