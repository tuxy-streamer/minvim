return {
	"mfussenegger/nvim-dap",
	recommended = true,
	desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		{
			"theHamsta/nvim-dap-virtual-text",
			opts = {},
		},
	},
	event = { "BufReadPost" },
	config = function()
		local has_mason_dap, mason_dap = pcall(require, "mason-nvim-dap")
		if has_mason_dap then
			mason_dap.setup({})
		end
		vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
		local dap_signs = {
			Stopped = { "▶", "DiagnosticInfo" },
			Breakpoint = { "●", "DiagnosticError" },
			BreakpointCondition = { "◆", "DiagnosticWarn" },
			LogPoint = { "◆", "DiagnosticInfo" },
		}
		for name, sign in pairs(dap_signs) do
			local text = sign[1]
			local texthl = sign[2] or "DiagnosticInfo"
			vim.fn.sign_define("Dap" .. name, { text = text, texthl = texthl, linehl = nil, numhl = nil })
		end
		local has_vscode, vscode = pcall(require, "dap.ext.vscode")
		local has_plenary, plenary_json = pcall(require, "plenary.json")
		if has_vscode and has_plenary then
			vscode.json_decode = function(str)
				return vim.json.decode(plenary_json.json_strip_comments(str))
			end
		end
	end,
}
