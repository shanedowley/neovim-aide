local navigation = require("navigation.functions")

vim.keymap.set("n", "<leader>nk", navigation.goto_previous_function, {
	desc = "Previous function",
	silent = true,
})

vim.keymap.set("n", "<leader>nj", navigation.goto_next_function, {
	desc = "Next function",
	silent = true,
})

vim.keymap.set("n", "<leader>nh", navigation.goto_function_start, {
	desc = "Function start",
	silent = true,
})

vim.keymap.set("n", "<leader>nl", navigation.goto_function_end, {
	desc = "Function end",
	silent = true,
})
