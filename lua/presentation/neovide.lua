local M = {}

function M.setup()
  if not vim.g.neovide then
    return
  end

  -- Font and UI scaling
  vim.o.guifont = "JetBrainsMono Nerd Font Mono:h14"
  vim.g.neovide_scale_factor = 1.0

  -- Cursor presentation
  vim.g.neovide_cursor_animation_length = 0.02
  vim.g.neovide_cursor_trail_size = 0.0
  vim.g.neovide_cursor_antialiasing = true

  -- Window padding
  vim.g.neovide_padding_top = 6
  vim.g.neovide_padding_bottom = 6
  vim.g.neovide_padding_right = 8
  vim.g.neovide_padding_left = 8

  -- Transparency and blur
  vim.g.neovide_opacity = 1.0
  vim.g.neovide_window_blurred = false

  -- Floating-window presentation
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 12
  vim.g.neovide_light_radius = 4

  -- macOS-style input behaviour
  vim.g.neovide_input_macos_option_key_is_meta = "only_left"

  -- Remember size between launches
  vim.g.neovide_remember_window_size = true

  -- Neovide-specific keybindings
  vim.keymap.set("n", "<D-s>", ":w<CR>")
  vim.keymap.set("v", "<D-c>", '"+y')
  vim.keymap.set("n", "<D-v>", '"+P')
  vim.keymap.set("i", "<D-v>", '<ESC>"+Pli')

  -- Dynamic window title
  vim.o.title = true

  local function update_title()
    local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    local file = vim.fn.expand("%:t")

    if file ~= "" then
      local mode = vim.api.nvim_get_mode().mode
      vim.o.titlestring = string.format("nvim — %s/%s [%s]", cwd, file, mode)
    else
      vim.o.titlestring = "nvim — " .. cwd
    end
  end

  update_title()

  vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
    callback = update_title,
  })
end

return M
