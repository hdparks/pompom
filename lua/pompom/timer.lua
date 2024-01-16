local Utils = require('pompom.utils')
local PomPomTimer = {}
PomPomTimer.__index = PomPomTimer
DEFAULT_POM_LENGTH = 25 * 60 * 1000 -- default pom = 25 min
DEFAULT_BREAK_LENGTH = 5 * 60 * 1000 -- default break = 5 min

--- @class PomPomTimer
--- @field settings PomPomSettings
--- @field current_timer? any
--- @field current_start number -- timestamp of the start of the current session
--- @field current_duration number -- length of the current session in ms
function PomPomTimer:new(settings)
	setmetatable({
		settings = settings,
		current_timer = nil,
		current_start = nil,
		current_duration = nil
		-- TODO: some way to pause? Might need to rethink start+duration combo
	},self)
	return self
end

--- @param ms number -- miliseconds
--- @param cb any -- callback
function PomPomTimer:start(ms, cb)
	local cb_plus_cleanup = function()
		cb()
		self.current_start = nil
		self.current_duration = nil
	end
	Utils.run_timer(ms, cb_plus_cleanup)
	self.current_start = reltime()
	self.current_duration = ms
end

function PomPomTimer:start_pom(on_session_end)
	self:start(self.pom_length, on_session_end)
end

function PomPomTimer:start_break(on_session_end)
	self:start(self.break_length, on_session_end)
end

--- @param settings PomPomSettings
function PomPomTimer:configure(settings)
	self.settings = settings
end

--- @return number -- time remaining in seconds
function PomPomTimer:get_time_remaining()
	return self.current_start + self.current_duration - reltime()
end

--- @return string -- time remaining, pretty
function PomPomTimer:get_time_remaining_str()
	local seconds = self:get_time_remaining()
	local hours = seconds / (60 * 60)
	seconds = seconds % (60 * 60)
	local minutes = seconds / 60
	seconds = seconds % 60

	local out = {}
	if hours > 0 then
		out.insert(hours .. "h ")
	end
	if minutes > 0 then
		out.insert(minutes .. "m ")
	end
	out.insert(seconds .. "s")
	local outstr = out:concat() .. " remaining"
	return outstr
end

return PomPomTimer
