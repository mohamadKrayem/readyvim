-- Find and replace across the whole project, with a live preview of every
-- change before anything is written.
--
-- * <leader>fr  open it, with the word under the cursor already filled in
--               (on a visual selection: the selection)
--
-- Fill in Search and Replace, check the preview, then <localleader>r
-- (Space r) replaces everywhere. Files/Flags narrow it down, e.g. *.lua
-- or --ignore-case.
return {
	"MagicDuck/grug-far.nvim",
	cmd = "GrugFar",
	opts = {},
	keys = {
		{
			"<leader>fr",
			function()
				require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
			end,
			desc = "[F]ind and [R]eplace in the project",
		},
		{
			"<leader>fr",
			function()
				require("grug-far").with_visual_selection()
			end,
			mode = "x",
			desc = "[F]ind and [R]eplace the selection in the project",
		},
	},
}
