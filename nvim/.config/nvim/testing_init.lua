vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true

-- Ensure packpath includes the site directory (stripped by --clean)
vim.opt.packpath:prepend(vim.fn.stdpath("data") .. "/site")

vim.cmd.packadd("nvim-treesitter")
vim.cmd.packadd("kulala.nvim")

vim.loader.enable()

require("nvim-treesitter").setup({
  ensure_installed = { "http" },
  auto_install = true,
})

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
