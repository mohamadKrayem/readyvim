-- Autocommands.

local augroup = function(name)
	return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Briefly highlight whatever was just yanked, so it's obvious what got copied.
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("YankHighlight"),
	pattern = "*",
	callback = function()
		vim.hl.on_yank()
	end,
})
