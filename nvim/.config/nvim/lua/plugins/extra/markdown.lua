return {
  { -- render-markdown.nvim
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
    config = function()
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
