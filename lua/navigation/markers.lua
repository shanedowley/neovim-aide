local M = {}

local MARKER_PATTERN = [[\C\<\(TODO\|FIXME\|BUG\|HACK\|NOTE\|XXX\)\>]]

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, {
		title = "Navigation",
	})
end

local function current_buffer_searchable()
	if vim.bo.buftype ~= "" then
		notify("Code marker navigation is unavailable in this buffer", vim.log.levels.WARN)
		return false
	end

	return true
end

local function search(flags, not_found_message)
	if not current_buffer_searchable() then
		return
	end

	local original = vim.api.nvim_win_get_cursor(0)
	local found = vim.fn.search(MARKER_PATTERN, flags)

	if found == 0 then
		vim.api.nvim_win_set_cursor(0, original)
		notify(not_found_message, vim.log.levels.INFO)
	end
end

function M.goto_next_marker()
	search("W", "No next code marker")
end

function M.goto_previous_marker()
	search("bW", "No previous code marker")
end

return M
