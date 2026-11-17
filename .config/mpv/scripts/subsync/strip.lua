-- The sync bar at the bottom of the window:
--
--   header    SUBTITLE SYNC · track · status                                  +0.80 s
--   row       ‹  −  [ timeline: subtitle lines on top, waveform below ]  +  ›
--   footer    key hints                                  Reset  [Line starts now]
--
-- The timeline shows `strip.span` seconds with the playhead fixed in the middle; dragging
-- it moves every subtitle line with the mouse.
local mp = require 'mp'
local settings = require 'settings'
local canvas = require 'canvas'
local tracks = require 'tracks'
local cues = require 'cues'
local waveform = require 'waveform'
local sync = require 'sync'

local strip = {}

strip.HEIGHT = 174
strip.span = settings.span -- seconds on the timeline; the wheel changes it

local C = canvas.colors
local PADDING = 32
local ROW_Y, ROW_H = 44, 84       -- the timeline row, from the bar's top
local LINE_Y, LINE_H = 10, 24     -- subtitle blocks, from the timeline's top
local WAVE_H = 44                 -- waveform bars grow up from the timeline's bottom
local QUIET_DB = 24               -- this far below the loudest sound in view shows as flat
local BAR_W = 3                   -- waveform bar width

local HINTS = 'drag to move     wheel zoom     Enter line starts now     z / x  ±0.1 s     Ctrl+s save .srt     Esc done'

local function format_delay(seconds)
    return (seconds >= 0 and '+' or '−') .. ('%.2f s'):format(math.abs(seconds))
end

-- What the header says next to the track name
local function status_text(sub_track, lines, audio_track)
    if not sub_track then return 'No subtitles on  ·  j to pick a track' end
    if lines.state == 'pending' then return 'Reading subtitle timings…' end
    if lines.state == 'failed' then return "Couldn't read this track's timings (local files only)" end
    local dialogue = audio_track and tracks.is_surround(audio_track) and '   ·   dialogue channel' or ''
    return 'drag the blocks onto the speech' .. dialogue
end

local function draw_header(c, top, sub_track, lines, audio_track)
    local y = top + 24
    c:text(PADDING, y, 'SUBTITLE SYNC', { size = 13, align = 'left', bold = true, color = C.accent })
    local track = sub_track and (tracks.label(sub_track) .. '      ') or ''
    c:text(PADDING + 140, y, track .. status_text(sub_track, lines, audio_track),
        { size = 13, align = 'left', color = C.muted, clip = c.w - 2 * PADDING - 280 })
    c:text(c.w - PADDING, y, format_delay(sync.delay()), { size = 20, align = 'right', bold = true })
end

-- ‹ − on the left, + › on the right. Returns the x and width left for the timeline.
local function draw_side_buttons(c, row_top)
    local y, h = row_top + 20, 44
    local x = c:button(PADDING, y, 36, h, '‹', 'dark', function() sync.jump(-1) end)
    x = c:button(x, y, 44, h, '−', 'primary', function() sync.nudge(-0.1) end)
    local timeline_x = x
    local right = c.w - PADDING - 36 - 44 - 16
    x = c:button(right + 8, y, 44, h, '+', 'primary', function() sync.nudge(0.1) end)
    c:button(x, y, 36, h, '›', 'dark', function() sync.jump(1) end)
    return timeline_x, right - timeline_x
end

-- Where things go on the timeline: time -> x, with `now` in the middle
local function make_timeline(x, y, w, now)
    local start = now - strip.span / 2
    local units_per_second = w / strip.span
    return {
        x = x, y = y, w = w, h = ROW_H,
        start = start,
        finish = start + strip.span,
        now = now,
        units_per_second = units_per_second,
        x_of = function(t) return x + (t - start) * units_per_second end,
        clip = { x, y, w, ROW_H },
    }
end

-- Small marks every second (every 5 or 10 when zoomed out), taller every 5th
local function draw_ticks(c, tl)
    local step = strip.span <= 30 and 1 or strip.span <= 90 and 5 or 10
    local marks = {}
    for t = math.floor(tl.start / step) * step, tl.finish, step do
        local tall = t % (step * 5) == 0
        marks[#marks + 1] = { tl.x_of(t), tl.y, 1, tall and 10 or 5 }
    end
    c:boxes(marks, C.border, '00', tl.clip)
end

-- Bars of voice-band loudness, scaled so the loudest sound in view is full height
local function draw_waveform(c, tl, audio_track)
    local src, map = tracks.source(audio_track)
    if not src then return end
    local centre_only = tracks.is_surround(audio_track)
    local bins_per_bar = math.max(1, math.ceil(BAR_W / (waveform.BIN * tl.units_per_second)))

    local levels, loudest = {}, -100
    local first = math.floor(math.max(0, tl.start) / waveform.BIN)
    first = first - first % bins_per_bar
    for bin = first, math.floor(tl.finish / waveform.BIN), bins_per_bar do
        local level = waveform.level(src, map, centre_only, bin, bins_per_bar)
        if level then
            levels[#levels + 1] = { bin = bin, db = level }
            loudest = math.max(loudest, level)
        end
    end

    local bars = {}
    local bottom = tl.y + tl.h - 4
    local bar_w = math.max(1, bins_per_bar * waveform.BIN * tl.units_per_second - 1)
    for _, level in ipairs(levels) do
        local strength = math.max(0, math.min(1, (level.db - loudest + QUIET_DB) / QUIET_DB))
        local h = math.max(1, strength * WAVE_H)
        bars[#bars + 1] = { tl.x_of(level.bin * waveform.BIN), bottom - h, bar_w, h }
    end
    c:boxes(bars, C.wave, '00', tl.clip)
end

-- Subtitle lines as blocks, shifted by the delay: shown ones dim accent, the one on screen
-- bright accent, upcoming ones grey. Wide enough blocks show their text.
local function draw_lines(c, tl, lines)
    local delay = sync.delay()
    local upcoming, shown, on_screen, labels = {}, {}, {}, {}
    for _, line in ipairs(lines) do
        local s, e = line.s + delay, line.e + delay
        if e > tl.start and s < tl.finish then
            local x, w = tl.x_of(s), math.max(2, (e - s) * tl.units_per_second - 2)
            local is_on_screen = s <= tl.now and tl.now <= e
            local group = is_on_screen and on_screen or (e < tl.now and shown or upcoming)
            group[#group + 1] = { x, tl.y + LINE_Y, w, LINE_H }
            if line.text ~= '' and w > 24 then
                labels[#labels + 1] = { x = x, w = w, text = line.text, on_screen = is_on_screen }
            end
        end
    end
    c:boxes(upcoming, C.line, '00', tl.clip)
    c:boxes(shown, C.accent, '99', tl.clip)
    c:boxes(on_screen, C.accent, '00', tl.clip)

    for _, label in ipairs(labels) do
        local left, right = math.max(label.x, tl.x), math.min(label.x + label.w, tl.x + tl.w)
        if right - left > 12 then
            c:text(label.x + 6, tl.y + LINE_Y + LINE_H / 2, label.text, {
                size = 12, align = 'left', color = label.on_screen and C.background or C.line_text,
                clip_box = { left, tl.y, right - 4 - left, tl.h },
            })
        end
    end
end

local function draw_timeline(c, row_top, sub_lines, audio_track)
    local x, w = draw_side_buttons(c, row_top)
    local tl = make_timeline(x, row_top, w, mp.get_property_number('time-pos', 0))
    c:box(tl.x, tl.y, tl.w, tl.h, C.panel)
    c:on_click(tl.x, tl.y, tl.w, tl.h, function(press_x)
        local start_delay = sync.delay()
        return function(mouse_x) sync.set_delay(start_delay + (mouse_x - press_x) / tl.units_per_second) end
    end)

    draw_ticks(c, tl)
    if audio_track and settings.waveform then draw_waveform(c, tl, audio_track) end
    if sub_lines.state == 'ok' then draw_lines(c, tl, sub_lines.lines) end
    c:box(tl.x + tl.w / 2 - 1.5, tl.y - 6, 3, tl.h + 12, C.accent) -- playhead
end

local function draw_footer(c, top)
    local y = top + strip.HEIGHT - 22
    c:text(PADDING, y, HINTS, { size = 12, align = 'left', color = C.muted, clip = c.w - 2 * PADDING - 300 })
    local snap_x = c.w - PADDING - 170
    c:button(snap_x - 88, y - 16, 80, 32, 'Reset', 'outline', sync.reset)
    c:button(snap_x, y - 16, 170, 32, 'Line starts now', 'light', sync.snap)
end

-- Draw the bar with its top at `top`
function strip.draw(c, top)
    c:box(0, top, c.w, strip.HEIGHT, C.background)
    c:on_click(0, top, c.w, strip.HEIGHT, function() end) -- clicks on the bar don't fall through

    local sub_track = tracks.selected('sub')
    local sub_lines = sub_track and cues.of(sub_track) or { state = 'none', lines = {} }
    local audio_track = tracks.selected('audio')

    draw_header(c, top, sub_track, sub_lines, audio_track)
    draw_timeline(c, top + ROW_Y, sub_lines, audio_track)
    draw_footer(c, top)
end

-- Mouse wheel over the bar: factor < 1 zooms in
function strip.zoom(factor)
    strip.span = math.max(6, math.min(120, strip.span * factor))
end

return strip
