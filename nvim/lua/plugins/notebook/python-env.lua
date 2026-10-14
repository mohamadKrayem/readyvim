-- Jupyter notebooks (optional). Everything for notebooks lives in this folder,
-- and lua/config/lazy.lua imports it on one line: delete that line, then this
-- folder, and notebook support is gone without touching anything else.
--
-- molten is a Python "remote plugin", and jupytext.nvim shells out to the
-- jupytext CLI. Both come from one venv kept out of the way:
--
--   uv venv ~/.local/share/nvim-notebook
--   uv pip install --python ~/.local/share/nvim-notebook/bin/python \
--     pynvim jupyter_client nbformat jupytext pillow
--
-- Pointing nvim's Python host at it, and putting its bin/ on PATH inside nvim
-- only, means nothing has to be on your shell PATH. It goes at the END of
-- PATH: jupytext is only found there, but `python` must still be whatever it
-- was - the language server picks its interpreter from PATH, and this venv
-- has none of your packages.
local venv = vim.fn.expand("~/.local/share/nvim-notebook")

if vim.fn.executable(venv .. "/bin/python") == 1 then
	vim.g.python3_host_prog = venv .. "/bin/python"
	vim.env.PATH = vim.env.PATH .. ":" .. venv .. "/bin"
end

-- No plugin of its own; this file only sets up the environment above.
return {}
