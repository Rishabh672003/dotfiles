local W = require'wezterm'

-- @param direction string horizontal, vertical, h, v
local function split(direction)
    direction = string.lower(direction):sub(1, 1)
    if direction == 'v' then
        return W.action{SplitVertical={domain='CurrentPaneDomain'}}
    elseif direction == 'h' then
        return W.action{SplitHorizontal={domain='CurrentPaneDomain'}}
    end
    return nil
end

local function kb(key, mods, action)
    return { key = key, mods = mods, action = action }
end

local bg_orig = '#232326'
local bg      = '#1c1c1f'
local dim_bg  = '#2c2d31'
local fg      = '#dcdfe4'
local dim_fg  = '#5a5b5e'
local hl_bg   = dim_fg
local accent  = '#61afef'
-- sizes can be int or string in units of cell, pt, px or %
local border_size = 0
local padding_size = border_size

local angular_tab = {
    inner = {
        active = {
            bg = hl_bg,
            fg = fg,
        },
        inactive = {
            bg = dim_bg,
            fg = dim_fg,
        },
    },
    left = {
        active = {
            text = '',
            bg = bg,
            fg = hl_bg,
        },
        inactive = {
            text = '',
            bg = bg,
            fg = dim_bg,
        },
    },
    right = {
        active = {
            text = '',
            bg = bg,
            fg = hl_bg,
        },
        inactive = {
            text = '',
            bg = bg,
            fg = dim_bg,
        },
    }
}
local startline_tab = {
    inner = {
        active = {
            bg = hl_bg,
            fg = fg,
        },
        inactive = {
            bg = dim_bg,
            fg = dim_fg,
        },
    },
    left = {
        active = {
            text = '▍',
            bg = hl_bg,
            fg = accent,
        },
        inactive = {
            text = '▏',
            bg = dim_bg,
            fg = fg,
        },
    },
    right = {
        active = {
            text = '',
            bg = hl_bg,
            fg = accent,
        },
        inactive = {
            text = '',
            bg = bg,
            fg = dim_bg,
        },
    }
}

local mtab = angular_tab
W.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    if tab.is_active then
        return {
            { Background = { Color = mtab.left.active.bg } },
            { Foreground = { Color = mtab.left.active.fg } },
            { Text = mtab.left.active.text },
            { Background = { Color = mtab.inner.active.bg } },
            { Foreground = { Color = mtab.inner.active.fg } },
            { Text = '  ' .. tab.active_pane.title .. '  ' },
            { Background = { Color = mtab.right.active.bg } },
            { Foreground = { Color = mtab.right.active.fg } },
            { Text = mtab.right.active.text },
        }
    else
        return {
            { Background = { Color = mtab.left.inactive.bg } },
            { Foreground = { Color = mtab.left.inactive.fg } },
            { Text = mtab.left.inactive.text },
            { Background = { Color = mtab.inner.inactive.bg } },
            { Foreground = { Color = mtab.inner.inactive.fg } },
            { Text = '  ' .. tab.active_pane.title .. '  ' },
            { Background = { Color = mtab.right.inactive.bg } },
            { Foreground = { Color = mtab.right.inactive.fg } },
            { Text = mtab.right.inactive.text },
        }
    end
end)

local theme = W.get_builtin_color_schemes()['OneHalfDark']
theme.background = bg
theme.tab_bar = { background = bg }
theme.tab_bar.new_tab = {
    bg_color = mtab.inner.inactive.bg,
    fg_color = mtab.inner.inactive.fg,
}
theme.tab_bar.new_tab_hover = {
    bg_color = mtab.inner.active.bg,
    fg_color = mtab.inner.active.fg,
}

local font = W.font_with_fallback({
    'JetBrainsMono Nerd Font',
    'Noto Color Emoji'
})
local bold_font = W.font_with_fallback({
    {
        family = 'JetBrainsMono Nerd Font',
        weight = "Bold"
    },
    'Noto Color Emoji'
})

return {
    hide_tab_bar_if_only_one_tab = false,
    use_fancy_tab_bar = false,
    color_schemes = { ['GabMus'] = theme },
    color_scheme = 'GabMus',
    window_background_opacity = 0.9,
    font = font,
    font_size = 12.0,
    harfbuzz_features = {
        -- set all to 0 to disable ligatures
        'calt=1', 'clig=1', 'liga=1'
    },
    default_cursor_style = 'BlinkingUnderline',
    keys = {
        kb('%', 'CTRL|SHIFT', split('h')),
        kb('$', 'CTRL|SHIFT', split('v')),
    },
    mouse_bindings = {
        {
            event = { Down = { streak = 1, button = 'Left' } },
            mods = 'NONE',
            action = W.action.ClearSelection,
        },
    },
    window_decorations = 'TITLE | RESIZE',
    window_frame = {
        font = bold_font,
        font_size = 12.0,

        active_titlebar_bg = bg,
        active_titlebar_fg = fg,
        inactive_titlebar_bg = dim_bg,
        inactive_titlebar_fg = dim_fg,
        inactive_titlebar_border_bottom = bg,
        active_titlebar_border_bottom = bg,
        button_bg = bg,
        button_fg = fg,
        button_hover_bg = hl_bg,
        button_hover_fg = fg,

        border_left_width = border_size,
        border_right_width = border_size,
        border_bottom_height = border_size,
        border_top_height = border_size,
        border_left_color = bg,
        border_right_color = bg,
        border_bottom_color = bg,
        border_top_color = bg,
    },
    window_padding = {
        top = padding_size,
        right = padding_size,
        bottom = padding_size,
        left = padding_size,
    },
    use_resize_increments = true,
    -- right_status = {
    --     { Background = { Color = bg } },
    --     { Text = '[ 󰘠 ] [ 󰘡 ]' },
    -- }
    custom_block_glyphs = true,
}
