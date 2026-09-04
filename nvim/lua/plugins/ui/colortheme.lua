-- Dark-only colorscheme set + a curated picker.
--
-- <leader>ut opens a picker that lists ONLY the dark themes below (no light
-- variants ever show), previews live as you move, restores on cancel, and
-- remembers your choice across restarts.

local state_file = vim.fn.stdpath("state") .. "/colorscheme"
local DEFAULT = "no-clown-fiesta"

-- The only themes the picker offers. Add/remove dark variants here.
local THEMES = {
	"moonfly",
	"github_dark_dimmed",
	"github_dark",
	"github_dark_default",
	"github_dark_high_contrast",
	"zenbones",
	"zenwritten",
	"neobones",
	"no-clown-fiesta",
	"rasmus",
}

local function persist(name)
	pcall(vim.fn.writefile, { name }, state_file)
end

local function saved()
	local ok, lines = pcall(vim.fn.readfile, state_file)
	if ok and lines and lines[1] and lines[1] ~= "" then
		return lines[1]
	end
	return DEFAULT
end

local function apply(name)
	vim.o.background = "dark"
	pcall(vim.cmd.colorscheme, name)
end

local function pick()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previous = vim.g.colors_name

	pickers
		.new({}, {
			prompt_title = "Theme (dark)",
			finder = finders.new_table({ results = THEMES }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(bufnr, map)
				local function preview()
					local entry = action_state.get_selected_entry()
					if entry then
						apply(entry[1])
					end
				end
				local function move(step)
					return function()
						if step > 0 then
							actions.move_selection_next(bufnr)
						else
							actions.move_selection_previous(bufnr)
						end
						preview()
					end
				end
				local function cancel()
					actions.close(bufnr)
					if previous then
						apply(previous)
					end
				end
				local function bind(modes, key, fn)
					for _, m in ipairs(modes) do
						map(m, key, fn)
					end
				end

				vim.schedule(preview)
				for _, k in ipairs({ "<Down>", "<C-n>", "<C-j>" }) do
					bind({ "i", "n" }, k, move(1))
				end
				for _, k in ipairs({ "<Up>", "<C-p>", "<C-k>" }) do
					bind({ "i", "n" }, k, move(-1))
				end
				bind({ "n" }, "j", move(1))
				bind({ "n" }, "k", move(-1))
				bind({ "i", "n" }, "<Esc>", cancel)
				bind({ "i" }, "<C-c>", cancel)
				bind({ "n" }, "q", cancel)

				actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(bufnr)
					local name = entry and entry[1] or DEFAULT
					apply(name)
					persist(name)
				end)
				return true
			end,
		})
		:find()
end

return {
	-- Theme plugins (only their dark variants are offered by the picker).
	{ "kvrohit/rasmus.nvim", lazy = false },
	{ "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false },
	{ "aktersnurra/no-clown-fiesta.nvim", lazy = false },
	{ "zenbones-theme/zenbones.nvim", lazy = false, dependencies = { "rktjmp/lush.nvim" } },
	{
		"projekt0n/github-nvim-theme",
		lazy = false,
		priority = 1000,
		config = function()
			require("github-theme").setup({}) -- registers the github_* colorschemes
		end,
	},

	-- Picker keymap + apply the saved theme at startup (extends telescope).
	{
		"nvim-telescope/telescope.nvim",
		optional = true,
		keys = {
			{ "<leader>ut", pick, desc = "[U]I: pick dark [T]heme" },
		},
		init = function()
			apply(saved()) -- best-effort immediate (no flash if already loaded)
			vim.api.nvim_create_autocmd("VimEnter", {
				once = true,
				callback = function()
					apply(saved()) -- re-apply once every theme plugin has loaded
				end,
			})
		end,
	},
}
