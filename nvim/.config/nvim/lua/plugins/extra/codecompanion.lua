return {
  { -- codecompanion.nvim
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "franco-ruggeri/codecompanion-spinner.nvim",
    },
    opts = {
      strategies = {
        -- Change the default chat adapter
        chat = {
          adapter = "anthropic",
        },
      },
      display = {
        chat = {
          -- show_settings = true,
          -- start_in_insert_mode = true,
          auto_scroll = true,
          window = {
            layout = "vertical",
          },
        },
      },
      opts = {
        -- Set debug logging
        log_level = "DEBUG",
      },
      adapters = {
        acp = {
          gemini_cli = function()
            return require("codecompanion.adapters").extend("gemini_cli", {
              commands = {
                flash = {
                  "gemini",
                  "--experimental-acp",
                  "-m",
                  "gemini-2.5-flash",
                },
                pro = {
                  "gemini",
                  "--experimental-acp",
                  "-m",
                  "gemini-2.5-pro",
                },
              },
              defaults = {
                auth_method = "gemini-api-key",
              },
            })
          end,
        },
      },
      extensions = {
        spinner = {},
      },
    },

    config = function(_, opts)
      require("codecompanion").setup(opts)
      vim.keymap.set({ "n" }, "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
      vim.keymap.set({ "v" }, "<leader>a", "<cmd>CodeCompanionChat<cr>", { noremap = true, silent = true })

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
      vim.cmd([[cab cca CodeCompanionActions]])
    end,
  },
}
