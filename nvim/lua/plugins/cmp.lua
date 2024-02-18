------------------------------------------ AUTOCOMPLETION ------------------------------------------

---checks if the character preceding the cursor is text or whitespace
---@return boolean
local function is_preceding_character_text()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  return not (col == 0 or vim.api.nvim_get_current_line():sub(col, col):match '%s')
end

local map_item = {
  source = {
    buffer = 'BUF │',
    path = 'PTH │',
    nvim_lsp = 'LSP │',
    luasnip = 'SNP │',

    nvim_lsp_signature_help = '',
  },
  type = {
    Class = ' CLS',
    Color = ' CLR',
    Constant = ' CON',
    Constructor = ' CTR',
    Enum = ' ENM',
    EnumMember = ' ENM',
    Event = ' EVT',
    Field = ' FLD',
    File = ' FIL',
    Folder = ' FOL',
    Function = ' FUN',
    Interface = ' INT',
    Keyword = ' KEY',
    Method = ' MTH',
    Module = ' MOD',
    Operator = ' OPR',
    Property = ' PRP',
    Reference = ' REF',
    Snippet = ' SNP',
    Struct = ' STR',
    Text = ' TXT',
    TypeParameter = ' TYP',
    Unit = ' UNT',
    Value = ' VAL',
    Variable = ' VAR',
  },
}

return {
  {
    'L3MON4D3/LuaSnip',
    lazy = true,
    config = function()
      local luasnip = require 'luasnip'
      local function isnoremap(lhs, rhs)
        vim.keymap.set({ 'i', 's' }, lhs, rhs, { silent = true, noremap = true, nowait = true })
      end

      isnoremap('<C-F>', function() luasnip.jump(1) end)
      isnoremap('<C-B>', function() luasnip.jump(-1) end)
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'VeryLazy',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require 'cmp'

      -- overall autocompletion engine setup
      cmp.setup {
        mapping = {
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<C-U>'] = cmp.mapping.scroll_docs(-4),
          ['<C-D>'] = cmp.mapping.scroll_docs(4),
          ['<C-J>'] = function(fallback)
            _ = cmp.confirm() or (is_preceding_character_text() and cmp.complete() or fallback())
          end,
          ['<C-Q>'] = function() _ = cmp.abort() or cmp.complete() end,
        },
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        completion = { keyword_length = 2 },
        formatting = {
          expandable_indicator = true,
          fields = { 'menu', 'abbr', 'kind' },
          format = function(entry, item)
            item.menu = map_item.source[entry.source.name] or entry.source.name
            item.abbr = vim.trim(item.abbr):sub(1, 40)
            item.kind = item.menu == '' and ' ' or map_item.type[item.kind]
            return item
          end,
        },
        sources = { -- CHECK: entry_filter attribute for a source
          { name = 'luasnip', priority = 10 },
          { name = 'nvim_lsp', priority = 5 },
          { name = 'nvim_lsp_signature_help', priority = 5 },
          { name = 'buffer', priority = 1 },
          { name = 'path', option = { trailing_slash = true }, priority = 1 },
        },
        window = {
          completion = {
            border = 'rounded',
            zindex = 100,
            scrolloff = 4,
            col_offset = 4,
            winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
          },
          documentation = {
            border = 'rounded',
            zindex = 100,
            scrolloff = 4,
            max_width = 60,
            max_height = 20,
            winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
          },
        },
      }

      -- command line autocompletion setup
      local common_config = {
        mapping = {
          ['<Tab>'] = { c = cmp.mapping.select_next_item() },
          ['<S-Tab>'] = { c = cmp.mapping.select_prev_item() },
          ['<C-J>'] = { c = function() _ = cmp.confirm() or cmp.complete() end },
        },
        formatting = { fields = { 'abbr' }, format = function(_, item) return item end },
      }
      local search_config = vim.deepcopy(common_config)
      search_config.sources = { { name = 'buffer' } }
      cmp.setup.cmdline('/', search_config)
      local cmdline_config = vim.deepcopy(common_config)
      cmdline_config.sources = {
        { name = 'cmdline', option = { ignore_cmds = { 'Man', '!' } } },
        { name = 'path', option = { trailing_slash = true } },
      }
      cmp.setup.cmdline(':', cmdline_config)
    end,
  },
}
