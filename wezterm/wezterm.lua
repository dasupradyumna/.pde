local wezterm = require 'wezterm'

local config = {}

-- always start GUI in full screen
wezterm.on('gui-startup',function(cmd)
  local _, _, win = wezterm.mux.spawn_window(cmd or {})
  win:gui_window():toggle_fullscreen()
end)

-- core
config.default_prog = { [[C:\Program Files\PowerShell\7\pwsh.exe]] }
config.exit_behavior = 'CloseOnCleanExit'
config.exit_behavior_messaging = 'Terse'

-- tabs
config.show_new_tab_button_in_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true
-- config.use_fancy_tab_bar = false

-- font
config.font_dirs = { 'fonts' }
config.font_locator = 'ConfigDirsOnly'
config.font = wezterm.font 'Hurmit Nerd Font Mono'
config.font_size = 11.0
config.underline_position = -4

-- colors
config.force_reverse_video_cursor = true

-- windows
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_decorations = 'RESIZE'

-- keybindings
-- config.disable_default_mouse_bindings = true

return config
