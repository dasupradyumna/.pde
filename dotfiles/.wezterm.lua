local wezterm = require 'wezterm'

local config = {}

-- initialization
config.default_prog = { [[C:\Program Files\PowerShell\7\pwsh.exe]] }
config.automatically_reload_config = true

-- font
config.font = wezterm.font 'Hurmit Nerd Font Mono'
config.font_size = 11.0

-- window
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

return config
