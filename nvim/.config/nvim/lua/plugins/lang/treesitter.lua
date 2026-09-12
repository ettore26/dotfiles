return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = "VeryLazy",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "bash",
        "zsh",
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
        "python",
      })

      -- ft=zsh otherwise claims the tree-sitter zsh parser, whose external
      -- scanner aborts on large histories:
      --   Assertion failed: (size == length), deserialize, scanner.c:475
      -- Reproduces by parsing ~/.zsh_history as a plain string, so it is the
      -- grammar, not highlighting. bash parses the same content fine and is
      -- already installed above.
      vim.treesitter.language.register("bash", "zsh")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = {
      mode = "cursor",
      max_lines = 3,
      separator = "─",
    },
  },
}
