-- Jump anywhere on screen: press s, type the first letters of where you want
-- to go, then the label that appears there.
--
-- * s  jump (also works after an operator: ds<label> deletes up to it)
-- * S  select a treesitter node around the cursor - function, block, argument
-- * r  in operator-pending mode, act somewhere else and come back (yr<label>iw)
--
-- f/t/F/T are left alone on purpose: flash can take them over with labels,
-- but plain f/t muscle memory is worth more than the upgrade.
return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		modes = { char = { enabled = false } },
	},
	keys = {
		{
			"s",
			function()
				require("flash").jump()
			end,
			mode = { "n", "x", "o" },
			desc = "Flash: jump",
		},
		{
			"S",
			function()
				require("flash").treesitter()
			end,
			mode = { "n", "x", "o" },
			desc = "Flash: select a treesitter node",
		},
		{
			"r",
			function()
				require("flash").remote()
			end,
			mode = "o",
			desc = "Flash: act on a remote spot",
		},
	},
}
