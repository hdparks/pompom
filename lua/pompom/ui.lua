local Buffer = require("pompom.buffer")
local Logger = require("pompom.logger")
local Utils = require("pompom.utils")


--- @class PomPomUI
--- @field win_id number
--- @field bufnr number
--- @field settings PomPomSettings
--- @field active_list PomPomList
local PomPomUI = {}
PomPomUI.__index = PomPomUI

local function toggle_config(config)
	-- merge the table, "force" means prefer rightmost table
	return vim.tbl_extend("force", {
		ui_fallback_width = 60,
		ui_width_ratio = 1/1.618 -- golden ratio
	}, config or {})
end

--- @param list PomPomList
--- @return string
local function list_name(list)
	return list and list.name or "nil"
end

--- @param settings PomPomSettings
--- @param timer PomPomTimer
--- @return table
function PomPomUI:new(settings, timer)
	return setmetatable({
		win_id = nil,
		bufnr = nil,
		active_list = nil,
		settings = settings,
		timer = timer
	}, self)
end

function PomPomUI:close_menu()
	if self.closing then
		return
	end

	self.closing = true
	if self.bufnr ~= nil and vim.api.nvim_buf_is_valid(self.bufnr) then
		vim.api.nvim_buf_delete(self.bufnr, { force = true })
	end

	if self.win_id ~= nil and vim.api.nvim_win_is_valid(self.win_id) then
		vim.api.nvim_win_close(self.win_id, true)
	end

	self.active_list = nil
	self.win_id = nil
	self.bufnr = nil

	self.closing = false
end


--- @param toggle_opts PomPomToggleOptions
--- @return number, number
function PomPomUI:_create_window(toggle_opts)
	local win = vim.api.nvim_list_uis()
	local width = toggle_opts.ui_fallback_width

	if #win > 0 then
		width = math.floor(win[1].width * toggle_opts.ui_width_ratio)
	end

	if toggle_opts.ui_max_width and width > toggle_opts.ui_max_width then
		width = toggle_opts.ui_max_width
	end

	local height = 10
	local bufnr = vim.api.nvim_create_buf(false, true)
	local win_id = vim.api.nvim_open_win(bufnr, true, {
		relative="editor",
		title = toggle_opts.title or "PomPom",
		title_pos = toggle_opts.title_pos or "left",
		row = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		style = "minimal",
		border = toggle_opts.border or "single"
	})

	if win_id == 0 then
		self.bufnr = bufnr
		self:close_menu()
		error("Failed to create window")
	end

	Buffer.setup_autocmds_and_keymaps(bufnr)
	Utils.run_interval(
		1000,
		function ()
			-- TODO use nvim_set_win_config() to update the time remaining if the current Timer is active
		end,
		function ()
			-- TODO return true when the window is closed 
			Logger:log("pompom.ui window-updater finished")
			return true
		end)

	self.win_id = win_id


	--- What does this do?
	vim.api.nvim_set_option_value("number", true, {
		win = win_id
	})

	return win_id, bufnr
end

--- @param list? PomPomList
--- @params ops? any
function PomPomUI:toggle_quick_menu(list, opts)
	Logger:log("pomom: toggling quick menu")
	opts = toggle_config(opts)
	if list == nil or self.win_id ~= nil then
		Logger:log("pompom: closing quick menu")
		if self.settings.save_on_toggle then
			self:save()
		end
		self:close_menu()
		return
	end
	Logger:log("pompom: opening quick menu")

	local win_id, bufnr = self:_create_window(opts)
	self.win_id = win_id
	self.bufnr = bufnr
	self.active_list = list

	-- replace the contents of the window with the contents of the given list
	local contents = self.active_list:display()
	vim.api.nvim_buf_set_lines(self.bufnr, 0,-1,false,contents)
end

function PomPomUI:save()
	local list = Buffer.get_contents(self.bufnr)
	self.active_list:resolve_displayed(list)
	if self.settings.sync_on_ui_close then
		-- what is sync? What is this power?
		require('pompom'):sync()
	end
end

--- @param settings PomPomSettings
function PomPomUI:configure(settings)
	self.settings = settings
end

return PomPomUI
