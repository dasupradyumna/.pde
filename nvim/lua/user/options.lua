----------------------------------------- BUILTIN OPTIONS ------------------------------------------

local set = vim.opt

-------------------------- NAVIGATION-SEARCH-PATTERNS --------------------------

set.whichwrap = 'h,l,<,>,[,]'
set.startofline = true
set.cdhome = true
set.ignorecase = true
set.smartcase = true

--------------------------------- TEXT-DISPLAY ---------------------------------

set.scrolloff = 4
set.wrap = false
set.sidescrolloff = 4
set.display:append 'uhex'
set.fillchars = 'diff:╱,eob: '  -- TODO: add fold*, msgsep
set.list = true
set.listchars = 'tab:──,trail:·,extends:~,precedes:~'
set.number = true
set.numberwidth = 2

---------------------------- SYNTAX-HIGHLIGHT-SPELL ----------------------------

set.cursorline = true  -- TODO: move this to an autocommand
set.colorcolumn = '+1'
set.spell = true
----------- HACK: spellfile ------------
local config_path = vim.fn.stdpath 'config'
-- excluding the Drive specifier (C:) fixes the argument error for spellfile
if vim.fn.has 'win32' == 1 then config_path = config_path:sub(3) end
set.spellfile = config_path .. '/spell/en.utf-8.add'
--------------- EndHACK ----------------
set.spelloptions:append 'camel'

----------------------------------- WINDOWS ------------------------------------

set.splitbelow = true
set.splitright = true

-------------------------------- MESSAGES-INFO ---------------------------------

set.shortmess = 'aoOsIcCF'
set.report = 0
set.verbosefile = vim.fn.stdpath 'data' .. '/verbose.txt'
set.confirm = true

--------------------------------- TEXT-SELECT ----------------------------------

set.selectmode = 'key'
set.keymodel = 'startsel,stopsel'

---------------------------------- TEXT-EDIT -----------------------------------

set.textwidth = 100
set.backspace:append 'nostop'
set.formatoptions = 'tcro/qn1j'
set.complete = ''
set.completeopt = ''
set.matchpairs:append '<:>'

---------------------------------- TAB-INDENT ----------------------------------

set.tabstop = 4
set.shiftwidth = 0
set.expandtab = true
