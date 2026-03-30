return {
  'stevearc/aerial.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },

  config = function(_, opts)
    require("aerial").setup(opts)
    vim.keymap.set("n", "<leader>s", "<cmd>AerialToggle!<CR>")
  end,
}
