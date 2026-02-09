local vim = vim

local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

--- Create editable floating window for todo.txt
local create_floating_window = function()
	local filename = "/storage/personal/notes/todo.txt"
	local screen_width = vim.o.columns
	local screen_height = vim.o.lines
	local width = math.floor(screen_width * 0.8)
	local height = math.floor(screen_height * 0.8)
	local row = math.floor((screen_height - height) / 2)
	local col = math.floor((screen_width - width) / 2)
	local buf = vim.fn.bufadd(filename)
	vim.fn.bufload(buf)
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
	vim.api.nvim_set_option_value("buftype", "", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
	local winconfig = {
		relative = "editor",
		height = height,
		width = width,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}
	local win = vim.api.nvim_open_win(buf, true, winconfig)
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":TodoWindowClose<CR>", { noremap = true, silent = true })
	return { buf = buf, win = win }
end

local toggle_floating_window = function()
	if vim.api.nvim_win_is_valid(state.floating.win) then
		vim.api.nvim_win_close(state.floating.win, true)
	else
		state.floating = create_floating_window()
	end
end

vim.api.nvim_create_user_command("TodoWindowToggle", toggle_floating_window, {})
vim.api.nvim_create_user_command("TodoWindowClose", function()
	if vim.api.nvim_win_is_valid(state.floating.win) then
		vim.api.nvim_win_close(state.floating.win, true)
	end
end, {})
