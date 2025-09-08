function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  else
    -- If there is no current directory (e.g. over ssh), just show the buffer name
    return vim.api.nvim_buf_get_name(0)
  end
end

vim.api.nvim_create_user_command("OilToggle", function()
  vim.cmd((vim.bo.filetype == "oil") and "bd" or "Oil")
end, { nargs = 0 })

return {
  "stevearc/oil.nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },

  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    buf_options = {
      buflisted = false,
      bufhidden = "hide",
    },
    view_options = {
      -- Show files and directories that start with "."
      show_hidden = true,
    },
    keymaps = {
      ["<F1>"] = { "actions.show_help" },
    },
    win_options = {
      winbar = "%!v:lua.get_oil_winbar()",
    },

    -- vim.keymap.set('n', '<leader>e', '<CMD>Oil --preview<CR>', { desc = 'Open parent directory' }),
    -- vim.keymap.set('n', '<leader>e', '<CMD>Oil<CR>', { desc = 'Open parent directory' }),
    vim.keymap.set("n", "<leader>e", "<CMD>OilToggle<CR>", { desc = "Open parent directory" }),

    vim.keymap.set("n", "go", function()
      local oil = require("oil")
      local current_dir = oil.get_current_dir()
      local cursor_entry = oil.get_cursor_entry()

      if current_dir and cursor_entry and cursor_entry.name then
        vim.api.nvim_command("edit " .. current_dir .. cursor_entry.name)
      end
    end, { desc = "Open file under cursor and do not follow link" }),
  },
}
