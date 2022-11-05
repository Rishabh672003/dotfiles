require("user.whichkey")
require("user.options")
require("user.autocommands")
require("user.plugins")
require("user.cybu")
require("user.zen-mode")
require("user.illuminate")
require("user.lsp")
require('lab').setup {
  code_runner = {
    enabled = true,
  },
  quick_data = {
    enabled = true,
  }
}

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "black", filetypes = { "python" } },
}
