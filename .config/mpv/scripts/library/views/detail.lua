-- A title's page: its thumbnail, name and play buttons on the left, its files on the right.
local app = require 'app'
local fs = require 'fs'
local canvas = require 'canvas'
local history = require 'history'
local playback = require 'playback'
local nav = require 'nav'
local actions = require 'actions'

local detail = {}

local C, MARGIN = canvas.colors, canvas.MARGIN
local TOP = 84
local ROW_H = 48

local function draw_side_panel(c, title, last, panel_w)
    c:box(0, 0, panel_w, c.h, C.panel)
    c:text(MARGIN, 50, '<  ' .. nav.section().name, { align = 'left', color = C.muted })
    c:on_click(MARGIN, 30, 160, 40, function() app.ui.view = 'grid' end)

    local poster_w = panel_w - MARGIN - 32
    local poster_h = poster_w * 9 / 16
    c:poster(title, MARGIN, TOP, poster_w, poster_h)

    local y = TOP + poster_h + 24
    c:text(MARGIN, y, title.name, { size = 26, bold = true, clip = panel_w - MARGIN - 24 })
    c:text(MARGIN, y + 38, #title.files .. ' files', { size = 14, color = C.muted })

    local x, buttons_y = MARGIN, y + 72
    if last then
        local label = 'Resume ' .. fs.index_of(title.files, last)
        x = c:button(x, buttons_y, label, true, function() playback.play(title.files, last) end)
    end
    -- Play all wraps to a second row when the panel is too narrow for both buttons
    if x + canvas.button_width('Play all') > panel_w - 24 then
        x, buttons_y = MARGIN, buttons_y + 52
    end
    c:button(x, buttons_y, 'Play all', not last, function() playback.play(title.files, title.files[1]) end)
end

-- Scroll so the selected episode is on screen
local function scroll_to_selection(rows)
    local ui = app.ui
    if ui.ep - 1 < ui.ep_top then
        ui.ep_top = ui.ep - 1
    elseif ui.ep > ui.ep_top + rows then
        ui.ep_top = ui.ep - rows
    end
end

local function draw_episode(c, i, file, x, y, w, last_index)
    local selected = i == app.ui.ep
    local middle = y + ROW_H / 2 - 2
    if selected then
        c:box(x, y, w, ROW_H - 4, C.selected)
        c:frame(x, y, w, ROW_H - 4, C.accent, 2)
    end
    -- files before the last played one are dimmed as watched
    local watched = last_index and i < last_index and not selected
    local is_last = i == last_index
    c:text(x + 16, middle, ('%02d'):format(i), { size = 14, align = 'left', color = C.muted })
    c:text(x + 60, middle, fs.basename(file), {
        align = 'left', color = watched and C.dim or C.text, clip = w - (is_last and 180 or 76),
    })
    if is_last then c:text(x + w - 16, middle, 'last played', { size = 13, align = 'right', color = C.accent }) end
    c:on_click(x, y, w, ROW_H, function() actions.click_item(i) end)
end

local function draw_episodes(c, title, last, x)
    local ui = app.ui
    local w = c.w - x - 32
    c:text(x, 50, 'EPISODES', { size = 13, align = 'left', color = C.muted })
    local rows = math.max(1, math.floor((c.h - TOP - 40) / ROW_H))
    scroll_to_selection(rows)
    local last_index = last and fs.index_of(title.files, last)
    for i = ui.ep_top + 1, math.min(#title.files, ui.ep_top + rows) do
        draw_episode(c, i, title.files[i], x, TOP + (i - 1 - ui.ep_top) * ROW_H, w, last_index)
    end
end

function detail.draw(c)
    local title = app.ui.title
    local last = history.last_played(title)
    local panel_w = math.min(440, c.w * 0.4)
    draw_side_panel(c, title, last, panel_w)
    draw_episodes(c, title, last, panel_w + 32)
    c:hint('Enter play from here     r resume     p play all     i info     Backspace back     Ctrl+r refresh     Esc close')
end

return detail
