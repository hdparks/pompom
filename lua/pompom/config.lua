--- @class PomPomConfig
--- @field task_config PomPomTaskConfig
--- @field ui_config PomPomUiConfig


--- @class PomPomTaskConfig
--- @field done_prefix string
--- @field not_done_prefix string

local DEFAULT_NOT_DONE_PREFIX = "- [ ] "
local DEFAULT_DONE_PREFIX = "- [x] "

--- @class PomPomUiConfig
--- @field fallback_width integer
--- @field width_ratio integer
--- @field width_max integer
--- @field height integer
--- @field title string
--- @field title_pos string
--- @field border string

local DEFAULT_FALLBACK_WIDTH = 60
local DEFAULT_WIDTH_RATIO = 1 / 1.618 -- golden ratio
local DEFAULT_WIDTH_MAX = 120
local DEFAULT_HEIGHT = 10
local DEFAULT_TITLE = "PomPom"
local DEFAULT_TITLE_POS = "left"
local DEFAULT_BORDER = "single"

local PomPomConfig = {}
PomPomConfig.__index = PomPomConfig

--- @return PomPomConfig
function PomPomConfig:default()
	return setmetatable({
		task_config = {
			done_prefix = DEFAULT_DONE_PREFIX,
			not_done_prefix = DEFAULT_NOT_DONE_PREFIX
		},
		ui_config = {
			fallback_width = DEFAULT_FALLBACK_WIDTH,
			width_ratio = DEFAULT_WIDTH_RATIO,
			width_max = DEFAULT_WIDTH_MAX,
			height = DEFAULT_HEIGHT,
			title = DEFAULT_TITLE,
			title_pos = DEFAULT_TITLE_POS,
			border = DEFAULT_BORDER
		}
	}, self)
end

return PomPomConfig
