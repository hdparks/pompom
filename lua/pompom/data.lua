local Path = require("plenary.path")
local Logger = require("pompom.logger")

local data_path = vim.fn.stdpath("data")
local full_data_path = string.format("%s/pompom.json",data_path)

--- @param data any 
local function write_data(data)
	Logger:log("pompom.data: writing data")
	Path:new(full_data_path):write(vim.json.encode(data), "w")
end

local M = {}

function M.__dangerously_clear_data()
	write_data({})
end

function M.info()
	return {
		data_path = data_path,
		full_data_path = full_data_path
	}
end

function M.set_data_path(path)
	full_data_path = path
end

local function has_keys(t)
	for _ in pairs(t) do
		return true
	end

	return false
end


--- @alias PomPomRawData {[string]: {[string]:string[]}}

--- @class PomPomData 
--- @field seen {[string]:{[string]:boolean}}
--- @field _data PomPomRawData
--- @field has_error boolean
local Data = {}

-- 1. load data
-- 2. keep track of the lists requested
-- 3. sync save

Data.__index = Data

--- @return PomPomRawData
local function read_data()
	Logger:log("pompom.data: reading data")
	local path = Path:new(full_data_path)
	local exists = path:exists()

	if not exists then
		Logger:log("pompom.data: no data found, initializing")
		write_data({})
	end

	local out_data = path:read()

	if not out_data or out_data == "" then
		Logger:log("pompom.data: data empty, reinitializing")
		write_data({})
		out_data = path:read()
	end

	local data = vim.json.decode(out_data)
	Logger:log("pompom.data:", data)
	return data
end


--- @return PomPomData
function Data:new()
	local ok, data = pcall(read_data)
	Logger:log("pompom.data: init", tostring(ok))
	return setmetatable({
		_data = data,
		has_error = not ok,
		seen = {}
	}, self)
end

--- @param key string
--- @param name string
--- @return string[]
function Data:_get_data(key, name)
	if not self._data[key] then
		self._data[key] = {}
	end

	return self._data[key][name] or {}
end

--- @param key string
--- @param name string
--- @return string[]
function Data:data(key, name)
	if self.has_error then
		error("PomPom: there was an error reading the data file, cannot read data")
	end

	if not self.seen[key] then
		self.seen[key] = {}
	end

	self.seen[key][name] = true

	return self:_get_data(key, name)
end


--- @param key string
--- @param name string
--- @param values string[]
function Data:update(key, name, values)
	if self.has_error then
		error("PomPom: there was an error reading the data file, cannot update")
	end
	self:_get_data(key, name)
	self._data[key][name] = values
end

function Data:sync()
	Logger:log("pompom.data: syncing data")
	if self.has_error then
		return
	end

	if not has_keys(self.seen) then
		Logger:log("pompom.data: nothing seen, early out")
		return
	end

	local ok, data = pcall(read_data)
	if not ok then 
		error("PomPom: unable to sync data, error reading data file")
	end

	for k, v in pairs(self._data) do
		data[k] = v
	end

	ok = pcall(write_data, data)

	if ok then
		self.seen = {}
	end
end

M.Data = Data

return M
