-- ~/.config/nvim/lua/keymaps/lsp.lua
local map = vim.keymap.set

local hover_win = nil

local function close_hover()
	if hover_win and vim.api.nvim_win_is_valid(hover_win) then
		vim.api.nvim_win_close(hover_win, true)
	end
	hover_win = nil
end

local function safe_hover()
	close_hover()

	local params = vim.lsp.util.make_position_params(0, "utf-8")

	vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result, _, _)
		if err or not result or not result.contents then
			vim.notify("No hover information available", vim.log.levels.INFO, { title = "LSP Hover" })
			return
		end

		local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
		lines = vim.tbl_filter(function(line)
			return line and line ~= ""
		end, lines)

		if vim.tbl_isempty(lines) then
			vim.notify("No hover information available", vim.log.levels.INFO, { title = "LSP Hover" })
			return
		end

		local buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = "wipe"
		vim.bo[buf].swapfile = false
		vim.bo[buf].filetype = ""
		vim.bo[buf].syntax = "OFF"

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

		local width = 0
		for _, line in ipairs(lines) do
			width = math.max(width, vim.fn.strdisplaywidth(line))
		end
		width = math.min(math.max(width + 2, 20), 80)

		local height = math.min(#lines, 20)

		hover_win = vim.api.nvim_open_win(buf, false, {
			relative = "cursor",
			row = 1,
			col = 0,
			width = width,
			height = height,
			style = "minimal",
			border = "rounded",
			focusable = false,
		})

		vim.api.nvim_create_autocmd({
			"CursorMoved",
			"CursorMovedI",
			"InsertEnter",
			"BufLeave",
		}, {
			once = true,
			callback = close_hover,
		})
	end)
end

-- LSP hover
map("n", "<leader>lh", safe_hover, { desc = "LSP: Hover" })

-- LSP core
map("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP: Definition" })
map("n", "<leader>lD", vim.lsp.buf.declaration, { desc = "LSP: Declaration" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP: Rename" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP: Code action" })
map("n", "<leader>lf", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "LSP: Format" })

-- Diagnostics
map("n", "<leader>le", vim.diagnostic.open_float, { desc = "Diag: Line diagnostics" })
map("n", "<leader>l[", vim.diagnostic.goto_prev, { desc = "Diag: Prev" })
map("n", "<leader>l]", vim.diagnostic.goto_next, { desc = "Diag: Next" })
