vim.loader.enable()
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true

-- 0.11.5 fallback: prepend lazy's plugin dirs directly (no vim.pack needed)
local lazy_plugins = vim.fn.stdpath("data") .. "/lazy"
vim.opt.rtp:prepend(lazy_plugins .. "/nvim-treesitter")
vim.opt.rtp:prepend(lazy_plugins .. "/kulala.nvim")

require("nvim-treesitter.configs").setup({
  ensure_installed = { "http" },
  highlight = { enable = true },
})

require("kulala").setup({
  global_keymaps = true,
  global_keymaps_prefix = "<leader>R",
  kulala_keymaps_prefix = "",
  disable_script_print_output = true,
  kulala_keymaps = { ["Interrupt requests"] = false },
})
