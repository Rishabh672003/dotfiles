-- What keys and clicks do in the library (the info panel's own keys are in views/info.lua).
local mp = require 'mp'
local app = require 'app'
local fs = require 'fs'
local catalog = require 'catalog'
local history = require 'history'
local posters = require 'posters'
local media_info = require 'media_info'
local playback = require 'playback'
local nav = require 'nav'

local actions = {}

local function open_title(title)
    local ui = app.ui
    ui.view, ui.title, ui.ep_top = 'detail', title, 0
    ui.ep = fs.index_of(title.files, history.last_played(title)) or 1
end

-- Enter
function actions.activate()
    local ui = app.ui
    if ui.view == 'detail' then
        return playback.play(ui.title.files, ui.title.files[ui.ep])
    end
    local item = nav.selected()
    if not item then return end
    if nav.in_files_tab() then
        if item.is_dir then return nav.open_folder(item.path) end
        return playback.play(nav.folder_files(), item.path) -- the rest of the folder queued, like autoload
    end
    if nav.section().resume then return playback.play(item.files, history.last_played(item)) end
    if #item.files == 1 then return playback.play(item.files, item.files[1]) end
    open_title(item)
end

-- A click selects an item; a click on the selected item opens it
function actions.click_item(i)
    local ui = app.ui
    local key = ui.view == 'detail' and 'ep' or 'sel'
    if ui[key] == i then
        actions.activate()
    else
        ui[key] = i
    end
end

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

-- Arrow keys. In the Files tab, left / right go up a folder / into the selected one.
function actions.move(dx, dy)
    local ui = app.ui
    if ui.view == 'detail' then
        ui.ep = clamp(ui.ep + dx + dy, 1, #ui.title.files)
    elseif nav.in_files_tab() and dx < 0 then
        nav.up_folder()
    elseif nav.in_files_tab() and dx > 0 then
        local entry = nav.selected()
        if entry and entry.is_dir then nav.open_folder(entry.path) end
    else
        ui.sel = clamp(ui.sel + dx + dy * (ui.cols or 6), 1, #nav.items())
    end
end

-- Backspace: back out of the detail view, the search, then the folder; else close
function actions.back()
    local ui = app.ui
    if ui.view == 'detail' then
        ui.view = 'grid'
    elseif ui.search ~= '' then
        ui.search = ''
    elseif nav.in_files_tab() then
        nav.up_folder()
    else
        app.close()
    end
end

-- Esc
function actions.escape()
    if app.ui.view == 'detail' then
        app.ui.view = 'grid'
    else
        app.close()
    end
end

-- Tab
function actions.next_tab()
    local ui = app.ui
    if ui.view == 'grid' then ui.sec, ui.sel, ui.top = ui.sec % #app.sections + 1, 1, 0 end
end

function actions.show_tab(i)
    local ui = app.ui
    ui.view, ui.sec, ui.sel, ui.top = 'grid', i, 1, 0
end

-- p: play the whole title; in the Files tab the selected folder, or the folder shown
function actions.play_all()
    local ui = app.ui
    if ui.view == 'detail' then return playback.play(ui.title.files, ui.title.files[1]) end
    if nav.in_files_tab() then
        local entry = nav.selected()
        local files = fs.collect(entry and entry.is_dir and entry.path or ui.folder)
        playback.play(files, files[1])
    end
end

-- r: continue the selected title from its last played file
function actions.resume()
    local ui = app.ui
    local title = ui.view == 'detail' and ui.title or nav.selected()
    local last = title and title.files and history.last_played(title)
    if last then playback.play(title.files, last) end
end

-- Shift+Enter in the Files tab: add the selection to the playlist (a folder: all of it)
function actions.append()
    if not nav.in_files_tab() then return end
    local entry = nav.selected()
    if not entry then return end
    local files = entry.is_dir and fs.collect(entry.path) or { entry.path }
    for _, file in ipairs(files) do mp.commandv('loadfile', file, 'append-play') end
    mp.osd_message('Added to playlist: ' .. entry.name)
end

-- ~ in the Files tab
function actions.go_home()
    if nav.in_files_tab() then nav.open_folder(app.HOME) end
end

--[[ search ]]

function actions.start_search()
    if app.ui.view == 'grid' then app.ui.searching = true end
end

function actions.type_search(text)
    app.ui.search, app.ui.sel = app.ui.search .. text, 1
end

function actions.erase_search_char()
    -- drop the last UTF-8 character
    app.ui.search, app.ui.sel = app.ui.search:gsub('[%z\1-\127\194-\244][\128-\191]*$', ''), 1
end

function actions.finish_search()
    app.ui.searching = false
end

function actions.cancel_search()
    app.ui.searching, app.ui.search, app.ui.sel = false, '', 1
end

--[[ refresh ]]

-- The title with this path in the current tab, if it's still there
local function find_title(path)
    for _, title in ipairs(nav.section().titles) do
        if title.path == path then return title end
    end
end

-- Ctrl+r / F5: rescan the folders, staying on the same tab, title and folder
function actions.refresh()
    local ui = app.ui
    local tab_name = nav.section() and nav.section().name
    local open_title_path = ui.view == 'detail' and ui.title.path

    app.sections = catalog.scan()
    ui.sec = 1
    for i, section in ipairs(app.sections) do
        if section.name == tab_name then ui.sec = i end
    end
    if open_title_path then
        local title = find_title(open_title_path)
        if title then
            ui.title, ui.ep = title, math.min(ui.ep, #title.files)
        else
            ui.view = 'grid'
        end
    end
    if nav.in_files_tab() and ui.folder then
        local entry = nav.selected()
        nav.open_folder(ui.folder, entry and entry.path)
    end
    posters.retry_failed()
    media_info.clear()
    mp.osd_message('Library refreshed')
end

return actions
