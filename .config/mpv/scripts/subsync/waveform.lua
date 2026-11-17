-- How loud the voice band (200–3500 Hz) of the playing audio is over time. ffmpeg reads it
-- in 20-second chunks around the playhead; on surround tracks only the centre channel,
-- where films put the dialogue.
local mp = require 'mp'

local waveform = {}

waveform.BIN = 0.05 -- seconds per loudness value

-- Called when a chunk finishes loading (main.lua redraws)
waveform.on_loaded = function() end

local CHUNK = 20 -- seconds read per ffmpeg call
local RATE = 4000 -- samples per second; plenty for loudness
local BINS_PER_CHUNK = CHUNK / waveform.BIN
local SILENCE = -100 -- dB

-- Loudness in dBFS of 16-bit samples data[first_byte .. first_byte + bytes)
local function loudness(data, first_byte, bytes)
    local sum, count = 0, 0
    -- every 4th sample (8 bytes apart) is enough for a loudness value
    for i = first_byte, math.min(first_byte + bytes - 2, #data - 1), 8 do
        local low, high = data:byte(i, i + 1)
        local sample = high * 256 + low
        if sample >= 32768 then sample = sample - 65536 end
        sum, count = sum + sample * sample, count + 1
    end
    if count == 0 or sum == 0 then return SILENCE end
    return 10 * math.log10(sum / count / 1073741824) -- 1073741824 = 32768^2, full scale
end

local function ffmpeg_args(src, map, chunk, centre_only)
    local filters = 'highpass=f=200,lowpass=f=3500'
    if centre_only then filters = 'pan=mono|c0=FC,' .. filters end
    return { 'ffmpeg', '-v', 'error', '-nostdin', '-ss', tostring(chunk * CHUNK), '-t', tostring(CHUNK),
        '-i', src, '-map', map, '-ac', '1', '-ar', tostring(RATE), '-af', filters, '-f', 's16le', '-' }
end

local chunks = {} -- "file#map#chunk[#c]" -> array of dB per bin, or 'pending'

local function chunk_levels(src, map, chunk, centre_only)
    local key = ('%s#%s#%d%s'):format(src, map, chunk, centre_only and '#c' or '')
    if chunks[key] then return chunks[key] end
    chunks[key] = 'pending'
    local command = { name = 'subprocess', args = ffmpeg_args(src, map, chunk, centre_only),
        playback_only = false, capture_stdout = true, capture_stderr = true }
    mp.command_native_async(command, function(ok, result)
        local data = ok and result.stdout or ''
        local bytes_per_bin = RATE * waveform.BIN * 2
        local levels = {}
        for bin = 0, BINS_PER_CHUNK - 1 do
            levels[bin + 1] = loudness(data, bin * bytes_per_bin + 1, bytes_per_bin)
        end
        chunks[key] = levels
        waveform.on_loaded()
    end)
    return 'pending'
end

-- Loudest level (dB) of bins first_bin .. first_bin + count - 1, or nil while loading.
-- Bins are BIN seconds long, counted from the start of the file.
function waveform.level(src, map, centre_only, first_bin, count)
    local chunk = math.floor(first_bin / BINS_PER_CHUNK)
    local levels = chunk_levels(src, map, chunk, centre_only)
    if type(levels) ~= 'table' then return nil end
    local loudest = SILENCE
    for bin = first_bin, first_bin + count - 1 do
        loudest = math.max(loudest, levels[bin - chunk * BINS_PER_CHUNK + 1] or SILENCE)
    end
    return loudest
end

return waveform
