-- From script-opts/subsync.conf
local options = require 'mp.options'

local settings = {
    accent = 'f2b134',
    span = 24,      -- seconds shown on the timeline at first (the wheel zooms)
    bottom = 48,    -- pixels kept free under the bar for uosc's timeline (scaled like uosc)
    waveform = true,
}
options.read_options(settings, 'subsync')

return settings
