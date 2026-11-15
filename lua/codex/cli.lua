local M = {}

local config = require("codex.config").get()

local mode = require("codex_mode")

local function resolve_model(request_mode)
	local workflow = config.workflow or {}
	local profiles = workflow.model_profiles or {}

	local selected_mode = request_mode
	if selected_mode == nil then
		selected_mode = mode.current()
	end

	local model = profiles[selected_mode]

	if type(model) == "string" and model ~= "" then
		return model
	end

	return config.model
end

function M.build_exec_argv(prompt_text, request_mode)
	local argv = {
		config.cli.executable,
		"exec",
		"--model",
		resolve_model(request_mode),
	}

	if config.cli.skip_git_repo_check then
		table.insert(argv, "--skip-git-repo-check")
	end

	table.insert(argv, prompt_text)

	return argv
end

return M
