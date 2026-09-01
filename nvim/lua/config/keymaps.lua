-- Global keymaps. Plugin-specific bindings live with their plugin spec, not here.
--
-- Leader is set in init.lua, before this file loads.

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Space is the leader, so stop it from also moving the cursor right.
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- ── Movement ────────────────────────────────────────────────────────────────

-- Coarse vertical jumps. Deliberately mirrored in tmux copy-mode so the same
-- two keys scroll in both places.
map({ "n", "x" }, "<C-p>", "8k", {})
map({ "n", "x" }, "<C-n>", "8j", {})

-- Half-page scroll and search, always recentring so the cursor never ends up
-- pinned to the top or bottom edge.
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)

-- Hop between unmatched brackets. ]i / [i because ]% / [% are awkward to reach.
map({ "n", "x", "o" }, "]i", "]%", { desc = "Go to next unmatched closing bracket" })
map({ "n", "x", "o" }, "[i", "[%", { desc = "Go to previous unmatched opening bracket" })

-- Same motion from insert mode, via a one-shot normal command.
map("i", "]i", "<C-o>]%", { desc = "Go to next unmatched closing bracket" })
map("i", "[i", "<C-o>[%", { desc = "Go to previous unmatched opening bracket" })

-- ── Files ───────────────────────────────────────────────────────────────────
map("n", "<C-s>", "<cmd> w <CR>", opts)
map("n", "<leader>sn", "<cmd>noautocmd w <CR>", opts) -- save, skipping format-on-save
map("n", "<C-q>", "<cmd> q <CR>", opts)

-- ── Editing ─────────────────────────────────────────────────────────────────
map("n", "x", '"_x', opts) -- delete a char without clobbering the register
map("v", "p", '"_dP', opts) -- paste over a selection and keep the original yank
map("v", "<", "<gv", opts) -- keep the selection after re-indenting
map("v", ">", ">gv", opts)
map("n", "<leader>lw", "<cmd>set wrap!<CR>", opts)

-- Throw away unsaved changes and re-read the file from disk. Confirms first,
-- and defaults to "No" - this is not undoable.
map("n", "<leader>rd", function()
	if not vim.bo.modified then
		vim.notify("No unsaved changes", vim.log.levels.INFO)
		return
	end
	if vim.fn.confirm("Discard unsaved changes and reload from disk?", "&Yes\n&No", 2) == 1 then
		vim.cmd("edit!")
	end
end, { desc = "Revert/Discard buffer to saved version" })

-- ── Buffers ─────────────────────────────────────────────────────────────────
map("n", "<S-l>", ":bnext<CR>", opts)
map("n", "<S-h>", ":bprevious<CR>", opts)
map("n", "<leader>bd", ":bdelete!<CR>", opts) -- close this buffer
map("n", "<leader>bn", "<cmd> enew <CR>", opts) -- new empty buffer
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", opts) -- close every other buffer
map("n", "<leader>bD", "<cmd>%bdelete!<CR>", opts) -- close all buffers

-- ── Windows & splits ────────────────────────────────────────────────────────
map("n", "<leader>v", "<C-w>v", opts) -- split vertically
map("n", "<leader>h", "<C-w>s", opts) -- split horizontally
map("n", "<leader>se", "<C-w>=", opts) -- even out the split sizes
map("n", "<leader>xs", ":close<CR>", opts)

-- Move between splits. Matches the tmux Ctrl+h/j/k/l bindings, so the same
-- four keys cross nvim splits and tmux panes without thinking about it.
map("n", "<C-k>", ":wincmd k<CR>", opts)
map("n", "<C-j>", ":wincmd j<CR>", opts)
map("n", "<C-h>", ":wincmd h<CR>", opts)
map("n", "<C-l>", ":wincmd l<CR>", opts)

-- Resize with the arrow keys, which are otherwise unused.
map("n", "<Up>", ":resize -2<CR>", opts)
map("n", "<Down>", ":resize +2<CR>", opts)
map("n", "<Left>", ":vertical resize -2<CR>", opts)
map("n", "<Right>", ":vertical resize +2<CR>", opts)

-- ── Tabs ────────────────────────────────────────────────────────────────────
map("n", "<leader>to", ":tabnew<CR>", opts)
map("n", "<leader>tx", ":tabclose<CR>", opts)
map("n", "<leader>tn", ":tabn<CR>", opts)
map("n", "<leader>tp", ":tabp<CR>", opts)

-- ── Diagnostics ─────────────────────────────────────────────────────────────
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic message" })

map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic message" })

map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic (error) message" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- ── AI completion (codeium.vim) ─────────────────────────────────────────────
-- These are expr mappings: the function's return value is what gets typed.
map("i", "<C-h>", function()
	return vim.fn["codeium#Accept"]()
end, { expr = true, silent = true })
map("i", "<c-;>", function()
	return vim.fn["codeium#CycleCompletions"](1)
end, { expr = true, silent = true })
map("i", "<c-,>", function()
	return vim.fn["codeium#CycleCompletions"](-1)
end, { expr = true, silent = true })
map("i", "<c-x>", function()
	return vim.fn["codeium#Clear"]()
end, { expr = true, silent = true })

-- ── Jump between occurrences of the word / selection under the cursor ───────
-- Unlike plain *, these do not move the cursor on the first press, and they
-- keep working on repeat because the search register is reused.

-- Build the \<word\> pattern `*` would have set, so we can tell whether the
-- current search is already this word.
local function word_pattern()
	return "\\<" .. vim.fn.escape(vim.fn.expand("<cword>"), "\\/.*'$^~[]") .. "\\>"
end

-- Already searching for this word? step with n/N. Otherwise kick off a fresh
-- search with */# , which sets the register for subsequent presses.
local function jump_word(forward)
	local stepping = vim.fn.getreg("/") == word_pattern()
	if forward then
		vim.cmd(stepping and "normal! nzzzv" or "normal! *zzzv")
	else
		vim.cmd(stepping and "normal! Nzzzv" or "normal! #zzzv")
	end
end

-- Visual mode: yank the selection into @v and search for it literally.
local function jump_selection(forward)
	vim.cmd('normal! "vy')
	local selection = vim.fn.escape(vim.fn.getreg("v"), "\\/.*'$^~[]")
	selection = vim.fn.substitute(selection, "\n", "\\\\n", "g")

	vim.fn.setreg("/", selection)
	vim.cmd(forward and "normal! nzzzv" or "normal! Nzzzv")
end

map("n", "<leader>n", function()
	jump_word(true)
end, { desc = "Jump to next occurrence of word", noremap = true, silent = true })

map("n", "<leader>p", function()
	jump_word(false)
end, { desc = "Jump to previous occurrence of word", noremap = true, silent = true })

map("x", "<leader>n", function()
	jump_selection(true)
end, { desc = "Jump to next occurrence of selection", noremap = true, silent = true })

map("x", "<leader>p", function()
	jump_selection(false)
end, { desc = "Jump to previous occurrence of selection", noremap = true, silent = true })

-- ── Treesitter-aware container navigation ───────────────────────────────────
-- [[ and ]] jump to the edges of whatever construct encloses the cursor - a
-- function, class, loop, JSX element - instead of vim's paragraph defaults.

-- Node types worth stopping at. Anything not listed is walked straight past,
-- so [[ lands on the enclosing function rather than some intermediate wrapper.
local container_types = {
	-- Functions & methods
	function_declaration = true,
	function_definition = true,
	function_expression = true,
	arrow_function = true,
	method_definition = true,
	method = true,
	local_function = true,
	-- Classes
	class_declaration = true,
	class_definition = true,
	class_body = true,
	-- Control flow
	if_statement = true,
	for_statement = true,
	for_in_statement = true,
	while_statement = true,
	do_statement = true,
	switch_statement = true,
	try_statement = true,
	-- Blocks
	block = true,
	-- HTML / JSX
	jsx_element = true,
	jsx_self_closing_element = true,
	element = true,
	html_element = true,
	-- Other
	table_constructor = true, -- Lua tables
	object = true, -- JS objects
	array = true,
}

local function goto_container_edge(edge)
	local node = vim.treesitter.get_node()
	if not node then
		return
	end

	-- Climb until we hit something in container_types.
	local cur = node
	while cur do
		if container_types[cur:type()] then
			break
		end
		cur = cur:parent()
	end

	if not cur then
		return
	end

	local row, col
	if edge == "start" then
		row, col = cur:start()
	else
		row, col = cur:end_()
		-- end_() reports the position just past the node, so back up one column
		-- to land on the final character rather than after it.
		if col > 0 then
			col = col - 1
		end
	end

	vim.api.nvim_win_set_cursor(0, { row + 1, col })
end

map({ "n", "x", "o" }, "[[", function()
	goto_container_edge("start")
end, { desc = "Go to start of current container" })

map({ "n", "x", "o" }, "]]", function()
	goto_container_edge("end")
end, { desc = "Go to end of current container" })
