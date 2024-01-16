local PomPomUtils = {}

--- @param str string
--- @param separator string
--- @return string[]
function PomPomUtils.split(str, separator)
	if separator == nil then
		separator = "%s"
	end

	local out = {}

	for group in string.gmatch(str,"([^"..separator.."]+)") do
		table.insert(out, group)
	end
	return out
end


--- @param str string
--- @return boolean
function PomPomUtils.is_whitespace(str)
	return string.gsub(str,"%s","") == ""
end

--- @param str string
--- @return string
function PomPomUtils.trim(str)
	return str:gsub("^%s+",""):gsub("%s+$","")
end

--- @param str string
--- @return string
function PomPomUtils.remove_duplicate_whitespace(str)
	return str:gsub("%s+"," ")
end


function PomPomUtils.run_timer(ms, cb)
	local timer = vim.loop.new_timer()
	timer:start(ms, 0, vim.schedule_wrap(function()
		timer:stop()
		cb()
	end))
end

--- @param ms number -- length of interval in ms
--- @param cb (fun()) -- callback: to be run each interval
--- @param cb_until (fun():boolean) -- callback: when true or error, stop interval
function PomPomUtils.run_interval(ms, cb, cb_until)
	local timer = vim.loop.new_timer()
	timer:start(0, ms, vim.schedule_wrap(function()
		print('on schedule!', cb, cb_until)
		local success, done = pcall(cb_until)
		-- if done or error, stop timer
		if not success or done then
			timer:stop()
		end
		-- if error, throw
		if not success then
			error(done)
		end
		cb()
	end))
end

return PomPomUtils
