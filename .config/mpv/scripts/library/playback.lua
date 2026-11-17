-- Starting playback from the library.
local mp = require 'mp'
local app = require 'app'
local fs = require 'fs'

local playback = {}

-- Tracks picked in the info panel, switched to once that file has loaded:
-- { path, audio = row, sub = row } (rows from media_info.tracks)
local pending_tracks

-- Play `start` with all of `files` as the playlist (so next/prev walks the series), and
-- close the library. `tracks` = { audio = row, sub = row } picks tracks for `start`.
function playback.play(files, start, tracks)
    if #files == 0 then return end
    local first = fs.index_of(files, start) or 1
    mp.commandv('loadfile', files[first], 'replace')
    for i, file in ipairs(files) do
        if i ~= first then mp.commandv('loadfile', file, 'append') end
    end
    -- the started file went in first; move it back to its place in the order
    if first > 1 then mp.commandv('playlist-move', 0, first) end
    pending_tracks = tracks and { path = files[first], audio = tracks.audio, sub = tracks.sub }
    app.close()
end

local function is_track(entry, row)
    if row.file then return entry['external-filename'] == row.file end
    return not entry.external and entry['ff-index'] == row.ff
end

local function apply_tracks(want)
    local sub_found = false
    for _, entry in ipairs(mp.get_property_native('track-list') or {}) do
        if want.audio and entry.type == 'audio' and is_track(entry, want.audio) then
            mp.set_property_number('aid', entry.id)
        elseif want.sub and not want.sub.off and entry.type == 'sub' and is_track(entry, want.sub) then
            mp.set_property_number('sid', entry.id)
            sub_found = true
        end
    end
    if want.sub and want.sub.off then
        mp.set_property('sid', 'no')
    elseif want.sub and want.sub.file and not sub_found then
        mp.commandv('sub-add', want.sub.file, 'select') -- mpv didn't load that file by itself
    end
end

mp.register_event('file-loaded', function()
    local want = pending_tracks
    if want and mp.get_property('path') == want.path then
        pending_tracks = nil
        apply_tracks(want)
    end
end)

return playback
