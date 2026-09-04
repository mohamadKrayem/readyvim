-- lf file manager (testing as a replacement for yazi on the try-lf branch).
-- Requires the `lf` binary on PATH:  brew install lf
-- Opens lf in a floating terminal (via vim-floaterm) and opens the file you
-- pick in a NEW TAB in this nvim instance.
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
		-- Enter on a file opens it in a new tab (lf is always launched from nvim).
		vim.g.floaterm_opener = "tabe"

		-- Make the floating window blend with the active colorscheme, and keep
		-- it in sync when the theme changes (via the <leader>ut picker).
		local function theme()
			vim.api.nvim_set_hl(0, "Floaterm", { link = "Normal" })
			vim.api.nvim_set_hl(0, "FloatermBorder", { link = "FloatBorder" })
		end
		theme()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = theme })
	end,
}
