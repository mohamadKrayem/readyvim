-- How diagnostics look. Loaded after plugins so it wins over colorscheme defaults.

-- Treesitter highlights at priority 100. LSP semantic tokens default to 125 and
-- would repaint everything a flatter colour, so drop them below treesitter.
-- See https://github.com/NvChad/NvChad/issues/1907
vim.hl.priorities.semantic_tokens = 95

vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		-- Lead with the error code (e.g. "[E1005] unexpected token") so the
		-- code is greppable and visible without opening the float.
		format = function(diagnostic)
			local code = diagnostic.code and string.format("[%s]", diagnostic.code) or ""
			return string.format("%s %s", code, diagnostic.message)
		end,
	},
	underline = false,
	update_in_insert = true,
	float = {
		source = true,
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = "󰌵 ",
		},
	},
})

-- The old config passed an `on_ready` key here to clear the virtual-text
-- background. vim.diagnostic.config() has no such option, so it was silently
-- dropped and never ran. Uncomment to actually get a transparent background -
-- it has to re-apply on every colorscheme change, which is why it's an autocmd.
--
-- vim.api.nvim_create_autocmd("ColorScheme", {
-- 	group = vim.api.nvim_create_augroup("DiagnosticTransparency", { clear = true }),
-- 	callback = function()
-- 		vim.cmd("highlight DiagnosticVirtualText guibg=NONE")
-- 	end,
-- })
