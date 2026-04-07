-- comments - uses Neovim's built-in gc/gcc with enhanced treesitter commentstring support
-- ideas https://github.com/catgoose/nvim/blob/main/lua/plugins/comment.lua

return {
  'folke/ts-comments.nvim',
  opts = {},
  event = 'VeryLazy',
}
