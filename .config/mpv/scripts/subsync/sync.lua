-- Changing the subtitle delay (mpv's sub-delay), and saving the result as an .srt.
local mp = require 'mp'
local tracks = require 'tracks'
local cues = require 'cues'

local sync = {}

function sync.delay()
    return mp.get_property_number('sub-delay', 0)
end

-- Rounded to 10 ms
function sync.set_delay(seconds)
    mp.set_property_number('sub-delay', math.floor(seconds * 100 + 0.5) / 100)
end

function sync.nudge(seconds)
    sync.set_delay(sync.delay() + seconds)
end

function sync.reset()
    sync.set_delay(0)
end

-- Jump to the previous (-1) or next (1) subtitle line
function sync.jump(direction)
    mp.commandv('sub-seek', direction)
end

-- "Line starts now": shift the subtitles so the line whose start is nearest the playhead
-- starts exactly now. Without loaded lines, mpv's sub-step does the same for the next line.
function sync.snap()
    local track = tracks.selected('sub')
    local loaded = track and cues.of(track)
    if not (loaded and loaded.state == 'ok') then return mp.commandv('sub-step', 1) end
    local now, delay = mp.get_property_number('time-pos', 0), sync.delay()
    local nearest
    for _, line in ipairs(loaded.lines) do
        if not nearest or math.abs(line.s + delay - now) < math.abs(nearest.s + delay - now) then nearest = line end
    end
    if nearest then sync.set_delay(now - nearest.s) end
end

-- 3725.5 -> "01:02:05,500"
local function srt_time(seconds)
    local ms = math.floor(math.max(0, seconds) * 1000 + 0.5)
    return ('%02d:%02d:%02d,%03d'):format(math.floor(ms / 3600000), math.floor(ms / 60000) % 60,
        math.floor(ms / 1000) % 60, ms % 1000)
end

-- Write the lines with the delay applied next to the video ("Movie.eng.synced.srt"),
-- switch to that file and set the delay back to 0
function sync.save_srt()
    local track = tracks.selected('sub')
    local loaded = track and cues.of(track)
    if not (loaded and loaded.state == 'ok' and loaded.has_text) then
        return mp.osd_message('Needs a text subtitle track (not PGS/VobSub)')
    end
    local video = mp.get_property('path', '')
    local out = (video:match('^(.*)%.[^./]+$') or video) .. '.' .. (track.lang or 'sub') .. '.synced.srt'
    local f = io.open(out, 'w')
    if not f then return mp.osd_message("Couldn't write " .. out) end
    local delay = sync.delay()
    for i, line in ipairs(loaded.lines) do
        local text = line.raw ~= '' and line.raw or line.text
        f:write(i, '\n', srt_time(line.s + delay), ' --> ', srt_time(line.e + delay), '\n', text, '\n\n')
    end
    f:close()
    cues.forget(out)
    sync.reset()
    mp.commandv('sub-add', out, 'select')
    mp.osd_message('Saved ' .. out:match('[^/]+$'))
end

return sync
