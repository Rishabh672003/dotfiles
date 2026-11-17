-- A tab's titles as a grid of 16:9 thumbnails (Continue, Movies, Series, ...).
local app = require 'app'
local fs = require 'fs'
local canvas = require 'canvas'
local history = require 'history'
local nav = require 'nav'
local actions = require 'actions'
local header = require 'views.header'

local grid = {}

local C, MARGIN = canvas.colors, canvas.MARGIN
local TOP = 100
local GAP = 24
local MIN_TILE_W = 260
local CAPTION_H = 64 -- name and caption under each thumbnail

-- "12 files", "12 files  ·  resume", or on the Continue tab "resume 3 of 12"
local function caption(title, on_continue_tab)
    local count = #title.files > 1 and (#title.files .. ' files') or ''
    local last = history.last_played(title)
    if not last then return count end
    if on_continue_tab then
        if #title.files == 1 then return 'resume' end
        return ('resume %d of %d'):format(fs.index_of(title.files, last), #title.files)
    end
    return count .. (count ~= '' and '  ·  ' or '') .. 'resume'
end

-- Columns and tile size that fill the page width
local function layout(c)
    local width = c.w - 2 * MARGIN
    local cols = math.max(2, math.min(8, math.floor((width + GAP) / (MIN_TILE_W + GAP))))
    local tile_w = (width - (cols - 1) * GAP) / cols
    local tile_h = tile_w * 9 / 16
    local rows = math.max(1, math.floor((c.h - TOP - 40) / (tile_h + CAPTION_H)))
    return cols, rows, tile_w, tile_h
end

-- Scroll so the selected row is on screen
local function scroll_to_selection(rows, cols)
    local ui = app.ui
    local row = math.floor((ui.sel - 1) / cols)
    if row < ui.top then
        ui.top = row
    elseif row >= ui.top + rows then
        ui.top = row - rows + 1
    end
end

local function draw_tile(c, i, title, x, y, w, h, on_continue_tab)
    local selected = i == app.ui.sel
    if selected then c:frame(x, y, w, h, C.accent, 3) end
    c:poster(title, x, y, w, h)
    c:text(x, y + h + 10, title.name, { bold = selected, clip = w })
    c:text(x, y + h + 32, caption(title, on_continue_tab), { size = 13, color = C.muted })
    c:on_click(x, y, w, h + 50, function() actions.click_item(i) end)
end

function grid.draw(c)
    local ui = app.ui
    local section = nav.section()
    local items = nav.items()
    ui.sel = math.max(1, math.min(ui.sel, #items))

    local cols, rows, tile_w, tile_h = layout(c)
    ui.cols = cols
    scroll_to_selection(rows, cols)

    local first = ui.top * cols + 1
    for i = first, math.min(#items, first + rows * cols - 1) do
        local slot = i - first
        local x = MARGIN + (slot % cols) * (tile_w + GAP)
        local y = TOP + math.floor(slot / cols) * (tile_h + CAPTION_H)
        draw_tile(c, i, items[i], x, y, tile_w, tile_h, section.resume)
    end

    if #items == 0 then c:message(ui.search ~= '' and 'No matches' or 'Nothing here yet') end
    if ui.searching then
        c:hint(header.SEARCH_HINT)
    else
        c:hint('arrows / hjkl move     Enter ' .. (section.resume and 'resume' or 'open')
            .. '     r resume     i info     / search     Tab section     Ctrl+r refresh     Esc close')
    end
end

return grid
