-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Enable treesitter highlighting and indentation for all filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- Check for external file changes
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
  group = vim.api.nvim_create_augroup("CheckForExternalChanges", { clear = true }),
  callback = function()
    vim.cmd("checktime")
  end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Start with a new jumplist on opening
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd("clearjumps")
  end,
})

-- Clean up unnamed buffers when entering a named buffer
vim.api.nvim_create_augroup("BufferCleanup", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = "BufferCleanup",
  callback = function()
    -- Get current buffer
    local current_buf = vim.api.nvim_get_current_buf()
    local current_bufname = vim.api.nvim_buf_get_name(current_buf)

    -- If we're in a named buffer, check for and close unnamed buffers
    if current_bufname ~= "" and not current_bufname:match("^%s*$") then
      -- Get all buffers
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) then
          local bufname = vim.api.nvim_buf_get_name(buf)
          -- Check if this is an unnamed buffer that's not oil or harpoon
          local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
          local modified = vim.api.nvim_get_option_value("modified", { buf = buf })
          if
            (bufname == "" or bufname:match("^%s*$"))
            and not modified
            and ft ~= "netrw"
            and ft ~= "oil"
            and ft ~= "harpoon"
            and not ft:match("^snacks_")
          then
            vim.api.nvim_buf_delete(buf, { force = false })
          end
        end
      end
    end
  end,
})
