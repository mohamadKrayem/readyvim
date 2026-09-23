-- Move between projects without leaving nvim.
--
-- <leader>sp picks a project, saves the current one's session, and restores
-- the target's - tabs, splits, buffers, folds. Only this nvim changes, so a
-- neighbouring tmux pane (claude, a dev server, a log tail) is untouched.
--
-- Sessions are keyed by directory, so there is nothing to name or manage.
-- Nothing is ever restored automatically: startup stays predictable, and you
-- ask for a session when you want one.
local M = {}

-- The same roots the tmux sessionizer uses, so both pickers agree on what
-- counts as a project.
local function project_roots()
	local paths = vim.env.TMUX_SESSIONIZER_PATHS
	if paths and paths ~= "" then
		return vim.split(paths, ":", { trimempty = true })
	end
	local home = vim.env.HOME
	return { home .. "/Dev", home .. "/personal", home .. "/.config" }
end

local function project_dirs()
	local dirs = {}
	for _, root in ipairs(project_roots()) do
		if vim.fn.isdirectory(root) == 1 then
			for name, kind in vim.fs.dir(root) do
				if kind == "directory" then
					table.insert(dirs, root .. "/" .. name)
				end
			end
		end
	end
	table.sort(dirs)
	return dirs
end

-- Remembered so <leader>sP can bounce straight back, the way prefix+Shift-Tab
-- does for tmux sessions.
local previous_project = nil

function M.switch(dir)
	dir = vim.fs.normalize(dir)
	local current = vim.fs.normalize(vim.fn.getcwd())
	if dir == current then
		return
	end
	if vim.fn.isdirectory(dir) == 0 then
		vim.notify("Not a directory: " .. dir, vim.log.levels.ERROR)
		return
	end

	local persistence = require("persistence")

	-- Sessions are keyed by cwd, so the save has to happen before the cd.
	persistence.save()

	-- Let go of the old project. Without this its language servers stay
	-- attached and its buffers end up saved into the next project's session.
	for _, client in ipairs(vim.lsp.get_clients()) do
		vim.lsp.stop_client(client.id)
	end
	vim.cmd("silent! tabonly")
	vim.cmd("silent! %bwipeout!")

	vim.cmd("cd " .. vim.fn.fnameescape(dir))
	previous_project = current

	persistence.load()

	-- First visit to this project - nothing to restore, so open the file
	-- picker instead of leaving an empty buffer sitting there.
	if vim.api.nvim_buf_get_name(0) == "" then
		require("telescope.builtin").find_files()
	end
end

-- ~/Dev/foo reads better than the full absolute path.
local function tilde(path)
	return (path:gsub("^" .. vim.pesc(vim.env.HOME), "~"))
end

-- One picker for both lists. Items are { path = ..., display = ... }.
local function choose(title, items)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values

	pickers
		.new({}, {
			prompt_title = title,
			finder = finders.new_table({
				results = items,
				entry_maker = function(item)
					return { value = item.path, display = item.display, ordinal = item.display }
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(bufnr)
				actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(bufnr)
					if entry then
						M.switch(entry.value)
					end
				end)
				return true
			end,
		})
		:find()
end

function M.pick()
	local dirs = project_dirs()
	if vim.tbl_isempty(dirs) then
		vim.notify("No project directories found under: " .. table.concat(project_roots(), ", "), vim.log.levels.WARN)
		return
	end

	local items = {}
	for _, dir in ipairs(dirs) do
		table.insert(items, { path = dir, display = tilde(dir) })
	end
	choose("Projects", items)
end

-- Every worktree of the repo the current directory belongs to. The porcelain
-- format is one "worktree <path>" line per tree, each followed by "branch
-- refs/heads/<name>", "detached" or "bare".
local function worktrees()
	local out = vim.fn.systemlist({ "git", "-C", vim.fn.getcwd(), "worktree", "list", "--porcelain" })
	if vim.v.shell_error ~= 0 then
		return nil
	end

	local trees, tree = {}, nil
	for _, line in ipairs(out) do
		local path = line:match("^worktree (.+)$")
		if path then
			tree = { path = vim.fs.normalize(path), label = "detached" }
			table.insert(trees, tree)
		elseif tree then
			local branch = line:match("^branch refs/heads/(.+)$")
			if branch then
				tree.label = branch
			elseif line == "bare" then
				tree.label = "bare"
			end
		end
	end
	return trees
end

-- Switching worktree is switching directory, so it goes through M.switch like
-- anything else: this worktree's session is saved, the target's is restored.
function M.pick_worktree()
	local trees = worktrees()
	if not trees then
		vim.notify("Not inside a git repository", vim.log.levels.WARN)
		return
	end
	if #trees < 2 then
		vim.notify("This repository has no other worktrees", vim.log.levels.INFO)
		return
	end

	local here = vim.fs.normalize(vim.fn.getcwd())
	local items = {}
	for _, tree in ipairs(trees) do
		table.insert(items, {
			path = tree.path,
			-- Branch first: that is what you are actually picking between.
			display = string.format("%s %-24s %s", tree.path == here and "*" or " ", tree.label, tilde(tree.path)),
		})
	end
	choose("Worktrees", items)
end

return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {},

	init = function()
		-- What a session records. `blank` and `terminal` are deliberately
		-- absent: restoring empty windows and dead terminal buffers (floaterm
		-- running lf) just leaves junk to close on the way back in.
		vim.o.sessionoptions = "buffers,curdir,folds,globals,help,skiprtp,tabpages,winsize,winpos,localoptions"

		-- The keymaps below are the everyday route in; these exist so the
		-- same thing is scriptable and reachable by name.
		vim.api.nvim_create_user_command("Projects", function()
			M.pick()
		end, { desc = "Pick a project to switch to" })

		vim.api.nvim_create_user_command("ProjectSwitch", function(o)
			M.switch(o.args)
		end, { nargs = 1, complete = "dir", desc = "Switch to a project by path" })

		vim.api.nvim_create_user_command("Worktrees", function()
			M.pick_worktree()
		end, { desc = "Switch to another worktree of this repo" })
	end,

	keys = {
		{ "<leader>sp", M.pick, desc = "[S]witch [P]roject" },
		{ "<leader>gw", M.pick_worktree, desc = "[G]it [W]orktree: switch to another" },
		{
			"<leader>sP",
			function()
				if previous_project then
					M.switch(previous_project)
				else
					vim.notify("No previous project this session", vim.log.levels.INFO)
				end
			end,
			desc = "[S]witch to [P]revious project",
		},
		{
			"<leader>sl",
			function()
				require("persistence").load()
			end,
			desc = "[S]ession: re[L]oad this directory's session",
		},
	},
}
