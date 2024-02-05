local Path = require("plenary.path")
local Logger = require("pompom.logger")
local Task = require("pompom.task")
local utils = require("pompom.utils")

local data_path = vim.fn.stdpath("data") .. "/pompom_data"
-- ensure directory exists
local data_path_dir = Path:new(data_path)
local mkdir_result = data_path_dir:mkdir({exists_ok = true})
Logger:log('mkdir_result: ' .. tostring(mkdir_result))

--- @param list_name string
--- @return string
local function escape_list_name(list_name)
	return list_name:gsub("%/","_")
end

--- @param list_name string
--- @return string
local function get_path(list_name)
	return data_path .."/".. escape_list_name(list_name) .. ".json"
end

--- @param list_name string
--- @param data any
local function write_data(list_name, data)
	local full_data_path = get_path(list_name)
	Logger:log("pompom.data: writing data to ".. full_data_path)
	local path = Path:new(full_data_path)
	local input = vim.json.encode(data)
	path:write(input, "w")
end

--- @param list_name string
--- @return data any
local function read_data(list_name)
	local full_data_path = get_path(list_name)
	Logger:log("reading from "..full_data_path)

	local file = Path:new(full_data_path)
	if not file:exists() then
		Logger:log("creating file" .. full_data_path)
		write_data(list_name, {})
	end
	local contents = file:read()

	return vim.json.decode(contents)
end

local PomPomData = {}
PomPomData.__index = PomPomData

--- @param list_name string 
--- @param tasks PomPomTask[]
function PomPomData.write_tasks(list_name, tasks)
	write_data(list_name, tasks)
end

--- @param list_name string
--- @return PomPomTask[]
function PomPomData.read_tasks(list_name)
	local task_objs = read_data(list_name)
	local tasks = {}
	for _, task_obj in ipairs(task_objs) do
		local task = Task:new(task_obj['text'], task_obj['done'])
		table.insert(tasks, task)
	end
	return tasks
end

return PomPomData
