-- Every edit nvim remembers, as a tree - including the branches plain u can
-- no longer reach after you undo and then type something new. undofile is on
-- (config/options.lua), so the history survives closing the file.
--
-- * <leader>U  toggle the tree. Move through it with j/k to preview each
--              state in the buffer, <CR> to restore it, q to close.
return {
	"mbbill/undotree",
	cmd = "UndotreeToggle",
	init = function()
		vim.g.undotree_SetFocusWhenToggle = 1 -- jump into the tree when it opens
		vim.g.undotree_WindowLayout = 2 -- tree on the left, diff along the bottom
	end,
	keys = {
		{ "<leader>U", "<cmd>UndotreeToggle<CR>", desc = "[U]ndo tree" },
	},
}
