local Ui = require('pompom.ui')
local Data = require("pompom.data")
local Logger = require("pompom.logger")
local Config = require("pompom.config")

--- @class PomPom
--- @field ui PomPomUI
--- @field config PomPomConfig
--- @field current_list_name string
local PomPom = {}

PomPom.__index = PomPom

---@return PomPom
function PomPom:new()
	return setmetatable({
		ui = Ui:new(),
		current_list_name = vim.loop.cwd(),
		config = Config:default()
	}, self)
end

--- @return PomPomTask[]
function PomPom:get_tasks()
	local data = Data.read_tasks(self.current_list_name)
	return data
end

--- @param tasks PomPomTask[]
function PomPom:save_tasks(tasks)
	Data.write_tasks(self.current_list_name, tasks)
end

function PomPom:toggle_ui()
	if self.ui.win_id ~= nil then
		self.ui:close_menu()
	else
		self.ui:open_menu(self:get_tasks())
	end
end


--- @param index? integer
function PomPom:add_task(index)
	if self.ui.win_id == nil then
		self:toggle_ui()
	end
	self.ui:add_new_task(index)
end

-- singleton pompom
local the_pompom = PomPom:new()
return the_pompom
