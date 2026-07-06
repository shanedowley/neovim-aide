local M = {}

local config = {
	model = "gpt-5.4-mini",
	-- --------------------------------------------------
	-- Test / Fault Injection
	-- --------------------------------------------------
	-- model = "no-model", -- force healthcheck failure

	cli = {
		executable = "codex",
		skip_git_repo_check = true, -- allow Codex operation outside Git repos
	},

	health = {
		min_cli_version = "0.120.0",
		model_probe_enabled = true,
	},

	workflow = {
		default_mode = "fast",

		model_profiles = {
			fast = "gpt-5.4-mini",
			balanced = "gpt-5.4-mini",
			strict = "gpt-5.4-mini",
			refactor = "gpt-5.4-mini",
		},
	},
}

function M.get()
	return config
end

return M
