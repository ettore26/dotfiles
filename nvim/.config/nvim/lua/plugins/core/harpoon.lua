-- harpoon plugin

return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    -- event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    -- opts = function()
    --
    settings = {
      save_on_toggle = false,
      sync_on_ui_close = true,
    },
    config = function()
      local harpoon = require 'harpoon'
      -- -- REQUIRED

      -- require('harpoon'):setup()
      -- -- REQUIRED
      --
      harpoon:setup {
        settings = {
          save_on_toggle = false,
          sync_on_ui_close = true,
          -- This helps prevent unnamed buffers when using Harpoon
          tabline = false,
          tabline_prefix = '   ',
          tabline_suffix = '   ',
        },
        -- You might want to use these options to ensure files are properly loaded
        -- with their full path, which helps avoid unnamed buffers
        menu = {
          width = vim.api.nvim_win_get_width(0) - 4,
        },
      }

      local toggle_opts = {
        title = ' Harpoon ',
        border = 'rounded',
        title_pos = 'center',
        ui_width_ratio = 0.60,
      }

      vim.keymap.set('n', '<leader>fm', function()
        harpoon.ui:toggle_quick_menu(harpoon:list(), toggle_opts)
      end, { desc = '[F]ind [M]arks Harpoon' })

      vim.keymap.set('n', '<leader>ma', function()
        harpoon:list():add()
      end, { desc = '[M]ark [A]dd' })

      vim.keymap.set('n', '<leader>md', function()
        harpoon:list():remove()
      end, { desc = '[M]ark [D]elete' })

      vim.keymap.set('n', '<C-1>', function()
        harpoon:list():select(1)
      end)
      vim.keymap.set('n', '<C-2>', function()
        harpoon:list():select(2)
      end)
      vim.keymap.set('n', '<C-3>', function()
        harpoon:list():select(3)
      end)
      vim.keymap.set('n', '<C-4>', function()
        harpoon:list():select(4)
      end)
    end,
  },
}
