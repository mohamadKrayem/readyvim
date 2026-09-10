-- Multicursor plugin configuration
return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	config = function()
		local mc = require("multicursor-nvim")
		mc.setup()

		local set = vim.keymap.set

		-- Add or skip cursor above/below the main cursor.
		set({ "n", "x" }, "<up>", function()
			mc.lineAddCursor(-1)
		end)
		set({ "n", "x" }, "<down>", function()
			mc.lineAddCursor(1)
		end)
		set({ "n", "x" }, "<leader><up>", function()
			mc.lineSkipCursor(-1)
		end)
		set({ "n", "x" }, "<leader><down>", function()
			mc.lineSkipCursor(1)
		end)

		-- Add or skip adding a new cursor by matching word/selection
		-- Alt/Meta key bindings (may not work in all terminals)
		set({ "n", "x" }, "<M-d>", function()
			mc.matchAddCursor(1)
		end)
		set({ "n", "x" }, "<M-f>", function()
			mc.matchSkipCursor(1)
		end)
		set({ "n", "x" }, "<M-a>", function()
			mc.matchAllAddCursors()
		end)

		-- Leader key alternatives (more reliable)
		set({ "n", "x" }, "<leader>j", function()
			mc.matchAddCursor(1)
		end, { desc = "Add cursor to next match" })
		set({ "n", "x" }, "<leader>k", function()
			mc.matchAddCursor(-1)
		end, { desc = "Add cursor to prev match" })
		set({ "n", "x" }, "<leader>J", function()
			mc.matchSkipCursor(1)
		end, { desc = "Skip next match" })
		set({ "n", "x" }, "<leader>K", function()
			mc.matchSkipCursor(-1)
		end, { desc = "Skip prev match" })
		set({ "n", "x" }, "<leader>A", function()
			mc.matchAllAddCursors()
		end, { desc = "Add cursor to all matches" })

		-- Add and remove cursors with control + left click.
		set("n", "<C-LeftMouse>", mc.handleMouse)
		set("n", "<C-LeftDrag>", mc.handleMouseDrag)
		set("n", "<C-LeftRelease>", mc.handleMouseRelease)

		-- Add cursor at the current position
		set("n", "<leader>mc", function()
			mc.addCursor()
		end)

		-- Add cursor on each line of a paragraph
		set("n", "ga", mc.addCursorOperator)

		-- Align cursor columns
		set("n", "<leader>ma", mc.alignCursors)

		-- Duplicate cursors
		set({ "n", "x" }, "<leader>md", mc.duplicateCursors)

		-- Disable and enable cursors (changed from <C-q> due to conflict with quit)
		set({ "n", "x" }, "<leader>mt", mc.toggleCursor, { desc = "Toggle cursors on/off" })

		-- Restore cursors if accidentally cleared
		set("n", "<leader>gv", mc.restoreCursors)

		-- Mappings defined in a keymap layer only apply when there are
		-- multiple cursors. This lets you have overlapping mappings.
		mc.addKeymapLayer(function(layerSet)
			-- Select a different cursor as the main one.
			layerSet({ "n", "x" }, "<Left>", mc.prevCursor)
			layerSet({ "n", "x" }, "<Right>", mc.nextCursor)

			-- Delete the main cursor.
			layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

			-- Enable and clear cursors using escape.
			layerSet("n", "<esc>", function()
				if not mc.cursorsEnabled() then
					mc.enableCursors()
				else
					mc.clearCursors()
				end
			end)
		end)

		-- Customize how cursors look.
		local hl = vim.api.nvim_set_hl
		hl(0, "MultiCursorCursor", { reverse = true })
		hl(0, "MultiCursorVisual", { link = "Visual" })
		hl(0, "MultiCursorSign", { link = "SignColumn" })
		hl(0, "MultiCursorMatchPreview", { link = "Search" })
		hl(0, "MultiCursorDisabledCursor", { reverse = true })
		hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
		hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
	end,
}
