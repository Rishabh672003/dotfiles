-- The Files tab: a plain folder browser.
local mp = require 'mp'
local app = require 'app'
local fs = require 'fs'
local canvas = require 'canvas'
local nav = require 'nav'
local actions = require 'actions'
local header = require 'views.header'

local files = {}

local C, MARGIN = canvas.colors, canvas.MARGIN
local TOP = 132
local ROW_H = 40

-- Scroll so the selected row is on screen
local function scroll_to_selection(rows)
    local ui = app.ui
    if ui.sel - 1 < ui.top then
        ui.top = ui.sel - 1
    elseif ui.sel > ui.top + rows then
        ui.top = ui.sel - rows
    end
end

-- The playing file, or a folder it is in
local function is_playing(entry, playing)
    if entry.is_dir then return playing:sub(1, #entry.path + 1) == entry.path .. '/' end
    return playing == entry.path
end

local function draw_row(c, i, entry, y, width, playing)
    local middle = y + ROW_H / 2 - 2
    if i == app.ui.sel then
        c:box(MARGIN, y, width, ROW_H - 4, C.selected)
        c:frame(MARGIN, y, width, ROW_H - 4, C.accent, 2)
    end
    local active = is_playing(entry, playing)
    local color = active and C.accent or (entry.is_dir and C.text or C.file)
    local name = entry.name .. (entry.is_dir and '/' or '')
    c:text(MARGIN + 16, middle, name, { align = 'left', bold = entry.is_dir, color = color, clip = width - 140 })
    if active then c:text(MARGIN + width - 16, middle, 'playing', { size = 13, align = 'right', color = C.accent }) end
    c:on_click(MARGIN, y, width, ROW_H, function() actions.click_item(i) end)
end

function files.draw(c)
    local ui = app.ui
    local items = nav.items()
    ui.sel = math.max(1, math.min(ui.sel, #items))
    ui.cols = 1

    c:text(MARGIN, 100, fs.short_path(ui.folder), { size = 14, color = C.muted, clip = c.w - 2 * MARGIN })

    local width = c.w - 2 * MARGIN
    local rows = math.max(1, math.floor((c.h - TOP - 48) / ROW_H))
    scroll_to_selection(rows)
    local playing = mp.get_property('path', '')
    for i = ui.top + 1, math.min(#items, ui.top + rows) do
        draw_row(c, i, items[i], TOP + (i - 1 - ui.top) * ROW_H, width, playing)
    end

    if #items == 0 then c:message(ui.search ~= '' and 'No matches' or 'No folders or media here') end
    if ui.searching then
        c:hint(header.SEARCH_HINT)
    else
        c:hint('Enter open / play     Left / Backspace up     Shift+Enter add to playlist     p play folder'
            .. '     i info     ~ home     / search     Ctrl+r refresh     Esc close')
    end
end

return files
