--[[
    Hyprland 0.55+ Lua Configuration
    Main file – loads all modules
--]]

-- Environment variables
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Monitor
hl.monitor({
    output = "",                     -- auto-detect
    mode = "1920x1080@60",
    position = "0x0",
    scale = "1.0",
})

-- Blur layer rules
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true })
hl.layer_rule({ match = { namespace = "lockscreen" }, blur = true })

-- Load configuration modules (order doesn't matter much)
require("variables")     -- global settings, decorations, animations, etc.
require("startup")       -- exec-once commands
require("keybinds")      -- all key bindings
require("window-rule")   -- window rules and workspace rules
