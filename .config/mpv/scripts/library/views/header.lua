-- Top bar of the grid and the Files tab: "Library", the tabs and the search box.
local app = require 'app'
local canvas = require 'canvas'
local actions = require 'actions'

local header = {}

local C, MARGIN = canvas.colors, canvas.MARGIN
local BAR_Y, BAR_H = 30, 38
local SEARCH_W = 300

header.SEARCH_HINT = 'type to filter     Enter done     Esc clear'

-- Returns the x where the tabs end
local function draw_tabs(c)
    local x = MARGIN + 120
    for i, section in ipairs(app.sections) do
        local active = i == app.ui.sec
        local w = #section.name * 9 + 28
        if active then c:box(x, BAR_Y, w, BAR_H, C.text) end
        c:text(x + w / 2, BAR_Y + BAR_H / 2, section.name, {
            size = 16, align = 'center', bold = active, color = active and C.background or C.muted,
        })
        c:on_click(x, BAR_Y, w, BAR_H, function() actions.show_tab(i) end)
        x = x + w + 8
    end
    return x
end

-- The box sits at the right but never over the tabs: on narrow windows it shrinks, and
-- when there's no room it's left out and the search shows as a line under the bar.
local function draw_search(c, tabs_end)
    local ui = app.ui
    local x = math.max(c.w - MARGIN - SEARCH_W, tabs_end + 16)
    local w = c.w - MARGIN - x
    local cursor = ui.searching and '|' or ''
    if w >= 48 then
        c:box(x, BAR_Y, w, BAR_H, C.field)
        if ui.searching then c:frame(x, BAR_Y, w, BAR_H, C.accent) end
        local placeholder = ui.searching and '' or 'Search  ( / )'
        local label = ui.search ~= '' and ui.search or placeholder
        c:text(x + 12, BAR_Y + BAR_H / 2, label .. cursor, {
            align = 'left', color = ui.search ~= '' and C.text or C.muted, clip = w - 20,
        })
        c:on_click(x, BAR_Y, w, BAR_H, actions.start_search)
    elseif ui.search ~= '' or ui.searching then
        c:text(c.w - MARGIN, 100, 'search: ' .. ui.search .. cursor, { size = 14, align = 'top-right', color = C.accent })
    end
end

function header.draw(c)
    c:text(MARGIN, 34, 'Library', { size = 26, bold = true })
    draw_search(c, draw_tabs(c))
end

return header
