return {
  { -- 'folke/snacks.nvim'
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      explorer = { enabled = true },
      input = { enabled = true },
      picker = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      --
      words = { enabled = false },
      scope = { enabled = false },
      --
      indent = { enabled = false },
      dashboard = { enabled = false },
      notifier = { enabled = false },
      scroll = { enabled = false },
      lazygit = {},
      -- image = {},
    },
    keys = {
      {
        "<leader>E",
        function()
          Snacks.explorer()
        end,
        desc = "File Explorer",
      },
    },
  },
}
