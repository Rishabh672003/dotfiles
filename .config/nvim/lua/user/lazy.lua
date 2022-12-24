local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.runtimepath:prepend(lazypath)

-- example using a list of specs with the default options
vim.g.mapleader = " " -- make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup({
	"lewis6991/impatient.nvim",
	{ "folke/which-key.nvim", lazy = true },
	"nvim-lua/popup.nvim",
	"nvim-lua/plenary.nvim",
	"windwp/nvim-autopairs",
	{ "catppuccin/nvim", name = "catppuccin" },
	"folke/tokyonight.nvim",
	{
		"hrsh7th/nvim-cmp",
		-- load cmp on InsertEnter
		event = "InsertEnter",
		-- these dependencies will only be loaded when cmp loads
		-- dependencies are always lazy-loaded unless specified otherwise
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
		},
		{ "stevearc/dressing.nvim", event = "VeryLazy" },
	},
	"antoinemadec/FixCursorHold.nvim",
	"jose-elias-alvarez/null-ls.nvim",
	"RRethy/vim-illuminate",
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",
	{ "b0o/schemastore.nvim", lazy = true },
	{ "is0n/jaq-nvim", lazy = true },
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-telescope/telescope-file-browser.nvim",
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/playground",
			"JoosepAlviste/nvim-ts-context-commentstring",
			"kyazdani42/nvim-web-devicons",
		},
	},
	"goolord/alpha-nvim",
	"Darazaki/indent-o-matic",
	"MunifTanjim/nui.nvim",
	{ "numToStr/Comment.nvim", lazy = true },
	{ "lewis6991/gitsigns.nvim", lazy = true },
	{
		"kyazdani42/nvim-tree.lua",
		tag = "nightly", -- optional, updated every week. (see issue #1193)
		lazy = true,
	},
	{ "ghillb/cybu.nvim" },
	{ "akinsho/toggleterm.nvim", lazy = true },
	"nvim-lualine/lualine.nvim",
	"ahmedkhalf/project.nvim",
	"lukas-reineke/indent-blankline.nvim",
	{ "NvChad/nvim-colorizer.lua", lazy = true },
	{ "ellisonleao/glow.nvim", lazy = true },
	"rcarriga/nvim-notify",
	"stevearc/dressing.nvim",
	{
		"ziontee113/icon-picker.nvim",
		config = function()
			require("icon-picker")
		end,
	},
	"SmiteshP/nvim-navic",
	"utilyre/barbecue.nvim",
	"max397574/better-escape.nvim",
	{
		"phaazon/hop.nvim",
		branch = "v2", -- optional but strongly recommended
	},
	"folke/zen-mode.nvim",
	"ThePrimeagen/vim-be-good",
	"andweeb/presence.nvim",
	{ "mfussenegger/nvim-dap", commit = "6b12294a57001d994022df8acbe2ef7327d30587", lazy = true },
	{ "rcarriga/nvim-dap-ui", commit = "1cd4764221c91686dcf4d6b62d7a7b2d112e0b13", lazy = true },
	{ "ravenxrz/DAPInstall.nvim", commit = "8798b4c36d33723e7bba6ed6e2c202f84bb300de", lazy = true },
	{ "mfussenegger/nvim-dap-python", commit = "27a0eff2bd3114269bb010d895b179e667e712bd", lazy = true },
})
