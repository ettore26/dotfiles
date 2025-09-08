return {
  { -- 'ton/vim-bufsurf'
    'ton/vim-bufsurf',
    config = function()
      vim.keymap.set('n', '<A-n>', '<cmd>BufSurfForward<CR>', { desc = 'Next buffer in history' })
      vim.keymap.set('n', '<A-p>', '<cmd>BufSurfBack<CR>', { desc = 'Previous buffer in history' })
    end,
  },

  -- { -- 'landonb/vim-buffer-ring'
  --   'landonb/vim-buffer-ring',
  --   config = function()
  --     vim.keymap.set('n', '<A-n>', '<cmd>BufferRingForward<CR>', { desc = 'Next buffer in history' })
  --     vim.keymap.set('n', '<A-p>', '<cmd>BufferRingReverse<CR>', { desc = 'Previous buffer in history' })
  --   end,
  -- },
}
