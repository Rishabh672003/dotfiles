-- Builds the library's tabs from the configured folders.
--
-- A tab ("section") is { name, titles }, plus resume = true for Continue and
-- browse = true for Files.
-- A title is { name, path, files }, plus dir = path when it's a folder. It is either a
-- folder directly inside a library folder (with every media file under it) or a loose file.
local utils = require 'mp.utils'
local app = require 'app'
local fs = require 'fs'
local history = require 'history'

local catalog = {}

-- "The.Devils.1971.BFI.Upscale.1080p..." -> "The Devils (1971)"
function catalog.pretty_name(name)
    local s = name:gsub('[._-]', ' '):gsub('%s+', ' ')
    local title, year = s:match('^(.-)%s+[%(%[]?(%d%d%d%d)%f[^%d]')
    if title and title ~= '' and tonumber(year) >= 1900 and tonumber(year) <= 2099 then
        s = title .. ' (' .. year .. ')'
    else
        s = s:gsub('%s%d%d%d%d?p%f[^%w].*$', '') -- drop "1080p ..." and what follows
    end
    local capitalised = (' ' .. s):gsub(' (%l)', function(c) return ' ' .. c:upper() end)
    return capitalised:sub(2)
end

local function file_title(root, name)
    local path = utils.join_path(root, name)
    return { name = catalog.pretty_name(fs.basename(name)), path = path, files = { path } }
end

local function folder_title(root, name)
    local path = utils.join_path(root, name)
    local files = fs.collect(path)
    if #files == 0 then return nil end
    return { name = catalog.pretty_name(name), path = path, dir = path, files = files }
end

local function titles_in(root)
    local titles = {}
    for _, name in ipairs(utils.readdir(root, 'files') or {}) do
        if fs.is_media(name) then titles[#titles + 1] = file_title(root, name) end
    end
    for _, name in ipairs(utils.readdir(root, 'dirs') or {}) do
        if name:sub(1, 1) ~= '.' then titles[#titles + 1] = folder_title(root, name) end
    end
    return titles
end

local function by_name(a, b)
    return fs.natural_key(a.name) < fs.natural_key(b.name)
end

-- Titles with a last played file, most recently played first
local function continue_tab(sections)
    local started = {}
    for _, section in ipairs(sections) do
        for _, title in ipairs(section.titles) do
            if history.last_played(title) then started[#started + 1] = title end
        end
    end
    if #started == 0 then return nil end
    table.sort(started, function(a, b) return history.played_at(a) > history.played_at(b) end)
    return { name = 'Continue', titles = started, resume = true }
end

-- Continue first, one tab per library folder name (same-named folders share a tab), Files last
function catalog.scan()
    local sections, section_named = {}, {}
    for _, root in ipairs(app.roots) do
        local name = root:match('([^/]+)$') or root
        local section = section_named[name:lower()]
        if not section then
            section = { name = name, titles = {} }
            section_named[name:lower()] = section
            sections[#sections + 1] = section
        end
        for _, title in ipairs(titles_in(root)) do section.titles[#section.titles + 1] = title end
    end
    for _, section in ipairs(sections) do table.sort(section.titles, by_name) end

    local continue = continue_tab(sections)
    if continue then table.insert(sections, 1, continue) end
    sections[#sections + 1] = { name = 'Files', titles = {}, browse = true }
    return sections
end

return catalog
