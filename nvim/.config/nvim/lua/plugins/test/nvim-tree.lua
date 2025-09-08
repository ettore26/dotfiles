return {
  'nvim-tree/nvim-tree.lua',
  opts = {

    view = {
      -- fullscreen = true,
      -- adaptive_size = true,
      -- width = '100%',
      keymaps = {

        vim.keymap.set('n', '<F11>', function()
          api.tree.open { current_window = true }
        end, { noremap = true }),
      },
    },
  },
}
