return {
	"kristijanhusak/vim-dadbod-ui",
	cmd = { "DB", "DBUI" },
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true, event = "CmdLineEnter" },
		{
			"kristijanhusak/vim-dadbod-completion",
			ft = { "sql", "mysql", "plsql" },
		},
	},
	init = function()
		vim.g.db_ui_use_nerd_fonts = 1
	end,
}
