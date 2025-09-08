return {
  {
    "m4xshen/hardtime.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      max_time = 5000,
      max_count = 10,
      disabled_filetypes = {
        lazy = false,
        oil = false,
      },
      callback = function(message)
        require("notify")(message, vim.log.levels.WARN)
      end,
    },
  },
}
