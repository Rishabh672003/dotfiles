-- Drawing for the library's views.
--
-- A canvas collects one frame: ASS drawing commands for mpv's OSD plus the areas that
-- react to clicks. Views lay out in a space 720 units tall (and as wide as the window's
-- shape allows), so the same numbers work at any window size: the OSD scales it up.
local app = require 'app'
local fs = require 'fs'
local posters = require 'posters'

local canvas = {}

canvas.MARGIN = 56 -- page margin on the left and right
canvas.HEIGHT = 720

canvas.colors = {
    background = '0e0f12',
    panel = '15171b',
    field = '1a1c21',
    selected = '23262c',
    border = '3a3d44',
    text = 'ecebe6',
    file = 'c9c8c2',
    dim = '8a8983',
    muted = 'a3a29c',
    accent = app.opts.accent,
}
local C = canvas.colors

-- Placeholder tile colours, until a title's thumbnail exists
local TILE_COLORS = { '3b4a5c', '5c4a3b', '4a5c3b', '5c3b45', '3b5c58', '2f4660', '4d3b5c', '5c553b', '5c3b3b' }

-- Text anchor: which point of the text sits at (x, y)
local ANCHOR = { ['top-left'] = 7, top = 8, ['top-right'] = 9, left = 4, center = 5, right = 6 }

-- ASS writes colours as BBGGRR
local function ass_color(rrggbb)
    return rrggbb:sub(5, 6) .. rrggbb:sub(3, 4) .. rrggbb:sub(1, 2)
end

local function ass_escape(s)
    return (s:gsub('\\', '\\\239\187\191'):gsub('{', '\\{'):gsub('\n', ' '))
end

local Canvas = {}
Canvas.__index = Canvas

-- A new empty frame for a window of px_w x px_h pixels
function canvas.new(px_w, px_h)
    local width = math.floor(px_w * canvas.HEIGHT / px_h)
    return setmetatable({
        w = width,
        h = canvas.HEIGHT,
        scale_x = px_w / width,  -- pixels per unit
        scale_y = px_h / canvas.HEIGHT,
        cover_x = math.huge,     -- thumbnails are cut off here (see Canvas:poster)
        events = {},
        click_areas = {},
        next_overlay_id = 0,
    }, Canvas)
end

function Canvas:add(event)
    self.events[#self.events + 1] = event
end

-- A filled rectangle. alpha is ASS hex: '00' opaque .. 'FF' invisible.
function Canvas:box(x, y, w, h, color, alpha)
    self:add(('{\\an7\\pos(%.2f,%.2f)\\bord0\\shad0\\1c&H%s&\\1a&H%s&\\p1}m 0 0 l %.2f 0 %.2f %.2f 0 %.2f{\\p0}')
        :format(x, y, ass_color(color), alpha or '00', w, w, h, h))
end

-- An outline just outside the rectangle x, y, w, h
function Canvas:frame(x, y, w, h, color, thickness)
    local t = thickness or 1
    self:box(x - t, y - t, w + 2 * t, t, color)
    self:box(x - t, y + h, w + 2 * t, t, color)
    self:box(x - t, y, t, h, color)
    self:box(x + w, y, t, h, color)
end

-- style fields (all optional):
--   size    font size, default 15
--   color   default colors.text
--   align   one of the ANCHOR names, default 'top-left'
--   bold
--   clip    cut the text off this many units right of x
function Canvas:text(x, y, str, style)
    style = style or {}
    local size = style.size or 15
    local clip = ''
    if style.clip then
        clip = ('\\clip(%.0f,%.0f,%.0f,%.0f)'):format(x, y - size, x + style.clip, y + size * 2)
    end
    self:add(('{\\an%d\\pos(%.2f,%.2f)\\fs%.2f\\b%d\\bord0\\shad0\\1c&H%s&%s}%s'):format(
        ANCHOR[style.align or 'top-left'], x, y, size, style.bold and 1 or 0,
        ass_color(style.color or C.text), clip, ass_escape(str)))
end

-- Run fn when the rectangle is clicked. Areas added later sit on top.
function Canvas:on_click(x, y, w, h, fn)
    self.click_areas[#self.click_areas + 1] = { x = x, y = y, w = w, h = h, fn = fn }
end

-- Run the topmost click area under the pixel position px, py
function Canvas:click(px, py)
    local x, y = px / self.scale_x, py / self.scale_y
    for i = #self.click_areas, 1, -1 do
        local area = self.click_areas[i]
        if x >= area.x and x <= area.x + area.w and y >= area.y and y <= area.y + area.h then
            area.fn()
            return
        end
    end
end

function canvas.button_width(label)
    return #label * 9 + 40
end

-- A button sized to its label. Returns the x where a button next to it can go.
function Canvas:button(x, y, label, primary, fn)
    local w, h = canvas.button_width(label), 40
    if primary then
        self:box(x, y, w, h, C.accent)
    else
        self:frame(x, y, w, h, C.border)
    end
    self:text(x + w / 2, y + h / 2, label, { align = 'center', bold = primary, color = primary and C.background or C.text })
    self:on_click(x, y, w, h, fn)
    return x + w + 12
end

-- Hint line at the bottom of the page
function Canvas:hint(str)
    self:text(canvas.MARGIN, self.h - 28, str, { size = 13, align = 'left', color = C.muted, clip = self.w - 2 * canvas.MARGIN })
end

-- A message in the middle of the page, e.g. "No matches"
function Canvas:message(str)
    self:text(self.w / 2, self.h / 2, str, { size = 18, align = 'center', color = C.muted })
end

local function first_letter(name)
    return name:gsub('^The ', ''):match('^[%z\1-\127\194-\244][\128-\191]*') or '?'
end

-- A title's thumbnail. Until it exists: a coloured tile with the title's first letter.
-- Thumbnails are overlays, drawn above all OSD drawing, so they stop at self.cover_x
-- (the edge of the info panel) instead of showing through it.
function Canvas:poster(title, x, y, w, h)
    -- round to whole pixels so the tile and the thumbnail line up exactly
    local px, py = math.floor(x * self.scale_x), math.floor(y * self.scale_y)
    local pw, ph = math.floor(w * self.scale_x), math.floor(h * self.scale_y)
    x, y, w, h = px / self.scale_x, py / self.scale_y, pw / self.scale_x, ph / self.scale_y

    local color = TILE_COLORS[tonumber(fs.hash(title.path):sub(1, 6), 16) % #TILE_COLORS + 1]
    self:box(x, y, w, h, color)
    self:text(x + w / 2, y + h / 2, first_letter(title.name), { size = 40, align = 'center', bold = true, color = 'ffffff' })

    local visible_w = math.min(pw, math.floor(self.cover_x * self.scale_x) - px)
    posters.show(self.next_overlay_id, title, px, py, pw, ph, visible_w)
    self.next_overlay_id = self.next_overlay_id + 1
end

-- Put the frame on screen
function Canvas:show(osd)
    osd.res_x, osd.res_y = self.w, self.h
    osd.data = table.concat(self.events, '\n')
    osd:update()
    posters.end_frame()
end

return canvas
