-- Python REPL: send code from the buffer to a Jupyter kernel running in a
-- terminal split. jet.nvim downloads its own engine on first use; the kernel
-- has to exist already (ipykernel - see the README).
--
-- * <leader>rr toggles the REPL, starting a kernel if none is running.
-- * <leader>rs sends the expression under the cursor and moves to the next
--   one, so repeated presses walk through a script. In visual mode it sends
--   the selection instead.
-- * <leader>ro opens :Jet, the kernel manager (start, stop, rename).
--
-- jet.ipy decides what "the expression under the cursor" means for Python -
-- a whole def, class, for block or statement - and prefers a kernel from the
-- project's own virtualenv over the global one.

local function send(range, filetype)
	require("jet.api").get_kernel({ filetype = filetype }, function(k)
		local code = range:code({ comments = false })
		if code then
			k:send_repl(code)
		end
	end)
end

-- The expression under the cursor, or the next one below it when the cursor
-- sits on a blank line or a comment.
local function current_expr()
	local api = require("jet.api")
	local expr = api.get_expr()
	if not expr then
		local pos = api.next_expr_boundary({ current_ok = false, boundary = "start" })
		expr = pos and api.get_expr(pos)
	end
	return expr
end

return {
	"wurli/jet.nvim",
	dependencies = { "wurli/jet.ipy" },
	ft = "python",
	cmd = "Jet",
	config = function()
		require("jet").setup({})
		require("jet.ipy").setup()
	end,
	keys = {
		{
			"<leader>rr",
			function()
				require("jet.api").get_kernel({ filetype = vim.bo.filetype }, function(k)
					k:term_toggle()
				end)
			end,
			desc = "[R]EPL: toggle",
		},
		{
			"<leader>rs",
			function()
				local expr = current_expr()
				if not expr then
					vim.notify("No code to send below the cursor", vim.log.levels.INFO)
					return
				end
				send(expr, vim.bo.filetype)

				local next_pos = require("jet.api").next_expr_boundary({ direction = 1, boundary = "start" })
				if next_pos then
					vim.fn.cursor(next_pos:to_cursor())
				end
			end,
			desc = "[R]EPL: [S]end expression, move to the next",
		},
		{
			"<leader>rs",
			function()
				return require("jet.api").handle_motion(send)()
			end,
			mode = "x",
			expr = true,
			desc = "[R]EPL: [S]end selection",
		},
		{ "<leader>ro", "<cmd>Jet<CR>", desc = "[R]EPL: [O]pen the kernel manager" },
	},
}
