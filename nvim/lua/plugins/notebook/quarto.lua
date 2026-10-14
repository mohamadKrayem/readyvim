-- Language-server features inside notebook cells - completion, go to
-- definition, hover, rename - which basedpyright can't give a Markdown file
-- on its own (otter.nvim feeds it the cells). Also runs cells through molten:
-- <leader>ir the cell under the cursor, <leader>ia it and everything above,
-- <leader>iA all of them.
--
-- Only switched on for notebooks: other Markdown files are left alone.
return {
	"quarto-dev/quarto-nvim",
	dependencies = { "jmbuhr/otter.nvim", "nvim-treesitter/nvim-treesitter" },
	ft = "markdown",
	opts = {
		lspFeatures = {
			enabled = true,
			languages = { "python" },
			chunks = "all",
			diagnostics = { enabled = true, triggers = { "BufWritePost" } },
			completion = { enabled = true },
		},
		codeRunner = { enabled = true, default_method = "molten" },
	},
	config = function(_, opts)
		require("quarto").setup(opts)

		local function activate(buf)
			if vim.api.nvim_buf_get_name(buf):match("%.ipynb$") then
				require("quarto").activate()
				local runner = require("quarto.runner")
				local map = function(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, desc = "Notebook: " .. desc })
				end
				map("<leader>ir", runner.run_cell, "run the cell")
				map("<leader>ia", runner.run_above, "run this cell and every one above")
				map("<leader>iA", runner.run_all, "run all cells")
			end
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("notebook.quarto", { clear = true }),
			pattern = "markdown",
			callback = function(e)
				activate(e.buf)
			end,
		})
		-- The notebook that triggered this lazy load is already open.
		activate(vim.api.nvim_get_current_buf())
	end,
}
