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

-- Bind each db buffer to its own directory's .env (vim-dadbod-ui, one-dir-at-a-time)
vim.api.nvim_create_autocmd("FileType", {
  desc = "Load dir-local .env and bind dadbod connection for DB query buffers",
  group = vim.api.nvim_create_augroup("dadbod-dir-env", { clear = true }),
  pattern = { "sql", "mysql", "plsql", "redis" },
  callback = function(args)
    -- run once per real file buffer; skip dadbod-ui's own scratch/query buffers
    -- (DBUIFindBuffer re-sets ft=sql -> would re-trigger this and loop)
    if vim.b[args.buf].dadbod_dir_env_done then
      return
    end
    if vim.bo[args.buf].buftype ~= "" or args.file == "" then
      return
    end
    vim.b[args.buf].dadbod_dir_env_done = true

    local dir = vim.fn.fnamemodify(args.file, ":p:h")
    if vim.fn.filereadable(dir .. "/.env") ~= 1 then
      return
    end
    -- this file's dir becomes cwd -> its inner .env is the one dadbod-ui reads
    vim.cmd.lcd(vim.fn.fnameescape(dir))

    -- Derive g:db_ui_save_location from THIS file's location: parent of its dir.
    -- dadbod-ui globs saved queries from <save_location>/<connection_name>, and
    -- the connection name (from DB_UI_<DIR>) equals the dir basename -> the glob
    -- lands back in this exact dir. No static project path. Note: dadbod-ui
    -- reads this once at first DBUI init; sibling dirs share a parent so the
    -- value is stable. (Switching to a dir under a different parent mid-session
    -- needs a fresh nvim, since the DBUI instance is cached.)
    vim.g.db_ui_save_location = vim.fn.fnamemodify(dir, ":h")

    -- Bind b:db from the dir's .env so a directly-opened file (not via the DBUI
    -- drawer) still runs with :DB. Drawer integration is handled natively by
    -- g:db_ui_save_location -> files show under "Saved queries"; opening one
    -- from the drawer binds the connection itself, no autocmd needed.
    pcall(function()
      require("lazy").load({ plugins = { "vim-dotenv", "vim-dadbod" } })
    end)
    if vim.fn.exists(":Dotenv") == 2 then
      -- vim-dotenv expands ${PGUSER}/${DATABASE_URL} on load
      vim.cmd("silent! Dotenv " .. vim.fn.fnameescape(dir .. "/.env"))
      if vim.env.DATABASE_URL and vim.env.DATABASE_URL ~= "" then
        vim.b.db = vim.env.DATABASE_URL
      end
    end
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
