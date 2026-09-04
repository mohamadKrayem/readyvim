-- For `plugins/markview.lua` users.
return {
	"OXY2DEV/markview.nvim",
	lazy = false,
	submodules = false, -- skip the .wiki submodule (docs only; breaks on case-insensitive FS)

	-- Completion for `blink.cmp`
	-- dependencies = { "saghen/blink.cmp" },
}
