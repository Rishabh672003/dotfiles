-- Subtitle sync: a bar above uosc's seekbar (Alt+s) that shows every subtitle line on a
-- timeline under the playhead, with the speech waveform below, so the lines can be dragged
-- onto the speech. Settings: script-opts/subsync.conf
--
-- Files in this folder:
--   settings.lua   options
--   tracks.lua     the selected subtitle / audio track, where ffmpeg can read it
--   cues.lua       every line's start and end time (ffmpeg / ffprobe, cached)
--   waveform.lua   voice-band loudness around the playhead (ffmpeg)
--   sync.lua       changing the delay, "line starts now", saving an .srt
--   canvas.lua     drawing
--   strip.lua      the bar itself
local mp = require 'mp'
local settings = require 'settings'
local canvas = require 'canvas'
local cues = require 'cues'
local waveform = require 'waveform'
local sync = require 'sync'
local strip = require 'strip'

local osd = mp.create_osd_overlay('ass-events')
osd.z = 2000 -- above uosc

local is_open = false
local frame -- the last drawn canvas, for mouse clicks
local strip_top -- where the bar starts, in canvas units
local drag -- while the mouse button is held on the timeline: called with each mouse x

-- uosc's timeline sits under the bar; uosc scales it by 1.3 in fullscreen and by the display's DPI
local function bottom_margin_px()
    local fullscreen = mp.get_property_bool('fullscreen', false)
    return settings.bottom * (fullscreen and 1.3 or 1) * mp.get_property_number('display-hidpi-scale', 1)
end

--[[ subtitles move up while the bar is open, so they aren't hidden behind it ]]

local saved_sub_pos

local function lift_subtitles(top)
    if saved_sub_pos == nil then saved_sub_pos = mp.get_property_number('sub-pos', 100) end
    local pos = math.floor(100 * (top - 6) / canvas.HEIGHT)
    if mp.get_property_number('sub-pos', 100) ~= pos then mp.set_property_number('sub-pos', pos) end
end

local function restore_subtitles()
    if saved_sub_pos then mp.set_property_number('sub-pos', saved_sub_pos) end
    saved_sub_pos = nil
end

--[[ drawing ]]

local function render()
    if not is_open then return end
    local size = mp.get_property_native('osd-dimensions') or {}
    if (size.w or 0) == 0 or (size.h or 0) == 0 then return end
    local c = canvas.new(size.w, size.h)
    strip_top = c.h - bottom_margin_px() / c.scale_y - strip.HEIGHT
    lift_subtitles(strip_top)
    strip.draw(c, strip_top)
    c:show(osd)
    frame = c
end

cues.on_loaded = render
waveform.on_loaded = render

-- The playhead moves, so redraw continuously while open
local redraw_timer = mp.add_periodic_timer(1 / 30, render)
redraw_timer:kill()

--[[ keys and mouse ]]

local bound = {}

-- Bindings are grouped by name prefix so a group can be removed together
local function bind(group, key, fn, flags)
    local name = 'subsync-' .. group .. '-' .. key
    mp.add_forced_key_binding(key, name, fn, flags or { repeatable = true })
    bound[name] = true
end

local function unbind(group)
    local prefix = 'subsync-' .. group .. '-'
    for name in pairs(bound) do
        if name:sub(1, #prefix) == prefix then
            mp.remove_key_binding(name)
            bound[name] = nil
        end
    end
end

local function on_mouse_button(event)
    if event.event == 'up' then
        drag = nil
    elseif frame and (event.event == 'down' or event.event == 'press') then
        local mouse = mp.get_property_native('mouse-pos') or {}
        local drag_fn = mouse.x and frame:click(mouse.x, mouse.y)
        drag = event.event == 'down' and drag_fn or nil -- 'press' is a click without a hold
    end
    render()
end

local function zoom(factor)
    strip.zoom(factor)
    render()
end

-- The bar takes the mouse only while the pointer is over it (or dragging), so uosc's
-- seekbar below keeps working
local mouse_bound = false

local function update_mouse_bindings(mouse)
    local over_bar = false
    if frame and strip_top and mouse and mouse.y then
        local _, y = frame:to_units(mouse.x or 0, mouse.y)
        over_bar = y >= strip_top and y <= strip_top + strip.HEIGHT
    end
    local want = over_bar or drag ~= nil
    if want and not mouse_bound then
        bind('mouse', 'MBTN_LEFT', on_mouse_button, { complex = true })
        bind('mouse', 'MBTN_LEFT_DBL', function() end)
        bind('mouse', 'WHEEL_UP', function() zoom(0.8) end)
        bind('mouse', 'WHEEL_DOWN', function() zoom(1.25) end)
    elseif not want and mouse_bound then
        unbind('mouse')
    end
    mouse_bound = want
end

mp.observe_property('mouse-pos', 'native', function(_, mouse)
    if not is_open then return end
    if drag and mouse and mouse.x then
        drag((frame:to_units(mouse.x, mouse.y)))
        render()
    end
    update_mouse_bindings(mouse)
end)

--[[ open / close ]]

local saved_window_dragging

local function close()
    if not is_open then return end
    is_open, drag, mouse_bound = false, nil, false
    redraw_timer:kill()
    unbind('keys')
    unbind('mouse')
    restore_subtitles()
    mp.set_property_bool('window-dragging', saved_window_dragging)
    osd:remove()
    mp.commandv('script-message-to', 'uosc', 'disable-elements', mp.get_script_name(), '')
end

local function open()
    is_open = true
    mp.commandv('script-message-to', 'uosc', 'disable-elements', mp.get_script_name(), 'controls,volume,top_bar,speed')
    -- mpv turns a held, moving left button into window dragging and cancels the click,
    -- which would end every drag on the timeline
    saved_window_dragging = mp.get_property_bool('window-dragging', true)
    mp.set_property_bool('window-dragging', false)
    bind('keys', 'ESC', close)
    bind('keys', 'ENTER', sync.snap)
    bind('keys', 'KP_ENTER', sync.snap)
    bind('keys', 'Ctrl+BS', sync.reset)
    bind('keys', 'Ctrl+s', sync.save_srt)
    redraw_timer:resume()
    render()
end

mp.add_key_binding('Alt+s', 'timeline', function()
    if is_open then close() else open() end
end)
mp.observe_property('osd-dimensions', 'native', render)
