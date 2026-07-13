-- ~/.config/nvim/lua/codex_mode.lua
--
-- Neovim-AIDE workflow modes.
--
-- These modes are intentionally lightweight in R1.x:
--
--   mode -> prompt policy
--
-- In R2.0, this module can evolve toward:
--
--   mode -> workflow profile -> provider/model profile + prompt policy
--
-- The public user-facing concept should remain stable:
--
--   fast      quick, concise, low-friction assistance
--   balanced  general-purpose default behaviour
--   strict    precision-first, low-speculation assistance
--   refactor  constrained rewrite/refactor safety profile

local M = {}

-- Emergency fallback used only if configuration cannot be read
-- or contains an invalid workflow mode.
local FALLBACK_MODE = "fast"

-- Explicit cycle order.
--
-- From the default `fast`, cycling moves through increasing deliberateness:
--
--   fast -> balanced -> strict -> refactor -> fast
--
local MODE_ORDER = {
	"fast",
	"balanced",
	"strict",
	"refactor",
}

local profiles = {
	fast = {
		name = "fast",
		label = "Fast",
		intent = "low_latency",
		risk = "low",
		description = "Quick, concise assistance for low-friction daily use.",

		-- Future R2.x hint only. Not used by R1.x execution.
		future_model_profile = "low-latency",

		explain_suffix = table.concat({
			"",
			"FAST MODE:",
			"- Keep output minimal.",
			"- Skip redundant explanation.",
			"- Prefer the shortest useful answer.",
			"",
		}, "\n"),

		rewrite_suffix = table.concat({
			"",
			"FAST MODE:",
			"- Keep the change minimal.",
			"- Avoid unrelated edits.",
			"- Prefer the smallest correct change.",
			"",
		}, "\n"),
	},

	balanced = {
		name = "balanced",
		label = "Balanced",
		intent = "general",
		risk = "medium",
		description = "General-purpose assistance with practical detail and proportionate changes.",

		-- Future R2.x hint only. Not used by R1.x execution.
		future_model_profile = "general-coding",

		explain_suffix = table.concat({
			"",
			"BALANCED MODE:",
			"- Be clear and practical.",
			"- Give enough detail to support developer judgement.",
			"- Avoid unnecessary verbosity.",
			"",
		}, "\n"),

		rewrite_suffix = table.concat({
			"",
			"BALANCED MODE:",
			"- Keep changes proportionate to the instruction.",
			"- Preserve existing intent and style where practical.",
			"- Avoid unrelated rewrites.",
			"",
		}, "\n"),
	},

	strict = {
		name = "strict",
		label = "Strict",
		intent = "precision",
		risk = "low",
		description = "Precision-first assistance with low speculation and conservative changes.",

		-- Future R2.x hint only. Not used by R1.x execution.
		future_model_profile = "precision",

		explain_suffix = table.concat({
			"",
			"STRICT MODE:",
			"- Be extremely precise.",
			"- Avoid speculation.",
			"- If unsure, explicitly say so.",
			"- Do not invent missing context.",
			"",
		}, "\n"),

		rewrite_suffix = table.concat({
			"",
			"STRICT MODE:",
			"- Make only the requested change.",
			"- No stylistic changes beyond the instruction.",
			"- Preserve structure unless a structural change is required.",
			"- Avoid unrelated edits.",
			"",
		}, "\n"),
	},

	refactor = {
		name = "refactor",
		label = "Refactor",
		intent = "constrained_rewrite",
		risk = "high",
		description = "Constrained refactor profile for safe selection-only rewrites.",

		-- Future R2.x hint only. Not used by R1.x execution.
		future_model_profile = "code-reasoning",

		explain_suffix = table.concat({
			"",
			"REFACTOR MODE:",
			"- Explain refactor tradeoffs briefly.",
			"- Prefer minimal, safe changes.",
			"- Call out any behavioural risk explicitly.",
			"",
		}, "\n"),

		rewrite_suffix = table.concat({
			"",
			"REFACTOR MODE (HARD RULES):",
			"- Output MUST be code only (no commentary).",
			"- Output MUST be ONLY the rewritten selection; do not include surrounding file content.",
			"",
			"- Preserve external interface unless I explicitly ask otherwise.",
			"- Do NOT rename the selected function.",
			"- Do NOT change the selected function signature (name, parameter list, return type).",
			"",
			"- The selection MUST remain EXACTLY ONE function definition.",
			"- Do NOT add any other top-level declarations in the output (no new helper functions, no extra functions, no structs/classes/enums, no templates, no overloads).",
			"- Do NOT create lambdas or local function-objects to replace helpers.",
			"- Do NOT introduce any new symbol that reuses an existing name in the file (no shadowing).",
			"",
			"- If a helper already exists elsewhere in the file that satisfies the goal, you MUST reuse it via a call; never redefine it.",
			"- If asked to extract clamp logic and a clamp helper exists, call it with appropriate bounds rather than creating a new clamp.",
			"",
			"- Prefer internal clarity only: local variable naming, small control-flow cleanup, comments, const correctness (only if interface unchanged).",
			"- Avoid broad redesign.",
			"- Avoid behavioural change unless explicitly requested.",
			"",
		}, "\n"),
	},
}

local function has_profile(name)
	return type(name) == "string" and profiles[name] ~= nil
end

local function copy_profile(profile)
	if type(vim) == "table" and vim.deepcopy then
		return vim.deepcopy(profile)
	end

	-- Fallback for unusually constrained test environments.
	local out = {}
	for k, v in pairs(profile) do
		out[k] = v
	end
	return out
end

local function configured_default_mode()
	local ok, config = pcall(require, "codex.config")
	if not ok or not config or type(config.get) ~= "function" then
		return FALLBACK_MODE
	end

	local cfg = config.get()
	local workflow = cfg.workflow or {}
	local mode = workflow.default_mode

	if has_profile(mode) then
		return mode
	end

	return FALLBACK_MODE
end

local state = {
	current = configured_default_mode(),
}

local function index_of_mode(name)
	for i, mode_name in ipairs(MODE_ORDER) do
		if mode_name == name then
			return i
		end
	end
	return nil
end

function M.get()
	return profiles[state.current]
end

function M.profile(name)
	if not has_profile(name) then
		return nil
	end

	return copy_profile(profiles[name])
end

function M.exists(name)
	return has_profile(name)
end

function M.set(name)
	if not has_profile(name) then
		return false
	end

	state.current = name
	return true
end

function M.current()
	return state.current
end

function M.label(name)
	local profile = profiles[name or state.current]
	if not profile then
		return name or state.current
	end

	return profile.label or profile.name
end

function M.description(name)
	local profile = profiles[name or state.current]
	if not profile then
		return ""
	end

	return profile.description or ""
end

function M.default()
	return configured_default_mode()
end

function M.fallback()
	return FALLBACK_MODE
end

function M.names()
	local out = {}

	for _, name in ipairs(MODE_ORDER) do
		if profiles[name] then
			table.insert(out, name)
		end
	end

	return out
end

function M.profiles()
	local out = {}

	for _, name in ipairs(MODE_ORDER) do
		if profiles[name] then
			table.insert(out, copy_profile(profiles[name]))
		end
	end

	return out
end

function M.cycle()
	local current_index = index_of_mode(state.current)

	if not current_index then
		state.current = FALLBACK_MODE
		return state.current
	end

	local next_index = current_index + 1
	if next_index > #MODE_ORDER then
		next_index = 1
	end

	state.current = MODE_ORDER[next_index]
	return state.current
end

return M

