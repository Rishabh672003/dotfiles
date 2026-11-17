--[[
    Startup commands – runs once after Hyprland is ready
--]]

hl.on("hyprland.start", function()
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE QT_QPA_PLATFORMTHEME")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && systemctl --user start kcd")
    hl.exec_cmd("vellum")

    -- wallpaper
    hl.exec_cmd("swaybg -i ~/Pictures/Wallpapers/wallpapers/main_image_star-forming_region_carina_nircam_final-5mb.jpg")
    -- hl.exec_cmd("mpvpaper -vs -o 'no-audio loop' eDP-1 ~/Videos/video-wallpapers/Rain-28236.mp4")
    -- hl.exec_cmd("wpaperd -d")

    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("~/.config/hypr/scripts/max-volume-100.sh")
    hl.exec_cmd("~/.config/hypr/scripts/vicinae.sh")
    hl.exec_cmd("sleep 10 && qbittorrent")

    hl.exec_cmd("pgrep -x wlsunset || wlsunset -l 19.465622 -L 72.806099 -t 3400")
    hl.exec_cmd("wayle panel start")
    hl.exec_cmd("kcd-indicator")
end)
