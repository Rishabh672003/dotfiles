-- File helpers: which files are media, natural sorting, folder listings, paths.
local utils = require 'mp.utils'
local app = require 'app'

local fs = {}

local media_exts = {}
for ext in app.opts.exts:gmatch('[^,%s]+') do media_exts[ext:lower()] = true end

function fs.is_media(name)
    local ext = name:match('%.([^.]+)$')
    return ext ~= nil and media_exts[ext:lower()] == true
end

-- Release "sample" clips: "sample.mkv", "movie-sample.mkv", anything inside "Sample/"
local function is_sample(path)
    local lower = path:lower()
    return lower:match('/sample/') or lower:match('/sample%.[^/]+$') or lower:match('[%.%-_ ]sample%.[^./]+$')
end

-- Sort key that compares numbers as numbers, so "Ep 2" comes before "Ep 10"
function fs.natural_key(s)
    return s:lower():gsub('%d+', function(n) return ('%012d'):format(tonumber(n)) end)
end

function fs.natural_sort(list)
    table.sort(list, function(a, b) return fs.natural_key(a) < fs.natural_key(b) end)
    return list
end

local function is_hidden(name)
    return name:sub(1, 1) == '.'
end

local function read_dir(dir, kind)
    return fs.natural_sort(utils.readdir(dir, kind) or {})
end

-- Every media file under dir, recursively. A folder's own files come before its
-- subfolders (main movie before Extras/), and sample clips go last.
function fs.collect(dir)
    local main, samples = {}, {}
    local function walk(folder)
        for _, name in ipairs(read_dir(folder, 'files')) do
            if fs.is_media(name) then
                local path = utils.join_path(folder, name)
                local list = is_sample(path) and samples or main
                list[#list + 1] = path
            end
        end
        for _, name in ipairs(read_dir(folder, 'dirs')) do
            if not is_hidden(name) then walk(utils.join_path(folder, name)) end
        end
    end
    walk(dir)
    for _, path in ipairs(samples) do main[#main + 1] = path end
    return main
end

-- One folder's entries for the Files tab, subfolders first: { name, path, is_dir }
function fs.list_dir(dir)
    local entries = {}
    for _, name in ipairs(read_dir(dir, 'dirs')) do
        if not is_hidden(name) then
            entries[#entries + 1] = { name = name, path = utils.join_path(dir, name), is_dir = true }
        end
    end
    for _, name in ipairs(read_dir(dir, 'files')) do
        if fs.is_media(name) then
            entries[#entries + 1] = { name = name, path = utils.join_path(dir, name) }
        end
    end
    return entries
end

-- Size in bytes, or nil if the file can't be opened
function fs.file_size(path)
    local f = io.open(path, 'rb')
    if not f then return nil end
    local size = f:seek('end')
    f:close()
    return size
end

-- "/a/b/Movie.mkv" -> "Movie"
function fs.basename(path)
    return ((path:match('([^/]+)$') or path):gsub('%.[^.]+$', ''))
end

-- "/a/b/Movie.mkv" -> "/a/b"
function fs.parent(path)
    return path:match('^(.*)/[^/]+$')
end

-- "/home/me/Videos" -> "~/Videos"
function fs.short_path(path)
    if path == app.HOME then return '~' end
    if path:sub(1, #app.HOME + 1) == app.HOME .. '/' then return '~' .. path:sub(#app.HOME + 1) end
    return path
end

-- Short stable id for a path, used in cache file names
function fs.hash(s)
    local h = 5381
    for i = 1, #s do h = (h * 33 + s:byte(i)) % 4294967296 end
    return ('%08x%x'):format(h, #s)
end

function fs.index_of(list, value)
    for i, item in ipairs(list) do
        if item == value then return i end
    end
end

return fs
