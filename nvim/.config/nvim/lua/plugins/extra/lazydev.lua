-- Lua APIs (resolution)
return {
  { -- folke/lazydev.nvim, Lua APIs
    "folke/lazydev.nvim",
    event = "VeryLazy",
    ft = "lua",
    opts = {
      library = {
        { path = "snacks.nvim", words = { "Snacks" } }, -- Add this line
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        -- Needs `LelouchHe/xmake-luals-addon` to be installed on
        --        ~/.local/share/nvim/mason/packages/lua-language-server/libexec/meta/3rd/
        { path = "${3rd}/xmake-luals-addon/library", files = { "xmake.lua" } },
      },
    },
  },
}
