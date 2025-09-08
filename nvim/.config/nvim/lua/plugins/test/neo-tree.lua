-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  branch = 'v3.x',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree position=current reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      hijack_netrw_behavior = 'open_current',
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['oc'] = 'noop',
          ['od'] = 'noop',
          ['og'] = 'noop',
          ['om'] = 'noop',
          ['on'] = 'noop',
          ['os'] = 'noop',
          ['ot'] = 'noop',
        },
      },
    },
    enable_git_status = false,
    enable_diagnostics = false,
    default_component_configs = {
      indent = false,
      -- indent = {
      --   indent_size = 2,
      --   padding = 1, -- extra padding on left hand side
      --   -- indent guides
      --   with_markers = true,
      --   indent_marker = '│',
      --   last_indent_marker = '└',
      --   highlight = 'NeoTreeIndentMarker',
      --   -- expander config, needed for nesting files
      --   with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      --   expander_collapsed = '',
      --   expander_expanded = '',
      --   expander_highlight = 'NeoTreeExpander',
      -- },
      icon = false,
      -- icon = {
      --   folder_closed = '|',
      --   folder_open = '|',
      --   folder_empty = '|',
      --   provider = nil,
      -- },
    },
  },
}
