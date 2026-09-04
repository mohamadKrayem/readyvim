-- lf file manager (testing as a replacement for yazi on the try-lf branch).
-- Requires the `lf` binary on PATH:  brew install lf
-- Opens lf in a floating terminal (via vim-floaterm) and edits the file you
-- pick back in this nvim instance.
return {
	"ptzz/lf.vim",
	dependencies = { "voldikss/vim-floaterm" },
	cmd = { "Lf" },
	keys = {
		{ "<leader>-", "<cmd>Lf<cr>", desc = "Open lf at the current file" },
		{ "<leader>cw", "<cmd>Lf .<cr>", desc = "Open lf in the working directory" },
	},
	init = function()
		vim.g.lf_map_keys = 0 -- we set our own keys above
		vim.g.lf_replace_netrw = 0 -- don't hijack netrw
		vim.g.floaterm_width = 0.9
		vim.g.floaterm_height = 0.9
		vim.g.floaterm_borderchars = "─│─│╭╮╯╰"
	end,
}
