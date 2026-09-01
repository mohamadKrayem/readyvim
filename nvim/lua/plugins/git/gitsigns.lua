-- Adds git related signs to the gutter, as well as utilities for managing changes
return {
	"lewis6991/gitsigns.nvim",
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		signs_staged = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		-- Inline "author, time ago - summary" at the end of the current line.
		-- On by default; toggle with <leader>gB.
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 300,
			virt_text_pos = "eol",
		},
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local function map(keys, fn, desc)
				vim.keymap.set("n", keys, fn, { buffer = bufnr, desc = "Git: " .. desc })
			end
			-- Full blame popup for the current line (author, date, commit, message).
			map("<leader>gb", function()
				gs.blame_line({ full = true })
			end, "[B]lame line (full)")
			-- Toggle the inline end-of-line blame.
			map("<leader>gB", gs.toggle_current_line_blame, "Toggle inline [B]lame")
			-- Preview the diff hunk under the cursor.
			map("<leader>gp", gs.preview_hunk, "[P]review hunk")
			-- Open the FULL commit (message + diff) that last changed this line,
			-- in a navigable fugitive buffer.
			map("<leader>gc", function()
				local line = vim.fn.line(".")
				local file = vim.fn.expand("%:p")
				local dir = vim.fn.expand("%:p:h")
				local out = vim.fn.systemlist({
					"git",
					"-C",
					dir,
					"blame",
					"-L",
					line .. "," .. line,
					"--porcelain",
					file,
				})
				local hash = out[1] and out[1]:match("^(%x+)")
				if not hash or hash == "" then
					vim.notify("No commit found for this line", vim.log.levels.WARN)
					return
				end
				if hash:match("^0+$") then
					vim.notify("This line is not committed yet", vim.log.levels.INFO)
					return
				end
				vim.cmd("Git show " .. hash)
			end, "Show full [C]ommit for line")
			-- Jump between changed hunks.
			map("]c", function()
				gs.nav_hunk("next")
			end, "Next hunk")
			map("[c", function()
				gs.nav_hunk("prev")
			end, "Prev hunk")
		end,
	},
}
