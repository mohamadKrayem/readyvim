-- Keep the enclosing function, class or block pinned at the top of the
-- window while you scroll through its body, so you always know where you are.
--
-- * [x  jump up to the line that is pinned (the start of the conteXt).
--       Not [c: gitsigns and the class motion already share that one.
return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		max_lines = 3, -- at most three levels of nesting, so it never eats the screen
		multiline_threshold = 1, -- one line per level: the def, not its whole signature
	},
	keys = {
		{
			"[x",
			function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end,
			desc = "Jump to the pinned context",
		},
	},
}
