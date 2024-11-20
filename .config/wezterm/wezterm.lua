local wezterm = require("wezterm")

local config = {
	font = wezterm.font_with_fallback({
		{ family = "JetBrainsMono NF", weight = "Regular" },
		{ family = "MesloLGM Nerd Font" },
		"Noto Color Emoji",
	}),
	warn_about_missing_glyphs = false,
	font_size = 14,
	bold_brightens_ansi_colors = true,
	color_scheme = "tokyonight",
	window_decorations = "NONE",
	enable_wayland = true,
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	automatically_reload_config = true,
	window_background_opacity = 0.4,
	window_close_confirmation = "NeverPrompt",
	max_fps = 120,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}

-- config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
--
-- config.keys = {
-- 	{
-- 		key = "|",
-- 		mods = "LEADER|SHIFT",
-- 		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
-- 	},
-- 	{
-- 		key = "-",
-- 		mods = "LEADER",
-- 		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
-- 	},
-- 	{
-- 		key = "t",
-- 		mods = "LEADER",
-- 		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
-- 	},
-- }

return config
