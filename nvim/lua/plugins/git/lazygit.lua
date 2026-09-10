-- nvim v0.8.0
return {
	"kdheepak/lazygit.nvim",
	lazy = true,
	-- Called by the lazygit `os.edit` command (see lazygit config.yml) via
	-- `nvim --server $NVIM --remote-expr`. While lazygit is open its float is the
	-- "current" window, so we can't rely on nvim's --remote file opening. Instead
	-- we pick the real editing window ourselves, close the lazygit float, and
	-- open the file there (jumping to it if it's already visible via :drop).
	init = function()
		function _G.LazygitEdit(file, line)
			vim.schedule(function()
				-- Find the real editing window (non-floating, non-terminal).
				local target
				for _, w in ipairs(vim.api.nvim_list_wins()) do
					local cfg = vim.api.nvim_win_get_config(w)
					local b = vim.api.nvim_win_get_buf(w)
					if cfg.relative == "" and vim.bo[b].buftype ~= "terminal" then
						target = w
						break
					end
				end
				-- Close the lazygit floating terminal(s).
				for _, w in ipairs(vim.api.nvim_list_wins()) do
					local ok, cfg = pcall(vim.api.nvim_win_get_config, w)
					if ok and cfg.relative ~= "" then
						local b = vim.api.nvim_win_get_buf(w)
						if vim.bo[b].buftype == "terminal" then
							pcall(vim.api.nvim_win_close, w, true)
							pcall(vim.api.nvim_buf_delete, b, { force = true })
						end
					end
				end
				vim.g.lazygit_opened = 0
				if target and vim.api.nvim_win_is_valid(target) then
					vim.api.nvim_set_current_win(target)
				end
				-- :drop jumps to the file if already open in a window/tab,
				-- otherwise edits it in the current (editing) window.
				vim.cmd("drop " .. vim.fn.fnameescape(file))
				local ln = tonumber(line)
				if ln and ln > 0 then
					pcall(vim.api.nvim_win_set_cursor, 0, { ln, 0 })
				end
			end)
			return ""
		end
	end,
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	-- optional for floating window border decoration
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	-- setting the keybinding for LazyGit with 'keys' is recommended in
	-- order to load the plugin when the command is run for the first time
	keys = {
		{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
	},
}
