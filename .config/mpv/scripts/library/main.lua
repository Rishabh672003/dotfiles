-- Library: the configured media folders as a grid of titles.
--   Alt+l   open / close        Ctrl+o  open on the Files tab
--   Opens by itself when mpv starts idle. Settings: script-opts/library.conf
--
-- Files in this folder:
--   app.lua          settings and shared state (app.ui documents the UI state)
--   fs.lua           media files, natural sorting, folder listings
--   catalog.lua      tabs and titles from the configured folders
--   history.lua      last played file per title
--   posters.lua      thumbnails (ffmpeg -> cached BGRA -> mpv overlays)
--   media_info.lua   ffprobe details and track lists for the info panel
--   playback.lua     starting playback
--   nav.lua          the current tab's items, the Files tab's folder
--   actions.lua      what keys and clicks do
--   canvas.lua       drawing
--   views/           header, grid, files (Files tab), detail (a title), info (panel)
local mp = require 'mp'
local app = require 'app'
local canvas = require 'canvas'
local catalog = require 'catalog'
local posters = require 'posters'
local nav = require 'nav'
local actions = require 'actions'
local header = require 'views.header'
local grid = require 'views.grid'
local files = require 'views.files'
local detail = require 'views.detail'
local info = require 'views.info'

local osd = mp.create_osd_overlay('ass-events')
local frame -- the last drawn canvas, for mouse clicks

--[[ drawing ]]

app.render = function()
    local ui = app.ui
    if not ui then return end
    local size = mp.get_property_native('osd-dimensions') or {}
    if (size.w or 0) == 0 or (size.h or 0) == 0 then return end

    local c = canvas.new(size.w, size.h)
    if ui.info then c.cover_x = c.w - info.width(c) end
    c:box(0, 0, c.w, c.h, canvas.colors.background)
    if ui.view == 'detail' then
        detail.draw(c)
    else
        header.draw(c)
        if nav.in_files_tab() then files.draw(c) else grid.draw(c) end
    end
    if ui.info then info.draw(c) end
    c:show(osd)
    frame = c
end

--[[ keys ]]

local function click()
    local mouse = mp.get_property_native('mouse-pos') or {}
    if frame and mouse.x then
        app.ui.searching = false
        frame:click(mouse.x, mouse.y)
    end
end

local function do_nothing() end

-- Always active
local navigation_keys = {
    UP = function() actions.move(0, -1) end,
    DOWN = function() actions.move(0, 1) end,
    LEFT = function() actions.move(-1, 0) end,
    RIGHT = function() actions.move(1, 0) end,
    WHEEL_UP = function() actions.move(0, -1) end,
    WHEEL_DOWN = function() actions.move(0, 1) end,
    MBTN_LEFT = click,
    MBTN_LEFT_DBL = do_nothing,
}

-- When not typing a search
local library_keys = {
    k = navigation_keys.UP,
    j = navigation_keys.DOWN,
    h = navigation_keys.LEFT,
    l = navigation_keys.RIGHT,
    ENTER = actions.activate,
    KP_ENTER = actions.activate,
    BS = actions.back,
    ESC = actions.escape,
    TAB = actions.next_tab,
    ['/'] = actions.start_search,
    p = actions.play_all,
    r = actions.resume,
    i = function() app.ui.info = true end,
    ['Shift+ENTER'] = actions.append,
    ['~'] = actions.go_home,
    ['Ctrl+r'] = actions.refresh,
    F5 = actions.refresh,
}

-- While typing a search (letters arrive through ANY_UNICODE, see bind_keys)
local search_keys = {
    ENTER = actions.finish_search,
    KP_ENTER = actions.finish_search,
    ESC = actions.cancel_search,
    BS = actions.erase_search_char,
}

local function on_typed(event)
    local typed = event.key_text
    if event.event ~= 'up' and typed and typed:match('^[^%c]+$') then actions.type_search(typed) end
end

local bound = {}

local function unbind_keys()
    for name in pairs(bound) do mp.remove_key_binding(name) end
    bound = {}
end

local bind_keys -- defined below; key handlers rebind after each press since the mode may change

-- Wrap a key handler: run it, then rebind and redraw (unless it closed the library)
local function handler(fn)
    return function(...)
        if not app.ui then return end
        fn(...)
        if app.ui then
            bind_keys()
            app.render()
        end
    end
end

local function bind(key, fn, flags)
    local name = 'library-' .. key
    mp.add_forced_key_binding(key, name, handler(fn), flags or { repeatable = true })
    bound[name] = true
end

bind_keys = function()
    local ui = app.ui
    unbind_keys()
    for key, fn in pairs(navigation_keys) do bind(key, fn) end
    if ui.searching then
        for key, fn in pairs(search_keys) do bind(key, fn) end
        bind('ANY_UNICODE', on_typed, { repeatable = true, complex = true })
        return
    end
    for key, fn in pairs(library_keys) do bind(key, fn) end
    if ui.info then
        for key, fn in pairs(info.keys) do bind(key, fn) end -- same names: replaces the library keys
    end
end

--[[ open / close ]]

local UOSC_HIDDEN = 'timeline,controls,volume,top_bar,speed,pause_indicator,idle_indicator'

local function hide_uosc(elements)
    mp.commandv('script-message-to', 'uosc', 'disable-elements', mp.get_script_name(), elements)
end

app.close = function()
    if not app.ui then return end
    app.ui = nil
    unbind_keys()
    posters.hide_all()
    osd:remove()
    hide_uosc('')
end

local function open()
    app.sections = catalog.scan()
    app.ui = { view = 'grid', sec = 1, sel = 1, top = 0, search = '', searching = false }
    hide_uosc(UOSC_HIDDEN)
    bind_keys()
    app.render()
end

local function toggle()
    if app.ui then app.close() else open() end
end

-- Ctrl+o (the key mpv-file-browser used) opens straight on the Files tab
local function open_files_tab()
    if not app.ui then open() end
    app.ui.search, app.ui.searching = '', false
    actions.show_tab(#app.sections)
    bind_keys()
    app.render()
end

mp.add_key_binding('Alt+l', 'open', toggle)
mp.add_key_binding('Ctrl+o', 'browse', open_files_tab)
mp.observe_property('osd-dimensions', 'native', function() app.render() end)

-- Open by itself when mpv starts with nothing to play, e.g. `mpv --idle --force-window`
local opened_on_idle = false
mp.observe_property('idle-active', 'bool', function(_, idle)
    if idle and not opened_on_idle and app.opts.open_on_idle and mp.get_property('force-window') ~= 'no' then
        opened_on_idle = true
        open()
    end
end)
