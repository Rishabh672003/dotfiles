-- reload("user.whichkey")
reload("user.options")
-- reload("user.autocommands")
reload("user.plugins")
reload("user.cybu")
reload("user.zen-mode")
reload("user.illuminate")
reload("user.lsp")
local formatters = reload("lvim.lsp.null-ls.formatters")
formatters.setup({
	{ command = "autopep8", filetypes = { "python" } },
	{ command = "prettier" },
})
lvim.format_on_save = true
