local M = {}

local SUPPORTED_FILETYPES = {
	c = true,
	cpp = true,
	objc = true,
	objcpp = true,
}

local FUNCTION_TYPES = {
	function_definition = true,
	method_definition = true,
}

local CLASS_FILETYPES = {
	cpp = true,
	objcpp = true,
}

local CLASS_TYPES = {
	class_specifier = true,
	struct_specifier = true,
}

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, {
		title = "Navigation",
	})
end

local function current_buffer_supported()
	local filetype = vim.bo.filetype or ""

	if not SUPPORTED_FILETYPES[filetype] then
		notify("Function navigation is currently supported for C and C++ buffers", vim.log.levels.WARN)
		return false
	end

	return true
end

local function current_buffer_supports_classes()
	local filetype = vim.bo.filetype or ""

	if not CLASS_FILETYPES[filetype] then
		notify("Class selection is currently supported for C++ buffers", vim.log.levels.WARN)
		return false
	end

	return true
end

local function get_root()
	if not current_buffer_supported() then
		return nil
	end

	if not vim.treesitter or not vim.treesitter.get_parser then
		notify("Treesitter is not available", vim.log.levels.WARN)
		return nil
	end

	local ok_parser, parser = pcall(vim.treesitter.get_parser, 0)
	if not ok_parser or not parser then
		notify("No Treesitter parser is available for this buffer", vim.log.levels.WARN)
		return nil
	end

	local ok_parse, trees = pcall(parser.parse, parser)
	if not ok_parse or not trees or not trees[1] then
		notify("Unable to parse the current buffer", vim.log.levels.WARN)
		return nil
	end

	return trees[1]:root()
end

local function node_start_position(node)
	local row, col = node:start()
	return row, col
end

local function node_end_position(node)
	local start_row, _, end_row, end_col = node:range()

	if end_col == 0 and end_row > start_row then
		local target_row = end_row - 1
		local lines = vim.api.nvim_buf_get_lines(0, target_row, target_row + 1, false)
		local line = lines[1] or ""

		return target_row, math.max(#line - 1, 0)
	end

	return end_row, math.max(end_col - 1, 0)
end

local function collect_function_nodes(root)
	local nodes = {}

	local function visit(node)
		if FUNCTION_TYPES[node:type()] then
			table.insert(nodes, node)
		end

		for child in node:iter_children() do
			visit(child)
		end
	end

	visit(root)

	table.sort(nodes, function(left, right)
		local left_row, left_col = node_start_position(left)
		local right_row, right_col = node_start_position(right)

		if left_row == right_row then
			return left_col < right_col
		end

		return left_row < right_row
	end)

	return nodes
end

local function cursor_position()
	local cursor = vim.api.nvim_win_get_cursor(0)
	return cursor[1] - 1, cursor[2]
end

local function position_before(left_row, left_col, right_row, right_col)
	return left_row < right_row or (left_row == right_row and left_col < right_col)
end

local function position_after(left_row, left_col, right_row, right_col)
	return left_row > right_row or (left_row == right_row and left_col > right_col)
end

local function enclosing_function(root)
	local row, col = cursor_position()
	local node = root:named_descendant_for_range(row, col, row, col)

	while node do
		if FUNCTION_TYPES[node:type()] then
			return node
		end

		node = node:parent()
	end

	return nil
end

local function enclosing_class(root)
	local row, col = cursor_position()
	local node = root:named_descendant_for_range(row, col, row, col)

	while node do
		if CLASS_TYPES[node:type()] then
			return node
		end

		node = node:parent()
	end

	return nil
end

local function move_to(row, col)
	vim.api.nvim_win_set_cursor(0, { row + 1, col })
end

local function current_function_node()
	local root = get_root()
	if not root then
		return nil
	end

	local node = enclosing_function(root)

	if not node then
		notify("Cursor is not inside a function", vim.log.levels.INFO)
		return nil
	end

	return node
end

function M.current_function_text()
	local node = current_function_node()
	if not node then
		return nil
	end

	return vim.treesitter.get_node_text(node, 0)
end

function M.goto_previous_function()
	local root = get_root()
	if not root then
		return
	end

	local row, col = cursor_position()
	local previous = nil

	for _, node in ipairs(collect_function_nodes(root)) do
		local node_row, node_col = node_start_position(node)

		if position_before(node_row, node_col, row, col) then
			previous = node
		else
			break
		end
	end

	if not previous then
		notify("No previous function", vim.log.levels.INFO)
		return
	end

	move_to(node_start_position(previous))
end

function M.goto_next_function()
	local root = get_root()
	if not root then
		return
	end

	local row, col = cursor_position()

	for _, node in ipairs(collect_function_nodes(root)) do
		local node_row, node_col = node_start_position(node)

		if position_after(node_row, node_col, row, col) then
			move_to(node_row, node_col)
			return
		end
	end

	notify("No next function", vim.log.levels.INFO)
end

function M.goto_function_start()
	local node = current_function_node()
	if not node then
		return
	end

	move_to(node_start_position(node))
end

function M.goto_function_end()
	local node = current_function_node()
	if not node then
		return
	end

	move_to(node_end_position(node))
end

function M.select_current_function()
	local node = current_function_node()
	if not node then
		return
	end

	local start_row, start_col = node_start_position(node)
	local end_row, end_col = node_end_position(node)

	move_to(start_row, start_col)
	vim.cmd("normal! v")
	move_to(end_row, end_col)
end

function M.select_current_class()
	if not current_buffer_supports_classes() then
		return
	end

	local root = get_root()
	if not root then
		return
	end

	local node = enclosing_class(root)

	if not node then
		notify("Cursor is not inside a class or struct", vim.log.levels.INFO)
		return
	end

	local start_row, start_col = node_start_position(node)
	local end_row, end_col = node_end_position(node)

	move_to(start_row, start_col)
	vim.cmd("normal! v")
	move_to(end_row, end_col)
end

return M
