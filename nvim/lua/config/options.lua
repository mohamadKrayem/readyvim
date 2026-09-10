-- Editor settings, grouped by what they affect.
--
-- Note: this file absorbs the old core/styles.lua, which used to load *after*
-- core/options.lua and quietly overrode the indent width from 4 to 2. The 2
-- below is the value that was actually in effect - the 4 never applied.

local o = vim.o
local opt = vim.opt

-- ── Line numbers & signs ────────────────────────────────────────────────────
o.number = true
o.relativenumber = true -- relative numbers make {count}j / {count}k trivial
o.numberwidth = 4
o.signcolumn = "yes" -- pin it open; the buffer jitters sideways otherwise

-- ── Indentation ─────────────────────────────────────────────────────────────
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.autoindent = true
o.smartindent = true
o.breakindent = true -- wrapped lines keep their indent

-- ── Wrapping & scrolling ────────────────────────────────────────────────────
o.wrap = false
o.linebreak = true -- if wrap is ever toggled on, break at words not mid-word
o.scrolloff = 4 -- keep some context above/below the cursor
o.sidescrolloff = 8
o.whichwrap = "bs<>[]hl" -- let these keys move across line boundaries

-- ── Search ──────────────────────────────────────────────────────────────────
o.ignorecase = true
o.smartcase = true -- ...unless the query has a capital in it
o.hlsearch = false -- highlights linger and get noisy; incsearch is enough

-- ── Splits ──────────────────────────────────────────────────────────────────
o.splitbelow = true -- new splits open down/right, matching reading order
o.splitright = true

-- ── UI ──────────────────────────────────────────────────────────────────────
opt.termguicolors = true
o.showmode = false -- lualine already shows the mode
o.showtabline = 2 -- always visible, bufferline lives here
o.cursorline = false
o.pumheight = 10 -- cap the completion popup so it can't swallow the screen
o.cmdheight = 1
o.conceallevel = 0 -- keep markdown backticks visible
o.mouse = "a"

-- ── Files & persistence ─────────────────────────────────────────────────────
o.fileencoding = "utf-8"
o.undofile = true -- undo survives closing the file
o.swapfile = false
o.backup = false
o.writebackup = false

-- ── Timing ──────────────────────────────────────────────────────────────────
o.updatetime = 250 -- drives CursorHold: gitsigns blame, LSP hover
o.timeoutlen = 300 -- how long to wait mid-sequence for the next key

-- ── Completion & editing behaviour ──────────────────────────────────────────
o.completeopt = "menuone,noselect"
o.backspace = "indent,eol,start"
opt.shortmess:append("c") -- drop "match 1 of 2" completion chatter
opt.iskeyword:append("-") -- treat foo-bar as one word for w/e/*
opt.formatoptions:remove({ "c", "r", "o" }) -- never auto-continue comments on a new line
opt.runtimepath:remove("/usr/share/vim/vimfiles") -- ignore system Vim plugins

-- ── Folding (treesitter-driven, all open on load) ───────────────────────────
o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"
o.foldenable = false
o.foldlevel = 99

-- ── Clipboard ───────────────────────────────────────────────────────────────
o.clipboard = "unnamedplus"

-- Over SSH there is no local clipboard to talk to, so round-trip through the
-- terminal with OSC 52. Locally macOS already wires up pbcopy/pbpaste.
if vim.env.SSH_TTY ~= nil then
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = require("vim.ui.clipboard.osc52").paste("+"),
			["*"] = require("vim.ui.clipboard.osc52").paste("*"),
		},
	}
end
