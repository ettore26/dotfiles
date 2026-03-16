-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "[Q]uickfix list open diagnostic" })
vim.keymap.set("n", "]g", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[g", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Open diagnostic" })

-- Reload
vim.keymap.set("n", "<leader>sr", function()
  vim.cmd("silent! source " .. vim.env.MYVIMRC)
  vim.notify("Config reloaded", vim.log.levels.INFO)
end, { desc = "[S]ource [R]eload" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Navigate buffers
vim.keymap.set("n", "<C-n>", "<cmd>bnext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<C-p>", "<cmd>bprevious<CR>", { silent = true, desc = "Previous buffer" })

-- vim.keymap.set("n", "<C-c>", "<cmd>bwipeout<CR>", { silent = true, desc = "Closees the buffer" })
vim.keymap.set("n", "<C-c>", function()
  if vim.bo.filetype == "oil" then
    vim.cmd("only")
    return
  end
  vim.cmd("bwipeout")
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and not name:match("^oil://") then
        return
      end
    end
  end
  require("oil").open()
end, { silent = true, desc = "Close buffer, open Oil if last" })
