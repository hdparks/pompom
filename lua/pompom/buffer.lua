local PomPomGroup = require("pompom.autocmd")
local Logger = require("pompom.logger")
local utils = require("pompom.utils")

local PomPomBuffer = {}
local POMPOM_MENU = "__pompom-menu__"


local function get_pompom_menu_name()
	return POMPOM_MENU
end

--- @param key string
function PomPomBuffer.run_toggle_command(key)
	require('pompom').ui:toggle_quick_menu()
end

function PomPomBuffer.setup_autocmds_and_keymaps(bufnr)
	local curr_file = vim.api.nvim_buf_get_name(0)
	local cmd = string.format(
		"autocmd Filetype pompom "
			.. "let path = '%s' | call clearmatches()",
		curr_file:gsub("\\","\\\\")
	)
	vim.cmd(cmd)

	if vim.api.nvim_buf_get_name(bufnr) == "" then
		vim.api.nvim_buf_set_name(bufnr, get_pompom_menu_name())
	end

	vim.api.nvim_set_option_value("filetype","pompom", {
		buf = bufnr
	})
	vim.api.nvim_set_option_value("buftype","acwrite", { buf = bufnr })
	vim.keymap.set("n","q", function() PomPomBuffer:run_toggle_command("q") end, {buffer=bufnr, silent=true})
	vim.keymap.set("n","Esc", function() PomPomBuffer:run_toggle_command("Esc") end, {buffer=bufnr, silent=true})
	-- TODO one to toggle list item done
	-- TODO one to toggle list item active
	vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
		group = PomPomGroup,
		buffer = bufnr,
		callback = function()
			require("pompom").ui:save()
			vim.schedule(function()
				require("pompom").ui:toggle_quick_menu()
			end)
		end
	})
	vim.api.nvim_create_autocmd({ "BufLeave" }, {
		group = PomPomGroup,
		buffer = bufnr,
		callback = function()
			PomPomBuffer:run_toggle_command(":q")
		end
	})
end


--- @param bufnr number
--- @return string[]
function PomPomBuffer.get_contents(bufnr)
	Logger:log("getting contents of bufnr", bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
	local indices = {}

	for _, line in ipairs(lines) do
		if not utils.is_whitespace(line) then
			table.insert(indices, line)
		end
	end
	return indices
end

function PomPomBuffer.set_contents(bufnr, contents)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)
end

return PomPomBuffer
