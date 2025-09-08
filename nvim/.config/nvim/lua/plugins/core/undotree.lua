return {
  {
    'mbbill/undotree',
    event = 'VeryLazy',
    opts = {
      vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle),
      -- vim.api.nvim_set_keymap('n', '\\', ':NvimTreeToggle<cr>', { silent = true, noremap = true }),
    },
    config = function() end,
  },
}
