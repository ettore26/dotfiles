-- plugins/telescope.lua:

return { -- Fuzzy Finder (files, lsp, etc)
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require("telescope").setup({
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      -- defaults = {
      --   mappings = {
      --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
      --   },
      -- },
      defaults = {
        hidden = true,
        no_ignore = true,
        winblend = 0,
        border = true,
        -- borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
        -- borderchars = { '▔', '▕', '▁', '▏', '🭽', '🭾', '🭿', '🭼' },
        file_ignore_patterns = {
          "node_modules",
          -- '.ruff_cache',
          ".git/",
          -- '.mypy_cache',
        },
        preview = {
          filesize_limit = 0.5555,
          treesitter = false,
        },
        mappings = {
          i = {
            ["<C-s>"] = require("telescope.actions.layout").toggle_preview,
            ["<C-h>"] = "which_key",
          },
        },
      },
      pickers = {
        find_files = {
          -- hidden = true, -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
          -- no_ignore = true,
          -- find_command = { 'rg', '--files', '--hidden', '--no-ignore', '--glob', '!**/.git/*' },
          -- find_command = { 'rg', '--files', '--hidden' },
          -- find_command = { 'fd', '-t=d', '-t=f' },
          find_command = { "fd", "-t=f", "--no-ignore-parent", "--hidden" },
          -- theme = 'dropdown',
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })

    -- Enable Telescope extensions if they are installed
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")

    -- See `:help telescope.builtin`
    local builtin = require("telescope.builtin")
    local utils = require("telescope.utils")

    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind [G]rep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffers" })
    vim.keymap.set("n", "<leader>hf", builtin.help_tags, { desc = "[H]elp Tags [F]ind" })
    vim.keymap.set("n", "<leader>hm", builtin.man_pages, { desc = "[H]elp [M]an Pages" })
    vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
    vim.keymap.set("n", "<leader>ft", builtin.builtin, { desc = "[F]ind [T]elescope" })
    vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind [W]ord current" })
    vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
    vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
    vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
    vim.keymap.set("n", "<leader>fq", builtin.quickfix, { desc = "[F]ind [Q]uickfix List" })
    vim.keymap.set("n", "<leader>fx", builtin.lsp_document_symbols, { desc = "[F]ind Document Symbols" })
    vim.keymap.set("n", "<leader>fy", builtin.lsp_dynamic_workspace_symbols, { desc = "[F]ind Dynamic Workspace Symbols" })
    vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "[/] Fuzzily search in current buffer" })

    vim.keymap.set("n", "<leader>fF", function()
      builtin.find_files({ cwd = utils.buffer_dir() })
    end, { desc = "[F]ind [F]iles Current Dir" })

    vim.keymap.set("n", "<leader>fi", function()
      builtin.find_files({
        find_command = { "rg", "--files", "--hidden", "--no-ignore", "--glob", "!**/.git/*" },
      })
    end, { desc = "[F]ind [I]gnored files" })

    vim.keymap.set("n", "<leader>f/", function()
      builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
      })
    end, { desc = "[F]ind [/] in Open Files" })

    vim.keymap.set("n", "<leader>fn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "[F]ind [N]eovim files" })

    vim.keymap.set("n", "<leader>hg", function()
      builtin.live_grep({
        search_dirs = vim.fn.globpath(vim.o.runtimepath, "doc/*", 1, 1),
        prompt_title = "Live Grep in Help Tags",
      })
    end, { desc = "[H]elp Tags [Grep]" })
  end,
}
