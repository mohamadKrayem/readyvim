return { -- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs", -- Sets main module to use for opts
	-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
	opts = {
		ensure_installed = {
			-- Core
			"lua",
			"vim",
			"vimdoc",
			"regex",
			"bash",
			"markdown",
			"markdown_inline",
			"json",
			"yaml",
			"toml",
			"gitignore",
			"dockerfile",
			"make",
			"cmake",
			"sql",

			-- Web / Frontend
			"html",
			"css",
			"javascript",
			"typescript",
			"tsx",

			-- Backend / Infra
			"python",
			"go",
			"java",
			"groovy",
			"rust",
			"graphql",
			"terraform",

			-- Extra popular
			"c",
			"cpp",
			"php",
			"ruby",
		},
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = { "ruby" },
		},
		indent = {
			enable = true,
			disable = { "ruby" },
		},
		-- Enable textobjects (selection + movement)
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Auto jump forward like targets.vim
				keymaps = {
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
					["al"] = "@loop.outer",
					["il"] = "@loop.inner",
					["aa"] = "@parameter.outer",
					["ia"] = "@parameter.inner",
					["ab"] = "@block.outer",
					["ib"] = "@block.inner",
					["icd"] = "@conditional.inner",
					["acd"] = "@conditional.outer",
					["icm"] = "@comment.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true,
				lookahead = true, -- Feels more like LazyVim
				goto_next_start = {
					["]f"] = "@function.outer",
					["]c"] = "@class.outer",
					["]i"] = "@block.inner", -- start of next block
				},
				goto_next_end = {
					["]F"] = "@function.outer",
					["]C"] = "@class.outer",
					["]I"] = "@block.inner", -- end of next block
				},
				goto_previous_start = {
					["[f"] = "@function.outer",
					["[c"] = "@class.outer",
					["[i"] = "@block.inner", -- start of prev block
				},
				goto_previous_end = {
					["[F"] = "@function.outer",
					["[C"] = "@class.outer",
					["[I"] = "@block.inner", -- end of prev block
				},
			},
		},
	},
}
