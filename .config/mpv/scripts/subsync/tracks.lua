-- The playing file's subtitle and audio tracks, and where ffmpeg can read them from.
local mp = require 'mp'

local tracks = {}

local LANGUAGES = {
    eng = 'English', jpn = 'Japanese', spa = 'Spanish', fre = 'French', fra = 'French', ger = 'German',
    deu = 'German', chi = 'Chinese', zho = 'Chinese', kor = 'Korean', hin = 'Hindi', ind = 'Indonesian',
    por = 'Portuguese', ita = 'Italian', rus = 'Russian', tha = 'Thai', vie = 'Vietnamese', ara = 'Arabic',
    en = 'English', ja = 'Japanese', es = 'Spanish', fr = 'French', de = 'German', zh = 'Chinese', ko = 'Korean',
    hi = 'Hindi', id = 'Indonesian', pt = 'Portuguese', it = 'Italian', ru = 'Russian',
}

-- The main selected track of a kind ('sub' or 'audio'), from mpv's track-list
function tracks.selected(kind)
    for _, track in ipairs(mp.get_property_native('track-list') or {}) do
        if track.type == kind and track.selected and (track['main-selection'] or 0) == 0 then return track end
    end
end

-- The file ffmpeg should read the track from and its -map value, or nil for streams
function tracks.source(track)
    if track.external then
        local kind = track.type == 'sub' and 's' or 'a'
        return track['external-filename'], '0:' .. kind .. ':0'
    end
    local path = mp.get_property('path', '')
    if path:sub(1, 1) ~= '/' or not track['ff-index'] then return nil end
    return path, '0:' .. track['ff-index']
end

-- "eng", "en" or "en-CA" -> "English"
local function language_name(code)
    if not code or code == '' or code == 'und' then return 'Unknown' end
    code = code:lower()
    return LANGUAGES[code] or LANGUAGES[code:match('^%a+') or ''] or code:upper()
end

-- "English · SDH"
function tracks.label(track)
    local language = language_name(track.lang)
    if track.title and track.title ~= '' then return language .. ' · ' .. track.title end
    return language
end

-- 5.1 or more: films put the dialogue in the centre channel
function tracks.is_surround(track)
    return (track['demux-channel-count'] or 0) >= 6
end

return tracks
