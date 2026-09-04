-- lf file manager (testing as a replacement for yazi on the try-lf branch),
-- via floaterm's native lf integration. Requires the `lf` binary: brew install lf
-- Enter/l on a file sends it back to nvim and opens it in a NEW TAB.
return {
	"voldikss/vim-floaterm",
	cmd = { "FloatermNew", "FloatermToggle" },
	keys = {
		{
			"<leader>-",
			function()
				local dir = vim.fn.expand("%:p:h")
				if dir == "" then
					dir = vim.fn.getcwd()
				end
				vim.cmd("FloatermNew --name=lf --width=0.9 --height=0.9 --title=lf lf " .. vim.fn.fnameescape(dir))
			end,
			desc = "Open lf at the current file",
		},
		{
			"<leader>cw",
			"<cmd>FloatermNew --name=lf --width=0.9 --height=0.9 --title=lf lf<cr>",
			desc = "Open lf in the working directory",
		},
	},
	init = function()
		-- Open the picked file as a buffer (shows as a tab in the bufferline,
		-- single tabpage — so no leftover dashboard tab and :q quits cleanly).
		vim.g.floaterm_opener = "drop"
		vim.g.floaterm_borderchars = "─│─│╭╮╯╰"

		-- Blend the floating window with the active colorscheme (and keep it in
		-- sync when you switch themes with <leader>ut).
		local function theme()
			vim.api.nvim_set_hl(0, "Floaterm", { link = "Normal" })
			vim.api.nvim_set_hl(0, "FloatermBorder", { link = "FloatBorder" })
		end
		theme()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = theme })
	end,
}
