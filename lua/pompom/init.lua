local popup = require('plenary.popup')

local M = {}

local function create_window()
	local width = 50
	local height = 5 
	local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	local bufnr = vim.api.nvim_create_buf(false,false)

	local pompom_win_id, win = popup.create(bufnr, {
		title = "PomPom",
		highlight = "PomPomWindow",
		line = math.floor((vim.o.lines - height) / 2) - 1,
		col = math.floor((vim.o.columns - width) / 2),
		minwidth = width,
		minheight = height,
		borderchars = borderchars
	})

	vim.api.nvim_win_set_option(
		win.border.win_id,
		"winhl",
		"Normal:PomPomBorder"
	)

	return {
		bufnr = bufnr,
		win_id = pompom_win_id
	}
end

function M.Start(ms) 
	local timer = vim.loop.new_timer()
	timer:start(5000, ms, vim.schedule_wrap(function() 
		timer:stop()
		vim.api.nvim_command('echomsg "pompom!!"') 
		os.execute('say "ding dong break time"')
		os.execute('notify "ding dong break time"')
		create_window()
	end))
end

return M
