-- Review changes the way a pull request shows them: every changed file in a
-- panel on the left, a side-by-side diff on the right.
--
-- * <leader>gd  all uncommitted changes (press again to close)
-- * <leader>gh  history of the current file, one commit per entry
-- * <leader>gH  history of the whole branch
--
-- Inside the view: <Tab>/<S-Tab> next/previous file, - stages or unstages
-- the file under the cursor, q closes.
local function toggle(cmd)
	return function()
		if next(require("diffview.lib").views) then
			vim.cmd("DiffviewClose")
		else
			vim.cmd(cmd)
		end
	end
end

return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
	opts = {
		-- q closes the whole view from any of its windows, like lazygit.
		keymaps = {
			view = { { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close diffview" } } },
			file_panel = { { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close diffview" } } },
			file_history_panel = { { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close diffview" } } },
		},
	},
	keys = {
		{ "<leader>gd", toggle("DiffviewOpen"), desc = "[G]it [D]iff: review uncommitted changes" },
		{ "<leader>gh", toggle("DiffviewFileHistory %"), desc = "[G]it [H]istory of this file" },
		{ "<leader>gH", toggle("DiffviewFileHistory"), desc = "[G]it [H]istory of the branch" },
	},
}
