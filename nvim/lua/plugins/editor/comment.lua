-- Line/selection commenting.
--
-- Three keys are bound to the same toggle because terminals disagree about
-- what Ctrl+/ actually sends: some emit <C-_>, some <C-/>, and <C-c> is a
-- fallback that works everywhere. Binding all three means the same chord
-- works in every terminal without per-machine config.
return {
	"numToStr/Comment.nvim",
	opts = {},
	config = function()
		local opts = { noremap = true, silent = true }
		local toggle_line = require("Comment.api").toggle.linewise.current
		local toggle_selection = "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>"

		for _, key in ipairs({ "<C-_>", "<C-c>", "<C-/>" }) do
			vim.keymap.set("n", key, toggle_line, opts)
			vim.keymap.set("v", key, toggle_selection, opts)
		end
	end,
}
