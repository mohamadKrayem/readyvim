-- Small plugins that need little or no configuration. Anything that grows past
-- a few lines of setup earns its own file.
return {
	-- Ctrl+h/j/k/l moves across nvim splits and tmux panes interchangeably.
	-- The matching half of this lives in ~/.tmux.conf.
	{ "christoomey/vim-tmux-navigator" },

	-- Infers indent width from the file being edited, which is why opening
	-- someone else's 4-space project doesn't fight the 2-space default set
	-- in config/options.lua.
	{ "tpope/vim-sleuth" },

	-- :Git / :Gdiffsplit etc. The heavyweight git workflow; gitsigns covers
	-- the in-buffer hunk work.
	{ "tpope/vim-fugitive" },

	-- Teaches fugitive about GitHub - :GBrowse, issue/PR completion.
	{ "tpope/vim-rhubarb" },

	-- Popup showing what a half-typed prefix can still expand to.
	{ "folke/which-key.nvim" },

	-- Close brackets and quotes as they're typed.
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		opts = {},
	},

	-- Flag TODO / FIXME / HACK in comments. Signs off - the sign column is
	-- already carrying git and diagnostics.
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	-- Paint colour literals (#ff0000, rgb(...)) in their own colour.
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
}
