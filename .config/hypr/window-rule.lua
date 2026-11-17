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

hl.window_rule({ match = { class = "^(qalculate-gtk)$" }, float = true })
hl.window_rule({ match = { class = "^(xdg-desktop-portal-.*)$" }, float = true, size = "1100 700", center = true })
hl.window_rule({
	match = { title = "^(Open|Open File|Open Files|Open Folder|Select Folder|Select a File|Choose Files|Save|Save As|Save File|File Upload|Import|Export).*" },
	float = true,
	center = true,
})

hl.window_rule({
	match = { class = "^(btop-float)$" },
	float = true,
	size = "1536 864",
	center = true,
	pin = true,
})

hl.window_rule({ match = { class = "^(discord)$", title = "^(Discord Updater)$" }, float = true })

hl.window_rule({ match = { title = "^(Show Me The Key)$" }, float = true })
hl.window_rule({
	match = { title = "^(Floating Window - Show Me The Key)$" },
	float = true,
	size = "1305 168",
	move = "621 886",
	pin = true,
})

hl.window_rule({
	match = { title = "^(Picture-in-Picture|Firefox|Picture in picture)$" },
	float = true,
	size = "640 376",
	move = "1261 55",
	pin = true,
})

hl.window_rule({
	match = { class = "^(org.qbittorrent.qBittorrent)$", title = "negative:^qBittorrent v.*" },
	float = true,
	center = true,
})

hl.window_rule({ match = { class = "^(DesktopEditors)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(Local)$", title = "negative:^Local$" }, float = true, center = true })

-- Chrome extension popouts open with initial title "_crx_<extension id>" (PWAs don't)
hl.window_rule({ match = { initial_title = "^(_crx_.*)$" }, float = true, center = true })

-- kcd-indicator device window
hl.window_rule({
	match = { class = "^(io.github.kcd.Indicator)$" },
	float = true,
	size = "900 720",
	center = true,
	focus_on_activate = true,
})
