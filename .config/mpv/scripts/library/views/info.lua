-- The info panel (i): a panel on the right about the selected item.
--   a file:               location, size, duration, video, audio and subtitle tracks;
--                         audio / subtitles can be picked before playing
--   a multi-file title:   folder, total size, last played file
--   a Files-tab folder:   location and item count
local mp = require 'mp'
local app = require 'app'
local fs = require 'fs'
local canvas = require 'canvas'
local history = require 'history'
local media_info = require 'media_info'
local playback = require 'playback'
local nav = require 'nav'

local info = {}

local C = canvas.colors
local PADDING = 28
local TRACK_ROW_H = 32

function info.width(c)
    return math.floor(math.min(440, c.w * 0.5))
end

--[[ what the panel is about ]]

-- { kind = 'file', file, name, files = its playlist, title = its title if any, resume = on Continue tab }
-- { kind = 'title', title }   a title with several files, in the grid
-- { kind = 'folder', entry }  a folder in the Files tab
function info.target()
    local ui = app.ui
    if ui.view == 'detail' then
        local title = ui.title
        return { kind = 'file', file = title.files[ui.ep], name = title.name, files = title.files, title = title }
    end
    local item = nav.selected()
    if not item then return nil end
    if nav.in_files_tab() then
        if item.is_dir then return { kind = 'folder', entry = item } end
        return { kind = 'file', file = item.path, name = fs.basename(item.path), files = nav.folder_files() }
    end
    local on_continue_tab = nav.section().resume
    if #item.files == 1 or on_continue_tab then
        local file = on_continue_tab and history.last_played(item) or item.files[1]
        return { kind = 'file', file = file, name = item.name, files = item.files, title = item, resume = on_continue_tab }
    end
    return { kind = 'title', title = item }
end

local function target_path(target)
    if target.kind == 'file' then return target.file end
    if target.kind == 'title' then return target.title.path end
    return target.entry.path
end

--[[ layout: content flows down the panel, one line at a time ]]

local Flow = {}
Flow.__index = Flow

local function new_flow(c, x, w)
    return setmetatable({ c = c, x = x, w = w, y = 32 }, Flow)
end

-- One line of text; moves down by `advance` (default 1.5 x the font size)
function Flow:line(str, style, advance)
    style.clip = self.w
    self.c:text(self.x, self.y, str, style)
    self.y = self.y + (advance or (style.size or 15) * 1.5)
end

-- Small accent label above the name, e.g. "S01 · E06"
function Flow:kicker(str)
    self:line(str, { size = 13, bold = true, color = C.accent }, 22)
end

function Flow:name(str)
    self:line(str, { size = 24, bold = true }, 36)
end

function Flow:heading(str)
    self.y = self.y + 10
    self:line(str, { size = 12, bold = true, color = C.muted }, 22)
end

function Flow:detail(str, color, advance)
    self:line(str, { size = 14, color = color }, advance or 22)
end

-- Small labelled boxes in a row: size, container, duration
function Flow:chips(labels)
    local x = self.x
    for _, label in ipairs(labels) do
        local w = #label * 7.5 + 20
        self.c:box(x, self.y, w, 26, C.field)
        self.c:text(x + w / 2, self.y + 13, label, { size = 13, align = 'center' })
        x = x + w + 8
    end
    self.y = self.y + 36
end

--[[ track choice (audio / subtitles) for the file in the panel ]]

-- Kept in ui.track_choice while the same file stays selected:
-- { path, audio = index, sub = index, audio_list, sub_list, changed = { audio = bool, sub = bool } }
local function track_choice(file, audio, subs)
    local choice = app.ui.track_choice
    if not (choice and choice.path == file) then
        choice = {
            path = file,
            changed = {},
            -- start with what mpv would pick by itself
            audio = media_info.default_track(audio, mp.get_property_native('alang')) or 1,
            sub = media_info.default_track(subs, mp.get_property_native('slang')) or #subs,
        }
        app.ui.track_choice = choice
    end
    choice.audio_list, choice.sub_list = audio, subs
    return choice
end

local function cycle_track(kind)
    local choice = app.ui.track_choice
    local list = choice and choice[kind .. '_list']
    if not list or #list == 0 then return end
    choice[kind] = choice[kind] % #list + 1
    choice.changed[kind] = true
end

-- A list of tracks with the chosen one marked. Shows at most max_rows, scrolled so the
-- chosen one is visible. kind is 'audio' or 'sub'.
local function draw_track_list(flow, heading, count, choice, kind, max_rows)
    local list = choice[kind .. '_list']
    if #list == 0 then return end
    local c = flow.c
    flow:heading(heading .. '  ·  ' .. count)

    local chosen = choice[kind]
    local first = 1
    if #list > max_rows then first = math.max(1, math.min(chosen - math.floor(max_rows / 2), #list - max_rows + 1)) end
    local last = math.min(#list, first + max_rows - 1)

    for i = first, last do
        local track, on = list[i], i == chosen
        local middle = flow.y + (TRACK_ROW_H - 4) / 2
        if on then c:box(flow.x - 10, flow.y, flow.w + 20, TRACK_ROW_H - 4, C.field) end
        c:text(flow.x, middle, on and '●' or '○', { size = 14, align = 'left', color = on and C.accent or C.muted })
        c:text(flow.x + 22, middle, track.label, { size = 14, align = 'left', clip = flow.w * 0.42 })
        c:text(flow.x + flow.w, middle, track.meta, { size = 13, align = 'right', color = C.muted })
        c:on_click(flow.x - 10, flow.y, flow.w + 20, TRACK_ROW_H, function()
            choice[kind], choice.changed[kind] = i, true
        end)
        flow.y = flow.y + TRACK_ROW_H
    end
    if #list > max_rows then
        local key = kind == 'audio' and 'a' or 's'
        flow:line(('%d–%d of %d   ·   %s to cycle'):format(first, last, #list, key), { size = 12, color = C.muted }, 20)
    end
end

--[[ the three kinds of content; each returns the button label and what it does ]]

local function draw_folder(flow, target)
    local entry = target.entry
    flow:kicker('FOLDER')
    flow:name(entry.name)
    flow:heading('LOCATION')
    flow:detail(fs.short_path(entry.path), nil, 26)
    flow:chips({ #fs.list_dir(entry.path) .. ' items' })
    return 'Open folder', function()
        app.ui.info = false
        nav.open_folder(entry.path)
    end
end

local function draw_title(flow, target)
    local title = target.title
    local last = history.last_played(title)
    flow:kicker(#title.files .. ' FILES')
    flow:name(title.name)
    flow:heading('FOLDER')
    flow:detail(fs.short_path(title.path), nil, 26)
    local total = 0
    for _, file in ipairs(title.files) do total = total + (media_info.size_of(file) or 0) end
    flow:chips({ media_info.human_size(total), #title.files .. ' files' })
    flow:heading(last and 'LAST PLAYED' or 'STARTS WITH')
    flow:detail(fs.basename(last or title.files[1]))
    local label = last and ('Resume %d of %d'):format(fs.index_of(title.files, last), #title.files) or 'Play from start'
    return label, function() playback.play(title.files, last or title.files[1]) end
end

-- "Play E06 with Spanish subtitles", and the tracks to play it with
local function play_button(target, choice, episode)
    local changed = choice and choice.changed or {}
    local with
    if changed.sub then
        local sub = choice.sub_list[choice.sub]
        with = sub.off and 'no subtitles' or (sub.label .. ' subtitles')
    end
    if changed.audio then
        with = with and 'chosen tracks' or (choice.audio_list[choice.audio].label .. ' audio')
    end
    local label = (target.resume and 'Resume' or 'Play') .. (episode and (' E' .. episode) or '')
        .. (with and (' with ' .. with) or '')

    local tracks
    if changed.audio or changed.sub then
        tracks = {
            audio = changed.audio and choice.audio_list[choice.audio] or nil,
            sub = changed.sub and choice.sub_list[choice.sub] or nil,
        }
    end
    return label, function() playback.play(target.files, target.file, tracks) end
end

-- The top part: name, position in its playlist, location, size / container / duration
local function draw_file_summary(flow, target, probe)
    local file = target.file
    local season, episode = fs.basename(file):match('[Ss](%d%d?)[%s%._-]*[Ee](%d%d?%d?)')
    if season then flow:kicker(('S%02d · E%02d'):format(tonumber(season), tonumber(episode))) end
    flow:name(target.name)

    local where = {}
    local index = fs.index_of(target.files, file)
    if #target.files > 1 and index then
        where[#where + 1] = ('%s %d of %d'):format(season and 'Episode' or 'File', index, #target.files)
    end
    if target.title and history.last_played(target.title) == file then where[#where + 1] = 'last played' end
    if #where > 0 then flow:detail(table.concat(where, ' · '), C.muted) end

    flow:heading('FILE')
    flow:detail(fs.short_path(fs.parent(file) or '') .. '/', nil, 20)
    flow:detail(file:match('([^/]+)$'), C.muted, 26)
    local chips = { media_info.human_size(media_info.size_of(file)), (file:match('%.([^./]+)$') or ''):upper() }
    if type(probe) == 'table' and probe.format and probe.format.duration then
        chips[#chips + 1] = media_info.human_time(probe.format.duration)
    end
    flow:chips(chips)
    return episode
end

-- Returns the track choice (nil until ffprobe has answered) and the episode number
local function draw_file(flow, target, bottom)
    local probe = media_info.probe(target.file)
    local episode = draw_file_summary(flow, target, probe)
    if probe == 'pending' then
        flow:detail('Reading file…', C.muted)
        return nil, episode
    elseif probe == 'failed' then
        flow:detail("Couldn't read this file", C.muted)
        return nil, episode
    end

    local video, audio, subs = media_info.tracks(target.file, probe)
    if video then
        flow:heading('VIDEO')
        flow:detail(media_info.video_summary(video))
    end
    local choice = track_choice(target.file, audio, subs)
    -- audio and subtitles share the rows left above the button (a third at most for audio)
    local rows = math.floor((bottom - flow.y - 2 * 32 - 40) / TRACK_ROW_H)
    if rows >= 2 then
        local audio_rows = math.min(#audio, math.max(1, math.floor(rows / 3)))
        draw_track_list(flow, 'AUDIO', #audio, choice, 'audio', audio_rows)
        draw_track_list(flow, 'SUBTITLES', #subs - 1, choice, 'sub', math.max(1, rows - audio_rows))
    end
    return choice, episode
end

--[[ the panel ]]

function info.draw(c)
    local panel_w = info.width(c)
    local panel_x = c.w - panel_w
    local x, w = panel_x + PADDING, panel_w - 2 * PADDING
    c:box(panel_x, 0, panel_w, c.h, C.panel)
    c:box(panel_x, 0, 1, c.h, C.selected)
    c:on_click(panel_x, 0, panel_w, c.h, function() end) -- clicks on the panel don't reach the grid behind it

    app.ui.info_play = nil
    local target = info.target()
    if not target then return c:text(x, 40, 'Nothing selected', { color = C.muted }) end

    local button_y = c.h - 112
    local flow = new_flow(c, x, w)
    local label, play
    local hints = 'Enter play     ↑↓ next'
    if target.kind == 'folder' then
        label, play = draw_folder(flow, target)
    elseif target.kind == 'title' then
        label, play = draw_title(flow, target)
    else
        local choice, episode = draw_file(flow, target, button_y - 16)
        if choice then hints = hints .. '     a audio     s subtitles' end
        label, play = play_button(target, choice, episode)
    end
    app.ui.info_play = play

    c:box(x, button_y, w, 44, C.accent)
    c:text(x + w / 2, button_y + 22, label, { align = 'center', bold = true, color = C.background })
    c:on_click(x, button_y, w, 44, play)
    c:text(x, c.h - 48, hints, { size = 12, align = 'left', color = C.muted, clip = w })
    c:text(x, c.h - 26, 'c copy path     o open folder     i close', { size = 12, align = 'left', color = C.muted, clip = w })
end

--[[ keys while the panel is open (on top of the library's own) ]]

local function close_panel()
    app.ui.info = false
end

local function play_selection()
    if app.ui.info_play then app.ui.info_play() end
end

local function copy_path()
    local target = info.target()
    if not target then return end
    local path = target_path(target)
    if not mp.set_property('clipboard/text', path) then
        mp.command_native_async({ name = 'subprocess', args = { 'wl-copy', path }, playback_only = false }, function() end)
    end
    mp.osd_message('Copied: ' .. path)
end

-- A file's folder, or the folder itself
local function open_in_file_manager()
    local target = info.target()
    if not target then return end
    local folder = target.kind == 'file' and fs.parent(target.file) or target_path(target)
    mp.command_native_async({ name = 'subprocess', args = { 'xdg-open', folder }, playback_only = false, detach = true },
        function() end)
end

info.keys = {
    i = close_panel,
    ESC = close_panel,
    BS = close_panel,
    ENTER = play_selection,
    KP_ENTER = play_selection,
    a = function() cycle_track('audio') end,
    s = function() cycle_track('sub') end,
    c = copy_path,
    o = open_in_file_manager,
}

return info
