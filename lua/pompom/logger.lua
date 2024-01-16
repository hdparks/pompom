local utils = require("pompom.utils")

--- @class PomPomLog
--- @field lines string[]
--- @field max_lines number

local PomPomLog = {}
PomPomLog.__index = PomPomLog

function PomPomLog:new()
	return setmetatable({
		lines = {},
		enabled = true,
		max_lines = 50,
	}, self)
end

function PomPomLog:disable()
	self.enabled = false
end

function PomPomLog:enable()
	self.enabled = true
end

--- @vararg any
function PomPomLog:log(...)
	local processed = {}
	for i=1,select("#",...) do
		local item = select(i,...)
		if type(item) == "table" then
			item = vim.inspect(item)
		end
		table.insert(processed, item)
	end

	local lines = {}
	for _, line in ipairs(processed) do
		local split = utils.split(line, "\n")
		for _, l in ipairs(split) do
			if not utils.is_whitespace(l) then
				local ll = utils.trim(utils.remove_duplicate_whitespace(l))
				table.insert(lines, ll)
			end
		end
	end

	table.insert(self.lines, table.concat(lines, " "))

	while #self.lines > self.max_lines do
		table.remove(self.lines, 1)
	end
end

function PomPomLog:clear()
	self.lines = {}
end

function PomPomLog:show()
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0,-1,false, self.lines)
	vim.api.nvim_win_set_buf(0,bufnr)
end

return PomPomLog:new()
