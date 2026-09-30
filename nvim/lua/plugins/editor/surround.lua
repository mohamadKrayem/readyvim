-- Add, change or delete what surrounds text: quotes, brackets, tags, calls.
-- Under gs because plain s is flash.
--
-- * gsa{motion}{char}  add       gsaiw"   word -> "word"
-- * gsd{char}          delete    gsd"     "word" -> word
-- * gsr{old}{new}      replace   gsr"'    "word" -> 'word'
--
-- In visual mode gsa{char} wraps the selection. Opening brackets add inner
-- spaces, closing ones don't: gsaiw( gives ( word ), gsaiw) gives (word).
-- f is a function call (gsaiwf asks for the name) and t an HTML tag.
return {
	"nvim-mini/mini.surround",
	keys = {
		{ "gsa", mode = { "n", "x" }, desc = "Surround: add" },
		{ "gsd", desc = "Surround: delete" },
		{ "gsr", desc = "Surround: replace" },
		{ "gsf", desc = "Surround: find to the right" },
		{ "gsF", desc = "Surround: find to the left" },
		{ "gsh", desc = "Surround: highlight" },
	},
	opts = {
		mappings = {
			add = "gsa",
			delete = "gsd",
			replace = "gsr",
			find = "gsf",
			find_left = "gsF",
			highlight = "gsh",
			update_n_lines = "gsn",
		},
	},
}
