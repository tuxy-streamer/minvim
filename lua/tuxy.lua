-- Autocmds
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Settings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.autoformat = true
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }
vim.g.deprecation_warnings = true
vim.g.trouble_lualine = true
vim.g.markdown_recommended_style = 0
vim.g.db_ui_use_nerd_fonts = 1

local opt = vim.opt

-- General settings
opt.number = true
opt.relativenumber = true
opt.wrap = false
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.spelllang = { "en" }

-- Indentation setings
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Search settings
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Visual settings
opt.termguicolors = true
opt.signcolumn = "yes"
opt.showmatch = true
opt.ruler = true
opt.showmode = false
opt.conceallevel = 0
opt.concealcursor = ""
opt.lazyredraw = true
opt.synmaxcol = 300
opt.virtualedit = "block"
opt.showtabline = 1

-- File settings
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.undolevels = 10000
opt.wildmode = "longest:full,full"
opt.autoread = true

-- Behaviour settings
opt.autochdir = false
opt.iskeyword:append("-")
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.modifiable = true

-- General keybinds
local map = vim.keymap.set

map("n", "<leader>o", ":update<CR> :source<CR>", { desc = "General: Update and Source current file" })
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "General: Clear search highlight" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: Exit insert mode" })

-- Colorscheme
vim.pack.add({ { src = "https://github.com/p00f/alabaster.nvim" } })
vim.cmd("colorscheme alabaster")

-- Oil
vim.pack.add({ { src = "https://github.com/stevearc/oil.nvim" } })
require("oil").setup()
map("n", "\\", ":Oil<CR>", { desc = "Oil: Open parent directory" })

-- Todo Comments
vim.pack.add({ { src = "https://github.com/folke/todo-comments.nvim" } })
local todo_comments = require("todo-comments")
todo_comments.setup()
map("n", "[t", function()
	todo_comments.jump_prev()
end, { desc = "TodoComments: Previous Todo Comment" })
map("n", "]t", function()
	todo_comments.jump_next()
end, { desc = "TodoComments: Next Todo Comment" })
map("n", "<leader>st", ":TodoTelescope<cr>", { desc = "TodoComments: Search Todo comment in telescope" })

-- Telescope
vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
})
local themes = require("telescope.themes")
local telescope = require("telescope")
telescope.setup({
	defaults = themes.get_ivy(),
	pickers = {
		find_files = {
			find_command = { "fd", "--type", "f", "--follow" },
		},
	},
})
map("n", "<leader>sf", ":Telescope find_files<CR>", { desc = "Telescope: Find files" })
map("n", "<leader>sl", ":Telescope live_grep<CR>", { desc = "Telescope: Live grep" })
map("n", "<leader>sb", ":Telescope buffers<CR>", { desc = "Telescope: Search buffers" })
map("n", "<leader>sh", ":Telescope help_tags<CR>", { desc = "Telescope: Search help tags" })
map("n", "<leader>so", ":Telescope builtin<CR>", { desc = "Telescope: Search options" })
map("n", "<leader>sv", ":Telescope vim_options<CR>", { desc = "Telescope: Search vim options" })
map("n", "<leader>sg", ":Telescope git_files<CR>", { desc = "Telescope: Search git files" })

-- Treesitter
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter" } })
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"vimdoc",
		"javascript",
		"typescript",
		"c",
		"lua",
		"rust",
		"jsdoc",
		"bash",
	},
	sync_install = false,
	auto_install = true,
	indent = {
		enable = true,
	},
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = { "markdown" },
	},
})

-- Autocompletion
vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp", build = "cargo build --release" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
})
require("luasnip").setup()
local blink_cmp = require("blink.cmp")
blink_cmp.setup({
	fuzzy = { implementation = "prefer_rust_with_warning" },
	keymap = { preset = "default" },
	completion = {
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
		},
	},
	appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = "mono" },
	signature = { enabled = true },
	snippets = { preset = "luasnip" },
	sources = {
		default = { "lsp", "buffer", "snippets", "path" },
		providers = {
			dadbod = { module = "vim_dadbod_completion.blink" },
			lsp = { fallbacks = {} },
		},
	},
})

-- LSP
vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
})
local capabilities =
	vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), blink_cmp.get_lsp_capabilities())
require("mason").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		-- Assembly
		"asmfmt",
		-- Go
		"gofumpt",
		"golangci-lint",
		"goimports-reviser",
		"golines",
		"gomodifytags",
		"gotests",
		-- -- Python
		-- "pylint",
		-- "pydocstyle",
		-- Lua
		"luacheck",
		"stylua",
		-- Git
		"gitleaks",
		"gitlint",
		-- Rust
		"codelldb",
		-- JS/TS
		"prettierd",
		"eslint_d",
		-- Yaml
		"yamllint",
		"yamlfix",
		"yamlfmt",
		-- Json
		"jsonlint",
		"fixjson",
		-- Bash
		"shellcheck",
		"shellharden",
		"shfmt",
		-- Make
		"checkmake",
		-- Css
		"stylelint",
		-- Markdown
		"markdownlint-cli2",
		-- Html
		"htmlhint",
		-- C/C++
		"clang-format",
		-- Sql
		"sqlfluff",
		"sqruff",
		"pgformatter",
	},
	auto_update = true,
	run_on_start = true,
	debounce_hours = 10,
})
require("mason-lspconfig").setup({
	ensure_installed = {
		"asm_lsp",
		"lua_ls",
		"rust_analyzer",
		"gopls",
		"ruff",
		"pyright",
		"marksman",
		"bashls",
		"jsonls",
		"zls",
		"clangd",
	},
	handlers = {
		function(server_name) -- default handler (optional)
			require("lspconfig")[server_name].setup({
				capabilities = capabilities,
			})
		end,

		["lua_ls"] = function()
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {
						format = {
							enable = true,
							-- Put format options here
							-- NOTE: the value should be STRING!!
							defaultConfig = {
								indent_style = "tab",
								indent_size = "1",
							},
						},
					},
				},
			})
		end,
		["ruff"] = function()
			lspconfig.ruff.setup({
				capabilities = capabilities,
				settings = {
					configuration = "~/.config/lsp/ruff.toml",
				},
			})
		end,
	},
})

vim.diagnostic.config({
	virtual_text = false,
	float = {
		focusable = false,
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

vim.lsp.enable({
	"asm_lsp",
	"lua_ls",
	"rust_analyzer",
	"gopls",
	"ruff",
	"basedpyright",
	"marksman",
	"bashls",
	"jsonls",
	"zls",
	"clangd",
})

map("n", "gd", ":Telescope lsp_definitions<CR>", { desc = "LSP: Search definition in telescope" })
map("n", "gr", ":Telescope lsp_references<CR>", { desc = "LSP: Show references in telescope" })
map("n", "gws", ":Telescope lsp_workspace_symbols<CR>", { desc = "LSP: Show workspace symbols in telescope" })
map("n", "gds", ":Telescope lsp_document_symbols<CR>", { desc = "LSP: Show document symbols in telescope" })
map("n", "<leader>rr", ":LspRestart<CR>", { desc = "LSP: Restart Server" })
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code Action" })
map("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover Documentation" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Go to Declaration" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "LSP: Show Diagnostics" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename Symbol" })

-- Formatting
vim.pack.add({ { src = "https://github.com/stevearc/conform.nvim" } })
local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
		rust = { "rustfmt", lsp_format = "fallback" },
		cpp = { "clang-format" },
		c = { "clang-format" },
		javascript = { "prettierd", "eslint_d" },
		typescript = { "prettierd", "eslint_d" },
		go = { "gofumpt", "goimports-reviser", "golines", "gomodifytags", "gotests" },
		yaml = { "yamlfix", "yamlfmt" },
		json = { "fixjson", "prettierd" },
		bash = { "shellharden", "shfmt" },
		markdown = { "prettierd" },
		css = { "prettierd" },
		sql = { "pgformatter" },
		assembly = { "asmfmt" },
	},
	format_on_save = function(bufnr)
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
		end
		return { timeout_ms = 500, lsp_format = "fallback" }
	end,
})

-- Linting
vim.pack.add({ { src = "https://github.com/mfussenegger/nvim-lint" } })
local lint = require("lint")
lint.linters_by_ft = {
	go = { "golangcilint" },
	lua = { "luacheck" },
	python = { "pylint", "ruff", "mypy" },
	css = { "stylelint" },
	markdown = { "markdownlint-cli2" },
	yaml = { "yamllint" },
	json = { "jsonlint" },
	html = { "htmlhint" },
	rust = { "clippy" },
	cpp = { "clangtidy" },
	bash = { "shellcheck", "shellharden" },
	sql = { "sqlfluff", "sqruff" },
	makefile = { "checkmake" },
}

-- -- Mypy
-- local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
-- lint.linters.mypy.args = {
-- 	"--show-column-numbers",
-- 	"--show-error-end",
-- 	"--strict",
-- 	"--python-executable",
-- 	venv_python,
-- }

vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

-- Render Markdown
vim.pack.add({ { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" } })
require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
})

-- Mini
vim.pack.add({
	{ src = "https://github.com/echasnovski/mini.pairs" },
	{ src = "https://github.com/echasnovski/mini.indentscope" },
})
require("mini.pairs").setup()
require("mini.indentscope").setup({
	draw = {
		delay = 0,
	},
	symbol = "│",
	options = {
		try_as_border = true,
	},
})

-- Repl
vim.pack.add({ { src = "https://github.com/pappasam/nvim-repl" } })
map("x", "<Leader>r", "<Plug>(ReplSendVisual)", { desc = "Repl: Send visual" })
map("n", "<Leader>rc", "<Plug>(ReplSendCell)", { desc = "Repl: Send cell" })
map("n", "<Leader>rr", "<Plug>(ReplSendLine)", { desc = "Repl: Send line" })

-- Gitsigns
vim.pack.add({ { src = "https://github.com/lewis6991/gitsigns.nvim" } })
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gs = require("gitsigns")
		local function map_buf(mode, lhs, rhs, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		map_buf("n", "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "GitSigns: Stage Hunk" })
		map_buf("n", "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "GitSigns: Reset Hunk" })
		map_buf("n", "<leader>hS", ":Gitsigns stage_buffer<CR>", { desc = "GitSigns: Stage Buffer" })
		map_buf("n", "<leader>hR", ":Gitsigns reset_buffer<CR>", { desc = "GitSigns: Reset Buffer" })
		map_buf("n", "<leader>hp", ":Gitsigns preview_hunk<CR>", { desc = "GitSigns: Preview Hunk" })
		map_buf("n", "<leader>hi", ":Gitsigns preview_hunk_inline<CR>", { desc = "GitSigns: Preview Hunk Inline" })
		map_buf("n", "<leader>hb", ":Gitsigns blame_line<CR>", { desc = "GitSigns: Blame Line (Full)" })

		-- custom function keymaps
		map_buf("n", "]h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]h", bang = true })
			else
				gs.nav_hunk("next")
			end
		end, { desc = "GitSigns: Next Hunk" })

		map_buf("n", "[h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[h", bang = true })
			else
				gs.nav_hunk("prev")
			end
		end, { desc = "GitSigns: Previous Hunk" })
		map_buf("v", "<leader>hs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "GitSigns: Stage Hunk (Visual)" })
		map_buf("v", "<leader>hr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "GitSigns: Reset Hunk (Visual)" })
		map_buf("n", "<leader>hd", gs.diffthis, { desc = "GitSigns: Diff This" })
		map_buf("n", "<leader>hD", function()
			gs.diffthis("~")
		end, { desc = "GitSigns: Diff This ~" })
		map_buf("n", "<leader>hQ", function()
			gs.setqflist("all")
		end, { desc = "GitSigns: Quickfix All Hunks" })
		map_buf("n", "<leader>hq", gs.setqflist, { desc = "GitSigns: Quickfix Hunks" })
		map_buf("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "GitSigns: Toggle Line Blame" })
		map_buf("n", "<leader>tw", gs.toggle_word_diff, { desc = "GitSigns: Toggle Word Diff" })
		map_buf({ "o", "x" }, "ih", gs.select_hunk, { desc = "GitSigns: Select Hunk" })
	end,
})

-- Neogen
vim.pack.add({ { src = "https://github.com/danymat/neogen" } })
require("neogen").setup({ snippet_engines = "luasnip" })
map("n", "<leader>nf", ":Neogen func<CR>", { desc = "Neogen: Generate Function docs" })
map("n", "<leader>nt", ":Neogen type<CR>", { desc = "Neogen: Generate Type/Class docs" })

-- Neotest
vim.pack.add({
	{ src = "https://github.com/nvim-neotest/neotest" },
	{ src = "https://github.com/antoinemadec/FixCursorHold.nvim" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/nvim-neotest/neotest-python" },
	{ src = "https://github.com/nvim-neotest/neotest-jest" },
	{ src = "https://github.com/rcasia/neotest-bash" },
	{ src = "https://github.com/nvim-neotest/neotest-go" },
	{ src = "https://github.com/marilari88/neotest-vitest" },
})

require("neotest").setup({
	adapters = {
		require("neotest-python"),
		require("neotest-jest"),
		require("neotest-vitest"),
		require("neotest-bash"),
		require("neotest-go"),
	},
})
map("n", "<leader>tr", ":Neotest run<CR>", { desc = "Neotest: Run test" })
map("n", "<leader>to", ":Neotest output<CR>", { desc = "Neotest: Show output" })
map("n", "<leader>ts", ":Neotest summary<CR>", { desc = "Neotest: Show summary" })
map("n", "<leader>ta", ":lua require('neotest').run.run({suite=true})<CR>", { desc = "Neotest: Run all tests" })

-- DadBod
vim.pack.add({
	{ src = "https://github.com/kristijanhusak/vim-dadbod-ui" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-completion" },
	{ src = "https://github.com/tpope/vim-dadbod" },
})

-- Image
vim.pack.add({ { src = "https://github.com/3rd/image.nvim" } })
