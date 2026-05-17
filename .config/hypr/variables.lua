hl.config({
    misc = {
        disable_hyprland_logo = true,
    },
    general = {
        layout = "master",
        gaps_in = 4,
        gaps_out = 4,
        border_size = 0,
        col = {
            active_border = "0xFF5E81AC",
            inactive_border = "0x66333333",
        },
    },
    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
        },
    },
    input = {
        kb_layout = "us",
        kb_options = "caps:escape",
        repeat_rate = 50,
        repeat_delay = 240,
        follow_mouse = 1,
        float_switch_override_focus = true,
        sensitivity = 0.1,
        touchpad = {
            disable_while_typing = 1,
            natural_scroll = 1,
            clickfinger_behavior = 1,
            middle_button_emulation = 1,
            tap_to_click = 1,
        },
    },
    -- Dwindle and master belong inside hl.config, not as separate functions
    dwindle = {
        force_split = 2,
    },
    master = {
        mfact = 0.50,
        new_on_top = false,
    },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace"
})

-- Custom curves (unchanged)
hl.curve("overshot",   { type = "bezier", points = { {0.05, 0.1}, {0.1, 1.05} } })
hl.curve("smoothOut",  { type = "bezier", points = { {0.36, 0}, {0.66, -0.56} } })
hl.curve("smoothIn",   { type = "bezier", points = { {0.25, 1}, {0.5, 1} } })

-- Animations – use "bezier" / "spring" instead of "curve"
hl.animation({ leaf = "windows",      enabled = true, speed = 5,  bezier = "overshot",  style = "slide" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 4,  bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 4,  bezier = "default" })
hl.animation({ leaf = "border",       enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade",         enabled = true, speed = 10, bezier = "smoothIn" })
hl.animation({ leaf = "fadeDim",      enabled = true, speed = 10, bezier = "smoothIn" })
hl.animation({ leaf = "workspaces",   enabled = true, speed = 6,  bezier = "default" })
