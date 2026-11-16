-- ~/.config/nvim/lua/codex_cli.lua
local M = {} -- module table

-- Latest submitted current-buffer Explain inputs; session-local, never persisted.
local latest_explain_request = nil

local parse = require("codex_parse")
local prompt = require("codex_prompt")
local mode = require("codex_mode")
local navigation = require("navigation.functions")
local codex_log = require("codex_log")
local recovery = require("codex_recovery")
local guard = require("codex_guard")
local memory = require("codex_memory")
local selection = require("codex.selection")
local ts = require("codex.treesitter")
local clang = require("codex.clang")
local runner = require("codex.runner")
local preview = require("codex.preview")
local state = require("codex.state")
local ui = require("codex.ui")

-- -------------------------------------------------------------------
-- Generic helpers
-- -------------------------------------------------------------------

local function current_file(bufnr)
	bufnr = bufnr or 0
	return vim.api.nvim_buf_get_name(bufnr)
end

local function set_state_running(op_name, bufnr, message)
	state.set("running", {
		op = op_name,
		mode = mode.current(),
		file = current_file(bufnr),
		message = message or "Running Codex request",
	})
end

local function set_state_preview(op_name, bufnr, message)
	state.set("preview", {
		op = op_name,
		mode = mode.current(),
		file = current_file(bufnr),
		message = message or "Preview ready",
	})
end

local function set_state_validating(op_name, bufnr, message)
	state.set("validating", {
		op = op_name,
		mode = mode.current(),
		file = current_file(bufnr),
		message = message or "Validating candidate with clang",
	})
end

local function set_state_applied(op_name, bufnr, message)
	state.set("applied", {
		op = op_name,
		mode = mode.current(),
		file = current_file(bufnr),
		message = message or "Changes applied successfully",
	})
end

local function set_state_failed(op_name, bufnr, message, captured_metadata)
	local file
	local current_mode

	if captured_metadata then
		file = captured_metadata.file
		current_mode = captured_metadata.mode
	else
		file = current_file(bufnr)
		current_mode = mode.current()
	end

	state.set("failed", {
		op = op_name,
		mode = current_mode,
		file = file,
		message = message or "Codex operation failed",
	})
end

local function set_state_complete(op_name, bufnr, message, captured_metadata)
	local file
	local current_mode

	if captured_metadata then
		file = captured_metadata.file
		current_mode = captured_metadata.mode
	else
		file = current_file(bufnr)
		current_mode = mode.current()
	end

	state.set("complete", {
		op = op_name,
		mode = current_mode,
		file = file,
		message = message or "Codex operation complete",
	})
end

local function log_workflow_end(op_name, bufnr, result, stage, message)
	codex_log.write("workflow_end", {
		op = op_name,
		mode = mode.current(),
		file = current_file(bufnr or 0),
		stage = stage or "-",
		result = result or "-",
		message = message or "",
	})
end

local function system_run(argv)
	if not vim.system then
		return { code = 127, stdout = "", stderr = "vim.system not available", signal = nil }
	end

	local res = vim.system(argv, { text = true }):wait()
	return {
		code = res.code or 1,
		stdout = res.stdout or "",
		stderr = res.stderr or "",
		signal = res.signal,
	}
end

local function split_nonempty_lines(s)
	local out = {}
	for line in (s or ""):gmatch("([^\n]*)\n?") do
		if line ~= "" then
			table.insert(out, line)
		end
	end
	return out
end

local function open_scratch(lines, _, title)
	title = title or "Codex Output"

	local bufname = "codex://" .. title
	local bufnr = vim.fn.bufnr(bufname)

	if bufnr == -1 then
		vim.cmd("botright new")
		bufnr = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_name(bufnr, bufname)
	else
		vim.cmd("botright sbuffer " .. bufnr)
	end

	pcall(vim.treesitter.stop, bufnr)

	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].filetype = ""
	vim.bo[bufnr].syntax = "OFF"
	vim.wo.conceallevel = 0

	vim.bo[bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines or {})
	vim.bo[bufnr].modifiable = false

	local function close()
		pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
	end

	vim.keymap.set("n", "q", close, {
		buffer = bufnr,
		nowait = true,
		silent = true,
		desc = "Close Codex scratch buffer",
	})

	vim.keymap.set("n", "<Esc>", close, {
		buffer = bufnr,
		nowait = true,
		silent = true,
		desc = "Close Codex scratch buffer",
	})

	return bufnr
end

local function prompt_user(opts, cb)
	vim.ui.input({ prompt = opts.prompt, default = opts.default }, function(answer)
		if answer and answer ~= "" then
			cb(answer)
		end
	end)
end

local function sanitize_prompt_for_log(text)
	text = tostring(text or "")
	text = text:gsub("\n", " ")
	text = text:gsub("%s+", " ")
	text = vim.trim(text)

	if #text > 500 then
		text = text:sub(1, 500) .. "..."
	end

	return text
end

local function remember_and_log_op(op_name, user_prompt, captured_metadata)
	local file
	local current_mode
	local prompt_version

	if captured_metadata then
		file = captured_metadata.file
		current_mode = captured_metadata.mode
		prompt_version = captured_metadata.prompt_version
	else
		file = current_file(0)
		current_mode = mode.current()
		prompt_version = prompt.version and prompt.version() or "unknown"
	end

	local cleaned_prompt = sanitize_prompt_for_log(user_prompt)

	memory.save_last_op({
		op = op_name,
		prompt = user_prompt,
		mode = current_mode,
		prompt_version = prompt_version,
		timestamp = os.time(),
	})

	-- Do not set operational Running here.
	-- Story 8: runtime healthcheck must be visible before Codex execution.
	-- Runner owns the transition to Running after health passes.
	-- set_state_running(op_name, 0, "Running Codex request")

	codex_log.write("prompt", {
		mode = current_mode,
		file = file,
		prompt_version = prompt_version,
		op = op_name,
		text = cleaned_prompt,
	})
end

local function write_tempfile(lines, suffix)
	local path = vim.fn.tempname() .. (suffix or "")
	vim.fn.writefile(lines or {}, path)
	return path
end

local function build_local_unified_diff(original_lines, candidate_lines, ft)
	local suffix = ".txt"
	ft = ft or ""

	if ft == "c" then
		suffix = ".c"
	elseif ft == "cpp" or ft == "cxx" or ft == "cc" or ft == "objc" or ft == "objcpp" then
		suffix = ".cpp"
	end

	local old_path = write_tempfile(original_lines or {}, suffix)
	local new_path = write_tempfile(candidate_lines or {}, suffix)

	if vim.fn.executable("diff") ~= 1 then
		return nil, { "Local diff preview unavailable: `diff` not found in PATH." }
	end

	local res = system_run({ "diff", "-u", old_path, new_path })

	if res.code ~= 0 and res.code ~= 1 then
		local err = split_nonempty_lines(res.stderr)
		if #err == 0 then
			err = split_nonempty_lines(res.stdout)
		end
		if #err == 0 then
			err = { "Failed to build local unified diff." }
		end
		return nil, err
	end

	local diff_lines = split_nonempty_lines(res.stdout)

	if res.code == 0 or #diff_lines == 0 then
		return {}, nil
	end

	return diff_lines, nil
end

-- -------------------------------------------------------------------
-- Validation helpers
-- -------------------------------------------------------------------

local function validate_apply_body(raw, body, want_lines, title_prefix, op_name)
	title_prefix = title_prefix or "Apply"

	if #body == 0 then
		codex_log.write("fail", {
			op = op_name,
			mode = mode.current(),
			file = current_file(0),
			stage = "validate",
			reason = "apply_block_missing",
		})

		set_state_failed(op_name, 0, title_prefix .. ": no marked replacement block found")

		recovery.show_failure({
			kind = "apply_block_missing",
			stage = "validate",
			op = op_name,
			mode = mode.current(),
			file = current_file(0),
			reason = title_prefix .. ": no marked replacement block found",
			title = "Codex " .. title_prefix .. " (unparsed)",
			lines = raw,
		})
		return nil
	end

	if #body == 1 and vim.trim(body[1]) == "ERROR" then
		codex_log.write("fail", {
			op = op_name,
			mode = mode.current(),
			file = current_file(0),
			stage = "validate",
			reason = "codex_returned_error",
		})

		set_state_failed(op_name, 0, title_prefix .. ": Codex returned ERROR")

		recovery.show_failure({
			kind = "codex_returned_error",
			stage = "validate",
			op = op_name,
			mode = mode.current(),
			file = current_file(0),
			reason = title_prefix .. ": Codex returned ERROR",
			title = "Codex " .. title_prefix .. " (ERROR)",
			lines = raw,
		})
		return nil
	end

	if want_lines and #body ~= want_lines then
		codex_log.write("fail", {
			op = op_name,
			mode = mode.current(),
			file = current_file(0),
			stage = "validate",
			reason = "wrong_line_count",
			got_lines = #body,
			want_lines = want_lines,
		})

		set_state_failed(
			op_name,
			0,
			string.format("%s: wrong line count (got %d, want %d)", title_prefix, #body, want_lines)
		)

		recovery.show_failure({
			kind = "wrong_line_count",
			stage = "validate",
			op = op_name,
			mode = mode.current(),
			file = current_file(0),
			reason = string.format("%s: wrong line count (got %d, want %d)", title_prefix, #body, want_lines),
			title = "Codex " .. title_prefix .. " (wrong line count)",
			lines = raw,
		})
		return nil
	end

	return body
end

local function validate_rewrite_common(original_text, body, want_lines, opts)
	opts = opts or {}
	local op_name = opts.op_name

	if parse.looks_like_chatty_output(body) then
		codex_log.write("fail", {
			op = op_name,
			mode = mode.current(),
			file = current_file(0),
			stage = "validate",
			reason = "rule_break_output",
		})

		set_state_failed(op_name, 0, "Codex violated output rules")

		recovery.show_failure({
			kind = "rule_break_output",
			stage = "validate",
			op = op_name,
			mode = mode.current(),
			file = current_file(0),
			reason = "Codex violated output rules",
			title = "Codex Output (rule break)",
			lines = body,
		})
		return nil
	end

	body = selection.trim_blank_edges(body)

	local bad, why = guard.too_large_rewrite(body, want_lines)
	if bad then
		codex_log.write("fail", {
			op = op_name,
			mode = mode.current(),
			file = current_file(0),
			stage = "validate",
			reason = why or "invalid_rewrite",
		})

		set_state_failed(op_name, 0, "Codex output rejected: " .. (why or "invalid"))

		recovery.show_failure({
			kind = why or "invalid_rewrite",
			stage = "validate",
			op = op_name,
			mode = mode.current(),
			file = current_file(0),
			reason = "Codex output rejected: " .. (why or "invalid"),
			title = "Codex Output (rejected)",
			lines = body,
		})
		return nil
	end

	if opts.check_preprocessor then
		local bad_pp, why_pp = guard.rejects_preprocessor_injection(body)
		if bad_pp then
			codex_log.write("fail", {
				op = op_name,
				mode = mode.current(),
				file = current_file(0),
				stage = "validate",
				reason = "preprocessor_injection_rejected",
			})

			set_state_failed(op_name, 0, "Codex output rejected by preprocessor guard")

			recovery.show_failure({
				kind = "preprocessor_injection_rejected",
				stage = "validate",
				op = op_name,
				mode = mode.current(),
				file = current_file(0),
				reason = "Codex output rejected by preprocessor guard",
				title = "Codex Output (guard rejected)",
				lines = why_pp,
			})
			return nil
		end
	end

	if opts.check_refactor and mode.current() == "refactor" then
		local bad2, why_lines = guard.violates_refactor_single_function(original_text, body)
		if bad2 then
			codex_log.write("fail", {
				op = op_name,
				mode = mode.current(),
				file = current_file(0),
				stage = "validate",
				reason = "refactor_guard_rejected",
			})

			set_state_failed(op_name, 0, "Codex output rejected by refactor guard")

			recovery.show_failure({
				kind = "refactor_guard_rejected",
				stage = "validate",
				op = op_name,
				mode = mode.current(),
				file = current_file(0),
				reason = "Codex output rejected by refactor guard",
				title = "Codex Output (rejected)",
				lines = why_lines,
			})
			return nil
		end
	end

	return body
end

local function clang_validate_or_reject(bufnr, ft, start_line, end_line, body, user_prompt, title, op_name)
	if not clang.is_cc_ft(ft) then
		return true
	end

	set_state_validating(op_name, bufnr, "Validating candidate with clang")

	local ok, clang_lines, tmppath, meta = clang.preflight_range_replace(bufnr, ft, start_line, end_line, body)

	codex_log.write("validate", {
		op = op_name,
		mode = mode.current(),
		file = current_file(bufnr),
		stage = "validate",
		result = ok and "PASS" or "FAIL",
		check = "clang",
	})

	codex_log.write("latency", {
		op = op_name,
		mode = mode.current(),
		file = current_file(bufnr),
		stage = "validate",
		elapsed_ms = meta.elapsed_ms or -1,
		result = ok and "PASS" or "FAIL",
	})

	if ok then
		return true
	end

	codex_log.write("fail", {
		op = op_name,
		mode = mode.current(),
		file = current_file(bufnr),
		stage = "validate",
		reason = "clang_rejected",
	})

	set_state_failed(op_name, bufnr, "clang validation rejected candidate")

	recovery.show_failure({
		kind = "clang_rejected",
		stage = "validate",
		op = op_name,
		mode = mode.current(),
		file = current_file(bufnr),
		reason = "clang validation rejected candidate",
		title = title or "Codex Rejected (clang)",
		lines = clang_lines or { "No clang diagnostic output available." },
	})

	vim.notify("clang rejected rewrite; not applied", vim.log.levels.ERROR, { title = "Codex" })
	return false
end

local function apply_lines_and_log(bufnr, start_line, end_line, body, op_name)
	vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, body)

	codex_log.write("apply", {
		op = op_name,
		mode = mode.current(),
		file = current_file(bufnr),
		stage = "write",
		result = "PASS",
		range = string.format("%d-%d", start_line, end_line),
	})

	set_state_applied(op_name, bufnr, "Changes applied successfully")
	log_workflow_end(op_name, bufnr, "PASS", "write", "Changes applied successfully")
end

-- -------------------------------------------------------------------
-- Safe preview flow helper
-- -------------------------------------------------------------------

local function safe_preview_flow(opts)
	local ui = require("codex.ui")
	local target_bufnr = opts.target_bufnr or vim.api.nvim_get_current_buf()
	local ft = opts.ft or (vim.bo[target_bufnr].filetype or "")
	local original_lines = opts.original_lines or {}
	local original_text = opts.original_text or table.concat(original_lines, "\n")
	local want_lines = opts.want_lines
	local prompt_label = opts.prompt_label or "instruction"
	local op_name = opts.op_name
	local preview_title = opts.preview_title or "Codex Safe Diff Preview"
	local clang_title = opts.clang_title or "Codex Rejected (clang)"
	local raw_title_prefix = opts.raw_title_prefix or "Apply"

	prompt_user({ prompt = "Codex [" .. mode.current() .. "] " .. prompt_label .. ": " }, function(user_prompt)
		remember_and_log_op(op_name, user_prompt)

		local p = prompt.build_apply(user_prompt, original_text)

		runner.run({
			op = op_name,
			filetype = ft,
			prompt = p,
			spinner_message = ui.phase_message(op_name, "running"),

			on_success = function(result)
				local raw = parse.normalize_lines(result.output)

				local body = parse.parse_apply_body(raw)
				body = selection.collapse_if_doubled(body, want_lines)
				body = validate_apply_body(raw, body, nil, raw_title_prefix, op_name)
				if not body then
					return
				end

				body = validate_rewrite_common(original_text, body, want_lines or #original_lines, {
					op_name = op_name,
					check_preprocessor = false,
					check_refactor = opts.check_refactor,
				})
				if not body then
					return
				end

				local diff_lines, diff_err = build_local_unified_diff(original_lines, body, ft)
				if not diff_lines then
					codex_log.write("fail", {
						op = op_name,
						mode = mode.current(),
						file = current_file(target_bufnr),
						stage = "preview",
						reason = "diff_preview_failed",
					})

					set_state_failed(op_name, target_bufnr, "Failed to build diff preview")

					recovery.show_failure({
						kind = "diff_preview_failed",
						stage = "preview",
						op = op_name,
						mode = mode.current(),
						file = current_file(target_bufnr),
						reason = "Failed to build local diff preview",
						title = "Codex Diff Preview (error)",
						lines = diff_err or { "Failed to build diff preview." },
					})
					return
				end

				if #diff_lines == 0 then
					set_state_complete(op_name, target_bufnr, "No changes produced")
					vim.notify("No changes produced", vim.log.levels.INFO, { title = "Codex" })
					return
				end

				set_state_preview(op_name, target_bufnr, "Preview ready")

				codex_log.write("apply", {
					op = op_name,
					mode = mode.current(),
					file = current_file(target_bufnr),
					stage = "preview",
					result = "PASS",
				})

				preview.open_diff(diff_lines, {
					title = preview_title,
					on_confirm = function()
						codex_log.write("apply", {
							op = op_name,
							mode = mode.current(),
							file = current_file(target_bufnr),
							stage = "confirm",
							result = "PASS",
						})

						local ok = clang_validate_or_reject(
							target_bufnr,
							ft,
							opts.start_line,
							opts.end_line,
							body,
							user_prompt,
							clang_title,
							op_name
						)

						if not ok then
							return false
						end

						apply_lines_and_log(target_bufnr, opts.start_line, opts.end_line, body, op_name)
						vim.notify("Preview confirmed and applied", vim.log.levels.INFO, { title = "Codex" })
						return true
					end,
					on_abort = function()
						codex_log.write("apply", {
							op = op_name,
							mode = mode.current(),
							file = current_file(target_bufnr),
							stage = "abort",
							result = "ABORT",
						})

						set_state_complete(op_name, target_bufnr, "Preview closed without applying changes")
					end,
				})
			end,

			on_failure = function(result)
				set_state_failed(op_name, target_bufnr, "Codex execution failed")
				local raw = parse.normalize_lines(result.output)
				recovery.show_failure({
					kind = "codex_exec_failed",
					stage = "codex_exec",
					op = op_name,
					mode = mode.current(),
					file = current_file(target_bufnr),
					reason = "Codex execution failed",
					title = "Codex Safe Apply (failed)",
					lines = raw,
				})
			end,
		})
	end)
end

-- -------------------------------------------------------------------
-- Public API
-- -------------------------------------------------------------------

function M.replace_current_function()
	local ft = vim.bo.filetype or "text"
	local start_line, end_line = ts.get_current_function_range_cc()

	if not start_line or not end_line then
		vim.notify("No enclosing function found at cursor", vim.log.levels.WARN, { title = "Codex" })
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	local text = table.concat(lines, "\n")

	M.replace_range(text, start_line, end_line, ft)
end

function M.explain_current_line()
	local line = vim.fn.getline(".")
	local ft = vim.bo.filetype or ""
	local user_prompt = prompt.build_explain(ft, "line")
	local op_name = "explain_current_line"

	remember_and_log_op(op_name, user_prompt)

	runner.run_embedded(line, user_prompt, {
		op = op_name,
		filetype = ft,
		spinner_message = "Codex explaining current line…",
		stream_output = true,
		on_success = function(_)
			set_state_complete(op_name, 0, "Explanation opened")
		end,
		on_failure = function(result)
			set_state_failed(op_name, 0, "Codex execution failed")
			if #result.stderr > 0 then
				open_scratch(result.stderr, "text", "Codex STDERR")
			end
		end,
	})
end

function M.explain_current_buffer()
	local context = require("codex.context")
	local source, capture_error = context.capture_source(vim.api.nvim_get_current_buf())

	if not source then
		vim.notify(capture_error.message, vim.log.levels.WARN, {
			title = "Codex",
		})
		return
	end

	local captured_mode = mode.current()
	local captured_prompt_version = prompt.version()
	local captured_suffix = mode.profile(captured_mode).explain_suffix or ""
	local captured_context_enabled = context.enabled()

	local request = {
		operation = "explain_current_buffer",
		captured_at = source.captured_at,
		source = source,
		context_enabled = captured_context_enabled,
		metadata = {
			file = source.path,
			mode = captured_mode,
			prompt_version = captured_prompt_version,
		},
	}

	-- Freeze prompt policy before Git lookup can process editor events.
	local user_prompt = table.concat({
		prompt.build_explain(source.filetype, "buffer", {
			mode = captured_mode,
			prompt_version = captured_prompt_version,
			explain_suffix = captured_suffix,
		}),
		"",
		"Context:",
		"- Buffer: " .. vim.fn.fnamemodify(source.path, ":t"),
		"- Filetype: " .. (source.filetype ~= "" and source.filetype or "text"),
		"- The supplied input is the complete current Neovim buffer, including unsaved changes.",
	}, "\n")

	local spinner_message = ui.phase_message(request.operation, "running")
	local repository, repository_error = context.resolve_worktree(source)
	if not repository then
		local message = repository_error.message
		if repository_error.details and repository_error.details ~= "" then
			message = message .. "\n" .. repository_error.details
		end
		vim.notify(message, vim.log.levels.ERROR, {
			title = "Codex",
		})
		return
	end

	request.repository = repository

	local execution_location, execution_error = context.capture_execution_location(repository)
	if not execution_location then
		local message = execution_error.message
		if execution_error.details and execution_error.details ~= "" then
			message = message .. "\n" .. execution_error.details
		end
		vim.notify(message, vim.log.levels.ERROR, {
			title = "Codex",
		})
		return
	end

	local execution_directory = execution_location.execution_directory.path
	local validate_execution_location = context.validate_execution_location

	local capture_document = context.capture_document
	local render_supplement = prompt.render_explain_supplement
	local document_options = {
		-- Add any known configured native Codex instruction fallback filenames.
		native_instruction_filenames = {},
	}

	request.baseline_instruction = user_prompt
	request.submitted_instruction = user_prompt
	request.supplement_status = request.context_enabled and "not_selected" or "disabled"

	local phase = "ready"
	local selection_generation = 0

	local function submit()
		if phase ~= "ready" then
			return
		end
		phase = "submitted"

		remember_and_log_op(request.operation, user_prompt, request.metadata)

		local submitted_at = os.time()
		local document = request.document
		local omission = request.document_omission

		local inspection_record = {
			payload = {
				operation = request.operation,
				captured_at = request.captured_at,
				submitted_at = submitted_at,
				context_enabled = request.context_enabled,

				source = {
					bufnr = source.bufnr,
					path = source.path,
					filetype = source.filetype,
					changedtick = source.changedtick,
					modified = source.modified,
					captured_at = source.captured_at,
					text = source.text,
				},

				prompt_policy = {
					mode = request.metadata.mode,
					prompt_version = request.metadata.prompt_version,
					explain_suffix = captured_suffix,
				},

				baseline_instruction = request.baseline_instruction,
				submitted_instruction = request.submitted_instruction,

				repository = {
					editor_path = request.repository.editor_path,
					resolved_path = request.repository.resolved_path,
					worktree_root = request.repository.worktree_root,
					relative_file = request.repository.relative_file,
					lookup_ms = request.repository.lookup_ms,
				},

				execution_location = {
					execution_directory = {
						path = execution_location.execution_directory.path,
						dev = execution_location.execution_directory.dev,
						ino = execution_location.execution_directory.ino,
					},
					worktree_root = {
						path = execution_location.worktree_root.path,
						dev = execution_location.worktree_root.dev,
						ino = execution_location.worktree_root.ino,
					},
					git_directory = {
						path = execution_location.git_directory.path,
						dev = execution_location.git_directory.dev,
						ino = execution_location.git_directory.ino,
					},
				},

				supplement_status = request.supplement_status,
				selected_document_path = request.selected_document_path,

				document = document and {
					status = document.status,
					selected_path = document.selected_path,
					resolved_path = document.resolved_path,
					worktree_root = document.worktree_root,
					relative_file = document.relative_file,
					text = document.text,
					sha256 = document.sha256,
					byte_count = document.byte_count,
					read_bytes = document.read_bytes,
					supplied_bytes = document.supplied_bytes,
					limit_bytes = document.limit_bytes,
					captured_at = document.captured_at,
					preparation_ms = document.preparation_ms,
				} or nil,

				document_omission = omission and {
					status = omission.status,
					code = omission.code,
					message = omission.message,
					selected_path = omission.selected_path,
					resolved_path = omission.resolved_path,
					observed_size = omission.observed_size,
					read_bytes = omission.read_bytes,
					supplied_bytes = omission.supplied_bytes,
					limit_bytes = omission.limit_bytes,
					captured_at = omission.captured_at,
					preparation_ms = omission.preparation_ms,
				} or nil,
			},

			outcome = {
				status = "submission_requested",
				observed_at = submitted_at,
			},
		}

		latest_explain_request = inspection_record

		runner.run_embedded(source.text, request.submitted_instruction, {
			recovery_metadata_only = request.supplement_status == "included" and true or nil,
			op = request.operation,
			filetype = source.filetype,
			execution_directory = execution_directory,
			validate_execution_directory = function(directory)
				if directory ~= execution_directory then
					return nil,
						{
							code = "invalid_execution_location",
							message = "Execution directory differs from the captured request.",
						}
				end

				return validate_execution_location(execution_location)
			end,
			captured_metadata = {
				file = request.metadata.file,
				mode = request.metadata.mode,
				prompt_version = request.metadata.prompt_version,
			},
			spinner_message = spinner_message,
			stream_output = true,
			on_success = function(_)
				inspection_record.outcome = {
					status = "completed",
					observed_at = os.time(),
				}
				set_state_complete(
					request.operation,
					request.source.bufnr,
					"Buffer explanation opened",
					request.metadata
				)
			end,
			on_failure = function(result)
				inspection_record.outcome = {
					status = "failed",
					observed_at = os.time(),
					code = result.code,
					stage = result.stage,
				}
				set_state_failed(request.operation, request.source.bufnr, "Codex execution failed", request.metadata)
				if #result.stderr > 0 then
					open_scratch(result.stderr, "text", "Codex STDERR")
				end
			end,
		})
	end
	local function prepare_document(answer)
		request.selected_document_path = type(answer) == "string" and answer or nil

		local function omit(record)
			request.document_omission = record
			request.supplement_status = "omitted"
			request.submitted_instruction = request.baseline_instruction
			vim.notify(
				"Supplementary document omitted: " .. record.message .. " Explain will continue without it.",
				vim.log.levels.WARN,
				{ title = "Codex" }
			)
		end

		if type(answer) ~= "string" or answer == "" then
			omit({
				status = "omitted",
				code = "invalid_document_path",
				message = "No valid repository-relative document path was supplied.",
				selected_path = request.selected_document_path,
				supplied_bytes = 0,
			})
			return
		end

		local captured, document, omission = pcall(capture_document, request.repository, answer, document_options)

		if not captured then
			omit({
				status = "omitted",
				code = "document_capture_failed",
				message = "Supplementary document capture encountered an error.",
				selected_path = answer,
				supplied_bytes = 0,
			})
			return
		end

		if document == nil then
			if type(omission) == "table" and type(omission.message) == "string" then
				omit(omission)
			else
				omit({
					status = "omitted",
					code = "invalid_document_capture",
					message = "Supplementary document capture returned an invalid result.",
					selected_path = answer,
					supplied_bytes = 0,
				})
			end
			return
		end

		if type(document) ~= "table" or document.status ~= "included" then
			omit({
				status = "omitted",
				code = "invalid_document_capture",
				message = "Supplementary document capture returned an invalid result.",
				selected_path = answer,
				supplied_bytes = 0,
			})
			return
		end

		request.document = document

		local rendered, section = pcall(render_supplement, document, request.context_enabled)
		if not rendered or type(section) ~= "string" or section == "" then
			omit({
				status = "omitted",
				code = "document_render_failed",
				message = "Supplementary document context could not be rendered.",
				selected_path = answer,
				resolved_path = document.resolved_path,
				supplied_bytes = 0,
			})
			return
		end

		request.supplement_section = section
		request.submitted_instruction = request.baseline_instruction .. "\n\n" .. section
		request.supplement_status = "included"
	end

	local choices = {
		"Explain without supplementary document",
		"Select one supplementary document",
	}

	local show_choice
	show_choice = function()
		if phase ~= "ready" and phase ~= "returning" then
			return
		end

		phase = "choosing"
		selection_generation = selection_generation + 1
		local generation = selection_generation

		vim.ui.select(choices, {
			prompt = "Explain captured buffer:",
		}, function(choice)
			if phase ~= "choosing" or generation ~= selection_generation then
				return
			end

			if choice == nil then
				phase = "cancelled"
				return
			end

			if choice == choices[1] then
				phase = "ready"
				submit()
				return
			end

			if choice ~= choices[2] then
				phase = "cancelled"
				vim.notify("Explain cancelled: unrecognised selection.", vim.log.levels.WARN, {
					title = "Codex",
				})
				return
			end

			phase = "entering"
			vim.ui.input({
				prompt = "Supplementary document path (relative to captured Git worktree): ",
			}, function(answer)
				if phase ~= "entering" or generation ~= selection_generation then
					return
				end

				if answer == nil then
					phase = "returning"
					vim.schedule(function()
						if phase == "returning" and generation == selection_generation then
							show_choice()
						end
					end)
					return
				end

				phase = "preparing"
				prepare_document(answer)

				phase = "ready"
				submit()
			end)
		end)
	end

	if request.context_enabled then
		show_choice()
	else
		submit()
	end
end

function M.explain_text(text)
	local ft = vim.bo.filetype or ""
	local op_name = "explain_text"
	local default_prompt = prompt.build_explain(ft, "selection")

	prompt_user({ prompt = "Codex explain: ", default = default_prompt }, function(user_prompt)
		remember_and_log_op(op_name, user_prompt)

		runner.run_embedded(text, user_prompt, {
			op = op_name,
			filetype = ft,
			spinner_message = ui.phase_message(op_name, "running"),
			stream_output = true,
			on_success = function(_)
				set_state_complete(op_name, 0, "Explanation opened")
			end,
			on_failure = function(result)
				set_state_failed(op_name, 0, "Codex execution failed")
				if #result.stderr > 0 then
					open_scratch(result.stderr, "text", "Codex STDERR")
				end
			end,
		})
	end)
end

function M.explain_current_function()
	local bufnr = vim.api.nvim_get_current_buf()
	local text = navigation.current_function_text()

	if not text or vim.trim(text) == "" then
		return
	end

	local ft = vim.bo[bufnr].filetype or ""
	local op_name = "explain_current_function"
	local user_prompt = table.concat({
		prompt.build_explain(ft, "selection"),
		"",
		"Context:",
		"- The supplied input is the complete enclosing function at the cursor.",
	}, "\n")

	remember_and_log_op(op_name, user_prompt)

	runner.run_embedded(text, user_prompt, {
		op = op_name,
		filetype = ft,
		spinner_message = ui.phase_message(op_name, "running"),
		stream_output = true,
		on_success = function(_)
			set_state_complete(op_name, bufnr, "Function explanation opened")
		end,
		on_failure = function(result)
			set_state_failed(op_name, bufnr, "Codex execution failed")
			if #result.stderr > 0 then
				open_scratch(result.stderr, "text", "Codex STDERR")
			end
		end,
	})
end

function M.explain_current_class()
	local bufnr = vim.api.nvim_get_current_buf()
	local text = navigation.current_class_text()

	if not text or vim.trim(text) == "" then
		return
	end

	local ft = vim.bo[bufnr].filetype or ""
	local op_name = "explain_current_class"
	local user_prompt = table.concat({
		prompt.build_explain(ft, "selection"),
		"",
		"Context:",
		"- The supplied input is the complete enclosing class or struct at the cursor.",
		"- Explain its purpose, responsibilities, state, methods, dependencies, and important design considerations.",
	}, "\n")

	remember_and_log_op(op_name, user_prompt)

	runner.run_embedded(text, user_prompt, {
		op = op_name,
		filetype = ft,
		spinner_message = ui.phase_message(op_name, "running"),
		stream_output = true,
		on_success = function(_)
			set_state_complete(op_name, bufnr, "Class explanation opened")
		end,
		on_failure = function(result)
			set_state_failed(op_name, bufnr, "Codex execution failed")
			if #result.stderr > 0 then
				open_scratch(result.stderr, "text", "Codex STDERR")
			end
		end,
	})
end

function M.explain_selection()
	local ui = require("codex.ui")

	-- Immediate UX acknowledgement before selection/prompt work begins.
	ui.start(ui.phase_message("explain_selection", "starting"))

	vim.schedule(function()
		local text = select(1, selection.collect_selection())
		if not text or vim.trim(text) == "" then
			ui.stop("No selection captured", vim.log.levels.WARN)
			vim.notify("No selection captured", vim.log.levels.WARN, { title = "Codex" })
			return
		end
		local ft = vim.bo.filetype or ""
		local user_prompt = prompt.build_explain(ft, "selection")

		remember_and_log_op("explain_selection", user_prompt)

		runner.run_embedded(text, user_prompt, {
			op = "explain_selection",
			filetype = ft,
			spinner_message = ui.phase_message("explain_selection", "running"),
			stream_output = true,
			on_success = function(_)
				set_state_complete("explain_selection", 0, "Explanation opened")
			end,
			on_failure = function(result)
				set_state_failed("explain_selection", 0, "Codex execution failed")
				if #result.stderr > 0 then
					open_scratch(result.stderr, "text", "Codex STDERR")
				end
			end,
		})
	end)
end

function M.explain_selection_fast()
	local ui = require("codex.ui")

	ui.start(ui.phase_message("explain_selection_fast", "starting"))

	vim.schedule(function()
		local text = select(1, selection.collect_selection())
		if not text or vim.trim(text) == "" then
			ui.stop("No selection captured", vim.log.levels.WARN)
			vim.notify("No selection captured", vim.log.levels.WARN, { title = "Codex" })
			return
		end
		local ft = vim.bo.filetype or ""
		local user_prompt = prompt.build_explain_fast(ft, "selection")

		remember_and_log_op("explain_selection_fast", user_prompt)

		runner.run_embedded(text, user_prompt, {
			op = "explain_selection_fast",
			filetype = ft,
			spinner_message = ui.phase_message("explain_selection_fast", "running"),
			stream_output = true,
			on_success = function(_)
				set_state_complete("explain_selection_fast", 0, "Fast explanation opened")
			end,
			on_failure = function(result)
				set_state_failed("explain_selection_fast", 0, "Codex execution failed")
				if #result.stderr > 0 then
					open_scratch(result.stderr, "text", "Codex STDERR")
				end
			end,
		})
	end)
end

function M.review_current_function()
	local bufnr = vim.api.nvim_get_current_buf()
	local text = navigation.current_function_text()

	if not text or vim.trim(text) == "" then
		return
	end

	local ft = vim.bo[bufnr].filetype or ""
	local op_name = "review_current_function"

	local user_prompt = table.concat({
		prompt.build_review(ft, "selection"),
		"",
		"Context:",
		"- The supplied input is the complete enclosing function at the cursor.",
		"- Review it as production-quality code.",
		"- Focus on correctness, readability, maintainability, robustness, and potential defects.",
		"- Do not rewrite the code.",
		"- Do not produce a patch.",
	}, "\n")

	remember_and_log_op(op_name, user_prompt)

	runner.run_embedded(text, user_prompt, {
		op = op_name,
		filetype = ft,
		spinner_message = ui.phase_message(op_name, "running"),

		on_success = function(result)
			local body = parse.prefer_clean_answer(result.output)
			body = selection.collapse_if_doubled(body, nil)

			set_state_complete(op_name, bufnr, "Function review opened")
			open_scratch(body, nil, "Codex Function Review")
		end,

		on_failure = function(result)
			set_state_failed(op_name, bufnr, "Codex execution failed")

			if #result.stderr > 0 then
				recovery.show_failure({
					kind = "codex_exec_failed",
					stage = "codex_exec",
					op = op_name,
					mode = mode.current(),
					file = current_file(bufnr),
					reason = "Codex execution failed",
					title = "Codex STDERR",
					lines = result.stderr,
				})
			end
		end,
	})
end

function M.review_current_class()
	local bufnr = vim.api.nvim_get_current_buf()
	local text = navigation.current_class_text()

	if not text or vim.trim(text) == "" then
		return
	end

	local ft = vim.bo[bufnr].filetype or ""
	local op_name = "review_current_class"

	local user_prompt = table.concat({
		prompt.build_review(ft, "selection"),
		"",
		"Context:",
		"- The supplied input is the complete enclosing class or struct at the cursor.",
		"- Review it as production-quality code.",
		"- Focus on correctness, readability, maintainability, robustness, design, and potential defects.",
		"- Consider responsibilities, state, methods, dependencies, cohesion, and encapsulation.",
		"- Do not rewrite the code.",
		"- Do not produce a patch.",
	}, "\n")

	remember_and_log_op(op_name, user_prompt)

	runner.run_embedded(text, user_prompt, {
		op = op_name,
		filetype = ft,
		spinner_message = ui.phase_message(op_name, "running"),

		on_success = function(result)
			local body = parse.prefer_clean_answer(result.output)
			body = selection.collapse_if_doubled(body, nil)

			set_state_complete(op_name, bufnr, "Class review opened")
			open_scratch(body, nil, "Codex Class Review")
		end,

		on_failure = function(result)
			set_state_failed(op_name, bufnr, "Codex execution failed")

			if #result.stderr > 0 then
				recovery.show_failure({
					kind = "codex_exec_failed",
					stage = "codex_exec",
					op = op_name,
					mode = mode.current(),
					file = current_file(bufnr),
					reason = "Codex execution failed",
					title = "Codex STDERR",
					lines = result.stderr,
				})
			end
		end,
	})
end

function M.apply_inline_current_line()
	local line = vim.fn.getline(".")
	local lnum = vim.fn.line(".")
	local ft = vim.bo.filetype or ""
	local want_lines = 1
	local op_name = "apply_inline_current_line"

	prompt_user({ prompt = "Codex [" .. mode.current() .. "] instruction: " }, function(user_prompt)
		remember_and_log_op(op_name, user_prompt)

		local p = prompt.build_apply(user_prompt, line)

		runner.run({
			op = op_name,
			filetype = ft,
			prompt = p,
			spinner_message = ui.phase_message(op_name, "running"),

			on_success = function(result)
				local raw = parse.normalize_lines(result.output)
				local body = parse.parse_apply_body(raw)
				body = validate_apply_body(raw, body, want_lines, "Apply", op_name)
				if not body then
					return
				end

				local ok =
					clang_validate_or_reject(0, ft, lnum, lnum, body, user_prompt, "Codex Rejected (clang)", op_name)
				if not ok then
					return
				end

				apply_lines_and_log(0, lnum, lnum, body, op_name)
			end,

			on_failure = function(result)
				set_state_failed(op_name, 0, "Codex execution failed")
				local raw = parse.normalize_lines(result.output)
				recovery.show_failure({
					kind = "codex_exec_failed",
					stage = "codex_exec",
					op = op_name,
					mode = mode.current(),
					file = current_file(0),
					reason = "Codex execution failed",
					title = "Codex Apply (failed)",
					lines = raw,
				})
			end,
		})
	end)
end

function M.replace_range(text, start_line, end_line, ft)
	if not text or vim.trim(text) == "" then
		vim.notify("No selection captured", vim.log.levels.WARN, { title = "Codex" })
		return
	end

	ft = ft or (vim.bo.filetype or "text")
	local want_lines = selection.lines_count(text)
	local op_name = "replace_range"

	prompt_user({ prompt = "Codex [" .. mode.current() .. "] instruction: " }, function(user_prompt)
		remember_and_log_op(op_name, user_prompt)

		local p = prompt.build_raw_rewrite(user_prompt, ft, want_lines)

		runner.run_embedded(text, p, {
			op = op_name,
			filetype = ft,
			spinner_message = ui.phase_message(op_name, "running"),

			on_success = function(result)
				local body = parse.prefer_clean_answer(result.output)
				body = selection.collapse_if_doubled(body, want_lines)

				body = validate_rewrite_common(text, body, want_lines, {
					op_name = op_name,
					check_preprocessor = true,
					check_refactor = true,
				})
				if not body then
					return
				end

				local ok = clang_validate_or_reject(
					0,
					ft,
					start_line,
					end_line,
					body,
					user_prompt,
					"Codex Rejected (clang)",
					op_name
				)
				if not ok then
					return
				end

				apply_lines_and_log(0, start_line, end_line, body, op_name)
			end,

			on_failure = function(result)
				set_state_failed(op_name, 0, "Codex execution failed")
				if #result.stderr > 0 then
					recovery.show_failure({
						kind = "codex_exec_failed",
						stage = "codex_exec",
						op = op_name,
						mode = mode.current(),
						file = current_file(0),
						reason = "Codex execution failed",
						title = "Codex STDERR",
						lines = result.stderr,
					})
				end
			end,
		})
	end)
end

function M.replace_selection()
	local ui = require("codex.ui")
	ui.start(ui.phase_message("replace_selection", "starting"))

	vim.schedule(function()
		local text, start_line, end_line = selection.collect_selection()
		if not text or vim.trim(text) == "" then
			ui.stop("No selection captured", vim.log.levels.WARN)
			vim.notify("No selection captured", vim.log.levels.WARN, { title = "Codex" })
			return
		end

		M.replace_range(text, start_line, end_line, vim.bo.filetype or "text")
	end)
end

function M.open_output_scratch()
	local text = select(1, selection.collect_selection())
	if not text or vim.trim(text) == "" then
		vim.notify("No selection captured", vim.log.levels.WARN, { title = "Codex" })
		return
	end

	local ft = vim.bo.filetype or "text"
	local op_name = "open_output_scratch"

	prompt_user({ prompt = "Codex [" .. mode.current() .. "] instruction: " }, function(user_prompt)
		remember_and_log_op(op_name, user_prompt)
		local p = prompt.build_raw_rewrite(user_prompt, ft, nil)

		runner.run_embedded(text, p, {
			op = op_name,
			filetype = ft,
			spinner_message = ui.phase_message(op_name, "running"),

			on_success = function(result)
				local body = parse.prefer_clean_answer(result.output)
				body = selection.collapse_if_doubled(body, nil)
				set_state_complete(op_name, 0, "Output opened in scratch buffer")
				open_scratch(body, nil, "Codex Output")
			end,

			on_failure = function(result)
				set_state_failed(op_name, 0, "Codex execution failed")
				if #result.stderr > 0 then
					recovery.show_failure({
						kind = "codex_exec_failed",
						stage = "codex_exec",
						op = op_name,
						mode = mode.current(),
						file = current_file(0),
						reason = "Codex execution failed",
						title = "Codex STDERR",
						lines = result.stderr,
					})
				end
			end,
		})
	end)
end

function M.save_output_to_file_text(text)
	if not text or vim.trim(text) == "" then
		vim.notify("No selection captured", vim.log.levels.WARN, { title = "Codex" })
		return
	end

	local ft = vim.bo.filetype or "text"
	local op_name = "save_output_to_file_text"

	prompt_user({ prompt = "Codex [" .. mode.current() .. "] instruction: " }, function(user_prompt)
		vim.ui.input({ prompt = "Save output as: " }, function(filename)
			if not filename or vim.trim(filename) == "" then
				codex_log.write("fail", {
					op = op_name,
					mode = mode.current(),
					file = current_file(0),
					stage = "save_output",
					reason = "filename_prompt_cancelled",
				})

				set_state_complete(op_name, 0, "Save output cancelled")
				vim.notify("Save output cancelled", vim.log.levels.INFO, { title = "Codex" })
				return
			end

			remember_and_log_op(op_name, user_prompt)
			local p = prompt.build_raw_rewrite(user_prompt, ft, nil)

			runner.run_embedded(text, p, {
				op = op_name,
				filetype = ft,
				spinner_message = ui.phase_message(op_name, "running"),

				on_success = function(result)
					local to_write = parse.prefer_clean_answer(result.output)
					to_write = selection.collapse_if_doubled(to_write, nil)

					if parse.looks_like_chatty_output(to_write) then
						set_state_failed(op_name, 0, "Codex violated output rules; not writing file")
						recovery.show_failure({
							kind = "rule_break_output",
							stage = "validate",
							op = op_name,
							mode = mode.current(),
							file = current_file(0),
							reason = "Codex violated output rules; not writing file",
							title = "Codex Output (rule break)",
							lines = to_write,
						})
						return
					end

					vim.cmd("edit " .. vim.fn.fnameescape(filename))
					vim.api.nvim_buf_set_lines(0, 0, -1, false, to_write)
					vim.cmd("write")
					set_state_complete(op_name, 0, "Codex output written to file")
					vim.notify("Codex output written to " .. filename, vim.log.levels.INFO, { title = "Codex" })
				end,

				on_failure = function(result)
					set_state_failed(op_name, 0, "Codex execution failed")
					if #result.stderr > 0 then
						recovery.show_failure({
							kind = "codex_exec_failed",
							stage = "codex_exec",
							op = op_name,
							mode = mode.current(),
							file = current_file(0),
							reason = "Codex execution failed",
							title = "Codex STDERR",
							lines = result.stderr,
						})
					end
				end,
			})
		end)
	end)
end

function M.apply_inline()
	local ui = require("codex.ui")
	ui.start(ui.phase_message("apply_inline", "starting"))

	vim.schedule(function()
		local text, start_line, end_line = selection.collect_selection()
		if not text or vim.trim(text) == "" then
			ui.stop("No selection captured", vim.log.levels.WARN)
			vim.notify("No selection captured", vim.log.levels.WARN, { title = "Codex" })
			return
		end

		local ft = vim.bo.filetype or ""
		local want_lines = selection.lines_count(text)
		local op_name = "apply_inline"

		prompt_user({ prompt = "Codex [" .. mode.current() .. "] instruction: " }, function(user_prompt)
			remember_and_log_op(op_name, user_prompt)

			local p = prompt.build_apply(user_prompt, text)

			runner.run({
				op = op_name,
				filetype = ft,
				prompt = p,
				spinner_message = ui.phase_message(op_name, "running"),

				on_success = function(result)
					local raw = parse.normalize_lines(result.output)
					local body = parse.parse_apply_body(raw)
					body = validate_apply_body(raw, body, want_lines, "Apply", op_name)
					if not body then
						return
					end

					local ok = clang_validate_or_reject(
						0,
						ft,
						start_line,
						end_line,
						body,
						user_prompt,
						"Codex Rejected (clang)",
						op_name
					)
					if not ok then
						return
					end

					apply_lines_and_log(0, start_line, end_line, body, op_name)
				end,

				on_failure = function(result)
					set_state_failed(op_name, 0, "Codex execution failed")
					local raw = parse.normalize_lines(result.output)
					recovery.show_failure({
						kind = "codex_exec_failed",
						stage = "codex_exec",
						op = op_name,
						mode = mode.current(),
						file = current_file(0),
						reason = "Codex execution failed",
						title = "Codex Apply (failed)",
						lines = raw,
					})
				end,
			})
		end)
	end)
end

function M.preview_diff_current_line()
	local line = vim.fn.getline(".")
	local lnum = vim.fn.line(".")
	local ft = vim.bo.filetype or ""

	if not line or vim.trim(line) == "" then
		vim.notify("No line captured", vim.log.levels.WARN, { title = "Codex" })
		return
	end

	safe_preview_flow({
		op_name = "preview_diff_current_line",
		prompt_label = "instruction (diff)",
		raw_title_prefix = "Apply",
		preview_title = "Diff Preview",
		clang_title = "Codex Rejected (clang)",
		target_bufnr = vim.api.nvim_get_current_buf(),
		ft = ft,
		start_line = lnum,
		end_line = lnum,
		want_lines = 1,
		original_lines = { line },
		original_text = line,
		check_refactor = false,
	})
end

function M.preview_diff()
	local ui = require("codex.ui")
	ui.start(ui.phase_message("preview_diff", "starting"))

	vim.schedule(function()
		local text, start_line, end_line = selection.collect_selection()
		local ft = vim.bo.filetype or ""

		if not text or vim.trim(text) == "" then
			ui.stop("No selection captured", vim.log.levels.WARN)
			vim.notify("No selection captured", vim.log.levels.WARN, { title = "Codex" })
			return
		end

		safe_preview_flow({
			op_name = "preview_diff",
			prompt_label = "instruction (diff)",
			raw_title_prefix = "Apply",
			preview_title = "Diff Preview",
			clang_title = "Codex Rejected (clang)",
			target_bufnr = vim.api.nvim_get_current_buf(),
			ft = ft,
			start_line = start_line,
			end_line = end_line,
			want_lines = selection.lines_count(text),
			original_lines = vim.fn.getline(start_line, end_line),
			original_text = text,
			check_refactor = false,
		})
	end)
end

function M.run_current_line()
	local line = vim.fn.getline(".")
	local lnum = vim.fn.line(".")
	local ft = vim.bo.filetype or "text"
	local op_name = "run_current_line"

	prompt_user({ prompt = "Codex [" .. mode.current() .. "] instruction: " }, function(user_prompt)
		remember_and_log_op(op_name, user_prompt)

		local p = prompt.build_raw_rewrite(user_prompt, ft, 1)

		runner.run_embedded(line, p, {
			op = op_name,
			filetype = ft,
			spinner_message = ui.phase_message(op_name, "running"),

			on_success = function(result)
				local body = parse.prefer_clean_answer(result.output)
				body = selection.collapse_if_doubled(body, 1)

				body = validate_rewrite_common(line, body, 1, {
					op_name = op_name,
					check_preprocessor = true,
					check_refactor = false,
				})
				if not body then
					return
				end

				local single_line = { body[1] or line }

				local ok = clang_validate_or_reject(
					0,
					ft,
					lnum,
					lnum,
					single_line,
					user_prompt,
					"Codex Rejected (clang)",
					op_name
				)
				if not ok then
					return
				end

				apply_lines_and_log(0, lnum, lnum, single_line, op_name)
			end,

			on_failure = function(result)
				set_state_failed(op_name, 0, "Codex execution failed")
				if #result.stderr > 0 then
					recovery.show_failure({
						kind = "codex_exec_failed",
						stage = "codex_exec",
						op = op_name,
						mode = mode.current(),
						file = current_file(0),
						reason = "Codex execution failed",
						title = "Codex STDERR",
						lines = result.stderr,
					})
				end
			end,
		})
	end)
end

function M.run_entire_file()
	local buf = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local text = table.concat(buf, "\n")
	local ft = vim.bo.filetype or "text"
	local op_name = "run_entire_file"

	prompt_user({ prompt = "Codex [" .. mode.current() .. "] instruction: " }, function(user_prompt)
		remember_and_log_op(op_name, user_prompt)

		local p = prompt.build_entire_file_rewrite(user_prompt)

		runner.run_embedded(text, p, {
			op = op_name,
			filetype = ft,
			spinner_message = ui.phase_message(op_name, "running"),

			on_success = function(result)
				local body = parse.prefer_clean_answer(result.output)
				body = selection.collapse_if_doubled(body, nil)

				if parse.looks_like_file_prose(body) or parse.looks_like_chatty_output(body) then
					set_state_failed(op_name, 0, "Codex returned non-file output; not overwriting buffer")
					recovery.show_failure({
						kind = "non_file_output_rejected",
						stage = "validate",
						op = op_name,
						mode = mode.current(),
						file = current_file(0),
						reason = "Codex returned non-file output; not overwriting buffer",
						title = "Codex File Output (refused overwrite)",
						lines = body,
					})
					return
				end

				local ok =
					clang_validate_or_reject(0, ft, 1, #buf, body, user_prompt, "Codex Rejected (clang)", op_name)
				if not ok then
					return
				end

				apply_lines_and_log(0, 1, #buf, body, op_name)
			end,

			on_failure = function(result)
				set_state_failed(op_name, 0, "Codex execution failed")
				if #result.stderr > 0 then
					recovery.show_failure({
						kind = "codex_exec_failed",
						stage = "codex_exec",
						op = op_name,
						mode = mode.current(),
						file = current_file(0),
						reason = "Codex execution failed",
						title = "Codex STDERR",
						lines = result.stderr,
					})
				end
			end,
		})
	end)
end

function M.patch_buffer()
	local filename = vim.fn.expand("%:p")
	prompt_user({ prompt = "Codex patch: " }, function(p_text)
		set_state_complete("patch_buffer", 0, "Opened Codex diff terminal")
		local cmd = string.format("codex --diff %q %q", p_text, filename)
		vim.cmd("botright split | term " .. cmd)
	end)
end

function M.scratchpad_prompt(default_prompt)
	local op_name = "scratchpad_prompt"

	prompt_user({ prompt = "Codex scratch: ", default = default_prompt or "" }, function(p_text)
		local text = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local buftext = table.concat(text, "\n")
		local ft = vim.bo.filetype or ""

		remember_and_log_op(op_name, p_text)

		runner.run_embedded(buftext, p_text, {
			op = op_name,
			filetype = ft,
			spinner_message = ui.phase_message(op_name, "running"),

			on_success = function(result)
				set_state_complete(op_name, 0, "Scratchpad output opened")
				open_scratch(parse.clean_codex_output(result.output), "markdown")
			end,

			on_failure = function(result)
				set_state_failed(op_name, 0, "Codex execution failed")
				if #result.stderr > 0 then
					recovery.show_failure({
						kind = "codex_exec_failed",
						stage = "codex_exec",
						op = op_name,
						mode = mode.current(),
						file = current_file(0),
						reason = "Codex execution failed",
						title = "Codex STDERR",
						lines = result.stderr,
					})
				end
			end,
		})
	end)
end

function M.safe_preview_confirm_apply_selection()
	local ui = require("codex.ui")
	ui.start(ui.phase_message("safe_preview_confirm_apply_selection", "starting"))

	vim.schedule(function()
		local text, start_line, end_line = selection.collect_selection()

		if not text or vim.trim(text) == "" then
			ui.stop("No selection captured", vim.log.levels.WARN)
			vim.notify("No selection captured", vim.log.levels.WARN, { title = "Codex" })
			return
		end

		safe_preview_flow({
			op_name = "safe_preview_confirm_apply_selection",
			prompt_label = "instruction",
			raw_title_prefix = "Apply",
			preview_title = "Codex Safe Diff Preview",
			clang_title = "Codex Rejected (clang)",
			target_bufnr = vim.api.nvim_get_current_buf(),
			ft = vim.bo.filetype or "",
			start_line = start_line,
			end_line = end_line,
			want_lines = selection.lines_count(text),
			original_lines = vim.fn.getline(start_line, end_line),
			original_text = text,
			check_refactor = false,
		})
	end)
end

function M.safe_preview_confirm_apply_current_function()
	local ft = vim.bo.filetype or ""
	local start_line, end_line = ts.get_current_function_range_cc()

	if not start_line or not end_line then
		vim.notify("No enclosing function found at cursor", vim.log.levels.WARN, { title = "Codex" })
		return
	end

	local target_bufnr = vim.api.nvim_get_current_buf()
	local original_lines = vim.api.nvim_buf_get_lines(target_bufnr, start_line - 1, end_line, false)
	local original_text = table.concat(original_lines, "\n")

	safe_preview_flow({
		op_name = "safe_preview_confirm_apply_current_function",
		prompt_label = "refactor",
		raw_title_prefix = "Refactor",
		preview_title = "Codex Function Refactor Preview",
		clang_title = "Codex Refactor Rejected (clang)",
		target_bufnr = target_bufnr,
		ft = ft,
		start_line = start_line,
		end_line = end_line,
		want_lines = nil,
		original_lines = original_lines,
		original_text = original_text,
		check_refactor = true,
	})
end

function M.open_scratchpad_with_text(text)
	local bufname = "codex://scratchpad"
	local bufnr = vim.fn.bufnr(bufname)

	if bufnr == -1 then
		vim.cmd("botright new")
		bufnr = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_name(bufnr, bufname)
	else
		local winid = vim.fn.bufwinid(bufnr)
		if winid ~= -1 then
			vim.api.nvim_set_current_win(winid)
		else
			vim.cmd("botright sbuffer " .. bufnr)
		end
	end

	local lines = vim.split(text or "", "\n", { plain = true })
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].filetype = "text"
end

function M.toggle_context()
	local on = require("codex.context").toggle()
	vim.notify("Codex context injection: " .. (on and "ON" or "OFF"), vim.log.levels.INFO, { title = "Codex" })
end

function M.show_commands()
	local path = vim.fn.stdpath("config") .. "/docs/COMMANDS.md"

	if vim.fn.filereadable(path) ~= 1 then
		vim.notify("Codex commands draft not found: " .. path, vim.log.levels.WARN, { title = "Codex" })
		return
	end

	local lines = vim.fn.readfile(path)
	open_scratch(lines, "markdown", "Commands")
end

function M.show_explain_context()
	local record = latest_explain_request
	if not record then
		vim.notify("No current-buffer Explain request has been submitted in this session.", vim.log.levels.INFO, {
			title = "Codex",
		})
		return
	end

	-- Payload is privately owned and never modified after submission.
	-- Copy outcome so this explicit refresh has one callback-observed status.
	local payload = record.payload
	local outcome = vim.deepcopy(record.outcome)

	local function metadata_without_text(value)
		if not value then
			return nil
		end
		local metadata = {}
		for key, item in pairs(value) do
			if key ~= "text" then
				metadata[key] = item
			end
		end
		return metadata
	end

	local sections = {
		{
			name = "Submitted instruction supplied to run_embedded",
			text = payload.submitted_instruction,
		},
		{
			name = "Captured source input supplied separately to run_embedded",
			text = payload.source.text,
		},
		{
			name = "Baseline instruction",
			text = payload.baseline_instruction,
		},
	}

	if payload.document then
		sections[#sections + 1] = {
			name = "Captured supplementary document; inclusion is reported in metadata",
			text = payload.document.text,
		}
	end

	-- Pick boundaries absent from every stored content section.
	local boundary
	local index = 0
	repeat
		boundary = "<<<AIDE_EXPLAIN_INSPECTION_" .. index .. "_"
		index = index + 1
		local collision = false
		for _, section in ipairs(sections) do
			if section.text:find(boundary, 1, true) then
				collision = true
				break
			end
		end
		if not collision then
			break
		end
	until false

	local lines = {
		"Neovim-AIDE application-supplied context",
		"",
		"WARNING: This report may contain sensitive source and project-document content.",
		"Session-local view. Nothing is automatically exported or copied to the clipboard.",
		"",
		"This is not complete Codex context or evidence of effective execution permissions.",
		"Instruction and source are separate application inputs; the runner adds its source envelope.",
		"All identities below were captured; inspection does not revalidate their current state.",
		"Refresh occurs only when :CodexExplainContext is invoked.",
		"",
		"Content display:",
		"- Stored strings are copied without trimming, newline conversion or prompt regeneration.",
		"- LF bytes separate buffer lines; CR and TAB bytes remain in those lines.",
		"- Visible list characters are display aids, not stored content.",
		"- Trailing empty lines are retained before each END boundary.",
		"- Boundary lines and their separating line breaks are report framing.",
		"- Byte counts and hashes describe stored strings, not this report as an export format.",
		"",
		"Callback-observed outcome: " .. vim.json.encode(outcome),
	}

	if outcome.status == "submission_requested" then
		lines[#lines + 1] = "Submission was requested; no completion notification has been received."
		lines[#lines + 1] = "This does not establish whether a child is waiting, running or health-blocked."
	end

	local function add_metadata(label, value)
		lines[#lines + 1] = label .. ": " .. (value == nil and "not recorded" or vim.json.encode(value))
	end

	lines[#lines + 1] = ""
	add_metadata("Operation", payload.operation)
	add_metadata("Capture timestamp", payload.captured_at)
	add_metadata("Submission timestamp", payload.submitted_at)
	add_metadata("Captured context-enabled decision", payload.context_enabled)
	add_metadata("Source identity", metadata_without_text(payload.source))
	add_metadata("Captured prompt policy", payload.prompt_policy)
	add_metadata("Captured Git repository", payload.repository)
	add_metadata("Captured execution location", payload.execution_location)
	add_metadata("Supplementary status", payload.supplement_status)
	add_metadata("Selected document path", payload.selected_document_path)
	add_metadata("Captured document metadata", metadata_without_text(payload.document))
	add_metadata("Document omission", payload.document_omission)

	for number, section in ipairs(sections) do
		lines[#lines + 1] = ""
		lines[#lines + 1] = section.name
		lines[#lines + 1] = "Stored bytes: " .. #section.text
		lines[#lines + 1] = "SHA-256 of stored bytes: " .. vim.fn.sha256(section.text)
		lines[#lines + 1] = boundary .. "BEGIN_" .. number .. ">>>"

		for _, line in ipairs(vim.split(section.text, "\n", { plain = true, trimempty = false })) do
			lines[#lines + 1] = line
		end

		lines[#lines + 1] = boundary .. "END_" .. number .. ">>>"
	end

	local name = "codex://explain-context"
	local existing = vim.fn.bufnr(name)
	local visible_window

	if existing ~= -1 and vim.api.nvim_buf_is_valid(existing) then
		-- Disable undo before replacing any earlier sensitive report.
		vim.bo[existing].undofile = false
		vim.bo[existing].undolevels = -1

		local current_window = vim.api.nvim_get_current_win()
		for _, win in ipairs(vim.fn.win_findbuf(existing)) do
			if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == existing then
				if not visible_window or win == current_window then
					visible_window = win
				end
			end
		end
	end

	local bufnr
	if visible_window then
		-- This also selects the target tab when necessary.
		local focused = pcall(vim.api.nvim_set_current_win, visible_window)
		if
			not focused
			or not vim.api.nvim_win_is_valid(visible_window)
			or vim.api.nvim_get_current_win() ~= visible_window
			or vim.api.nvim_win_get_buf(visible_window) ~= existing
		then
			vim.notify("Explain context view could not be focused. Please retry.", vim.log.levels.WARN, {
				title = "Codex",
			})
			return
		end

		bufnr = existing
		vim.bo[bufnr].buftype = "nofile"
		vim.bo[bufnr].bufhidden = "wipe"
		vim.bo[bufnr].swapfile = false
		vim.bo[bufnr].filetype = ""

		vim.bo[bufnr].readonly = false
		vim.bo[bufnr].modifiable = true
		local updated = pcall(vim.api.nvim_buf_set_lines, bufnr, 0, -1, false, lines)

		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.bo[bufnr].modifiable = false
			vim.bo[bufnr].readonly = true
		end

		if not updated or not vim.api.nvim_buf_is_valid(bufnr) then
			vim.notify("Explain context view could not be refreshed. Please retry.", vim.log.levels.WARN, {
				title = "Codex",
			})
			return
		end
	else
		bufnr = require("codex.window").open({
			name = name,
			lines = lines,
			filetype = "",
			close_desc = "Close Explain context inspection",
		})
	end

	vim.bo[bufnr].undofile = false
	vim.bo[bufnr].undolevels = -1
	vim.bo[bufnr].buflisted = false
	vim.bo[bufnr].syntax = ""

	vim.wo.conceallevel = 0
	vim.wo.wrap = false
	vim.wo.spell = false
	vim.wo.foldenable = false
	vim.wo.list = true
	vim.wo.listchars = "tab:>-,trail:.,eol:$,nbsp:+"
end

function M.show_context()
	local context = require("codex.context")
	local window = require("codex.window")

	local info = context.collect(0)
	local block = context.render_block(0)

	local markers = "none"
	if info.markers and #info.markers > 0 then
		markers = table.concat(info.markers, ", ")
	end

	local status = info.enabled and "Enabled" or "Disabled"

	local lines = {
		"Codex Project Context",
		"=====================",
		"",
		"Status:        " .. status,
		"Project root:  " .. tostring(info.project_root or "-"),
		"Current file:  " .. tostring(info.file or "-"),
		"Relative file: " .. tostring(info.relative_file or "-"),
		"Filetype:      " .. tostring(info.filetype or "-"),
		"Markers:       " .. markers,
		"",
		"Injected block",
		"--------------",
		"",
	}

	if block and block ~= "" then
		vim.list_extend(lines, vim.split(block, "\n", { plain = true }))
	else
		lines[#lines + 1] = "Project Context is disabled. No context block will be added to prompts."
	end

	window.open({
		name = "codex://context",
		lines = lines,
		filetype = "markdown",
		close_desc = "Close Codex project context",
	})
end

function M.explain_failure()
	local recovery = require("codex_recovery")
	local failure_report = recovery.get_last_failure()

	local ok, reason = recovery.can_explain_with_codex(failure_report)
	if not ok then
		vim.notify(reason, vim.log.levels.WARN, { title = "Codex" })
		return
	end

	local recovery_metadata_only
	if failure_report.recovery_metadata_only == true or failure_report.output_persistence == "metadata_only" then
		recovery_metadata_only = true
	end

	set_state_running("explain_failure", 0, "Explaining last captured failure")

	local prompt = table.concat({
		"You are diagnosing a captured Neovim-AIDE failure.",
		"",
		"Explain the likely cause concisely.",
		"Do not suggest editing source files unless the failure clearly requires it.",
		"Do not invent missing context.",
		"Give:",
		"1. Likely cause",
		"2. Why the system rejected it",
		"3. Suggested next diagnostic step",
		"",
		"Failure report:",
		vim.json.encode(failure_report),
	}, "\n")

	require("codex.runner").run({
		op = "explain_failure",
		prompt = prompt,
		recovery_metadata_only = recovery_metadata_only,
		spinner_message = "Codex [explain_failure] working…",
		filetype = "text",
		on_success = function(result)
			local lines = result.output or {}

			if type(lines) ~= "table" then
				lines = { tostring(lines) }
			end

			set_state_complete("explain_failure", 0, "Failure explanation opened")

			open_scratch(lines, "markdown", "Explain Failure")
		end,
		on_failure = function(result)
			set_state_failed("explain_failure", 0, "Codex failed to explain failure")
			vim.notify("Codex failed to explain failure", vim.log.levels.ERROR, { title = "Codex" })
		end,
	})
end

function M.health_check()
	require("codex.health").show()
end

function M.show_guardrails()
	require("codex_guard").show()
end

function M.show_state()
	require("codex.state").show()
end

function M.show_state_history()
	require("codex.state").show_history()
end

function M.show_latency()
	require("codex.latency").show()
end

function M.show_recovery()
	require("codex_recovery").show_last_failure()
end

function M.clear_recovery()
	require("codex_recovery").clear_last_failure()
	vim.notify("Codex recovery cleared", vim.log.levels.INFO, { title = "Codex" })
end

function M.show_prompt_version()
	require("codex.prompt_version").show()
end

function M.show_last_op()
	require("codex.session").show_last_op()
end

function M.repeat_last_op()
	require("codex.session").repeat_last_op()
end

function M.clear_last_op()
	require("codex_memory").clear_last_op()
	vim.notify("Codex last operation cleared", vim.log.levels.INFO, { title = "Codex" })
end

pcall(vim.api.nvim_del_user_command, "CodexHealth")
vim.api.nvim_create_user_command("CodexHealth", function()
	require("codex_cli").health_check()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexHealthCheck")
vim.api.nvim_create_user_command("CodexHealthCheck", function()
	local ok = require("codex.health").is_healthy()

	if ok then
		vim.notify("Codex health: PASS", vim.log.levels.INFO, { title = "Codex" })
	else
		vim.notify("Codex health: NOT PASS", vim.log.levels.ERROR, { title = "Codex" })
	end
end, {})

pcall(vim.api.nvim_del_user_command, "CodexGuardrails")
vim.api.nvim_create_user_command("CodexGuardrails", function()
	require("codex_cli").show_guardrails()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexState")
vim.api.nvim_create_user_command("CodexState", function()
	require("codex_cli").show_state()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexStateHistory")
vim.api.nvim_create_user_command("CodexStateHistory", function()
	require("codex_cli").show_state_history()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexLatency")
vim.api.nvim_create_user_command("CodexLatency", function()
	require("codex_cli").show_latency()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexExplainFailure")
vim.api.nvim_create_user_command("CodexExplainFailure", function()
	require("codex_cli").explain_failure()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexRecovery")
vim.api.nvim_create_user_command("CodexRecovery", function()
	require("codex_cli").show_recovery()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexRecoveryClear")
vim.api.nvim_create_user_command("CodexRecoveryClear", function()
	require("codex_cli").clear_recovery()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexPromptVersion")
vim.api.nvim_create_user_command("CodexPromptVersion", function()
	require("codex_cli").show_prompt_version()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexLastOp")
vim.api.nvim_create_user_command("CodexLastOp", function()
	require("codex_cli").show_last_op()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexLastOpClear")
vim.api.nvim_create_user_command("CodexLastOpClear", function()
	require("codex_cli").clear_last_op()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexRepeat")
vim.api.nvim_create_user_command("CodexRepeat", function()
	require("codex_cli").repeat_last_op()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexExplainContext")
vim.api.nvim_create_user_command("CodexExplainContext", function()
	require("codex_cli").show_explain_context()
end, {
	desc = "Inspect latest submitted current-buffer Explain inputs",
})

pcall(vim.api.nvim_del_user_command, "CodexContext")
vim.api.nvim_create_user_command("CodexContext", function()
	require("codex_cli").show_context()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexToggleContext")
vim.api.nvim_create_user_command("CodexToggleContext", function()
	require("codex_cli").toggle_context()
end, {})

pcall(vim.api.nvim_del_user_command, "CodexCommands")
vim.api.nvim_create_user_command("CodexCommands", function()
	require("codex_cli").show_commands()
end, {})

return M
