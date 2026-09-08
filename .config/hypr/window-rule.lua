--[[
    Window and workspace rules
--]]

-- Workspace rules
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, rounding = 0 })

-- Window rules to keep borders and rounding at 0 for extra cleanliness
hl.window_rule({ match = { workspace = "w[tv1]" }, border_size = 0, rounding = 0 })
hl.window_rule({ match = { workspace = "w[tv1-100]" }, border_size = 0, rounding = 0 })
hl.window_rule({ match = { workspace = "f[1]" }, border_size = 0, rounding = 0 })

-- Application-specific rules
hl.window_rule({ match = { title = "Blanket" }, float = true })
hl.window_rule({ match = { title = ".*zoom.*" }, float = true })
hl.window_rule({ match = { title = "blueman" }, float = true })

-- File dialogs / popups
hl.window_rule({ match = { class = "^(qalculate-gtk)$" }, float = true })

-- Discord updater
hl.window_rule({ match = { class = "^(discord)$", title = "^(Discord Updater)$" }, float = true })

-- Ghostty inspector
hl.window_rule({ match = { title = "^(ghostty: Terminal Inspector)$" }, float = true })

-- KDE Connect Daemon
hl.window_rule({ match = { title = ".*(KDE Connect Daemon)$" }, float = true })

-- Show Me The Key
hl.window_rule({ match = { title = "^(Show Me The Key)$" }, float = true })
hl.window_rule({
	match = { title = "^(Floating Window - Show Me The Key)$" },
	float = true,
	size = "1305 168",
	move = "621 886",
	pin = true,
})

-- Picture-in-Picture
hl.window_rule({
	match = { title = "^(Picture-in-Picture|Firefox|Picture in picture)$" },
	float = true,
	size = "640 376",
	move = "1261 55",
	pin = true,
})
