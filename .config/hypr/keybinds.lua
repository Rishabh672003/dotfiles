--[[
    Keybindings for Hyprland 0.55+ — Final version using official API stubs
--]]

-- -----------------------------------------------------------
-- 1. Workspace navigation (focus)
-- -----------------------------------------------------------
hl.bind("SUPER + comma", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + SHIFT + comma", hl.dsp.focus({ workspace = "+1" }))

-- -----------------------------------------------------------
-- 2. Launchers and scripts
-- -----------------------------------------------------------
hl.bind("SUPER + Space", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("vicinae vicinae://launch/clipboard/history"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/waybar.sh"))
hl.bind("SUPER + M", hl.dsp.exec_cmd("vicinae vicinae://launch/@Rishabh/media-player-control/index"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("vicinae vicinae://launch/core/search-emojis"))
hl.bind("SUPER + I", hl.dsp.exec_cmd("pkill rofi || ~/.config/hypr/scripts/kaomoji.sh"))
hl.bind("SUPER + SHIFT + I", hl.dsp.exec_cmd("pkill rofi || rofi -modi nerdy -show nerdy"))
hl.bind("SUPER + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/hyprpicker.sh"))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("~/.config/hypr/scripts/books-search.sh"))
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("~/.config/hypr/scripts/lock.sh"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/wf-recorder.sh"))

-- -----------------------------------------------------------
-- 3. Media keys
-- -----------------------------------------------------------
hl.bind("XF86Display", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("XF86WLAN", hl.dsp.exec_cmd("pkexec systemctl restart NetworkManager && dunstify 'NetworkManager restarted'"))
hl.bind("XF86NotificationCenter", hl.dsp.exec_cmd("~/.config/hypr/scripts/dunst.sh"))
hl.bind("XF86PickupPhone", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86HangupPhone", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86Favorites", hl.dsp.exec_cmd("playerctl -a play-pause"))

-- -----------------------------------------------------------
-- 4. Volume and brightness
-- -----------------------------------------------------------
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -q set +5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -q set 5%-"))

-- -----------------------------------------------------------
-- 5. Window management
-- -----------------------------------------------------------
hl.bind("SUPER + Q", hl.dsp.window.close({ window = "activewindow" }))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))

hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("foot"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("webcord --enable-features=UseOzonePlatform --ozone-platform=wayland --uri=%U"))
hl.bind("SUPER + G", hl.dsp.exec_cmd("evince"))
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd("foliate"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("qalculate-gtk"))
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())

hl.bind("SUPER + Escape", hl.dsp.exec_cmd("pkill wlogout || wlogout"))
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("mocp -P"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("nemo"))
hl.bind("SUPER + S", hl.dsp.exec_cmd("AppimageLauncher ~/Applications/YouTube-Music-3.7.5.AppImage"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("showmethekey-gtk"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("firefox --private-window"))
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("pavucontrol"))

-- Toggle float + pin together
hl.bind("SUPER + O", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.pin())
end)

-- -----------------------------------------------------------
-- 6. System
-- -----------------------------------------------------------
hl.bind("SUPER + SHIFT + J", hl.dsp.exec_cmd("reboot"))
hl.bind("SUPER + SHIFT + K", hl.dsp.exec_cmd("shutdown now"))

-- -----------------------------------------------------------
-- 7. Screenshots
-- -----------------------------------------------------------
hl.bind("Print", function()
    hl.exec_cmd("hyprctl keyword animation 'fadeOut,0,0,default'")
    hl.exec_cmd("grimblast --notify copysave area")
    hl.exec_cmd("hyprctl keyword animation 'fadeOut,1,4,default'")
end)
hl.bind("ALT + Print", hl.dsp.exec_cmd("grimblast --notify --cursor copysave screen"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | tesseract --oem 1 -l eng - - | wl-copy"))

-- -----------------------------------------------------------
-- 8. Scratchpad (special workspace)
-- -----------------------------------------------------------
-- Move window to special workspace (raw dispatcher – no Lua equivalent)
hl.bind("SUPER + S", hl.dsp.exec_raw("movetoworkspace, special"))
-- Toggle special workspace visibility
hl.bind("SUPER + A", hl.dsp.workspace.toggle_special())

-- -----------------------------------------------------------
-- 9. Focus movement (direction)
-- -----------------------------------------------------------
hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))

-- -----------------------------------------------------------
-- 10. Move windows around the layout
-- -----------------------------------------------------------
hl.bind("SUPER + Left",  hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + Down",  hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + Up",    hl.dsp.window.move({ direction = "u" }))

-- -----------------------------------------------------------
-- 11. Go to any workspace (focus) and move window to workspace
-- -----------------------------------------------------------
for i = 1, 10 do
    local key = (i == 10) and "0" or tostring(i)
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
end

-- -----------------------------------------------------------
-- 12. Mouse bindings
-- -----------------------------------------------------------
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })   -- drag to move
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true }) -- drag to resize

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e+1" }))

-- -----------------------------------------------------------
-- 13. Tab / group management
-- -----------------------------------------------------------
hl.bind("SUPER + B", hl.dsp.group.toggle())
hl.bind("SUPER + TAB", hl.dsp.group.next())

-- -----------------------------------------------------------
-- 14. Resize active window
-- -----------------------------------------------------------
hl.bind("SUPER + Z", hl.dsp.window.resize({ x = -40, y = 0 }))
hl.bind("SUPER + X", hl.dsp.window.resize({ x = 40, y = 0 }))

-- -----------------------------------------------------------
-- 15. Layout switching
-- -----------------------------------------------------------
hl.bind("SUPER + N", function()
    hl.config({ general = { layout = "master" } })
end)
hl.bind("SUPER + SHIFT + N", function()
    hl.config({ general = { layout = "dwindle" } })
end)
