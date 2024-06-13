local wezterm = require 'wezterm'

-- switches between the argument values based on system OS
local function win_linux(windows_value, linux_value)
  return wezterm.target_triple == 'x86_64-pc-windows-msvc' and windows_value or linux_value
end

local config = {}

-- core
config.default_prog = { win_linux([[C:\Program Files\PowerShell\7\pwsh.exe]], '/usr/bin/bash') }
config.exit_behavior = 'CloseOnCleanExit'
config.exit_behavior_messaging = 'Terse'
config.automatically_reload_config = true

-- font
config.font_dirs = { 'fonts' }
config.font_locator = 'ConfigDirsOnly'
config.font = wezterm.font 'Hermit'
config.font_size = 11.5
config.underline_position = -4
config.allow_square_glyphs_to_overflow_width = 'Never'
config.anti_alias_custom_block_glyphs = false

-- colors
config.force_reverse_video_cursor = true
config.color_scheme_dirs = { 'colors' }
config.color_scheme = 'Midnight'

-- windows
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_decorations = 'RESIZE'
wezterm.on('update-status', function(window)
  local palette = window:effective_config().resolved_palette

  window:set_left_status(wezterm.format {
    { Attribute = { Intensity = 'Bold' } },
    { Foreground = { Color = palette.tab_bar.active_tab.fg_color } },
    { Background = { Color = palette.tab_bar.active_tab.bg_color } },
    { Text = ('  %s '):format(wezterm.hostname():upper()) },
  })

  window:set_right_status(wezterm.format {
    { Foreground = { Color = palette.ansi[5] } },
    { Text = ('%s '):format(wezterm.strftime '%H:%M %a %d %b %Y') },
  })
end)

-- tabs
config.show_new_tab_button_in_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_max_width = 25
config.use_fancy_tab_bar = false
wezterm.on('format-tab-title', function(tab)
  local title_format = tab.is_active and ' %s ' or '  %s  '
  return title_format:format(tab.active_pane.foreground_process_name:match '^.+/(.*)$')
end)

-- panes
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.8 } -- CHECK:

-- keybindings
-- config.disable_default_mouse_bindings = true

return config
