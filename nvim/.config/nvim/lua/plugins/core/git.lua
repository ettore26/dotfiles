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
  --         delete = "",
  --       },
  --     },
  --   },
  -- },

  { -- gitsigns.nvim
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("gitsigns").setup({
        signs = {
            add = "",
            change = "",
            delete = "",
            topdelete = "",
            changedelete = "",
            untracked = "",
        },

        signs_staged_enable = false,

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
          end)

          map("n", "[c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gitsigns.nav_hunk("prev")
            end
          end)

          -- Actions
          map("n", "<leader>hs", gitsigns.stage_hunk)
          map("n", "<leader>hr", gitsigns.reset_hunk)

          map("v", "<leader>hs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end)

          map("v", "<leader>hr", function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end)

          map("n", "<leader>hS", gitsigns.stage_buffer)
          map("n", "<leader>hR", gitsigns.reset_buffer)
          map("n", "<leader>hp", gitsigns.preview_hunk)
          map("n", "<leader>hi", gitsigns.preview_hunk_inline)

          map("n", "<leader>hb", function()
            gitsigns.blame_line({ full = true })
          end)

          map("n", "<leader>hd", gitsigns.diffthis)

          map("n", "<leader>hD", function()
            gitsigns.diffthis("~")
          end)

          map("n", "<leader>hQ", function()
            gitsigns.setqflist("all")
          end)
          map("n", "<leader>hq", gitsigns.setqflist)

          -- Toggles
          map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
          map("n", "<leader>tw", gitsigns.toggle_word_diff)

          -- Text object
          map({ "o", "x" }, "ih", gitsigns.select_hunk)
        end,
      })
    end,
  },
}
