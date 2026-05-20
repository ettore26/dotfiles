return {
  -- community plugin:
  -- 'epwalsh/obsidian.nvim',
  -- Official fork:
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = 'markdown',
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    'nvim-lua/plenary.nvim',

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    legacy_commands = false,
    sync = {
      enabled = true,
    },
    workspaces = {
      {
        name = 'personal',
        path = '~/Documents/notes',
      },
      -- {
      --   name = 'personal',
      --   path = '~/.local/share/nvim/obsidian/vaults/personal',
      -- },
      -- {
      --   name = 'work',
      --   path = '~/.local/share/nvim/obsidian/vaults/work',
      -- },
    },

    -- completion = {
    --   -- Set to false to disable completion.
    --   nvim_cmp = true,
    --   -- Trigger completion at 2 chars.
    --   min_chars = 2,
    -- },

    ui = {
      enable = false,
    },

    -- Render of checkbox icons lives in render-markdown.nvim
    -- (lua/plugins/extra/markdown.lua). This only controls the toggle order
    -- when cycling states via `<leader>ch` / `<cr>` smart_action.
    checkbox = {
      enabled = true,
      create_new = true,
      order = { ' ', '/', '?', '!', '~', '>', 'x' },
    },

    callbacks = {
      enter_note = function(note)
        local actions = require('obsidian.actions')
        local api = require('obsidian.api')

        -- Toggle check-boxes.
        vim.keymap.set('n', '<leader>ch', actions.toggle_checkbox, {
          buffer = note.bufnr,
          desc = 'Obsidian: toggle checkbox',
        })

        -- Smart action: follow link / toggle checkbox / fold heading / show tag.
        vim.keymap.set('n', '<cr>', actions.smart_action, {
          buffer = note.bufnr,
          expr = true,
          desc = 'Obsidian: smart action',
        })

        -- Override 'gf' to follow markdown/wiki links inside the vault.
        vim.keymap.set('n', 'gf', function()
          if api.cursor_link() then
            return "m'<cmd>Obsidian follow_link<cr>"
          end
          return 'gf'
        end, {
          buffer = note.bufnr,
          expr = true,
          desc = 'Obsidian: follow link or gf',
        })
      end,
    },
  },
}
