--------------------------------------- WEZTERM CONFIGURATION --------------------------------------

local wezterm = require 'wezterm'

-- Debug logging for wezterm
DEBUG_WEZTERM = false
function DEBUG(...)
  if DEBUG_WEZTERM then wezterm.log_info(...) end
end

-- switches between the argument values based on system OS
local function win_linux(windows_value, linux_value)
  return wezterm.target_triple == 'x86_64-pc-windows-msvc' and windows_value or linux_value
end

local config = wezterm.config_builder()

-- config.scrollback_lines = 100000

-- core
config.default_prog = { win_linux([[C:\Program Files\PowerShell\7\pwsh.exe]], '/usr/bin/bash') }
config.exit_behavior = 'CloseOnCleanExit'
config.exit_behavior_messaging = 'Brief'
config.automatically_reload_config = true

-- font
config.font_dirs = { 'fonts' }
config.font_locator = 'ConfigDirsOnly'
config.font = wezterm.font 'Hermit'
config.font_size = 9
config.underline_position = -4
-- config.allow_square_glyphs_to_overflow_width = 'Never'
config.anti_alias_custom_block_glyphs = false

-- colors
config.force_reverse_video_cursor = true
config.color_scheme_dirs = { 'colors' }
config.color_scheme = 'Midnight'

-- windows
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_decorations = 'NONE'
wezterm.on('update-status', function(window) -- window: GuiWin
  local palette = window:effective_config().resolved_palette

  window:set_left_status(wezterm.format {
    { Attribute = { Intensity = 'Bold' } },
    { Foreground = { Color = palette.tab_bar.active_tab.fg_color } },
    { Background = { Color = palette.tab_bar.active_tab.bg_color } },
    { Text = ('  %s '):format(wezterm.hostname():upper()) },
  })

  window:set_right_status(wezterm.format {
    { Foreground = { Color = palette.ansi[5] } },
    { Text = ('%s '):format(wezterm.strftime '%H:%M:%S %a %d %b %Y') },
  })
end)

-- tabs
config.show_new_tab_button_in_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_max_width = 25
config.use_fancy_tab_bar = false
wezterm.on('format-tab-title', function(tab)
  DEBUG(
    ('tab_title:[%s] is_active:[%s] pane_title:[%s] foreground_process_name:[%s] cwd:[%s] domain_name:[%s]'):format(
      tab.tab_title,
      tab.is_active,
      tab.active_pane.title,
      tab.active_pane.foreground_process_name,
      tab.active_pane.current_working_dir,
      tab.active_pane.domain_name
    )
  )

  local title = tab.tab_title
  if #title == 0 then
    title = tab.active_pane.domain_name
    title = title ~= 'local' and title or tab.active_pane.title
  end
  local title_format = tab.is_active and ' %s ' or '  %s  '
  return title_format:format(title)
end)

-- panes
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.7 }

-- keybindings
-- config.disable_default_mouse_bindings = true
-- add keymap to close current pane
config.keys = {
  {
    key = 'D',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ShowLauncherArgs {
      flags = 'FUZZY|DOMAINS',
      fuzzy_help_text = 'Filter domains: ',
    },
  },
}

-- domains
-- FIX: exec domain does not set tab title
config.exec_domains = require('exec_domains').docker()

return config
