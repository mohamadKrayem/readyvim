--  Entry point. Order matters here:
--    1. leader keys, before any mapping or plugin spec can reference <leader>
--    2. editor settings
--    3. plugins (lazy.nvim owns everything under lua/plugins/)
--    4. UI tweaks that must win over whatever a colorscheme sets

-- Leader has to be assigned before lazy.nvim reads a single spec, otherwise
-- any lazy-loaded plugin that maps <leader>x silently binds to the wrong key.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.lazy")

-- Loaded last on purpose: these override colorscheme highlight groups.
require("config.diagnostics")
require("config.autocmds")
