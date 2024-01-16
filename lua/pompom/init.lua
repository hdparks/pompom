local Ui = require('pompom.ui')
local Data = require("pompom.data")
local Config = require('pompom.config')
local List = require("pompom.list")
local Timer = require("pompom.timer")

--- @class PomPom
--- @field config PomPomConfig
--- @field ui PomPomUI
--- @field data PomPomData
--- @field lists {[string]:{[string]: PomPomList}}
--- @field timer PomPomTimer
local PomPom = {}

PomPom.__index = PomPom

---@return PomPom
function PomPom:new()
	local config = Config.get_defualt_config()

	local pompom = setmetatable({
		config = config,
		data = Data.Data:new(),
		ui = Ui:new(config.settings),
		lists = {},
		timer = Timer:new(config.settings)
	}, self)
	return pompom
end

---@param name string?
---@return PomPomList
function PomPom:list(name)
	name = name or Config.DEFAULT_LIST

	local key = self.config.settings.key()
	local lists = self.lists[key]

	if not lists then
		lists = {}
		self.lists[key] = lists
	end

	local existing_list = lists[name]

	if existing_list then
		if not self.data.seen[key] then
			self.data.seen[key] = {}
		end
		self.data.seen[key][name] = true
		return existing_list
	end

	local data = self.data:data(key, name)
	local list_config = Config.get_config(self.config, name)

	local list = List.decode(list_config, name, data)
	lists[name] = list
	return list
end

function PomPom:_for_each_list(cb)
	local key = self.config.settings.key()
	local seen = self.data.seen[key]
	local lists = self.lists[key]

	if not seen then
		return
	end

	for list_name, _ in pairs(seen) do
		local list_config = Config.get_config(self.config, list_name)
		cb(lists[list_name], list_config, list_name)
	end
end

function PomPom:sync()
	local key = self.config.settings.key()
	self:_for_each_list(function(list, _, list_name)
		if list.config.encode == false then
			return
		end

		local encoded = list:encode()
		self.data:update(key, list_name, encoded)
	end)
	self.data:sync()
end

function PomPom:info()
	return {
		paths = Data.info(),
		default_list_name = Config.DEFAULT_LIST
	}
end

function PomPom:dump()
	return self.data._data
end

local the_pompom = PomPom:new()

--- @param partial_config PomPomPartialConfig
--- @return PomPom
function PomPom:setup(partial_config)
	if self ~= the_pompom then
		---@diagnostic disable-next-line: cast-local-type
		partial_config = self
		self = the_pompom
	end

	self.config = Config.merge_config(partial_config, self.config)
	self.ui:configure(self.config.settings)

	return self
end


return the_pompom
