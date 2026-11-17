-- The start and end time of every line in a subtitle track. mpv only exposes the line on
-- screen, so ffmpeg converts the whole track to SRT in the background. Image subtitles (PGS,
-- VobSub) can't become text; for those ffprobe gives each picture's time instead.
--
-- A line is { s = start, e = end, text = one line without tags, raw = text as in the file }.
local mp = require 'mp'
local utils = require 'mp.utils'
local tracks = require 'tracks'

local cues = {}

-- Called when a track's lines finish loading (main.lua redraws)
cues.on_loaded = function() end

local cache_dir = mp.command_native({ 'expand-path', '~~cache/subsync' })
mp.command_native({ name = 'subprocess', args = { 'mkdir', '-p', cache_dir }, playback_only = false })

local function seconds(h, m, s, ms)
    return tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s) + tonumber(ms) / 1000
end

local function parse_srt(data)
    local lines = {}
    data = data:gsub('\r', '') .. '\n\n'
    for block in data:gmatch('(.-)\n\n+') do
        local h1, m1, s1, ms1, h2, m2, s2, ms2, rest = block:match(
            '(%d+):(%d+):(%d+)[,.](%d+)%s*%-%->%s*(%d+):(%d+):(%d+)[,.](%d+)[^\n]*\n?(.*)')
        if h1 then
            local raw = rest:gsub('%s+$', '')
            local text = raw:gsub('<[^>]->', ''):gsub('{[^}]-}', ''):gsub('%s+', ' ')
            lines[#lines + 1] = { s = seconds(h1, m1, s1, ms1), e = seconds(h2, m2, s2, ms2), raw = raw, text = text }
        end
    end
    table.sort(lines, function(a, b) return a.s < b.s end)
    return lines
end

-- ffprobe "pts,duration,size" rows: one per picture. Tiny pictures are "clear the screen"
-- events; a picture without a duration lasts until the next one (8 s at most).
local function parse_packets(data)
    local packets, lines = {}, {}
    for t, duration, size in data:gmatch('([%d.]+),([%w./]+),(%d+)') do
        packets[#packets + 1] = { t = tonumber(t), duration = tonumber(duration), size = tonumber(size) }
    end
    for i, p in ipairs(packets) do
        if p.size >= 50 then
            local next_t = packets[i + 1] and packets[i + 1].t
            local e = (p.duration and p.duration > 0) and p.t + p.duration or next_t or p.t + 2
            lines[#lines + 1] = { s = p.t, e = math.min(e, p.t + 8), raw = '', text = '' }
        end
    end
    return lines
end

local function has_text(lines)
    for _, line in ipairs(lines) do
        if line.text ~= '' then return true end
    end
    return false
end

local function file_size(path)
    local f = io.open(path, 'rb')
    if not f then return 0 end
    local size = f:seek('end')
    f:close()
    return size
end

local function hash(s)
    local h = 5381
    for i = 1, #s do h = (h * 33 + s:byte(i)) % 4294967296 end
    return ('%08x%x'):format(h, #s)
end

-- Reading an embedded track means reading the whole video file, so the result is kept on
-- disk. External subtitle files are quick to read again.
local function disk_cache_file(track, key, src)
    if track.external then return nil end
    return ('%s/%s.json'):format(cache_dir, hash(key .. '#' .. file_size(src)))
end

local function read_disk_cache(file)
    local f = file and io.open(file, 'r')
    if not f then return nil end
    local lines = utils.parse_json(f:read('*a'))
    f:close()
    return lines
end

local function write_disk_cache(file, lines)
    local f = file and io.open(file, 'w')
    if not f then return end
    f:write(utils.format_json(lines))
    f:close()
end

local function subprocess(args, callback)
    mp.command_native_async({ name = 'subprocess', args = args, playback_only = false,
        capture_stdout = true, capture_stderr = true }, function(ok, result)
        callback(ok and result.status == 0 and result.stdout or nil)
    end)
end

local loaded = {} -- "file#map" -> { state = 'pending' | 'ok' | 'failed', lines, has_text }

-- The track's lines: { state, lines, has_text }. While state is 'pending' they're loading.
function cues.of(track)
    local src, map = tracks.source(track)
    if not src then return { state = 'failed', lines = {} } end
    local key = src .. '#' .. map
    if loaded[key] then return loaded[key] end

    local entry = { state = 'pending', lines = {} }
    loaded[key] = entry
    local function set_lines(lines)
        entry.lines, entry.state, entry.has_text = lines, #lines > 0 and 'ok' or 'failed', has_text(lines)
    end

    local cache_file = disk_cache_file(track, key, src)
    local cached = read_disk_cache(cache_file)
    if cached then
        set_lines(cached)
        return entry
    end

    local function finish(lines)
        set_lines(lines)
        if cache_file and #lines > 0 then write_disk_cache(cache_file, lines) end
        cues.on_loaded()
    end

    subprocess({ 'ffmpeg', '-v', 'error', '-nostdin', '-i', src, '-map', map, '-f', 'srt', '-' }, function(out)
        local lines = parse_srt(out or '')
        if #lines > 0 then return finish(lines) end
        local stream = track.external and 's:0' or tostring(track['ff-index'])
        subprocess({ 'ffprobe', '-v', 'error', '-select_streams', stream,
            '-show_entries', 'packet=pts_time,duration_time,size', '-of', 'csv=p=0', src }, function(packets)
            finish(parse_packets(packets or ''))
        end)
    end)
    return entry
end

-- Forget what was loaded from `path` (it was just rewritten)
function cues.forget(path)
    for key in pairs(loaded) do
        if key:sub(1, #path + 1) == path .. '#' then loaded[key] = nil end
    end
end

return cues
