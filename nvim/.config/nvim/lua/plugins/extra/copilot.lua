return {
  -- copilot.vim
  'github/copilot.vim',
  -- event = 'VeryLazy',
  config = function(bufnr)
    vim.g.copilot_enabled = false
  end,
}
