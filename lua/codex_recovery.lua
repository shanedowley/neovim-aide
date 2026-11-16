local M = {}

local window = require("codex.window")

local failure = require("codex.failure")
local last_failure = nil

local function failure_store_path()
	return vim.fn.stdpath("state") .. "/codex_last_failure.json"
end

local function now_string()
	return os.date("%Y-%m-%d %H:%M:%S")
end

local function copy(tbl)
	return vim.deepcopy(tbl)
end

local function basename(path)
	if not path or path == "" then
		return "-"
	end
	return vim.fn.fnamemodify(path, ":t")
end

local function open_scratch(lines, title, filetype)
	return window.open({
		name = "codex-recovery://last",
		lines = lines,
		filetype = filetype or "markdown",
		close_desc = "Close Codex recovery",
	})
end

local function has_meaningful_lines(lines)
	if type(lines) ~= "table" or #lines == 0 then
		return false
	end

	if #lines == 1 and lines[1] == "No diagnostic output available." then
		return false
	end

	for _, line in ipairs(lines) do
		if tostring(line):match("%S") then
			return true
		end
	end

	return false
end

local function metadata_only_recovery(record)
	return record.recovery_metadata_only == true or record.output_persistence == "metadata_only"
end

local function recovery_metadata(record)
	local metadata = {
		output_persistence = "metadata_only",
		output_available = false,
		kind = failure.kinds.unknown_failure,
	}

	local kind = record.kind
	if type(kind) == "string" and failure.kinds[kind] == kind then
		metadata.kind = kind
	end

	-- Attribution fields must come from application-controlled request metadata.
	for _, key in ipairs({
		"stage",
		"op",
		"mode",
		"file",
		"filetype",
		"request_id",
		"prompt_version",
		"updated_at",
	}) do
		if type(record[key]) == "string" then
			metadata[key] = record[key]
		end
	end

	for _, key in ipairs({ "latency_ms", "exit_code" }) do
		local value = record[key]
		if type(value) == "number" and value == value and value > -math.huge and value < math.huge then
			metadata[key] = value
		end
	end

	-- Never persist a caller-supplied free-text reason.
	metadata.reason = metadata.kind

	return metadata
end

local function suggested_actions_for_failure(f)
	if metadata_only_recovery(f) and f.output_available == false then
		return {
			"Raw diagnostic output was deliberately not persisted.",
			"Check :CodexLog for request timing and status metadata.",
			"Retry the original operation to obtain fresh diagnostics.",
		}
	end

	local kind = failure.normalize(f.kind)
	local actions = {}

	if kind == failure.kinds.healthcheck_not_pass then
		actions = {
			"Run `:CodexHealth`.",
			"Inspect the failing dependency or model configuration.",
			"Retry only after healthcheck returns PASS.",
		}
	elseif kind == failure.kinds.healthcheck_error then
		actions = {
			"Run `:CodexHealth`.",
			"Inspect Neovim health output for runtime errors.",
			"Check Codex CLI availability and configuration.",
		}
	elseif kind == failure.kinds.user_cancelled then
		actions = {
			"No action required.",
			"The operation was cancelled intentionally.",
		}
	elseif kind == failure.kinds.codex_exec_failed then
		actions = {
			"Inspect STDERR for runtime failure details.",
			"Check `:CodexLog` for the matching request ID.",
			"Retry the operation if the environment is healthy.",
		}
	else
		actions = {
			"Run `:CodexHealth`.",
			"Check `:CodexLog` for the matching request ID.",
			"Retry the operation if the environment is healthy.",
			"If this is repeatable, inspect stdout/stderr and the captured output above.",
		}
	end

	return actions
end

local function render_failure_lines(f)
	local lines = {
		"# Codex Recovery Report",
		"",
		"## Summary",
		"",
		"| Field | Value |",
		"|---|---|",
		("| Failure kind | " .. tostring(f.kind or "-") .. " |"),
		("| Stage | " .. tostring(f.stage or "-") .. " |"),
		("| Operation | " .. tostring(f.op or "-") .. " |"),
		("| Request ID | " .. tostring(f.request_id or "-") .. " |"),
		("| Mode | " .. tostring(f.mode or "-") .. " |"),
		("| File | " .. tostring(f.file or "-") .. " |"),
		("| File name | " .. tostring(f.file_name or basename(f.file)) .. " |"),
		("| Filetype | " .. tostring(f.filetype or "-") .. " |"),
		("| Latency ms | " .. tostring(f.latency_ms or "-") .. " |"),
		("| Exit code | " .. tostring(f.exit_code or "-") .. " |"),
		("| Prompt version | " .. tostring(f.prompt_version or "-") .. " |"),
		("| Updated at | " .. tostring(f.updated_at or "-") .. " |"),
		"",
		"## Reason",
		"",
		tostring(f.reason or "-"),
		"",
	}

	if metadata_only_recovery(f) then
		if f.output_available == false then
			lines[#lines + 1] = "Raw diagnostic output was deliberately not persisted."
			lines[#lines + 1] = "Only recovery metadata is available for this restored record."
		else
			lines[#lines + 1] = "Full diagnostic output is available in this session only."
			lines[#lines + 1] = "Only recovery metadata is persisted."
		end
		lines[#lines + 1] = ""
	end

	local stderr = f.stderr or {}
	if has_meaningful_lines(stderr) then
		lines[#lines + 1] = "## STDERR"
		lines[#lines + 1] = ""
		lines[#lines + 1] = "```text"
		for _, line in ipairs(stderr) do
			lines[#lines + 1] = line
		end
		lines[#lines + 1] = "```"
		lines[#lines + 1] = ""
	end

	local stdout = f.stdout or {}
	if has_meaningful_lines(stdout) then
		lines[#lines + 1] = "## STDOUT"
		lines[#lines + 1] = ""
		lines[#lines + 1] = "```text"
		for _, line in ipairs(stdout) do
			lines[#lines + 1] = line
		end
		lines[#lines + 1] = "```"
		lines[#lines + 1] = ""
	end

	local payload = f.lines or {}
	if has_meaningful_lines(payload) then
		lines[#lines + 1] = "## Captured output"
		lines[#lines + 1] = ""
		lines[#lines + 1] = "```text"

		for _, line in ipairs(payload) do
			lines[#lines + 1] = line
		end

		lines[#lines + 1] = "```"
		lines[#lines + 1] = ""
	end
	lines[#lines + 1] = "## Suggested actions"
	lines[#lines + 1] = ""

	for _, action in ipairs(suggested_actions_for_failure(f)) do
		lines[#lines + 1] = "- " .. action
	end
	return lines
end

local function normalize_lines_payload(lines)
	if type(lines) == "table" then
		return lines
	end

	if type(lines) == "string" and lines ~= "" then
		return vim.split(lines, "\n", { plain = true })
	end

	return { "No diagnostic output available." }
end

local function write_last_failure(record)
	local path = failure_store_path()
	local persisted = metadata_only_recovery(record) and recovery_metadata(record) or record
	local json = vim.json.encode(persisted)

	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
	return vim.fn.writefile({ json }, path) == 0
end

local function read_last_failure()
	local path = failure_store_path()

	if vim.fn.filereadable(path) ~= 1 then
		return nil
	end

	local lines = vim.fn.readfile(path)
	local raw = table.concat(lines, "\n")

	if raw == "" then
		return nil
	end

	local ok, decoded = pcall(vim.json.decode, raw)
	if not ok or type(decoded) ~= "table" then
		return nil
	end

	if metadata_only_recovery(decoded) then
		return recovery_metadata(decoded)
	end

	return decoded
end

function M.capture(opts)
	opts = opts or {}

	local protected = metadata_only_recovery(opts)
	local unavailable = protected and opts.output_available == false

	last_failure = {
		kind = failure.normalize(opts.kind),
		stage = opts.stage or "-",
		op = opts.op,
		mode = opts.mode,
		file = opts.file,
		file_name = basename(opts.file),
		filetype = opts.filetype,
		reason = opts.reason or "codex_failure",

		request_id = opts.request_id,
		latency_ms = opts.latency_ms,
		exit_code = opts.exit_code,
		prompt_version = opts.prompt_version,

		stdout = not unavailable and normalize_lines_payload(opts.stdout) or nil,
		stderr = not unavailable and normalize_lines_payload(opts.stderr) or nil,

		title = opts.title or "Codex Failure",
		lines = not unavailable and normalize_lines_payload(opts.lines) or nil,
		updated_at = now_string(),
	}

	if protected then
		last_failure.output_persistence = "metadata_only"
		last_failure.output_available = not unavailable
		last_failure = copy(last_failure)
	end

	local ok, written = pcall(write_last_failure, last_failure)
	if protected and (not ok or written ~= true) then
		vim.notify(
			"Codex recovery metadata could not be saved. The latest record is available in this session only.",
			vim.log.levels.WARN,
			{ title = "Codex" }
		)
	end

	return copy(last_failure)
end

function M.get_last_failure()
	if last_failure then
		return copy(last_failure)
	end

	local persisted = read_last_failure()
	if persisted then
		last_failure = persisted
		return copy(last_failure)
	end

	return nil
end

function M.clear_last_failure()
	last_failure = nil

	local path = failure_store_path()
	if vim.fn.filereadable(path) == 1 then
		pcall(vim.fn.delete, path)
	end
end

function M.render_last_failure_lines()
	local f = M.get_last_failure()

	if not f then
		return {
			"Codex Recovery Report",
			"=====================",
			"",
			"No failure has been captured in this session.",
		}
	end

	return render_failure_lines(f)
end

function M.show_last_failure()
	open_scratch(M.render_last_failure_lines(), "Recovery", "codex")
end

function M.show_failure(opts)
	opts = opts or {}

	local reason = opts.reason or "codex_failure"
	local title = opts.title or "Codex Failure"
	local captured = M.capture(opts)
	local level = failure.is_user_cancelled(captured.kind) and vim.log.levels.INFO or vim.log.levels.ERROR

	vim.notify(reason, level, { title = "Codex" })
	open_scratch(render_failure_lines(captured), title, "codex")
end

function M.can_explain_with_codex(failure_report)
	if not failure_report then
		return false, "No failure has been captured."
	end

	if metadata_only_recovery(failure_report) and failure_report.output_available == false then
		return false,
			"Raw diagnostic output was deliberately not persisted. Retry the original operation for fresh diagnostics."
	end

	local kind = failure.normalize(failure_report.kind)

	if kind == failure.kinds.healthcheck_not_pass or kind == failure.kinds.healthcheck_error then
		return false, "Cannot explain healthcheck failures with Codex. Run :CodexHealth for diagnostics."
	end

	return true, nil
end

return M
