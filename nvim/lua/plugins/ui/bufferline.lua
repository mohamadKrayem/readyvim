return {
	"akinsho/bufferline.nvim",
	dependencies = {
		"moll/vim-bbye",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("bufferline").setup({
			options = {
				mode = "buffers", -- one entry per buffer, not per tabpage
				themable = true, -- lets the highlights block below take effect
				numbers = "none",
				close_command = "Bdelete! %d", -- vim-bbye: closes without wrecking the layout
				buffer_close_icon = "✗",
				close_icon = "✗",
				path_components = 1, -- filename only
				modified_icon = "●",
				left_trunc_marker = "",
				right_trunc_marker = "",
				max_name_length = 30,
				max_prefix_length = 30, -- how much path to show when two buffers share a name
				tab_size = 21,
				diagnostics = false,
				diagnostics_update_in_insert = false,
				color_icons = true,
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_close_icon = true,
				persist_buffer_sort = true, -- manual reordering survives a restart
				separator_style = { "│", "│" },
				enforce_regular_tabs = true,
				always_show_bufferline = true,
				show_tab_indicators = false,
				-- Active vs inactive tabs are told apart by font color (see highlights).
				indicator = {
					style = "none",
				},
				icon_pinned = "󰐃",
				minimum_padding = 1,
				maximum_padding = 5,
				maximum_length = 15,
				sort_by = "insert_at_end",
			},
			highlights = {
				separator = {
					fg = "#434C5E",
				},
				-- Inactive tabs: dim / "sleepy".
				background = {
					fg = "#5c6370",
				},
				buffer_visible = {
					fg = "#5c6370",
				},
				-- Current tab: bright / "lightning".
				buffer_selected = {
					fg = "#ffffff",
					bold = true,
					italic = false,
				},
			},
		})
	end,
}
