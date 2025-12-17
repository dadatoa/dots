-- WezTerm Keybindings Documentation by dragonlobster
-- ===================================================
-- Leader Key:
-- The leader key is set to ALT + q, with a timeout of 2000 milliseconds (2 seconds).
-- To execute any keybinding, press the leader key (ALT + q) first, then the corresponding key.

-- Keybindings:
-- 1. Tab Management:
--    - LEADER + c: Create a new tab in the current pane's domain.
--    - LEADER + x: Close the current pane (with confirmation).
--    - LEADER + b: Switch to the previous tab.
--    - LEADER + n: Switch to the next tab.
--    - LEADER + <number>: Switch to a specific tab (0–9).

-- 2. Pane Splitting:
--    - LEADER + | or $: Split the current pane horizontally into two panes.
--    - LEADER + -: Split the current pane vertically into two panes.

-- 3. Pane Navigation:
--    - LEADER + h: Move to the pane on the left.
--    - LEADER + j: Move to the pane below.
--    - LEADER + k: Move to the pane above.
--    - LEADER + l: Move to the pane on the right.

-- 4. Pane Resizing:
--    - LEADER + LeftArrow: Increase the pane size to the left by 5 units.
--    - LEADER + RightArrow: Increase the pane size to the right by 5 units.
--    - LEADER + DownArrow: Increase the pane size downward by 5 units.
--    - LEADER + UpArrow: Increase the pane size upward by 5 units.

-- 5. Status Line:
--    - The status line indicates when the leader key is active, displaying an ocean wave emoji (🌊).

-- Miscellaneous Configurations:
-- - Tabs are shown even if there's only one tab.
-- - The tab bar is located at the bottom of the terminal window.
-- - Tab and split indices are zero-based.

-- Pull in the wezterm API
local wezterm = require("wezterm")
-- local mux = wezterm.mux
local act = wezterm.action
-- This will hold the configuration.
local config = wezterm.config_builder()

-- bigger window at startup
config.initial_rows = 48
config.initial_cols = 150

wezterm.on("gui-startup", function(cmd)
	local screen = wezterm.gui.screens().main
	local ratio = 0.9
	local width, height = screen.width * ratio, screen.height * ratio
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {
		position = { x = (screen.width - width) / 2, y = (screen.height - height) / 2 },
	})
	-- window:gui_window():maximize()
	window:gui_window():set_inner_size(width, height)
end)

-- smart workspace switcher
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

-- This is where you actually apply your config choices

workspace_switcher.apply_to_config(config)

config.front_end = "WebGpu"

config.set_environment_variables = {
  PATH = "/opt/homebrew/bin:/run/current-system/sw/bin:" .. os.getenv("PATH"),
  XDG_CONFIG_HOME = os.getenv("HOME") .. "/.config",
}

-- For example, changing the color scheme:
config.color_scheme = "Catppuccin Frappe"
config.window_background_opacity = 0.8

-- config.font = wezterm.font("Cousine Nerd Font Mono")

config.font_size = 17

config.window_decorations = "RESIZE"

-- Spawn a nu shell in login mode
config.default_prog = { 'nu' }

------------------
-- keymaps--
------------------

-- timeout_milliseconds defaults to 1000 and can be omitted
config.leader = { key = 's', mods = 'CMD', timeout_milliseconds = 1500 }
config.keys = {
  { key = 'X', mods = 'CTRL', action = wezterm.action.ActivateCopyMode },

  -- split horizontally
  {
    key = '|',
    mods = 'LEADER',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '$',
    mods = 'LEADER',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },

  -- split vertically
  {
    key = '-',
    mods = 'LEADER',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- mode resize
  {
    key = 'r',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
      name = 'resize_pane',
      one_shot = false,
    },
  },

  -- Switch to a monitoring workspace, which will have `top` launched into it
  {
    key = 'u',
    mods = 'LEADER',
    action = act.SwitchToWorkspace {
      name = 'monitoring',
      spawn = {
        args = { 'top' },
      },
    },
  },

  {
    key = "s",
    mods = "LEADER",
    action = workspace_switcher.switch_workspace(),
  },

  {
    key = '9',
    mods = 'ALT',
    action = act.ShowLauncherArgs { flags = 'DOMAINS|FUZZY' },
  },

  -- Create a new workspace with a random name and switch to it
  { key = 'i', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace },

  -- lauch editor on config file
  {
    key = ",",
    mods = "SUPER",
    action = act.SpawnCommandInNewWindow({
      cwd = os.getenv("WEZTERM_CONFIG_DIR"),
      args = { os.getenv("SHELL"), "-c", "$EDITOR $WEZTERM_CONFIG_FILE" },
    }),
  },

}



-- tab bar
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
-- config.tab_and_split_indies_are_zero_based = true

-- tmux status
wezterm.on("update-right-status", function(window, _)
  local SOLID_LEFT_ARROW = ""
  local ARROW_FOREGROUND = { Foreground = { Color = "#c6a0f6" } }
  local prefix = ""

  if window:leader_is_active() then
    prefix = " " .. utf8.char(0x1f30a) -- ocean wave
    SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  end

  if window:active_tab():tab_id() ~= 0 then
    ARROW_FOREGROUND = { Foreground = { Color = "#b7bdf8" } }
  end -- arrow color based on if tab is first pane

  window:set_left_status(wezterm.format {
    { Background = { Color = "#1e2030" } },
    { Text = prefix },
    ARROW_FOREGROUND,
    { Text = SOLID_LEFT_ARROW }
  })
end)

-------------------------------
--- MULTIPLEXER
--- ---------------------------

config.ssh_domains = {
  {
    name = 'xen_mgt',
    remote_address = 'xen',
    username = 'root',
    default_prog = { 'bash' },
    -- multiplexing = 'None',
    -- default_prog = { 'shpool', 'attach', 'main' },
    -- assume_shell = 'Posix'
  }
}

config.unix_domains = {
  {
    name = 'test',
    proxy_command = { 'ssh', 'root@xen' }
  }
}

-- and finally, return the configuration to wezterm
return config
