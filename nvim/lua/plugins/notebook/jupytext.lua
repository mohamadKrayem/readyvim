-- Open a .ipynb as Markdown - text with ```python code cells - edit it like
-- any file, and :w writes it back as .ipynb. Existing outputs in the file are
-- kept (molten.lua shows them and adds new ones on save).
--
-- Loaded at startup on purpose: it has to catch the *.ipynb read itself.
return {
	"GCBallesteros/jupytext.nvim",
	lazy = false,
	opts = {
		style = "markdown",
		output_extension = "md",
		force_ft = "markdown",
	},
}
