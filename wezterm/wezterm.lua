local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Font
config.color_scheme = 'Tokyo Night'
config.font_size = 16
config.font = 
    wezterm.font('Maple Mono NF')

-- Window settings
config.window_background_opacity = 0.7
config.macos_window_background_blur = 20
config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'AlwaysPrompt'
config.window_padding = {
  left = 16,
  right = 16,
  top = 16,
  bottom = 16,
}
-- Tab Bar
config.hide_tab_bar_if_only_one_tab = true
config.status_update_interval = 1000
config.use_fancy_tab_bar = false
wezterm.on('update-right-status', function(window, pane)
    local ws = window:active_workspace()

    if window:active_key_table() then ws = window:active_key_table() end
    if window:leader_is_active() then ws = 'LDR' end

    function basename(s)
        return string.gsub(s, '(.*[/\\])(.*)', '%2')
    end

    local actual_process = basename(pane:get_foreground_process_name())

    window:set_right_status(wezterm.format({
        { Text = wezterm.nerdfonts.oct_table .. '  ' .. ws },
        { Text = " | " },
        { Foreground = { Color = "FFB86C" } },
        { Text = wezterm.nerdfonts.fa_code .. "  " .. actual_process },
        "ResetAttributes",
        { Text = " " },
    }))
end)

-- Keys
config.leader = { key = 'a', mods = 'CMD', timeout_milliseconds = 1000 }
config.keys = {
    {
        key = 'c',
        mods = 'LEADER',
        action = act.ActivateCopyMode
    },
    {
        key = '|',
        mods = 'LEADER|SHIFT',
        action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
        key = '-',
        mods = 'LEADER',
        action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
        key = 'h',
        mods = 'LEADER',
        action = act.ActivatePaneDirection('Left'),
    },
    {
        key = 'j',
        mods = 'LEADER',
        action = act.ActivatePaneDirection('Down'),
    },
    {
        key = 'k',
        mods = 'LEADER',
        action = act.ActivatePaneDirection('Up'),
    },
    {
        key = 'l',
        mods = 'LEADER',
        action = act.ActivatePaneDirection('Right'),
    },
    {
        key = 'x',
        mods = 'LEADER',
        action = act.CloseCurrentPane { confirm = true },
    },
    {
        key = 'z',
        mods = 'LEADER',
        action = act.TogglePaneZoomState, 
    },
    {
        key = 's',
        mods = 'LEADER',
        action = act.RotatePanes 'Clockwise', 
    },
    {
        key = 'r',
        mods = 'LEADER',
        action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false }, 
    },
    -- Tabs
    {
        key = 'n',
        mods = 'LEADER',
        action = act.SpawnTab('CurrentPaneDomain'), 
    },
    {
        key = '[',
        mods = 'LEADER',
        action = act.ActivateTabRelative(-1), 
    },
    {
        key = ']',
        mods = 'LEADER',
        action = act.ActivateTabRelative(1), 
    },
    {
        key = 't',
        mods = 'LEADER',
        action = act.ShowTabNavigator, 
    },
    {
        key = 'm',
        mods = 'LEADER',
        action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false }, 
    },
    {
        key = 'w',
        mods = 'LEADER',
        action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' }, 
    },
    -- Send "CMD-A" to the terminal when pressing CMD-A, CMD-A
    {
        key = 'a',
        mods = 'LEADER|CMD',
        action = act.SendKey { key = 'a', mods = 'CMD' },
    }
}

config.key_tables = {
  -- Defines the keys that are active in our resize-pane mode.
  -- Since we're likely to want to make multiple adjustments,
  -- we made the activation one_shot=false. We therefore need
  -- to define a key assignment for getting out of this mode.
  -- 'resize_pane' here corresponds to the name="resize_pane" in
  -- the key assignments above.
  resize_pane = {
    { key = 'LeftArrow', action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },

    { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },

    { key = 'UpArrow', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },

    { key = 'DownArrow', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },

    -- Cancel the mode by pressing escape
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'Enter', action = 'PopKeyTable' },
  },

  move_tab = {
    { key = 'LeftArrow', action = act.MoveTabRelative(-1) },
    { key = 'h', action = act.MoveTabRelative(-1) },

    { key = 'RightArrow', action = act.MoveTabRelative(-1)  },
    { key = 'l', action = act.MoveTabRelative(-1)  },

    { key = 'UpArrow', action = act.MoveTabRelative(1) }, 
    { key = 'k', action = act.MoveTabRelative(1) },

    { key = 'DownArrow', action = act.MoveTabRelative(1) },
    { key = 'j', action = act.MoveTabRelative(1) },

    -- Cancel the mode by pressing escape
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'Enter', action = 'PopKeyTable' },
  }
}

return config
