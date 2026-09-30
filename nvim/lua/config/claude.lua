-- Hand code to the claude running in a neighbouring tmux pane, instead of
-- copying and pasting it across.
--
-- * <leader>ac in normal mode sends "@path/to/file " - claude reads the file.
-- * <leader>ac on a visual selection sends the path, the line numbers and
--   the code itself in a fenced block.
--
-- Either way nothing is submitted: focus moves to the claude pane so you can
-- type the question and press Enter yourself.
local M = {}

local function tmux(args, input)
	local res = vim.system(vim.list_extend({ "tmux" }, args), { stdin = input, text = true }):wait()
	return res.code == 0 and res.stdout or nil
end

-- claude's process renames itself to its version number ("2.1.283"), so
-- pane_current_command is useless here; the process arguments still say
-- "claude". Panes in the current window win over the rest of the session.
local function find_claude_pane()
	local panes = tmux({ "list-panes", "-s", "-F", "#{window_active} #{pane_id} #{pane_tty}" })
	if not panes then
		return nil
	end
	local best
	for line in panes:gmatch("[^\n]+") do
		local active, id, tty = line:match("^(%d) (%%%d+) (.+)$")
		if id and id ~= vim.env.TMUX_PANE then
			local ps = vim.system({ "ps", "-o", "args=", "-t", tty }, { text = true }):wait().stdout or ""
			for args in ps:gmatch("[^\n]+") do
				if args:match("^claude%f[%s%z]") or args:match("/claude%f[%s%z]") then
					if active == "1" then
						return id
					end
					best = best or id
				end
			end
		end
	end
	return best
end

local function send(text)
	if not vim.env.TMUX then
		vim.notify("Not inside tmux", vim.log.levels.WARN)
		return
	end
	local pane = find_claude_pane()
	if not pane then
		vim.notify("No claude pane in this tmux session", vim.log.levels.WARN)
		return
	end
	-- A bracketed paste (-p), so the newlines in a code block land as text
	-- instead of each one submitting the prompt.
	tmux({ "load-buffer", "-b", "nvim-to-claude", "-" }, text)
	tmux({ "paste-buffer", "-p", "-d", "-b", "nvim-to-claude", "-t", pane })
	tmux({ "select-pane", "-t", pane })
end

local function relative_path()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		return nil
	end
	return vim.fn.fnamemodify(path, ":.")
end

function M.send_file()
	local path = relative_path()
	if not path then
		vim.notify("This buffer has no file to send", vim.log.levels.WARN)
		return
	end
	send("@" .. path .. " ")
end

function M.send_selection()
	-- Leave visual mode first so '< and '> hold this selection, not the last one.
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
	local first, last = vim.fn.line("'<"), vim.fn.line("'>")
	local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
	local where = (relative_path() or "[unsaved buffer]")
		.. (first == last and (" line " .. first) or (" lines " .. first .. "-" .. last))
	local fence = "```" .. vim.bo.filetype
	send(where .. ":\n" .. fence .. "\n" .. table.concat(lines, "\n") .. "\n```\n")
end

vim.keymap.set("n", "<leader>ac", M.send_file, { desc = "[A]I: send this file to [C]laude" })
vim.keymap.set("x", "<leader>ac", M.send_selection, { desc = "[A]I: send the selection to [C]laude" })

return M
