-- Title thumbnails. ffmpeg grabs one frame (or scales the folder's poster.jpg) into a raw
-- BGRA file in the cache, which mpv's overlay-add can show as-is.
local mp = require 'mp'
local utils = require 'mp.utils'
local app = require 'app'
local fs = require 'fs'

local posters = {}

local WIDTH, HEIGHT = 384, 216 -- 16:9
local BYTES = WIDTH * HEIGHT * 4
local MAX_JOBS = 2 -- ffmpeg processes at once
local POSTER_IMAGES = { 'poster.jpg', 'poster.png', 'folder.jpg', 'folder.png', 'cover.jpg', 'cover.png' }

local status = {} -- title path -> 'ok' | 'pending' | 'failed'
local queue, running = {}, 0

local function cache_file(title)
    return ('%s/%s_%dx%d.bgra'):format(app.cache_dir, fs.hash(title.path), WIDTH, HEIGHT)
end

-- A poster image in the title's folder, else its first media file. Second value: is it an image?
local function source_of(title)
    if title.dir then
        for _, name in ipairs(POSTER_IMAGES) do
            local path = utils.join_path(title.dir, name)
            if fs.file_size(path) then return path, true end
        end
    end
    return title.files[1], false
end

local function ffmpeg_command(src, seek, out)
    local args = { 'ffmpeg', '-v', 'error', '-y', '-nostdin' }
    if seek then
        args[#args + 1] = '-ss'
        args[#args + 1] = seek
    end
    local fill = ('scale=%d:%d:force_original_aspect_ratio=increase,crop=%d:%d,format=bgra')
        :format(WIDTH, HEIGHT, WIDTH, HEIGHT)
    for _, arg in ipairs({ '-i', src, '-frames:v', '1', '-vf', fill, '-f', 'rawvideo', out }) do
        args[#args + 1] = arg
    end
    return { name = 'subprocess', args = args, playback_only = false, capture_stderr = true }
end

local start_jobs -- defined below; each finished job starts the next one

local function make(title)
    local out = cache_file(title)
    local tmp = out .. '.tmp'
    local src, is_image = source_of(title)
    -- 5 minutes in skips intros; shorter clips fall back to 30 s, then the first frame
    local seeks = is_image and { false } or { '300', '30', false }

    local function attempt(i)
        mp.command_native_async(ffmpeg_command(src, seeks[i], tmp), function()
            if fs.file_size(tmp) == BYTES then
                os.rename(tmp, out)
                status[title.path] = 'ok'
            elseif i < #seeks then
                return attempt(i + 1)
            else
                os.remove(tmp)
                status[title.path] = 'failed'
            end
            running = running - 1
            app.render()
            start_jobs()
        end)
    end
    attempt(1)
end

start_jobs = function()
    while running < MAX_JOBS and #queue > 0 do
        running = running + 1
        make(table.remove(queue, 1))
    end
end

-- True when the thumbnail is on disk. Otherwise queues it (if enabled) and returns false.
local function ready(title)
    if status[title.path] == nil then
        if fs.file_size(cache_file(title)) == BYTES then
            status[title.path] = 'ok'
        elseif app.opts.posters then
            status[title.path] = 'pending'
            queue[#queue + 1] = title
            start_jobs()
        end
    end
    return status[title.path] == 'ok'
end

function posters.retry_failed()
    for path, st in pairs(status) do
        if st == 'failed' then status[path] = nil end
    end
end

--[[ On screen. Each thumbnail is an mpv overlay; ids 0..39 are ours (thumbfast uses 42). ]]

local MAX_OVERLAYS = 40
local shown, shown_this_frame = {}, {}

-- Show the title's thumbnail in the pixel rectangle x, y, w, h, cut off after visible_w
-- pixels. Does nothing while the thumbnail is still being made.
function posters.show(id, title, x, y, w, h, visible_w)
    if id >= MAX_OVERLAYS or visible_w <= 0 or not ready(title) then return end
    -- to cut off the right side, read fewer source columns (same row stride) and scale them the same
    local src_w, dst_w = WIDTH, w
    if visible_w < w then
        src_w = math.floor(WIDTH * visible_w / w)
        dst_w = math.floor(src_w * w / WIDTH)
    end
    mp.command_native({ 'overlay-add', id, x, y, cache_file(title), 0, 'bgra', src_w, HEIGHT, WIDTH * 4, dst_w, h })
    shown_this_frame[id] = true
end

-- Call after drawing a frame: removes the thumbnails it didn't show again.
function posters.end_frame()
    for id in pairs(shown) do
        if not shown_this_frame[id] then mp.command_native({ 'overlay-remove', id }) end
    end
    shown, shown_this_frame = shown_this_frame, {}
end

function posters.hide_all()
    for id in pairs(shown) do mp.command_native({ 'overlay-remove', id }) end
    shown, shown_this_frame = {}, {}
end

return posters
