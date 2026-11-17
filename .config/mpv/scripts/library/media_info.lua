-- File details for the info panel: ffprobe results, track lists and readable labels.
local mp = require 'mp'
local utils = require 'mp.utils'
local app = require 'app'
local fs = require 'fs'

local media_info = {}

local LANGUAGES = {
    eng = 'English', jpn = 'Japanese', spa = 'Spanish', hin = 'Hindi', tha = 'Thai', chi = 'Chinese', zho = 'Chinese',
    ger = 'German', deu = 'German', fre = 'French', fra = 'French', ind = 'Indonesian', por = 'Portuguese',
    vie = 'Vietnamese', kor = 'Korean', ita = 'Italian', rus = 'Russian', ara = 'Arabic', tur = 'Turkish',
    pol = 'Polish', dut = 'Dutch', nld = 'Dutch', swe = 'Swedish', nor = 'Norwegian', dan = 'Danish',
    fin = 'Finnish', may = 'Malay', msa = 'Malay', tam = 'Tamil', tel = 'Telugu', ben = 'Bengali', mar = 'Marathi',
    urd = 'Urdu', heb = 'Hebrew', gre = 'Greek', ell = 'Greek', cze = 'Czech', ces = 'Czech', hun = 'Hungarian',
    rum = 'Romanian', ron = 'Romanian', ukr = 'Ukrainian', fil = 'Filipino', tgl = 'Tagalog',
    en = 'English', ja = 'Japanese', es = 'Spanish', hi = 'Hindi', ko = 'Korean', zh = 'Chinese', fr = 'French',
    de = 'German', pt = 'Portuguese', it = 'Italian', ru = 'Russian',
}
local CODECS = {
    h264 = 'H.264', hevc = 'HEVC', av1 = 'AV1', vp9 = 'VP9', mpeg4 = 'MPEG-4', mpeg2video = 'MPEG-2',
    aac = 'AAC', ac3 = 'AC-3', eac3 = 'E-AC-3', dts = 'DTS', truehd = 'TrueHD', flac = 'FLAC', opus = 'Opus',
    mp3 = 'MP3', vorbis = 'Vorbis', subrip = 'SRT', ass = 'ASS', ssa = 'SSA', hdmv_pgs_subtitle = 'PGS',
    dvd_subtitle = 'VobSub', webvtt = 'VTT', mov_text = 'TX3G',
}
local SUBTITLE_EXTS = { srt = true, ass = true, ssa = true, vtt = true, sub = true, sup = true }

local function language_name(code)
    if not code or code == '' or code == 'und' then return 'Unknown' end
    return LANGUAGES[code:lower()] or code:upper()
end

local function codec_name(codec)
    return codec and (CODECS[codec] or codec:upper()) or '?'
end

-- 1115785809 -> "1.04 GB"
function media_info.human_size(bytes)
    if not bytes then return '?' end
    local units, i = { 'B', 'KB', 'MB', 'GB', 'TB' }, 1
    while bytes >= 1024 and i < #units do bytes, i = bytes / 1024, i + 1 end
    return (i >= 4 and '%.2f %s' or '%.0f %s'):format(bytes, units[i])
end

-- 6683.5 -> "1:51:23"
function media_info.human_time(seconds)
    seconds = math.floor(tonumber(seconds) or 0)
    local h, m, s = math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60
    if h > 0 then return ('%d:%02d:%02d'):format(h, m, s) end
    return ('%d:%02d'):format(m, s)
end

--[[ cached lookups; media_info.clear() forgets them (refresh) ]]

local sizes = {}  -- path -> bytes, or false if unreadable
local probes = {} -- path -> ffprobe json, 'pending' or 'failed'

function media_info.clear()
    sizes, probes = {}, {}
end

function media_info.size_of(path)
    if sizes[path] == nil then sizes[path] = fs.file_size(path) or false end
    return sizes[path] or nil
end

local PROBE_FIELDS = 'format=duration'
    .. ':stream=index,codec_type,codec_name,profile,width,height,avg_frame_rate,pix_fmt,channel_layout,channels,color_transfer'
    .. ':stream_tags=language,title'
    .. ':stream_disposition=default,forced,attached_pic'

-- ffprobe's JSON for the file, or 'pending' (redraws when done) or 'failed'
function media_info.probe(path)
    if probes[path] ~= nil then return probes[path] end
    probes[path] = 'pending'
    local command = { name = 'subprocess', playback_only = false, capture_stdout = true,
        args = { 'ffprobe', '-v', 'error', '-of', 'json', '-show_entries', PROBE_FIELDS, path } }
    mp.command_native_async(command, function(ok, result)
        local json = ok and result.status == 0 and utils.parse_json(result.stdout or '')
        probes[path] = json or 'failed'
        app.render()
    end)
    return 'pending'
end

--[[ tracks ]]

-- "stereo" -> "2.0", "5.1(side)" -> "5.1"
local function channels_label(stream)
    local layout = stream.channel_layout or ''
    return ({ mono = '1.0', stereo = '2.0' })[layout] or layout:match('^(%d%.%d)')
        or (stream.channels and stream.channels .. 'ch')
end

-- A row in the panel's audio / subtitle list:
--   { label, lang, meta, default, ff = stream index (mpv's ff-index) }
-- or for a subtitle file next to the video: { label, lang, meta, file = path }
-- or { label = 'Off', off = true }
local function track_row(stream)
    local tags, disposition = stream.tags or {}, stream.disposition or {}
    local meta = { codec_name(stream.codec_name) }
    if stream.codec_type == 'audio' then meta[#meta + 1] = channels_label(stream) end
    local title = tags.title
    if title and title ~= '' and title:lower() ~= language_name(tags.language):lower() then
        meta[#meta + 1] = title == 'MTL' and 'machine' or title
    end
    if disposition.forced == 1 then meta[#meta + 1] = 'forced' end
    if disposition.default == 1 then meta[#meta + 1] = 'default' end
    return {
        label = language_name(tags.language),
        lang = tags.language,
        meta = table.concat(meta, ' · '),
        ff = stream.index,
        default = disposition.default == 1,
    }
end

-- Subtitle files beside the video that start with its name ("Movie.en.srt")
local function subtitle_files(path)
    local rows = {}
    local dir, stem = path:match('^(.*)/([^/]+)%.[^./]+$')
    if not dir then return rows end
    for _, name in ipairs(fs.natural_sort(utils.readdir(dir, 'files') or {})) do
        local ext = name:match('%.([^.]+)$')
        if ext and SUBTITLE_EXTS[ext:lower()] and name:sub(1, #stem) == stem then
            local lang = name:sub(#stem + 2):match('^(%a%a%a?)%.')
            rows[#rows + 1] = {
                label = lang and LANGUAGES[lang:lower()] or 'External',
                lang = lang,
                meta = ext:upper() .. ' · external',
                file = utils.join_path(dir, name),
            }
        end
    end
    return rows
end

-- The file's main video stream, its audio rows and its subtitle rows (ending with "Off")
function media_info.tracks(path, probe)
    local video, audio, subs = nil, {}, {}
    for _, stream in ipairs(probe.streams or {}) do
        local is_cover_art = (stream.disposition or {}).attached_pic == 1
        if stream.codec_type == 'video' and not is_cover_art then
            video = video or stream
        elseif stream.codec_type == 'audio' then
            audio[#audio + 1] = track_row(stream)
        elseif stream.codec_type == 'subtitle' then
            subs[#subs + 1] = track_row(stream)
        end
    end
    for _, row in ipairs(subtitle_files(path)) do subs[#subs + 1] = row end
    subs[#subs + 1] = { label = 'Off', meta = '', off = true }
    return video, audio, subs
end

-- "1920×1080 · H.264 High · 23.976 fps · 8-bit SDR"
function media_info.video_summary(stream)
    local parts = {}
    if stream.width then parts[#parts + 1] = stream.width .. '×' .. stream.height end
    local codec = codec_name(stream.codec_name)
    if stream.codec_name == 'h264' and stream.profile then codec = codec .. ' ' .. stream.profile end
    parts[#parts + 1] = codec
    local num, den = (stream.avg_frame_rate or ''):match('^(%d+)/(%d+)$')
    if num and tonumber(num) > 0 and tonumber(den) > 0 then
        local fps = ('%.3f'):format(num / den):gsub('0+$', ''):gsub('%.$', '')
        parts[#parts + 1] = fps .. ' fps'
    end
    local bits = (stream.pix_fmt or ''):match('p(1[02])') or '8'
    local range = ({ smpte2084 = 'HDR10', ['arib-std-b67'] = 'HLG' })[stream.color_transfer or ''] or 'SDR'
    parts[#parts + 1] = bits .. '-bit ' .. range
    return table.concat(parts, ' · ')
end

-- The row mpv would pick by itself: the first of `languages` (alang / slang), else the
-- track flagged default. nil if neither matches.
function media_info.default_track(rows, languages)
    for _, lang in ipairs(languages or {}) do
        for i, row in ipairs(rows) do
            if row.lang and row.lang:lower() == lang:lower() then return i end
        end
    end
    for i, row in ipairs(rows) do
        if row.default then return i end
    end
end

return media_info
