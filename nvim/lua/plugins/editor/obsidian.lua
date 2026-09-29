-- Notes: a folder of plain Markdown files at ~/personal/notes, with links
-- between notes, backlinks and daily notes. No Obsidian app needed - though
-- it can open the same folder as a vault if you ever want it.
--
-- * <leader>on new note, <leader>ot today's note, <leader>of find a note by
--   name, <leader>os search inside notes, <leader>ob what links here.
-- * Inside a note: <CR> follows a link or toggles a checkbox, ]o / [o jump
--   between links, and typing [[ completes note names.
--
-- markview already renders the Markdown, so obsidian's own rendering is off
-- to keep the two from drawing over each other.
local vault = vim.fn.expand("~/personal/notes")

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- latest release, not main
	cmd = "Obsidian",
	-- Only wake up for files inside the vault. `*` crosses directories in an
	-- autocmd pattern, so this covers daily/ and any other subfolder too.
	event = {
		"BufReadPre " .. vault .. "/*.md",
		"BufNewFile " .. vault .. "/*.md",
	},
	init = function()
		-- obsidian refuses to start on a workspace that does not exist yet.
		vim.fn.mkdir(vault, "p")
	end,
	opts = {
		legacy_commands = false,
		workspaces = { { name = "notes", path = vault } },
		-- Readable file names from the title ("Meeting notes" ->
		-- meeting-notes.md) instead of the default random timestamp id.
		note_id_func = function(...)
			return require("obsidian.builtin").title_id(...)
		end,
		new_notes_location = "notes_subdir",
		daily_notes = { folder = "daily", workdays_only = false },
		picker = { name = "telescope.nvim" },
		ui = { enable = false },
	},
	keys = {
		{ "<leader>on", "<cmd>Obsidian new<CR>", desc = "N[o]tes: [N]ew note" },
		{ "<leader>ot", "<cmd>Obsidian today<CR>", desc = "N[o]tes: [T]oday's daily note" },
		{ "<leader>of", "<cmd>Obsidian quick_switch<CR>", desc = "N[o]tes: [F]ind a note by name" },
		{ "<leader>os", "<cmd>Obsidian search<CR>", desc = "N[o]tes: [S]earch inside notes" },
		{ "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "N[o]tes: [B]acklinks to this note" },
	},
}
