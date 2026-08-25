-- git plugins

-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.

-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following Lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do


-- GIT SIGN PLUGINS PRODUCES THE ERROR: nvim: /builddir/build/BUILD/neovim-0.11.3-build/neovim-0.11.3/src/nvim/decoration.c:1071: buf_signcols_count_range: Assertion `buf->b_signcols.count[prevwidth - 1] >= 0' failed
return {

  { -- vim-fugitive
    "https://github.com/tpope/vim-fugitive",
    event = "VeryLazy",
  },

  -- { -- mini.diff
  --   "echasnovski/mini.diff",
  --   event = "VeryLazy",
  --   keys = {
  --     {
  --       "<leader>go",
  --       function()
  --         require("mini.diff").toggle_overlay(0)
  --       end,
  --       desc = "Toggle mini.diff overlay",
  --     },
  --   },
  --   opts = {
  --     view = {
  --       style = "sign",
  --       signs = {
  --         add = "▎",
  --         change = "▎",
  --         delete = "",
  --       },
  --     },
  --   },
  -- },

  { -- gitsigns.nvim
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("gitsigns").setup({
        -- signs = {
        --     add = "",
        --     change = "",
        --     delete = "",
        --     topdelete = "",
        --     changedelete = "",
        --     untracked = "",
        -- },
        --
        -- signs_staged_enable = false,

        on_attach = function(bufnr)
          local gitsigns = require("gitsigns")

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gitsigns.nav_hunk("next")
            end
          end, { desc = "Jump to next git change" })

          map("n", "[c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gitsigns.nav_hunk("prev")
            end
          end, { desc = "Jump to previous git change" })

          -- Actions
          map("n", "<leader>cs", gitsigns.stage_hunk, { desc = "Git stage hunk" })
          map("n", "<leader>cr", gitsigns.reset_hunk, { desc = "Git reset hunk" })

          map("v", "<leader>cs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "Git stage selected hunk" })

          map("v", "<leader>cr", function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "Git reset selected hunk" })

          map("n", "<leader>cS", gitsigns.stage_buffer, { desc = "Git stage buffer" })
          map("n", "<leader>cR", gitsigns.reset_buffer, { desc = "Git reset buffer" })
          map("n", "<leader>cp", gitsigns.preview_hunk, { desc = "Git preview hunk" })
          map("n", "<leader>ci", gitsigns.preview_hunk_inline, { desc = "Git preview hunk inline" })

          map("n", "<leader>cb", function()
            gitsigns.blame_line({ full = true })
          end, { desc = "Git blame line" })

          map("n", "<leader>cd", gitsigns.diffthis, { desc = "Git diff against index" })

          map("n", "<leader>cD", function()
            gitsigns.diffthis("~")
          end, { desc = "Git diff against last commit" })

          map("n", "<leader>cQ", function()
            gitsigns.setqflist("all")
          end, { desc = "Git hunks to quickfix (all buffers)" })
          map("n", "<leader>cq", gitsigns.setqflist, { desc = "Git hunks to quickfix (current buffer)" })

          -- Toggles
          map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle git blame line" })
          map("n", "<leader>tw", gitsigns.toggle_word_diff, { desc = "Toggle git word diff" })

          -- Text object
          map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "Select git hunk" })
        end,
      })
    end,
  },
}
