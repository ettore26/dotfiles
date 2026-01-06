--[[
 _______  _______  _______  _______  ______    _______
|       ||       ||       ||       ||    _ |  |       |
|    ___||_     _||_     _||   _   ||   | ||  |    ___|
|   |___   |   |    |   |  |  | |  ||   |_||_ |   |___
|    ___|  |   |    |   |  |  |_|  ||    __  ||    ___|
|   |___   |   |    |   |  |       ||   |  | ||   |___
|_______|  |___|    |___|  |_______||___|  |_||_______|  NeoVim Config
--]]

vim.loader.enable()

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Netrw configuration
-- require 'config.netrw'
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- ...
vim.g.editorconfig = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Use stack to save jumps, old jumps may be removed
vim.o.jumpoptions = "stack"

vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
  group = vim.api.nvim_create_augroup("CheckForExternalChanges", { clear = true }),
  callback = function()
    vim.cmd("checktime")
  end,
})

-- Use spaces instead of tabs
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smarttab = true

-- Follow file indentation
vim.opt.smartindent = true

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 3

-- Adds max column delimiter line
-- vim.opt.colorcolumn = '120'

-- Folding configuration
-- https://www.jackfranklin.co.uk/blog/code-folding-in-vim-neovim/
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 1
vim.opt.foldnestmax = 10
vim.opt.fillchars:append({ fold = " " })
vim.opt.foldenable = false

-- ..
vim.opt.laststatus = 3

-- hide/replace chars by plugins
vim.opt.conceallevel = 1

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

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Navigate buffers
-- vim.keymap.set('n', '<C-n>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set("n", "<C-n>", "<cmd>bnext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<C-p>", "<cmd>bprevious<CR>", { silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<C-c>", "<cmd>bwipeout<CR>", { silent = true, desc = "Closees the buffer" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

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
          if
            (bufname == "" or bufname:match("^%s*$"))
            and vim.api.nvim_get_option_value("filetype", { buf = buf }) ~= "netrw"
            and vim.api.nvim_get_option_value("filetype", { buf = buf }) ~= "oil"
            and vim.api.nvim_get_option_value("filetype", { buf = buf }) ~= "harpoon"
          then
            -- Close the unnamed buffer
            vim.api.nvim_buf_delete(buf, { force = false })
          end
        end
      end
    end
  end,
})

-- Lazy plugin manager config
require("config.lazy")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
