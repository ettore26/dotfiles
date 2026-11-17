return {
  { -- render-markdown.nvim
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
    config = function()
      -- Bujo highlights; `link` ignores other attrs, so extra attrs are merged onto the resolved group
      local function bujo_highlights()
        local hl = function(name, base, extra)
          local v = vim.api.nvim_get_hl(0, { name = base, link = false })
          vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", v, extra or {}))
        end
        hl("BujoMigrated", "DiagnosticInfo")
        hl("BujoScheduled", "Special")
        hl("BujoMigratedText", "Comment")
        hl("BujoCancelled", "Comment")
        hl("BujoCancelledText", "Comment", { strikethrough = true })
        hl("BujoEvent", "DiagnosticWarn")
        hl("BujoPriority", "DiagnosticError", { bold = true })
        hl("BujoIdea", "DiagnosticHint")
      end
      bujo_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = bujo_highlights })

      require("render-markdown").setup({
        file_types = { "markdown", "codecompanion", "Avante", "vimwiki" },
        completions = {
          lsp = {
            enabled = true,
          },
        },
        code = {
          sign = false,
          language = false,
          language_border = "",
          -- highlight = 'none',
          -- highlight_border = 'none',
        },
        checkbox = {
          enabled = true,
          unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownChecked" },
          checked   = { icon = "󰄲 ", highlight = "RenderMarkdownChecked" },
          custom = {
            todo = { raw = "[_]" }, -- move the built-in todo off "[-]" so it can't shadow ours
            -- in_progress = { raw = "[/]", rendered = "󰪞 ", highlight = "RenderMarkdownChecked" },
            -- delayed     = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownChecked" },
            -- question    = { raw = "[?]", rendered = "󰋗 ", highlight = "RenderMarkdownChecked" },
            -- important   = { raw = "[!]", rendered = "󰀦 ", highlight = "RenderMarkdownChecked" },
            -- cancelled   = { raw = "[~]", rendered = "󰩺 ", highlight = "RenderMarkdownChecked" },
            -- forwarded   = { raw = "[>]", rendered = "➤ ", highlight = "RenderMarkdownChecked" },

            -- migrated = { raw = "[>]", rendered = " ", highlight = "RenderMarkdownInfo" },
            -- scheduled = { raw = "[<]", rendered = " ", highlight = "RenderMarkdownHint" },
            -- cancelled = { raw = "[-]", rendered = " ↻ ", highlight = "RenderMarkdownError" },
            -- important = { raw = "[!]", rendered = " ", highlight = "RenderMarkdownWarn" },
            migrated  = { raw = "[>]", rendered = "> ", highlight = "BujoMigrated", scope_highlight = "BujoMigratedText" },
            scheduled = { raw = "[<]", rendered = "< ", highlight = "BujoScheduled", scope_highlight = "BujoMigratedText" },
            cancelled = { raw = "[-]", rendered = "– ", highlight = "BujoCancelled", scope_highlight = "BujoCancelledText" },
            event     = { raw = "[o]", rendered = "○ ", highlight = "BujoEvent" },
            priority  = { raw = "[!]", rendered = "! ", highlight = "BujoPriority", scope_highlight = "BujoPriority" },
            idea      = { raw = "[*]", rendered = "✱ ", highlight = "BujoIdea" },
          },
        },
      })
    end,
  },

  -- { -- markview.nvim
  --   'OXY2DEV/markview.nvim',
  --   lazy = false,
  --   opts = {
  --     preview = {
  --       -- modes = { 'n', 'v', 'i' },
  --       -- modes = { 'n', 'no', 'c', 'i' },
  --       hybrid_modes = { 'n', 'v', 'i' },
  --       filetypes = { 'markdown', 'codecompanion', 'Avante' },
  --       -- filetypes = { 'codecompanion' },
  --       ignore_buftypes = {},
  --     },
  --   },
  -- },
}
