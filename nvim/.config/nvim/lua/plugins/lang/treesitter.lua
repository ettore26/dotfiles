return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs", -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "vim",
        "vimdoc",
        "java",
        "javascript",
        "typescript",
        "rust",
        "glsl",
        "comment",
        "json",
        "yaml",
        "toml",
        "ruby",
        "go",
        "clojure",
        "python"
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { "ruby" },
      },
      indent = { enable = true, disable = { "ruby" } },
      fold = {
        enable = true,
      },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = {
      mode = "cursor",
      max_lines = 3,
      separator = "─",
    },
    -- opts = function()
    --   local tsc = require 'treesitter-context'
    --   Snacks.toggle({
    --     name = 'Treesitter Context',
    --     get = tsc.enabled,
    --     set = function(state)
    --       if state then
    --         tsc.enable()
    --       else
    --         tsc.disable()
    --       end
    --     end,
    --   }):map '<leader>ut'
    --   return { mode = 'cursor', max_lines = 3 }
    -- end,
  },
}
