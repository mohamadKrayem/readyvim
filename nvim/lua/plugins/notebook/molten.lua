-- Run code in a Jupyter kernel and see the output right under it.
--
-- In a notebook (.ipynb, opened as Markdown by jupytext.lua) the kernel starts
-- by itself - the project's own kernel when its .venv has one, otherwise the
-- one the notebook was saved with - and the outputs already stored in the file
-- are shown. Saving writes new outputs back.
-- In a plain .py file, <leader>ii starts a kernel first.
--
-- * <leader>ir  run the code cell under the cursor   (notebooks, via quarto)
-- * <leader>ia  run every cell above, and this one   (notebooks)
-- * <leader>iA  run all cells                        (notebooks)
-- * <leader>il  run the current line
-- * <leader>ir  on a visual selection: run the selection
-- * <leader>ie  run an operator: <leader>ieip runs the paragraph
-- * <leader>io  open / enter the output window (scroll it, copy from it)
-- * <leader>ih  hide the output
-- * <leader>id  delete the cell's output
-- * <leader>ii  start a kernel (asks which)
--
-- Plots open in Preview: Warp can't draw images inside tmux, so there's no
-- inline image provider.
return {
	"benlubas/molten-nvim",
	version = "^1.0.0",
	build = ":UpdateRemotePlugins",
	init = function()
		vim.g.molten_image_provider = "none"
		vim.g.molten_auto_image_popup = true -- plots open in Preview
		vim.g.molten_auto_open_output = false -- output shows as text under the cell instead
		vim.g.molten_virt_text_output = true
		vim.g.molten_virt_lines_off_by_1 = true -- below the closing ``` of a notebook cell
		vim.g.molten_wrap_output = true
		vim.g.molten_output_win_max_height = 20

		-- Open a notebook: start the kernel of the project it sits in (the
		-- nearest .venv above it, registered by <leader>is), else the kernel it
		-- was saved with, else one named after the active venv. Then show its
		-- stored outputs.
		local function init_notebook(e)
			vim.schedule(function()
				local kernels = vim.fn.MoltenAvailableKernels()
				local proj = _G.NotebookProjectKernel and _G.NotebookProjectKernel(vim.fs.dirname(vim.fs.abspath(e.file)))
				local ok, name = true, proj and proj.name
				if not (name and vim.tbl_contains(kernels, name)) then
					ok, name = pcall(function()
						return vim.json.decode(io.open(e.file, "r"):read("a")).metadata.kernelspec.name
					end)
				end
				if not ok or not vim.tbl_contains(kernels, name) then
					name = nil
					local active = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
					if active then
						name = active:match("/.+/(.+)")
					end
				end
				if name and vim.tbl_contains(kernels, name) then
					vim.cmd(("MoltenInit %s"):format(name))
				end
				vim.cmd("MoltenImportOutput")
			end)
		end

		local group = vim.api.nvim_create_augroup("notebook.molten", { clear = true })
		vim.api.nvim_create_autocmd("BufAdd", { group = group, pattern = "*.ipynb", callback = init_notebook })
		-- BufAdd misses the file nvim was started with (nvim notes.ipynb).
		vim.api.nvim_create_autocmd("BufEnter", {
			group = group,
			pattern = "*.ipynb",
			callback = function(e)
				if vim.v.vim_did_enter ~= 1 then
					init_notebook(e)
				end
			end,
		})
		-- Save: write the outputs of cells you ran back into the .ipynb.
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = group,
			pattern = "*.ipynb",
			callback = function()
				if require("molten.status").initialized() == "Molten" then
					vim.cmd("MoltenExportOutput!")
				end
			end,
		})

		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { silent = true, desc = "Notebook: " .. desc })
		end
		map("n", "<leader>ii", ":MoltenInit<CR>", "start a kernel")
		map("n", "<leader>ie", ":MoltenEvaluateOperator<CR>", "run an operator")
		map("n", "<leader>il", ":MoltenEvaluateLine<CR>", "run the line")
		map("x", "<leader>ir", ":<C-u>MoltenEvaluateVisual<CR>gv", "run the selection")
		map("n", "<leader>io", ":noautocmd MoltenEnterOutput<CR>", "open / enter the output")
		map("n", "<leader>ih", ":MoltenHideOutput<CR>", "hide the output")
		map("n", "<leader>id", ":MoltenDelete<CR>", "delete the cell's output")
	end,
}
