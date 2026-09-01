-- lazy.nvim bootstrap + plugin loading.
--
-- Plugins are grouped by what they do rather than listed one by one, so adding
-- a plugin means dropping a file into the right folder - no edit here.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		error("Could not clone lazy.nvim:\n" .. out)
	end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ import = "plugins.ui" }, -- colorscheme, statusline, tabs, dashboard
		{ import = "plugins.editor" }, -- navigation, search, syntax, editing
		{ import = "plugins.lsp" }, -- language servers, completion, formatting
		{ import = "plugins.git" }, -- git signs, lazygit
		{ import = "plugins.ai" }, -- AI completion
		{ import = "plugins.debug" }, -- DAP
	},
})
