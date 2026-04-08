vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true

-- --clean strips the site dir from packpath; vim.pack needs it to packadd installed plugins
vim.opt.packpath:prepend(vim.fn.stdpath("data") .. "/site")

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/mistweaverco/kulala.nvim",
})

vim.loader.enable()

-- Experimental: new messages/cmdline UI (Neovim 0.12+)
require("vim._core.ui2").enable()

require("nvim-treesitter").install({ "http" })

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

require("kulala").setup({
  global_keymaps = true,
  global_keymaps_prefix = "<leader>R",
  kulala_keymaps_prefix = "",
  disable_script_print_output = true,
  kulala_keymaps = { ["Interrupt requests"] = false },
})
