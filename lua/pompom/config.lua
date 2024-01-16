local Logger = require("pompom.logger")
local M = {}
local DEFAULT_LIST = "__pompom_files"
local DEFAULT_DONE_PREFIX = "- [x] "
local DEFAULT_NOT_DONE_PREFIX = "- [ ] "
local DEFAULT_DONE_PREFIX_ESCAPED = "%- %[x%] ?"
local DEFAULT_NOT_DONE_PREFIX_ESCAPED = "%- %[ %] ?"
M.DEFAULT_LIST = DEFAULT_LIST



--- @alias PomPomListItem { value: string, done: boolean }

--- @class PomPomConfig
--- @field default PomPomParitalConfigItem
--- @field settings PomPomSettings
--- @field [string] PomPomParitalConfigItem

--- @class PomPomParitalConfigItem
--- @field display? (fun(item: PomPomListItem): string)
--- @field equals? (fun(a: PomPomListItem, b:PomPomListItem): boolean)
--- @field encode? (fun(obj: PomPomListItem): string)
--- @field decode? (fun(str:string): PomPomListItem)
--- @field create_list_item? (fun(config:PomPomParitalConfigItem,item:any?):PomPomListItem)

--- @class PomPomSettings
--- @field save_on_toggle boolean defaults to false
--- @field sync_on_ui_close? boolean
--- @field pom_length? number
--- @field break_length? number
--- @field key (fun(): string)

--- @return PomPomParitalConfigItem
function M.get_config(config, name)
	return vim.tbl_extend("force", {}, config.default, config[name] or {})
end

--- @return PomPomConfig
function M.get_defualt_config()
	return {
		settings = {
			save_on_toggle = false,
			sync_on_ui_close = false,
			pom_length = 25 * 60 * 1000, -- default to 25 minutes
			break_length = 5 * 60 * 1000, -- default to 5 minutes

			-- TODO does this do the right thing? is having new lists for each working directory the right thing?
			key = function() return vim.loop.cwd() end,
		},
		default = {
			--- @param obj PomPomListItem
			--- @return string
			encode = function(obj)
				return vim.json.encode(obj)
			end,

			--- @param str string
			--- @return PomPomListItem
			decode = function(str)
				return vim.json.decode(str)
			end,

			--- @param item PomPomListItem
			--- @return string
			display = function(item)
				return (item.done and DEFAULT_DONE_PREFIX or DEFAULT_NOT_DONE_PREFIX) .. (item.value or "")
			end,

			--- @param a PomPomListItem
			--- @param b PomPomListItem
			--- @return boolean
			equals = function(a,b)
				return a.value == b.value
			end,

			--- @param config PomPomParitalConfigItem
			--- @param item? string
			create_list_item = function(config, item)
				Logger:log("creating list item",item)
				local sub1 = "^" .. DEFAULT_DONE_PREFIX_ESCAPED
				local sub2 = "^" .. DEFAULT_NOT_DONE_PREFIX_ESCAPED
				Logger:log("subbing",sub1,", ",sub2)
				local list_item = item and {
					value = item:gsub(sub1,""):gsub(sub2,""),
					done = item:sub(1,DEFAULT_DONE_PREFIX:len()) == DEFAULT_DONE_PREFIX }
				or {
					value = "",
					done = false,
				}
				return list_item
			end,

			--- @return string
			get_root_dir = function()
				return stdpath('cache') .. "/pompom"
			end
		},
	}
end

return M
