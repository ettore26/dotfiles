-- smart-splits v3 dropped start_resize_mode, so this loops over its resize functions
-- until a key other than h/j/k/l is pressed
local function resize_mode()
  local ss = require("smart-splits")
  local actions = { h = ss.resize_left, j = ss.resize_down, k = ss.resize_up, l = ss.resize_right }
  while true do
    vim.cmd.redraw()
    vim.api.nvim_echo({ { "-- RESIZE -- h/j/k/l, any other key to exit", "ModeMsg" } }, false, {})
    local ok, key = pcall(vim.fn.getcharstr)
    local action = ok and actions[key]
    if not action then
      break
    end
    action()
  end
  vim.api.nvim_echo({ { "" } }, false, {})
end

return {
  "mrjones2014/smart-splits.nvim",
  lazy = false, -- backend-tmux sets @pane-is-vim on load; lazy loading leaves tmux eating C-hjkl
  dependencies = {
    { "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" },
  },
  opts = {
    mux = { backend = "smart-splits-backend-tmux" },
  },
  keys = {
    { "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize split left" },
    { "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize split down" },
    { "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize split up" },
    { "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize split right" },
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Go to left split" },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Go to lower split" },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Go to upper split" },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Go to right split" },
    { "<leader>wr", resize_mode, desc = "[W]indow [R]esize mode" },
  },
}
