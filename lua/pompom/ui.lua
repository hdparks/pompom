local Buffer = require("pompom.buffer")
local Logger = require("pompom.logger")
local Task = require("pompom.task")


--- @class PomPomUI
--- @field win_id number
--- @field bufnr number
local PomPomUI = {}
PomPomUI.__index = PomPomUI


function PomPomUI:new()
	return setmetatable({
		win_id = nil,
		bufnr = nil,
	}, self)
end

function PomPomUI:close_menu()
	if self.closing or self.win_id == nil then
		return
	end

	self.closing = true
	if self.bufnr ~= nil and vim.api.nvim_buf_is_valid(self.bufnr) then
		vim.api.nvim_buf_delete(self.bufnr, { force = true })
	end

	if self.win_id ~= nil and vim.api.nvim_win_is_valid(self.win_id) then
		vim.api.nvim_win_close(self.win_id, true)
	end

	self.win_id = nil
	self.bufnr = nil

	self.closing = false
end


--- @return number, number
function PomPomUI:_create_window()
	local config = require("pompom").config.ui_config
	local win = vim.api.nvim_list_uis()
	local width = config.fallback_width

	if #win > 0 then
		width = math.floor(win[1].width * config.width_ratio)
	end

	if config.width_max and width > config.width_max then
		width = config.width_max
	end

	local height = 10
	local bufnr = vim.api.nvim_create_buf(false, true)
	local win_id = vim.api.nvim_open_win(bufnr, true, {
		relative="editor",
		title = config.title or "PomPom",
		title_pos = config.title_pos or "left",
		row = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		style = "minimal",
		border = config.border or "single"
	})

	if win_id == 0 then
		self.bufnr = bufnr
		self:close_menu()
		error("Failed to create window")
	end

	Buffer.setup_autocmds_and_keymaps(bufnr, self)
	return win_id, bufnr
end

--- @param tasks PomPomTask[]
function PomPomUI:open_menu(tasks)
	if self.win_id ~= nil then
		self:close_menu()
	end
	Logger:log("pompom: opening quick menu")
	local win_id, bufnr = self:_create_window()
	self.win_id = win_id
	self.bufnr = bufnr

	-- replace the contents of the window with the contents of the given list
	local contents = {}
	for _, task in ipairs(tasks) do
		table.insert(contents, task:display())
	end

	vim.api.nvim_buf_set_lines(self.bufnr, 0,-1,false,contents)
	vim.api.nvim_win_set_cursor(self.win_id, {#contents, #(contents[#contents])})
end

function PomPomUI:save_contents()
	local task_strs = Buffer.get_contents(self.bufnr)
	local tasks = {}
	for _, task_str in ipairs(task_strs) do
		local task = Task.decode(task_str)
		if task ~= nil then
			table.insert(tasks, task)
		end
	end
	require('pompom'):save_tasks(tasks)
end

return PomPomUI
