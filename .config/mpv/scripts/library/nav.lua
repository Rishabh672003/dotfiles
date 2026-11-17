-- What the library is showing: the current tab, its items (filtered by the search) and,
-- in the Files tab, the folder being browsed.
local mp = require 'mp'
local app = require 'app'
local fs = require 'fs'

local nav = {}

function nav.section()
    return app.sections[app.ui.sec]
end

function nav.in_files_tab()
    local section = nav.section()
    return section ~= nil and section.browse == true
end

-- Show `dir` in the Files tab, with `select_path` selected if it's there
function nav.open_folder(dir, select_path)
    local ui = app.ui
    ui.folder, ui.folder_items = dir, fs.list_dir(dir)
    ui.search, ui.sel, ui.top = '', 1, 0
    for i, entry in ipairs(ui.folder_items) do
        if entry.path == select_path then ui.sel = i end
    end
end

function nav.up_folder()
    local ui = app.ui
    local parent = fs.parent(ui.folder)
    if parent then nav.open_folder(parent ~= '' and parent or '/', ui.folder) end
end

-- The Files tab starts in the playing file's folder, else in home
local function open_first_folder()
    local playing = mp.get_property('path', '')
    local dir = playing:sub(1, 1) == '/' and fs.parent(playing)
    nav.open_folder((dir and dir ~= '') and dir or app.HOME, playing)
end

-- The current tab's titles (or the Files tab's entries) that match the search
function nav.items()
    local ui = app.ui
    local all
    if nav.in_files_tab() then
        if not ui.folder then open_first_folder() end
        all = ui.folder_items
    else
        all = nav.section() and nav.section().titles or {}
    end
    if ui.search == '' then return all end
    local query, matches = ui.search:lower(), {}
    for _, item in ipairs(all) do
        if item.name:lower():find(query, 1, true) then matches[#matches + 1] = item end
    end
    return matches
end

function nav.selected()
    return nav.items()[app.ui.sel]
end

-- The media files of the Files tab's folder, to queue a file with its neighbours
function nav.folder_files()
    local files = {}
    for _, entry in ipairs(app.ui.folder_items) do
        if not entry.is_dir then files[#files + 1] = entry.path end
    end
    return files
end

return nav
