-- Settings and the state shared by every part of the library.
local mp = require 'mp'
local options = require 'mp.options'

local app = {}

-- From script-opts/library.conf
app.opts = {
    dirs = '~/Videos',
    exts = 'mkv,mp4,avi,webm,mov,m4v,wmv,flv,ts,mpg,mpeg,mp3,flac,m4a,opus,ogg,wav',
    accent = 'f2b134',
    posters = true,
    open_on_idle = true,
}
options.read_options(app.opts, 'library')

local function expand(path)
    return mp.command_native({ 'expand-path', path })
end

-- expand-path only expands "~/", not a bare "~"
app.HOME = (expand('~/'):gsub('/$', ''))

-- The library folders, expanded, without trailing slashes
app.roots = {}
for dir in app.opts.dirs:gmatch('[^,]+') do
    local trimmed = dir:gsub('^%s+', ''):gsub('%s+$', '')
    app.roots[#app.roots + 1] = (expand(trimmed):gsub('/+$', ''))
end

app.cache_dir = expand('~~cache/library')
mp.command_native({ name = 'subprocess', args = { 'mkdir', '-p', app.cache_dir }, playback_only = false })

-- The tabs, rebuilt each time the library opens (see catalog.lua).
app.sections = {}

-- nil while the library is closed. While open:
--   view            'grid' or 'detail'
--   sec             index of the active tab in app.sections
--   sel, top        selected item, first visible row (grid and Files list)
--   cols            columns in the grid as last drawn, for up/down
--   search          filter text; searching = true while typing it
--   title, ep, ep_top     detail view: the title, selected episode, first visible episode
--   folder, folder_items  Files tab: the folder shown and its entries
--   info            the info panel is open
--   track_choice    audio/subtitle picked in the info panel (views/info.lua)
--   info_play       what Enter does in the info panel
app.ui = nil

-- Filled in by main.lua; other modules call these to redraw or close the library.
app.render = function() end
app.close = function() end

return app
