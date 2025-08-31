-------------------------------------- TERMINAL TOOL LAUNCHER --------------------------------------

local M = {}

local tab_handles = {}

local function launch_tool(tool, tabname)
  -- Check if we have a cached tab handle for this tool
  if tab_handles[tool] then
    vim.api.nvim_set_current_tabpage(tab_handles[tool])
    vim.cmd 'startinsert'
    return
  end

  -- Create a new tab
  vim.g.tabs_nvim_no_prompt = true
  vim.cmd 'tabnew'
  local new_tab = vim.api.nvim_get_current_tabpage()
  vim.api.nvim_tabpage_set_var(new_tab, 'tabs_nvim_name', tabname)
  vim.api.nvim_set_option_value('sidescrolloff', 0, { scope = 'local' })

  -- Start terminal with the tool
  vim.cmd('terminal ' .. tool)

  -- Cache the tab handle
  tab_handles[tool] = new_tab

  -- Create autocommand to clear cache when tab is closed
  vim.api.nvim_create_autocmd('TabClosed', {
    buffer = 0,
    callback = function() tab_handles[tool] = nil end,
    once = true,
  })

  -- Start insert mode
  vim.cmd 'startinsert'
end

function M.lazygit() launch_tool('lazygit', 'git') end

function M.cursor_agent() launch_tool('cursor-agent', 'cursor') end

return M
