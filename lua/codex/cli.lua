local M = {}

local config = require("codex.config").get()

local mode = require("codex_mode")

local function resolve_model()
	local workflow = config.workflow or {}
	local profiles = workflow.model_profiles or {}

	local current_mode = mode.current()
	local model = profiles[current_mode]

	if type(model) == "string" and model ~= "" then
		return model
	end

	return config.model
end

function M.build_exec_argv(prompt_text)
	local argv = {
		config.cli.executable,
		"exec",
		"--model",
		resolve_model(),
	}

	if config.cli.skip_git_repo_check then
		table.insert(argv, "--skip-git-repo-check")
	end

	table.insert(argv, prompt_text)

	return argv
end

return M
