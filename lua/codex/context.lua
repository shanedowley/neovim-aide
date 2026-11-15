local M = {}

local enabled = true

local ROOT_MARKERS = {
	".git",
	"compile_commands.json",
	"Cargo.toml",
	"go.mod",
	"build.zig",
	"package.json",
	"pyproject.toml",
	"Makefile",
	"CMakeLists.txt",
}

function M.enabled()
	return enabled
end

function M.toggle()
	enabled = not enabled
	return enabled
end

local function current_path(bufnr)
	bufnr = bufnr or 0
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return nil
	end
	return vim.fn.fnamemodify(name, ":p")
end

-- Capture privately owned source values without yielding or reading disk text.
-- The caller must retain these values rather than rereading the buffer later.
function M.capture_source(bufnr)
	if bufnr == nil or bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end

	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
		return nil, {
			code = "invalid_buffer",
			message = "Source buffer is no longer available.",
		}
	end

	if vim.bo[bufnr].buftype ~= "" then
		return nil, {
			code = "unsupported_buffer",
			message = "Current buffer cannot be explained.",
		}
	end

	local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
	local captured_at = os.time()
	local name = vim.api.nvim_buf_get_name(bufnr)
	local filetype = vim.bo[bufnr].filetype or ""
	local modified = vim.bo[bufnr].modified
	local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")

	if changedtick ~= vim.api.nvim_buf_get_changedtick(bufnr) then
		return nil,
			{
				code = "inconsistent_capture",
				message = "Source buffer changed during capture. Please retry.",
			}
	end

	if vim.trim(text) == "" then
		return nil, {
			code = "empty_buffer",
			message = "Current buffer is empty.",
		}
	end

	if name == "" then
		return nil,
			{
				code = "unnamed_buffer",
				message = "Save or name the source buffer before project-aware Explain.",
			}
	end

	return {
		bufnr = bufnr,
		path = vim.fn.fnamemodify(name, ":p"),
		filetype = filetype,
		changedtick = changedtick,
		modified = modified,
		text = text,
		captured_at = captured_at,
	}
end

local function parent_dir(path)
	return vim.fn.fnamemodify(path, ":h")
end

local function resolution_error(code, message, details)
	return nil, {
		code = code,
		message = message,
		details = details,
	}
end

local function single_output_line(output)
	if type(output) ~= "string" then
		return nil
	end

	local line = output:gsub("\n$", "")
	if line == "" or line:find("[\r\n%z]") then
		return nil
	end

	return line
end

function M.resolve_worktree(source)
	local uv = vim.uv or vim.loop

	if type(source) ~= "table" or type(source.path) ~= "string" or source.path:sub(1, 1) ~= "/" then
		return resolution_error("invalid_source", "Git lookup requires a captured absolute source path.")
	end

	if type(vim.system) ~= "function" then
		return resolution_error("git_unavailable", "Git lookup requires vim.system().")
	end

	local started = uv.hrtime()
	local function elapsed_ms()
		return (uv.hrtime() - started) / 1e6
	end

	local resolved_path
	local entry, entry_error = uv.fs_lstat(source.path)

	if entry then
		resolved_path = uv.fs_realpath(source.path)
		if not resolved_path then
			return resolution_error("unresolved_source", "Cannot resolve the source filesystem target.")
		end

		local target = uv.fs_stat(resolved_path)
		if not target or target.type ~= "file" then
			return resolution_error("invalid_source", "Source filesystem target is not a regular file.")
		end
	else
		if not tostring(entry_error):find("ENOENT", 1, true) then
			return resolution_error("unresolved_source", "Cannot inspect the source filesystem path.", entry_error)
		end

		-- A named new file is supported only when its parent exists.
		local resolved_parent = uv.fs_realpath(parent_dir(source.path))
		local parent_stat = resolved_parent and uv.fs_stat(resolved_parent)

		if not parent_stat or parent_stat.type ~= "directory" then
			return resolution_error("missing_parent", "Source parent directory is missing or inaccessible.")
		end

		local separator = resolved_parent == "/" and "" or "/"
		resolved_path = resolved_parent .. separator .. vim.fn.fnamemodify(source.path, ":t")
	end

	local source_directory = parent_dir(resolved_path)

	-- clear_env prevents removed variables from being inherited again.
	-- This environment belongs only to the Git lookup subprocesses.
	local git_env = {}
	for key, value in pairs(vim.fn.environ()) do
		if not key:match("^GIT_") then
			git_env[key] = value
		end
	end
	git_env.LC_ALL = "C"

	local function query(argument)
		local remaining = math.floor(1000 - elapsed_ms())
		if remaining <= 0 then
			return resolution_error("git_timeout", "Git worktree lookup exceeded its one-second limit.")
		end

		local ok, process = pcall(vim.system, {
			"git",
			"--no-optional-locks",
			"-C",
			source_directory,
			"rev-parse",
			argument,
		}, {
			env = git_env,
			clear_env = true,
		})

		if not ok then
			return resolution_error("git_lookup_failed", "Could not start Git worktree lookup.", tostring(process))
		end

		local waited, result = pcall(function()
			return process:wait(remaining)
		end)

		if not waited then
			-- Request termination without another blocking wait.
			pcall(function()
				process:kill(9)
			end)
			return resolution_error(
				"git_lookup_failed",
				"Could not collect Git worktree lookup results.",
				tostring(result)
			)
		end

		if type(result) ~= "table" or type(result.code) ~= "number" then
			return resolution_error("git_lookup_failed", "Git returned an invalid process result.")
		end

		if result.code == 124 or elapsed_ms() >= 1000 then
			return resolution_error("git_timeout", "Git worktree lookup exceeded its one-second limit.")
		end

		if result.code ~= 0 then
			local stderr = result.stderr or ""
			local code = "git_lookup_failed"
			local message = "Git worktree lookup failed."

			if stderr:find("not a git repository", 1, true) then
				code = "not_git_worktree"
				message = "Source is not inside a Git worktree."
			end

			return resolution_error(code, message, stderr)
		end

		local line = single_output_line(result.stdout)
		if not line then
			return resolution_error("invalid_git_result", "Git returned empty or ambiguous worktree information.")
		end

		return line
	end

	local membership, membership_error = query("--is-inside-work-tree")
	if not membership then
		return nil, membership_error
	end

	if membership == "false" then
		return resolution_error("not_git_worktree", "Source is not inside a Git worktree.")
	end

	if membership ~= "true" then
		return resolution_error("invalid_git_result", "Git returned invalid worktree membership.")
	end

	local root, root_error = query("--show-toplevel")
	if not root then
		return nil, root_error
	end

	if root:sub(1, 1) ~= "/" then
		return resolution_error("invalid_git_result", "Git returned a non-absolute worktree root.")
	end

	local worktree_root = uv.fs_realpath(root)
	local root_stat = worktree_root and uv.fs_stat(worktree_root)
	if not root_stat or root_stat.type ~= "directory" then
		return resolution_error("invalid_git_result", "Git worktree root is missing or inaccessible.")
	end

	local prefix = worktree_root == "/" and "/" or worktree_root .. "/"
	if resolved_path:sub(1, #prefix) ~= prefix then
		return resolution_error("source_outside_worktree", "Resolved source is outside the reported Git worktree.")
	end

	if elapsed_ms() >= 1000 then
		return resolution_error("git_timeout", "Git worktree lookup exceeded its one-second limit.")
	end

	return {
		editor_path = source.path,
		resolved_path = resolved_path,
		worktree_root = worktree_root,
		relative_file = resolved_path:sub(#prefix + 1),
		lookup_ms = elapsed_ms(),
	}
end

local function marker_type(name)
	if name == ".git" then
		return "directory"
	end
	return "file"
end

local function find_root(start_path)
	if not start_path or start_path == "" then
		return nil, {}
	end

	local start_dir = parent_dir(start_path)
	local best_root = nil
	local best_markers = nil

	for _, marker in ipairs(ROOT_MARKERS) do
		local found = vim.fs.find(marker, {
			upward = true,
			path = start_dir,
			limit = 1,
			type = marker_type(marker),
		})

		if found and #found > 0 then
			local root = parent_dir(found[1])

			if not best_root or #root > #best_root then
				best_root = root
				best_markers = { marker }
			elseif root == best_root then
				best_markers = best_markers or {}
				table.insert(best_markers, marker)
			end
		end
	end

	if not best_root then
		return nil, {}
	end

	table.sort(best_markers)
	return best_root, best_markers
end

function M.collect(bufnr)
	bufnr = bufnr or 0

	local path = current_path(bufnr)
	local ft = vim.bo[bufnr].filetype or ""
	local root, markers = find_root(path)

	local rel = nil
	if root and path then
		local prefix = root .. "/"
		if path:sub(1, #prefix) == prefix then
			rel = path:sub(#prefix + 1)
		else
			rel = vim.fn.fnamemodify(path, ":t")
		end
	end

	return {
		enabled = enabled,
		file = path,
		filetype = ft,
		project_root = root,
		relative_file = rel,
		markers = markers or {},
	}
end

function M.render_block(bufnr)
	if not enabled then
		return ""
	end

	local info = M.collect(bufnr)

	local lines = {
		"READ-ONLY PROJECT CONTEXT (metadata only):",
		"- project_root: " .. tostring(info.project_root or "unknown"),
		"- file: " .. tostring(info.relative_file or info.file or "unknown"),
		"- filetype: " .. tostring(info.filetype or "unknown"),
	}

	if info.markers and #info.markers > 0 then
		lines[#lines + 1] = "- markers: " .. table.concat(info.markers, ", ")
	else
		lines[#lines + 1] = "- markers: none"
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "CONTEXT USAGE RULES:"
	lines[#lines + 1] = "- Use this only as background orientation."
	lines[#lines + 1] = "- Do NOT mention this context in your answer."
	lines[#lines + 1] = "- Do NOT inspect files, run commands, or describe tool usage."
	lines[#lines + 1] = "- Do NOT ask to open or search the project."
	lines[#lines + 1] = "- Still obey all output rules exactly."

	return table.concat(lines, "\n")
end

return M
