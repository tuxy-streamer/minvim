local vim = vim

--  NOTE: Autocmds

-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Open PDF in PDF viewer
vim.api.nvim_create_autocmd("BufReadCmd", {
	pattern = "*.pdf",
	callback = function()
		local filename = vim.fn.shellescape(vim.api.nvim_buf_get_name(0))
		vim.cmd("silent !zathura " .. filename .. " &")
		vim.cmd("let tobedeleted = bufnr('%') | b# | exe \"bd! \" . tobedeleted")
	end,
})

--  NOTE: Settings

-- Global
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.autoformat = true
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }
vim.g.deprecation_warnings = true
vim.g.trouble_lualine = true
vim.g.markdown_recommended_style = 0
vim.g.db_ui_use_nerd_fonts = 1

local opt = vim.opt

-- General
opt.number = true
opt.relativenumber = true
opt.wrap = false
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.spelllang = { "en" }
opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
opt.spell = true

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Search
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Visual
opt.termguicolors = true
opt.signcolumn = "yes"
opt.numberwidth = 1
opt.showmatch = true
opt.ruler = true
opt.showmode = false
opt.conceallevel = 0
opt.concealcursor = ""
opt.lazyredraw = true
opt.synmaxcol = 300
opt.virtualedit = "block"
opt.showtabline = 1
opt.winborder = "rounded"
opt.background = "dark"

-- File
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.undolevels = 10000
opt.wildmode = "longest:full,full"
opt.autoread = true

-- Behavior
opt.autochdir = false
opt.iskeyword:append("-")
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.modifiable = true

-- Startup & Redraw
opt.timeoutlen = 300
opt.updatetime = 250
opt.redrawtime = 1500
opt.regexpengine = 2
-- Treesitter performance
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99

-- Buffer loading
opt.hidden = true
opt.bufhidden = "wipe"

--   NOTE: Keymaps

local map = vim.keymap.set

-- Default
map("n", "<Leader>vu", ":update<CR> :source<CR>", { desc = "Default: Update and Source current file" })
map("n", "<Leader>vr", ":restart<CR>", { desc = "Default: Restart neovim" })
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Default: Clear search highlight" })

-- Terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: Exit insert mode" })

--  NOTE: Plugins

-- Colorscheme
vim.pack.add({ { src = "https://github.com/rebelot/kanagawa.nvim" } })
vim.cmd("colorscheme kanagawa")

--  HACK: Do Not Remove
-- (Override colorscheme border).
vim.api.nvim_set_hl(0, "FloatBorder", { fg = nil, bg = nil })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = nil, fg = nil })

-- Oil
vim.pack.add({ { src = "https://github.com/stevearc/oil.nvim" } })
require("oil").setup()
map("n", "\\", ":Oil<CR>", { desc = "Oil: Open parent directory" })

-- Todo Comments
vim.pack.add({ { src = "https://github.com/folke/todo-comments.nvim" } })
require("todo-comments").setup({
	highlight = {
		multiline_context = 100,
		max_line_len = 1000,
	},
})
map("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "TodoComments: Previous Todo Comment" })
map("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "TodoComments: Next Todo Comment" })
map("n", "<Leader>st", ":TodoTelescope<cr>", { desc = "TodoComments: Search Todo comment in telescope" })

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
map("n", "<Leader>sf", ":Telescope find_files<CR>", { desc = "Telescope: Find files" })
map("n", "<Leader>sl", ":Telescope live_grep<CR>", { desc = "Telescope: Live grep" })
map("n", "<Leader>sb", ":Telescope buffers<CR>", { desc = "Telescope: Search buffers" })
map("n", "<Leader>sh", ":Telescope help_tags<CR>", { desc = "Telescope: Search help tags" })
map("n", "<Leader>so", ":Telescope builtin<CR>", { desc = "Telescope: Search options" })
map("n", "<Leader>sv", ":Telescope vim_options<CR>", { desc = "Telescope: Search vim options" })
map("n", "<Leader>sg", ":Telescope git_files<CR>", { desc = "Telescope: Search git files" })

-- Treesitter
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
})

require("nvim-treesitter").setup({
	ensure_installed = {
		"vimdoc",
		"javascript",
		"typescript",
		"c",
		"lua",
		"rust",
		"jsdoc",
		"bash",
		"go",
	},
	sync_install = true,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
	auto_install = true,

	indent = {
		enable = true,
	},

	highlight = {
		-- `false` will disable the whole extension
		enable = true,
		disable = function(lang, buf)
			if lang == "html" then
				print("disabled")
				return true
			end

			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				vim.notify(
					"File larger than 100KB treesitter disabled for performance",
					vim.log.levels.WARN,
					{ title = "Treesitter" }
				)
				return true
			end
		end,

		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = { "markdown" },
	},
})

require("treesitter-context").setup({
	enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
	multiwindow = false, -- Enable multiwindow support.
	max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
	min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
	line_numbers = true,
	multiline_threshold = 20, -- Maximum number of lines to show for a single context
	trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
	mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
	-- Separator between context and content. Should be a single character string, like '-'.
	-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
	separator = nil,
	zindex = 20, -- The Z-index of the context window
	on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
})

-- Autocompletion (Blink)
vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
})
require("luasnip").setup({ enable_autosnippets = true })
require("luasnip.loaders.from_vscode").lazy_load()
local blink_cmp = require("blink.cmp")
blink_cmp.setup({
	fuzzy = { implementation = "lua" },
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

-- Lsp (Nvim-Lspconfig, Mason)
vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
})

local langs = {
	bash = {
		lsp = "bashls",
		linter = { "shellcheck", "shellharden" },
		formatter = "shfmt",
	},
	c = {
		lsp = "clangd",
		formatter = "clang-format",
	},
	css = {
		linter = "stylelint",
	},
	git = {
		linter = { "gitleaks", "gitlint" },
	},
	go = {
		lsp = "gopls",
		linter = { "golangci-lint", "goimports-reviser", "golines", "gomodifytags", "gotests" },
		formatter = "gofumpt",
	},
	html = {
		linter = "htmlhint",
	},
	js = {
		linter = "eslint_d",
		formatter = "prettier",
	},
	json = {
		linter = { "jsonlint", "fixjson" },
	},
	lua = {
		lsp = "lua_ls",
		linter = "luacheck",
		formatter = "stylua",
	},
	make = { linter = "checkmake" },
	markdown = {
		lsp = "marksman",
		linter = "markdownlint-cli2",
		formatter = "prettier",
	},
	python = {
		lsp = "ruff",
		linter = { "bandit", "mypy", "flake8" },
		formatter = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
	},
	rust = {
		lsp = "rust_analyzer",
		linter = { "clippy" },
		formatter = "rustfmt",
	},
	sql = {
		linter = { "sqlfluff", "sqruff" },
		formatter = "pgformatter",
	},
	toml = {
		linter = "tombi",
	},
	yaml = {
		lsp = "yamlls",
		linter = { "yamllint", "yamlfix" },
		formatter = "yamlfmt",
	},
	zig = {
		lsp = "zls",
	},
}

local function collectLsp(src, dest)
	for k, v in pairs(src) do
		if k == "lsp" then
			if type(v) == "string" then
				table.insert(dest, v)
			elseif type(v) == "table" then
				collectLsp(v, dest)
			end
		elseif type(v) == "table" then
			collectLsp(v, dest)
		end
	end
	return dest
end

local function collectLinter(src, dest)
	for k, v in pairs(src) do
		if k == "linter" then
			if type(v) == "string" then
				table.insert(dest, v)
			elseif type(v) == "table" then
				for _, item in pairs(v) do
					if type(item) == "string" then
						table.insert(dest, item)
					elseif type(item) == "table" then
						collectLinter(item, dest)
					end
				end
			end
		elseif type(v) == "table" then
			collectLinter(v, dest)
		end
	end
end

local function collectFormatter(src, dest)
	for k, v in pairs(src) do
		if k == "formatter" then
			if type(v) == "string" then
				table.insert(dest, v)
			elseif type(v) == "table" then
				for _, item in pairs(v) do
					if type(item) == "string" then
						table.insert(dest, item)
					elseif type(item) == "table" then
						collectFormatter(item, dest)
					end
				end
			end
		elseif type(v) == "table" then
			collectFormatter(v, dest)
		end
	end
end

local lsptbl = {}
local lintertbl = {}
local formattertbl = {}
collectLsp(langs, lsptbl)
collectLinter(langs, lintertbl)
collectFormatter(langs, formattertbl)

local toolstbl = {}
for _, v in ipairs(lintertbl) do
	table.insert(toolstbl, v)
end
for _, v in ipairs(formattertbl) do
	table.insert(toolstbl, v)
end

local lspconfig = require("lspconfig")
local capabilities =
	vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), blink_cmp.get_lsp_capabilities())
require("mason").setup()

require("mason-tool-installer").setup({
	ensure_installed = toolstbl,
	auto_update = true,
	run_on_start = true,
	debounce_hours = 10,
})

require("mason-lspconfig").setup({
	ensure_installed = lsptbl,
	handlers = {
		function(server_name)
			lspconfig[server_name].setup({
				capabilities = capabilities,
			})
		end,
	},
})

vim.lsp.config("ruff", {
	settings = {
		configuration = "~/.config/lsp/ruff.toml",
	},
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = { vim.env.VIMRUNTIME },
				checkThirdParty = false,
			},
			telemetry = {
				enabled = false,
			},
		},
	},
})

vim.diagnostic.config({
	virtual_text = false,
	float = {
		focusable = false,
		border = "rounded",
		source = true,
		header = "",
		prefix = "",
	},
})

vim.lsp.buf.hover({
	border = "rounded",
})

vim.lsp.enable(lsptbl)

map("n", "gd", ":Telescope lsp_definitions<CR>", { desc = "LSP: Search definition in telescope" })
map("n", "gr", ":Telescope lsp_references<CR>", { desc = "LSP: Show references in telescope" })
map("n", "gws", ":Telescope lsp_workspace_symbols<CR>", { desc = "LSP: Show workspace symbols in telescope" })
map("n", "gds", ":Telescope lsp_document_symbols<CR>", { desc = "LSP: Show document symbols in telescope" })
map("n", "<Leader>grr", ":LspRestart<CR>", { desc = "LSP: Restart Server" })
map({ "n", "v" }, "<Leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code Action" })
map("n", "K", function()
	vim.lsp.buf.hover({
		border = "rounded",
	})
end, { desc = "LSP: Hover" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Go to Declaration" })
map("n", "<Leader>d", vim.diagnostic.open_float, { desc = "LSP: Show Diagnostics" })
map("n", "<Leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename Symbol" })

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
		javascript = { "prettier", "eslint_d" },
		typescript = { "prettier", "eslint_d" },
		go = { "gofumpt", "goimports-reviser", "golines", "gomodifytags", "gotests" },
		yaml = { "yamlfix", "yamlfmt" },
		json = { "fixjson", "prettier" },
		bash = { "shellharden", "shfmt" },
		markdown = { "prettier" },
		css = { "prettier" },
		sql = { "pgformatter" },
		assembly = { "asmfmt" },
		toml = { "tombi" },
	},
	format_on_save = function(bufnr)
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
		end
		vim.schedule(function()
			conform.format({ bufnr = bufnr, timeout_ms = 500, lsp_format = "fallback" })
		end)
	end,
})

-- Linting
vim.pack.add({ { src = "https://github.com/mfussenegger/nvim-lint" } })
local lint = require("lint")
lint.linters_by_ft = {
	go = { "golangcilint" },
	lua = { "luacheck" },
	python = { "ruff", "mypy", "bandit", "flake8" },
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
	toml = { "tombi" },
}

-- Mypy
lint.linters.mypy.args = {
	"--show-column-numbers",
	"--show-error-end",
	"--strict",
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

-- Render Markdown
vim.pack.add({ { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" } })
require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
	render_modes = true,
	indent = {
		enabled = true,
		skip_heading = false,
	},
	sign = { enabled = true },
	heading = {
		enabled = true,
		render_modes = false,
		atx = true,
		setext = false,
		sign = true,
		icons = {},
		position = "inline",
		width = "block",
		right_pad = 1,
		border = false,
		border_virtual = false,
		border_prefix = false,
		above = "",
		below = "",
	},
})

-- Mini (Pairs, Indentscope, Icons)
vim.pack.add({
	{ src = "https://github.com/echasnovski/mini.pairs" },
	{ src = "https://github.com/echasnovski/mini.indentscope" },
	{ src = "https://github.com/nvim-mini/mini.icons" },
})
require("mini.pairs").setup()
require("mini.icons").setup()
require("mini.indentscope").setup({
	draw = {
		delay = 0,
	},
	symbol = "│",
	options = {
		try_as_border = true,
	},
})

-- IRON
vim.pack.add({ { src = "https://github.com/Vigemus/iron.nvim.git" } })
require("iron.core").setup({
	config = {
		scratch_repl = true,
		repl_definition = {
			sh = {
				command = { "bash" },
			},
			python = {
				command = { "ipython", "--no-autoindent" },
				format = require("iron.fts.common").bracketed_paste_python,
				block_dividers = { "# %%", "#%%" },
				env = { PYTHON_BASIC_REPL = "1" },
			},
		},
		repl_filetype = function(_, ft)
			return ft
		end,
		dap_integration = true,
		repl_open_cmd = require("iron.view").split.vertical.botright(50),
	},
	keymaps = {
		toggle_repl = "<space>rr",
		restart_repl = "<space>rR",
		send_motion = "<space>rv",
		visual_send = "<space>rv",
		send_file = "<space>rf",
		send_line = "<space>rl",
		send_paragraph = "<space>rp",
		send_until_cursor = "<space>rc",
		send_code_block = "<space>rb",
		send_code_block_and_move = "<space>rbn",
		cr = "<space>rs<cr>",
		interrupt = "<space>rsi",
		exit = "<space>rq",
		clear = "<space>rd",
	},
	highlight = {
		underline = true,
	},
	ignore_blank_lines = true,
})

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

		map_buf("n", "<Leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "GitSigns: Stage Hunk" })
		map_buf("n", "<Leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "GitSigns: Reset Hunk" })
		map_buf("n", "<Leader>hS", ":Gitsigns stage_buffer<CR>", { desc = "GitSigns: Stage Buffer" })
		map_buf("n", "<Leader>hR", ":Gitsigns reset_buffer<CR>", { desc = "GitSigns: Reset Buffer" })
		map_buf("n", "<Leader>hp", ":Gitsigns preview_hunk<CR>", { desc = "GitSigns: Preview Hunk" })
		map_buf("n", "<Leader>hi", ":Gitsigns preview_hunk_inline<CR>", { desc = "GitSigns: Preview Hunk Inline" })
		map_buf("n", "<Leader>hb", ":Gitsigns blame_line<CR>", { desc = "GitSigns: Blame Line (Full)" })

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
		map_buf("v", "<Leader>hs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "GitSigns: Stage Hunk (Visual)" })
		map_buf("v", "<Leader>hr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "GitSigns: Reset Hunk (Visual)" })
		map_buf("n", "<Leader>hd", gs.diffthis, { desc = "GitSigns: Diff This" })
		map_buf("n", "<Leader>hD", function()
			gs.diffthis("~")
		end, { desc = "GitSigns: Diff This ~" })
		map_buf("n", "<Leader>hQ", function()
			gs.setqflist("all")
		end, { desc = "GitSigns: Quickfix All Hunks" })
		map_buf("n", "<Leader>hq", gs.setqflist, { desc = "GitSigns: Quickfix Hunks" })
		map_buf("n", "<Leader>tb", gs.toggle_current_line_blame, { desc = "GitSigns: Toggle Line Blame" })
		map_buf("n", "<Leader>tw", gs.toggle_word_diff, { desc = "GitSigns: Toggle Word Diff" })
		map_buf({ "o", "x" }, "ih", gs.select_hunk, { desc = "GitSigns: Select Hunk" })
	end,
})

-- Neogen
vim.pack.add({ { src = "https://github.com/danymat/neogen" } })
require("neogen").setup({ snippet_engines = "luasnip" })
map("n", "<Leader>nf", ":Neogen func<CR>", { desc = "Neogen: Generate Function docs" })
map("n", "<Leader>nt", ":Neogen type<CR>", { desc = "Neogen: Generate Type/Class docs" })

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
map("n", "<Leader>tr", ":Neotest run<CR>", { desc = "Neotest: Run test" })
map("n", "<Leader>to", ":Neotest output<CR>", { desc = "Neotest: Show output" })
map("n", "<Leader>ts", ":Neotest summary<CR>", { desc = "Neotest: Show summary" })
map("n", "<Leader>ta", ":lua require('neotest').run.run({suite=true})<CR>", { desc = "Neotest: Run all tests" })

-- DadBod
vim.pack.add({
	{ src = "https://github.com/kristijanhusak/vim-dadbod-ui" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-completion" },
	{ src = "https://github.com/tpope/vim-dadbod" },
})

-- Image
vim.pack.add({ { src = "https://github.com/3rd/image.nvim" } })
require("image").setup({
	backend = "kitty",
	processor = "magick_cli",
	integrations = {
		markdown = {
			enabled = true,
			clear_in_insert_mode = false,
			download_remote_images = true,
			only_render_image_at_cursor = false,
			only_render_image_at_cursor_mode = "popup",
			floating_windows = false,
			filetypes = { "markdown", "vimwiki" },
		},
		neorg = {
			enabled = true,
			filetypes = { "norg" },
		},
		typst = {
			enabled = true,
			filetypes = { "typst" },
		},
		html = {
			enabled = false,
		},
		css = {
			enabled = false,
		},
	},
	max_width = nil,
	max_height = nil,
	max_width_window_percentage = nil,
	max_height_window_percentage = 50,
	scale_factor = 1.0,
	window_overlap_clear_enabled = false,
	window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "scrollview", "scrollview_sign" },
	editor_only_render_when_focused = false,
	tmux_show_only_in_active_window = false,
	hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
})
-- DAP
vim.pack.add({
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
	{ src = "https://github.com/jay-babu/mason-nvim-dap.nvim" },
})

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

require("mason-nvim-dap").setup({
	handlers = {
		function(config)
			require("mason-nvim-dap").default_setup(config)
		end,
	},
})

local dap = require("dap")
require("dapui").setup()

map("n", "<Leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "DAP: Toggle Breakpoint" })
map("n", "<Leader>dr", "<cmd>DapToggleRepl<CR>", { desc = "DAP: Toggle REPL" })
map("n", "<Leader>dc", "<cmd>DapContinue<CR>", { desc = "DAP: Continue" })
map("n", "<Leader>di", "<cmd>DapStepInto<CR>", { desc = "DAP: Step Into" })
map("n", "<Leader>do", "<cmd>DapStepOut<CR>", { desc = "DAP: Step Out" })
map("n", "<Leader>dO", "<cmd>DapStepOver<CR>", { desc = "DAP: Step Over" })
map("n", "<Leader>dP", "<cmd>DapPause<CR>", { desc = "DAP: Pause" })
map("n", "<Leader>dt", "<cmd>DapTerminate<CR>", { desc = "DAP: Terminate" })

-- custom function keymaps
local dap_widgets = require("dap.ui.widgets")

local function dap_cond_bp()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end

local function dap_continue_args()
	require("dap")
	dap.continue({ before = get_args })
end

map("n", "<Leader>dB", dap_cond_bp, { desc = "DAP: Conditional Breakpoint" })
map("n", "<Leader>da", dap_continue_args, { desc = "DAP: Continue with Args" })
map("n", "<Leader>dC", dap.run_to_cursor, { desc = "DAP: Run to Cursor" })
map("n", "<Leader>dg", dap.goto_, { desc = "DAP: Go to Line" })
map("n", "<Leader>dj", dap.down, { desc = "DAP: Move Down Frame" })
map("n", "<Leader>dk", dap.up, { desc = "DAP: Move Up Frame" })
map("n", "<Leader>dl", dap.run_last, { desc = "DAP: Run Last" })
map("n", "<Leader>ds", dap.session, { desc = "DAP: Show Session Info" })
map("n", "<Leader>dw", dap_widgets.hover, { desc = "DAP: Hover Widget" })

-- Obsidian
vim.pack.add({ { src = "https://github.com/obsidian-nvim/obsidian.nvim" } })
require("obsidian").setup({
	legacy_commands = false,
	workspaces = {
		{
			name = "personal",
			path = "/storage/personal/notes/",
		},
	},
})
map("n", "<Leader>oo", "<cmd>Obsidian<CR>", { desc = "Obsidian: Obsidian Subcommands" })
map("n", "<Leader>ob", "<cmd>Obsidian backlinks<CR>", { desc = "Obsidian: Obsidian Backlinks" })
