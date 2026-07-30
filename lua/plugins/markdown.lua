-- ~/.config/nvim/lua/plugins/markdown.lua
return {
	{
		"iamcco/markdown-preview.nvim",
		ft = { "markdown" },
		cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },

		build = function(plugin)
			local yarn = "yarn"

			if vim.fn.executable("yarn") ~= 1 then
				if vim.fn.executable("npx") ~= 1 then
					error("markdown-preview.nvim requires npm/npx when yarn is not installed")
				end

				yarn = "npx --yes yarn"
			end

			local app_dir = plugin.dir .. "/app"
			local cmd = "cd " .. vim.fn.shellescape(app_dir) .. " && " .. yarn .. " install --frozen-lockfile"
			local output = vim.fn.system(cmd)

			if vim.v.shell_error ~= 0 then
				error(output)
			end
		end,

		init = function()
			vim.g.mkdp_browser = "safari"
			vim.g.mkdp_auto_close = 1
			vim.g.mkdp_refresh_slow = 0
		end,

		keys = {
			{
				"<leader>Mp",
				"<cmd>MarkdownPreviewToggle<CR>",
				desc = "Toggle Markdown Preview",
			},
			{
				"<leader>Ms",
				"<cmd>MarkdownPreviewStop<CR>",
				desc = "Stop Markdown Preview",
			},
		},
	},
}
