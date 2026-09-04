-- lf file manager (testing as a replacement for yazi), via floaterm's native
-- lf integration. Requires the `lf` binary:  brew install lf
--
-- * <leader>-  opens lf with the cursor already on the current file,
--   <leader>cw opens it in the working directory.
-- * Opening nvim on a directory (`nvim .`) launches lf there instead of netrw,
--   and picking a file replaces the current buffer (no stray tab).
return {
	"voldikss/vim-floaterm",
	cmd = { "FloatermNew", "FloatermToggle" },
	keys = {
		{
			"<leader>-",
			function()
				-- lf's positional argument is a "cd-or-select-path": hand it a file
				-- and it starts in the parent directory with the cursor already on
				-- that file. Fall back to a directory when there is no real file to
				-- point at (scratch buffers, terminals, an unwritten new file).
				local target = vim.fn.expand("%:p")
				if vim.bo.buftype ~= "" or vim.fn.filereadable(target) == 0 then
					target = vim.fn.expand("%:p:h")
					if target == "" or vim.fn.isdirectory(target) == 0 then
						target = vim.fn.getcwd()
					end
				end
				vim.cmd("FloatermNew --name=lf --width=0.9 --height=0.9 --title=lf lf " .. vim.fn.fnameescape(target))
			end,
			desc = "Open lf at the current file",
		},
		{
			"<leader>cw",
			"<cmd>FloatermNew --name=lf --width=0.9 --height=0.9 --title=lf lf<cr>",
			desc = "Open lf in the working directory",
		},
	},
	init = function()
		-- Picked file replaces the current window's buffer (shows in bufferline,
		-- single tabpage — no stray tabpages, :q quits cleanly).
		vim.g.floaterm_opener = "drop"
		vim.g.floaterm_borderchars = "─│─│╭╮╯╰"

		-- Take over netrw so opening a directory shows lf, not the netrw list.
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		local function open_lf(path)
			vim.cmd("FloatermNew --name=lf --width=0.9 --height=0.9 --title=lf lf " .. vim.fn.fnameescape(path))
		end

		-- When a directory buffer is entered (via `nvim <dir>` or `:edit <dir>`),
		-- wipe it and open lf in that directory instead.
		local grp = vim.api.nvim_create_augroup("LfDirHijack", { clear = true })
		local hijacking = false
		vim.api.nvim_create_autocmd("BufEnter", {
			group = grp,
			callback = function(ev)
				if hijacking then
					return
				end
				if ev.file ~= "" and vim.fn.isdirectory(ev.file) == 1 then
					hijacking = true
					local dir = ev.file
					vim.schedule(function()
						if vim.api.nvim_buf_is_valid(ev.buf) then
							pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
						end
						open_lf(dir)
						hijacking = false
					end)
				end
			end,
		})

		-- Blend the floating window with the active colorscheme.
		local function theme()
			vim.api.nvim_set_hl(0, "Floaterm", { link = "Normal" })
			vim.api.nvim_set_hl(0, "FloatermBorder", { link = "FloatBorder" })
		end
		theme()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = theme })
	end,
}
