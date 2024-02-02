local Utils = require("pompom.utils")
--- @class PomPomTask
--- @field done boolean
--- @field text string

local PomPomTask = {}
PomPomTask.__index = PomPomTask

--- @param done? boolean
--- @param text? string
function PomPomTask:new(text, done)
	return setmetatable({
		done = done or false,
		text = text or "new task"
	}, self)
end

--- @param str string
--- @return PomPomTask?
function PomPomTask.decode(str)
	if str == nil then
		return nil
	end
	local config = require('pompom').config.task_config
	local done = str:sub(1, #config.done_prefix) == config.done_prefix
	local text = str:gsub("^" .. Utils.to_escaped_str(config.done_prefix), ""):gsub("^"..Utils.to_escaped_str(config.not_done_prefix), "")
	return PomPomTask:new(text, done)
end

function PomPomTask:display()
	local config = require('pompom').config.task_config
	return (self.done and config.done_prefix or config.not_done_prefix) .. self.text
end

return PomPomTask
