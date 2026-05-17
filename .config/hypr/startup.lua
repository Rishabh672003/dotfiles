--[[
    Startup commands – runs once after Hyprland is ready
--]]

hl.on("hyprland.start", function()
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE QT_QPA_PLATFORMTHEME")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("sh /home/rishabh/.config/hypr/scripts/launch.sh")

    -- wallpaper
    hl.exec_cmd("swaybg -i ~/Pictures/Wallpapers/wallpapers/main_image_star-forming_region_carina_nircam_final-5mb.jpg")
    -- hl.exec_cmd("mpvpaper -vs -o 'no-audio loop' eDP-1 ~/Videos/video-wallpapers/Rain-28236.mp4")
    -- hl.exec_cmd("wpaperd -d")

    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("/usr/lib/kdeconnectd")
    hl.exec_cmd("~/.config/hypr/scripts/max-volume-100.sh")
    hl.exec_cmd("vicinae server")
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    -- hl.exec_cmd("hyprpanel")
    hl.exec_cmd("kdeconnect-indicator")
    hl.exec_cmd("wlsunset -S 7:00 -s 21:00")
    hl.exec_cmd("sh ~/projects/qbit.sh")
    hl.exec_cmd("swayidle -w before-sleep '~/.config/hypr/scripts/lock.sh'")
    hl.exec_cmd("playerctld daemon")
    hl.exec_cmd("wl-paste -t text --watch clipman store -P --histpath='~/.local/share/clipman-primary.json'")
    hl.exec_cmd("ssh-agent -s")
    hl.exec_cmd("sleep 10 && qbittorrent")
end)
