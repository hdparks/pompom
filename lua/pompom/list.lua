local Logger = require("pompom.logger")

local function index_of(items, element, config)
	local equals = config and config.equals
		or function(a,b)
			return a == b
		end
	local index = -1
	for i, item in ipairs(items) do
		if equals(element, item) then
			index = i
			break
		end
	end
	return index
end

--- @class PomPomItem
--- @field value string
--- @field done boolean
--- @field duration number
--- @field context any

--- @class PomPomList
--- @field config PomPomPartialConfigItem
--- @field name string
--- @field _index number
--- @field items PomPomItem[]


local PomPomList = {}
PomPomList.__index = PomPomList

--- @return PomPomList
--- @param config PomPomParitalConfigItem
--- @param name string
--- @param items PomPomItem[]
function PomPomList:new(config, name, items)
	return setmetatable({
		items = items,
		config = config,
		name = name,
		_index = 1,
	},self)
end

--- @return number
function PomPomList:length()
	return #self.items
end

--- @return PomPomList
function PomPomList:clear()
	self.items = {}
	return self
end

--- @return PomPomList
--- @param item PomPomItem 
function PomPomList:append(item)
	item = item or self.config.create_list_item(self.config)

	local index = index_of(self.items, item, self.config)
	if index == -1 then
		table.insert(self.items, item)
	end
	return self
end

--- @return PomPomList
--- @param item PomPomItem 
function PomPomList:prepend(item)
	item = item or self.config.create_list_item(self.config)
	local index = index_of(self.items, item, self.config)
	if index == -1 then
		table.insert(self.items, 1, item)
	end

	return self
end

--- @return PomPomList
--- @param item PomPomItem 
function PomPomList:remove(item)
	item = item or self.config.create_list_item(self.config)
	for i, v in ipairs(self.items) do
		if self.config.equals(v, item) then
			table.remove(item,i)
			break
		end
	end
	return self
end

--- @return PomPomList
--- @param pos number
function PomPomList:removeAt(pos)
	if #self.items >= pos then
		table.remove(self.items, pos)
	end
	return self
end

--- @return PomPomItem
--- @param pos number
function PomPomList:get(pos)
	return self.items.get(pos)
end

--- @return string[]
function PomPomList:display()
	local displayed = {}
	for _, item in ipairs(self.items) do
		table.insert(displayed, self.config.display(item))
	end
	return displayed
end

--- @return string[]
function PomPomList:encode()
	local out = {}
	for _, v in ipairs(self.items) do
		table.insert(out, self.config.encode(v))
	end
	return out
end


--- @param config PomPomParitalConfigItem
--- @param name string
--- @param items string[]
--- @return PomPomList
function PomPomList.decode(config, name, items)
	local list_items = {}
	for _, item in ipairs(items) do
		table.insert(list_items, config.decode(item))
	end

	return PomPomList:new(config, name, list_items)
end

--- @param str string
--- @return PomPomItem?
function PomPomList:get_by_display(str)
	local displayed = self:display()
	local index = index_of(displayed, str)
	if index == -1 then
		return nil
	end
	return self.items[index]
end

--- @param displayed string[]
function PomPomList:resolve_displayed(displayed)
	Logger:log("resolving displayed list: ", self:display(), "\nvs\n", displayed)
	local new_list = {}

	local list_displayed = self:display()
	-- TODO see harpoon source for calculating "remove" list

	for i, v in ipairs(displayed) do
		local index = index_of(list_displayed, v)
		if index == -1 then
			new_list[i] = self.config.create_list_item(self.config, v)
			-- this one's new, haven't seen it around before
		else
			--if index ~= i then
			--	-- this one's out of order
			--end
			local index_in_new_list = index_of(new_list, self.items[index], self.config)
			if index_in_new_list == -1 then
				new_list[i] = self.items[index]
			end
		end
	end
	self.items = new_list
	Logger:log("list now: ", self:display())
end

return PomPomList
