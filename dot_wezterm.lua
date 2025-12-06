local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font_size = 14
config.font = wezterm.font 'JetBrainsMonoNL NF'

config.initial_cols = 120
config.initial_rows = 28

config.exit_behavior = 'CloseOnCleanExit'
config.window_close_confirmation = 'NeverPrompt'

config.keys = {
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
    -- Make Option-Right equivalent to Alt-f; forward-word
    {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
}

return config
