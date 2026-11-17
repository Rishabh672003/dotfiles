-- Remembers the last file played in each title, so a title can be resumed.
-- Saved in <cache>/state.json as { [title path] = { file = path, t = os.time() } }.
local mp = require 'mp'
local utils = require 'mp.utils'
local app = require 'app'

local history = {}

local state_file = app.cache_dir .. '/state.json'

local function load()
    local f = io.open(state_file, 'r')
    if not f then return {} end
    local entries = utils.parse_json(f:read('*a')) or {}
    f:close()
    -- older versions saved just the file path
    for key, value in pairs(entries) do
        if type(value) == 'string' then entries[key] = { file = value, t = 0 } end
    end
    return entries
end

local entries = load()

local function save()
    local f = io.open(state_file, 'w')
    if not f then return end
    f:write(utils.format_json(entries))
    f:close()
end

-- The title's last played file, or nil if there is none or it's no longer part of the title
function history.last_played(title)
    local entry = entries[title.path]
    if not entry then return nil end
    for _, file in ipairs(title.files) do
        if file == entry.file then return file end
    end
end

-- When the title was last played (os.time()), 0 if never
function history.played_at(title)
    local entry = entries[title.path]
    return entry and entry.t or 0
end

-- A title is a folder directly inside a library folder, or a loose file in it
local function title_path_of(path)
    for _, root in ipairs(app.roots) do
        if path:sub(1, #root + 1) == root .. '/' then
            local folder = path:sub(#root + 2):match('^([^/]+)/')
            return folder and (root .. '/' .. folder) or path
        end
    end
end

mp.register_event('file-loaded', function()
    local path = mp.get_property('path', '')
    local title_path = title_path_of(path)
    if title_path then
        entries[title_path] = { file = path, t = os.time() }
        save()
    end
end)

return history
