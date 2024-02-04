local wezterm = require 'wezterm'

-- switches between the argument values based on system OS
local function win_linux(windows_value, linux_value)
  return wezterm.target_triple == 'x86_64-pc-windows-msvc' and windows_value or linux_value
end

local config = {}

-- core
config.default_prog = { win_linux([[C:\Program Files\PowerShell\7\pwsh.exe]], '/usr/bin/zsh') }
config.exit_behavior = 'CloseOnCleanExit'
config.exit_behavior_messaging = 'Terse'
config.automatically_reload_config = false

-- tabs
config.show_new_tab_button_in_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true
config.use_fancy_tab_bar = false

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

-- windows
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_decorations = 'RESIZE'

-- keybindings
-- config.disable_default_mouse_bindings = true


return config
