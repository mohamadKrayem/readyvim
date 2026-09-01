-- Debugging (DAP) for Node/JS/TS and Python.
-- Lazy-loaded: nothing runs until you press one of the <leader>d keys below,
-- so startup is untouched. Adapters (debugpy / js-debug) install via Mason on
-- first use.
return {
	"mfussenegger/nvim-dap",
	dependencies = {
		-- UI: scopes, breakpoints, watches, repl (auto opens on session start).
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio", -- required by nvim-dap-ui
		-- Inline variable values as virtual text while stepping.
		"theHamsta/nvim-dap-virtual-text",
		-- Installs the debug adapters (debugpy, js-debug-adapter) via Mason.
		"jay-babu/mason-nvim-dap.nvim",
		-- Python convenience layer (debug current file / test / method).
		"mfussenegger/nvim-dap-python",
	},
	-- These keys are the lazy-load trigger.
	keys = {
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "Debug: Continue / Start",
		},
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Debug: Toggle Breakpoint",
		},
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Debug: Conditional Breakpoint",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "Debug: Step Into",
		},
		{
			"<leader>do",
			function()
				require("dap").step_over()
			end,
			desc = "Debug: Step Over",
		},
		{
			"<leader>dO",
			function()
				require("dap").step_out()
			end,
			desc = "Debug: Step Out",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.toggle()
			end,
			desc = "Debug: Toggle REPL",
		},
		{
			"<leader>dl",
			function()
				require("dap").run_last()
			end,
			desc = "Debug: Run Last",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate()
			end,
			desc = "Debug: Terminate",
		},
		{
			"<leader>du",
			function()
				require("dapui").toggle()
			end,
			desc = "Debug: Toggle UI",
		},
		{
			"<leader>de",
			function()
				require("dapui").eval()
			end,
			mode = { "n", "v" },
			desc = "Debug: Eval expression",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		-- Install the adapters we use (python -> debugpy, js -> js-debug-adapter).
		-- No `handlers` key = mason-nvim-dap only installs; we configure adapters
		-- ourselves below so nothing is double-configured.
		require("mason-nvim-dap").setup({
			ensure_installed = { "python", "js" },
			automatic_installation = true,
		})

		dapui.setup()
		require("nvim-dap-virtual-text").setup()

		-- Open/close the debug UI automatically with the session.
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- Nicer breakpoint / stopped signs.
		vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", numhl = "" })
		vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", numhl = "" })
		vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })

		local mason = vim.fn.stdpath("data") .. "/mason/packages"

		-- ── Python ────────────────────────────────────────────────────────────
		-- Uses debugpy's bundled interpreter for the adapter; your project code
		-- still runs under the active virtualenv that basedpyright resolves.
		require("dap-python").setup(mason .. "/debugpy/venv/bin/python")

		-- ── Node / JavaScript / TypeScript ────────────────────────────────────
		local js_debug = mason .. "/js-debug-adapter/js-debug/src/dapDebugServer.js"
		for _, adapter in ipairs({ "pwa-node", "node" }) do
			dap.adapters[adapter] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = { js_debug, "${port}" },
				},
			}
		end

		for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
			dap.configurations[lang] = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch current file",
					program = "${file}",
					cwd = "${workspaceFolder}",
					sourceMaps = true,
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach to process",
					processId = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
					sourceMaps = true,
				},
			}
		end
	end,
}
