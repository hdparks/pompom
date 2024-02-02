local PomPomGroup = require("pompom.autocmd")
local Logger = require("pompom.logger")
local Task = require("pompom.task")
local utils = require("pompom.utils")

local PomPomBuffer = {}
local POMPOM_MENU = "__pompom-menu__"


local function get_pompom_menu_name()
	return POMPOM_MENU
end


--- @param bufnr number
--- @param ui PomPomUI
function PomPomBuffer.setup_autocmds_and_keymaps(bufnr, ui)
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
	vim.keymap.set("n","q", function() ui:close_menu() end, {buffer=bufnr, silent=true})
	vim.keymap.set("n","Esc", function() ui:close_menu() end, {buffer=bufnr, silent=true})
	-- TODO maybe this belongs in a separate config step somewhere else? At least it should if this ever gets shared
	vim.keymap.set("n","<leader>d", function() PomPomBuffer.toggle_task_status(bufnr) end, {buffer=bufnr, silent=true} )
	vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
		group = PomPomGroup,
		buffer = bufnr,
		callback = function()
			require("pompom").ui:save_contents()
			vim.schedule(function()
				ui:close_menu()
			end)
		end
	})
	vim.api.nvim_create_autocmd({ "BufLeave" }, {
		group = PomPomGroup,
		buffer = bufnr,
		callback = function()
			ui:close_menu()
		end
	})
end

--- @param bufnr number
function PomPomBuffer.toggle_task_status(bufnr)
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1 -- now it's zero-based line index
	Logger:log("getting toggle_line_args", bufnr, row, row + 1)
	local line = unpack(vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false))

	local item = Task.decode(line)
	item.done = not item.done
	vim.api.nvim_buf_set_lines(bufnr, row, row+1, false, {item:display()})
end


--- @param bufnr number
--- @return string[]
function PomPomBuffer.get_contents(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
	local valid_lines = {}

	for _, line in ipairs(lines) do
		if not utils.is_whitespace(line) then
			table.insert(valid_lines, line)
		end
	end
	return valid_lines
end

function PomPomBuffer.set_contents(bufnr, contents)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)
end

return PomPomBuffer
