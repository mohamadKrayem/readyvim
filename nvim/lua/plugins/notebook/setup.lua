-- Getting a notebook to run, in one key each.
--
-- * <leader>is  set up the environment: the notebook venv (molten's Python
--               side + jupytext), a kernel for this project, a
--               pyrightconfig.json so the LSP sees the project's .venv (only if
--               the project has no pyright settings), and molten's
--               registration with nvim. Safe to run again - it only adds what
--               is missing or out of date. Runs in a split so you see it work.
-- * <leader>in  new notebook in the current folder, bound to this project's
--               kernel (python3 when the project has none), opened right away.
--
-- A project with its own .venv gets its own kernel, named after the folder
-- that holds the .venv, so a notebook can import the project's packages - and
-- notebooks opened anywhere under that folder use it. Without one, notebooks
-- use the global python3 kernel.
local notebook_venv = vim.fn.expand("~/.local/share/nvim-notebook")
local global_kernel_venv = vim.fn.expand("~/.local/share/jupyter-kernel-venv")

-- The project's own kernel: the nearest .venv at or above `dir` (the current
-- directory by default), so it is found from any subfolder of the project.
-- nil when there is no .venv to run a kernel in.
local function project_kernel(dir)
	local root = vim.fs.root(dir or vim.fn.getcwd(), function(name, path)
		return name == ".venv" and vim.fn.executable(path .. "/.venv/bin/python") == 1
	end)
	if not root then
		return nil
	end
	local name = vim.fs.basename(root):lower():gsub("[^%w%-_.]", "-")
	return { root = root, python = root .. "/.venv/bin/python", name = name }
end

-- molten.lua asks the same question when a notebook opens, so it starts the
-- project's kernel rather than whichever one the notebook was last saved with.
_G.NotebookProjectKernel = project_kernel

-- basedpyright doesn't find a project's .venv by itself, so imports from it
-- show as unresolved. Tell it where the venv is - but only when the project
-- has no pyright settings of its own, so nothing of yours is overridden.
-- Returns true when it wrote the file.
local function point_lsp_at_venv(root)
	if vim.uv.fs_stat(root .. "/pyrightconfig.json") then
		return false
	end
	local pyproject = root .. "/pyproject.toml"
	if vim.uv.fs_stat(pyproject) then
		local text = table.concat(vim.fn.readfile(pyproject), "\n")
		if text:find("%[tool%.pyright%]") or text:find("%[tool%.basedpyright%]") then
			return false
		end
	end
	vim.fn.writefile({ '{ "venvPath": ".", "venv": ".venv" }' }, root .. "/pyrightconfig.json")
	-- Language servers already running read their config at start.
	vim.cmd("silent! LspRestart")
	return true
end

local function setup()
	local proj = project_kernel()
	local q = vim.fn.shellescape

	-- uv when it's there (fast), plain venv + pip otherwise.
	local lines = {
		"set -e",
		"mkvenv() { if command -v uv >/dev/null; then uv venv -q \"$1\"; else python3 -m venv \"$1\"; fi; }",
		"pipi() { py=$1; shift; if command -v uv >/dev/null; then uv pip install -q --python \"$py\" \"$@\"; else \"$py\" -m pip install -q \"$@\"; fi; }",
		"",
		"echo '1/3  notebook environment: " .. notebook_venv:gsub(vim.pesc(vim.env.HOME), "~") .. "'",
		"[ -x " .. q(notebook_venv .. "/bin/python") .. " ] || mkvenv " .. q(notebook_venv),
		"pipi " .. q(notebook_venv .. "/bin/python") .. " pynvim jupyter_client nbformat jupytext pillow",
		"",
	}
	if proj then
		vim.list_extend(lines, {
			"echo '2/3  kernel for this project: " .. proj.name .. " (" .. proj.root:gsub(vim.pesc(vim.env.HOME), "~") .. "/.venv)'",
			"pipi " .. q(proj.python) .. " ipykernel",
			q(proj.python)
				.. " -m ipykernel install --user --name "
				.. q(proj.name)
				.. " --display-name "
				.. q("Python (" .. proj.name .. ")"),
		})
	else
		vim.list_extend(lines, {
			"echo '2/3  no .venv in this project - using the global python3 kernel'",
			"[ -x " .. q(global_kernel_venv .. "/bin/python") .. " ] || mkvenv " .. q(global_kernel_venv),
			"pipi " .. q(global_kernel_venv .. "/bin/python") .. " ipykernel",
			q(global_kernel_venv .. "/bin/python")
				.. " -m ipykernel install --user --name python3 --display-name 'Python 3'",
		})
	end
	vim.list_extend(lines, { "echo '3/3  registering molten with nvim'" })

	vim.cmd("botright 12new")
	local buf = vim.api.nvim_get_current_buf()
	vim.fn.jobstart({ "bash", "-c", table.concat(lines, "\n") }, {
		term = true,
		on_exit = function(_, code)
			vim.schedule(function()
				if code ~= 0 then
					vim.notify("Notebook setup failed - see the output above", vim.log.levels.ERROR)
					return
				end
				-- A first-time setup made the venv after startup, so point nvim
				-- at it now rather than waiting for a restart.
				vim.g.python3_host_prog = notebook_venv .. "/bin/python"
				if not vim.env.PATH:find(notebook_venv .. "/bin", 1, true) then
					vim.env.PATH = vim.env.PATH .. ":" .. notebook_venv .. "/bin" -- last: see python-env.lua
				end
				vim.cmd("silent UpdateRemotePlugins")
				if vim.api.nvim_buf_is_valid(buf) then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
				local wrote_config = proj and point_lsp_at_venv(proj.root)
				vim.notify(
					"Notebook environment ready"
						.. (proj and (" - kernel '" .. proj.name .. "'") or " - kernel 'python3'")
						.. (wrote_config and ", pyrightconfig.json added so the LSP sees .venv" or "")
						.. ". If this was the first setup, restart nvim once.",
					vim.log.levels.INFO
				)
			end)
		end,
	})
end

local function new_notebook()
	local python = notebook_venv .. "/bin/python"
	if vim.fn.executable(python) == 0 then
		vim.notify("No notebook environment yet - run <leader>is first", vim.log.levels.WARN)
		return
	end
	vim.ui.input({ prompt = "New notebook name: ", default = "untitled" }, function(name)
		if not name or vim.trim(name) == "" then
			return
		end
		name = vim.trim(name):gsub("%.ipynb$", "")
		local path = vim.fn.getcwd() .. "/" .. name .. ".ipynb"
		if vim.uv.fs_stat(path) then
			vim.notify(vim.fn.fnamemodify(path, ":~:.") .. " already exists", vim.log.levels.WARN)
			return
		end

		local proj = project_kernel()
		local kernel = proj and proj.name or "python3"
		local display = proj and ("Python (" .. proj.name .. ")") or "Python 3"
		local script = [[
import nbformat, sys
path, kernel, display, title = sys.argv[1:5]
nb = nbformat.v4.new_notebook()
nb.metadata["kernelspec"] = {"name": kernel, "display_name": display, "language": "python"}
nb.metadata["language_info"] = {"name": "python"}
nb.cells = [nbformat.v4.new_markdown_cell("# " + title), nbformat.v4.new_code_cell("")]
nbformat.write(nb, path)
]]
		local res = vim.system({ python, "-c", script, path, kernel, display, name }, { text = true }):wait()
		if res.code ~= 0 then
			vim.notify("Could not create the notebook:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
			return
		end
		vim.cmd("edit " .. vim.fn.fnameescape(path))
		-- Land in the empty code cell, ready to type.
		vim.fn.search("^```python", "w")
		vim.cmd("normal! j")
	end)
end

vim.api.nvim_create_user_command("NotebookSetup", setup, { desc = "Set up everything a notebook needs to run" })
vim.api.nvim_create_user_command("NotebookNew", new_notebook, { desc = "Create a notebook and open it" })
vim.keymap.set("n", "<leader>is", setup, { desc = "Notebook: [S]et up the environment" })
vim.keymap.set("n", "<leader>in", new_notebook, { desc = "Notebook: [N]ew notebook" })

-- No plugin of its own; this file only adds the commands and keys above.
return {}
