
--- @class PomPomTimer
--- @field timer uv_timer_t
--- @field callback function
--- @field duration number
--- @field running boolean
local PomPomTimer = {}
PomPomTimer.__index = PomPomTimer

--- @param duration number
---@param callback function
function PomPomTimer:new(duration, callback)
	local timer = vim.loop.new_timer()
	return setmetatable({
		duration=duration,
		remaining=duration,
		callback=callback,
		timer=timer,
		running=false
	}, self)
end

function PomPomTimer:start()
	print('starting')
	self.timer:start(self.remaining,0,self.callback)
	self.running = true
end

function PomPomTimer:pause()
	print("pausing")
	self.timer:stop()
	self.remaining = self:getRemainingMs()
	self.running = false
end


function PomPomTimer:toggle()
	if self.running then
		self:pause()
	else
		self:start()
	end
end

function PomPomTimer:close()
	self.timer:close()
end

function PomPomTimer:reset()
	self.remaining = self.duration
end

function PomPomTimer:getRemainingMs()
	if self.running then
		return self.timer:get_due_in()
	else
		return self.remaining
	end
end

return PomPomTimer
